# ------------------------------------------------------------------------------
# 🍺 Homebrew Setup & Initialization
# ------------------------------------------------------------------------------

# 🍺 Installs Homebrew if not already installed
# - Ensures brew is functional afterward
# 💡 Usage: homebrew-install
function homebrew-install() {
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "Homebrew installation failed."
            return 1
        }
    else
        echo "Homebrew is already installed."
    fi

    # Verify Homebrew is working
    if ! brew --version &>/dev/null; then
        echo "Homebrew seems to be installed but not working properly."
        return 1
    fi

    echo "✅ Homebrew is installed and working."
}

# ⚙️ Runs the full Homebrew environment setup:
# - Installs Homebrew if needed
# - Prunes unlisted packages
# - Installs saved formula and casks
# 💡 Usage: homebrew-setup
function homebrew-setup() {
    homebrew-install || return 1
    homebrew-prune-packages || return 1
    homebrew-install-packages || return 1
    homebrew-install-from-settings || return 1
    homebrew-maintain || return 1
}

# ------------------------------------------------------------------------------
# 💾 Homebrew Package Management
# ------------------------------------------------------------------------------

# 💾 Saves lists of top-level Homebrew formula and casks
# 📄 Output: $DEVKIT_MODULES_PATH/homebrew/formulas.txt and casks.txt
# 💡 Usage: homebrew-save-packages
function homebrew-save-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formula_output="$base_dir/formulas.txt"
    local casks_output="$base_dir/casks.txt"

    echo "🍺 Saving installed Homebrew formula to $formula_output"
    echo "🧴 Saving installed Homebrew casks to $casks_output"
    mkdir -p "$base_dir"

    brew list --formula --installed-on-request >"$formula_output"
    brew list --cask >"$casks_output"

    echo "✅ Saved installed packages:"
    echo "   📄 Formulas: $formula_output"
    echo "   📄 Casks:    $casks_output"
}

# 📦 Installs Homebrew formula and casks from saved package lists
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/formulas.txt and casks.txt
# 💡 Usage: homebrew-install-packages
function homebrew-install-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formula_input="$base_dir/formulas.txt"
    local casks_input="$base_dir/casks.txt"

    if [[ ! -f "$formula_input" && ! -f "$casks_input" ]]; then
        echo "❌ No package lists found in $base_dir"
        return 1
    fi

    if [[ -f "$formula_input" ]]; then
        echo "🍺 Installing Homebrew formula from $formula_input"
        xargs brew install --formula <"$formula_input" || {
            echo "❌ Failed to install formula. Please check the list."
            return 1
        }
    fi

    source "$DEVKIT_ROOT/bin/devkit.zsh"

    postgres-setup || {
        echo "❌ Failed to set up PostgreSQL. Please check the setup."
        return 1
    }

    if [[ -f "$casks_input" ]]; then
        echo "🧴 Installing Homebrew casks from $casks_input"
        xargs brew install --cask <"$casks_input" || {
            echo "❌ Failed to install casks. Please check the list."
            return 1
        }
    fi

    homebrew-clean || return 1

    echo "✅ Finished installing Homebrew packages"
}

