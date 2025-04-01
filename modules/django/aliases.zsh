# ------------------------------------------------------------------------------
# 🧰 Django Project Setup
# ------------------------------------------------------------------------------

alias django-project-setup='python-environment-setup && pip-install && django-database-init'

# ------------------------------------------------------------------------------
# 🔍 Django Utilities
# ------------------------------------------------------------------------------

# Print the path to Django's internal template directory
alias django-find-templates='python-environment-activate && python -c "import django; print(django.__path__)"'

# Format all code using isort and black
alias django-format-documents='isort . && black --line-length 80 .'

# Collect static files for deployment (clears first)
alias django-collect-static='python-environment-activate && python manage.py collectstatic --clear --noinput'
