# ------------------------------------------------------------------------------
# 🐍 Python Aliases
# ------------------------------------------------------------------------------
alias python='python3'
alias pip='pip3'

# ------------------------------------------------------------------------------
# 🐍 Python Virtual Environment Management
# ------------------------------------------------------------------------------

alias python-environment-create='python -m venv venv && source venv/bin/activate && echo "✅ Environment created and activated."'

function python-environment-activate() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        if [[ -f "venv/bin/activate" ]]; then
            source venv/bin/activate && echo "✅ Environment activated."
        else
            echo "❌ No virtual environment found. Run python-environment-create first."
        fi
    fi
}

alias python-environment-delete='[[ -d venv ]] && rm -rf venv && echo "🗑️ Environment deleted."'

alias python-environment-setup='python-environment-delete; python-environment-create && python-environment-activate && pip-install-all'

function python-environment-is-activated() {
    # Check if a virtual environment is currently activated
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "❌ Virtual environment is not activated."
        return 1
    else
        echo "✅ Virtual environment is active: $VIRTUAL_ENV"
        return 0
    fi
}

# ------------------------------------------------------------------------------
# 📦 Pip Dependency Management
# ------------------------------------------------------------------------------

alias pip-install='python-environment-activate && pip install -r requirements.txt'
alias pip-install-test='python-environment-activate && pip install -r requirements-test.txt'
alias pip-install-all='python-environment-activate && pip install -r requirements.txt && pip install -r requirements-test.txt'

alias pip-freeze='python-environment-activate && pip-chill > requirements.txt'
alias pip-freeze-test='python-environment-activate && pip-chill > requirements-test.txt'

alias pip-update='pip-install-all && pip-upgrade && pip-upgrade requirements-test.txt'

# ------------------------------------------------------------------------------
# 🐚 Python Shell Helpers
# ------------------------------------------------------------------------------

alias python-shell='python-environment-activate && python manage.py shell'
alias python-shell-dev='django-settings dev && python manage.py shell'
