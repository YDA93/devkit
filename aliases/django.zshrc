# Django
alias django-run-server='python manage.py runserver 0.0.0.0:8000'
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
alias django-translations-make='django-admin makemessages -l ar'
alias django-translations-compile='django-admin compilemessages'
alias django-make-migrations='python manage.py makemigrations'
alias django-migrate='python manage.py migrate'
alias django-find-templates='python -c "import django; print(django.__path__)"'


django-start-project() {
    name=$1 # First Aurgment
    django-admin startproject $name
}

django-start-app() {
    name=$1 # First Aurgment
    python manage.py startapp $name
}