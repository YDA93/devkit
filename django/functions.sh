# ------------------------------------------------------------------------------
# 🚀 Django Server Shortcuts
# ------------------------------------------------------------------------------
function django-run-server() {
    if [ $# -eq 0 ]; then
        python manage.py runserver 0.0.0.0:8000
    else
        python manage.py runserver 0.0.0.0:$@

    fi
}

function django-secret-key-generate() {
    raw_key=$(python3 -c "
import secrets
import string

safe_chars = string.ascii_letters + string.digits + '!@#%^&*(-_=+)'
print(''.join(secrets.choice(safe_chars) for _ in range(50)))
")

    environment_variable_set "DJANGO_SECRET_KEY" "$raw_key"
}

# 🔍 Description:
#   Finds and prints all "cron/" URL patterns in Django apps defined in
#   INTERNAL_APPS (inside project/settings/base.py). Output is prefixed
#   with the app name and formatted as a full URL.
#
# 💡 Usage:
#   django-find-cron-urls [project_root]
#   - If no argument is passed, it defaults to the current directory.
#   - You can also capture the output:
#       crons=($(django-find-cron-urls))
#
# 🧠 How it works:
#   - Parses INTERNAL_APPS list using sed/grep.
#   - Loops through each app directory to find `urls.py`.
#   - Reads the entire file into a single line to handle multi-line path().
#   - Breaks paths again at `)` to isolate each call.
#   - Uses grep to find `path("cron/...")` patterns.
#   - Ignores commented-out lines automatically (because comments don't match).
#   - Extracts the cron path using sed and prefixes it with the app name.
#
# 📦 Output:
#   ✅ Found 2 cron path(s):
#     ➤ https://$ADMIN_DOMAIN/app_name/cron/your-path/
#
#   🧾 Return value:
#     A list of fully formatted cron URLs.
# -----------------------------------------------------------------------------
function django-find-cron-urls() {
    local project_root=${1:-.}
    local settings_file="$project_root/project/settings/base.py"

    echo "🚀 Searching for cron jobs in internal apps..."

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
        echo "✅ Found ${#matches[@]} cron path(s):"
        for match in "${matches[@]}"; do
            echo "  ➤ $match"
        done
    else
        echo "⚠️  No cron paths found."
    fi

    # 📤 Return the full URLs
    printf '%s\n' "${matches[@]}"
}

# ------------------------------------------------------------------------------
# 🌍 Django Translations Shortcuts
# ------------------------------------------------------------------------------

function django-translations-make() {
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
}

function django-translations-compile() {
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
}

# ------------------------------------------------------------------------------
# 🧱 Django Project Management Shortcuts
# ------------------------------------------------------------------------------

function django-project-start() {
    site_name=$1 # First Aurgment
    django-admin startproject $site_name
}

function django-app-start() {
    app_name=$1 # First Aurgment
    python manage.py startapp $app_name
}

# ------------------------------------------------------------------------------
# 🗃️ Django Database Management Shortcuts
# ------------------------------------------------------------------------------
function django-loaddata() {
    local project_directory=$1
    local backup_file=$2

    # Check if project_directory is provided
    if [ -z "$project_directory" ]; then
        echo "Error: Project directory is not provided!"
        return 1
    fi

    # Use default backup file if none provided
    if [ -z "$backup_file" ]; then
        backup_file="data.json"
    fi

    # Perform restoration using loaddata
    echo "Restoring django data using 'loaddata' from $backup_file..."
    python "$project_directory"/manage.py loaddata "$backup_file" --traceback
    echo "Data restoration complete."
    sleep 2

    # Reset database sequences for all installed apps
    echo "Resetting database sequences..."
    apps=$(python "$project_directory"/manage.py shell -c "from django.apps import apps; print('\n'.join([app.label for app in apps.get_app_configs()]))")
    echo "$apps" | while IFS= read -r app; do
        echo "Resetting sequences for $app..."
        python "$project_directory"/manage.py sqlsequencereset $app | python "$project_directory"/manage.py dbshell
    done
    echo "Database sequences reset."
    sleep 2
}

function django-dumpdata() {
    local project_directory=$1

    # Check if project_directory is provided
    if [ -z "$project_directory" ]; then
        echo "Error: Project directory is not provided!"
        return 1
    fi

    # Perform data backup using dumpdata
    echo "Performing django data backup using 'dumpdata'..."
    python "$project_directory"/manage.py dumpdata --natural-foreign --natural-primary --indent 2 >data.json
    echo "Data backup complete."
    sleep 2
}

function django-make-migrations() {
    python manage.py makemigrations $@
}

function django-migrate() {
    python manage.py migrate $@
}

function django-delete-migrations-and-cache() {
    # Get the current directory
    project_directory="$PWD"

    # Change to the project directory
    cd "$project_directory"

    # Delete migration files in Django apps (excluding venv)
    find . -path "*/migrations/*.py" -not -name "__init__.py" -not -path "./venv/*" -exec sh -c 'app_name=$(basename "$(dirname "$(dirname "{}")")"); echo "Deleted $app_name -> $(basename "{}")"; rm "{}"' \; 2>/dev/null || true

    # Delete migration cache in Django apps (excluding venv)
    find . -type d -name "__pycache__" -not -path "./venv/*" -exec sh -c 'app_name=$(basename "$(dirname "$(dirname "{}")")"); [ "$app_name" != "." ] && echo "Deleted $app_name -> $(basename "$(dirname "{}")")/__pycache__" || echo "Deleted $(basename "$(dirname "{}")")/__pycache__"; rm -r "{}"' \; 2>/dev/null || true

    echo "Deleted all Django migration files and __pycache__ folders (excluding venv)."

    # Return to the original directory
    cd "$OLDPWD"
}

function django-migrate-to-new-database() {
    # Stop executing the script on any error
    set -e

    # Redirect output to a log file
    LOGFILE="migration_$(date +'%Y%m%d%H%M%S').log"
    exec > >(tee -a $LOGFILE) 2>&1
    echo "Output is being logged to $LOGFILE"

    # Redirect output to console on exit
    trap 'exec >& /dev/tty 2>& /dev/tty' EXIT

    # Get the current directory
    project_directory="$PWD"

    python-environment-is-activated || return 0

    django-settings-local

    environment_variable_exists LOCAL_DB_NAME || return 0

    environment_variable_exists LOCAL_DB_PASSWORD || return 0

    # Extracting value of LOCAL_DB_PASSWORD from .env file
    local_db_password=$(grep "LOCAL_DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d '"')

    # Set the PGPASSWORD environment variable
    export PGPASSWORD="$local_db_password"

    postgres_check_password || return 0

    # Prompt user for confirmation
    if confirm_or_abort "This action will reset the project to its initial state. Proceed?"; then
        echo "Confirmed!"
    else
        echo "Canceled!"
        return 0
    fi

    # Prompt user for backup
    backup_performed=false
    if confirm_or_abort "Do you want to backup data?"; then
        django-dumpdata "$project_directory" || return 0

        backup_performed=true
    else
        echo "Skipping data backup..."
    fi

    postgres_manage_database_creation || return 0

    # Update the .env file with the correct database name
    environment_variable_set "LOCAL_DB_NAME" "$db_name" || return 0

    django-delete-migrations-and-cache

    # Store the original content of the urls.py
    original_content=$(cat ./project/urls.py)

    echo "Updating project URLs..."
    # Comment out the entire content of the file
    sed -i '' 's/^/# /' ./project/urls.py

    # Create an empty urlpatterns block
    echo "urlpatterns = []" >>./project/urls.py

    # Run makemigrations
    python "$project_directory"/manage.py makemigrations

    # Create cache table
    python "$project_directory"/manage.py createcachetable

    # Run migrate
    python "$project_directory"/manage.py migrate

    # Restore data logic
    if [ "$backup_performed" = true ]; then
        django-loaddata "$project_directory" || return 0 # Using the default "data.json"

    else
        if confirm_or_abort "Do you want to restore data from a backup file?"; then
            echo "Please provide the path to the backup file:"
            read backup_file
            django-loaddata "$project_directory" "$backup_file" || return 0 # Using the user-specified backup file
        fi
    fi

    echo "Restoring original project URLs..."
    # Restore original urlpatterns block
    echo "$original_content" >./project/urls.py

    # Clean up: Reset the PGPASSWORD environment variable
    unset PGPASSWORD

    echo "Project reset and migration complete."

    # Now redirect output back to console
    exec >&/dev/tty 2>&/dev/tty
}

# ------------------------------------------------------------------------------
# 🧪 Django Test Shortcuts
# ------------------------------------------------------------------------------

function django-run-pytest() {
    django-settings-test

    # Replace '/' with '.', remove '.py::', and replace '::' with '.'
    modified_arg=$(echo $1 | sed 's/\//./g' | sed 's/.py::/./' | sed 's/::/./')
    if [[ -n "$modified_arg" ]]; then
        echo "Testing: $modified_arg"
    else
        echo "Testing: All"
    fi

    coverage run -m pytest -v -n auto $modified_arg
    coverage report
}

function django-run-test() {
    django-settings-test

    # Replace '/' with '.', remove '.py::', and replace '::' with '.'
    modified_arg=$(echo $1 | sed 's/\//./g' | sed 's/.py::/./' | sed 's/::/./')
    if [[ -n "$modified_arg" ]]; then
        echo "Testing: $modified_arg"
    else
        echo "Testing: All"
    fi

    python manage.py test $modified_arg
}
