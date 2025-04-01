# ------------------------------------------------------------------------------
# 🗃️ Google Cloud Storage Management
# ------------------------------------------------------------------------------

# 🗃️ Creates static, media, and artifacts buckets in GCS
# - Enables fine-grained access control
# - Sets public read and CORS policies
# - Syncs static files automatically
# 💡 Usage: gcloud-storage-buckets-create
function gcloud-storage-buckets-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create new storage buckets?" "$@" || return 1

    echo "🔹 Creating Storage Buckets $GS_BUCKET_STATIC, $GS_BUCKET_NAME, and $GCP_PROJECT_ID-cloudbuild-artifacts"

    # Create a new static bucket with Fine-grained access control
    gsutil mb -b on -c standard -l $GCP_REGION gs://$GS_BUCKET_STATIC/ &&

        # Create a new media bucket with Fine-grained access control
        gsutil mb -b on -c standard -l $GCP_REGION gs://$GS_BUCKET_NAME/ &&
        gcloud-storage-buckets-set-public-read --quiet &&
        gcloud-storage-buckets-set-cross-origin --quiet &&
        gcloud-storage-buckets-sync-static --quiet &&

        # Create a new bucket for Cloud Build artifacts
        gsutil mb -l $GCP_REGION gs://$GCP_PROJECT_ID-cloudbuild-artifacts/
}

# 🗑️ Deletes static, media, and artifacts buckets from GCS
# - Removes all contents before deletion
# 💡 Usage: gcloud-storage-buckets-delete
function gcloud-storage-buckets-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete all storage buckets and their contents?" "$@" || return 1

    echo "🔹 Deleting the Storage Buckets $GS_BUCKET_STATIC, $GS_BUCKET_NAME, and $GCP_PROJECT_ID-cloudbuild-artifacts..."

    # Delete all objects from all buckets in parallel and remove the buckets
    # Will remove three buckets: static, media, and Cloud Build artifacts
    gsutil -m rm -r gs://$GS_BUCKET_STATIC/ gs://$GS_BUCKET_NAME/ gs://$GCP_PROJECT_ID-cloudbuild-artifacts/

}

# 📤 Uploads local static files to the static bucket
# - Uses `gsutil rsync` with compression for web assets
# 💡 Usage: gcloud-storage-buckets-sync-static
function gcloud-storage-buckets-sync-static() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to sync static files to the storage bucket?" "$@" || return 1

    echo "🔹 Syncing static files to the storage bucket $GS_BUCKET_STATIC..."

    # Sync static files to the static bucket
    gsutil -o "GSUtil:parallel_process_count=1" -m rsync -r -j html,txt,css,js ./static gs://$GS_BUCKET_STATIC/
}

# 🌐 Sets public read access on static and media buckets
# - Grants `roles/storage.objectViewer` to `allUsers`
# 💡 Usage: gcloud-storage-buckets-set-public-read
function gcloud-storage-buckets-set-public-read() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to set public read permissions to the storage buckets?" "$@" || return 1

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

# 🔄 Applies CORS policy to static and media buckets
# - Uses configuration from `cross-origin.json`
# 💡 Usage: gcloud-storage-buckets-set-cross-origin
function gcloud-storage-buckets-set-cross-origin() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to set cross-origin policy to the storage buckets?" "$@" || return 1

    echo "🔹 Setting cross-origin policy to the Storage Buckets $GS_BUCKET_STATIC and $GS_BUCKET_NAME..."

    # Set cross-origin policy to the static bucket and media bucket
    gsutil -m cors set cross-origin.json gs://$GS_BUCKET_STATIC gs://$GS_BUCKET_NAME
}
