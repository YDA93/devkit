# Function to ask the user if they want to continue or abort, with a custom message
function ask_continue_with_message() {
    local message="$1" # Message describing the next step
    echo "➡️  Next: $message"
    echo -n "Do you want to continue? (yes/no): "
    read CONFIRMATION

    # Convert input to lowercase
    CONFIRMATION=$(echo "$CONFIRMATION" | tr '[:upper:]' '[:lower:]')

    if [[ "$CONFIRMATION" != "yes" ]]; then
        echo "❌ Skipping this step."
        return 1 # Stop execution of the calling function
    fi
}

# Function to load and validate the configuration from the .env file
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

# Function to setup the Django project on Google Cloud Platform
function gcloud_django_setup {
    # Step 1: Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Step 2: Create a new Cloud SQL for PostgreSQL instance
    ask_continue_with_message "Create a new Cloud SQL instance for PostgreSQL." || return 1
    gcloud_sql_instance_create

    # Step 3: Create database and user in Cloud SQL for PostgreSQL
    ask_continue_with_message "Create a new database and user in Cloud SQL for PostgreSQL." || return 1
    gcloud_sql_db_and_user_create

    # Step 4: Create Artifact Registry repository
    ask_continue_with_message "Create a new Artifact Registry repository." || return 1
    gcloud_artifact_registry_repository_create

    # Step 5: Create Cloud Storage buckets
    ask_continue_with_message "Create new Cloud Storage buckets." || return 1
    gcloud_storage_buckets_create

    # Step 6: Create Cloud Secret Manager secret
    ask_continue_with_message "Create a new Secret Manager secret." || return 1
    gcloud_secret_manager_env_create

    # Step 7: Create Cloud Run service
    ask_continue_with_message "Build and deploy the service to Cloud Run for the first time." || return 1
    gcloud_run_build_and_deploy_initial

    # Step 8: Start the Cloud SQL Proxy in a separate terminal and apply migrations and initial data to the database
    ask_continue_with_message "Start the Cloud SQL Proxy in a separate terminal, then apply database migrations and populate the database with initial data." || return 1
    gcloud_sql_proxy_and_django_setup
}

# Function to delete the Django project from Google Cloud Platform
function gcloud_django_teardown {
    # Step 1: Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Step 2: Delete Cloud Run service
    ask_continue_with_message "Delete the Cloud Run service." || return 1
    gcloud_run_service_delete

    # Step 3: Delete Cloud Secret Manager secret
    ask_continue_with_message "Delete the Secret Manager secret." || return 1
    gcloud_secret_manager_env_delete

    # Step 4: Delete Cloud Storage buckets
    ask_continue_with_message "Delete the Cloud Storage buckets." || return 1
    gcloud_storage_buckets_delete

    # Step 5: Delete Artifact Registry repository
    ask_continue_with_message "Delete the Artifact Registry repository." || return 1
    gcloud_artifact_registry_repository_delete

    # Step 6: Delete Cloud SQL for PostgreSQL instance
    ask_continue_with_message "Delete the Cloud SQL instance." || return 1
    gcloud_sql_instance_delete

}

# Function to update the Django project on Google Cloud Platform
function gcloud_django_update {
    # Step 1: Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Step 2: Build and deploy the latest image to Cloud Run
    ask_continue_with_message "Build and deploy the latest image to Cloud Run." || return 1
    gcloud_run_build_and_deploy_latest

    # Step 3: Update Cloud Secret Manager secret
    ask_continue_with_message "Update the Secret Manager secret." || return 1
    gcloud_secret_manager_env_update

    # Step 4: Update Cloud Storage buckets
    ask_continue_with_message "Update the Cloud Storage buckets." || return 1
    gcloud_storage_buckets_sync_static
}
