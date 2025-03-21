# Function to create a new IPv4 address for Google Compute Engine
# This function reserves a global static IP address that can be used for load balancing
function gcloud_compute_engine_ipv4_create {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new static IPv4 address?" || return 1

    echo "🔹 Creating a global static IPv4 address for the Load Balancer..."

    gcloud compute addresses create $GS_PROJECT_ID-ipv4 \
        --global \
        --ip-version=IPV4 \
        --network-tier=PREMIUM \
        --quiet &&
        gcloud compute addresses describe $GS_PROJECT_ID-ipv4 --global --format="get(address)" --quiet
}

# Function to delete the reserved IPv4 address from Google Compute Engine
# This function releases the static IP address from the global address pool
function gcloud_compute_engine_ipv4_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the static IPv4 address?" "$@" || return 1

    echo "🔹 Deleting the static IPv4 address..."

    gcloud compute addresses delete $GS_PROJECT_ID-ipv4 --global --quiet
}

# Function to create a new SSL certificate for Google Compute Engine
# This function provisions a Google-managed SSL certificate for securing HTTPS traffic
function gcloud_compute_engine_ssl_certificate_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new SSL certificate?" "$@" || return 1

    echo "🔹 Creating Google-managed SSL certificate..."

    gcloud compute ssl-certificates create $GS_PROJECT_ID-ssl-certificate \
        --domains="$ADMIN_DOMAIN,www.$ADMIN_DOMAIN" \
        --global \
        --quiet &&
        gcloud compute ssl-certificates describe $GS_PROJECT_ID-ssl-certificate --global --format="get(managed.status)" --quiet
}

# Function to delete an existing SSL certificate from Google Compute Engine
# This function removes a Google-managed SSL certificate from the system
function gcloud_compute_engine_ssl_certificate_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the SSL certificate?" "$@" || return 1

    echo "🔹 Deleting the SSL certificate..."

    gcloud compute ssl-certificates delete $GS_PROJECT_ID-ssl-certificate --global --quiet
}

# Function to create a new Network Endpoint Group for Google Compute Engine
# This function provisions a serverless Network Endpoint Group (NEG) for Cloud Run integration
# to be used in backend services for load balancing.
function gcloud_compute_engine_network_endpoint_group_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new Network Endpoint Group?" "$@" || return 1

    echo "🔹 Creating Network Endpoint Group (NEG) for Cloud Run..."

    gcloud compute network-endpoint-groups create $GS_PROJECT_ID-neg \
        --region=$GS_RUN_REGION \
        --network-endpoint-type=serverless \
        --cloud-run-service=$GS_RUN_NAME \
        --quiet

}

# Function to delete the Network Endpoint Group from Google Compute Engine
# This function removes a serverless Network Endpoint Group (NEG) associated with Cloud Run.
function gcloud_compute_engine_network_endpoint_group_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the Network Endpoint Group?" "$@" || return 1

    echo "🔹 Deleting Network Endpoint Group (NEG)..."

    gcloud compute network-endpoint-groups delete $GS_PROJECT_ID-neg --region=$GS_RUN_REGION --quiet
}

# Function to create a new backend service for Google Compute Engine and attach the Network Endpoint Group (NEG)
# This function provisions a global backend service and links it to a Network Endpoint Group (NEG)
# for HTTP load balancing.
function gcloud_compute_engine_backend_service_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new backend service and attach the Network Endpoint Group (NEG)?" "$@" || return 1

    echo "🔹 Creating backend service and attaching Network Endpoint Group (NEG) to it..."

    gcloud compute backend-services create $GS_PROJECT_ID-backend-service \
        --global \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --protocol=HTTP \
        --quiet &&
        gcloud compute backend-services add-backend $GS_PROJECT_ID-backend-service \
            --global \
            --network-endpoint-group=$GS_PROJECT_ID-neg \
            --network-endpoint-group-region=$GS_RUN_REGION \
            --quiet
}

# Function to detach the Network Endpoint Group (NEG) from the backend service and delete the backend service
# This function removes the NEG from the backend service and deletes the backend service from the global scope.
function gcloud_compute_engine_backend_service_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to remove the Network Endpoint Group (NEG) from the backend service and delete the backend service?" "$@" || return 1

    echo "🔹 Removing the Network Endpoint Group (NEG) from the backend service and deleting the backend service..."

    gcloud compute backend-services remove-backend $GS_PROJECT_ID-backend-service \
        --global \
        --network-endpoint-group=$GS_PROJECT_ID-neg \
        --network-endpoint-group-region=$GS_RUN_REGION \
        --quiet
    gcloud compute backend-services delete $GS_PROJECT_ID-backend-service --global --quiet
}

