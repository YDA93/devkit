# Function to create a new Cloud SQL for PostgreSQL instance
function gcloud_sql_instance_create() {
    # Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    gcloud services enable servicenetworking.googleapis.com

    # Define variables for instance configuration
    TIER="db-custom-1-3840" # 1 vCPU, 3.75 GB RAM
    STORAGE_SIZE="10GB"
    MAINTENANCE_WINDOW_DAY="SAT" # Saturday
    MAINTENANCE_WINDOW_HOUR="23" # 23:00 UTC (equivalent to Sunday 02:00 Kuwait Time)

    # Create the Cloud SQL for PostgreSQL instance (Sandbox)
    gcloud sql instances create "$GS_SQL_INSTANCE_ID" \
        --database-version="$GS_SQL_DB_VERSION" \
        --tier="$TIER" \
        --region="$GS_SQL_INSTANCE_REGION" \
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
        --root-password="$GS_SQL_INSTANCE_PASSWORD"

    # Output the instance details
    gcloud sql instances describe "$GS_SQL_INSTANCE_ID"
}

# Function to delete a Cloud SQL instance
function gcloud_sql_instance_delete() {
    # Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    INSTANCE_NAME=$GS_SQL_INSTANCE_ID

    # Ask for user confirmation before deletion (compatible with zsh & bash)
    echo "⚠️ WARNING: This will permanently delete the Cloud SQL instance '$INSTANCE_NAME'."
    echo -n "Are you sure you want to proceed? (yes/no): "
    read CONFIRMATION

    # Convert input to lowercase
    CONFIRMATION=$(echo "$CONFIRMATION" | tr '[:upper:]' '[:lower:]')

    if [[ "$CONFIRMATION" == "yes" ]]; then
        echo "🔄 Deleting Cloud SQL instance: $INSTANCE_NAME ..."

        # Delete the instance
        gcloud sql instances delete $INSTANCE_NAME

    else
        echo "❌ Operation cancelled by user."
    fi
}

# Function to run the cloud-sql-proxy with the loaded configuration
function gcloud_sql_proxy_start() {
    # Call the configuration loading function
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi
    # If the configuration loads and validates, run the cloud-sql-proxy
    # The port is set to GS_PROXY_PORT to avoid conflicts with the default port 3306 & 5432
    ./cloud-sql-proxy --port $GS_PROXY_PORT "${GS_PROJECT_ID}:${GS_SQL_INSTANCE_REGION}:${GS_SQL_INSTANCE_ID}"
}

# Function to connect to a gcloud PostgreSQL instance
function gcloud_sql_postgres_connect() {
    # Step 1: Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Step 2: Run Expect to automate password entry and execute SQL commands
    gcloud sql connect "$GS_SQL_INSTANCE_ID" --user=postgres
}

# Function to create a new database and user in gcloud PostgreSQL
function gcloud_sql_db_and_user_create() {
    # Step 1: Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Step 2: Run Expect to automate password entry and execute SQL commands
    expect <<EOF
    spawn gcloud sql connect "$GS_SQL_INSTANCE_ID" --user=postgres
    set timeout 120

    expect {
        "*Allowlisting*" {
            sleep 25
            exp_continue
        }
        "*Password:*" {
            send -- "$GS_SQL_INSTANCE_PASSWORD\r"
            exp_continue
        }
        "postgres=>" {
            sleep 2

            # Step 5: Create the user (ignore errors if already exists)
            send -- "CREATE USER \"$GS_SQL_DB_USERNAME\" WITH PASSWORD '$GS_SQL_DB_PASSWORD';\r"
            expect "postgres=>"

            sleep 2

            # Step 6: Create the database (ignore errors if already exists)
            send -- "CREATE DATABASE \"$GS_SQL_DB_NAME\";\r"
            expect "postgres=>"

            sleep 2

            # Step 7: Properly send the \c command to switch databases
            send -- "\\\\c \"$GS_SQL_DB_NAME\"\r"
            expect {
                "*Password*" {
                    send -- "$GS_SQL_INSTANCE_PASSWORD\r"
                    expect "$GS_SQL_DB_NAME=>"
                }
                "$GS_SQL_DB_NAME=>" { }
                timeout { puts "❌ ERROR: Switching databases failed."; exit 1 }
            }

            sleep 2

            # Step 8: Grant privileges on the database to the user
            send -- "GRANT ALL PRIVILEGES ON DATABASE \"$GS_SQL_DB_NAME\" TO \"$GS_SQL_DB_USERNAME\";\r"
            expect "$GS_SQL_DB_NAME=>"

            sleep 2

            # Step 9: Grant privileges on the public schema to the user
            send -- "GRANT ALL ON SCHEMA public TO \"$GS_SQL_DB_USERNAME\";\r"
            expect "$GS_SQL_DB_NAME=>"

            sleep 1

            # Step 10: Exit PostgreSQL
            send -- "\\\\q\r"
            expect eof
        }
    }
EOF
}

