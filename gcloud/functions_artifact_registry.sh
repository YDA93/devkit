# Function to create an Artifact Registry repository for storing Docker images
# This is necessary for deploying applications with Cloud Run or Kubernetes
function gcloud_artifact_registry_repository_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new Artifact Registry repository?" "$@" || return 1

    echo "🔹 Creating a new Artifact Registry repository..."

    # Create the Artifact Registry repository for Docker images
    gcloud artifacts repositories create $GCP_ARTIFACT_REGISTRY_NAME \
        --repository-format=docker \
        --location=$GCP_ARTIFACT_REGISTRY_REGION \
        --description="Artifact Registry for $OFFICIAL_DOMAIN" \
        --quiet
}

# Function to delete an existing Artifact Registry repository
# This permanently removes the repository and its contents
function gcloud_artifact_registry_repository_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the Artifact Registry repository?
This action is irreversible and will permanently delete the repository." "$@" || return 1

    echo "🔹 Deleting the Artifact Registry repository..."

    # Delete the Artifact Registry repository
    gcloud artifacts repositories delete $GCP_ARTIFACT_REGISTRY_NAME \
        --location=$GCP_ARTIFACT_REGISTRY_REGION \
        --quiet
}
