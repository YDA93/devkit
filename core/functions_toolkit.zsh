# ✅ Checks if all required tools are installed
# 💡 Usage: devkit-setup-check [--quiet]
function devkit-setup-check() {
    local settings_file="$DEVKIT_ROOT/settings.json"

    local quiet=false
    if [[ "$1" == "--quiet" || "$1" == "-q" ]]; then
        quiet=true
    fi

    if [[ ! -f "$settings_file" ]]; then
        if [[ "$quiet" == false ]]; then
            _log-error "✗ Settings file not found at $settings_file"
            _log-hint "💡 Run: devkit-settings-setup"
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
            _log-warning "⚠️  DevKit is not fully set up"
            _log-error "✗ Missing tools: ${missing[*]}"
            _log-hint "👉 Run: devkit-setup"
        fi
        return 1
    fi

    if [[ "$quiet" == false ]]; then
        _log-success "✓ DevKit is fully set up!"
        echo
    fi

    return 0
}

# 🚀 Checks and updates the devkit CLI from GitHub if a new version is available (based on tags)
# - Compares latest remote version tag vs local
# - Only pulls if out of date
# 💡 Usage: devkit-cli-update
function devkit-cli-update() {
    local repo_url="https://github.com/YDA93/devkit"

    _log-info "🔹 Checking for devkit updates..."

    if [[ ! -d "$DEVKIT_ROOT" ]]; then
        _log-info "🔹 devkit not found. Cloning into $DEVKIT_ROOT..."
        git clone "$repo_url" "$DEVKIT_ROOT" || {
            _log-error "✗ Failed to clone devkit"
            return 1
        }
        _log-success "✓ devkit installed for the first time"
        echo
        source "$DEVKIT_ROOT/bin/devkit.zsh"
        return 0
    fi

    # Fetch latest tags and branches
    _log-info "🔹 Fetching latest tags and branches from remote repository..."
    git -C "$DEVKIT_ROOT" fetch --tags --quiet || {
        _log-warning "⚠️  Failed to fetch tags from remote repository"
        _log-hint "💡 Please check your internet connection or try again later"
        echo
        return 1
    }
    git -C "$DEVKIT_ROOT" fetch origin --prune --quiet || {
        _log-warning "⚠️  Failed to fetch branches from remote repository"
        _log-hint "💡 Please check your internet connection or try again later"
        echo
        return 1
    }

    # Get latest local and remote version tags
    local local_version remote_version
    _log-info "🔹 Checking local and remote version tags..."
    # ✅ Current tag at HEAD, or "no-tag"
    local_version=$(git -C "$DEVKIT_ROOT" describe --tags --exact-match 2>/dev/null || echo "no-tag")
    remote_version=$(git -C "$DEVKIT_ROOT" ls-remote --tags --sort='v:refname' "$repo_url" | grep -o 'refs/tags/[^\^{}]*' | awk -F/ '{print $3}' | tail -n 1)

    if [[ -z "$remote_version" ]]; then
        _log-warning "⚠️  No remote version tags found"
        echo
        return 1
    fi

    _log-info-2 "🔸 Local version: $local_version"
    _log-info-2 "🔸 Remote version: $remote_version"

    if [[ "$local_version" == "$remote_version" ]]; then
        _log-success "✓ devkit is already up to date (version: $local_version)"
        echo
        return 0
    fi

    _log-info-2 "🔸 New version available!"
    _log-info-2 "🔸 Current: $local_version"
    _log-info-2 "🔸 Latest : $remote_version"
    echo

    if ! gum confirm "👉 Do you want to update devkit to version $remote_version now?"; then
        _log-error "✗ Update canceled"
        echo
        return 0
    fi

    _log-info "🔹 Updating devkit to version $remote_version..."

    # ✅ Check out main branch (or detect default branch dynamically)
    local default_branch
    default_branch=$(git -C "$DEVKIT_ROOT" remote show origin | grep 'HEAD branch' | awk '{print $NF}')

    git -C "$DEVKIT_ROOT" checkout "$default_branch" -f || {
        _log-error "✗ Failed to checkout branch $default_branch"
        echo
        return 1
    }

    git -C "$DEVKIT_ROOT" pull origin "$default_branch" || {
        _log-error "✗ Failed to pull latest changes from $default_branch"
        echo
        return 1
    }

    _log-success "✓ devkit updated to latest version on branch: $default_branch"
    echo

    # Reload devkit if the script exists
    if [[ -f "$DEVKIT_ROOT/bin/devkit.zsh" ]]; then
        _log-info "🔹 Reloading devkit..."
        source "$DEVKIT_ROOT/bin/devkit.zsh"
        _log-success "✓ devkit reloaded"
        echo
    fi
}

