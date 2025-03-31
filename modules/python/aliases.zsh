# ------------------------------------------------------------------------------
# 🐍 Python Aliases
# ------------------------------------------------------------------------------
alias python='python3'
alias pip='pip3'

# ------------------------------------------------------------------------------
# 🐍 Python Virtual Environment Management
# ------------------------------------------------------------------------------

alias python-environment-create='python -m venv venv && source venv/bin/activate && echo "✅ Environment created and activated."'

# 🐍 Activates the Python virtual environment from ./venv
# 💡 Usage: python-environment-activate
function python-environment-activate() {
    local expected_python="$(pwd)/venv/bin/python3"
    local current_python="$(command -v python3)"

    if [[ "$current_python" == "$expected_python" ]]; then
        return 0
    fi

    if [[ -f "venv/bin/activate" ]]; then
        source venv/bin/activate && echo "✅ Environment activated: venv"
    else
        echo "❌ No virtual environment found at ./venv"
        echo "💡 Run: python-environment-create"
        return 1
    fi
}

alias python-environment-delete='[[ -d venv ]] && rm -rf venv && echo "🗑️ Environment deleted."'

alias python-environment-setup='python-environment-delete; python-environment-create && python-environment-activate && pip-install-all'

# ✅ Checks if the current Python interpreter is from the ./venv virtual environment
# 💡 Usage: python-environment-is-activated
function python-environment-is-activated() {
    local expected_python="$(pwd)/venv/bin/python3"
    local current_python="$(command -v python3)"

    if [[ "$current_python" == "$expected_python" ]]; then
        echo "✅ Virtual environment is active: venv"
        return 0
    else
        echo "❌ Virtual environment is not activated."
        return 1
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
