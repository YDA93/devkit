# ------------------------------------------------------------------------------
# 📦 Google Artifact Registry Utilities
# ------------------------------------------------------------------------------

# 🏗️ Creates a new Docker Artifact Registry repository
# 💡 Usage: gcloud-artifact-registry-repository-create
function gcloud-artifact-registry-repository-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new Artifact Registry repository?" "$@" || return 1

    _log-info "🔹 Creating a new Artifact Registry repository..."

    # Create the Artifact Registry repository for Docker images
    gcloud artifacts repositories create $GCP_ARTIFACT_REGISTRY_NAME \
        --repository-format=docker \
        --location=$GCP_REGION \
        --description="Artifact Registry for $OFFICIAL_DOMAIN" \
        --quiet
}

# 🗑️ Deletes an Artifact Registry repository and all its contents
# 💡 Usage: gcloud_artifact_registry_repository_delete
function gcloud_artifact_registry_repository_delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Artifact Registry repository?
This action is irreversible and will permanently delete the repository." "$@" || return 1

    _log-info "🔹 Deleting the Artifact Registry repository..."

    # Delete the Artifact Registry repository
    gcloud artifacts repositories delete $GCP_ARTIFACT_REGISTRY_NAME \
        --location=$GCP_REGION \
        --quiet
}
