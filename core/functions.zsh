# ------------------------------------------------------------------------------
# 🧰 DevKit Support Utilities
# ------------------------------------------------------------------------------

# 🧰 Initializes your CLI by asking user for name, email, and app selections (multi-select)
# - Stores results in ~/devkit/.settings
# 💡 Usage: devkit-settings-setup
function devkit-settings-setup() {
    # Define file paths
    local settings_file="$DEVKIT_ROOT/.settings"
    local cloned_settings_file="$DEVKIT_ROOT/.settings_clone"

    # Check and create the directory safely
    if ! mkdir -p "$(dirname "$settings_file")" 2>/dev/null || [ ! -w "$(dirname "$settings_file")" ]; then
        _log_error "❌ Cannot create or write to: $(dirname "$settings_file")"
        _log_hint "➡️ Please check disk space, permissions, or sync conflicts."
        exit 1
    fi

    # Welcome message
    gum style --border normal --margin "1 2" --padding "1 2" --bold "👋 Welcome! Let's set up DevKit CLI environment."

    # Clone settings for safe handling
    if [[ -f "$settings_file" ]]; then
        if ! cp "$settings_file" "$cloned_settings_file" 2>/dev/null; then
            _log_error "❌ Failed to clone settings file to $cloned_settings_file"
            exit 1
        fi
    else
        if ! echo "" >"$cloned_settings_file" 2>/dev/null; then
            _log_error "❌ Failed to create empty cloned settings file: $cloned_settings_file"
            exit 1
        fi
    fi

    # Get user inputs for settings
    _log_info "🔧 Please provide your details and select the apps you want to install."

    # Load basic user info
    full_name=$(gum input --header "👤 Full Name" --value "$(_read_setting_from_file "full_name" "$cloned_settings_file")")
    email=$(gum input --header "📧 Email Address" --value "$(_read_setting_from_file "email" "$cloned_settings_file")")

    # Define app lists
    local mas_apps=("1450874784|Transporter" "899247664|TestFlight" "1287239339|ColorSlurp" "409183694|Keynote" "409201541|Pages" "409203825|Numbers")
    local cask_apps=("discord" "cloudflare-warp" "firefox" "onedrive" "whatsapp" "zoom" "microsoft-auto-update" "microsoft-edge" "microsoft-excel" "microsoft-outlook" "microsoft-powerpoint" "microsoft-teams" "microsoft-word")
    local formula_apps=("weasyprint")

    # Handle each type of app
    _show_app_selection_menu "mas" "${mas_apps[@]}"
    _show_app_selection_menu "cask" "${cask_apps[@]}"
    _show_app_selection_menu "formula" "${formula_apps[@]}"

    # Cleanup and save settings
    echo "full_name=\"$full_name\"" >"$settings_file"
    echo "email=\"$email\"" >>"$settings_file"
    echo "" >>"$settings_file"
    echo "# mas apps" >>"$settings_file"
    _append_app_selections_to_settings "mas" "${mas_apps[@]}"
    echo "# cask apps" >>"$settings_file"
    _append_app_selections_to_settings "cask" "${cask_apps[@]}"
    echo "# formula apps" >>"$settings_file"
    _append_app_selections_to_settings "formula" "${formula_apps[@]}"
    _log_success "✅ Settings saved to $settings_file"
    _log_separator

    # Remove the cloned file
    rm -f "$cloned_settings_file"
}

# ✅ Checks if all required tools are installed
# 💡 Usage: devkit-is-setup [--quiet]
function devkit-is-setup() {
    local settings_file="$DEVKIT_ROOT/.settings"

    local quiet=false
    if [[ "$1" == "--quiet" || "$1" == "-q" ]]; then
        quiet=true
    fi

    if [[ ! -f "$settings_file" ]]; then
        if [[ "$quiet" == false ]]; then
            _log_error "❌ Settings file not found at $settings_file"
            _log_hint "💡 Run: devkit-settings-setup"
        fi
        return 1
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
            _log_warning "⚠️  DevKit is not fully set up."
            _log_error "🚫 Missing tools: ${missing[*]}"
            _log_hint "👉 Run: devkit-pc-setup"
        fi
        return 1
    fi

    if [[ "$quiet" == false ]]; then
        _log_success "✅ DevKit is fully set up!"
        _log_separator
    fi

    return 0
}

