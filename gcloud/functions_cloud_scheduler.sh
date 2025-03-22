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

}

# 🧼 Description:
#   Deletes all GCP Cloud Scheduler jobs that match the cron URLs found in your
#   Django project (using `django-find-cron-urls`). Each job name is generated
#   using the $GCP_PROJECT_NAME and the cron endpoint.
#
# 💡 Usage:
#   gcloud_schedular_job_delete
function gcloud_schedular_job_delete() {
    gcloud_config_load_and_validate || return 1
    local project_name=$(gcloud_slugify_project_name)

    echo "🔍 Fetching cron URLs from Django..."
    local urls=($(django-find-cron-urls | grep '^https://'))

    if [[ ${#urls[@]} -eq 0 ]]; then
        echo "⚠️  No cron URLs found. No jobs to delete."
        return 0
    fi

    _gcloud_cron_confirm_jobs delete "${urls[@]}" "$@" || return 1

    echo "🔹 Deleting ${#urls[@]} Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."

    for url in "${urls[@]}"; do
        local job_name=$(_gcloud_cron_generate_job_name "$url")

        echo "🔧 Deleting job: $job_name"

        gcloud scheduler jobs delete "$job_name" \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --quiet
    done

}
