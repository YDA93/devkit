# Function to build image
# This function builds a Docker image, tags it, pushes it to Artifact Registry, and configures
# Cloud Build permissions before initiating the build process.
function gcloud-run-build-image() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to build the Docker image and deploy the service to Cloud Run?" "$@" || return 1

    echo "🔹 Building the Docker image and pushing it to Artifact Registry..."

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

# Function to deploy the service to Cloud Run for the first time
# This function deploys the Cloud Run service using the built Docker image, configuring it with
# CPU, memory, and database connectivity settings while allowing unauthenticated access.
function gcloud-run-deploy-initial() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to deploy the service to Cloud Run for the first time?" "$@" || return 1

    echo "🔹 Deploying the service to Cloud Run for the first time..."

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

# Function to redeploy the service to Cloud Run
# This function redeploys an updated version of the Cloud Run service using the latest image from Artifact Registry.
function gcloud-run-deploy-latest() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to redeploy the service to Cloud Run?" "$@" || return 1

    echo "🔹 Redeploying the service to Cloud Run..."

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

# Function to update the service URLs environment variable in Cloud Run
# This function retrieves the Cloud Run service's URL and updates it as an environment variable in the service configuration.
function gcloud-run-set-service-urls-env() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to update the service URLs environment variable in Cloud Run?" "$@" || return 1

    echo "🔹 Updating the service URLs environment variable in Cloud Run..."

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

# Function to build the image and deploy the service to Cloud Run for the first time
# This function builds the Docker image, deploys it to Cloud Run, and updates the service URL environment variable.
function gcloud-run-build-and-deploy-initial() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to build the Docker image and deploy the service to Cloud Run for the first time?" "$@" || return 1

    echo "⚙️ Starting to build the Docker image and deploy the service to Cloud Run for the first time..."
    # Build the image, deploy the service for the first time, and update the service URL environment variable
    gcloud-run-build-image --quiet && gcloud-run-deploy-initial --quiet && gcloud-run-set-service-urls-env --quiet
}

# Function to build the image and redeploy the service to Cloud Run
# This function builds the Docker image, redeploys the Cloud Run service, and updates the service URL environment variable.
function gcloud-run-build-and-deploy-latest() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to build the Docker image and redeploy the service to Cloud Run?" "$@" || return 1

    echo "⚙️ Starting to build the Docker image and redeploy the service to Cloud Run..."

    # Build the image, redeploy the service, and update the service URL environment variable
    gcloud-run-build-image --quiet && gcloud-run-deploy-latest --quiet && gcloud-run-set-service-urls-env --quiet
}

# Function to delete the service from Cloud Run with user confirmation
# This function permanently deletes a Cloud Run service along with its associated job after user confirmation.
function gcloud-run-service-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Cloud Run service and job?" "$@" || return 1

    # Delete the service
    echo "🔹 Deleting the Cloud Run service '$GCP_RUN_NAME'..."
    gcloud run services delete "$GCP_RUN_NAME" --region "$GCP_REGION" --quiet

    # Delete the Cloud Run job
    echo "🔹 Deleting the Cloud Run job 'migrate-job'..."
    gcloud run jobs delete migrate-job --region="$GCP_REGION" --quiet
}