# 📦 Prints the current installed devkit version
# 💡 Usage: devkit-version
function devkit-version() {

    if [[ ! -d "$DEVKIT_ROOT" ]]; then
        _log-error "✗ devkit is not installed"
        return 1
    fi

    local current_version
    current_version=$(git -C "$DEVKIT_ROOT" describe --tags --abbrev=0 2>/dev/null)

    if [[ -z "$current_version" ]]; then
        _log-error "✗ No version tag found in devkit"
        return 1
    fi

    _log-info-2 "🔸 Current devkit version: $current_version"
    echo
}

# 📋 Checks installed versions of common tools
# 💡 Usage: devkit-tools-check
function devkit-tools-check() {
    _log-title "🔧 Development Environment Status:"

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
            _log-error "  $emoji  $padded_label Not installed"
            missing_tools+=("$name")
        fi
    }

    _log-section-title "💻 Shell & System Tools"
    print_version "🧩" "Devkit" "git" "git -C \$DEVKIT_ROOT describe --tags --abbrev=0 2>/dev/null"
    print_version "🧮" "Zsh" "zsh" "zsh --version | awk '{print \$2}'"
    print_version "🛠 " "Git" "git" "git --version | awk '{print \$3}'"
    print_version "🛍 " "MAS" "mas" "mas version"
    print_version "♻️ " "ccache" "ccache" "ccache --version | head -n 1 | awk '{print \$3}'"
    print_version "🧪" "Expect" "expect" "expect -v | awk '{print \$3}'"
    echo

    _log-section-title "🧰 Developer Tools & Editors"
    print_version "🖥 " "VS Code" "code" "code --version | head -n 1"
    print_version "🏗 " "Android Studio" "studio" "studio --version 2>/dev/null | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+'"
    print_version "🧱" "Gradle" "gradle" "gradle --version | awk '/Gradle / {print \$2}'"
    echo

    _log-section-title "⚙️  Languages & Package Managers"
    print_version "☕" "Java" "java" "java -version 2>&1 | awk -F '\"' '/version/ {print \$2}'"
    print_version "🐍" "Python" "python3" "python3 --version | awk '{print \$2}'"
    print_version "📦" "Pip" "pip3" "pip3 --version | awk '{print \$2}'"
    print_version "🟢" "Node.js" "node" "node --version | sed 's/v//'"
    print_version "📦" "NPM" "npm" "npm --version"
    print_version "💎" "Ruby" "ruby" "ruby --version | awk '{print \$2}'"
    print_version "📦" "Gems" "gem" "gem --version"
    print_version "🎯" "Dart" "dart" "dart --version 2>&1 | awk '{print \$4}'"
    echo

    _log-section-title "📱 Mobile Dev Tools"
    print_version "🛠️ " "Xcode" "xcodebuild" "xcodebuild -version | head -n 1 | awk '{print \$2}'"
    print_version "🍎" "CocoaPods" "pod" "pod --version"
    print_version "💙" "Flutter" "flutter" "flutter --version 2>/dev/null | head -n 1 | awk '{print \$2}'"
    print_version "📱" "Android SDK" "sdkmanager" "sdkmanager --version"
    print_version "🔌" "Android Platform Tools" "adb" "adb version | head -n 1 | awk '{print \$5}'"
    echo

    _log-section-title "🚀  Cloud & Deployment"
    print_version "☁️ " "Google Cloud CLI" "gcloud" "gcloud --version | grep 'Google Cloud SDK' | awk '{print \$4}'"
    print_version "🔥" "Firebase CLI" "firebase" "firebase --version"
    print_version "🐳" "Docker" "docker" "docker --version | awk '{gsub(/,/,\"\"); print \$3}'"
    echo

    _log-section-title "🗄️  Databases"
    print_version "🐘" "PostgreSQL" "psql" "psql --version | awk '{print \$3}'"
    echo

    _log-section-title "🧩 Miscellaneous Tools"
    print_version "🖨 " "WeasyPrint" "weasyprint" "weasyprint --version | awk '{print \$3}'"
    echo

    echo

    if ((${#missing_tools[@]} > 0)); then
        _log-warning "⚠️  Missing tools: ${missing_tools[*]}"
        _log-hint "👉 Run: devkit-setup to install and configure required packages"
        echo
        return 1
    else
        _log-success "✓ All essential tools are installed!"
        echo
    fi
}

# 🔄 Checks for and installs macOS updates
# 💡 Usage: devkit-macos-update
function devkit-macos-update() {
    # 🛠️ Installs all available macOS software updates (system + security)
    _log-info "🔹 Checking for macOS software updates..."

    # Check for available software updates
    available_updates=$(softwareupdate -l 2>&1)

    if echo "$available_updates" | grep -q "No new software available"; then
        _log-success "✓ No updates available"
        echo
        return 0
    else
        _log-info "🔹 Updates available. Installing now..."
        softwareupdate -ia --verbose
        _log-success "✓ Updates installed successfully"
        _log-info-2 "🔸 A system restart may be required to complete installation"
        _log-warning "⚠️  Please reboot your Mac and then re-run: devkit-setup"
        echo
        return 1 # Signal that a reboot is needed
    fi
}
