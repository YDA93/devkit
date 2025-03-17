# Function to create .env file in Secret Manager
function gcloud_secret_manager_env_create() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Create .env file in Secret Manager with the contents of the local .env file and specified region
    gcloud secrets create $SECRET_FILE_NAME \
        --data-file=".env" \
        --replication-policy="user-managed" \
        --locations=$GS_SECRET_MANAGER_REGION

    gcloud secrets add-iam-policy-binding $SECRET_FILE_NAME \
        --member serviceAccount:$GS_PROJECT_NUMBER-compute@developer.gserviceaccount.com \
        --role roles/secretmanager.secretAccessor
}

# Function to update .env file in Secret Manager and disable only active previous versions
function gcloud_secret_manager_env_update() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Add a new version of the secret in Secret Manager with the updated .env file
    gcloud secrets versions add $SECRET_FILE_NAME --data-file=".env"

    echo "✅ Secret '$SECRET_FILE_NAME' updated successfully!"

    # Get the list of all versions (excluding the latest one)
    PREVIOUS_VERSIONS=$(gcloud secrets versions list $SECRET_FILE_NAME --format="csv(name,state)" | tail -n +3)

    if [[ ! -z "$PREVIOUS_VERSIONS" ]]; then
        while IFS="," read -r version state; do
            # Trim whitespace
            version=$(echo "$version" | xargs)
            state=$(echo "$state" | xargs | tr '[:lower:]' '[:upper:]') # Convert to uppercase

            # Only disable previous versions that are still ENABLED
            if [[ "$state" == "ENABLED" ]]; then
                gcloud secrets versions disable "$version" --secret="$SECRET_FILE_NAME"
                echo "⚠️ Disabled previous secret version: $version"
            else
                echo "✅ Skipped already disabled secret version: $version"
            fi
        done <<<"$PREVIOUS_VERSIONS"
    fi

    echo "✅ All previous active versions have been disabled!"
}

# Function to delete .env file from Secret Manager
function gcloud_secret_manager_env_delete() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Ask for user confirmation before deleting the secret
    echo "⚠️ Are you sure you want to delete the secret '$SECRET_FILE_NAME'? This action is irreversible. (yes/no):"
    read CONFIRMATION

    # Convert input to lowercase
    CONFIRMATION=$(echo "$CONFIRMATION" | tr '[:upper:]' '[:lower:]')

    if [[ "$CONFIRMATION" == "yes" ]]; then
        # Delete the secret
        gcloud secrets delete $SECRET_FILE_NAME

    else
        echo "❌ Operation cancelled by user."
    fi
}
