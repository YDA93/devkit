# ------------------------------------------------------------------------------
# 📆 Google Cloud Scheduler Utilities
# ------------------------------------------------------------------------------

# 🔤 Generates a job name based on the project and cron URL path
# 💡 Usage: _gcloud-scheduler-jobs-generate-name "https://..."
function _gcloud-scheduler-jobs-generate-name() {
    local url="$1"
    local project_name=$(_gcloud-slugify-project-name)
    local cron_path=$(echo "$url" | awk -F '/' '{print $(NF-1)}')
    echo "${project_name}_${cron_path}"
}

# 📝 Converts a cron URL into a human-readable job description
# 💡 Usage: _gcloud-scheduler-jobs-generate-description "https://..."
function _gcloud-scheduler-jobs-generate-description() {
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

# ✅ Prompts user to confirm Cloud Scheduler job creation/deletion
# 💡 Usage: _gcloud-scheduler-jobs-prompt [create|delete] <url...>
function _gcloud-scheduler-jobs-prompt() {
    local mode="$1"
    shift
    local urls=("$@")

    local job_names=()
    for url in "${urls[@]}"; do
        job_names+=("$(_gcloud-scheduler-jobs-generate-description "$url")")
    done

    local name_list=$(printf "  • %s\n" "${job_names[@]}")
    local verb=$([[ "$mode" == "delete" ]] && echo "Delete" || echo "Create")

    # Properly formatted multiline message
    local message=$(printf "%s %d Cloud Scheduler job(s) in project '%s':\n%s" \
        "$verb" "${#job_names[@]}" "$GCP_PROJECT_ID" "$name_list")

    _confirm-or-abort "$message" "$@" || return 1
}

# 🗑️ Deletes all Cloud Scheduler jobs in the current project and region
# 💡 Usage: gcloud-scheduler-jobs-delete
function gcloud-scheduler-jobs-delete() {
    gcloud-config-load-and-validate || return 1

    _log-info "📡 Fetching all Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."
    local urls=($(gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION" \
        --format="value(httpTarget.uri)"))

    if [[ ${#urls[@]} -eq 0 ]]; then
        _log-warning "⚠️  No Cloud Scheduler jobs found. Nothing to delete."
        return 0
    fi

    # Format job list for prompt
    _gcloud-scheduler-jobs-prompt delete "${urls[@]}" "$@" || return 1

    _log-info "🔹 Deleting ${#urls[@]} job(s)..."

    for url in "${urls[@]}"; do
        local job_name=$(_gcloud-scheduler-jobs-generate-name "$url")
        _log-info "🔧 Deleting job: $job_name"
        gcloud scheduler jobs delete "$job_name" \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --quiet
    done

    _log-success "✓ Deleted ${#urls[@]} Cloud Scheduler job(s)."
}

# 🔄 Syncs local Django cron jobs with Cloud Scheduler (create/delete as needed)
# 💡 Usage: gcloud-scheduler-jobs-sync
function gcloud-scheduler-jobs-sync() {
    gcloud-config-load-and-validate || return 1

    _log-info "🔹 Syncing Cloud Scheduler with Django cron URLs..."

    _log-info "🔍 Fetching cron URLs from Django..."
    local local_urls=($(django-find-cron-urls | grep '^https://'))
    declare -A local_jobs

    if [[ ${#local_urls[@]} -eq 0 ]]; then
        _log-warning "⚠️  No local cron URLs found. Will only check for deletions..."
    else
        _log-info "🔍 Found ${#local_urls[@]} local cron job(s):"
        for url in "${local_urls[@]}"; do
            local job_name=$(_gcloud-scheduler-jobs-generate-name "$url")
            local_jobs[$job_name]="$url"
            _log-info "  • $(_gcloud-scheduler-jobs-generate-description "$url")"
        done
    fi
    echo ""

    _log-info "📡 Fetching existing Cloud Scheduler jobs..."
    local remote_jobs=($(gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION" \
        --format="value(httpTarget.uri)"))

    if [[ ${#remote_jobs[@]} -eq 0 ]]; then
        _log-warning "⚠️  No Cloud Scheduler jobs found. Will only check for creations..."
    else
        _log-info "📡 Found ${#remote_jobs[@]} Cloud Scheduler job(s):"
        for url in "${remote_jobs[@]}"; do
            local description=$(_gcloud-scheduler-jobs-generate-description "$url")
            _log-info "  • $description"
        done
    fi
    echo ""

    # Track jobs to create or delete
    local to_create_urls=()
    local to_delete_urls=()

    # Remote jobs not in local → mark for deletion
    for url in "${remote_jobs[@]}"; do
        local job_name=$(_gcloud-scheduler-jobs-generate-name "$url")
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
        _gcloud-scheduler-jobs-prompt delete "${to_delete_urls[@]}" "$@" || return 1
    fi

    if [[ ${#to_create_urls[@]} -gt 0 ]]; then
        _gcloud-scheduler-jobs-prompt create "${to_create_urls[@]}" "$@" || return 1
    fi

    # 🔧 Delete jobs
    for url in "${to_delete_urls[@]}"; do
        local job_name=$(_gcloud-scheduler-jobs-generate-name "$url")
        _log-info "🗑️  Deleting job: $job_name"
        gcloud scheduler jobs delete "$job_name" \
            --project="$GCP_PROJECT_ID" \
            --location="$GCP_REGION" \
            --quiet
    done

    # 🔧 Create missing jobs
    local schedule="${2:-0 3 * * *}" # Default 3 AM
    for url in "${to_create_urls[@]}"; do
        local job_name=$(_gcloud-scheduler-jobs-generate-name "$url")
        local description=$(_gcloud-scheduler-jobs-generate-description "$url")

        _log-info "➕ Creating job: $job_name"

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
        _log-success "🟡 No changes needed. GCP Scheduler is already in sync with your local URLs."
    else
        _log-success "✓ Update complete:"
        if [[ ${#to_create_urls[@]} -gt 0 ]]; then
            _log-success "  ➕ ${#to_create_urls[@]} job(s) created"
        fi
        if [[ ${#to_delete_urls[@]} -gt 0 ]]; then
            _log-success "  🗑️  ${#to_delete_urls[@]} job(s) deleted"
        fi
    fi
}

# 📋 Lists all Cloud Scheduler jobs in the current project and region
# 💡 Usage: gcloud-scheduler-jobs-list
function gcloud-scheduler-jobs-list() {
    gcloud-config-load-and-validate || return 1

    _log-info "📡 Fetching all Cloud Scheduler jobs in project '$GCP_PROJECT_ID'..."
    gcloud scheduler jobs list \
        --project="$GCP_PROJECT_ID" \
        --location="$GCP_REGION"
}
