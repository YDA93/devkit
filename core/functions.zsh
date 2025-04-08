# ------------------------------------------------------------------------------
# 🧰 DevKit Support Utilities
# ------------------------------------------------------------------------------

# 🧰 Initializes your CLI by asking user for name, email, and per-app install choices
# - Stores results in ~/devkit/.settings
# 💡 Usage: devkit-settings-setup
function devkit-settings-setup() {
    local settings_file="$DEVKIT_ROOT/.settings"
    mkdir -p "$(dirname "$settings_file")"

    # Check if settings file exists
    if [[ -f "$settings_file" ]]; then
        echo "⚙️  Settings file already exists at $settings_file."
        while true; do
            echo -n "♻️  Do you want to reset the settings setup? [y/n]: "
            read reset_choice
            reset_choice="${reset_choice:l}"
            if [[ "$reset_choice" == "n" ]]; then
                echo "🚪 Exiting settings setup without changes."
                return
            elif [[ "$reset_choice" == "y" ]]; then
                echo "🔄 Resetting settings setup..."
                break
            else
                echo "⚠️  Please type y or n"
            fi
        done
    fi

    echo "👋 Welcome! Let's set up devkit CLI environment."

    # Zsh-compatible prompts
    echo -n "👤 Full name: "
    read full_name

    echo -n "📧 Email address: "
    read email

    echo ""
    echo "🛠️  We'll now ask which apps you'd like to install (one by one). Please type y or n."

    local mas_apps=(
        "1450874784|Transporter"
        "899247664|TestFlight"
        "1287239339|ColorSlurp"
        "409183694|Keynote"
        "409201541|Pages"
        "409203825|Numbers"
    )

    local cask_apps=(
        cloudflare-warp firefox onedrive whatsapp zoom
        microsoft-auto-update microsoft-edge microsoft-excel
        microsoft-outlook microsoft-powerpoint microsoft-teams
        microsoft-word
    )

    local formula_apps=(
        weasyprint
    )

    echo "full_name=\"$full_name\"" >"$settings_file"
    echo "email=\"$email\"" >>"$settings_file"

    echo "" >>"$settings_file"
    echo "# mas apps" >>"$settings_file"
    for app in "${mas_apps[@]}"; do
        IFS='|' read -r app_id app_name <<<"$app"

        while true; do
            echo -n "🛍️  Install $app_name (App Store)? [y/n]: "
            read choice
            choice="${choice:l}"
            [[ "$choice" == "y" || "$choice" == "n" ]] && break
            echo "⚠️  Please type y or n"
        done

        echo "mas_install_$app_id=\"$choice\"" >>"$settings_file"
    done

    echo "" >>"$settings_file"
    echo "# cask apps" >>"$settings_file"
    for app in "${cask_apps[@]}"; do
        safe_app_var=${app//-/_}

        while true; do
            echo -n "📦 Install $app (Homebrew Cask)? [y/n]: "
            read choice
            choice="${choice:l}"
            [[ "$choice" == "y" || "$choice" == "n" ]] && break
            echo "⚠️  Please type y or n"
        done

        echo "cask_install_${safe_app_var}=\"$choice\"" >>"$settings_file"
    done

    echo "" >>"$settings_file"
    echo "# formula apps" >>"$settings_file"
    for app in "${formula_apps[@]}"; do
        while true; do
            echo -n "🔧 Install $app (Homebrew Formula)? [y/n]: "
            read choice
            choice="${choice:l}"
            [[ "$choice" == "y" || "$choice" == "n" ]] && break
            echo "⚠️  Please type y or n"
        done

        echo "formula_install_$app=\"$choice\"" >>"$settings_file"
    done

    echo ""
    echo "✅ Settings saved to $settings_file"
}

# ✅ Checks if all required tools are installed
# 💡 Usage: devkit-is-setup [--quiet]
function devkit-is-setup() {
    local settings_file="$DEVKIT_ROOT/.settings"

    if [[ ! -f "$settings_file" ]]; then
        echo "❌ Settings file not found at $settings_file"
        echo "💡 Run: devkit-settings-setup"
        return 1
    fi

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

# 🚀 Sets up full devkit environment (tools, SDKs, configs)
# 💡 Usage: devkit-pc-setup [--quiet]
function devkit-pc-setup() {

    local log_dir="$DEVKIT_ROOT/logs/devkit/setup"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    {
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

        echo "--------------------------------------------------"
        echo "✅ devkit environment setup complete!"
        echo "--------------------------------------------------"

    } 2>&1 | tee -a "$log_file"

}

# 🔄 Updates devkit tools (Flutter, Homebrew, gcloud, NPM, etc.)
# 💡 Usage: devkit-pc-update
function devkit-pc-update() {
    local log_dir="$DEVKIT_ROOT/logs/devkit/update"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    {
        # --- Brew ---
        _log-update-step "Homebrew and Packages" "homebrew-maintain" || return 1

        # --- Pip (Python) ---
        _log-update-step "pip (Python)" bash -c '
        pip3 install --upgrade pip setuptools wheel
        ' || return 1

        # --- gcloud ---
        _log-update-step "gcloud CLI" gcloud components update --quiet || return 1

        # --- Flutter ---
        _log-update-step "Flutter SDK" flutter upgrade --force || return 1

        # --- NPM ---
        _log-update-step "NPM and Dependencies" bash -c '
        npm install -g npm@latest
        npm-check -g -u
        ' || return 1

        # --- CocoaPods ---
        _log-update-step "CocoaPods" pod repo update || return 1

        # --- Rosetta ---
        _log-update-step "Rosetta (Intel Compatibility)" softwareupdate --install-rosetta --agree-to-license || return 1

        # --- App Store Apps ---
        _log-update-step "App Store Apps (via mas-cli)" mas-maintain || return 1

        # --- Devkit ---
        _log-update-step "DevKit CLI" devkit-update || return 1

        # --- Software ---
        _log-update-step "System Updates" softwareupdate -ia --verbose || return 1

    } 2>&1 | tee -a "$log_file"
}

# 📋 Checks installed versions of common tools
# 💡 Usage: devkit-check-tools
function devkit-check-tools() {
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
            echo "  $emoji  $padded_label $version"
        else
            echo "  $emoji  $padded_label Not installed"
            missing_tools+=("$name")
        fi
    }

    _print_section_title "💻 Shell & System Tools"
    print_version "🧩" "Devkit" "git" "git -C \$DEVKIT_ROOT describe --tags --abbrev=0 2>/dev/null"
    print_version "🧮" "Zsh" "zsh" "zsh --version | awk '{print \$2}'"
    print_version "🛠 " "Git" "git" "git --version | awk '{print \$3}'"
    print_version "🛍 " "MAS" "mas" "mas version"
    print_version "♻️ " "ccache" "ccache" "ccache --version | head -n 1 | awk '{print \$3}'"
    print_version "🧪" "Expect" "expect" "expect -v | awk '{print \$3}'"
    echo

    _print_section_title "🧰 Developer Tools & Editors"
    print_version "🖥 " "VS Code" "code" "code --version | head -n 1"
    print_version "🏗 " "Android Studio" "studio" "studio --version 2>/dev/null | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'"
    print_version "🧱" "Gradle" "gradle" "gradle --version | awk '/Gradle / {print \$2}'"
    echo

    _print_section_title "⚙️  Languages & Package Managers"
    print_version "☕" "Java" "java" "java -version 2>&1 | awk -F '\"' '/version/ {print \$2}'"
    print_version "🐍" "Python" "python3" "python3 --version | awk '{print \$2}'"
    print_version "📦" "Pip" "pip3" "pip3 --version | awk '{print \$2}'"
    print_version "🟢" "Node.js" "node" "node --version | sed 's/v//'"
    print_version "📦" "NPM" "npm" "npm --version"
    print_version "💎" "Ruby" "ruby" "ruby --version | awk '{print \$2}'"
    print_version "📦" "Gems" "gem" "gem --version"
    print_version "🎯" "Dart" "dart" "dart --version 2>&1 | awk '{print \$4}'"
    echo

    _print_section_title "📱 Mobile Dev Tools"
    print_version "🛠️ " "Xcode" "xcodebuild" "xcodebuild -version | head -n 1 | awk '{print \$2}'"
    print_version "🍎" "CocoaPods" "pod" "pod --version"
    print_version "💙" "Flutter" "flutter" "flutter --version 2>/dev/null | head -n 1 | awk '{print \$2}'"
    print_version "📱" "Android SDK" "sdkmanager" "sdkmanager --version"
    print_version "🔌" "Android Platform Tools" "adb" "adb version | head -n 1 | awk '{print \$5}'"
    echo

    _print_section_title "🚀  Cloud & Deployment"
    print_version "☁️ " "Google Cloud CLI" "gcloud" "gcloud --version | grep 'Google Cloud SDK' | awk '{print \$4}'"
    print_version "🔥" "Firebase CLI" "firebase" "firebase --version"
    print_version "🐳" "Docker" "docker" "docker --version | awk '{gsub(/,/,\"\"); print \$3}'"
    echo

    _print_section_title "🗄️  Databases"
    print_version "🐘" "PostgreSQL" "psql" "psql --version | awk '{print \$3}'"
    echo

    _print_section_title "🧩 Miscellaneous Tools"
    printf "  🚀  %-24s %s\n" "Devkit CLI:" "$devkit_version"
    print_version "🖨 " "WeasyPrint" "weasyprint" "weasyprint --version | awk '{print \$3}'"
    echo

    echo "────────────────────────────────────"

    if ((${#missing_tools[@]} > 0)); then
        echo "⚠️  Missing tools: ${missing_tools[*]}"
        echo "👉 Run: devkit-pc-setup to install and configure required packages."
        return 1
    else
        echo "✅ All essential tools are installed!"
    fi
}

# 🧪 Full diagnostic on dev environment (gcloud, Xcode, Firebase, etc.)
# 💡 Usage: devkit-doctor
function devkit-doctor() {
    local log_dir="$DEVKIT_ROOT/logs/devkit/doctor"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    {
        echo "🔍 Running devkit doctor..."
        echo "────────────────────────────────────"

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
        echo "🔧 Checking default shell..."
        [[ "$SHELL" == *"zsh" ]] && echo "✅ Default shell is zsh" ||
            echo "⚠️  Zsh is not your default shell. Set it with: chsh -s $(which zsh)"

        # PATH Sanity
        echo "🔧 Checking PATH..."
        echo "$PATH" | grep -q "/usr/local/bin" &&
            echo "✅ /usr/local/bin is in PATH" ||
            echo "⚠️  /usr/local/bin is missing from PATH"

        echo "✅ All checks completed!"
        echo "🔧 Your devkit environment is ready!"
        echo "────────────────────────────────────"

    } 2>&1 | tee -a "$log_file"
}

# 🚀 Checks and updates the devkit CLI from GitHub if a new version is available (based on tags)
# - Compares latest remote version tag vs local
# - Only pulls if out of date
# 💡 Usage: devkit-update
function devkit-update() {
    local repo_url="https://github.com/YDA93/devkit"

    echo "🔄 Checking for devkit updates..."

    if [[ ! -d "$DEVKIT_ROOT" ]]; then
        echo "📦 devkit not found. Cloning into $DEVKIT_ROOT..."
        git clone "$repo_url" "$DEVKIT_ROOT" || {
            echo "❌ Failed to clone devkit."
            return 1
        }
        echo "✅ devkit installed for the first time."
        source "$DEVKIT_ROOT/bin/devkit.zsh"
        return 0
    fi

    # Fetch latest tags
    git -C "$target_dir" fetch --tags --quiet || {
        echo "⚠️  Failed to fetch tags from remote repository."
        echo "💡 Please check your internet connection or try again later."
        return 1
    }

    # Get latest local and remote version tags
    local local_version remote_version

    local_version=$(git -C "$target_dir" tag --sort=-v:refname | head -n 1)
    remote_version=$(git -C "$target_dir" ls-remote --tags --sort='v:refname' "$repo_url" | grep -o 'refs/tags/[^\^{}]*' | awk -F/ '{print $3}' | tail -n 1)

    # Handle case where no tags exist
    if [[ -z "$remote_version" ]]; then
        echo "⚠️  No remote version tags found."
        return 1
    fi

    if [[ -z "$local_version" ]]; then
        echo "ℹ️  No local version found. You might be on initial clone."
        local_version="none"
    fi

    echo "🔖 Local version: $local_version"
    echo "🌐 Remote version: $remote_version"

    if [[ "$local_version" == "$remote_version" ]]; then
        echo "✅ devkit is already up to date (version: $local_version)"
        return 0
    fi

    echo "📥 New version available!"
    echo "🔸 Current: $local_version"
    echo "🔹 Latest : $remote_version"

    echo -n "👉 Do you want to update devkit to version $remote_version now? (y/n): "
    read -r confirm
    if [[ "$confirm" != [Yy] ]]; then
        echo "❌ Update canceled."
        return 0
    fi

    echo "🚀 Updating devkit to version $remote_version..."

    if ! git -C "$target_dir" checkout "tags/$remote_version" -f; then
        echo "❌ Failed to checkout version $remote_version."
        return 1
    fi

    if [[ -f "$target_dir/bin/devkit.zsh" ]]; then
        echo "🔁 Reloading devkit..."
        source "$target_dir/bin/devkit.zsh"
        echo "✅ devkit updated and reloaded to version $remote_version."
    fi
}

# 📦 Prints the current installed devkit version
# 💡 Usage: devkit-version
function devkit-version() {

    if [[ ! -d "$DEVKIT_ROOT" ]]; then
        echo "❌ devkit is not installed."
        return 1
    fi

    local current_version
    current_version=$(git -C "$DEVKIT_ROOT" describe --tags --abbrev=0 2>/dev/null)

    if [[ -z "$current_version" ]]; then
        echo "❌ No version tag found in devkit."
        return 1
    fi

    echo "📦 Current devkit version: $current_version"
}
