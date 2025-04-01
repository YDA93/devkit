# ------------------------------------------------------------------------------
# 📦 npm Global Package Management
# ------------------------------------------------------------------------------

# 💾 Saves a list of globally installed npm packages (top-level only)
# 📄 Output: $DEVKIT_MODULES_PATH/npm/packages.txt
# 💡 Usage: npm-save-packages
function npm-save-packages() {
    local output="$DEVKIT_MODULES_PATH/npm/packages.txt"
    echo "📦 Saving global npm packages to $output"
    mkdir -p "$(dirname "$output")"

    npm list -g --depth=0 --parseable |
        tail -n +2 |
        awk -F/ '{print $NF}' >"$output" || {
        echo "❌ Failed to save npm packages. Please check your npm installation."
        return 1
    }

    echo "✅ Saved npm packages to $output"
}

# 📥 Installs global npm packages from saved list
# 📄 Input: $DEVKIT_MODULES_PATH/npm/packages.txt
# 💡 Usage: npm-install-packages
function npm-install-packages() {
    local input="$DEVKIT_MODULES_PATH/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ Package list not found at $input"
        return 1
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix) || {
        echo "❌ Failed to get npm prefix. Please check your npm installation."
        return 1
    }

    echo "📦 Installing global npm packages from $input"
    echo "📦 Using prefix: $npm_prefix"
    echo "📦 Packages:"
    cat "$input"
    echo ""

    NPM_CONFIG_PREFIX="$npm_prefix" xargs -n 1 npm install -g <"$input" || {
        echo "❌ Failed to install npm packages. Please check the list."
        return 1
    }

    echo "✅ Installed global npm packages"
}

# 🧹 Uninstalls global npm packages listed in packages.txt
# 📄 Input: $DEVKIT_MODULES_PATH/npm/packages.txt
# 💡 Usage: npm-uninstall-packages
function npm-uninstall-packages() {
    local input="$DEVKIT_MODULES_PATH/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ Package list not found at $input"
        return 1
    fi

    local npm_prefix
    npm_prefix=$(npm config get prefix) || {
        echo "❌ Failed to get npm prefix. Please check your npm installation."
        return 1
    }

    echo "🧹 Uninstalling global npm packages from $input"
    echo "🧹 Using prefix: $npm_prefix"
    echo "🧹 Packages:"
    cat "$input"
    echo ""

    NPM_CONFIG_PREFIX="$npm_prefix" xargs -n 1 npm uninstall -g <"$input" || {
        echo "❌ Failed to uninstall npm packages. Please check the list."
        return 1
    }

    echo "✅ Uninstalled global npm packages"
}

# ♻️ Repairs npm environment by reinstalling Node, uninstalling, and restoring global packages
# 💡 Usage: npm-repair
function npm-repair() {
    LATEST_NODE=$(echo "$DEVKIT_REQUIRED_FORMULAE" | grep '^node@' | sort -V | tail -n 1) || {
        echo "❌ Failed to find the latest Node.js version."
        return 1
    }

    echo "🔧 Reinstalling npm via Homebrew ($LATEST_NODE)..."
    brew reinstall "$LATEST_NODE" || return 1
    echo "🧼 Cleaning up existing global packages..."
    npm-uninstall-packages || return 1
    echo "♻️ Reinstalling global packages..."
    npm-install-packages || return 1
    echo "✅ npm repair complete"
}

# 🔥 Uninstalls global npm packages not listed in packages.txt (with confirmation)
# 📄 Input: $DEVKIT_MODULES_PATH/npm/packages.txt
# 💡 Usage: npm-prune-packages
function npm-prune-packages() {
    local file="$DEVKIT_MODULES_PATH/npm/packages.txt"

    if [[ ! -f "$file" ]]; then
        echo "❌ Package list not found at $file"
        return 1
    fi

    echo "🧹 Checking for npm packages to uninstall..."

    local current_pkgs=($(npm list -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $NF}')) || {
        echo "❌ Failed to list npm packages. Please check your npm installation."
        return 1
    }
    local saved_pkgs=($(cat "$file"))

    for pkg in "${current_pkgs[@]}"; do
        if ! printf '%s\n' "${saved_pkgs[@]}" | grep -qx "$pkg"; then
            if _confirm-or-abort "Uninstall \"$pkg\"? It is not listed in packages.txt." "$@"; then
                echo "❌ Uninstalling: $pkg"
                npm uninstall -g "$pkg"
            else
                echo "⏭️ Skipping: $pkg"
            fi
        fi
    done

    echo "✅ npm cleanup complete."
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
    echo "📦 Installed global npm packages:"
    npm list -g || {
        echo "❌ Failed to list npm packages. Please check your npm installation."
        return 1
    }
}

# 🩺 Diagnoses npm and Node.js setup
# - Verifies executables and prefix
# - Checks registry and permissions
# - Runs `npm doctor`
# 💡 Usage: npm-doctor
function npm-doctor() {
    echo "📦 Checking npm and Node.js..."

    if ! command -v node &>/dev/null; then
        echo "⚠️  Node.js is not installed or not in PATH."
        echo "💡 Install with: brew install node"
        return 1
    fi

    if ! command -v npm &>/dev/null; then
        echo "⚠️  npm is not installed."
        return 1
    fi

    npm_root=$(npm config get prefix 2>/dev/null) || {
        echo "⚠️  Failed to get npm prefix. Please check your npm installation."
        return 1
    }
    echo "📁 npm global prefix: ${npm_root:-⚠️ Not set}"

    current_registry=$(npm config get registry)
    if [[ "$current_registry" != "https://registry.npmjs.org/" ]]; then
        echo "⚠️  npm registry is: $current_registry"
        echo "    👉 Consider resetting it:"
        echo "       npm config set registry https://registry.npmjs.org/"
    else
        echo "✅ npm registry is set to default"
    fi

    global_path="$npm_root/lib/node_modules"
    if [[ -w "$global_path" ]]; then
        echo "✅ Global npm packages are writable"
    else
        echo "⚠️  No write access to global npm packages"
        echo "    👉 Consider using nvm or fnm to manage Node versions and avoid permission issues"
    fi

    echo "🧪 Running basic 'npm doctor' check..."
    npm doctor || echo "⚠️  npm doctor found some issues (see above)"

    return 0
}
