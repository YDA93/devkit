# Settings
alias django-settings-local='django-environment-activate && echo "Local settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='django-environment-activate && echo "Development settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='django-environment-activate && echo "Production settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-settings-test='django-environment-activate && echo "Test settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.test'

# Shell
alias django-shell='django-environment-activate && python manage.py shell'
alias django-shell-dev='django-environment-activate && django-settings-dev && python manage.py shell'

# Environment
alias django-environment-create="python -m venv venv && source venv/bin/activate && echo 'environment created. & activated.'"
alias django-environment-activate='if [ -z "$VIRTUAL_ENV" ]; then source venv/bin/activate && echo "Environment activated."; else echo "Environment already activated."; fi'
alias django-environment-delete='if [ -d "venv" ]; then rm -rf venv; echo "Deleted environment"; fi'
alias django-environment-setup='django-environment-delete && django-environment-create && django-environment-activate && django-pip-install-all'
alias django-project-setup='django-environment-setup && django-pip-install-all && django_migrate_to_new_database'

# Pip
alias django-pip-install='django-environment-activate && pip install -r requirements.txt'
alias django-pip-install-test='django-environment-activate && pip install -r requirements-test.txt'
alias django-pip-install-all='django-environment-activate && pip install -r requirements.txt && pip install -r requirements-test.txt'
alias django-pip-freeze='django-environment-activate && pip-chill > requirements.txt'
alias django-pip-freeze-test='django-environment-activate && pip-chill > requirements-test.txt'

# Find templates
alias django-find-templates='django-environment-activate && python -c "import django; print(django.__path__)"'
alias django-format-documents='isort . && black --line-length 80 .'
