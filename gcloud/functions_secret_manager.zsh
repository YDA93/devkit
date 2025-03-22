# Function to create .env file in Secret Manager
# This function creates a new secret in Google Cloud Secret Manager using the contents of the local .env file
# and grants the necessary permissions to the compute service account.
function gcloud_secret_manager_env_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new secret in Secret Manager?" "$@" || return 1

    echo "🔹 Creating a new secret '$GCP_SECRET_NAME' in Secret Manager..."

    # Create .env file in Secret Manager with the contents of the local .env file and specified region
    gcloud secrets create $GCP_SECRET_NAME \
        --data-file=".env" \
        --replication-policy="user-managed" \
        --locations=$GCP_REGION \
        --quiet &&
        gcloud secrets add-iam-policy-binding $GCP_SECRET_NAME \
            --member serviceAccount:$GCP_PROJECT_NUMBER-compute@developer.gserviceaccount.com \
            --role roles/secretmanager.secretAccessor \
            --quiet
}

# Function to update .env file in Secret Manager and disable only active previous versions
# This function adds a new version of the secret in Google Cloud Secret Manager and disables
# all previously active versions to ensure only the latest version remains accessible.
function gcloud_secret_manager_env_update() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to update the secret in Secret Manager?" "$@" || return 1

    echo "🔹 Updating the secret '$GCP_SECRET_NAME' in Secret Manager..."

    # Add a new version of the secret in Secret Manager with the updated .env file
    gcloud secrets versions add $GCP_SECRET_NAME --data-file=".env" --quiet

    # Get the list of all versions (excluding the latest one)
    PREVIOUS_VERSIONS=$(gcloud secrets versions list $GCP_SECRET_NAME --quiet --format="csv(name,state)" | tail -n +3)

    if [[ ! -z "$PREVIOUS_VERSIONS" ]]; then
        while IFS="," read -r version state; do
            # Trim whitespace
            version=$(echo "$version" | xargs)
            state=$(echo "$state" | xargs | tr '[:lower:]' '[:upper:]') # Convert to uppercase

            # Only disable previous versions that are still ENABLED
            if [[ "$state" == "ENABLED" ]]; then
                gcloud secrets versions disable "$version" --secret="$GCP_SECRET_NAME" --quiet
            fi
        done <<<"$PREVIOUS_VERSIONS"
    fi

}

# Function to delete .env file from Secret Manager
# This function permanently deletes a secret from Google Cloud Secret Manager after user confirmation.
function gcloud_secret_manager_env_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the secret from Secret Manager
This action is irreversible and will permanently delete the secret." "$@" || return 1

    echo "🔹 Deleting the secret '$GCP_SECRET_NAME' from Secret Manager..."

    # Delete the secret
    gcloud secrets delete $GCP_SECRET_NAME --quiet
}
