# Django
alias django-settings-local='export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-shell='python manage.py shell'
alias django-shell-dev='django-settings-dev && python manage.py shell'
alias django-envoirnment-create="python -m venv venv && source venv/bin/activate"
alias django-envoirnment-activate='source venv/bin/activate'
alias django-pip-install='pip install -r requirements.txt'
alias django-pip-install-test='pip install -r requirements-test.txt'
alias django-pip-install-all='pip install -r requirements.txt && pip install -r requirements-test.txt'
alias django-pip-freeze='pip freeze > requirements.txt'
alias django-pip-freeze-test='pip freeze > requirements-test.txt'
alias django-find-templates='python -c "import django; print(django.__path__)"'


django-run-server() {
    if [ $# -eq 0 ]
        then
            python manage.py runserver 0.0.0.0:8000
        else
            python manage.py runserver 0.0.0.0:$@

    fi
}

django-make-migrations() {
    python manage.py makemigrations $@
}

django-migrate() {
    python manage.py migrate $@
}

django-translations-make() {
    # Loop through directories    
    for d in */ ; do
        # Go to directory
        cd $d

        # Search for locale directory
        if [ -d "locale" ]; then
            django-admin makemessages -l ar && echo "Translation made to folder: $d"
        fi

        cd ..
    done
}

django-translations-compile() {
    # Loop through directories    
    for d in */ ; do
        # Go to directory
        cd $d

        # Search for locale directory
        if [ -d "locale" ]; then
            django-admin compilemessages && echo "Translation complied to folder: $d"
        fi

        cd ..
    done
}


django-start-project() {
    site_name=$1 # First Aurgment
    django-admin startproject $site_name
}

django-start-app() {
    app_name=$1 # First Aurgment
    python manage.py startapp $app_name
}