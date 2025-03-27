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

# 🛑 Asks the user to confirm before continuing (unless --quiet is passed).
# 💡 Usage: _confirm_or_abort "Are you sure?" [--quiet]
function _confirm_or_abort() {
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

function devkit-pc-setup() {
    _confirm_or_abort "Are you sure you want to set up your devkit environment?" "$@" || return 1

    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "Homebrew installation failed."
            return 1
        }
    else
        echo "Homebrew is already installed."
    fi

    # Verify Homebrew is working
    if ! brew --version &>/dev/null; then
        echo "Homebrew seems to be installed but not working properly."
        return 1
    fi

    echo "Homebrew is installed and working."

    # Now run homebrew-setup
    homebrew-setup
}

# 🔄 Updates tools like Homebrew, gcloud, Flutter, NPM, etc.
# Shows nice progress messages for each step.
function devkit-pc-update() {
    # Run sudo upfront and clear terminal
    sudo -v && clear

    # --- Brew ---
    _log_update_step "Homebrew and Packages" "homebrew-maintain"

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

    # --- devkit Software Updates ---
    _log_update_step "devkit System Updates" softwareupdate -ia --verbose
}

# 📦 Show versions of commonly used dev tools
function devkit-doctor() {
    echo "🔧 Development Environment Status:"
    echo "────────────────────────────────────"

    # Helper: check if command exists and print version
    function print_version() {
        local emoji="$1"
        local name="$2"
        local cmd="$3"
        local version_cmd="$4"

        # Pad label to 16 chars
        local padded_label=$(printf "%-22s" "$name:")

        if command -v "$cmd" &>/dev/null; then
            local version=$(eval "$version_cmd")
            echo "$emoji  $padded_label $version"
        else
            echo "$emoji  $padded_label Not installed"
        fi
    }

    print_version "🐍" "Python" "python3" "python3 --version | awk '{print \$2}'"
    print_version "📦" "Pip" "pip3" "pip3 --version | awk '{print \$2}'"
    print_version "🟢" "Node.js" "node" "node --version | sed 's/v//'"
    print_version "📦" "NPM" "npm" "npm --version"
    print_version "☕" "Java" "java" "java -version 2>&1 | awk -F '\"' '/version/ {print \$2}'"
    print_version "💙" "Flutter" "flutter" "flutter --version 2>/dev/null | head -n 1 | awk '{print \$2}'"
    print_version "🎯" "Dart" "dart" "dart --version 2>&1 | awk '{print \$4}'"
    print_version "🐘" "PostgreSQL" "psql" "psql --version | awk '{print \$3}'"
    print_version "🛠 " "Git" "git" "git --version | awk '{print \$3}'"
    print_version "💎" "Ruby" "ruby" "ruby --version | awk '{print \$2}'"
    print_version "📦" "Gems" "gem" "gem --version"
    print_version "🍎" "CocoaPods" "pod" "pod --version"
    print_version "☁️ " "Google Cloud CLI" "gcloud" "gcloud --version | grep 'Google Cloud SDK' | awk '{print \$4}'"
    print_version "🔥" "Firebase CLI" "firebase" "firebase --version"
    print_version "♻️ " "ccache" "ccache" "ccache --version | head -n 1 | awk '{print \$3}'"
    print_version "🧪" "Expect" "expect" "expect -v | awk '{print \$3}'"
    print_version "🧱" "Gradle" "gradle" "gradle --version | awk '/Gradle / {print \$2}'"
    print_version "🛍 " "MAS" "mas" "mas version"
    print_version "🖨 " "WeasyPrint" "weasyprint" "weasyprint --version | awk '{print \$3}'"
    print_version "💻" "Zsh" "zsh" "zsh --version | awk '{print \$2}'"
    echo "────────────────────────────────────"
}
