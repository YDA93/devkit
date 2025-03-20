# Function to create a new static and media bucket with Fine-grained access control and public access
# This function provisions static and media buckets in Google Cloud Storage with fine-grained access control,
# sets public read access, applies cross-origin settings, and syncs static files. Additionally, it creates
# a Cloud Build artifacts bucket for storing build outputs.
function gcloud_storage_buckets_create() {
    gcloud_config_load_and_validate || return 1

    confirm_action "Are you sure you want to create new storage buckets?" "$@" || return 1

    echo "🔹 Creating Storage Buckets $GS_BUCKET_STATIC, $GS_BUCKET_NAME, and $GS_PROJECT_ID-cloudbuild-artifacts"

    # Create a new static bucket with Fine-grained access control
    gsutil mb -b on -c standard -l $GS_BUCKET_REGION gs://$GS_BUCKET_STATIC/ &&

        # Create a new media bucket with Fine-grained access control
        gsutil mb -b on -c standard -l $GS_BUCKET_REGION gs://$GS_BUCKET_NAME/ &&
        gcloud_storage_buckets_set_public_read --quiet &&
        gcloud_storage_buckets_set_cross_origin --quiet &&
        gcloud_storage_buckets_sync_static --quiet &&

        # Create a new bucket for Cloud Build artifacts
        gsutil mb -l $GS_BUCKET_REGION gs://$GS_PROJECT_ID-cloudbuild-artifacts/
}

# Function to delete the static and media buckets forcefully with confirmation
# This function permanently deletes the static and media buckets along with their contents,
# as well as the Cloud Build artifacts bucket, after user confirmation.
function gcloud_storage_buckets_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_action "Are you sure you want to delete all storage buckets and their contents?" "$@" || return 1

    echo "🔹 Deleting the Storage Buckets $GS_BUCKET_STATIC, $GS_BUCKET_NAME, and $GS_PROJECT_ID-cloudbuild-artifacts..."

    # Delete all objects from all buckets in parallel and remove the buckets
    # Will remove three buckets: static, media, and Cloud Build artifacts
    gsutil -m rm -r gs://$GS_BUCKET_STATIC/ gs://$GS_BUCKET_NAME/ gs://$GS_PROJECT_ID-cloudbuild-artifacts/

}

# Function to sync static files to the static bucket
# This function uploads local static files to the Google Cloud Storage static bucket using rsync
# while compressing specific file types for optimized delivery.
function gcloud_storage_buckets_sync_static() {
    gcloud_config_load_and_validate || return 1

    confirm_action "Are you sure you want to sync static files to the storage bucket?" "$@" || return 1

    echo "🔹 Syncing static files to the storage bucket $GS_BUCKET_STATIC..."

    # Sync static files to the static bucket
    gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://$GS_BUCKET_STATIC/
}

# Function to set public read permissions to the static and media buckets
# This function grants public read access to the static and media buckets,
# allowing users to access stored objects without authentication.
function gcloud_storage_buckets_set_public_read() {
    gcloud_config_load_and_validate || return 1

    confirm_action "Are you sure you want to set public read permissions to the storage buckets?" "$@" || return 1

    echo "🔹 Setting public read permissions to the Storage Buckets $GS_BUCKET_STATIC and $GS_BUCKET_NAME..."

    # Set public read permissions to the static bucket
    gcloud storage buckets add-iam-policy-binding gs://$GS_BUCKET_STATIC \
        --member=allUsers \
        --role=roles/storage.objectViewer \
        --quiet &&
        # Set public read permissions to the media bucket
        gcloud storage buckets add-iam-policy-binding gs://$GS_BUCKET_NAME \
            --member=allUsers \
            --role=roles/storage.objectViewer \
            --quiet
}

# Function to set cross-origin policy to the static and media buckets
# This function configures Cross-Origin Resource Sharing (CORS) settings on the static and media buckets
# using a predefined JSON configuration file.
function gcloud_storage_buckets_set_cross_origin() {
    gcloud_config_load_and_validate || return 1

    confirm_action "Are you sure you want to set cross-origin policy to the storage buckets?" "$@" || return 1

    echo "🔹 Setting cross-origin policy to the Storage Buckets $GS_BUCKET_STATIC and $GS_BUCKET_NAME..."

    # Set cross-origin policy to the static bucket and media bucket
    gsutil -m cors set cross-origin.json gs://$GS_BUCKET_STATIC gs://$GS_BUCKET_NAME
}
