# 🧠 Takes a full cron URL and returns a clean job name using:
#   - slugified project name (from $GCP_PROJECT_NAME)
#   - the last segment of the path (e.g., bookeey_transactions)
#
# 📦 Usage:
#   _gcloud_cron_generate_job_name "https://domain/app/cron/something/"
#   → fecarecronjobs_something
function _gcloud_cron_generate_job_name() {
    local url="$1"
    local project_name=$(gcloud_slugify_project_name)
    local cron_path=$(echo "$url" | awk -F '/' '{print $(NF-1)}')
    echo "${project_name}_${cron_path}"
}

# 📝 Converts a cron URL into a human-friendly description like:
#   app.fe-care.com > Store > Bookeey Transactions
#
# 📦 Usage:
#   _gcloud_cron_generate_job_description "https://app.fe-care.com/store/cron/bookeey_transactions/"
function _gcloud_cron_generate_job_description() {
    local url="$1"
    local domain=$(echo "$url" | awk -F '/' '{print $3}')

    # Find app as the part right before "cron"
    local app=$(echo "$url" | awk -F '/' '{for(i=1;i<=NF;i++){if($i=="cron"){print $(i-1); exit}}}')
    local cron_path=$(echo "$url" | awk -F '/' '{print $(NF-1)}')

    # Capitalize app and path nicely
    local app_cap=$(echo "$app" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')
    local path_cap=$(echo "$cron_path" | tr '_' ' ' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')

    echo "$domain > $app_cap > $path_cap"
}

# 🧾 Confirms a list of Cloud Scheduler jobs before creation or deletion.
#
# 📦 Usage:
#   _gcloud_cron_confirm_jobs create "${urls[@]}"
#   _gcloud_cron_confirm_jobs delete "${urls[@]}"
function _gcloud_cron_confirm_jobs() {
    local mode="$1"
    shift
    local urls=("$@")

    local job_names=()
    for url in "${urls[@]}"; do
        job_names+=("$(_gcloud_cron_generate_job_description "$url")")
    done

    local name_list=$(printf "  • %s\n" "${job_names[@]}")
    local verb=$([[ "$mode" == "delete" ]] && echo "Delete" || echo "Create")

    # Properly formatted multiline message
    local message=$(printf "%s %d Cloud Scheduler job(s) in project '%s':\n%s" \
        "$verb" "${#job_names[@]}" "$GCP_PROJECT_ID" "$name_list")

    confirm_or_abort "$message" "$@" || return 1
}

# 🧼 Description:
#   Deletes **all** Cloud Scheduler jobs in the current GCP project and region.
#   This is a destructive operation and should be used with caution.
#
# 💡 Usage:
#   gcloud_schedular_job_delete
function gcloud_schedular_job_delete() {
    gcloud_config_load_and_validate || return 1

    echo "📡 Fetching all Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."
    local urls=($(gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION" \
        --format="value(httpTarget.uri)"))

    if [[ ${#urls[@]} -eq 0 ]]; then
        echo "⚠️  No Cloud Scheduler jobs found. Nothing to delete."
        return 0
    fi

    # Format job list for prompt
    _gcloud_cron_confirm_jobs delete "${urls[@]}" || return 1

    echo "🔹 Deleting ${#urls[@]} job(s)..."

    for url in "${urls[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")
        echo "🔧 Deleting job: $job_name"
        gcloud scheduler jobs delete "$job_name" \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --quiet
    done

    echo "✅ Deleted ${#urls[@]} Cloud Scheduler job(s)."
}

# 🔄 Description:
#   Syncs Cloud Scheduler jobs with your Django cron URLs:
#     - Creates missing jobs
#     - Deletes jobs that no longer exist locally
#
# 💡 Usage:
#   gcloud_schedular_job_update
#
#   Safe and interactive by default (requires confirmation).
function gcloud_schedular_job_update() {
    gcloud_config_load_and_validate || return 1

    echo "🔍 Fetching cron URLs from Django..."
    local local_urls=($(django-find-cron-urls | grep '^https://'))
    declare -A local_jobs

    if [[ ${#local_urls[@]} -eq 0 ]]; then
        echo "⚠️  No local cron URLs found. Will only check for deletions..."
    else
        for url in "${local_urls[@]}"; do
            local job_name=$(_gcloud_cron_generate_job_name "$url")
            local_jobs[$job_name]="$url"
        done
    fi

    echo "📡 Fetching existing Cloud Scheduler jobs..."
    local remote_jobs=($(gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION" \
        --format="value(httpTarget.uri)"))

    # Track jobs to create or delete
    local to_create_urls=()
    local to_delete_urls=()

    # Remote jobs not in local → mark for deletion
    for url in "${remote_jobs[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")
        if [[ -z "${local_jobs[$job_name]}" ]]; then
            to_delete_urls+=("$url")
        fi
    done

    # Local jobs not in remote → mark for creation
    for url in "${local_jobs[@]}"; do
        if ! printf '%s\n' "${remote_jobs[@]}" | grep -q "^$url$"; then
            to_create_urls+=$url
        fi
    done

    # Confirm before making changes
    if [[ ${#to_delete_urls[@]} -gt 0 ]]; then
        _gcloud_cron_confirm_jobs delete "${to_delete_urls[@]}" || return 1
    fi

    if [[ ${#to_create_urls[@]} -gt 0 ]]; then
        _gcloud_cron_confirm_jobs create "${to_create_urls[@]}" || return 1
    fi

    # 🔧 Delete jobs
    for url in "${to_delete_urls[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")
        echo "🗑️  Deleting job: $job_name"
        gcloud scheduler jobs delete "$job_name" \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --quiet
    done

    # 🔧 Create missing jobs
    local schedule="${2:-0 3 * * *}" # Default 3 AM
    for url in "${to_create_urls[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")
        local description=$(_gcloud_cron_generate_job_description "$url")

        echo "➕ Creating job: $job_name"

        gcloud scheduler jobs create http "$job_name" \
            --description="$description" \
            --schedule="$schedule" \
            --uri="$url" \
            --http-method=GET \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --time-zone="Asia/Kuwait" \
            --headers="Authorization=Bearer $GCP_SCHEDULER_TOKEN" \
            --quiet
    done

    if [[ ${#to_create_urls[@]} -eq 0 && ${#to_delete_urls[@]} -eq 0 ]]; then
        echo "🟡 No changes needed. GCP Scheduler is already in sync with your local URLs."
    else
        echo "✅ Update complete:"
        if [[ ${#to_create_urls[@]} -gt 0 ]]; then
            echo "  ➕ ${#to_create_urls[@]} job(s) created"
        fi
        if [[ ${#to_delete_urls[@]} -gt 0 ]]; then
            echo "  🗑️  ${#to_delete_urls[@]} job(s) deleted"
        fi
    fi
}

function gcloud_scheduler_job_list() {
    gcloud_config_load_and_validate || return 1

    echo "📡 Fetching all Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."
    gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION"
}
