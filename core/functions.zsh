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

# 🧪 Runs a command and exits if it fails, with a custom success message.
# 💡 Usage: _run_or_abort "Doing something" "✅ Success message" <command>
function _run_or_abort() {
    local description="$1"
    local success_msg="$2"
    shift 2

    echo "$description..."
    "$@"
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "❌ Failed: $description"
        return $exit_code
    fi
    if [ -n "$success_msg" ]; then
        echo "$success_msg"
        echo ""
    fi
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

# 🛡️ Checks if DevKit is fully set up based on required tools
# 🧪 Usage: devkit-is-setup [--quiet] || return 1
function devkit-is-setup() {
    local quiet=false
    if [[ "$1" == "--quiet" || "$1" == "-q" ]]; then
        quiet=true
    fi

    local required_tools=(
        git
        zsh
        node
        npm
        python3
        pip3
        java
        docker
        flutter
        dart
        gcloud
        firebase
        psql
        ruby
        pod
        mas
    )

    local missing=()

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing+=("$tool")
        fi
    done

    if ((${#missing[@]} > 0)); then
        if [[ "$quiet" == false ]]; then
            echo "⚠️  DevKit is not fully set up."
            echo "🚫 Missing tools: ${missing[*]}"
            echo "👉 Run: devkit-pc-setup"
        fi
        return 1
    fi

    if [[ "$quiet" == false ]]; then
        echo "✅ DevKit is fully set up!"
    fi

    return 0
}

# 🛠️ Checks for macOS software updates and installs them if available.
# 💡 Usage: _check-software-updates && echo "Up to date" || echo "Reboot required"
function _check-software-updates() {
    # 🛠️ Installs all available macOS software updates (system + security)
    echo "🔍 Checking for macOS software updates..."

    # Check for available software updates
    available_updates=$(softwareupdate -l 2>&1)

    if echo "$available_updates" | grep -q "No new software available"; then
        echo "✅ No updates available. Skipping installation."
        return 0
    else
        echo "⬇️  Updates available. Installing now..."
        softwareupdate -ia --verbose
        echo "✅ Updates installed successfully."
        echo "🔁 A system restart may be required to complete installation."
        echo "⚠️  Please reboot your Mac and then re-run: devkit-pc-setup"
        return 1 # Signal that a reboot is needed
    fi
}

# 🚀 Sets up your full devkit environment (tools, SDKs, configs).
# 💡 Usage: devkit-pc-setup [--quiet]  # Skips confirmation prompts
function devkit-pc-setup() {

    local log_file="$DEVKIT_ROOT/setup_$(date +'%Y%m%d%H%M%S').log"

    {
        _confirm_or_abort "Are you sure you want to set up your devkit environment?" "$@" || return 1

        _check-software-updates || return 1

        # 🔄 Syncs your custom .gitconfig to the system/global Git config
        git-sync-config || return 1

        # Install Homebrew and packages
        homebrew-setup || return 1

        # Now its time to ask the user to configure his cask apps prior to going further
        _confirm_or_abort "🧩 Please take a moment to open and configure your downloaded apps (e.g. VS Code, Android Studio). Press Enter when you're ready to continue." "$@" || return 1

        # Install NPM and packages
        npm-setup || return 1

        # Install MAS (Mac App Store) and applications
        mas-setup || return 1

        # Install Xcode and Command Line Tools
        xcode_setup || return 1

        # Flutter Android Setup
        flutter-android-sdk-setup || return 1

        echo "--------------------------------------------------"
        echo "✅ devkit environment setup complete!"
        echo "--------------------------------------------------"

    } 2>&1 | tee -a "$log_file"

}

# 🔄 Updates tools like Homebrew, gcloud, Flutter, NPM, etc.
# Shows nice progress messages for each step.
function devkit-pc-update() {
    local log_file="$DEVKIT_ROOT/update_$(date +'%Y%m%d%H%M%S').log"

    {
        # Run sudo upfront and clear terminal
        sudo -v && clear

        # --- Brew ---
        _log_update_step "Homebrew and Packages" "homebrew-maintain"

        # --- pip (Python) ---
        _log_update_step "pip (Python)" bash -c '
        pip3 install --upgrade pip setuptools wheel
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
        npm-check -g -u
        '

        # --- CocoaPods ---
        _log_update_step "CocoaPods" pod repo update

        # --- Rosetta ---
        _log_update_step "Rosetta (Intel Compatibility)" softwareupdate --install-rosetta --agree-to-license

        # --- App Store Apps ---
        _log_update_step "App Store Apps (via mas-cli)" mas-maintain

        # --- devkit Software Updates ---
        _log_update_step "devkit System Updates" softwareupdate -ia --verbose

    } 2>&1 | tee -a "$log_file"
}

# 📦 Show versions of commonly used dev tools and warn if missing
function devkit-doctor() {
    echo "🔧 Development Environment Status:"
    echo "────────────────────────────────────"

    # Track missing tools
    local missing_tools=()

    # Helper: check if command exists and print version
    function print_version() {
        local emoji="$1"
        local name="$2"
        local cmd="$3"
        local version_cmd="$4"

        local padded_label=$(printf "%-24s" "$name:")

        if command -v "$cmd" &>/dev/null; then
            local version=$(eval "$version_cmd")
            echo "$emoji  $padded_label $version"
        else
            echo "$emoji  $padded_label Not installed"
            missing_tools+=("$name")
        fi
    }
    print_version "🖥 " "VS Code" "code" "code --version | head -n 1"
    print_version "📱" "Android SDK" "sdkmanager" "sdkmanager --version"
    print_version "🔌" "Android Platform Tools" "adb" "adb version | head -n 1 | awk '{print \$5}'"
    print_version "🏗 " "Android Studio" "studio" "studio --version 2>/dev/null | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'"
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
    print_version "🐳" "Docker" "docker" "docker --version | awk '{gsub(/,/,\"\"); print \$3}'"
    print_version "🔥" "Firebase CLI" "firebase" "firebase --version"
    print_version "♻️ " "ccache" "ccache" "ccache --version | head -n 1 | awk '{print \$3}'"
    print_version "🧪" "Expect" "expect" "expect -v | awk '{print \$3}'"
    print_version "🧱" "Gradle" "gradle" "gradle --version | awk '/Gradle / {print \$2}'"
    print_version "🛍 " "MAS" "mas" "mas version"
    print_version "🖨 " "WeasyPrint" "weasyprint" "weasyprint --version | awk '{print \$3}'"
    print_version "💻" "Zsh" "zsh" "zsh --version | awk '{print \$2}'"

    echo "────────────────────────────────────"

    if ((${#missing_tools[@]} > 0)); then
        echo "⚠️  Missing tools: ${missing_tools[*]}"
        echo "👉 Run: devkit-pc-setup to install and configure required packages."
        return 1
    else
        echo "✅ All essential tools are installed!"
    fi
}
