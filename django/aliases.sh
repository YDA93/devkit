# Settings
alias django-settings-local='export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='export DJANGO_SETTINGS_MODULE=project.settings.prod'

# Shell
alias django-shell='python manage.py shell'
alias django-shell-dev='django-settings-dev && python manage.py shell'

# Envoirnment
alias django-envoirnment-create="python -m venv venv && source venv/bin/activate"
alias django-envoirnment-activate='source venv/bin/activate'

# Pip
alias django-pip-install='pip install -r requirements.txt'
alias django-pip-install-test='pip install -r requirements-test.txt'
alias django-pip-install-all='pip install -r requirements.txt && pip install -r requirements-test.txt'
alias django-pip-freeze='pip freeze > requirements.txt'
alias django-pip-freeze-test='pip freeze > requirements-test.txt'

# Find templates
alias django-find-templates='python -c "import django; print(django.__path__)"'
