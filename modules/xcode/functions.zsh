# 🛠️ Sets up Xcode, CLI tools, and related developer apps
function xcode_setup() {
    # Check for Xcode
    if ! command -v xcodebuild &>/dev/null; then
        echo "❌ Xcode not found. Please install it from the App Store manually or with mas:"
        echo "   mas install 497799835  # Xcode"
        return 1
    else
        echo "✅ Xcode is installed."
    fi

    # Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        echo "🔧 Installing Xcode Command Line Tools..."
        xcode-select --install
    else
        echo "✅ Xcode Command Line Tools are installed."
    fi

    # Accept license if needed
    if ! sudo xcodebuild -check-license &>/dev/null; then
        echo "📜 Accepting Xcode license..."
        sudo xcodebuild -license accept
    else
        echo "✅ Xcode license already accepted."
    fi

    # Run simulator first launch
    xcode_simulator_first_launch

    echo "🎉 Xcode setup completed."
}

# 🚀 Launch the iOS Simulator once to complete its first-run setup
function xcode_simulator_first_launch() {
    echo "📱 Launching iOS Simulator for initial setup..."
    open -a Simulator

    # Wait a few seconds for it to initialize
    sleep 5

    # Quit the Simulator (optional)
    osascript -e 'quit app "Simulator"'
    echo "✅ Simulator initialized."
}