# 🔥 Uninstalls Homebrew packages not listed in saved package files or .settings
# - Reads from: formulas.txt, casks.txt, and .settings
# - Prompts before each uninstall
# 💡 Usage: homebrew-prune-packages
function homebrew-prune-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formula_file="$base_dir/formulas.txt"
    local casks_file="$base_dir/casks.txt"
    local settings_file="$DEVKIT_ROOT/.settings"

    if [[ ! -f "$formula_file" && ! -f "$casks_file" && ! -f "$settings_file" ]]; then
        echo "❌ No package lists or settings file found."
        return 1
    fi

    echo "🧹 Checking for Homebrew packages to uninstall..."
    [[ -f "$settings_file" ]] && source "$settings_file"

    local current_formula=($(brew list --formula --installed-on-request))
    local current_casks=($(brew list --cask))

    local desired_formula=()
    local desired_casks=()

    # 1. From formulas.txt
    if [[ -f "$formula_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_formula+=("$line")
        done <"$formula_file"
    fi

    # 2. From .settings (formula)
    if [[ -f "$settings_file" ]]; then
        while IFS='=' read -r key value; do
            [[ "$value" != "\"y\"" ]] && continue
            [[ "$key" == formula_install_* ]] && desired_formula+=("${key#formula_install_}")
        done <"$settings_file"
    fi

    # 3. From casks.txt
    if [[ -f "$casks_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_casks+=("$line")
        done <"$casks_file"
    fi

    # 4. From .settings (cask)
    if [[ -f "$settings_file" ]]; then
        while IFS='=' read -r key value; do
            [[ "$value" != "\"y\"" ]] && continue
            if [[ "$key" == cask_install_* ]]; then
                local raw="${key#cask_install_}"
                desired_casks+=("${raw//_/-}") # Convert back to real cask name
            fi
        done <"$settings_file"
    fi

    # Remove duplicates from arrays
    desired_formula=($(printf "%s\n" "${desired_formula[@]}" | sort -u))
    desired_casks=($(printf "%s\n" "${desired_casks[@]}" | sort -u))

    # 🔥 Prune formula
    for pkg in "${current_formula[@]}"; do
        if ! printf '%s\n' "${desired_formula[@]}" | grep -qx "$pkg"; then
            if _confirm-or-abort "Uninstall formula \"$pkg\"? It's not in formulas.txt or settings." "$@"; then
                echo "❌ Uninstalling formula: $pkg"
                brew uninstall --ignore-dependencies "$pkg"
            else
                echo "⏭️ Skipping formula: $pkg"
            fi
        fi
    done

    # 🔥 Prune casks
    for cask in "${current_casks[@]}"; do
        if ! printf '%s\n' "${desired_casks[@]}" | grep -qx "$cask"; then
            if _confirm-or-abort "Uninstall cask \"$cask\"? It's not in casks.txt or settings." "$@"; then
                echo "❌ Uninstalling cask: $cask"
                brew uninstall --cask "$cask"
            else
                echo "⏭️ Skipping cask: $cask"
            fi
        fi
    done

    homebrew-clean || return 1

    echo "✅ Cleanup complete. Only desired packages remain."
}

# 📋 Lists all currently installed Homebrew packages
# 💡 Usage: homebrew-list-packages
function homebrew-list-packages() {
    echo "🍺 Installed Homebrew formula:"
    brew list --formula --installed-on-request
    echo "🧴 Installed Homebrew casks:"
    brew list --cask
}

# 📦 Installs Homebrew formula and casks based on user settings
# - Reads $DEVKIT_ROOT/.settings
# - Only installs entries marked "y"
# 💡 Usage: homebrew-install-from-settings
function homebrew-install-from-settings() {
    local settings_file="$DEVKIT_ROOT/.settings"

    if [[ ! -f "$settings_file" ]]; then
        echo "❌ Settings file not found at $settings_file"
        echo "💡 Run: devkit-settings-setup"
        return 1
    fi

    echo "🔧 Installing Homebrew packages based on your saved settings..."
    echo "📄 Source: $settings_file"
    echo ""

    source "$settings_file"

    echo "🍺 Installing selected Homebrew formula..."
    local installed_formula=0
    while IFS='=' read -r key value; do
        if [[ "$key" == formula_install_* && "$value" == "\"y\"" ]]; then
            local formula="${key#formula_install_}"
            echo "🔧 Installing formula: $formula"
            brew install "$formula" && ((installed_formula++))
        fi
    done <"$settings_file"

    echo ""
    echo "🧴 Installing selected Homebrew casks..."
    local installed_casks=0
    while IFS='=' read -r key value; do
        if [[ "$key" == cask_install_* && "$value" == "\"y\"" ]]; then
            local raw_cask="${key#cask_install_}"
            local cask="${raw_cask//_/-}" # 🔁 Replace underscores back to hyphens
            echo "📦 Installing cask: $cask"
            brew install --cask "$cask" && ((installed_casks++))
        fi
    done <"$settings_file"

    echo ""
    homebrew-clean || return 1

    echo "✅ Done! Installed $installed_formula formula and $installed_casks casks from saved settings."
}

# ------------------------------------------------------------------------------
# ♻️ Homebrew Maintenance & Health Checks
# ------------------------------------------------------------------------------

# ♻️ Performs full Homebrew maintenance:
# - Runs doctor
# - Updates and upgrades all packages
# - Cleans unused dependencies
# 💡 Usage: homebrew-maintain
function homebrew-maintain() {
    echo "🩺 Checking system health..."
    brew doctor || echo "⚠️ brew doctor reported issues."

    echo "⬆️  Updating Homebrew..."
    brew update || return 1
    echo "✅ Homebrew updated."

    echo "🔄 Upgrading formulas..."
    brew upgrade --formula || return 1
    echo "✅ Upgraded formulas."

    echo "🧴 Upgrading casks..."
    brew upgrade --cask || return 1
    echo "✅ Upgraded casks."

    homebrew-clean || return 1

    echo "✅ Homebrew maintenance complete!"
}

# ♻️ Cleans up Homebrew:
# - Autoremoves unused dependencies
# - Cleans up old versions and cache
# - Verifies installed packages
# 💡 Usage: homebrew-clean
function homebrew-clean() {
    echo "🧹 Autoremoving unused dependencies..."
    brew autoremove || return 1
    echo "✅ Removed unused dependencies."

    echo "🗑️ Cleaning up old versions and cache..."
    brew cleanup || return 1
    echo "✅ Cleaned up old versions and cache."

    echo "📦 Verifying installed packages..."
    brew missing || return 1
    echo "✅ Verified installed packages."
}

# 🔧 Checks the status of Homebrew on your system
# - Verifies installation
# - Runs 'brew doctor'
# - Checks for outdated packages
# 💡 Usage: homebrew-doctor
function homebrew-doctor() {
    echo "🔧 Checking Homebrew..."

    if ! command -v brew &>/dev/null; then
        echo "⚠️  Homebrew is not installed."
        echo "👉 You can install it with: homebrew-install"
        return 1
    fi

    echo "🩺 Running 'brew doctor'..."
    brew doctor
    if [[ $? -ne 0 ]]; then
        echo "⚠️  Homebrew reports issues. Run 'brew doctor' manually to review details."
        return 1
    else
        echo "✅ No major issues reported by Homebrew."
    fi

    echo "📦 Checking for outdated packages..."
    if [[ -n "$(brew outdated)" ]]; then
        echo "⚠️  You have outdated packages."
        echo "👉 Consider running 'brew outdated' to see which ones."
        echo "👉 To upgrade, use: 'homebrew-maintain'"
    else
        echo "✅ All packages are up to date."
    fi

    return 0
}