# Function to create a new URL Map for Google Compute Engine
# This function establishes a URL map that directs HTTP traffic to the correct backend service.
function gcloud_compute_engine_url_map_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new URL map?" "$@" || return 1

    echo "🔹 Creating URL map..."

    # Create the URL map
    gcloud compute url-maps create $GS_PROJECT_ID-url-map \
        --default-service=$GS_PROJECT_ID-backend-service \
        --global \
        --quiet

}

# Function to delete the URL Map from Google Compute Engine
# This function removes the previously created URL map used for traffic routing.
function gcloud_compute_engine_url_map_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the URL map?" "$@" || return 1

    echo "🔹 Deleting URL map..."

    gcloud compute url-maps delete $GS_PROJECT_ID-url-map --global --quiet
}

# Function to create a new Target HTTPS Proxy and attach the SSL certificate for Google Compute Engine
# This function provisions an HTTPS target proxy and binds it with a Google-managed SSL certificate.
function gcloud_compute_engine_target_https_proxy_and_attach_ssl_certificate() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new HTTPS target proxy and attach the SSL certificate?" "$@" || return 1

    echo "🔹 Creating HTTPS target proxy and attaching SSL certificate..."

    # Create HTTP Proxy for redirecting HTTP traffic to HTTPS (NO SSL required)
    gcloud compute target-http-proxies create $GS_PROJECT_ID-target-http-proxy \
        --global \
        --url-map=$GS_PROJECT_ID-url-map \
        --quiet &&
        # Create HTTPS Proxy
        gcloud compute target-https-proxies create $GS_PROJECT_ID-target-https-proxy \
            --global \
            --url-map=$GS_PROJECT_ID-url-map \
            --ssl-certificates=$GS_PROJECT_ID-ssl-certificate \
            --quiet

}

# Function to delete the Target HTTPS Proxy from Google Compute Engine
# This function removes both the HTTP and HTTPS target proxies associated with the load balancer.
function gcloud_compute_engine_target_https_proxy_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the Target HTTPS Proxy?" "$@" || return 1

    echo "🔹 Deleting the Target HTTPS Proxy..."

    # Delete the Target HTTP Proxy
    gcloud compute target-http-proxies delete $GS_PROJECT_ID-target-http-proxy --global --quiet
    # Delete the Target HTTPS Proxy
    gcloud compute target-https-proxies delete $GS_PROJECT_ID-target-https-proxy --global --quiet

}

# Function to create a new Global Forwarding Rule for Google Compute Engine
# This function provisions forwarding rules that route HTTP (port 80) and HTTPS (port 443) traffic
# to the appropriate proxies.
function gcloud_compute_engine_global_forwarding_rule_create() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to create a new Global Forwarding Rule?" "$@" || return 1

    echo "🔹 Creating global forwarding rule..."

    # Forward HTTP requests (port 80) to the HTTP proxy (which redirects to HTTPS)
    gcloud compute forwarding-rules create $GS_PROJECT_ID-http-forwarding-rule \
        --global \
        --load-balancing-scheme=EXTERNAL_MANAGED \
        --network-tier=PREMIUM \
        --address=$GS_PROJECT_ID-ipv4 \
        --target-http-proxy=$GS_PROJECT_ID-target-http-proxy \
        --ports=80 \
        --quiet &&

        # Forward HTTPS requests (port 443) to the HTTPS proxy
        gcloud compute forwarding-rules create $GS_PROJECT_ID-https-forwarding-rule \
            --global \
            --load-balancing-scheme=EXTERNAL_MANAGED \
            --network-tier=PREMIUM \
            --address=$GS_PROJECT_ID-ipv4 \
            --target-https-proxy=$GS_PROJECT_ID-target-https-proxy \
            --ports=443 \
            --quiet

}

# Function to delete the Global Forwarding Rule from Google Compute Engine
# This function removes the HTTP and HTTPS forwarding rules that direct traffic to the load balancer.
function gcloud_compute_engine_global_forwarding_rule_delete() {
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to delete the Global Forwarding Rule?" "$@" || return 1

    echo "🔹 Deleting global forwarding rule..."

    # Delete the HTTP Forwarding Rule
    gcloud compute forwarding-rules delete $GS_PROJECT_ID-http-forwarding-rule --global --quiet

    # Delete the HTTPS Forwarding Rule
    gcloud compute forwarding-rules delete $GS_PROJECT_ID-https-forwarding-rule --global --quiet

}

