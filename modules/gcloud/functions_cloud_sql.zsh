# Function to create a new Cloud SQL for PostgreSQL instance
# This function provisions a Cloud SQL PostgreSQL instance with predefined configurations, including
# storage settings, maintenance schedules, backup, and query insights.
function gcloud-sql-instance-create() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new Cloud SQL instance?" "$@" || return 1

    echo "🔹 Creating a new Cloud SQL instance for PostgreSQL..."

    # Define variables for instance configuration
    TIER="db-custom-1-3840" # 1 vCPU, 3.75 GB RAM
    STORAGE_SIZE="10GB"
    MAINTENANCE_WINDOW_DAY="SAT" # Saturday
    MAINTENANCE_WINDOW_HOUR="23" # 23:00 UTC (equivalent to Sunday 02:00 Kuwait Time)

    gcloud services enable servicenetworking.googleapis.com --quiet &&

        # Create the Cloud SQL for PostgreSQL instance (Sandbox)
        gcloud sql instances create "$GCP_SQL_INSTANCE_ID" \
            --database-version="$GCP_SQL_DB_VERSION" \
            --tier="$TIER" \
            --region="$GCP_REGION" \
            --storage-size="$STORAGE_SIZE" \
            --storage-type=SSD \
            --availability-type=ZONAL \
            --backup \
            --enable-point-in-time-recovery \
            --maintenance-window-day="$MAINTENANCE_WINDOW_DAY" \
            --maintenance-window-hour="$MAINTENANCE_WINDOW_HOUR" \
            --maintenance-release-channel=production \
            --insights-config-query-insights-enabled \
            --insights-config-record-application-tags \
            --insights-config-record-client-address \
            --assign-ip \
            --storage-auto-increase \
            --edition=ENTERPRISE \
            --root-password="$GCP_SQL_INSTANCE_PASSWORD" \
            --quiet &&

        # Output the instance details
        gcloud sql instances describe "$GCP_SQL_INSTANCE_ID" --quiet
}

# Function to delete a Cloud SQL instance
# This function permanently deletes a specified Cloud SQL instance after user confirmation.
function gcloud-sql-instance-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the Cloud SQL instance '$GCP_SQL_INSTANCE_ID'?" "$@" || return 1

    INSTANCE_NAME=$GCP_SQL_INSTANCE_ID

    echo "🔹 Deleting Cloud SQL instance: $INSTANCE_NAME ..."

    # Delete the instance
    gcloud sql instances delete $INSTANCE_NAME --quiet
}

# Function to run the cloud-sql-proxy with the loaded configuration
# This function starts the Cloud SQL Proxy, forwarding database connections through a local port
# to securely access the Cloud SQL instance.
function gcloud-sql-proxy-start() {
    # Call the configuration loading function
    gcloud-config-load-and-validate || return 1

    echo "🔹 Starting Cloud SQL Proxy..."
    # If the configuration loads and validates, run the cloud-sql-proxy
    # The port is set to GCP_SQL_PROXY_PORT to avoid conflicts with the default port 3306 & 5432
    ./cloud-sql-proxy --port $GCP_SQL_PROXY_PORT "${GCP_PROJECT_ID}:${GCP_REGION}:${GCP_SQL_INSTANCE_ID}"
}

# Function to connect to a gcloud PostgreSQL instance
# This function establishes an interactive connection to the Cloud SQL PostgreSQL instance using
# the gcloud CLI.
function gcloud-sql-postgres-connect() {
    # Step 1: Load Configuration and Validate
    gcloud-config-load-and-validate || return 1

    echo "🔹 Connecting to the Cloud SQL PostgreSQL instance..."

    # Step 2: Run Expect to automate password entry and execute SQL commands
    gcloud sql connect "$GCP_SQL_INSTANCE_ID" --user=postgres --quiet
}

# Function to create a new database and user in gcloud PostgreSQL
# This function automates the creation of a new database and user within a Cloud SQL PostgreSQL instance,
# assigns privileges, and ensures access permissions.
function gcloud-sql-db-and-user-create() {
    # Step 1: Load Configuration and Validate
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to create a new database and user?" "$@" || return 1

    echo "🔹 Creating a new database and user in Cloud SQL for PostgreSQL..."

    # Step 2: Run Expect to automate password entry and execute SQL commands
    expect <<EOF
    spawn gcloud sql connect "$GCP_SQL_INSTANCE_ID" --user=postgres
    set timeout 120

    expect {
        "*Allowlisting*" {
            sleep 25
            exp_continue
        }
        "*Password:*" {
            send -- "$GCP_SQL_INSTANCE_PASSWORD\r"
            exp_continue
        }
        "postgres=>" {
            sleep 2

            # Step 5: Create the user (ignore errors if already exists)
            send -- "CREATE USER \"$GCP_SQL_DB_USERNAME\" WITH PASSWORD '$GCP_SQL_DB_PASSWORD';\r"
            expect "postgres=>"

            sleep 2

            # Step 6: Create the database (ignore errors if already exists)
            send -- "CREATE DATABASE \"$GCP_SQL_DB_NAME\";\r"
            expect "postgres=>"

            sleep 2

            # Step 7: Properly send the \c command to switch databases
            send -- "\\\\c \"$GCP_SQL_DB_NAME\"\r"
            expect {
                "*Password*" {
                    send -- "$GCP_SQL_INSTANCE_PASSWORD\r"
                    expect "$GCP_SQL_DB_NAME=>"
                }
                "$GCP_SQL_DB_NAME=>" { }
                timeout { puts "❌ ERROR: Switching databases failed."; exit 1 }
            }

            sleep 2

            # Step 8: Grant privileges on the database to the user
            send -- "GRANT ALL PRIVILEGES ON DATABASE \"$GCP_SQL_DB_NAME\" TO \"$GCP_SQL_DB_USERNAME\";\r"
            expect "$GCP_SQL_DB_NAME=>"

            sleep 2

            # Step 9: Grant privileges on the public schema to the user
            send -- "GRANT ALL ON SCHEMA public TO \"$GCP_SQL_DB_USERNAME\";\r"
            expect "$GCP_SQL_DB_NAME=>"

            sleep 1

            # Step 10: Exit PostgreSQL
            send -- "\\\\q\r"
            expect eof
        }
    }
EOF
}

