# 🛠️ Sets up Xcode, CLI tools, and related developer apps
function xcode-setup() {
    echo "🚀 Starting Xcode setup..."

    # 🛠️ Installs all available macOS software updates (system + security)
    echo "📦 Running software updates..."
    _check-software-updates || return 1

    # 🔁 Installs Rosetta for Apple Silicon (to run Intel-based apps/tools)
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        echo "✅ Rosetta is already installed."
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
        echo "⚠️ CocoaPods not found. Skipping pod repo update."
    fi

    # 🔍 Check for Xcode installation
    if ! command -v xcodebuild &>/dev/null; then
        echo "❌ Xcode not found. Please install it from the App Store manually or using mas:"
        echo "   mas install 497799835  # Xcode"
        return 1
    else
        echo "✅ Xcode is installed."
    fi

    # 🔍 Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        echo "🔧 Installing Xcode Command Line Tools..."
        xcode-select --install || return 1
    else
        echo "✅ Xcode Command Line Tools are installed."
    fi

    # 🧪 Run simulator first launch (if function exists)
    if typeset -f xcode-simulator-first-launch >/dev/null; then
        xcode-simulator-first-launch || return 1
    fi

    echo "🎉 Xcode setup completed successfully."
}

# 🚀 Launch the iOS Simulator once to complete its first-run setup
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

    echo "✅ Xcode and Simulator first-launch setup complete."
}

function xcode-doctor() {
    # Xcode Checks
    echo "🔧 Checking Xcode..."
    xcode-select -p >/dev/null || {
        echo "⚠️  Xcode not properly installed or selected."
        return 1
    }

    # iOS Simulators
    if command -v xcrun &>/dev/null; then
        echo "📱 Checking iOS simulators..."
        xcrun simctl list devices available | grep -qE "iPhone|iPad" &&
            echo "✅ iOS simulators are available" ||
            echo "⚠️  No available iOS simulators found. You may need to install them via Xcode."
    fi

    # Rosetta
    echo "🔧 Checking Rosetta installation..."
    if [[ $(uname -m) == "arm64" && ! $(command -v otool) ]]; then
        echo "⚠️  Rosetta is not installed. Please install it: softwareupdate --install-rosetta"
        return 1
    fi
}
