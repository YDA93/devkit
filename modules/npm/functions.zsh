# ------------------------------------------------------------------------------
# 📦 npm Global Package Management
# ------------------------------------------------------------------------------

# 💾 Saves a list of globally installed npm packages (top-level only)
# 📄 Output: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-save-packages
function npm-save-packages() {
    _log-inline-title "npm Packages Saving"
    local output="$DEVKIT_MODULES_DIR/npm/packages.txt"
    _log-info "📦 Saving global npm packages to $output"
    mkdir -p "$(dirname "$output")"

    npm list -g --depth=0 --parseable |
        tail -n +2 |
        awk -F/ '{print $NF}' >"$output" || {
        _log-error "✗ Failed to save npm packages. Please check your npm installation"
        return 1
    }

    _log-success "✓ Saved npm packages to $output"

    _log-inline-title "End of npm Packages Saving"
    echo
}

# 📥 Installs global npm packages from saved list
# 📄 Input: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-install-packages
function npm-install-packages() {
    _log-inline-title "npm Packages Installation"
    local input="$DEVKIT_MODULES_DIR/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        _log-error "✗ Package list not found at $input"
        return 1
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix) || {
        _log-error "✗ Failed to get npm prefix. Please check your npm installation"
        return 1
    }

    _log-info "📦 Installing global npm packages from $input"
    _log-info "📦 Using prefix: $npm_prefix"
    _log-info "📦 Packages:"
    cat "$input"
    echo ""

    NPM_CONFIG_PREFIX="$npm_prefix" xargs -n 1 npm install -g <"$input" || {
        _log-error "✗ Failed to install npm packages. Please check the list"
        return 1
    }

    _log-success "✓ Installed global npm packages"

    source "$DEVKIT_ROOT/bin/devkit.zsh"
    _log-inline-title "End of npm Packages Installation"
    echo
}

# 🧹 Uninstalls global npm packages listed in packages.txt
# 📄 Input: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-uninstall-packages
function npm-uninstall-packages() {
    _log-inline-title "npm Packages Uninstallation"
    local input="$DEVKIT_MODULES_DIR/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        _log-error "✗ Package list not found at $input"
        return 1
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix) || {
        _log-error "✗ Failed to get npm prefix. Please check your npm installation"
        return 1
    }

    _log-info "🧹 Uninstalling global npm packages from $input"
    _log-info "🧹 Using prefix: $npm_prefix"
    _log-info "🧹 Packages:"
    cat "$input"
    echo ""

    NPM_CONFIG_PREFIX="$npm_prefix" xargs -n 1 npm uninstall -g <"$input" || {
        _log-error "✗ Failed to uninstall npm packages. Please check the list"
        return 1
    }

    _log-success "✓ Uninstalled global npm packages"

    _log-inline-title "End of npm Packages Uninstallation"
    echo
}

# ♻️ Repairs npm environment by reinstalling Node, uninstalling, and restoring global packages
# 💡 Usage: npm-repair
function npm-repair() {
    _log-inline-title "npm Environment Repair"
    LATEST_NODE=$(echo "$DEVKIT_REQUIRED_FORMULA" | grep '^node@' | sort -V | tail -n 1) || {
        _log-error "✗ Failed to find the latest Node.js version"
        return 1
    }

    _log-info "🔧 Reinstalling npm via Homebrew ($LATEST_NODE)..."
    brew reinstall "$LATEST_NODE" || return 1
    _log-success "✓ Reinstalled npm via Homebrew"
    echo
    _log-info "🧼 Cleaning up existing global packages..."
    npm-uninstall-packages || return 1
    _log-success "✓ Cleaned up global npm packages"
    echo
    _log-info "♻️ Reinstalling global packages..."
    npm-install-packages || return 1
    _log-success "✓ Reinstalled global npm packages"

    _log-inline-title "End of npm Environment Repair"
    echo
}

# 🔥 Uninstalls global npm packages not listed in packages.txt (with confirmation)
# 📄 Input: $DEVKIT_MODULES_DIR/npm/packages.txt
# 💡 Usage: npm-prune-packages
function npm-prune-packages() {
    _log-inline-title "npm Packages Pruning"
    local file="$DEVKIT_MODULES_DIR/npm/packages.txt"

    if [[ ! -f "$file" ]]; then
        _log-error "✗ Package list not found at $file"
        return 1
    fi

    _log-info "🧹 Checking for npm packages to uninstall..."

    local current_pkgs=($(npm list -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $NF}')) || {
        _log-error "✗ Failed to list npm packages. Please check your npm installation"
        return 1
    }
    local saved_pkgs=($(cat "$file"))

    for pkg in "${current_pkgs[@]}"; do
        if ! printf '%s\n' "${saved_pkgs[@]}" | grep -qx "$pkg"; then
            if _confirm-or-abort "Uninstall \"$pkg\"? It is not listed in packages.txt." "$@"; then
                _log-error "✗ Uninstalling: $pkg"
                npm uninstall -g "$pkg"
            else
                _log-info "⏭️ Skipping: $pkg"
            fi
        fi
    done

    _log-success "✓ npm cleanup complete"
    _log-inline-title "End of npm Packages Pruning"
    echo
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
    _log-info "📦 Installed global npm packages:"
    npm list -g || {
        _log-error "✗ Failed to list npm packages. Please check your npm installation"
        return 1
    }
    echo
}

# 🩺 Diagnoses npm and Node.js setup
# - Verifies executables and prefix
# - Checks registry and permissions
# - Runs `npm doctor`
# 💡 Usage: npm-doctor
function npm-doctor() {
    _log-inline-title "npm Doctor"

    _log-info "🔧 Checking Node installation..."
    if ! command -v node &>/dev/null; then
        _log-warning "⚠️  Node.js is not installed or not in PATH"
        _log-hint "💡 Install with: brew install node"
        echo
        return 1
    fi
    _log-success "✓ Node.js is installed"
    echo

    _log-info "🔧 Checking npm installation..."
    if ! command -v npm &>/dev/null; then
        _log-warning "⚠️  npm is not installed"
        echo
        return 1
    fi
    _log-success "✓ npm is installed"
    echo

    npm_root=$(npm config get prefix 2>/dev/null) || {
        _log-warning "⚠️  Failed to get npm prefix. Please check your npm installation"
        return 1
    }
    _log-info "📁 npm global prefix: ${npm_root:-⚠️ Not set}"

    current_registry=$(npm config get registry)
    if [[ "$current_registry" != "https://registry.npmjs.org/" ]]; then
        _log-warning "⚠️  npm registry is: $current_registry"
        _log-hint "    👉 Consider resetting it:"
        _log-hint "       npm config set registry https://registry.npmjs.org/"
        echo
    else
        _log-success "✓ npm registry is set to default"
        echo
    fi

    _log-info "🔧 Checking if global npm packages are writable"
    global_path="$npm_root/lib/node_modules"
    if [[ -w "$global_path" ]]; then
        _log-success "✓ Global npm packages are writable"
        echo
    else
        _log-warning "⚠️  No write access to global npm packages"
        _log-hint "    👉 Consider using nvm or fnm to manage Node versions and avoid permission issues"
        echo
    fi

    _log-info "🧪 Running basic 'npm doctor' check..."
    npm doctor || _log-warning "⚠️  npm doctor found some issues (see above)"
    echo

    _log-inline-title "End of npm Doctor"
    echo

    return 0
}
