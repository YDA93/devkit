# Run Server
django-run-server() {
    if [ $# -eq 0 ]
        then
            python manage.py runserver 0.0.0.0:8000
        else
            python manage.py runserver 0.0.0.0:$@

    fi
}

# Make Migrations
django-make-migrations() {
    python manage.py makemigrations $@
}

# Migrate
django-migrate() {
    python manage.py migrate $@
}

# Make Translations
django-translations-make() {
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
django-translations-compile() {
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
django_delete_migrations() {
    # Get the current directory
    project_directory="$PWD"

    # Delete migration files in Django apps (excluding venv)
    find "$project_directory" -path "*/migrations/*.py" -not -name "__init__.py" -not -path "$project_directory/venv/*" -exec sh -c 'echo "Deleted $(basename "$(dirname "$(dirname "{}")")")/$(basename "$(dirname "{}")")/$(basename "{}")"; rm "{}"' \;

    # Delete migration cache in Django apps (excluding venv)
    find "$project_directory" -type d -name "__pycache__" -not -path "$project_directory/venv/*" -exec sh -c 'echo "Deleted $(basename "$(dirname "{}")")/__pycache__"; rm -r "{}"' \;

    echo "Deleted all Django migration files and __pycache__ folders (excluding venv)."
}

# Start Project
django-start-project() {
    site_name=$1 # First Aurgment
    django-admin startproject $site_name
}

# Start App
django-start-app() {
    app_name=$1 # First Aurgment
    python manage.py startapp $app_name
}