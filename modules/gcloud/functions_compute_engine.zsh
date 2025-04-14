# ------------------------------------------------------------------------------
# 🌐 Google Compute Engine - Load Balancer Setup
# ------------------------------------------------------------------------------

# 🌐 Creates a global static IPv4 address for use with a load balancer
# 💡 Usage: gcloud-compute-engine-ipv4-create
function gcloud-compute-engine-ipv4-create {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new static IPv4 address?" "$@" || return 1

    _log_info "🔹 Creating a global static IPv4 address for the Load Balancer..."

    gcloud compute addresses create $GCP_PROJECT_ID-ipv4 \
        --global \
        --ip-version=IPV4 \
        --network-tier=PREMIUM \
        --quiet &&
        gcloud compute addresses describe $GCP_PROJECT_ID-ipv4 --global --format="get(address)" --quiet
}

# 🗑️ Deletes the reserved global static IPv4 address
# 💡 Usage: gcloud-compute-engine-ipv4-delete
function gcloud-compute-engine-ipv4-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the static IPv4 address?" "$@" || return 1

    _log_info "🔹 Deleting the static IPv4 address..."

    gcloud compute addresses delete $GCP_PROJECT_ID-ipv4 --global --quiet
}

# 🔐 Creates a Google-managed SSL certificate for your domain
# 💡 Usage: gcloud-compute-engine-ssl-certificate-create
function gcloud-compute-engine-ssl-certificate-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new SSL certificate?" "$@" || return 1

    _log_info "🔹 Creating Google-managed SSL certificate..."

    gcloud compute ssl-certificates create $GCP_PROJECT_ID-ssl-certificate \
        --domains="$ADMIN_DOMAIN,www.$ADMIN_DOMAIN" \
        --global \
        --quiet &&
        gcloud compute ssl-certificates describe $GCP_PROJECT_ID-ssl-certificate --global --format="get(managed.status)" --quiet
}

# 🗑️ Deletes the Google-managed SSL certificate
# 💡 Usage: gcloud-compute-engine-ssl-certificate-delete
function gcloud-compute-engine-ssl-certificate-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the SSL certificate?" "$@" || return 1

    _log_info "🔹 Deleting the SSL certificate..."

    gcloud compute ssl-certificates delete $GCP_PROJECT_ID-ssl-certificate --global --quiet
}

# 🔌 Creates a serverless NEG (Network Endpoint Group) for Cloud Run
# 💡 Usage: gcloud-compute-engine-network-endpoint-group-create
function gcloud-compute-engine-network-endpoint-group-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new Network Endpoint Group?" "$@" || return 1

    _log_info "🔹 Creating Network Endpoint Group (NEG) for Cloud Run..."

    gcloud compute network-endpoint-groups create $GCP_PROJECT_ID-neg \
        --region=$GCP_REGION \
        --network-endpoint-type=serverless \
        --cloud-run-service=$GCP_RUN_NAME \
        --quiet

}

# 🗑️ Deletes the serverless NEG used for Cloud Run
# 💡 Usage: gcloud-compute-engine-network-endpoint-group-delete
function gcloud-compute-engine-network-endpoint-group-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Network Endpoint Group?" "$@" || return 1

    _log_info "🔹 Deleting Network Endpoint Group (NEG)..."

    gcloud compute network-endpoint-groups delete $GCP_PROJECT_ID-neg --region=$GCP_REGION --quiet
}

# 🔄 Creates a backend service and attaches the NEG
# 💡 Usage: gcloud-compute-engine-backend-service-create
function gcloud-compute-engine-backend-service-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new backend service and attach the Network Endpoint Group (NEG)?" "$@" || return 1

    _log_info "🔹 Creating backend service and attaching Network Endpoint Group (NEG) to it..."

    gcloud compute backend-services create $GCP_PROJECT_ID-backend-service \
        --global \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --quiet &&
        gcloud compute backend-services add-backend $GCP_PROJECT_ID-backend-service \
            --global \
            --network-endpoint-group=$GCP_PROJECT_ID-neg \
            --network-endpoint-group-region=$GCP_REGION \
            --quiet
}