# Function to setup the Cloud Load Balancer on Google Compute Engine
# This function orchestrates the complete setup of a Cloud Load Balancer, including the creation of a static IP,
# SSL certificate, Network Endpoint Group, backend service, URL map, HTTPS proxy, and forwarding rules.
function gcloud_compute_engine_cloud_load_balancer_setup() {
    # Validate Google Cloud configuration before proceeding
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to set up the Cloud Load Balancer?" "$@" || return 1

    echo "⚙️ Starting to set up the Cloud Load Balancer..."

    gcloud services enable compute.googleapis.com networkservices.googleapis.com

    # Step 1: Create a static IPv4 address
    if ! gcloud_compute_engine_ipv4_create --quiet; then
        echo "❌ Failed to create static IP."
        return 1
    fi

    # Step 2: Ask user to point the subdomain to the static IP before proceeding
    confirm_or_abort "Please confirm that you have pointed your domain to the Load Balancer's IP Address." "$@" || return 1

    # Step 3: Create a Google-managed SSL certificate
    if ! gcloud_compute_engine_ssl_certificate_create --quiet; then
        echo "❌ Failed to create SSL certificate."
        return 1
    fi

    # Step 4: Create a Serverless Network Endpoint Group (NEG)
    if ! gcloud_compute_engine_network_endpoint_group_create --quiet; then
        echo "❌ Failed to create Network Endpoint Group."
        return 1
    fi

    # Step 5: Create a Backend Service
    if ! gcloud_compute_engine_backend_service_create --quiet; then
        echo "❌ Failed to create backend service and attach NEG."
        return 1
    fi

    # Step 6: Create URL Map for request routing
    if ! gcloud_compute_engine_url_map_create --quiet; then
        echo "❌ Failed to create URL map."
        return 1
    fi

    # Step 7: Create HTTPS Proxy and Attach SSL Certificate
    if ! gcloud_compute_engine_target_https_proxy_and_attach_ssl_certificate --quiet; then
        echo "❌ Failed to create HTTPS target proxy."
        return 1
    fi

    # Step 8: Create Global Forwarding Rule
    if ! gcloud_compute_engine_global_forwarding_rule_create --quiet; then
        echo "❌ Failed to create global forwarding rule."
        return 1
    fi

    echo "🎉 Cloud Load Balancer setup completed successfully!"
}

# Function to teardown the Cloud Load Balancer on Google Compute Engine
# This function reverses the load balancer setup by sequentially deleting the forwarding rules, target proxies,
# URL map, backend service, Network Endpoint Group, SSL certificate, and static IP.
function gcloud_compute_engine_cloud_load_balancer_teardown() {
    # Validate Google Cloud configuration before proceeding
    gcloud_config_load_and_validate || return 1

    confirm_or_abort "Are you sure you want to teardown the Cloud Load Balancer?" "$@" || return 1

    echo "⚙️ Starting to teardown the Cloud Load Balancer..."

    # Step 1: Delete Global Forwarding Rule
    gcloud_compute_engine_global_forwarding_rule_delete --quiet || echo "❌ Failed to delete global forwarding rule."

    # Step 2: Delete Target HTTPS Proxy
    gcloud_compute_engine_target_https_proxy_delete --quiet || echo "❌ Failed to delete target HTTPS proxy."

    # Step 3: Delete URL Map
    gcloud_compute_engine_url_map_delete --quiet || echo "❌ Failed to delete URL map."

    # Step 4: Detach NEG from the Backend Service
    # Attempt to delete the backend service, which also detaches the associated NEG.
    gcloud_compute_engine_backend_service_delete --quiet || echo "❌ Error: Failed to remove the Network Endpoint Group (NEG) from the backend service and delete the backend service."

    # Step 5: Delete NEG
    gcloud_compute_engine_network_endpoint_group_delete --quiet || echo "❌ Failed to delete Network Endpoint Group."

    # Step 6: Delete SSL Certificate
    gcloud_compute_engine_ssl_certificate_delete --quiet || echo "❌ Failed to delete SSL certificate."

    # Step 7: Delete Static IPv4 Address
    gcloud_compute_engine_ipv4_delete --quiet || echo "❌ Failed to delete static IP."

    echo "🎉 Cloud Load Balancer teardown completed successfully!"
}
