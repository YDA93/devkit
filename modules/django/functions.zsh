# ------------------------------------------------------------------------------
# 🎬 Project Bootstrap & Configuration
# ------------------------------------------------------------------------------

# 📦 Starts a new Django app inside the current project
# - Must be run from a Django project root
# 💡 Usage: django-app-start <app_name>
function django-project-start() {
    if [ -z "$1" ]; then
        _log-hint "Usage: django-project-start <projectname>"
        return 1
    fi

    local projectname=$1

    # Create project directory
    _log-info "Creating project directory '$projectname'..."
    mkdir "$projectname" && cd "$projectname" || return

    # Create the Python environment
    python-environment-create || return 1

    # Activate the Python environment
    python-environment-activate || return 1

    # Install Django
    _log-info "Installing Django..."
    pip install django || return 1

    # Start Django project
    _log-info "Starting Django project '$projectname'..."
    django-admin startproject "$projectname" . || return 1

    _log-success "✓ Django project '$projectname' created and ready!"
}

# 📦 Starts a new Django app inside the current project
# 💡 Usage: django-app-start <app_name>
function django-app-start() {
    if [ -z "$1" ]; then
        _log-hint "Usage: django-app-start <app_name>"
        return 1
    fi

    _log-info "Creating Django app '$1'..."
    app_name=$1 # First Aurgment
    python manage.py startapp $app_name
    _log-success "✓ Django app '$app_name' created successfully!"
}

# ⚙️ Sets the DJANGO_SETTINGS_MODULE environment variable based on the selected environment
# - Activates the Python environment
# - Supports local, dev, prod, and test
# 💡 Usage: django-settings [local|dev|prod|test]
function django-settings() {
    local env=$1
    python-environment-activate || return 1

    case "$env" in
    local)
        export DJANGO_SETTINGS_MODULE=project.settings.local
        _log-success "🌱 Local settings activated"
        ;;
    dev)
        export DJANGO_SETTINGS_MODULE=project.settings.dev
        _log-success "🛠️ Development settings activated"
        ;;
    prod)
        export DJANGO_SETTINGS_MODULE=project.settings.prod
        _log-success "🚀 Production settings activated"
        ;;
    test)
        export DJANGO_SETTINGS_MODULE=project.settings.test
        _log-success "🧪 Test settings activated"
        ;;
    *)
        _log-warning "⚠️ Unknown environment: '$env'"
        _log-hint "Usage: django-settings [local|dev|prod|test]"
        return 1
        ;;
    esac
}