# Function to delete a database and user in gcloud PostgreSQL
function gcloud_sql_db_and_user_delete() {
    # Load Configuration and Validate
    if ! gcloud_config_load_and_validate; then
        return 1 # Exit if configuration is not valid
    fi

    # Run Expect to automate password entry and execute SQL commands
    expect <<EOF
    spawn gcloud sql connect "$GS_SQL_INSTANCE_ID" --user=postgres
    set timeout 120

    expect {
        "*Allowlisting*" {
            sleep 25
            exp_continue
        }
        "*Password:*" {
            send -- "$GS_SQL_INSTANCE_PASSWORD\r"
            exp_continue
        }
        "postgres=>" {
            # Step 1: Revoke all privileges on the database from the user
            sleep 2
            send -- "REVOKE ALL PRIVILEGES ON DATABASE \"$GS_SQL_DB_NAME\" FROM \"$GS_SQL_DB_USERNAME\";\r"
            expect "postgres=>"

            # Step 2: Revoke all privileges on the public schema from the user
            sleep 2
            send -- "REVOKE ALL PRIVILEGES ON SCHEMA public FROM \"$GS_SQL_DB_USERNAME\";\r"
            expect "postgres=>"


            # Step 3: Drop the database (No IF EXISTS, will fail if it doesn't exist or has active connections)
            sleep 2
            send -- "DROP DATABASE \"$GS_SQL_DB_NAME\";\r"
            expect {
                "ERROR: database .* is being accessed by other users" {
                    send_user "\n❌ ERROR: Cannot drop database \"$GS_SQL_DB_NAME\" because it is in use.\n"
                    exit 1
                }
                "postgres=>"
            }

            # Step 4: Drop the user (No IF EXISTS, will fail if it doesn't exist)
            sleep 2
            send -- "DROP USER \"$GS_SQL_DB_USERNAME\";\r"
            expect {
                "ERROR: role .* does not exist" {
                    send_user "\n❌ ERROR: Cannot drop user \"$GS_SQL_DB_USERNAME\" because it does not exist.\n"
                    exit 1
                }
                "postgres=>"
            }


            # Step 5: Confirm deletion
            sleep 2
            send_user "\n✅ Dropped database \"$GS_SQL_DB_NAME\" and user \"$GS_SQL_DB_USERNAME\".\n"

            # Step 6: Exit PostgreSQL
            send -- "\\\\q\r"
            expect eof
        }
    }
EOF
}

# Function to start Cloud SQL Proxy in a new VS Code terminal tab and run Django setup
function gcloud_sql_proxy_and_django_setup() {
    echo "🔄 Starting the Cloud SQL Proxy in a new terminal window..."

    # Get the current working directory
    local cwd=$(pwd)

    # Open a new terminal window and run gcloud_sql_proxy_start in that directory
    osascript <<EOF
tell application "Terminal"
    do script "cd '$cwd' && gcloud_sql_proxy_start"
end tell
EOF

    echo "⏳ Waiting for Cloud SQL Proxy to start on port $GS_PROXY_PORT..."

    # Retry logic to check if the proxy is running
    local retries=15 # Max wait time (15 seconds)
    local delay=1    # Check every 1 second

    while true; do
        # First, check if the port is being used by Cloud SQL Proxy using `lsof`
        if lsof -iTCP -sTCP:LISTEN -nP | grep -q ":$GS_PROXY_PORT"; then
            # Second, confirm the port is actually responding using `nc`
            if nc -z 127.0.0.1 $GS_PROXY_PORT 2>/dev/null; then
                echo "✅ Cloud SQL Proxy is running on 127.0.0.1:$GS_PROXY_PORT!"
                break
            fi
        fi

        if ((retries-- <= 0)); then
            echo "❌ Cloud SQL Proxy failed to start within the expected time (30s)."
            return 1
        fi

        sleep $delay
    done

    # Run Django setup
    echo "⚙️ Running Django setup..."
    if django-settings-dev && python manage.py migrate && python manage.py populate_database; then
        echo "✅ Django setup completed successfully!"
    else
        echo "❌ Django setup failed."
        return 1
    fi
}
