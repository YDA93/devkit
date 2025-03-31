# ------------------------------------------------------------------------------
# 🐍 Python Virtual Environment Management
# ------------------------------------------------------------------------------

# 🐍 Activates the Python virtual environment from ./venv
# 💡 Usage: python-environment-activate
function python-environment-activate() {
    # Check if already activated
    if python-environment-is-active --quiet; then
        return 0
    fi

    # Activate if available
    if [[ -f "venv/bin/activate" ]]; then
        source venv/bin/activate && echo "✅ Environment activated: venv"
    else
        echo "❌ No virtual environment found at ./venv"
        echo "💡 Run: python-environment-create"
        return 1
    fi
}

# ✅ Checks if the current Python interpreter is from the ./venv virtual environment
# 💡 Usage: python-environment-is-active [--quiet]
function python-environment-is-active() {
    local expected_python="$(pwd)/venv/bin/python3"
    local current_python="$(command -v python3)"
    local quiet=false

    # Check for --quiet flag
    if [[ "$1" == "--quiet" ]]; then
        quiet=true
    fi

    if [[ "$current_python" == "$expected_python" ]]; then
        $quiet || echo "✅ Virtual environment is active: venv"
        return 0
    else
        $quiet || echo "❌ Virtual environment is not activated."
        return 1
    fi
}

# 🐍 Creates a Python virtual environment in ./venv and activates it
# 💡 Usage: python-environment-create
function python-environment-create() {
    python -m venv venv || {
        echo "❌ Failed to create virtual environment."
        return 1
    }

    python-environment-activate || return 1
}

# 🗑️ Deletes the existing ./venv virtual environment
# 💡 Usage: python-environment-delete
function python-environment-delete() {
    if python-environment-is-active --quiet; then
        deactivate
        echo "📴 Deactivated virtual environment."
    fi

    if [[ -d venv ]]; then
        rm -rf venv
        echo "🗑️ Environment deleted."
    else
        echo "ℹ️ No virtual environment found to delete."
    fi
}

# ⚙️ Deletes, recreates, activates the virtual environment and installs dependencies
# 💡 Usage: python-environment-setup
function python-environment-setup() {
    python-environment-delete
    python-environment-create && python-environment-activate && pip-install
}

# ------------------------------------------------------------------------------
# 🐚 Python Shell Helpers
# ------------------------------------------------------------------------------

# 🐚 Activates the environment, sets settings (optional), and opens the Django shell
# 💡 Usage: python-shell [local|dev|prod|test]
function python-shell() {
    local env=$1

    python-environment-activate || return 1

    if [[ -n "$env" ]]; then
        django-settings "$env" || return 1
    fi

    python manage.py shell
}

# ------------------------------------------------------------------------------
# 📦 Pip Dependency Management
# ------------------------------------------------------------------------------

# 📦 Installs Python dependencies
# - With --main: installs from requirements.txt
# - With --test: installs from requirements-test.txt
# - With no flags: installs both
# 💡 Usage: pip-install [--main|--test]
function pip-install() {
    python-environment-activate || return 1

    local install_main=false
    local install_test=false

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --main) install_main=true ;;
        --test) install_test=true ;;
        *)
            echo "❌ Unknown option: $1"
            return 1
            ;;
        esac
        shift
    done

    # If no flags provided, install both
    if ! $install_main && ! $install_test; then
        install_main=true
        install_test=true
    fi

    if $install_main; then
        echo "📦 Installing main dependencies from requirements.txt..."
        pip install -r requirements.txt || return 1
    fi

    if $install_test; then
        echo "🧪 Installing test/dev dependencies from requirements-test.txt..."
        pip install -r requirements-test.txt || return 1
    fi
}

# 🔄 Updates dependencies and regenerates requirements files
# - With --main: updates requirements.txt
# - With --test: updates requirements-test.txt
# - With no flags: updates both
# 💡 Usage: pip-update [--main|--test]
function pip-update() {
    local update_main=false
    local update_test=false

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
        --main) update_main=true ;;
        --test) update_test=true ;;
        *)
            echo "❌ Unknown option: $1"
            return 1
            ;;
        esac
        shift
    done

    # Default to updating both if no flags
    if ! $update_main && ! $update_test; then
        update_main=true
        update_test=true
    fi

    # Install and update
    if $update_main; then
        pip-install --main || return 1
        echo "🔄 Updating main dependencies in requirements.txt..."
        pip-upgrade requirements.txt || return 1
    fi

    if $update_test; then
        pip-install --test || return 1
        echo "🔄 Updating test dependencies in requirements-test.txt..."
        pip-upgrade requirements-test.txt || return 1
    fi
}
