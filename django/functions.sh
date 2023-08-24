# Run Server
function django-run-server() {
    if [ $# -eq 0 ]
        then
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
    for d in */ ; do
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
    for d in */ ; do
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

    # Delete migration files in Django apps (excluding venv)
    find "$project_directory" -path "*/migrations/*.py" -not -name "__init__.py" -not -path "$project_directory/venv/*" -exec sh -c 'echo "Deleted $(basename "$(dirname "$(dirname "{}")")")/$(basename "$(dirname "{}")")/$(basename "{}")"; rm "{}"' \;

    # Delete migration cache in Django apps (excluding venv)
    find "$project_directory" -type d -name "__pycache__" -not -path "$project_directory/venv/*" -exec sh -c 'echo "Deleted $(basename "$(dirname "{}")")/__pycache__"; rm -r "{}"' \;

    echo "Deleted all Django migration files and __pycache__ folders (excluding venv)."
}

function django_new_project_migrations() {

    project_directory="$PWD"

    # Prompt user for confirmation
    while true; do
        echo -n "This action will reset the project to its initial state.\nExisting migrations and caches will be removed, and new migrations will be created.\nProceed? (yes/no): "
        read confirm
        case $confirm in
            [Yy][Ee][Ss])
                break
                ;;
            [Nn][Oo])
                echo "Operation canceled."
                return
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done

    django-settings-local

    # Prompt user for PostgreSQL password
    echo -n "Enter PostgreSQL password: "
    read -s pg_password
    echo

    # Set the PGPASSWORD environment variable
    export PGPASSWORD="$pg_password"

    # Prompt user for backup and restore permission
    echo -n "Do you want to backup and restore data? (yes/no): "
    read backup_restore_choice
    backup_performed=false
    if [ "$backup_restore_choice" = "yes" ]; then
        # Perform data backup using dumpdata
        echo "Performing data backup using 'dumpdata'..."
        python "$project_directory"/manage.py dumpdata --natural-foreign --natural-primary --indent 2 > data.json
        echo "Data backup complete."
        sleep 2
        backup_performed=true
    else
        echo "Skipping data backup..."
    fi

    # Prompt user to enter database name
    echo -n "Enter name of the database you wish to create: "
    read db_name
    sleep 2

    # Check if db_name exists
    if psql -U postgres -h localhost -lqt | cut -d \| -f 1 | grep -qw "$db_name"; then
        while true; do
            echo -n "Database '$db_name' already exists. Do you want to drop it? (yes/no): "
            read drop_confirm
            case $drop_confirm in
                [Yy][Ee][Ss])
                    # Terminate active sessions
                    psql -U postgres -h localhost -c "SELECT pg_terminate_backend (pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$db_name';"
                    
                    # Drop the database
                    dropdb -U postgres -h localhost "$db_name"
                    echo "Database dropped."
                    sleep 2
                    break
                    ;;
                [Nn][Oo])
                    echo "Operation canceled. Exiting..."
                    return
                    ;;
                *)
                    echo "Please answer yes or no."
                    ;;
            esac
        done
    fi

    # Create new database
    echo "Creating new database..."
    createdb -U postgres -h localhost "$db_name"
    echo "New database created."
    sleep 2

    # Update the .env file with the correct database name
    echo "Updating LOCAL_DB_NAME value in .env file to $db_name..."
    sed -i '' "s/LOCAL_DB_NAME=\"[^\"]*\"/LOCAL_DB_NAME=\"$db_name\"/" .env
    echo "LOCAL_DB_NAME updated."
    sleep 2



    django_delete_migrations_and_cache

    # Store the original content of the urls.py
    original_content=$(cat ./project/urls.py)

    echo "Updating project URLs..."
    # Comment out the entire content of the file
    sed -i '' 's/^/# /' ./project/urls.py

    # Create an empty urlpatterns block
    echo "urlpatterns = []" >> ./project/urls.py

    # Run makemigrations
    python "$project_directory"/manage.py makemigrations

    # Create cache table
    python "$project_directory"/manage.py createcachetable

    # Run migrate
    python "$project_directory"/manage.py migrate

    # Check if data backup was performed
    if [ "$backup_performed" = true ]; then
        # Perform restoration using loaddata
        echo "Restoring data using 'loaddata'..."
        python "$project_directory"/manage.py loaddata data.json --traceback
        echo "Data restoration complete."
        sleep 2

        # Reset database sequences for all installed apps
        echo "Resetting database sequences..."
        function apps=$(python "$project_directory"/manage.py shell -c "from django.apps import apps; print(' '.join([app.label for app in apps.get_app_configs()]))")
        echo "$apps"
        echo "$apps" | xargs -n 1 python "$project_directory"/manage.py sqlsequencereset | python "$project_directory"/manage.py dbshell
        echo "Database sequences reset."
        sleep 2
    fi

    echo "Restoring original project URLs..."
    # Restore original urlpatterns block
    echo "$original_content" > ./project/urls.py


    # Clean up: Reset the PGPASSWORD environment variable
    unset PGPASSWORD

    echo "Project reset and migration complete."
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