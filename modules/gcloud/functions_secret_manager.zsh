# ------------------------------------------------------------------------------
# 🔐 Google Secret Manager - Environment File Utilities
# ------------------------------------------------------------------------------

# 🔐 Creates a new secret in Secret Manager from the local `.env` file
# - Grants access to the Compute Engine default service account
# 💡 Usage: gcloud-secret-manager-env-create
function gcloud-secret-manager-env-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new secret in Secret Manager?" "$@" || return 1

    _log-info "🔹 Creating a new secret '$GCP_SECRET_NAME' in Secret Manager..."

    # Create .env file in Secret Manager with the contents of the local .env file and specified region
    gcloud secrets create $GCP_SECRET_NAME \
        --data-file=".env" \
        --replication-policy="user-managed" \
        --locations=$GCP_REGION \
        --quiet &&
        gcloud secrets add-iam-policy-binding $GCP_SECRET_NAME \
            --member serviceAccount:$GCP_PROJECT_NUMBER-compute@developer.gserviceaccount.com \
            --role roles/secretmanager.secretAccessor \
            --quiet
}

# 🔄 Updates the secret in Secret Manager with a new version
# - Automatically disables all previously active versions
# 💡 Usage: gcloud-secret-manager-env-update
function gcloud-secret-manager-env-update() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to update the secret in Secret Manager?" "$@" || return 1

    _log-info "🔹 Updating the secret '$GCP_SECRET_NAME' in Secret Manager..."

    # Add a new version of the secret in Secret Manager with the updated .env file
    gcloud secrets versions add $GCP_SECRET_NAME --data-file=".env" --quiet

    # Get the list of all versions (excluding the latest one)
    PREVIOUS_VERSIONS=$(gcloud secrets versions list $GCP_SECRET_NAME --quiet --format="csv(name,state)" | tail -n +3)

    if [[ ! -z "$PREVIOUS_VERSIONS" ]]; then
        while IFS="," read -r version state; do
            # Trim whitespace
            version=$(echo "$version" | xargs)
            state=$(echo "$state" | xargs | tr '[:lower:]' '[:upper:]') # Convert to uppercase

            # Only disable previous versions that are still ENABLED
            if [[ "$state" == "ENABLED" ]]; then
                gcloud secrets versions disable "$version" --secret="$GCP_SECRET_NAME" --quiet
            fi
        done <<<"$PREVIOUS_VERSIONS"
    fi

}

# 🗑️ Permanently deletes the secret from Secret Manager
# - Deletes all versions and metadata
# 💡 Usage: gcloud-secret-manager-env-delete
function gcloud-secret-manager-env-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the secret from Secret Manager
    This action is irreversible and will permanently delete the secret." "$@" || return 1

    _log-info "🔹 Deleting the secret '$GCP_SECRET_NAME' from Secret Manager..."

    # Delete the secret
    gcloud secrets delete $GCP_SECRET_NAME --quiet
}

# 📥 Downloads a secret and saves it to a local `.env` file
# - Prompts user to select from available secrets
# 💡 Usage: gcloud-secret-manager-env-download
function gcloud-secret-manager-env-download() {
    _log-info "🔹 Fetching available secrets..."

    local temp_file=$(mktemp)
    gcloud secrets list --format="value(name)" 2>/dev/null >"$temp_file"

    cat "$temp_file"

    local secrets_array=()
    local line_number=0
    while IFS= read -r secret; do
        if [[ -n "$secret" ]]; then
            secrets_array+=("$secret")
            _log-success "✓ Added to array: ${secret}"
        fi
        ((line_number++))
    done <"$temp_file"
    rm -f "$temp_file"

    if [[ ${#secrets_array[@]} -eq 0 ]]; then
        _log-error "✗ No secrets found or failed to list secrets"
        return 1
    fi

    _log-info-2 "🔸 Available secrets:"
    i=0
    for secret in "${secrets_array[@]}"; do
        _log-info-2 "$((i + 1)). $secret"
        ((i++))
    done

    selection=$(gum input --placeholder "e.g., 1" --prompt "🔢 Select a secret number to download: ")

    if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
        _log-error "✗ Invalid input: Not a number"
        return 1
    fi

    if ((selection < 1 || selection > ${#secrets_array[@]})); then
        _log-error "✗ Invalid input: Out of range"
        return 1
    fi

    local counter=1
    local selected_secret=""
    for secret in "${secrets_array[@]}"; do
        if [[ "$counter" -eq "$selection" ]]; then
            selected_secret="$secret"
            break
        fi
        ((counter++))
    done

    _log-success "✓ Selected secret: '$selected_secret'"
    GCP_SECRET_NAME="$selected_secret"

    local output_file=".env"
    _log-info "🔹 Downloading '$GCP_SECRET_NAME' from Secret Manager..."

    if gcloud secrets versions access latest --secret="$GCP_SECRET_NAME" --quiet >"$output_file"; then
        _log-success "✓ .env downloaded and saved to: $output_file"
    else
        _log-error "✗ Failed to download .env — make sure the secret exists and has at least one version"
        return 1
    fi
}