# 🗑️ Removes NEG from backend service and deletes the service
# 💡 Usage: gcloud-compute-engine-backend-service-delete
function gcloud-compute-engine-backend-service-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to remove the Network Endpoint Group (NEG) from the backend service and delete the backend service?" "$@" || return 1

    _log_info "🔹 Removing the Network Endpoint Group (NEG) from the backend service and deleting the backend service..."

    gcloud compute backend-services remove-backend $GCP_PROJECT_ID-backend-service \
        --global \
        --network-endpoint-group=$GCP_PROJECT_ID-neg \
        --network-endpoint-group-region=$GCP_REGION \
        --quiet
    gcloud compute backend-services delete $GCP_PROJECT_ID-backend-service --global --quiet
}

# 🗺️ Creates a URL map to route requests to the backend service
# 💡 Usage: gcloud-compute-engine-url-map-create
function gcloud-compute-engine-url-map-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new URL map?" "$@" || return 1

    _log_info "🔹 Creating URL map..."

    # Create the URL map
    gcloud compute url-maps create $GCP_PROJECT_ID-url-map \
        --default-service=$GCP_PROJECT_ID-backend-service \
        --global \
        --quiet

}

# 🗑️ Deletes the URL map from Compute Engine
# 💡 Usage: gcloud-compute-engine-url-map-delete
function gcloud-compute-engine-url-map-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the URL map?" "$@" || return 1

    _log_info "🔹 Deleting URL map..."

    gcloud compute url-maps delete $GCP_PROJECT_ID-url-map --global --quiet
}

# 🔐 Creates HTTP & HTTPS target proxies and attaches SSL certificate
# 💡 Usage: gcloud-compute-engine-target-https-proxy-and-attach-ssl-certificate
function gcloud-compute-engine-target-https-proxy-and-attach-ssl-certificate() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new HTTPS target proxy and attach the SSL certificate?" "$@" || return 1

    _log_info "🔹 Creating HTTPS target proxy and attaching SSL certificate..."

    # Create HTTP Proxy for redirecting HTTP traffic to HTTPS (NO SSL required)
    gcloud compute target-http-proxies create $GCP_PROJECT_ID-target-http-proxy \
        --global \
        --url-map=$GCP_PROJECT_ID-url-map \
        --quiet &&
        # Create HTTPS Proxy
        gcloud compute target-https-proxies create $GCP_PROJECT_ID-target-https-proxy \
            --global \
            --url-map=$GCP_PROJECT_ID-url-map \
            --ssl-certificates=$GCP_PROJECT_ID-ssl-certificate \
            --quiet

}

# 🗑️ Deletes HTTP and HTTPS target proxies
# 💡 Usage: gcloud-compute-engine-target-https-proxy-delete
function gcloud-compute-engine-target-https-proxy-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Target HTTPS Proxy?" "$@" || return 1

    _log_info "🔹 Deleting the Target HTTPS Proxy..."

    # Delete the Target HTTP Proxy
    gcloud compute target-http-proxies delete $GCP_PROJECT_ID-target-http-proxy --global --quiet
    # Delete the Target HTTPS Proxy
    gcloud compute target-https-proxies delete $GCP_PROJECT_ID-target-https-proxy --global --quiet

}

# 🚦 Creates forwarding rules for HTTP (80) and HTTPS (443) traffic
# 💡 Usage: gcloud-compute-engine-global-forwarding-rule-create
function gcloud-compute-engine-global-forwarding-rule-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new Global Forwarding Rule?" "$@" || return 1

    _log_info "🔹 Creating global forwarding rule..."

    # Forward HTTP requests (port 80) to the HTTP proxy (which redirects to HTTPS)
    gcloud compute forwarding-rules create $GCP_PROJECT_ID-http-forwarding-rule \
        --global \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --network-tier=PREMIUM \
        --address=$GCP_PROJECT_ID-ipv4 \
        --target-http-proxy=$GCP_PROJECT_ID-target-http-proxy \
        --ports=80 \
        --quiet &&

        # Forward HTTPS requests (port 443) to the HTTPS proxy
        gcloud compute forwarding-rules create $GCP_PROJECT_ID-https-forwarding-rule \
            --global \
            --load-balancing-scheme=EXTERNAL_MANAGED \
            --network-tier=PREMIUM \
            --address=$GCP_PROJECT_ID-ipv4 \
            --target-https-proxy=$GCP_PROJECT_ID-target-https-proxy \
            --ports=443 \
            --quiet

}

