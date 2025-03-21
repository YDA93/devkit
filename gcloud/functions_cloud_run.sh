function docker_daemon_start() {
    echo "⏳ Starting Docker Daemon..."

    # Start Docker Daemon silently
    nohup open -a Docker --args --unattended &>/dev/null &
    disown

    # Wait for Docker daemon to become available
    while ! docker info &>/dev/null; do
        echo "⏳ Waiting for Docker to start..."
        sleep 5
    done

    echo "✅ Docker is now running!"
}

# Function to build image
# This function builds a Docker image, tags it, pushes it to Artifact Registry, and configures
# Cloud Build permissions before initiating the build process.
function gcloud_run_build_image() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to build the Docker image and deploy the service to Cloud Run?" "$@" || return 1

    echo "🔹 Building the Docker image and pushing it to Artifact Registry..."

    # Construct the full image path
    GS_RUN_FULL_IMAGE_NAME="$GS_RUN_REGION-docker.pkg.dev/$GS_PROJECT_ID/$GS_ARTIFACT_REGISTRY_NAME/$GS_EXTENDED_IMAGE_NAME"

    # Open Docker Desktop
    docker_daemon_start &&

        # Authenticate Docker to push the image
        gcloud auth configure-docker $GS_RUN_REGION-docker.pkg.dev --quiet &&
        # Build the docker image
        docker build -t $GS_EXTENDED_IMAGE_NAME -f builder.Dockerfile . &&

        # Tag and push the image
        docker tag $GS_EXTENDED_IMAGE_NAME $GS_RUN_FULL_IMAGE_NAME &&
        docker push $GS_RUN_FULL_IMAGE_NAME &&

        # Grant Cloud Run Developer role
        gcloud projects add-iam-policy-binding $GS_PROJECT_ID \
            --member="serviceAccount:$GS_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            --role="roles/run.developer" \
            --quiet &&

        # Grant Service Account User role
        gcloud projects add-iam-policy-binding $GS_PROJECT_ID \
            --member="serviceAccount:$GS_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            --role="roles/iam.serviceAccountUser" \
            --quiet &&

        # Build the image
        gcloud builds submit --config cloudmigrate.yaml \
            --substitutions _INSTANCE_NAME=$GS_SQL_INSTANCE_ID,_REGION=$GS_SQL_INSTANCE_REGION --region $GS_RUN_REGION \
            --default-buckets-behavior=regional-user-owned-bucket \
            --gcs-source-staging-dir=gs://$GS_PROJECT_ID-cloudbuild-artifacts/source \
            --gcs-log-dir=gs://$GS_PROJECT_ID-cloudbuild-artifacts/logs \
            --quiet
}

# Function to deploy the service to Cloud Run for the first time
# This function deploys the Cloud Run service using the built Docker image, configuring it with
# CPU, memory, and database connectivity settings while allowing unauthenticated access.
function gcloud_run_deploy_initial() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to deploy the service to Cloud Run for the first time?" "$@" || return 1

    echo "🔹 Deploying the service to Cloud Run for the first time..."

    # Deploy the service to Cloud Run for the first time
    gcloud run deploy $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --image $GS_RUN_REGION-docker.pkg.dev/$GS_PROJECT_ID/$GS_ARTIFACT_REGISTRY_NAME/$GS_RUN_NAME \
        --add-cloudsql-instances $GS_PROJECT_ID:$GS_SQL_INSTANCE_REGION:$GS_SQL_INSTANCE_ID \
        --allow-unauthenticated \
        --cpu=1 \
        --memory=1Gi \
        --min-instances=0 \
        --max-instances=5 \
        --quiet
}

# Function to redeploy the service to Cloud Run
# This function redeploys an updated version of the Cloud Run service using the latest image from Artifact Registry.
function gcloud_run_deploy_latest() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to redeploy the service to Cloud Run?" "$@" || return 1

    echo "🔹 Redeploying the service to Cloud Run..."

    # Redeploy the service to Cloud Run
    gcloud run deploy $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --image $GS_RUN_REGION-docker.pkg.dev/$GS_PROJECT_ID/$GS_ARTIFACT_REGISTRY_NAME/$GS_RUN_NAME \
        --cpu=1 \
        --memory=1Gi \
        --min-instances=0 \
        --max-instances=5 \
        --quiet
}

# Function to update the service URLs environment variable in Cloud Run
# This function retrieves the Cloud Run service's URL and updates it as an environment variable in the service configuration.
function gcloud_run_set_service_urls_env() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to update the service URLs environment variable in Cloud Run?" "$@" || return 1

    echo "🔹 Updating the service URLs environment variable in Cloud Run..."

    # Get the service URL
    CLOUDRUN_SERVICE_URLS=$(gcloud run services describe $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --format "value(metadata.annotations[\"run.googleapis.com/urls\"])" | tr -d '"[]') \
        --quiet

    # Update the service URL environment variable in Cloud Run
    gcloud run services update $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --update-env-vars "^##^CLOUDRUN_SERVICE_URLS=$CLOUDRUN_SERVICE_URLS" \
        --quiet

}

# Function to build the image and deploy the service to Cloud Run for the first time
# This function builds the Docker image, deploys it to Cloud Run, and updates the service URL environment variable.
function gcloud_run_build_and_deploy_initial() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to build the Docker image and deploy the service to Cloud Run for the first time?" "$@" || return 1

    echo "⚙️ Starting to build the Docker image and deploy the service to Cloud Run for the first time..."
    # Build the image, deploy the service for the first time, and update the service URL environment variable
    gcloud_run_build_image --quiet && gcloud_run_deploy_initial --quiet && gcloud_run_set_service_urls_env --quiet
}

# Function to build the image and redeploy the service to Cloud Run
# This function builds the Docker image, redeploys the Cloud Run service, and updates the service URL environment variable.
function gcloud_run_build_and_deploy_latest() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to build the Docker image and redeploy the service to Cloud Run?" "$@" || return 1

    echo "⚙️ Starting to build the Docker image and redeploy the service to Cloud Run..."

    # Build the image, redeploy the service, and update the service URL environment variable
    gcloud_run_build_image --quiet && gcloud_run_deploy_latest --quiet && gcloud_run_set_service_urls_env --quiet
}

# Function to delete the service from Cloud Run with user confirmation
# This function permanently deletes a Cloud Run service along with its associated job after user confirmation.
function gcloud_run_service_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the Cloud Run service and job?" "$@" || return 1

    # Delete the service
    echo "🔹 Deleting the Cloud Run service '$GS_RUN_NAME'..."
    gcloud run services delete "$GS_RUN_NAME" --region "$GS_RUN_REGION" --quiet

    # Delete the Cloud Run job
    echo "🔹 Deleting the Cloud Run job 'migrate-job'..."
    gcloud run jobs delete migrate-job --region="$GS_RUN_REGION" --quiet
}
