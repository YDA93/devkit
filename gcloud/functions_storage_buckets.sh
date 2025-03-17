# Function to create a new static and media bucket with Fine-grained access control and public access
function gcloud_storage_buckets_create() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Create a new static bucket with Fine-grained access control
    gsutil mb -b on -c standard -l $GS_BUCKET_REGION gs://$GS_BUCKET_STATIC/

    # Create a new media bucket with Fine-grained access control
    gsutil mb -b on -c standard -l $GS_BUCKET_REGION gs://$GS_BUCKET_NAME/

    gcloud_storage_buckets_set_public_read
    gcloud_storage_buckets_set_cross_origin
    gcloud_storage_buckets_sync_static

    # Create a new bucket for Cloud Build artifacts
    gsutil mb -l $GS_BUCKET_REGION gs://$GS_PROJECT_ID-cloudbuild-artifacts/
}

# Function to delete the static and media buckets forcefully with confirmation
function gcloud_storage_buckets_delete() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Ask user for confirmation (compatible with zsh & bash)
    echo "⚠️ Are you sure you want to delete the buckets ($GS_BUCKET_STATIC, $GS_BUCKET_NAME and $$GS_PROJECT_ID-cloudbuild-artifacts)? This action is irreversible. (yes/no):"
    read CONFIRMATION

    # Convert input to lowercase for case-insensitive comparison
    CONFIRMATION=$(echo "$CONFIRMATION" | tr '[:upper:]' '[:lower:]')

    if [[ "$CONFIRMATION" == "yes" ]]; then
        echo "🔄 Deleting all objects in the buckets and removing the buckets..."

        # Delete all objects in the static bucket and then delete the bucket
        gsutil -m rm -r gs://$GS_BUCKET_STATIC/
        gsutil rb gs://$GS_BUCKET_STATIC/

        # Delete all objects in the media bucket and then delete the bucket
        gsutil -m rm -r gs://$GS_BUCKET_NAME/
        gsutil rb gs://$GS_BUCKET_NAME/

        # Delete all objects in the Cloud Build artifacts bucket and then delete the bucket
        gsutil -m rm -r gs://$GS_PROJECT_ID-cloudbuild-artifacts/
        gsutil rb gs://$GS_PROJECT_ID-cloudbuild-artifacts/

    else
        echo "❌ Operation cancelled by user."
    fi
}

# Function to sync static files to the static bucket
function gcloud_storage_buckets_sync_static() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    # Sync static files to the static bucket
    gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://$GS_BUCKET_STATIC/
}

# Function to set public read permissions to the static and media buckets
function gcloud_storage_buckets_set_public_read() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    # Set public read permissions to the static bucket
    gcloud storage buckets add-iam-policy-binding gs://$GS_BUCKET_STATIC \
        --member=allUsers \
        --role=roles/storage.objectViewer
    # Set public read permissions to the media bucket
    gcloud storage buckets add-iam-policy-binding gs://$GS_BUCKET_NAME \
        --member=allUsers \
        --role=roles/storage.objectViewer
}

# Function to set cross-origin policy to the static and media buckets
function gcloud_storage_buckets_set_cross_origin() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    # Set cross-origin policy to the static bucket
    gsutil cors set cross-origin.json gs://$GS_BUCKET_STATIC
    # Set cross-origin policy to the media bucket
    gsutil cors set cross-origin.json gs://$GS_BUCKET_NAME
}
