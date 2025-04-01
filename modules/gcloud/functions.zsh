# ------------------------------------------------------------------------------
# ☁️ Google Cloud Platform (GCP) Configuration
# ------------------------------------------------------------------------------

# ☁️ Loads GCloud config from .env and validates secrets
# - Parses .env values
# - Supports multiline secret decoding into secure exports
# 💡 Internal utility – used by higher-level GCP commands
function gcloud-config-load-and-validate() {
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

# 🧼 Converts GCP project name into a clean, lowercase slug
# - Removes spaces and special characters
# 💡 Internal utility – used in naming conventions
function _gcloud-slugify-project-name() {
    echo "$GCP_PROJECT_NAME" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g'
}

# ------------------------------------------------------------------------------
# 🛠️ GCP Django Deployment Shortcuts
# ------------------------------------------------------------------------------

# 🚀 Sets up a complete Django project on Google Cloud
# - Creates SQL, buckets, secrets, and deploys to Cloud Run
# 💡 Usage: gcloud-project-django-setup
function gcloud-project-django-setup() {
    gcloud-config-load-and-validate || return 1

    local log_file="gcloud_setup_$(date +'%Y%m%d%H%M%S').log"
    {
        _confirm-or-abort "Set up a Django project in Google Cloud?" "$@" || return 1

        gcloud-login-cli || return 1
        gcloud-login-adc || return 1

        # Step 1: Create a new Cloud SQL for PostgreSQL instance
        if ! gcloud-sql-instance-create --quiet; then
            echo "❌ Error creating Cloud SQL instance."
            return 1
        fi

        # Step 2: Create database and user in Cloud SQL for PostgreSQL
        if ! gcloud-sql-db-and-user-create --quiet; then
            echo "❌ Error creating database and user in Cloud SQL instance."
            return 1
        fi

        # Step 3: Create Artifact Registry repository
        if ! gcloud-artifact-registry-repository-create --quiet; then
            echo "❌ Error creating Artifact Registry repository."
            return 1
        fi

        # Step 4: Create Cloud Storage buckets
        if ! gcloud-storage-buckets-create --quiet; then
            echo "❌ Error creating Cloud Storage buckets."
            return 1
        fi

        # Step 5: Create Cloud Secret Manager secret
        if ! gcloud-secret-manager-env-create --quiet; then
            echo "❌ Error creating Secret Manager secret."
            return 1
        fi

        # Step 6: Start the Cloud SQL Proxy in a separate terminal and apply migrations and initial data to the database
        if ! gcloud-sql-proxy-and-django-setup --quiet; then
            echo "❌ Error starting the Cloud SQL Proxy and applying migrations."
            return 1
        fi

        # Step 7: Build and deploy the service to Cloud Run
        if ! gcloud-run-build-and-deploy-initial --quiet; then
            echo "❌ Error building and deploying the service to Cloud Run."
            return 1
        fi

        # Step 8: Setup Cloud Load Balancer
        if ! gcloud-compute-engine-cloud-load-balancer-setup --quiet; then
            echo "❌ Error setting up the Cloud Load Balancer."
            return 1
        fi

        # Step 9: Create Cloud Scheduler jobs case exists
        if ! gcloud-scheduler-jobs-sync --quiet; then
            echo "❌ Error syncing Cloud Scheduler job."
            return 1
        fi

        echo "🎉 Django project in Google Cloud has been successfully set up!"
    } 2>&1 | tee -a "$log_file"
}

# 💣 Tears down all GCP resources used by the Django project
# - Destroys Cloud SQL, Run, buckets, secrets, etc.
# 💡 Usage: gcloud-project-django-teardown
function gcloud-project-django-teardown() {
    gcloud-config-load-and-validate || return 1
    local log_file="gcloud_teardown_$(date +'%Y%m%d%H%M%S').log"
    {
        _confirm-or-abort "Tear down the Django project in Google Cloud?" "$@" || return 1

        gcloud-login-cli || return 1
        gcloud-login-adc || return 1

        # Step 1: Delete Cloud Scheduler job
        gcloud-scheduler-jobs-delete --quiet

        # Step 2: Delete Cloud Load Balancer
        gcloud-compute-engine-cloud-load-balancer-teardown --quiet || echo "❌ Error deleting the Cloud Load Balancer."

        # Step 3: Delete Cloud Run service
        gcloud-run-service-delete --quiet || echo "❌ Error deleting the Cloud Run service."

        # Step 4: Delete Cloud Secret Manager secret
        gcloud-secret-manager-env-delete --quiet || echo "❌ Error deleting the Secret Manager secret."

        # Step 5: Delete Cloud Storage buckets
        gcloud-storage-buckets-delete --quiet || echo "❌ Error deleting Cloud Storage buckets."

        # Step 6: Delete Artifact Registry repository
        gcloud_artifact_registry_repository_delete --quiet || echo "❌ Error deleting Artifact Registry repository."

        # Step 7: Delete Cloud SQL for PostgreSQL instance
        gcloud-sql-instance-delete --quiet || echo "❌ Error deleting Cloud SQL instance."

    } 2>&1 | tee -a "$log_file"

}

# 🔁 Updates an existing Django project on Google Cloud
# - Redeploys image, updates secrets, storage, and scheduler
# 💡 Usage: gcloud-project-django-update
function gcloud-project-django-update() {
    gcloud-config-load-and-validate || return 1
    local log_file="gcloud_update_$(date +'%Y%m%d%H%M%S').log"
    {
        _confirm-or-abort "Update an existing Django deployment in Google Cloud?" "$@" || return 1

        gcloud-login-cli || return 1
        gcloud-login-adc || return 1

        # Step 1: Build and deploy the latest image to Cloud Run
        if ! gcloud-run-build-and-deploy-latest --quiet; then
            echo "❌ Error building and deploying the latest image to Cloud Run."
            return 1
        fi

        # Step 2: Update Cloud Secret Manager secret
        if ! gcloud-secret-manager-env-update --quiet; then
            echo "❌ Error updating the Secret Manager secret."
            return 1
        fi

        # Step 3: Update the service URLs environment variable in Cloud Run
        if ! gcloud-run-set-service-urls-env --quiet; then
            echo "❌ Error updating the Cloud Run service URLs environment variable."
            return 1
        fi

        # Step 4: Update Cloud Storage buckets
        if ! gcloud-storage-buckets-sync-static --quiet; then
            echo "❌ Error updating Cloud Storage buckets."
            return 1
        fi

        # Step 5: Sync Cloud Scheduler jobs
        if ! gcloud-scheduler-jobs-sync --quiet; then
            echo "❌ Error syncing Cloud Scheduler jobs."
            return 1
        fi

    } 2>&1 | tee -a "$log_file"
}
