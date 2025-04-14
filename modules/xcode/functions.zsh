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

    # 🛠️ Installs all available macOS software updates (system + security)
    _check-software-updates || return 1

    # 🔁 Installs Rosetta for Apple Silicon (to run Intel-based apps/tools)
    _log_info "🔁 Checking for Rosetta installation..."
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        _log_success "✓ Rosetta is already installed."
    else
        _log_info "🔁 Installing Rosetta..."
        softwareupdate --install-rosetta --agree-to-license || return 1
        _log_success "✓ Rosetta installed successfully."
    fi
    echo

    # 📜 Accept Xcode license, must be before updating CocoaPods
    _log_info "📜 Accepting Xcode license..."
    sudo xcodebuild -license accept || return 1
    _log_success "✓ Xcode license accepted."
    echo

    # 🍎 Updates CocoaPods master specs repo (used for dependency resolution)
    if command -v pod >/dev/null 2>&1; then
        _log_info "📦 Updating CocoaPods specs..."
        pod repo update || return 1
        _log_success "✓ CocoaPods specs updated."
        echo
    else
        _log_warning "⚠️ CocoaPods not found. Skipping pod repo update."
    fi

    # 🔍 Check for Xcode installation
    _log_info "🔍 Checking for Xcode installation..."
    if ! command -v xcodebuild &>/dev/null; then
        _log_error "✗ Xcode not found. Please install it from the App Store manually or using mas:"
        _log_error "   mas install 497799835  # Xcode"
        return 1
    else
        _log_success "✓ Xcode is installed."
        echo
    fi

    # 🔍 Check for Xcode Command Line Tools
    _log_info "🔍 Checking for Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        _log_info "🔧 Installing Xcode Command Line Tools..."
        xcode-select --install || return 1
        _log_success "✓ Xcode Command Line Tools installed successfully."
    else
        _log_success "✓ Xcode Command Line Tools are installed."
    fi
    echo

    # 🧪 Run simulator first launch (if function exists)
    if typeset -f xcode-simulator-first-launch >/dev/null; then
        xcode-simulator-first-launch || return 1
    fi

}

# 📱 Launches iOS Simulator to complete first-run setup
# - Runs `xcode-select` and `xcodebuild -runFirstLaunch`
# - Optionally pre-downloads iOS platform support
# 💡 Usage: xcode-simulator-first-launch
function xcode-simulator-first-launch() {
    # Set Xcode path (only if needed)
    _log_info "🔧 Setting Xcode path..."
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer || return 1
    _log_success "✓ Xcode path set to /Applications/Xcode.app/Contents/Developer."
    echo

    # Run Xcode's first launch tasks (installs tools, accepts licenses)
    _log_info "🔧 Running Xcode first launch tasks..."
    sudo xcodebuild -runFirstLaunch || return 1
    _log_success "✓ Xcode first launch tasks completed."
    echo

    # Pre-download the iOS platform support (optional but nice)
    _log_info "📦 Pre-downloading iOS platform support..."
    xcodebuild -downloadPlatform iOS || return 1
    _log_success "✓ iOS platform support pre-downloaded."
    echo

}

# 🩺 Verifies Xcode setup and tools
# - Checks for `xcode-select`, `xcrun`, iOS simulators, and Rosetta (if Apple Silicon)
# 💡 Usage: xcode-doctor
function xcode-doctor() {

    _log_info "🔧 Checking Xcode installation..."
    if ! xcode-select -p &>/dev/null; then
        _log_warning "⚠️  Xcode not properly installed or selected."
        _log_hint "💡 Try: xcode-select --install"
        return 1
    fi
    _log_success "✓ Xcode is properly installed."
    echo

    _log_info "🔧 Checking Xcode Command Line Tools..."
    if ! command -v xcrun &>/dev/null; then
        _log_warning "⚠️  'xcrun' not found. Xcode CLI tools may not be fully installed."
        return 1
    fi
    _log_success "✓ 'xcrun' found."
    echo

    _log_info "📱 Checking iOS simulators..."
    if xcrun simctl list devices available | grep -qE "iPhone|iPad"; then
        _log_success "✓ iOS simulators are available."
    else
        _log_warning "⚠️  No available iOS simulators found."
        _log_hint "💡 Open Xcode ➝ Preferences ➝ Components to install simulators."
    fi
    echo

    _log_info "🔧 Checking Rosetta installation..."
    if [[ $(uname -m) == "arm64" ]]; then
        if ! /usr/bin/pgrep oahd &>/dev/null; then
            _log_warning "⚠️  Rosetta is not installed."
            _log_hint "💡 Run: softwareupdate --install-rosetta --agree-to-license"
            echo
            return 1
        else
            _log_success "✓ Rosetta is installed."
            echo
        fi
    fi

    return 0
}
