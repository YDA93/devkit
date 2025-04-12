# ------------------------------------------------------------------------------
# 📦 npm Global Package Management
# ------------------------------------------------------------------------------

# 💾 Saves a list of globally installed npm packages (top-level only)
# 📄 Output: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-save-packages
function npm-save-packages() {
    local output="$DEVKIT_MODULES_DIR/npm/packages.txt"
    _log_info "📦 Saving global npm packages to $output"
    mkdir -p "$(dirname "$output")"

    npm list -g --depth=0 --parseable |
        tail -n +2 |
        awk -F/ '{print $NF}' >"$output" || {
        _log_error "❌ Failed to save npm packages. Please check your npm installation."
        return 1
    }

    _log_success "✅ Saved npm packages to $output"
}

# 📥 Installs global npm packages from saved list
# 📄 Input: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-install-packages
function npm-install-packages() {
    local input="$DEVKIT_MODULES_DIR/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        _log_error "❌ Package list not found at $input"
        return 1
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix) || {
        _log_error "❌ Failed to get npm prefix. Please check your npm installation."
        return 1
    }

    _log_info "📦 Installing global npm packages from $input"
    _log_info "📦 Using prefix: $npm_prefix"
    _log_info "📦 Packages:"
    cat "$input"
    echo ""

    NPM_CONFIG_PREFIX="$npm_prefix" xargs -n 1 npm install -g <"$input" || {
        _log_error "❌ Failed to install npm packages. Please check the list."
        return 1
    }

    _log_success "✅ Installed global npm packages"

    source "$DEVKIT_ROOT/bin/devkit.zsh"
}

# 🧹 Uninstalls global npm packages listed in packages.txt
# 📄 Input: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-uninstall-packages
function npm-uninstall-packages() {
    local input="$DEVKIT_MODULES_DIR/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        _log_error "❌ Package list not found at $input"
        return 1
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix) || {
        _log_error "❌ Failed to get npm prefix. Please check your npm installation."
        return 1
    }

    _log_info "🧹 Uninstalling global npm packages from $input"
    _log_info "🧹 Using prefix: $npm_prefix"
    _log_info "🧹 Packages:"
    cat "$input"
    echo ""

    NPM_CONFIG_PREFIX="$npm_prefix" xargs -n 1 npm uninstall -g <"$input" || {
        _log_error "❌ Failed to uninstall npm packages. Please check the list."
        return 1
    }

    _log_success "✅ Uninstalled global npm packages"
}

# ♻️ Repairs npm environment by reinstalling Node, uninstalling, and restoring global packages
# 💡 Usage: npm-repair
function npm-repair() {
    LATEST_NODE=$(echo "$DEVKIT_REQUIRED_FORMULA" | grep '^node@' | sort -V | tail -n 1) || {
        _log_error "❌ Failed to find the latest Node.js version."
        return 1
    }

    _log_info "🔧 Reinstalling npm via Homebrew ($LATEST_NODE)..."
    brew reinstall "$LATEST_NODE" || return 1
    _log_info "🧼 Cleaning up existing global packages..."
    npm-uninstall-packages || return 1
    _log_info "♻️ Reinstalling global packages..."
    npm-install-packages || return 1
    _log_success "✅ npm repair complete"
}

# 🔥 Uninstalls global npm packages not listed in packages.txt (with confirmation)
# 📄 Input: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-prune-packages
function npm-prune-packages() {
    local file="$DEVKIT_MODULES_DIR/npm/packages.txt"

    if [[ ! -f "$file" ]]; then
        _log_error "❌ Package list not found at $file"
        return 1
    fi

    _log_info "🧹 Checking for npm packages to uninstall..."

    local current_pkgs=($(npm list -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $NF}')) || {
        _log_error "❌ Failed to list npm packages. Please check your npm installation."
        return 1
    }
    local saved_pkgs=($(cat "$file"))

    for pkg in "${current_pkgs[@]}"; do
        if ! printf '%s\n' "${saved_pkgs[@]}" | grep -qx "$pkg"; then
            if _confirm-or-abort "Uninstall \"$pkg\"? It is not listed in packages.txt." "$@"; then
                _log_error "❌ Uninstalling: $pkg"
                npm uninstall -g "$pkg"
            else
                _log_info "⏭️ Skipping: $pkg"
            fi
        fi
    done

    _log_success "✅ npm cleanup complete."
}

# ⚙️ Full npm setup: prune and install from saved package list
# 💡 Usage: npm-setup
function npm-setup() {
    npm-prune-packages || return 1
    npm-install-packages || return 1
}

# 📋 Lists all globally installed npm packages
# 💡 Usage: npm-list-packages
function npm-list-packages() {
    _log_success "📦 Installed global npm packages:"
    npm list -g || {
        _log_error "❌ Failed to list npm packages. Please check your npm installation."
        return 1
    }
}

# 🩺 Diagnoses npm and Node.js setup
# - Verifies executables and prefix
# - Checks registry and permissions
# - Runs `npm doctor`
# 💡 Usage: npm-doctor
function npm-doctor() {
    _log_info "📦 Checking npm and Node.js..."

    if ! command -v node &>/dev/null; then
        _log_warning "⚠️  Node.js is not installed or not in PATH."
        _log_hint "💡 Install with: brew install node"
        return 1
    fi

    if ! command -v npm &>/dev/null; then
        _log_warning "⚠️  npm is not installed."
        return 1
    fi

    npm_root=$(npm config get prefix 2>/dev/null) || {
        _log_warning "⚠️  Failed to get npm prefix. Please check your npm installation."
        return 1
    }
    echo "📁 npm global prefix: ${npm_root:-⚠️ Not set}"

    current_registry=$(npm config get registry)
    if [[ "$current_registry" != "https://registry.npmjs.org/" ]]; then
        _log_warning "⚠️  npm registry is: $current_registry"
        echo "    👉 Consider resetting it:"
        echo "       npm config set registry https://registry.npmjs.org/"
    else
        _log_success "✅ npm registry is set to default"
    fi

    global_path="$npm_root/lib/node_modules"
    if [[ -w "$global_path" ]]; then
        _log_success "✅ Global npm packages are writable"
    else
        _log_warning "⚠️  No write access to global npm packages"
        echo "    👉 Consider using nvm or fnm to manage Node versions and avoid permission issues"
    fi

    _log_info "🧪 Running basic 'npm doctor' check..."
    npm doctor || _log_warning "⚠️  npm doctor found some issues (see above)"

    return 0
}
