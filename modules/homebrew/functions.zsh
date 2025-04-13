# ------------------------------------------------------------------------------
# 🍺 Homebrew Setup & Initialization
# ------------------------------------------------------------------------------

# 🍺 Installs Homebrew if not already installed
# - Ensures brew is functional afterward
# 💡 Usage: homebrew-install
function homebrew-install() {
    _log_info "🍺 Checking Homebrew installation..."
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        _log_info "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            _log_error "Homebrew installation failed."
            _log_separator
            return 1
        }
    else
        _log_success "✅ Homebrew is already installed."
        _log_separator
        return 0
    fi

    # Verify Homebrew is working
    if ! brew --version &>/dev/null; then
        _log_error "Homebrew seems to be installed but not working properly."
        _log_separator
        return 1
    fi

    _log_success "✅ Homebrew is installed and working."
    _log_separator
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
# 📄 Output: $DEVKIT_MODULES_DIR/homebrew/formulas.txt and casks.txt
# 💡 Usage: homebrew-save-packages
function homebrew-save-packages() {
    local base_dir="$DEVKIT_MODULES_DIR/homebrew"
    local formula_output="$base_dir/formulas.txt"
    local casks_output="$base_dir/casks.txt"

    _log_info "🍺 Saving installed Homebrew formula to $formula_output"
    _log_info "🧴 Saving installed Homebrew casks to $casks_output"
    mkdir -p "$base_dir"

    brew list --formula --installed-on-request >"$formula_output"
    brew list --cask >"$casks_output"

    _log_success "✅ Saved installed packages:"
    _log_info "   📄 Formulas: $formula_output"
    _log_info "   📄 Casks:    $casks_output"
    _log_separator
}

# 📦 Installs Homebrew formula and casks from saved package lists
# 📄 Input: $DEVKIT_MODULES_DIR/homebrew/formulas.txt and casks.txt
# 💡 Usage: homebrew-install-packages
function homebrew-install-packages() {
    local base_dir="$DEVKIT_MODULES_DIR/homebrew"
    local formula_input="$base_dir/formulas.txt"
    local casks_input="$base_dir/casks.txt"

    if [[ ! -f "$formula_input" && ! -f "$casks_input" ]]; then
        _log_error "❌ No package lists found in $base_dir"
        return 1
    fi

    if [[ -f "$formula_input" ]]; then
        _log_info "🍺 Installing Homebrew formula from $formula_input"
        xargs brew install --formula <"$formula_input" || {
            _log_error "❌ Failed to install formula. Please check the list."
            return 1
        }
    fi

    source "$DEVKIT_ROOT/bin/devkit.zsh"

    postgres-setup || {
        _log_error "❌ Failed to set up PostgreSQL. Please check the setup."
        return 1
    }

    if [[ -f "$casks_input" ]]; then
        _log_info "🧴 Installing Homebrew casks from $casks_input"
        xargs brew install --cask <"$casks_input" || {
            _log_error "❌ Failed to install casks. Please check the list."
            return 1
        }
    fi

    homebrew-clean || return 1

    _log_success "✅ Finished installing Homebrew packages"
    _log_separator
}

# 🔥 Uninstalls Homebrew packages not listed in saved package files or .settings
# - Reads from: formulas.txt, casks.txt, and .settings
# - Prompts before each uninstall
# 💡 Usage: homebrew-prune-packages
function homebrew-prune-packages() {
    local base_dir="$DEVKIT_MODULES_DIR/homebrew"
    local formula_file="$base_dir/formulas.txt"
    local casks_file="$base_dir/casks.txt"
    local settings_file="$DEVKIT_ROOT/.settings"

    if [[ ! -f "$formula_file" && ! -f "$casks_file" && ! -f "$settings_file" ]]; then
        _log_error "❌ No package lists or settings file found."
        return 1
    fi

    _log_info "🧹 Checking for Homebrew packages to uninstall..."
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
                _log_error "❌ Uninstalling formula: $pkg"
                brew uninstall --ignore-dependencies "$pkg"
            else
                _log_info "⏭️ Skipping formula: $pkg"
            fi
        fi
    done

    # 🔥 Prune casks
    for cask in "${current_casks[@]}"; do
        if ! printf '%s\n' "${desired_casks[@]}" | grep -qx "$cask"; then
            if _confirm-or-abort "Uninstall cask \"$cask\"? It's not in casks.txt or settings." "$@"; then
                _log_error "❌ Uninstalling cask: $cask"
                brew uninstall --cask "$cask"
            else
                _log_info "⏭️ Skipping cask: $cask"
            fi
        fi
    done

    _log_success "✅ Finished pruning Homebrew packages."
    _log_separator

    homebrew-clean || return 1

}

