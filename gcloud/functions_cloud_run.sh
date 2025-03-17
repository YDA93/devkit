# Function to build image
function gcloud_run_build_image() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Construct the full image path
    GS_RUN_FULL_IMAGE_NAME="$GS_RUN_REGION-docker.pkg.dev/$GS_PROJECT_ID/$GS_ARTIFACT_REGISTRY_NAME/$GS_EXTENDED_IMAGE_NAME"

    # Authenticate Docker to push the image
    gcloud auth configure-docker $GS_RUN_REGION-docker.pkg.dev &&
        # Build the docker image
        docker build -t $GS_EXTENDED_IMAGE_NAME -f builder.Dockerfile . &&

        # Tag and push the image
        docker tag $GS_EXTENDED_IMAGE_NAME $GS_RUN_FULL_IMAGE_NAME &&
        docker push $GS_RUN_FULL_IMAGE_NAME &&

        # Grant Cloud Run Developer role
        gcloud projects add-iam-policy-binding $GS_PROJECT_ID \
            --member="serviceAccount:$GS_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            --role="roles/run.developer" &&

        # Grant Service Account User role
        gcloud projects add-iam-policy-binding $GS_PROJECT_ID \
            --member="serviceAccount:$GS_PROJECT_NUMBER@cloudbuild.gserviceaccount.com" \
            --role="roles/iam.serviceAccountUser" &&

        # Build the image
        gcloud builds submit --config cloudmigrate.yaml \
            --substitutions _INSTANCE_NAME=$GS_SQL_INSTANCE_ID,_REGION=$GS_SQL_INSTANCE_REGION --region $GS_RUN_REGION \
            --default-buckets-behavior=regional-user-owned-bucket \
            --gcs-source-staging-dir=gs://$GS_PROJECT_ID-cloudbuild-artifacts/source \
            --gcs-log-dir=gs://$GS_PROJECT_ID-cloudbuild-artifacts/logs
}

# Function to deploy the service to Cloud Run for the first time
function gcloud_run_deploy_initial() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    # Deploy the service to Cloud Run for the first time
    gcloud run deploy $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --image $GS_RUN_REGION-docker.pkg.dev/$GS_PROJECT_ID/$GS_ARTIFACT_REGISTRY_NAME/$GS_RUN_NAME \
        --add-cloudsql-instances $GS_PROJECT_ID:$GS_SQL_INSTANCE_REGION:$GS_SQL_INSTANCE_ID \
        --allow-unauthenticated
}

# Function to redeploy the service to Cloud Run
function gcloud_run_deploy_latest() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    # Redeploy the service to Cloud Run
    gcloud run deploy $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --image $GS_RUN_REGION-docker.pkg.dev/$GS_PROJECT_ID/$GS_ARTIFACT_REGISTRY_NAME/$GS_RUN_NAME
}

# Function to update the service URL environment variable in Cloud Run
function gcloud_run_set_service_urls_env() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Get the service URL
    CLOUDRUN_SERVICE_URLS=$(gcloud run services describe $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --format "value(metadata.annotations[\"run.googleapis.com/urls\"])" | tr -d '"[]')

    # Update the service URL environment variable in Cloud Run
    gcloud run services update $GS_RUN_NAME \
        --region $GS_RUN_REGION \
        --update-env-vars "^##^CLOUDRUN_SERVICE_URLS=$CLOUDRUN_SERVICE_URLS"

}

# Function to build the image and deploy the service to Cloud Run for the first time
function gcloud_run_build_and_deploy_initial() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    echo "Building the image and deploying the service to Cloud Run for the first time..."
    # Build the image, deploy the service for the first time, and update the service URL environment variable
    gcloud_run_build_image && gcloud_run_deploy_initial && gcloud_run_set_service_urls_env
}

# Function to build the image and redeploy the service to Cloud Run
function gcloud_run_build_and_deploy_latest() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    echo "Building the image and redeploying the service to Cloud Run..."
    # Build the image, redeploy the service, and update the service URL environment variable
    gcloud_run_build_image && gcloud_run_deploy_latest && gcloud_run_set_service_urls_env
}

# Function to delete the service from Cloud Run with user confirmation
function gcloud_run_service_delete() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Ask for user confirmation before deletion
    echo "⚠️ WARNING: This will permanently delete the Cloud Run service '$GS_RUN_NAME' in region '$GS_RUN_REGION'."
    echo -n "Are you sure you want to proceed? (yes/no): "
    read CONFIRMATION

    # Convert input to lowercase
    CONFIRMATION=$(echo "$CONFIRMATION" | tr '[:upper:]' '[:lower:]')

    if [[ "$CONFIRMATION" == "yes" ]]; then

        # Delete the service
        echo "🔄 Deleting the Cloud Run service '$GS_RUN_NAME'..."
        gcloud run services delete "$GS_RUN_NAME" --region "$GS_RUN_REGION"

        # Delete the Cloud Run job
        echo "🔄 Deleting the Cloud Run job 'migrate-job'..."
        gcloud run jobs delete migrate-job --region="$GS_RUN_REGION"

    else
        echo "❌ Operation cancelled by user."
    fi
}
