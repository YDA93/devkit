# ------------------------------------------------------------------------------
# 🍎 Xcode & macOS Developer Tools
# ------------------------------------------------------------------------------

# 🛠️ Sets up Xcode, CLI tools, CocoaPods, and Rosetta (if needed)
# - Installs macOS software updates
# - Accepts Xcode license
# - Installs Rosetta for Apple Silicon
# - Updates CocoaPods specs (if installed)
# - Ensures Xcode and CLI tools are installed
# 💡 Usage: xcode-setup
function xcode-setup() {
    echo "🚀 Starting Xcode setup..."

    # 🛠️ Installs all available macOS software updates (system + security)
    echo "📦 Running software updates..."
    _check-software-updates || return 1

    # 🔁 Installs Rosetta for Apple Silicon (to run Intel-based apps/tools)
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        _log_success "✅ Rosetta is already installed."
    else
        echo "🔁 Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license || return 1
    fi

    # 📜 Accept Xcode license, must be before updating CocoaPods
    echo "📜 Accepting Xcode license..."
    sudo xcodebuild -license accept || return 1

    # 🍎 Updates CocoaPods master specs repo (used for dependency resolution)
    if command -v pod >/dev/null 2>&1; then
        echo "📦 Updating CocoaPods specs..."
        pod repo update || return 1
    else
        _log_warning "⚠️ CocoaPods not found. Skipping pod repo update."
    fi

    # 🔍 Check for Xcode installation
    if ! command -v xcodebuild &>/dev/null; then
        _log_error "❌ Xcode not found. Please install it from the App Store manually or using mas:"
        echo "   mas install 497799835  # Xcode"
        return 1
    else
        _log_success "✅ Xcode is installed."
    fi

    # 🔍 Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        echo "🔧 Installing Xcode Command Line Tools..."
        xcode-select --install || return 1
    else
        _log_success "✅ Xcode Command Line Tools are installed."
    fi

    # 🧪 Run simulator first launch (if function exists)
    if typeset -f xcode-simulator-first-launch >/dev/null; then
        xcode-simulator-first-launch || return 1
    fi

    echo "🎉 Xcode setup completed successfully."
}

# 📱 Launches iOS Simulator to complete first-run setup
# - Runs `xcode-select` and `xcodebuild -runFirstLaunch`
# - Optionally pre-downloads iOS platform support
# 💡 Usage: xcode-simulator-first-launch
function xcode-simulator-first-launch() {
    echo "📱 Launching iOS Simulator for initial setup..."

    # Set Xcode path (only if needed)
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer || return 1

    # Run Xcode's first launch tasks (installs tools, accepts licenses)
    echo "🔧 Running Xcode first launch tasks..."
    sudo xcodebuild -runFirstLaunch || return 1

    # Pre-download the iOS platform support (optional but nice)
    echo "📦 Pre-downloading iOS platform support..."
    xcodebuild -downloadPlatform iOS || return 1

    _log_success "✅ Xcode and Simulator first-launch setup complete."
}

# 🩺 Verifies Xcode setup and tools
# - Checks for `xcode-select`, `xcrun`, iOS simulators, and Rosetta (if Apple Silicon)
# 💡 Usage: xcode-doctor
function xcode-doctor() {
    echo "🔧 Checking Xcode..."

    if ! xcode-select -p &>/dev/null; then
        _log_warning "⚠️  Xcode not properly installed or selected."
        _log_hint "💡 Try: xcode-select --install"
        return 1
    fi

    if ! command -v xcrun &>/dev/null; then
        _log_warning "⚠️  'xcrun' not found. Xcode CLI tools may not be fully installed."
        return 1
    fi

    echo "📱 Checking iOS simulators..."
    if xcrun simctl list devices available | grep -qE "iPhone|iPad"; then
        _log_success "✅ iOS simulators are available."
    else
        _log_warning "⚠️  No available iOS simulators found."
        _log_hint "💡 Open Xcode ➝ Preferences ➝ Components to install simulators."
    fi

    echo "🔧 Checking Rosetta installation..."
    if [[ $(uname -m) == "arm64" ]]; then
        if ! /usr/bin/pgrep oahd &>/dev/null; then
            _log_warning "⚠️  Rosetta is not installed."
            _log_hint "💡 Run: softwareupdate --install-rosetta --agree-to-license"
            return 1
        else
            _log_success "✅ Rosetta is installed."
        fi
    fi

    return 0
}
