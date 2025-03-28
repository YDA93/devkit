# 🛠️ Sets up Xcode, CLI tools, and related developer apps
function xcode_setup() {
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
    if typeset -f xcode_simulator_first_launch >/dev/null; then
        xcode_simulator_first_launch || return 1
    fi

    echo "🎉 Xcode setup completed successfully."
}

# 🚀 Launch the iOS Simulator once to complete its first-run setup
function xcode_simulator_first_launch() {
    echo "📱 Launching iOS Simulator for initial setup..."

    # Set Xcode path (only if needed)
    sudo xcode-select -s /Applications/Xcode.app/Contents/Developer || return 1

    # Run Xcode's first launch tasks (installs tools, accepts licenses)
    echo "🔧 Running Xcode first launch tasks..."
    sudo xcodebuild -runFirstLaunch || return 1

    # 📜 Accept Xcode license
    echo "📜 Accepting Xcode license..."
    sudo xcodebuild -license accept || return 1

    # Pre-download the iOS platform support (optional but nice)
    echo "📦 Pre-downloading iOS platform support..."
    xcodebuild -downloadPlatform iOS || return 1

    echo "✅ Xcode and Simulator first-launch setup complete."
}
