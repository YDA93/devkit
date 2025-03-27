# Function to load and validate GCloud configuration
# Ensures necessary environment variables and secrets are available
function gcloud_config_load_and_validate() {
    local env_file=".env"
    local secrets_dir="/tmp/env_secrets"
    local exported_vars=() # List to track exported variables

    # Ensure the secrets directory exists
    mkdir -p "$secrets_dir"
    chmod 700 "$secrets_dir"

    # Check if .env file exists
    if [ ! -f "$env_file" ]; then
        echo "❌ Error: .env file not found."
        return 1
    fi

    # Read the .env file line by line
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        # Skip empty lines or comments
        [[ -z "$key" || "$key" =~ ^# ]] && continue

        # Strip potential surrounding quotes
        value="${value%\"}"
        value="${value#\"}"

        # Detect if value contains a multi-line pattern
        if [[ "$value" == *"\n"* || "$value" == "{"* || "$value" == "-----BEGIN "* ]]; then
            secret_file="$secrets_dir/$key.pem"

            # Ensure clean filename (no special characters)
            secret_file=$(echo "$secret_file" | tr -d '[:space:][:cntrl:]')

            # Convert escaped `\n` into actual newlines and write to file
            printf "%b" "${value//\\n/$'\n'}" >"$secret_file"

            # Secure the file
            chmod 600 "$secret_file"

            # Read content into an environment variable
            export "$key"="$(cat "$secret_file")"

            # Delete the temporary file
            rm -f "$secret_file"

            # Track exported variables
            exported_vars+=("$key (exported directly, file deleted)")
        else
            # Export normal key-value pairs directly
            export "$key=$value"
            exported_vars+=("$key (exported directly)")
        fi
    done <"$env_file"
}

# 🧼 Converts $GCP_PROJECT_NAME into a safe, lowercase, GCP-friendly slug
# - Removes spaces
# - Lowercases everything
# - Keeps only a-z, 0-9, _ and -
# -----------------------------------------------------------------------------
function _gcloud_slugify_project_name() {
    echo "$GCP_PROJECT_NAME" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g'
}

# ------------------------------------------------------------------------------
# ☁️ Google Cloud Platform - Django Project Shortcuts
# ------------------------------------------------------------------------------

# Function to set up a Django application in Google Cloud
# This function performs all required steps including creating a database, storage, and deploying the app
function gcloud_project_django_setup {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Set up a Django project in Google Cloud?" "$@" || return 1

    gcloud-login-cli || return 1
    gcloud-login-adc || return 1

    # Step 1: Create a new Cloud SQL for PostgreSQL instance
    if ! gcloud_sql_instance_create --quiet; then
        echo "❌ Error creating Cloud SQL instance."
        return 1
    fi

    # Step 2: Create database and user in Cloud SQL for PostgreSQL
    if ! gcloud_sql_db_and_user_create --quiet; then
        echo "❌ Error creating database and user in Cloud SQL instance."
        return 1
    fi

    # Step 3: Create Artifact Registry repository
    if ! gcloud_artifact_registry_repository_create --quiet; then
        echo "❌ Error creating Artifact Registry repository."
        return 1
    fi

    # Step 4: Create Cloud Storage buckets
    if ! gcloud_storage_buckets_create --quiet; then
        echo "❌ Error creating Cloud Storage buckets."
        return 1
    fi

    # Step 5: Create Cloud Secret Manager secret
    if ! gcloud_secret_manager_env_create --quiet; then
        echo "❌ Error creating Secret Manager secret."
        return 1
    fi

    # Step 6: Start the Cloud SQL Proxy in a separate terminal and apply migrations and initial data to the database
    if ! gcloud_sql_proxy_and_django_setup --quiet; then
        echo "❌ Error starting the Cloud SQL Proxy and applying migrations."
        return 1
    fi

    # Step 7: Build and deploy the service to Cloud Run
    if ! gcloud_run_build_and_deploy_initial --quiet; then
        echo "❌ Error building and deploying the service to Cloud Run."
        return 1
    fi

    # Step 8: Setup Cloud Load Balancer
    if ! gcloud_compute_engine_cloud_load_balancer_setup --quiet; then
        echo "❌ Error setting up the Cloud Load Balancer."
        return 1
    fi

    # Step 9: Create Cloud Scheduler jobs case exists
    if ! gcloud_scheduler_jobs_sync --quiet; then
        echo "❌ Error syncing Cloud Scheduler job."
        return 1
    fi

    echo "🎉 Django project in Google Cloud has been successfully set up!"

}

# Function to tear down the Django setup in Google Cloud
# Deletes all resources including the database, storage, and Cloud Run service
function gcloud_project_django_teardown {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Tear down the Django project in Google Cloud?" "$@" || return 1

    gcloud-login-cli || return 1
    gcloud-login-adc || return 1

    # Step 1: Delete Cloud Scheduler job
    gcloud_scheduler_jobs_delete --quiet

    # Step 2: Delete Cloud Load Balancer
    gcloud_compute_engine_cloud_load_balancer_teardown --quiet || echo "❌ Error deleting the Cloud Load Balancer."

    # Step 3: Delete Cloud Run service
    gcloud_run_service_delete --quiet || echo "❌ Error deleting the Cloud Run service."

    # Step 4: Delete Cloud Secret Manager secret
    gcloud_secret_manager_env_delete --quiet || echo "❌ Error deleting the Secret Manager secret."

    # Step 5: Delete Cloud Storage buckets
    gcloud_storage_buckets_delete --quiet || echo "❌ Error deleting Cloud Storage buckets."

    # Step 6: Delete Artifact Registry repository
    gcloud_artifact_registry_repository_delete --quiet || echo "❌ Error deleting Artifact Registry repository."

    # Step 7: Delete Cloud SQL for PostgreSQL instance
    gcloud_sql_instance_delete --quiet || echo "❌ Error deleting Cloud SQL instance."

}

# Function to update an existing Django deployment in Google Cloud
# This function redeploys the latest version, updates secrets, and syncs storage
function gcloud_project_django_update {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Update an existing Django deployment in Google Cloud?" "$@" || return 1

    gcloud-login-cli || return 1
    gcloud-login-adc || return 1

    # Step 1: Build and deploy the latest image to Cloud Run
    if ! gcloud_run_build_and_deploy_latest --quiet; then
        echo "❌ Error building and deploying the latest image to Cloud Run."
        return 1
    fi

    # Step 2: Update Cloud Secret Manager secret
    if ! gcloud_secret_manager_env_update --quiet; then
        echo "❌ Error updating the Secret Manager secret."
        return 1
    fi

    # Step 3: Update the service URLs environment variable in Cloud Run
    if ! gcloud_run_set_service_urls_env --quiet; then
        echo "❌ Error updating the Cloud Run service URLs environment variable."
        return 1
    fi

    # Step 4: Update Cloud Storage buckets
    if ! gcloud_storage_buckets_sync_static --quiet; then
        echo "❌ Error updating Cloud Storage buckets."
        return 1
    fi

    # Step 5: Sync Cloud Scheduler jobs
    if ! gcloud_scheduler_jobs_sync --quiet; then
        echo "❌ Error syncing Cloud Scheduler jobs."
        return 1
    fi
}