# 🗑️ Deletes forwarding rules for HTTP and HTTPS
# 💡 Usage: gcloud-compute-engine-global-forwarding-rule-delete
function gcloud-compute-engine-global-forwarding-rule-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Global Forwarding Rule?" "$@" || return 1

    _log_info "🔹 Deleting global forwarding rule..."

    # Delete the HTTP Forwarding Rule
    gcloud compute forwarding-rules delete $GCP_PROJECT_ID-http-forwarding-rule --global --quiet

    # Delete the HTTPS Forwarding Rule
    gcloud compute forwarding-rules delete $GCP_PROJECT_ID-https-forwarding-rule --global --quiet

}

# ⚙️ Sets up a full Cloud Load Balancer with IP, SSL, proxy, URL map, and forwarding rules
# 💡 Usage: gcloud-compute-engine-cloud-load-balancer-setup
function gcloud-compute-engine-cloud-load-balancer-setup() {
    # Validate Google Cloud configuration before proceeding
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to set up the Cloud Load Balancer?" "$@" || return 1

    _log_info "⚙️ Starting to set up the Cloud Load Balancer..."

    gcloud services enable compute.googleapis.com networkservices.googleapis.com

    # Step 1: Create a static IPv4 address
    if ! gcloud-compute-engine-ipv4-create --quiet; then
        _log_error "✗ Failed to create static IP."
        return 1
    fi

    # Step 2: Ask user to point the subdomain to the static IP before proceeding
    _confirm-or-abort "Please confirm that you have pointed your domain to the Load Balancer's IP Address." "$@" || return 1

    # Step 3: Create a Google-managed SSL certificate
    if ! gcloud-compute-engine-ssl-certificate-create --quiet; then
        _log_error "✗ Failed to create SSL certificate."
        return 1
    fi

    # Step 4: Create a Serverless Network Endpoint Group (NEG)
    if ! gcloud-compute-engine-network-endpoint-group-create --quiet; then
        _log_error "✗ Failed to create Network Endpoint Group."
        return 1
    fi

    # Step 5: Create a Backend Service
    if ! gcloud-compute-engine-backend-service-create --quiet; then
        _log_error "✗ Failed to create backend service and attach NEG."
        return 1
    fi

    # Step 6: Create URL Map for request routing
    if ! gcloud-compute-engine-url-map-create --quiet; then
        _log_error "✗ Failed to create URL map."
        return 1
    fi

    # Step 7: Create HTTPS Proxy and Attach SSL Certificate
    if ! gcloud-compute-engine-target-https-proxy-and-attach-ssl-certificate --quiet; then
        _log_error "✗ Failed to create HTTPS target proxy."
        return 1
    fi

    # Step 8: Create Global Forwarding Rule
    if ! gcloud-compute-engine-global-forwarding-rule-create --quiet; then
        _log_error "✗ Failed to create global forwarding rule."
        return 1
    fi

    _log_success "🎉 Cloud Load Balancer setup completed successfully!"
}

# 🔄 Teardown of all Cloud Load Balancer components
# 💡 Usage: gcloud-compute-engine-cloud-load-balancer-teardown
function gcloud-compute-engine-cloud-load-balancer-teardown() {
    # Validate Google Cloud configuration before proceeding
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to teardown the Cloud Load Balancer?" "$@" || return 1

    _log_info "⚙️ Starting to teardown the Cloud Load Balancer..."

    # Step 1: Delete Global Forwarding Rule
    gcloud-compute-engine-global-forwarding-rule-delete --quiet || _log_error "✗ Failed to delete global forwarding rule."

    # Step 2: Delete Target HTTPS Proxy
    gcloud-compute-engine-target-https-proxy-delete --quiet || _log_error "✗ Failed to delete target HTTPS proxy."

    # Step 3: Delete URL Map
    gcloud-compute-engine-url-map-delete --quiet || _log_error "✗ Failed to delete URL map."

    # Step 4: Detach NEG from the Backend Service
    # Attempt to delete the backend service, which also detaches the associated NEG.
    gcloud-compute-engine-backend-service-delete --quiet || _log_error "✗ Error: Failed to remove the Network Endpoint Group (NEG) from the backend service and delete the backend service."

    # Step 5: Delete NEG
    gcloud-compute-engine-network-endpoint-group-delete --quiet || _log_error "✗ Failed to delete Network Endpoint Group."

    # Step 6: Delete SSL Certificate
    gcloud-compute-engine-ssl-certificate-delete --quiet || _log_error "✗ Failed to delete SSL certificate."

    # Step 7: Delete Static IPv4 Address
    gcloud-compute-engine-ipv4-delete --quiet || _log_error "✗ Failed to delete static IP."

    _log_success "🎉 Cloud Load Balancer teardown completed successfully!"
}
