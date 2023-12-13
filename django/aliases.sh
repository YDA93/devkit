# Settings
alias django-settings-local='python-environment-activate && echo "Local settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='python-environment-activate && echo "Development settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='python-environment-activate && echo "Production settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-settings-test='python-environment-activate && echo "Test settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.test'

# Environment
alias django-project-setup='python-environment-setup && pip-install-all && django-migrate-to-new-database'

# Find templates
alias django-find-templates='python-environment-activate && python -c "import django; print(django.__path__)"'
alias django-format-documents='isort . && black --line-length 80 .'
