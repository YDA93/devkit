# 🛠️ Sets up PostgreSQL for the first time
# - Starts PostgreSQL service via Homebrew if not already running
# - Creates a default 'postgres' superuser if missing
# - Skips setup if already connected successfully
# 💡 Usage: postgres-setup
function postgres-setup() {
    # 🐘 Initialize PostgreSQL only if not already running or user missing
    if ! psql -U postgres -c '\q' &>/dev/null; then
        _log_info "⚙️  Setting up PostgreSQL for the first time..."

        # Start PostgreSQL if not already running
        if ! brew services list | grep -q "^$LATEST_PG.*started"; then
            _log_info "🔄 Starting PostgreSQL service..."
            # brew services start "$LATEST_PG"
        else
            _log_success "✓ PostgreSQL service is already running."
        fi

        # Create postgres superuser if missing
        if ! psql postgres -c '\du' | cut -d \| -f 1 | grep -qw postgres; then
            _log_info "➕ Creating default 'postgres' superuser..."
            createuser -s postgres
        else
            _log_success "✓ 'postgres' user already exists."
            echo
        fi
    else
        _log_success "✓ PostgreSQL is already set up and ready."
        echo
    fi
}

# ------------------------------------------------------------------------------
# 🐘 PostgreSQL Connection & Diagnostics
# ------------------------------------------------------------------------------

# 🔐 Validates PostgreSQL connection using PGPASSWORD
# - Checks if a password can authenticate as 'postgres'
# - Unsets PGPASSWORD on failure
# 💡 Usage: postgres-password-validation
function postgres-password-validation() {
    # Attempt to connect to PostgreSQL using the set PGPASSWORD
    if ! psql -U postgres -h localhost -c "\q" &>/dev/null; then
        _log_error "✗ Error: Unable to connect to PostgreSQL. Please check your password or server status."
        unset PGPASSWORD
        return 1
    fi
}

# 🔐 Establishes a secure PostgreSQL connection
# - Reuses valid $PGPASSWORD if available
# - Otherwise tries LOCAL_DB_PASSWORD from env
# - Prompts interactively if both are unavailable or invalid
# 💡 Usage: postgres-connect
function postgres-connect() {
    # ✅ 1. Check if PGPASSWORD is already set and valid
    if [[ -n "$PGPASSWORD" ]]; then
        if postgres-password-validation; then
            return 0
        else
            _log_warning "⚠️  Existing PGPASSWORD is invalid. Trying fallback..."
            unset PGPASSWORD
        fi
    fi

    # ✅ 2. Try LOCAL_DB_PASSWORD from external env helper
    if command -v environment-variable-get &>/dev/null; then
        env_pw=$(environment-variable-get LOCAL_DB_PASSWORD 2>/dev/null)
        if [[ -n "$env_pw" ]]; then
            export PGPASSWORD="$env_pw"
            if postgres-password-validation; then
                return 0
            else
                _log_warning "⚠️  LOCAL_DB_PASSWORD is set but invalid. Falling back to manual entry..."
                unset PGPASSWORD
            fi
        fi
    fi

    # 🔐 3. Prompt user if everything else fails
    pg_password=$(gum input --password --prompt "🔐 Enter the PostgreSQL password: ")
    echo

    export PGPASSWORD="$pg_password"

    postgres-password-validation || return 1

    return 0
}

# 🐘 Diagnoses local PostgreSQL environment
# - Checks for psql availability and service status
# - Attempts connection as the 'postgres' superuser
# - Provides guidance if any checks fail
# 💡 Usage: postgres-doctor
function postgres-doctor() {

    _log_info "🔧 Checking PostgreSQL installation..."
    if ! command -v psql &>/dev/null; then
        _log_warning "⚠️  psql command not found. PostgreSQL might not be installed."
        _log_hint "💡 Install with: brew install postgresql"
        echo
        return 1
    fi
    _log_success "✓ PostgreSQL is installed"
    echo

    _log_info "🛠 Checking if PostgreSQL service is running..."
    if pg_ctl status &>/dev/null || brew services list | grep -E 'postgresql(@[0-9]+)?' &>/dev/null; then
        _log_success "✓ PostgreSQL service appears to be running"
        echo
    else
        _log_warning "⚠️  PostgreSQL service not running or not installed"
        _log_hint "💡 Start with: brew services start $LATEST_PG"
        echo
    fi

    _log_info "🔑 Checking connection as 'postgres' user..."
    if psql -U postgres -c '\q' &>/dev/null; then
        _log_success "✓ Able to connect as 'postgres'"
        echo
    else
        _log_warning "⚠️  Cannot connect as 'postgres'"
        _log_hint "💡 Try creating the user with:"
        _log_hint "   createuser -s postgres"
        _log_hint ""
        _log_hint "🔐 To create a password for the user (optional but recommended):"
        _log_hint "   psql -U postgres"
        _log_hint "   Then inside psql, run:"
        _log_hint "     \\password postgres"
        _log_hint ""
        _log_hint "⚙️  Also ensure the PostgreSQL service is running:"
        _log_hint "   brew services start $LATEST_PG     "
        echo
    fi

    return 0
}

# ------------------------------------------------------------------------------
# 🗃️ PostgreSQL Database Operations
# ------------------------------------------------------------------------------

