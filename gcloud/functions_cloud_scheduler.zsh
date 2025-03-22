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
#   app.fe-care.com > Store > Cron > Bookeey Transactions
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

    echo "$domain > $app_cap > Cron > $path_cap"
}

# 🧾 Confirms a list of Cloud Scheduler jobs before creation or deletion.
#
# 📦 Usage:
#   _gcloud_cron_confirm_jobs create "${urls[@]}"
#   _gcloud_cron_confirm_jobs delete "${urls[@]}"
#
#   This will:
#     - Generate job names from URLs
#     - Show a bullet list of the job names
#     - Ask for user confirmation
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

# 🔧 Description:
#   Uses `django-find-cron-urls` to extract all cron URLs defined in your Django
#   project (based on INTERNAL_APPS), then creates a Cloud Scheduler job in GCP
#   for each one using `gcloud scheduler jobs create http`.
#
# 💡 Usage:
#   gcloud_schedular_job_create
#
#   Defaults:
#     schedule: "0 3 * * *" → Every day at 3:00 AM Kuwait time
function gcloud_schedular_job_create() {
    gcloud_config_load_and_validate || return 1

    local project_name=$(gcloud_slugify_project_name)
    local schedule="${2:-0 3 * * *}" # 🕒 Default: 3 AM daily (Kuwait time)

    echo "🔍 Fetching cron URLs from Django..."
    # 📥 Capture only URLs (not log lines) returned by django-find-cron-urls
    local urls=($(django-find-cron-urls | grep '^https://'))

    if [[ ${#urls[@]} -eq 0 ]]; then
        echo "⚠️  No cron URLs found. No jobs created."
        return 0
    fi

    _gcloud_cron_confirm_jobs create "${urls[@]}" "$@" || return 1

    echo "🔹 Creating ${#urls[@]} Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."

    for url in "${urls[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")
        local description=$(_gcloud_cron_generate_job_description "$url")

        echo "🔧 Creating job: $job_name"

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

    echo "✅ Created ${#urls[@]} Cloud Scheduler job(s)."

}

# 🧼 Description:
#   Deletes **all** Cloud Scheduler jobs in the current GCP project and region.
#   This is a destructive operation and should be used with caution.
#
# 💡 Usage:
#   gcloud_schedular_job_delete
#
#   This will:
#     - List all Cloud Scheduler jobs in the current project/region
#     - Prompt the user to confirm deletion
#     - Delete each job one-by-one using `gcloud scheduler jobs delete`
#
# ⚠️ Warning:
#   - This deletes all scheduled jobs, not just Django cron jobs
#   - Only use in environments where this is safe and intended
function gcloud_schedular_job_delete() {
    gcloud_config_load_and_validate || return 1

    echo "📡 Fetching all Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."
    local jobs=($(gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION" \
        --format="value(name)"))

    if [[ ${#jobs[@]} -eq 0 ]]; then
        echo "⚠️  No Cloud Scheduler jobs found. Nothing to delete."
        return 0
    fi

    # Format job list for prompt
    local job_list=$(printf "  • %s\n" "${jobs[@]}")
    local message=$(printf "This will permanently delete %d Cloud Scheduler job(s) in '%s':\n%s" \
        "${#jobs[@]}" "$GCP_PROJECT_ID" "$job_list")
    confirm_or_abort "$message" || return 1

    echo "🔹 Deleting ${#jobs[@]} job(s)..."

    for job in "${jobs[@]}"; do
        echo "🔧 Deleting job: $job"
        gcloud scheduler jobs delete "$job" \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --quiet
    done

    echo "✅ Deleted ${#jobs[@]} Cloud Scheduler job(s)."
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

    if [[ ${#local_urls[@]} -eq 0 ]]; then
        echo "⚠️  No local cron URLs found. Aborting update."
        return 1
    fi

    declare -A local_jobs
    for url in "${local_urls[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")
        local_jobs[$job_name]="$url"  # ✅ proper Zsh associative array key
    done

    echo "📡 Fetching existing Cloud Scheduler jobs..."
    local remote_jobs_output
    remote_jobs_output=$(gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION" \
        --format="value(name.basename())")

    local remote_jobs
    remote_jobs=(${(f)remote_jobs_output})

    # Track jobs to create or delete
    local to_create_urls=()
    local to_delete_jobs=()

    # Remote jobs not in local → mark for deletion
    for job in "${remote_jobs[@]}"; do
        if [[ -z "${local_jobs[$job]}" ]]; then
            to_delete_jobs+=("$job")
        fi
    done

    # Local jobs not in remote → mark for creation
    for job in "${(@k)local_jobs}"; do
        if ! printf '%s\n' "${remote_jobs[@]}" | grep -q "^$job$"; then
            to_create_urls+=("${local_jobs[$job]}")
        fi
    done

    # Confirm before making changes
    if [[ ${#to_delete_jobs[@]} -gt 0 ]]; then
        local delete_descriptions=()
        for job in "${to_delete_jobs[@]}"; do
            delete_descriptions+=("$job")
        done
        local delete_msg=$(printf "  • %s\n" "${delete_descriptions[@]}")
        confirm_or_abort "⚠️  The following GCP cron jobs will be deleted:\n$delete_msg" || return 1
    fi

    if [[ ${#to_create_urls[@]} -gt 0 ]]; then
        _gcloud_cron_confirm_jobs create "${to_create_urls[@]}" || return 1
    fi

    # 🔧 Delete jobs
    for job in "${to_delete_jobs[@]}"; do
        echo "🗑️  Deleting job: $job"
        gcloud scheduler jobs delete "$job" \
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

    echo "✅ Update complete: ${#to_create_urls[@]} job(s) created, ${#to_delete_jobs[@]} job(s) deleted."
}