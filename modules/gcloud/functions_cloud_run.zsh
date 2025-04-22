# ------------------------------------------------------------------------------
# 🚀 Google Cloud Run Deployment Utilities
# ------------------------------------------------------------------------------

# 🔨 Builds a Docker image, pushes to Artifact Registry, and triggers Cloud Build
# 💡 Usage: gcloud-run-build-image
function gcloud-run-build-image() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to build the Docker image and deploy the service to Cloud Run?" "$@" || return 1

    _log-info "🔹 Building the Docker image and pushing it to Artifact Registry..."

    # Construct the full image path
    GCP_RUN_FULL_IMAGE_NAME="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$GCP_ARTIFACT_REGISTRY_NAME/$GCP_EXTENDED_IMAGE_NAME"

    # Open Docker Desktop
    docker-daemon-start &&

        # Authenticate Docker to push the image
        gcloud auth configure-docker $GCP_REGION-docker.pkg.dev --quiet &&
        # Build the docker image
        docker build -t $GCP_EXTENDED_IMAGE_NAME -f builder.Dockerfile . &&

        # Tag and push the image
        docker tag $GCP_EXTENDED_IMAGE_NAME $GCP_RUN_FULL_IMAGE_NAME &&
        docker push $GCP_RUN_FULL_IMAGE_NAME &&

        # Grant Cloud Run Developer role
        gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
            --member="serviceAccount:$GCP_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            --role="roles/run.developer" \
            --quiet &&

        # Grant Service Account User role
        gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
            --member="serviceAccount:$GCP_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            --role="roles/iam.serviceAccountUser" \
            --quiet &&

        # Build the image
        gcloud builds submit --config cloudmigrate.yaml \
            --substitutions _INSTANCE_NAME=$GCP_SQL_INSTANCE_ID,_REGION=$GCP_REGION --region $GCP_REGION \
            --default-buckets-behavior=regional-user-owned-bucket \
            --gcs-source-staging-dir=gs://$GCP_PROJECT_ID-cloudbuild-artifacts/source \
            --gcs-log-dir=gs://$GCP_PROJECT_ID-cloudbuild-artifacts/logs \
            --quiet
}

# 🚀 Deploys the service to Cloud Run for the first time
# 💡 Usage: gcloud-run-deploy-initial
function gcloud-run-deploy-initial() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to deploy the service to Cloud Run for the first time?" "$@" || return 1

    _log-info "🔹 Deploying the service to Cloud Run for the first time..."

    # Deploy the service to Cloud Run for the first time
    gcloud run deploy $GCP_RUN_NAME \
        --region $GCP_REGION \
        --image $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$GCP_ARTIFACT_REGISTRY_NAME/$GCP_RUN_NAME \
        --add-cloudsql-instances $GCP_PROJECT_ID:$GCP_REGION:$GCP_SQL_INSTANCE_ID \
        --allow-unauthenticated \
        --cpu=$GCP_RUN_CPU \
        --memory=$GCP_RUN_MEMORY \
        --min-instances=$GCP_RUN_MIN_INSTANCES \
        --max-instances=$GCP_RUN_MAX_INSTANCES \
        --quiet
}

# 🔁 Redeploys the service to Cloud Run using the latest image
# 💡 Usage: gcloud-run-deploy-latest
function gcloud-run-deploy-latest() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to redeploy the service to Cloud Run?" "$@" || return 1

    _log-info "🔹 Redeploying the service to Cloud Run..."

    # Redeploy the service to Cloud Run
    gcloud run deploy $GCP_RUN_NAME \
        --region $GCP_REGION \
        --image $GCP_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$GCP_ARTIFACT_REGISTRY_NAME/$GCP_RUN_NAME \
        --cpu=$GCP_RUN_CPU \
        --memory=$GCP_RUN_MEMORY \
        --min-instances=$GCP_RUN_MIN_INSTANCES \
        --max-instances=$GCP_RUN_MAX_INSTANCES \
        --quiet
}

# 🌐 Updates the CLOUDRUN_SERVICE_URLS environment variable
# 💡 Usage: gcloud-run-set-service-urls-env
function gcloud-run-set-service-urls-env() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to update the service URLs environment variable in Cloud Run?" "$@" || return 1

    _log-info "🔹 Updating the service URLs environment variable in Cloud Run..."

    # Get the service URL
    CLOUDRUN_SERVICE_URLS=$(gcloud run services describe $GCP_RUN_NAME \
        --region $GCP_REGION \
        --format "value(metadata.annotations[\"run.googleapis.com/urls\"])" | tr -d '"[]') \
        --quiet

    # Update the service URL environment variable in Cloud Run
    gcloud run services update $GCP_RUN_NAME \
        --region $GCP_REGION \
        --update-env-vars "^##^CLOUDRUN_SERVICE_URLS=$CLOUDRUN_SERVICE_URLS" \
        --quiet

}

# 🚀 Builds image and deploys service to Cloud Run (first-time setup)
# 💡 Usage: gcloud-run-build-and-deploy-initial
function gcloud-run-build-and-deploy-initial() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to build the Docker image and deploy the service to Cloud Run for the first time?" "$@" || return 1

    _log-info "⚙️ Starting to build the Docker image and deploy the service to Cloud Run for the first time..."
    # Build the image, deploy the service for the first time, and update the service URL environment variable
    gcloud-run-build-image --quiet && gcloud-run-deploy-initial --quiet && gcloud-run-set-service-urls-env --quiet
}

# 🔁 Builds image and redeploys service to Cloud Run (update)
# 💡 Usage: gcloud-run-build-and-deploy-latest
function gcloud-run-build-and-deploy-latest() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to build the Docker image and redeploy the service to Cloud Run?" "$@" || return 1

    _log-info "⚙️ Starting to build the Docker image and redeploy the service to Cloud Run..."

    # Build the image, redeploy the service, and update the service URL environment variable
    gcloud-run-build-image --quiet && gcloud-run-deploy-latest --quiet && gcloud-run-set-service-urls-env --quiet
}

# 🗑️ Deletes Cloud Run service and job with confirmation
# 💡 Usage: gcloud-run-service-delete
function gcloud-run-service-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Cloud Run service and job?" "$@" || return 1

    # Delete the service
    _log-info "🔹 Deleting the Cloud Run service '$GCP_RUN_NAME'..."
    gcloud run services delete "$GCP_RUN_NAME" --region "$GCP_REGION" --quiet

    # Delete the Cloud Run job
    _log-info "🔹 Deleting the Cloud Run job 'migrate-job'..."
    gcloud run jobs delete migrate-job --region="$GCP_REGION" --quiet
}
