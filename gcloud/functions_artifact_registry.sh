# Function to create Artifact Registry
function gcloud_artifact_registry_repository_create() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Create Artifact Registry
    gcloud artifacts repositories create $GS_ARTIFACT_REGISTRY_NAME \
        --repository-format=docker \
        --location=$GS_ARTIFACT_REGISTRY_REGION \
        --description="Artifact Registry for $OFFICIAL_DOMAIN"
}

# Function to delete Artifact Registry
function gcloud_artifact_registry_repository_delete() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Delete Artifact Registry
    gcloud artifacts repositories delete $GS_ARTIFACT_REGISTRY_NAME \
        --location=$GS_ARTIFACT_REGISTRY_REGION
}