# 📋 Lists all PostgreSQL databases
# - Separates system and user databases
# - Connects securely via postgres-connect
# - Displays total database count
# 💡 Usage: postgres-database-list
function postgres-database-list() {
    postgres-connect || return 1

    # ✅ Explicitly fetch the list of databases now
    db_output=$(psql -U postgres -h localhost -lqt 2>/dev/null) || {
        _log_error "✗ Failed to retrieve database list."
        unset PGPASSWORD
        return 1
    }

    all_dbs=$(echo "$db_output" | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); if ($1 != "") print $1}' | sort)

    user_dbs=()
    system_dbs=()

    while IFS= read -r db; do
        case "$db" in
        postgres | template0 | template1)
            system_dbs+=("$db")
            ;;
        *)
            user_dbs+=("$db")
            ;;
        esac
    done <<<"$all_dbs"

    echo
    gum style --border normal --padding "1 2" --margin "1 0" --bold --foreground 212 "📋 PostgreSQL Databases"

    # System Databases
    gum style --bold --foreground 33 "🔧 System Databases:"
    gum style --foreground 240 "────────────────────"

    for db in "${system_dbs[@]}"; do
        echo " • $db"
    done

    echo

    # User Databases
    gum style --bold --foreground 36 "📦 User Databases:"
    gum style --foreground 240 "────────────────────"

    if [[ ${#user_dbs[@]} -eq 0 ]]; then
        echo " (none found)"
    else
        for db in "${user_dbs[@]}"; do
            echo " • $db"
        done
    fi

    echo

    # Summary
    total_count=$((${#system_dbs[@]} + ${#user_dbs[@]}))
    summary=$(printf "📊 Total databases: %2d (%d system, %d user)" "$total_count" "${#system_dbs[@]}" "${#user_dbs[@]}")

    gum style --bold --foreground 35 "$summary"
}

# 🏗️ Creates a PostgreSQL database (interactive)
# - Prompts for name and confirms overwrite if exists
# - Drops existing DB and terminates sessions before recreating
# 💡 Usage: postgres-database-create
function postgres-database-create() {
    postgres-database-list || return 1

    echo
    db_name=$(gum input --placeholder "database_name" --prompt "📦 Enter name of the database you wish to create: ")

    # Optional: Validate input
    if [[ -z "$db_name" ]]; then
        _log_error "✗ Database name cannot be empty."
        unset PGPASSWORD
        return 1
    fi
    echo

    # Check if the DB already exists
    db_exists=$(echo "$db_output" | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); if ($1 == "'"$db_name"'") print $1}')

    if [[ -n "$db_exists" ]]; then
        _confirm-or-abort "⚠️  Database '$db_name' already exists. Do you want to drop it?" || {
            _log_error "🚫 Operation canceled. Exiting..."
            unset PGPASSWORD
            return 1
        }

        _log_info "🔄 Terminating active sessions for '$db_name'..."
        if ! psql -U postgres -h 127.0.0.1 -c \
            "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db_name' AND pid <> pg_backend_pid();" 2>/dev/null; then
            _log_error "✗ Error: Failed to terminate active sessions."
            unset PGPASSWORD
            return 1
        fi

        _log_info "💣 Dropping database '$db_name'..."
        if ! dropdb -U postgres -h 127.0.0.1 "$db_name"; then
            _log_error "✗ Error: Failed to drop database."
            unset PGPASSWORD
            return 1
        fi

        _log_success "✓ Database '$db_name' dropped."
    fi

    _log_info "🚧 Creating new database '$db_name'..."
    if ! createdb -U postgres -h 127.0.0.1 "$db_name"; then
        _log_error "✗ Error: Failed to create database."
        unset PGPASSWORD
        return 1
    fi

    _log_success "✓ New database '$db_name' created successfully."
    echo
    unset PGPASSWORD
}

# 🗑️ Deletes a PostgreSQL database after confirmation
# - Prompts for name and confirms before dropping
# - Terminates any active sessions before deletion
# 💡 Usage: postgres-database-delete
function postgres-database-delete() {
    postgres-database-list || return 1

    databases=$(echo "$db_output" | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/, "", $1); if ($1 != "") print $1}' | sort)

    echo
    db_name=$(gum input --placeholder "database_name" --prompt "🎯 Enter the name of the database to delete: ")

    if [[ -z "$db_name" ]]; then
        _log_error "✗ Database name cannot be empty."
        unset PGPASSWORD
        return 1
    fi

    if echo "$databases" | grep -Fxq "$db_name"; then
        echo

        _confirm-or-abort "⚠️  Are you sure you want to delete '$db_name'? This action is irreversible." || {
            _log_error "🚫 Database '$db_name' was not dropped."
            exit 1
        }

        _log_info "🔄 Terminating active sessions for '$db_name'..."
        psql -U postgres -h localhost -c \
            "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db_name' AND pid <> pg_backend_pid();" >/dev/null

        _log_info "💣 Dropping database '$db_name'..."
        if dropdb -U postgres -h localhost "$db_name"; then
            _log_success "✓ Database '$db_name' has been dropped."
        else
            _log_error "✗ Failed to drop database '$db_name'."
        fi
    else
        _log_error "✗ Database '$db_name' does not exist."
    fi

    unset PGPASSWORD
}