# 🚀 Sets up full devkit environment (tools, SDKs, configs)
# 💡 Usage: devkit-pc-setup [--quiet]
function devkit-pc-setup() {

    local log_dir="$DEVKIT_ROOT/logs/devkit/setup"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    # {
    _confirm-or-abort "Are you sure you want to set up your devkit environment?" "$@" || return 1

    devkit-settings-setup || return 1

    _check-software-updates || return 1

    # 🔄 Setup Git configuration
    git-setup || return 1

    # Install Homebrew and packages
    homebrew-setup || return 1

    # Now its time to ask the user to configure his cask apps prior to going further
    _confirm-or-abort "🧩 Please take a moment to open and configure your downloaded apps (e.g. VS Code, Android Studio). Press Enter when you're ready to continue." "$@" || return 1

    # Install NPM and packages
    npm-setup || return 1

    # Install MAS (Mac App Store) and applications
    mas-setup || return 1

    # Install Xcode and Command Line Tools
    xcode-setup || return 1

    # Flutter Android Setup
    flutter-android-sdk-setup || return 1

    gum style --border normal --padding "1 2" --margin "1 0" --foreground 35 --bold "✅ devkit environment setup complete!"

    # } 2>&1 | tee -a "$log_file"

}

# 🔄 Updates devkit tools (Flutter, Homebrew, gcloud, NPM, etc.)
# 💡 Usage: devkit-pc-update
function devkit-pc-update() {
    local log_dir="$DEVKIT_ROOT/logs/devkit/update"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    # {
    _log-update-step 1 11 "Homebrew and Packages" homebrew-maintain || return 1
    _log-update-step 2 11 "pip (Python)" bash -c 'pip3 install --upgrade pip setuptools wheel' || return 1
    _log-update-step 3 11 "gcloud CLI" gcloud components update --quiet || return 1
    _log-update-step 4 11 "Flutter SDK" flutter upgrade --force || return 1
    _log-update-step 5 11 "NPM and Dependencies" bash -c 'npm install -g npm@latest; npm-check -g -u' || return 1
    _log-update-step 6 11 "CocoaPods" pod repo update || return 1
    _log-update-step 7 11 "Rosetta (Intel Compatibility)" softwareupdate --install-rosetta --agree-to-license || return 1
    _log-update-step 8 11 "VS Code Extensions" code-extensions-update || return 1
    _log-update-step 9 11 "App Store Apps (via mas-cli)" mas-maintain || return 1
    _log-update-step 10 11 "DevKit CLI" devkit-update || return 1
    _log-update-step 11 11 "System Updates" softwareupdate -ia --verbose || return 1

    # } 2>&1 | tee -a "$log_file"
}

