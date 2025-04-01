# ------------------------------------------------------------------------------
# 🔥 Firebase CLI Diagnostics
# ------------------------------------------------------------------------------

# 🩺 Checks the Firebase CLI environment
# - Verifies Firebase CLI and Node.js are installed
# - Checks Firebase login status
# 💡 Usage: firebase-doctor
function firebase-doctor() {
    echo "🔥 Checking Firebase CLI..."

    if ! command -v firebase &>/dev/null; then
        echo "⚠️  Firebase CLI not found."
        echo "💡 Install it globally with: npm install -g firebase-tools"
        return 1
    fi

    # Check if Node.js is available (since Firebase CLI depends on it)
    if ! command -v node &>/dev/null; then
        echo "⚠️  Node.js is not installed or not in PATH."
        echo "💡 Firebase CLI requires Node.js to work properly."
        return 1
    fi

    echo "🔐 Checking Firebase login status..."
    if firebase login:list | grep -q "@"; then
        echo "✅ Logged into Firebase CLI"
    else
        echo "⚠️  Not logged in to Firebase"
        echo "💡 Run: firebase login"
    fi

    return 0
}
