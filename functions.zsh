# A helper function to standardize the update process for various tools.

function _log_update_step() {
    local name="$1" # First argument: display name for logging
    shift           # Remaining arguments: command to execute

    echo "\n--------------------------------------------------"
    echo -e "🔧 Starting update: $name"
    echo "--------------------------------------------------"

    # Run the update command(s)
    if "$@"; then
        echo "--------------------------------------------------"
        echo "✅ Update successful: $name"
    else
        echo "--------------------------------------------------"
        echo "❌ Update failed: $name"
    fi

    echo "--------------------------------------------------"
}

# Updates system tools, SDKs, CLIs, and packages (Homebrew, Flutter, NPM, etc.)
# with nice output formatting and modular execution.
# ------------------------------------------------------------------------------
function update_software_and_packages() {
    # Run sudo upfront and clear terminal
    sudo -v && clear

    # --- Brew ---
    _log_update_step "Homebrew and Packages" bash -c '
        brew doctor
        brew update
        brew upgrade
        brew autoremove
        brew cleanup
    '

    # --- gcloud ---
    _log_update_step "gcloud CLI" gcloud components update

    # --- Flutter ---
    _log_update_step "Flutter SDK" bash -c '
        flutter upgrade --force
        flutter doctor -v
    '

    # --- NPM ---
    _log_update_step "NPM and Dependencies" bash -c '
        npm install -g npm@latest
        sudo npm-check -u
        npm audit fix --force
    '

    # --- Firebase CLI ---
    _log_update_step "Firebase CLI" bash -c '
        npm install -g firebase-tools
        npm audit fix --force
    '

    # --- Rosetta ---
    _log_update_step "Rosetta (Intel Compatibility)" softwareupdate --install-rosetta --agree-to-license

    # --- App Store Apps ---
    _log_update_step "App Store Apps (via mas-cli)" bash -c '
        mas outdated
        mas upgrade
    '

    # --- macOS Software Updates ---
    _log_update_step "macOS System Updates" softwareupdate -ia --verbose
}

# Checks if a specific environment variable exists and is non-empty in a .env file.
#
# Usage:
#   environment_variable_exists [variable_name] [env_file]
function environment_variable_exists() {
    local var_name="$1"
    local env_file="${2:-.env}"

    # Check if file exists
    if [[ ! -f "$env_file" ]]; then
        echo "❌ Error: File not found – $env_file"
        return 1
    fi

    # Check if the variable is present
    if ! grep -q "^${var_name}=" "$env_file"; then
        echo "❌ Error: $var_name is not defined in $env_file"
        return 1
    fi

    # Check if the variable is not empty
    if grep -q "^${var_name}=$" "$env_file"; then
        echo "❌ Error: $var_name is defined but empty in $env_file"
        return 1
    fi

    return 0
}

# Updates or adds a key-value pair in the .env file.
#
# Usage:
#   environment_variable_set [key] [value]
function environment_variable_set() {
    local key="$1"
    local value="$2"
    local env_file=".env"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "❌ Error: Key or value is missing!"
        echo "Usage: environment_variable_set [key] [value]"
        return 1
    fi

    # Ensure .env file exists
    if [ ! -f "$env_file" ]; then
        echo "❌ Error: .env file not found."
        return 1
    fi

    echo "🔹 Setting $key=\"$value\" in $env_file..."

    # Escape forward slashes and ampersands for sed replacement
    local escaped_value
    escaped_value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')

    if grep -q "^$key=" "$env_file"; then
        # Key exists, update it (handles values with or without quotes)
        sed -i '' -E "s|^$key=.*|$key=\"$escaped_value\"|" "$env_file"
    else
        # Key doesn't exist, append it
        echo "$key=\"$value\"" >>"$env_file"
    fi

    echo "✅ $key successfully set."
}

# Function to prompt user for confirmation unless --quiet is provided
#
# Usage:
#   confirm_or_abort [message] [--quiet]
function confirm_or_abort() {
    local message="$1"
    shift # Remove the first argument (message) from the list

    # Check if --quiet flag is present
    for arg in "$@"; do
        if [[ "$arg" == "--quiet" ]]; then
            return 0
        fi
    done

    local CONFIRM=""
    while true; do
        # Properly print message first, then prompt on next line
        printf "%s\n(yes/no): " "$message"

        if [[ -n "$BASH_VERSION" ]]; then
            read CONFIRM
        else
            read "? " CONFIRM
        fi

        case "$CONFIRM" in
        yes)
            return 0
            ;;
        no)
            echo "Aborting action."
            return 1
            ;;
        *)
            echo "❌ Please type 'yes' or 'no'."
            ;;
        esac
    done
}

# Opens a project folder from ~/Desktop/dev using VS Code.
# Supports auto-completion for available project names.
# Usage:
#   code_project [project_name]
function code_project() {
    local BASE_PATH="$HOME/Desktop/dev"
    local PROJECT_NAME=$1 # Get the first argument as project name

    # If no project is provided, list available projects
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "📂 Available projects in $BASE_PATH:"
        ls -1 "$BASE_PATH"
        return 1
    fi

    # Define project path
    local PROJECT_PATH="$BASE_PATH/$PROJECT_NAME"

    # Check if the directory exists
    if [[ -d "$PROJECT_PATH" ]]; then
        echo "🚀 Opening project: $PROJECT_NAME"
        code "$PROJECT_PATH"
    else
        echo "❌ Project not found: $PROJECT_PATH"
        return 1
    fi
}

# Auto-completion for code_project function
function _code_project_completions() {
    local BASE_PATH="$HOME/Desktop/dev"
    COMPREPLY=($(compgen -W "$(ls -1 "$BASE_PATH")" -- "${COMP_WORDS[1]}"))
}

# Enable tab completion for code_project
complete -F _code_project_completions code_project