# 🔐 Generates a new Django SECRET_KEY and sets it as an environment variable
# 💡 Usage: django-secret-key-generate
function django-secret-key-generate() {
    raw_key=$(python3 -c "
    import secrets
    import string

    safe_chars = string.ascii_letters + string.digits + '!@#%^&*(-_=+)'
    print(''.join(secrets.choice(safe_chars) for _ in range(50)))
    ")

    _log-info "🔑 Generating new Django SECRET_KEY..."
    environment-variable-set "DJANGO_SECRET_KEY" "$raw_key"
}

# ------------------------------------------------------------------------------
# 🧱 Database Schema & Migrations
# ------------------------------------------------------------------------------

# 🛠️ Wrapper for makemigrations (passes through args)
# 💡 Usage: django-migrate-make [args]
function django-migrate-make() {
    _log-info "🛠️ Running makemigrations..."
    python manage.py makemigrations $@
}

# 🧱 Wrapper for migrate (passes through args)
# 💡 Usage: django-migrate [args]
function django-migrate() {
    _log-info "🧱 Running migrate..."
    python manage.py migrate $@
}

# 🔄 Runs a full initial migration cycle
# - Deletes existing migrations and caches
# - Temporarily disables URLs to avoid import issues
# - Runs makemigrations, createcachetable, and migrate
# - Restores the original `urls.py`
# 💡 Usage: django-migrate-initial
function django-migrate-initial() {
    # 1. Delete all migrations and cache files
    django-migrate-and-cache-delete || return 1

    # 2. Handle URLs
    # Store the original content of the urls.py
    _log-info "Commenting out URLs temporarily to avoid import issues while running migrations..."
    local original_content=$(cat ./project/urls.py)
    # Comment out the entire content of the file
    sed -i '' 's/^/# /' ./project/urls.py
    # Create an empty urlpatterns block
    echo "urlpatterns = []" >>./project/urls.py

    # 3. Run makemigrations
    _log-info "Running makemigrations..."
    python "$PWD"/manage.py makemigrations || return 1
    # 4. Create cache table
    _log-info "Creating cache table..."
    python "$PWD"/manage.py createcachetable || return 1
    # 5. Run migrate
    _log-info "Running migrations..."
    python "$PWD"/manage.py migrate || return 1

    # 6. Restore original URLs
    _log-info "Restoring original project URLs..."
    echo "$original_content" >./project/urls.py
    _log-success "✓ Initial migration cycle complete"
}

# 🧼 Deletes all Django migration files and `__pycache__` folders (excluding venv)
# - Cleans migrations except `__init__.py`
# - Skips any path under `./venv/`
# 💡 Usage: django-migrate-and-cache-delete
function django-migrate-and-cache-delete() {
    # Get the current directory
    project_directory="$PWD"

    # Change to the project directory
    cd "$project_directory"

    # Delete migration files in Django apps (excluding venv)
    _log-info "Deleting all Django migration files..."
    find . -path "*/migrations/*.py" -not -name "__init__.py" -not -path "./venv/*" -exec sh -c 'app_name=$(basename "$(dirname "$(dirname "{}")")"); _log-success "Deleted $app_name -> $(basename "{}")"; rm "{}"' \; 2>/dev/null || true

    # Delete migration cache in Django apps (excluding venv)
    _log-info "Deleting all Django __pycache__ folders..."
    find . -type d -name "__pycache__" -not -path "./venv/*" -exec sh -c 'app_name=$(basename "$(dirname "$(dirname "{}")")"); [ "$app_name" != "." ] && _log-success "Deleted $app_name -> $(basename "$(dirname "{}")")/__pycache__" || _log-success "Deleted $(basename "$(dirname "{}")")/__pycache__"; rm -r "{}"' \; 2>/dev/null || true

    _log-success "Deleted all Django migration files and __pycache__ folders (excluding venv)"

    # Return to the original directory
    cd "$OLDPWD"
}

# 🔁 Rebuilds the Django project on a fresh database
# - Validates environment and settings
# - Optionally backs up data
# - Creates a new database and updates .env
# - Runs migrations and restores data
# 💡 Usage: django-database-init
function django-database-init() {
    # Redirect output to a log file
    local log_file="migration_$(date +'%Y%m%d%H%M%S').log"

    # {
    # Get the current directory
    local project_directory="$PWD"

    # 1. Validations
    python-environment-is-active || return 1
    django-settings local || return 1
    environment-variable-exists LOCAL_DB_NAME || return 1
    environment-variable-exists LOCAL_DB_PASSWORD || return 1

    # Prompt user for confirmation
    _confirm-or-abort "⚠️ This action will reset the project to its initial state. Proceed?" || return 1

    # 2. Export the PGPASSWORD environment variable
    postgres-connect || return 1

    # 3. Backup data if needed
    local backup_performed=false
    django-data-backup || return 1

    # 4. Create a new database
    postgres-database-create || return 1

    # 5. Update the .env file with the correct database name
    environment-variable-set "LOCAL_DB_NAME" "$db_name" || return 1

    # 6. Run initial migrations
    django-migrate-initial || return 1

    # 7. Restoration of data
    django-data-restore

    _log-success "✓ Database initialization complete"

    # } 2>&1 | tee -a "$log_file"

}

# ------------------------------------------------------------------------------
# 💾 Data Backup & Restore
# ------------------------------------------------------------------------------

# 📤 Backs up Django data to a local JSON fixture
# - Prompts user for confirmation before proceeding
# - Runs `dumpdata` and saves output to `data.json`
# - Sets `backup_performed=true` to allow automatic restore
# 💡 Usage: django-data-backup
function django-data-backup() {
    if ! _confirm-or-abort "Do you want to back up Django data?"; then
        _log-info "ℹ️ Skipping data backup..."
        return 0
    fi

    _log-info "📤 Performing Django data backup using 'dumpdata'..."
    python "$PWD/manage.py" dumpdata \
        --natural-foreign --natural-primary --indent 2 >data.json || return 1

    _log-success "✓ Data backup completed and saved to data.json"
    backup_performed=true
    sleep 1
}

# 🔁 Restores Django data from a fixture file
# - Restores from `data.json` if a backup was just made
# - Otherwise prompts the user to select a file and validates it
# - Uses `loaddata` to load the fixture, then resets DB sequences
# 💡 Usage: django-data-restore
function django-data-restore() {
    local backup_file=""

    if [[ "$backup_performed" = true ]]; then
        _log-info "♻️  Restoring from default backup (data.json)..."
        backup_file="data.json"
    else
        if ! _confirm-or-abort "Do you want to restore data from a backup file?"; then
            _log-info "ℹ️ Skipping data restore..."
            return 0
        fi

        backup_file=$(gum input --placeholder "/path/to/backup.sql" --prompt "📂 Enter the path to the backup file: ")

        if [[ -z "$backup_file" ]]; then
            _log-error "✗ No file path entered. Aborting restore"
            return 1
        fi

        if [[ ! -f "$backup_file" ]]; then
            _log-error "✗ File '$backup_file' does not exist. Aborting restore"
            return 1
        fi
    fi

    _log-info "📥 Restoring Django data from '$backup_file'..."
    python "$PWD/manage.py" loaddata "$backup_file" --traceback || return 1
    _log-success "✓ Data restoration complete"

    _log-info "🔁 Resetting database sequences..."
    apps=$(python "$PWD/manage.py" shell -c \
        "from django.apps import apps; print('\n'.join([app.label for app in apps.get_app_configs()]))")

    echo "$apps" | while IFS= read -r app; do
        _log-info "🔧 Resetting sequences for $app..."
        python "$PWD/manage.py" sqlsequencereset "$app" |
            python "$PWD/manage.py" dbshell
    done

    _log-success "✓ Database sequences reset"
}

# ------------------------------------------------------------------------------
# 🌍 Translations & Localization
# ------------------------------------------------------------------------------

# 🌐 Creates `.po` files for Arabic translations in apps with a `locale` directory
# - Recursively checks subdirectories for `locale/`
# - Skips venv and static files
# 💡 Usage: django-translations-make
function django-translations-make() {
    _log-info "🌐 Creating .po files for Arabic translations..."
    echo -e $(django-admin makemessages -l ar --ignore="venv/*" --ignore="static/*")" in main directory"
    # Loop through directories
    for d in */; do
        # Go to directory
        cd $d

        # Search for locale directory
        if [ -d "locale" ]; then
            echo -e $(django-admin makemessages -l ar)" in ${d::-1}"
        fi

        cd ..
    done
    _log-success "✓ .po files created for Arabic translations"
}

# 🛠️ Compiles translation `.po` files into `.mo` format
# - Recursively processes all subdirectories with a `locale/`
# 💡 Usage: django-translations-compile
function django-translations-compile() {
    _log-info "🛠️ Compiling translation .po files into .mo format..."
    # Loop through directories
    for d in */; do
        # Go to directory
        cd $d

        # Search for locale directory
        if [ -d "locale" ]; then
            echo -e $(django-admin compilemessages)" in $d"
        fi

        cd ..
    done
    _log-success "✓ .po files compiled into .mo format"
}
# ------------------------------------------------------------------------------
# 🚀 Development & Deployment Tools
# ------------------------------------------------------------------------------

# 🚀 Runs Django dev server on 0.0.0.0
# - Defaults to port 8000 if no port is specified
# 💡 Usage: django-run-server [port]
function django-run-server() {
    if [ $# -eq 0 ]; then
        _log-info "Starting Django server on port 8000..."
        python manage.py runserver 0.0.0.0:8000
    else
        _log-info "Starting Django server on port $1..."
        python manage.py runserver 0.0.0.0:$@
    fi
}

# 🔐 Uploads .env file and GCP_CREDENTIALS to GitHub Secrets
# 💡 Usage: django-upload-env-to-github-secrets
function django-upload-env-to-github-secrets() {
    # Get repo name in format owner/repo
    local REPO
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner) || {
        _log-error "✗ Failed to get repo name"
        return 1
    }

    _log-info "🔐 Uploading entire .env file to secret: ENVIRONMENT_VARIABLES"

    # Upload .env file content directly as multiline secret
    gh secret set ENVIRONMENT_VARIABLES --repo "$REPO" <.env || {
        _log-error "✗ Failed to upload ENVIRONMENT_VARIABLES"
        return 1
    }

    _log-success "✓ Uploaded ENVIRONMENT_VARIABLES to $REPO"

    _log-info "🔐 Uploading GCP_CREDENTIALS to GitHub secrets..."

    # Get GCP_CREDENTIALS using your custom command
    local GCP_CREDS
    GCP_CREDS=$(environment-variable-get "GCP_CREDENTIALS" --preserve-quotes --raw)

    # Validate that it's not empty
    if [[ -z "$GCP_CREDS" ]]; then
        _log-error "✗ GCP_CREDENTIALS is empty or failed to load"
        return 1
    fi

    # Upload GCP_CREDENTIALS as a separate GitHub secret
    gh secret set GCP_CREDENTIALS --repo "$REPO" -b"$GCP_CREDS" || {
        _log-error "✗ Failed to upload GCP_CREDENTIALS"
        return 1
    }

    _log-success "✓ Uploaded GCP_CREDENTIALS to $REPO"
}

# ------------------------------------------------------------------------------
# 🧪 Testing & Quality Assurance
# ------------------------------------------------------------------------------

# 🧪 Runs pytest with coverage using the test settings
# - Accepts optional test path (e.g., app/tests/test_views.py::TestView::test_get)
# 💡 Usage: django-run-pytest [path/to/test.py::TestClass::test_method]
function django-run-pytest() {
    _log-info "🧪 Running pytest with coverage..."
    django-settings test

    # Replace '/' with '.', remove '.py::', and replace '::' with '.'
    modified_arg=$(echo $1 | sed 's/\//./g' | sed 's/.py::/./' | sed 's/::/./')
    if [[ -n "$modified_arg" ]]; then
        _log-info "Testing: $modified_arg"
    else
        _log-info "Testing: All"
    fi

    coverage run -m pytest -v -n auto $modified_arg
    coverage report
    _log-success "✓ Pytest with coverage completed"
}

# 🧪 Runs Django tests using manage.py and test settings
# - Accepts optional test path in pytest-like format
# 💡 Usage: django-run-test [path/to/test.py::TestClass::test_method]
function django-run-test() {
    _log-info "🧪 Running Django tests..."
    django-settings test

    # Replace '/' with '.', remove '.py::', and replace '::' with '.'
    modified_arg=$(echo $1 | sed 's/\//./g' | sed 's/.py::/./' | sed 's/::/./')
    if [[ -n "$modified_arg" ]]; then
        _log-info "Testing: $modified_arg"
    else
        _log-info "Testing: All"
    fi

    python manage.py test $modified_arg
    _log-success "✓ Django tests completed"
}
# ------------------------------------------------------------------------------
# 🔍 Introspection & Automation
# ------------------------------------------------------------------------------

# 🔍 Finds all cron URL patterns in internal Django apps
# - Looks for path("cron/...") inside each app's urls.py
# - Uses INTERNAL_APPS from settings
# - Returns full URLs like: https://your-domain.com/store/cron/...
# 💡 Usage: django-find-cron-urls [project_root]
function django-find-cron-urls() {
    local project_root=${1:-.}
    local settings_file="$project_root/project/settings/base.py"

    _log-info "🚀 Searching for cron jobs in internal apps..."

    # 🔍 Extract INTERNAL_APPS values from base.py (e.g. "logs", "store", ...)
    local apps=($(sed -n '/INTERNAL_APPS *= *\[/,/]/p' "$settings_file" |
        grep -Eo '"[^"]+"' | tr -d '"'))

    local matches=()

    # 🔁 Loop through each internal app
    for app in "${apps[@]}"; do
        local urls_file="$project_root/$app/urls.py"

        # 📄 Only proceed if the app has a urls.py
        if [[ -f "$urls_file" ]]; then

            # 🧪 Read the entire file into one line to handle multi-line path() calls
            # 🔎 Find lines matching path("cron/...")
            local results=$(tr '\n' ' ' <"$urls_file" |
                sed 's/)/)\n/g' |
                grep 'path *( *["'\'']cron/' |
                sed -E "s/.*path *\( *['\"](cron\/[^\"')]+)['\"].*/$app\/\1/")

            # ➕ Add full URL paths to matches array
            if [[ -n "$results" ]]; then
                while IFS= read -r line; do
                    matches+=("https://$ADMIN_DOMAIN/$line")
                done <<<"$results"
            fi
        fi
    done

    # 🧾 Print the results
    if [[ ${#matches[@]} -gt 0 ]]; then
        _log-success "✓ Found ${#matches[@]} cron path(s):"
        for match in "${matches[@]}"; do
            _log-success "  ➤ $match"
        done
    else
        _log-warning "⚠️  No cron paths found"
    fi

    # 📤 Return the full URLs
    printf '%s\n' "${matches[@]}"
}
