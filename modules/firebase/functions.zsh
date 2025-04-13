# ------------------------------------------------------------------------------
# 🔥 Firebase CLI Diagnostics
# ------------------------------------------------------------------------------

# 🩺 Checks the Firebase CLI environment
# - Verifies Firebase CLI and Node.js are installed
# - Checks Firebase login status
# 💡 Usage: firebase-doctor
function firebase-doctor() {
    _log_info "🔥 Checking Firebase CLI installation..."

    if ! command -v firebase &>/dev/null; then
        _log_warning "⚠️  Firebase CLI not found."
        _log_hint "💡 Install it globally with: npm install -g firebase-tools"
        _log_separator
        return 1
    fi
    _log_success "✅ Firebase CLI is installed"
    _log_separator

    # Check if Node.js is available (since Firebase CLI depends on it)
    _log_info "🔍 Checking Node.js installation..."
    if ! command -v node &>/dev/null; then
        _log_warning "⚠️  Node.js is not installed or not in PATH."
        _log_hint "💡 Firebase CLI requires Node.js to work properly."
        _log_separator
        return 1
    fi
    _log_success "✅ Node.js is installed"
    _log_separator

    _log_info "🔐 Checking Firebase login status..."
    if firebase login:list | grep -q "@"; then
        _log_success "✅ Logged into Firebase CLI"
        _log_separator
    else
        _log_warning "⚠️  Not logged in to Firebase"
        _log_hint "💡 Run: firebase login"
        _log_separator
    fi

    return 0
}

# 📋 Lists all Firebase projects in your account
# 💡 Usage: firebase-project-list
function firebase-project-list() {
    _log_info "🔍 Fetching Firebase projects..."
    firebase projects:list
}

# 🔄 Switches the active Firebase project
# 💡 Usage: firebase-use-project <project-id>
function firebase-use-project() {
    if [[ -z "$1" ]]; then
        _log_error "❌ Usage: firebase-use-project <project-id>"
        return 1
    fi
    _log_info "🔄 Switching to Firebase project: $1"

    firebase use "$1"
    _log_success "✅ Switched to Firebase project: $1"
    _log_separator
}

# 🔐 Check Firebase CLI full authentication (account + valid token)
# 💡 Usage: firebase-login-check
function firebase-login-check() {
    _log_info "🔍 Checking Firebase CLI authentication..."

    # First, check if an account is configured
    local ACCOUNT=$(firebase login:list 2>/dev/null | grep -Eo "[[:alnum:]_.+-]+@[[:alnum:]_.+-]+")

    if [[ -z "$ACCOUNT" ]]; then
        _log_error "❌ No Firebase account configured. Run: firebase login"
        return 1
    fi

    _log_success "✅ Firebase account detected: $ACCOUNT"

    # Second, test token validity with a safe command
    if firebase projects:list >/dev/null 2>&1; then
        _log_success "✅ Firebase token is valid."
        _log_separator
    else
        _log_warning "⚠️ Firebase token expired or invalid."
        _log_hint "➡️ Run: firebase login --reauth"
        _log_separator
        return 1
    fi
}

# ------------------------------------------------------------------------------
# 🚀 Firebase Deployments
# ------------------------------------------------------------------------------

# 🚀 Deploys all configured Firebase services
# 💡 Usage: firebase-deploy-all
function firebase-deploy-all() {
    _confirm-or-abort "This will deploy all Firebase services (hosting, functions, etc.). Continue?" "$@" || return 1

    firebase deploy
    _log_success "✅ Firebase deployment complete."
    _log_separator
}

# 🏡 Deploys Firebase hosting only
# 💡 Usage: firebase-deploy-hosting
function firebase-deploy-hosting() {
    _confirm-or-abort "Deploy Firebase hosting only?" "$@" || return 1

    firebase deploy --only hosting
    _log_success "✅ Firebase hosting deployed."
    _log_separator
}

# ☁️ Deploys Firebase Cloud Functions only
# 💡 Usage: firebase-deploy-functions
function firebase-deploy-functions() {
    _confirm-or-abort "Deploy Firebase Cloud Functions only?" "$@" || return 1

    firebase deploy --only functions
    _log_success "✅ Firebase functions deployed."
    _log_separator
}

# 📦 Deploys Firebase Storage rules only
# 💡 Usage: firebase-deploy-storage
function firebase-deploy-storage() {
    _confirm-or-abort "Deploy Firebase Storage rules only?" "$@" || return 1

    firebase deploy --only storage
    _log_success "✅ Firebase Storage rules deployed."
    _log_separator
}

# 🔑 Deploys Firebase Firestore rules only
# 💡 Usage: firebase-deploy-firestore
function firebase-deploy-firestore() {
    _confirm-or-abort "Deploy Firebase Firestore rules only?" "$@" || return 1

    firebase deploy --only firestore:rules
    _log_success "✅ Firebase Firestore rules deployed."
    _log_separator
}

# 🔑 Deploys Firebase Realtime Database rules only
# 💡 Usage: firebase-deploy-realtime
function firebase-deploy-realtime() {
    _confirm-or-abort "Deploy Firebase Realtime Database rules only?" "$@" || return 1

    firebase deploy --only database:rules
    _log_success "✅ Firebase Realtime Database rules deployed."
    _log_separator
}

# 🔑 Deploys Firebase Authentication rules only
# 💡 Usage: firebase-deploy-auth
function firebase-deploy-auth() {
    _confirm-or-abort "Deploy Firebase Authentication rules only?" "$@" || return 1

    firebase deploy --only auth
    _log_success "✅ Firebase Authentication rules deployed."
    _log_separator
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
        _log_error "❌ Could not determine default Firebase project."
        return 1
    fi

    local url="https://console.firebase.google.com/project/$project_id/overview"
    _log_info "🌐 Opening Firebase console: $url"
    open "$url"
    _log_success "✅ Firebase console opened."
    _log_separator
}

# 📜 Tails Firebase Functions logs
# 💡 Usage: firebase-logs
function firebase-logs() {
    _log_info "📜 Tailing Firebase Functions logs..."
    firebase functions:log
    _log_success "✅ Firebase Functions logs displayed."
    _log_separator
}

# ------------------------------------------------------------------------------
# 🧩 Firebase Emulators
# ------------------------------------------------------------------------------

# 🧩 Starts Firebase emulators locally
# 💡 Usage: firebase-emulator-start
function firebase-emulator-start() {
    _confirm-or-abort "Start Firebase emulator suite locally?" "$@" || return 1

    firebase emulators:start
    _log_success "✅ Firebase emulator suite started."
    _log_separator
}

# 🧹 Clears Firebase emulator data
# 💡 Usage: firebase-clear-emulator-data
function firebase-clear-emulator-data() {
    _confirm-or-abort "This will clear all Firebase emulator data. Continue?" "$@" || return 1

    rm -rf ~/.firebase/emulatorhub
    _log_success "✅ Emulator data cleared."
    _log_separator
}