# 📋 Checks installed versions of common tools
# 💡 Usage: devkit-check-tools
function devkit-check-tools() {
    _log_title "🔧 Development Environment Status:"

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
            echo "  $emoji  $padded_label $version"
        else
            _log_error "  $emoji  $padded_label Not installed"
            missing_tools+=("$name")
        fi
    }

    _log_section_title "💻 Shell & System Tools"
    print_version "🧩" "Devkit" "git" "git -C \$DEVKIT_ROOT describe --tags --abbrev=0 2>/dev/null"
    print_version "🧮" "Zsh" "zsh" "zsh --version | awk '{print \$2}'"
    print_version "🛠 " "Git" "git" "git --version | awk '{print \$3}'"
    print_version "🛍 " "MAS" "mas" "mas version"
    print_version "♻️ " "ccache" "ccache" "ccache --version | head -n 1 | awk '{print \$3}'"
    print_version "🧪" "Expect" "expect" "expect -v | awk '{print \$3}'"
    echo

    _log_section_title "🧰 Developer Tools & Editors"
    print_version "🖥 " "VS Code" "code" "code --version | head -n 1"
    print_version "🏗 " "Android Studio" "studio" "studio --version 2>/dev/null | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'"
    print_version "🧱" "Gradle" "gradle" "gradle --version | awk '/Gradle / {print \$2}'"
    echo

    _log_section_title "⚙️  Languages & Package Managers"
    print_version "☕" "Java" "java" "java -version 2>&1 | awk -F '\"' '/version/ {print \$2}'"
    print_version "🐍" "Python" "python3" "python3 --version | awk '{print \$2}'"
    print_version "📦" "Pip" "pip3" "pip3 --version | awk '{print \$2}'"
    print_version "🟢" "Node.js" "node" "node --version | sed 's/v//'"
    print_version "📦" "NPM" "npm" "npm --version"
    print_version "💎" "Ruby" "ruby" "ruby --version | awk '{print \$2}'"
    print_version "📦" "Gems" "gem" "gem --version"
    print_version "🎯" "Dart" "dart" "dart --version 2>&1 | awk '{print \$4}'"
    echo

    _log_section_title "📱 Mobile Dev Tools"
    print_version "🛠️ " "Xcode" "xcodebuild" "xcodebuild -version | head -n 1 | awk '{print \$2}'"
    print_version "🍎" "CocoaPods" "pod" "pod --version"
    print_version "💙" "Flutter" "flutter" "flutter --version 2>/dev/null | head -n 1 | awk '{print \$2}'"
    print_version "📱" "Android SDK" "sdkmanager" "sdkmanager --version"
    print_version "🔌" "Android Platform Tools" "adb" "adb version | head -n 1 | awk '{print \$5}'"
    echo

    _log_section_title "🚀  Cloud & Deployment"
    print_version "☁️ " "Google Cloud CLI" "gcloud" "gcloud --version | grep 'Google Cloud SDK' | awk '{print \$4}'"
    print_version "🔥" "Firebase CLI" "firebase" "firebase --version"
    print_version "🐳" "Docker" "docker" "docker --version | awk '{gsub(/,/,\"\"); print \$3}'"
    echo

    _log_section_title "🗄️  Databases"
    print_version "🐘" "PostgreSQL" "psql" "psql --version | awk '{print \$3}'"
    echo

    _log_section_title "🧩 Miscellaneous Tools"
    print_version "🖨 " "WeasyPrint" "weasyprint" "weasyprint --version | awk '{print \$3}'"
    echo

    _log_separator

    if ((${#missing_tools[@]} > 0)); then
        _log_warning "⚠️  Missing tools: ${missing_tools[*]}"
        _log_hint "👉 Run: devkit-pc-setup to install and configure required packages."
        _log_separator
        return 1
    else
        _log_success "✅ All essential tools are installed!"
        _log_separator
    fi
}

# 🧪 Full diagnostic on dev environment (gcloud, Xcode, Firebase, etc.)
# 💡 Usage: devkit-doctor
function devkit-doctor() {
    local log_dir="$DEVKIT_ROOT/logs/devkit/doctor"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    # {

    # Check for missing tools
    devkit-check-tools || return 1

    # Homebrew Checks
    homebrew-doctor || return 1

    # Xcode Checks
    xcode-doctor || return 1

    # Git Checks
    git-doctor || return 1

    # PostgreSQL Checks
    postgres-doctor || return 1

    # NPM Checks
    npm-doctor || return 1

    # Firebase Checks
    firebase-doctor || return 1

    # Shell
    _log_info "🔧 Checking default shell..."
    [[ "$SHELL" == *"zsh" ]] && _log_success "✅ Default shell is set to zsh" ||
        _log_warning "⚠️  Zsh is not your default shell. Set it with: chsh -s $(which zsh)"

    _log_separator

    # PATH Sanity
    _log_info "🔧 Checking if /usr/local/bin is included in PATH"
    echo "$PATH" | grep -q "/usr/local/bin" &&
        _log_success "✅ /usr/local/bin is in PATH" ||
        _log_warning "⚠️  /usr/local/bin is missing from PATH"

    _log_separator

    # } 2>&1 | tee -a "$log_file"
}

# 🚀 Checks and updates the devkit CLI from GitHub if a new version is available (based on tags)
# - Compares latest remote version tag vs local
# - Only pulls if out of date
# 💡 Usage: devkit-update
function devkit-update() {
    local repo_url="https://github.com/YDA93/devkit"

    _log_info "🔄 Checking for devkit updates..."

    if [[ ! -d "$DEVKIT_ROOT" ]]; then
        _log_info "📦 devkit not found. Cloning into $DEVKIT_ROOT..."
        git clone "$repo_url" "$DEVKIT_ROOT" || {
            _log_error "❌ Failed to clone devkit."
            return 1
        }
        _log_success "✅ devkit installed for the first time."
        _log_separator
        source "$DEVKIT_ROOT/bin/devkit.zsh"
        return 0
    fi

    # Fetch latest tags and branches
    _log_info "🔄 Fetching latest tags and branches from remote repository..."
    git -C "$DEVKIT_ROOT" fetch --tags --quiet || {
        _log_warning "⚠️  Failed to fetch tags from remote repository."
        _log_hint "💡 Please check your internet connection or try again later."
        _log_separator
        return 1
    }
    git -C "$DEVKIT_ROOT" fetch origin --prune --quiet || {
        _log_warning "⚠️  Failed to fetch branches from remote repository."
        _log_hint "💡 Please check your internet connection or try again later."
        _log_separator
        return 1
    }

    # Get latest local and remote version tags
    local local_version remote_version
    _log_info "🔍 Checking local and remote version tags..."
    # ✅ Current tag at HEAD, or "no-tag"
    local_version=$(git -C "$DEVKIT_ROOT" describe --tags --exact-match 2>/dev/null || echo "no-tag")
    remote_version=$(git -C "$DEVKIT_ROOT" ls-remote --tags --sort='v:refname' "$repo_url" | grep -o 'refs/tags/[^\^{}]*' | awk -F/ '{print $3}' | tail -n 1)

    if [[ -z "$remote_version" ]]; then
        _log_warning "⚠️  No remote version tags found."
        _log_separator
        return 1
    fi

    _log_info "🔖 Local version: $local_version"
    _log_info "🌐 Remote version: $remote_version"

    if [[ "$local_version" == "$remote_version" ]]; then
        _log_success "✅ devkit is already up to date (version: $local_version)"
        _log_separator
        return 0
    fi

    _log_info "📥 New version available!"
    _log_info "🔸 Current: $local_version"
    _log_info "🔹 Latest : $remote_version"
    _log_separator

    if ! gum confirm "👉 Do you want to update devkit to version $remote_version now?"; then
        _log_error "❌ Update canceled."
        _log_separator
        return 0
    fi

    _log_info "🚀 Updating devkit to version $remote_version..."

    # ✅ Check out main branch (or detect default branch dynamically)
    local default_branch
    default_branch=$(git -C "$DEVKIT_ROOT" remote show origin | grep 'HEAD branch' | awk '{print $NF}')

    git -C "$DEVKIT_ROOT" checkout "$default_branch" -f || {
        _log_error "❌ Failed to checkout branch $default_branch."
        _log_separator
        return 1
    }

    git -C "$DEVKIT_ROOT" pull origin "$default_branch" || {
        _log_error "❌ Failed to pull latest changes from $default_branch."
        _log_separator
        return 1
    }

    _log_success "✅ devkit updated to latest version on branch: $default_branch"
    _log_separator

    # Reload devkit if the script exists
    if [[ -f "$DEVKIT_ROOT/bin/devkit.zsh" ]]; then
        _log_info "🔁 Reloading devkit..."
        source "$DEVKIT_ROOT/bin/devkit.zsh"
        _log_success "✅ devkit reloaded."
        _log_separator
    fi
}

# 📦 Prints the current installed devkit version
# 💡 Usage: devkit-version
function devkit-version() {

    if [[ ! -d "$DEVKIT_ROOT" ]]; then
        _log_error "❌ devkit is not installed."
        return 1
    fi

    local current_version
    current_version=$(git -C "$DEVKIT_ROOT" describe --tags --abbrev=0 2>/dev/null)

    if [[ -z "$current_version" ]]; then
        _log_error "❌ No version tag found in devkit."
        return 1
    fi

    _log_info "📦 Current devkit version: $current_version"
    _log_separator
}
