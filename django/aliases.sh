# Settings
alias django-settings-local='django-envoirnment-activate && export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='django-envoirnment-activate && export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='django-envoirnment-activate && export DJANGO_SETTINGS_MODULE=project.settings.prod'

# Shell
alias django-shell='django-envoirnment-activate && python manage.py shell'
alias django-shell-dev='django-envoirnment-activate && django-settings-dev && python manage.py shell'

# Envoirnment
alias django-envoirnment-create="python -m venv venv && source venv/bin/activate && echo 'Envoirnment created. & activated.'"
alias django-envoirnment-activate='source venv/bin/activate && echo "Envoirnment activated."'
alias django-delete-envoirnment='if [ -d "venv" ]; then rm -rf venv; echo "Deleted envoirnment"; fi'
alias django-envoirnment-setup='django-delete-envoirnment && django-envoirnment-create && django-envoirnment-activate && django-pip-install-all'
alias django-project-setup='django-envoirnment-setup && django-pip-install-all && django_migrate_to_new_database'

# Pip
alias django-pip-install='django-envoirnment-activate && pip install -r requirements.txt'
alias django-pip-install-test='django-envoirnment-activate && pip install -r requirements-test.txt'
alias django-pip-install-all='django-envoirnment-activate && pip install -r requirements.txt && pip install -r requirements-test.txt'
alias django-pip-freeze='django-envoirnment-activate && pip-chill > requirements.txt'
alias django-pip-freeze-test='django-envoirnment-activate && pip-chill > requirements-test.txt'

# Find templates
alias django-find-templates='django-envoirnment-activate && python -c "import django; print(django.__path__)"'
