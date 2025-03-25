# 📦 Runs a command with a clear start/success/failure message.
# 💡 Usage: _log_update_step "Thing to update" <command>
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

# 🔄 Updates tools like Homebrew, gcloud, Flutter, NPM, etc.
# Shows nice progress messages for each step.
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

# 🛑 Asks the user to confirm before continuing (unless --quiet is passed).
# 💡 Usage: confirm_or_abort "Are you sure?" [--quiet]
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
