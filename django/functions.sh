# Run Server
function django-run-server() {
    if [ $# -eq 0 ]; then
        python manage.py runserver 0.0.0.0:8000
    else
        python manage.py runserver 0.0.0.0:$@

    fi
}

# Make Migrations
function django-make-migrations() {
    python manage.py makemigrations $@
}

# Migrate
function django-migrate() {
    python manage.py migrate $@
}

# Make Translations
function django-translations-make() {
    # Loop through directories
    for d in */; do
        # Go to directory
        cd $d

        # Search for locale directory
        if [ -d "locale" ]; then
            echo -e $(django-admin makemessages -l ar)" in $d"
        fi

        cd ..
    done
}

# Compile Translations
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

# Delete migrations
function django_delete_migrations_and_cache() {
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

# Start Project
function django-start-project() {
    site_name=$1 # First Aurgment
    django-admin startproject $site_name
}

# Start App
function django-start-app() {
    app_name=$1 # First Aurgment
    python manage.py startapp $app_name
}

function check_if_virtual_environment_activated() {
    # Check if a virtual environment is activated
    if [ -z "$VIRTUAL_ENV" ]; then
        echo "Error: No virtual environment activated!"
        return 1
    fi
}

function restore_and_reset_db() {
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

function backup_django_data() {
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

function django_migrate_to_new_database() {
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

    if ! check_if_virtual_environment_activated; then
        return 0
    fi

    django-settings-local

    if ! check_env_variable_exists LOCAL_DB_NAME; then
        return 0
    fi

    if ! check_env_variable_exists LOCAL_DB_PASSWORD; then
        return 0
    fi

    # Extracting value of LOCAL_DB_PASSWORD from .env file
    local_db_password=$(grep "LOCAL_DB_PASSWORD=" .env | cut -d '=' -f2)

    # Set the PGPASSWORD environment variable
    export PGPASSWORD="$local_db_password"

    if ! check_postgresql_password; then
        return 0
    fi

    # Prompt user for confirmation
    if prompt_confirmation "This action will reset the project to its initial state. Proceed?"; then
        echo "Confirmed!"
    else
        echo "Canceled!"
        return 0
    fi

    # Prompt user for backup
    backup_performed=false
    if prompt_confirmation "Do you want to backup data?"; then
        if ! backup_django_data "$project_directory"; then
            return 0
        fi
        backup_performed=true
    else
        echo "Skipping data backup..."
    fi

    if ! prompt_and_manage_database_creation; then
        return 0
    fi

    # Update the .env file with the correct database name
    if ! update_env_key_value "LOCAL_DB_NAME" "$db_name"; then
        return 0
    fi

    django_delete_migrations_and_cache

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
        if ! restore_and_reset_db "$project_directory"; then  # Using the default "data.json"
            return 0
        fi
    else
        if prompt_confirmation "Do you want to restore data from a backup file?"; then
            echo "Please provide the path to the backup file:"
            read backup_file
            if ! restore_and_reset_db "$project_directory" "$backup_file"; then  # Using the user-specified backup file
                return 0
            fi
        fi
    fi

    echo "Restoring original project URLs..."
    # Restore original urlpatterns block
    echo "$original_content" >./project/urls.py

    # Clean up: Reset the PGPASSWORD environment variable
    unset PGPASSWORD

    echo "Project reset and migration complete."

    # Redirect output back to console
    exec >&/dev/tty 2>&/dev/tty
}