# Function to delete a database and user in gcloud PostgreSQL
# This function revokes privileges, drops the specified database, and removes the associated user
# from the Cloud SQL PostgreSQL instance.
function gcloud-sql-db-and-user-delete() {
    gcloud-config-load-and-validate || return 1

    _confirm-or-abort "Are you sure you want to delete the database and user '$GCP_SQL_DB_USERNAME'?" "$@" || return 1

    echo "🔹 Deleting the database and user in Cloud SQL for PostgreSQL..."

    # Run Expect to automate password entry and execute SQL commands
    expect <<EOF
    spawn gcloud sql connect "$GCP_SQL_INSTANCE_ID" --user=postgres
    set timeout 120

    expect {
        "*Allowlisting*" {
            sleep 25
            exp_continue
        }
        "*Password:*" {
            send -- "$GCP_SQL_INSTANCE_PASSWORD\r"
            exp_continue
        }
        "postgres=>" {
            # Step 1: Revoke all privileges on the database from the user
            sleep 2
            send -- "REVOKE ALL PRIVILEGES ON DATABASE \"$GCP_SQL_DB_NAME\" FROM \"$GCP_SQL_DB_USERNAME\";\r"
            expect "postgres=>"

            # Step 2: Revoke all privileges on the public schema from the user
            sleep 2
            send -- "REVOKE ALL PRIVILEGES ON SCHEMA public FROM \"$GCP_SQL_DB_USERNAME\";\r"
            expect "postgres=>"


            # Step 3: Drop the database (No IF EXISTS, will fail if it doesn't exist or has active connections)
            sleep 2
            send -- "DROP DATABASE \"$GCP_SQL_DB_NAME\";\r"
            expect {
                "ERROR: database .* is being accessed by other users" {
                    send_user "\n❌ ERROR: Cannot drop database \"$GCP_SQL_DB_NAME\" because it is in use.\n"
                    exit 1
                }
                "postgres=>"
            }

            # Step 4: Drop the user (No IF EXISTS, will fail if it doesn't exist)
            sleep 2
            send -- "DROP USER \"$GCP_SQL_DB_USERNAME\";\r"
            expect {
                "ERROR: role .* does not exist" {
                    send_user "\n❌ ERROR: Cannot drop user \"$GCP_SQL_DB_USERNAME\" because it does not exist.\n"
                    exit 1
                }
                "postgres=>"
            }


            # Step 5: Confirm deletion
            sleep 2
            send_user "\n✅ Dropped database \"$GCP_SQL_DB_NAME\" and user \"$GCP_SQL_DB_USERNAME\".\n"

            # Step 6: Exit PostgreSQL
            send -- "\\\\q\r"
            expect eof
        }
    }
EOF
}

# Function to start Cloud SQL Proxy in a new VS Code terminal tab and run Django setup
# This function launches the Cloud SQL Proxy in a new terminal tab, waits for it to be available,
# and then executes Django setup commands, including migrations and database population.
function gcloud-sql-proxy-and-django-setup() {
    _confirm-or-abort "Are you sure you want to start the Cloud SQL Proxy and run Django setup?" "$@" || return 1

    echo "🔹 Starting the Cloud SQL Proxy in a new terminal window, then start Django in Development 
    settings, apply migrations, and populate the database..."

    # Get the current working directory
    local cwd=$(pwd)

    # Open a new terminal window and run gcloud-sql-proxy-start in that directory
    osascript <<EOF
tell application "Terminal"
    do script "cd '$cwd' && gcloud-sql-proxy-start"
end tell
EOF

    echo "⏳ Waiting for Cloud SQL Proxy to start on port $GCP_SQL_PROXY_PORT..."

    # Retry logic to check if the proxy is running
    local retries=15 # Max wait time (15 seconds)
    local delay=1    # Check every 1 second

    while true; do
        # First, check if the port is being used by Cloud SQL Proxy using `lsof`
        if lsof -iTCP -sTCP:LISTEN -nP | grep -q ":$GCP_SQL_PROXY_PORT"; then
            # Second, confirm the port is actually responding using `nc`
            if nc -z 127.0.0.1 $GCP_SQL_PROXY_PORT 2>/dev/null; then
                echo "✅ Cloud SQL Proxy is running on 127.0.0.1:$GCP_SQL_PROXY_PORT!"
                break
            fi
        fi

        if ((retries-- <= 0)); then
            echo "❌ Cloud SQL Proxy failed to start within the expected time (30s)."
            return 1
        fi

        sleep $delay
    done

    # Run Django setup in previous terminal
    if django-settings dev && python manage.py migrate && python manage.py populate_database; then
        echo "✅ Django setup completed successfully!"
    else
        echo "❌ Django setup failed."
        return 1
    fi
}
