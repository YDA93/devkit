# Environment
alias python-environment-create="python -m venv venv && source venv/bin/activate && echo 'environment created. & activated.'"
alias python-environment-activate='if [ -z "$VIRTUAL_ENV" ]; then source venv/bin/activate && echo "Environment activated."; else echo "Environment already activated."; fi'
alias python-environment-delete='if [ -d "venv" ]; then rm -rf venv; echo "Deleted environment"; fi'
alias python-environment-setup='python-environment-delete && python-environment-create && python-environment-activate && pip-install-all'

# Pip
alias pip-install='python-environment-activate && pip install -r requirements.txt'
alias pip-install-test='python-environment-activate && pip install -r requirements-test.txt'
alias pip-install-all='python-environment-activate && pip install -r requirements.txt && pip install -r requirements-test.txt'
alias pip-freeze='python-environment-activate && pip-chill > requirements.txt'
alias pip-freeze-test='python-environment-activate && pip-chill > requirements-test.txt'
alias pip-update='pip-install-all && pip-upgrade && pip-upgrade requirements-test.txt'

# Shell
alias python-shell='python-environment-activate && python manage.py shell'
alias python-shell-dev='python-environment-activate && django-settings-dev && python manage.py shell'
