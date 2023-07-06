# Django
alias django-run-server='python manage.py runserver 0.0.0.0:8000'
alias django-shell='python manage.py shell'
alias django-settings-local='export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-envoirnment-create="python -m venv venv && source venv/bin/activate"
alias django-envoirnment-activate='source venv/bin/activate'
alias django-pip-install='pip install -r requirements.txt'
alias django-pip-install-test='pip install -r requirements-test.txt'
alias django-pip-install-all='pip install -r requirements.txt && pip install -r requirements-test.txt'
alias django-pip-freeze='pip freeze > requirements.txt'