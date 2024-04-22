# Function to load and validate configuration values from gcloud_project.sh
function gcloud_load_and_validate_config() {

    # Define an associative array to hold the variable names and their extracted values
    declare -A config_values

    # List of expected configuration variables
    local variables=(
        "project_id"
        "sql_region"
        "sql_id"
        "bucket_static_name"
        "bucket_media_name"
        "run_name"
        "run_region"
    )

    # Loop through each expected variable to load and validate it
    for var in "${variables[@]}"; do
        # Extract the value, ignoring lines starting with '#' and removing spaces around '='
        config_values[$var]=$(grep -E "^[[:space:]]*$var=" gcloud_project.sh | cut -d'=' -f2 | xargs)

        # Check if the variable is set
        if [ -z "${config_values[$var]}" ]; then
            echo "Error: '$var' is not set in gcloud_project.sh."
            return 1
        fi
    done

    # Export the variables so they can be used globally in the script
    for var in "${variables[@]}"; do
        export $var="${config_values[$var]}"
    done

    gcloud config set project $project_id
}

# Function to run the cloud-sql-proxy with the loaded configuration
function gcloud_proxy() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # If the configuration loads and validates, run the cloud-sql-proxy
    ./cloud-sql-proxy --port 3306 "${project_id}:${sql_region}:${sql_id}"
}

# Function to sync static files to the static bucket
function gcloud_sync_static() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # Sync static files to the static bucket
    gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://$bucket_static_name/
}

# Function to set public read permissions to the static and media buckets
function gcloud_set_public_read_to_buckets() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # Set public read permissions to the static bucket
    gsutil defacl set public-read gs://$bucket_static_name
    # Set public read permissions to the media bucket
    gsutil defacl set public-read gs://$bucket_media_name
}

# Function to set cross-origin policy to the static and media buckets
function gcloud_set_cross_origin() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # Set cross-origin policy to the static bucket
    gsutil cors set cross-origin.json gs://$bucket_static_name
    # Set cross-origin policy to the media bucket
    gsutil cors set cross-origin.json gs://$bucket_media_name
}

# Function to build image
function gcloud_build_image() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # Build the image
    gcloud builds submit --config cloudmigrate.yaml \
        --substitutions _INSTANCE_NAME=$sql_id,_REGION=$sql_region
}

# Function to deploy the service to Cloud Run for the first time
function gcloud_run_deploy_first_time() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # Deploy the service to Cloud Run for the first time
    gcloud run deploy $run_name \
        --platform managed \
        --region $run_region \
        --image gcr.io/$project_id/$run_name \
        --add-cloudsql-instances $project_id:$sql_region:$sql_id \
        --allow-unauthenticated
}

# Function to redeploy the service to Cloud Run
function gcloud_run_redeploy() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    # Redeploy the service to Cloud Run
    gcloud run deploy $run_name \
        --platform managed \
        --region $run_region \
        --image gcr.io/$project_id/$run_name
}

# Function to update the service URL environment variable in Cloud Run
function gcloud_run_update_service_url_env() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi

    # Get the service URL
    SERVICE_URL=$(gcloud run services describe $run_name --platform managed \
        --region $run_region --format "value(status.url)")

    # Update the service URL environment variable in Cloud Run
    gcloud run services update $run_name \
        --platform managed \
        --region $run_region \
        --set-env-vars CLOUDRUN_SERVICE_URL=$SERVICE_URL
}

# Function to build the image and deploy the service to Cloud Run for the first time
function gcloud_run_app_release() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    echo "Building the image and deploying the service to Cloud Run for the first time..."
    # Build the image, deploy the service for the first time, and update the service URL environment variable
    gcloud_build_image && gcloud_run_deploy_first_time && gcloud_run_update_service_url_env
}

# Function to build the image and redeploy the service to Cloud Run
function gcloud_run_app_update() {
    # Call the configuration loading function
    if ! gcloud_load_and_validate_config; then
        return 1 # Exit if configuration is not valid
    fi
    echo "Building the image and redeploying the service to Cloud Run..."
    # Build the image, redeploy the service, and update the service URL environment variable
    gcloud_build_image && gcloud_run_redeploy && gcloud_run_update_service_url_env
}