# 📋 Lists all currently installed Homebrew packages
# 💡 Usage: homebrew-list-packages
function homebrew-list-packages() {
    _log_info "🍺 Installed Homebrew formula:"
    brew list --formula --installed-on-request
    _log_info "🧴 Installed Homebrew casks:"
    brew list --cask
}

# 📦 Installs Homebrew formula and casks based on user settings
# - Reads $DEVKIT_ROOT/.settings
# - Only installs entries marked "y"
# 💡 Usage: homebrew-install-from-settings
function homebrew-install-from-settings() {
    local settings_file="$DEVKIT_ROOT/.settings"

    if [[ ! -f "$settings_file" ]]; then
        _log_error "❌ Settings file not found at $settings_file"
        _log_hint "💡 Run: devkit-settings-setup"
        return 1
    fi

    _log_info "🔧 Installing Homebrew packages based on your saved settings..."
    _log_info "📄 Source: $settings_file"
    echo ""

    source "$settings_file"

    _log_info "🍺 Installing selected Homebrew formula..."
    local installed_formula=0
    while IFS='=' read -r key value; do
        if [[ "$key" == formula_install_* && "$value" == "\"y\"" ]]; then
            local formula="${key#formula_install_}"
            _log_info "🔧 Installing formula: $formula"
            brew install "$formula" && ((installed_formula++))
        fi
    done <"$settings_file"

    echo ""
    _log_info "🧴 Installing selected Homebrew casks..."
    local installed_casks=0
    while IFS='=' read -r key value; do
        if [[ "$key" == cask_install_* && "$value" == "\"y\"" ]]; then
            local raw_cask="${key#cask_install_}"
            local cask="${raw_cask//_/-}" # 🔁 Replace underscores back to hyphens
            _log_info "📦 Installing cask: $cask"
            brew install --cask "$cask" && ((installed_casks++))
        fi
    done <"$settings_file"

    echo ""
    homebrew-clean || return 1

    _log_success "✅ Done! Installed $installed_formula formula and $installed_casks casks from saved settings."
    _log_separator
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
    _log_info "🩺 Checking brew system health..."
    brew doctor || _log_warning "⚠️ brew doctor reported issues."
    _log_success "✅ brew doctor completed."
    _log_separator

    _log_info "⬆️  Updating Homebrew..."
    brew update || return 1
    _log_success "✅ Homebrew updated."
    _log_separator

    _log_info "🔄 Upgrading formulas..."
    brew upgrade --formula || return 1
    _log_success "✅ Upgraded formulas."
    _log_separator

    _log_info "🧴 Upgrading casks..."
    brew upgrade --cask || return 1
    _log_success "✅ Upgraded casks."
    _log_separator

    homebrew-clean || return 1

}

# ♻️ Cleans up Homebrew:
# - Autoremoves unused dependencies
# - Cleans up old versions and cache
# - Verifies installed packages
# 💡 Usage: homebrew-clean
function homebrew-clean() {
    _log_info "🧹 Autoremoving unused dependencies..."
    brew autoremove || return 1
    _log_success "✅ Removed unused dependencies."
    _log_separator

    _log_info "🗑️  Cleaning up old versions and cache..."
    brew cleanup || return 1
    _log_success "✅ Cleaned up old versions and cache."
    _log_separator

    _log_info "📦 Verifying installed packages..."
    brew missing || return 1
    _log_success "✅ Verified installed packages."
    _log_separator
}

# 🔧 Checks the status of Homebrew on your system
# - Verifies installation
# - Runs 'brew doctor'
# - Checks for outdated packages
# 💡 Usage: homebrew-doctor
function homebrew-doctor() {
    _log_info "🔧 Checking Homebrew installation..."

    if ! command -v brew &>/dev/null; then
        _log_warning "⚠️  Homebrew is not installed."
        _log_hint "👉 You can install it with: homebrew-install"
        return 1
    fi
    _log_success "✅ Homebrew is installed."
    _log_separator

    _log_info "🩺 Running 'brew doctor'..."
    brew doctor
    if [[ $? -ne 0 ]]; then
        _log_warning "⚠️  Homebrew reports issues. Run 'brew doctor' manually to review details."
        _log_separator
        return 1
    else
        _log_success "✅ No major issues reported by Homebrew."
        _log_separator
    fi

    _log_info "📦 Checking for brew outdated packages..."
    if [[ -n "$(brew outdated)" ]]; then
        _log_warning "⚠️  You have outdated packages."
        _log_hint "👉 Consider running 'brew outdated' to see which ones."
        _log_hint "👉 To upgrade, use: 'homebrew-maintain'"
        _log_separator
    else
        _log_success "✅ All packages are up to date."
        _log_separator
    fi

    return 0
}
