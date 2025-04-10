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

# 📋 Lists all Firebase projects in your account
# 💡 Usage: firebase-project-list
function firebase-project-list() {
    echo "🔍 Fetching Firebase projects..."
    firebase projects:list
}

# 🔄 Switches the active Firebase project
# 💡 Usage: firebase-use-project <project-id>
function firebase-use-project() {
    if [[ -z "$1" ]]; then
        echo "❌ Usage: firebase-use-project <project-id>"
        return 1
    fi

    firebase use "$1"
    echo "✅ Switched to Firebase project: $1"
}

# ------------------------------------------------------------------------------
# 🚀 Firebase Deployments
# ------------------------------------------------------------------------------

# 🚀 Deploys all configured Firebase services
# 💡 Usage: firebase-deploy-all
function firebase-deploy-all() {
    _confirm-or-abort "This will deploy all Firebase services (hosting, functions, etc.). Continue?" "$@" || return 1

    firebase deploy
    echo "✅ Firebase deployment complete."
}

# 🏡 Deploys Firebase hosting only
# 💡 Usage: firebase-deploy-hosting
function firebase-deploy-hosting() {
    _confirm-or-abort "Deploy Firebase hosting only?" "$@" || return 1

    firebase deploy --only hosting
    echo "✅ Firebase hosting deployed."
}

# ☁️ Deploys Firebase Cloud Functions only
# 💡 Usage: firebase-deploy-functions
function firebase-deploy-functions() {
    _confirm-or-abort "Deploy Firebase Cloud Functions only?" "$@" || return 1

    firebase deploy --only functions
    echo "✅ Firebase functions deployed."
}

# 📦 Deploys Firebase Storage rules only
# 💡 Usage: firebase-deploy-storage
function firebase-deploy-storage() {
    _confirm-or-abort "Deploy Firebase Storage rules only?" "$@" || return 1

    firebase deploy --only storage
    echo "✅ Firebase Storage rules deployed."
}

# 🔑 Deploys Firebase Firestore rules only
# 💡 Usage: firebase-deploy-firestore
function firebase-deploy-firestore() {
    _confirm-or-abort "Deploy Firebase Firestore rules only?" "$@" || return 1

    firebase deploy --only firestore:rules
    echo "✅ Firebase Firestore rules deployed."
}

# 🔑 Deploys Firebase Realtime Database rules only
# 💡 Usage: firebase-deploy-realtime
function firebase-deploy-realtime() {
    _confirm-or-abort "Deploy Firebase Realtime Database rules only?" "$@" || return 1

    firebase deploy --only database:rules
    echo "✅ Firebase Realtime Database rules deployed."
}

# 🔑 Deploys Firebase Authentication rules only
# 💡 Usage: firebase-deploy-auth
function firebase-deploy-auth() {
    _confirm-or-abort "Deploy Firebase Authentication rules only?" "$@" || return 1

    firebase deploy --only auth
    echo "✅ Firebase Authentication rules deployed."
}

# ------------------------------------------------------------------------------
# 🌐 Firebase Console & Logs
# ------------------------------------------------------------------------------

# 🌐 Opens Firebase console in the browser
# 💡 Usage: firebase-open-console
function firebase-open-console() {
    local project_id
    project_id=$(firebase projects:list --format json | jq -r '.[0].projectId')

    if [[ -z "$project_id" || "$project_id" == "null" ]]; then
        echo "❌ Could not determine default Firebase project."
        return 1
    fi

    local url="https://console.firebase.google.com/project/$project_id/overview"
    echo "🌐 Opening Firebase console: $url"
    open "$url"
}

# 📜 Tails Firebase Functions logs
# 💡 Usage: firebase-logs
function firebase-logs() {
    echo "📜 Tailing Firebase Functions logs..."
    firebase functions:log
}

# ------------------------------------------------------------------------------
# 🧩 Firebase Emulators
# ------------------------------------------------------------------------------

# 🧩 Starts Firebase emulators locally
# 💡 Usage: firebase-emulator-start
function firebase-emulator-start() {
    _confirm-or-abort "Start Firebase emulator suite locally?" "$@" || return 1

    firebase emulators:start
}

# 🧹 Clears Firebase emulator data
# 💡 Usage: firebase-clear-emulator-data
function firebase-clear-emulator-data() {
    _confirm-or-abort "This will clear all Firebase emulator data. Continue?" "$@" || return 1

    rm -rf ~/.firebase/emulatorhub
    echo "✅ Emulator data cleared."
}
