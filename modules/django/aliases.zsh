# ------------------------------------------------------------------------------
# ⚙️ Django Settings Shortcuts
# ------------------------------------------------------------------------------

alias django-settings-local='python-environment-activate && echo "🌱 Local settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.local'
alias django-settings-dev='python-environment-activate && echo "🛠️ Development settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.dev'
alias django-settings-prod='python-environment-activate && echo "🚀 Production settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.prod'
alias django-settings-test='python-environment-activate && echo "🧪 Test settings activated" && export DJANGO_SETTINGS_MODULE=project.settings.test'

# ------------------------------------------------------------------------------
# 🧰 Django Project Setup
# ------------------------------------------------------------------------------

alias django-project-setup='python-environment-setup && pip-install-all && django-migrate-to-new-database'

# ------------------------------------------------------------------------------
# 🔍 Django Utilities
# ------------------------------------------------------------------------------

# Print the path to Django's internal template directory
alias django-find-templates='python-environment-activate && python -c "import django; print(django.__path__)"'

# Format all code using isort and black
alias django-format-documents='isort . && black --line-length 80 .'

# Collect static files for deployment (clears first)
alias django-collect-static='python-environment-activate && python manage.py collectstatic --clear --noinput'
