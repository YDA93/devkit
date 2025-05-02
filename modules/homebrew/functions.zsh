# ------------------------------------------------------------------------------
# 🍺 Homebrew Setup & Initialization
# ------------------------------------------------------------------------------

# 🍺 Installs Homebrew if not already installed
# - Ensures brew is functional afterward
# 💡 Usage: homebrew-install
function homebrew-install() {
    _log-inline-title "Homebrew Installation"

    _log-info "🍺 Checking Homebrew installation..."
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        _log-info "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            _log-error "Homebrew installation failed"
            echo
            return 1
        }
    else
        _log-success "✓ Homebrew is already installed"
        _log-inline-title "End of Homebrew Installation"
        echo
        return 0
    fi

    # Verify Homebrew is working
    if ! brew --version &>/dev/null; then
        _log-error "Homebrew seems to be installed but not working properly"
        _log-inline-title "End of Homebrew Installation"
        echo
        return 1
    fi

    _log-success "✓ Homebrew is installed and working"

    _log-inline-title "End of Homebrew Installation"
    echo
}

# ⚙️ Runs the full Homebrew environment setup:
# - Installs Homebrew if needed
# - Prunes unlisted packages
# - Installs saved formula and casks
# 💡 Usage: homebrew-setup
function homebrew-setup() {
    homebrew-install || return 1
    homebrew-install-packages || return 1
    homebrew-install-packages-from-settings || return 1

    # Check if powerlevel10k is installed via Homebrew
    if brew list powerlevel10k &>/dev/null; then
        _log-inline-title "Powerlevel10k Font Setup"
        powerlevel10k-set-font-meslo-nerd || return 1
        _log-success "✓ Powerlevel10k font set to MesloLGS Nerd Font across all terminals"
        _log-inline-title "End of Powerlevel10k Font Setup"
        echo
    fi

    homebrew-prune-packages || return 1
    homebrew-maintain || return 1
}

# ------------------------------------------------------------------------------
# 💾 Homebrew Package Management
# ------------------------------------------------------------------------------

# 💾 Saves lists of top-level Homebrew formula and casks
# 📄 Output: $DEVKIT_MODULES_DIR/homebrew/formulas.txt and casks.txt
# 💡 Usage: homebrew-save-packages
function homebrew-save-packages() {
    _log-inline-title "Homebrew Package Backup"

    local base_dir="$DEVKIT_MODULES_DIR/homebrew"
    local formula_output="$base_dir/formulas.txt"
    local casks_output="$base_dir/casks.txt"

    _log-info "🍺 Saving installed Homebrew formula to $formula_output"
    _log-info "🧴 Saving installed Homebrew casks to $casks_output"
    mkdir -p "$base_dir"

    brew list --formula --installed-on-request >"$formula_output"
    brew list --cask >"$casks_output"

    _log-success "✓ Saved installed packages:"
    _log-info "   📄 Formulas: $formula_output"
    _log-info "   📄 Casks:    $casks_output"
    echo

    _log-inline-title "End of Homebrew Package Backup"
    echo
}

# 📦 Installs Homebrew formula and casks from saved package lists
# 📄 Input: $DEVKIT_MODULES_DIR/homebrew/formulas.txt and casks.txt
# 💡 Usage: homebrew-install-packages
function homebrew-install-packages() {
    _log-inline-title "Homebrew Package Installation"
    local base_dir="$DEVKIT_MODULES_DIR/homebrew"
    local formula_input="$base_dir/formulas.txt"
    local casks_input="$base_dir/casks.txt"

    if [[ ! -f "$formula_input" && ! -f "$casks_input" ]]; then
        _log-error "✗ No package lists found in $base_dir"
        return 1
    fi

    if [[ -f "$formula_input" ]]; then
        _log-info "🍺 Installing Homebrew formula from $formula_input"
        xargs brew install --formula <"$formula_input" || {
            _log-error "✗ Failed to install formula. Please check the list"
            return 1
        }
    fi

    source "$DEVKIT_ROOT/bin/devkit.zsh"

    postgres-setup || {
        _log-error "✗ Failed to set up PostgreSQL. Please check the setup"
        return 1
    }

    if [[ -f "$casks_input" ]]; then
        _log-info "🧴 Installing Homebrew casks from $casks_input"

        while IFS= read -r cask || [[ -n "$cask" ]]; do
            if [[ -n "$cask" ]]; then # skip empty lines
                if ! brew install --cask "$cask"; then
                    _log-error "✗ Failed to install $cask, attempting to fix..."
                    brew uninstall --cask --force "$cask"
                    if brew install --cask "$cask"; then
                        _log-success "✓ Successfully installed $cask after fix"
                    else
                        _log-error "✗ Failed to install $cask even after fix"
                        return 1
                    fi
                fi
            fi
        done <"$casks_input"
    fi

    _log-success "✓ Finished installing Homebrew packages"

    _log-inline-title "End of Homebrew Package Installation"
    echo

}

# 📦 Installs Homebrew formula and casks based on user settings
# - Reads $DEVKIT_ROOT/settings.json
# - Only installs entries marked "y"
# 💡 Usage: homebrew-install-packages-from-settings
function homebrew-install-packages-from-settings() {
    _log-inline-title "Homebrew Package Installation from Settings"
    local settings_file="$DEVKIT_ROOT/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        _log-error "✗ Settings file not found at $settings_file"
        _log-hint "💡 Run: devkit-settings-setup"
        return 1
    fi

    _log-info "🔧 Installing Homebrew packages based on your saved settings..."
    echo ""

    _log-info "🍺 Installing the selected optional Homebrew formula..."
    formulas=($(_devkit-settings get array formula_apps))
    local installed_formula=0
    for formula in "${formulas[@]}"; do
        if brew install "$formula"; then
            ((installed_formula++))
        fi
    done

    echo ""
    _log-info "🧴 Installing the selected optional Homebrew casks..."
    casks=($(_devkit-settings get array cask_apps))
    local installed_casks=0
    for cask in "${casks[@]}"; do
        if brew install --cask "$cask"; then
            ((installed_casks++))
        else
            _log-error "Install failed for $cask, trying to fix..."
            brew uninstall --cask --force "$cask"
            if brew install --cask "$cask"; then
                ((installed_casks++))
                _log-success "✓ Successfully installed $cask after retry"
            else
                _log-error "Failed to install $cask after retry"
            fi
        fi
    done
    _log-success "✓ Done! Installed $installed_formula formula and $installed_casks casks from saved settings"

    _log-inline-title "End of Homebrew Package Installation from Settings"
    echo

}

# 🔥 Uninstalls Homebrew packages not listed in saved package files or settings.json
# - Reads from: formulas.txt, casks.txt, and settings.json
# - Prompts before each uninstall
# 💡 Usage: homebrew-prune-packages
function homebrew-prune-packages() {
    _log-inline-title "Homebrew Package Pruning"
    local base_dir="$DEVKIT_MODULES_DIR/homebrew"
    local formula_file="$base_dir/formulas.txt"
    local casks_file="$base_dir/casks.txt"
    local settings_file="$DEVKIT_ROOT/settings.json"

    if [[ ! -f "$formula_file" && ! -f "$casks_file" && ! -f "$settings_file" ]]; then
        _log-error "✗ No package lists or settings file found"
        return 1
    fi

    _log-info "🧹 Checking for Homebrew packages to uninstall..."

    local current_formula=($(brew list --formula --installed-on-request))
    local current_casks=($(brew list --cask))

    local desired_formula=$(_devkit-settings get array formula_apps)
    local desired_casks=$(_devkit-settings get array cask_apps)

    # 1. From formulas.txt
    if [[ -f "$formula_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_formula+=("$line")
        done <"$formula_file"
    fi

    # 2. From casks.txt
    if [[ -f "$casks_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_casks+=("$line")
        done <"$casks_file"
    fi

    # Remove duplicates from arrays
    desired_formula=($(printf "%s\n" "${desired_formula[@]}" | sort -u))
    desired_casks=($(printf "%s\n" "${desired_casks[@]}" | sort -u))

    # 🔥 Prune formula
    for pkg in "${current_formula[@]}"; do
        if ! printf '%s\n' "${desired_formula[@]}" | grep -qx "$pkg"; then
            if _confirm-or-abort "Uninstall formula \"$pkg\"? It's not in formulas.txt or settings." "$@"; then
                _log-error "✗ Uninstalling formula: $pkg"
                brew uninstall --ignore-dependencies "$pkg"
            else
                _log-info "⏭️ Skipping formula: $pkg"
            fi
        fi
    done

    # 🔥 Prune casks
    for cask in "${current_casks[@]}"; do
        if ! printf '%s\n' "${desired_casks[@]}" | grep -qx "$cask"; then
            if _confirm-or-abort "Uninstall cask \"$cask\"? It's not in casks.txt or settings." "$@"; then
                _log-error "✗ Uninstalling cask: $cask"
                brew uninstall --cask "$cask"
            else
                _log-info "⏭️ Skipping cask: $cask"
            fi
        fi
    done

    _log-success "✓ Finished pruning Homebrew packages"

    _log-inline-title "End of Homebrew Package Pruning"
    echo

}

# 📋 Lists all currently installed Homebrew packages
# 💡 Usage: homebrew-list-packages
function homebrew-list-packages() {
    _log-inline-title "Homebrew Package List"
    _log-info "🍺 Installed Homebrew formula:"
    brew list --formula --installed-on-request
    _log-info "🧴 Installed Homebrew casks:"
    brew list --cask
    _log-inline-title "End of Homebrew Package List"
    echo
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
    _log-inline-title "Homebrew Maintenance"

    _log-info "🩺 Checking brew system health..."
    brew doctor || _log-warning "⚠️ brew doctor reported issues"
    _log-success "✓ brew doctor completed"
    echo

    _log-info "⬆️  Updating Homebrew..."
    brew update || return 1
    _log-success "✓ Homebrew updated"
    echo

    _log-info "🔄 Upgrading formulas..."
    brew upgrade --formula || return 1
    _log-success "✓ Upgraded formulas"
    echo

    _log-info "🧴 Upgrading casks..."
    brew upgrade --cask || return 1
    _log-success "✓ Upgraded casks"

    _log-inline-title "End of Homebrew Maintenance"
    echo

    homebrew-clean || return 1

}

# ♻️ Cleans up Homebrew:
# - Autoremoves unused dependencies
# - Cleans up old versions and cache
# - Verifies installed packages
# 💡 Usage: homebrew-clean
function homebrew-clean() {
    _log-inline-title "Homebrew Cleanup"

    _log-info "🧹 Autoremoving unused dependencies..."
    brew autoremove || return 1
    _log-success "✓ Removed unused dependencies"
    echo

    _log-info "🗑️  Cleaning up old versions and cache..."
    brew cleanup || return 1
    _log-success "✓ Cleaned up old versions and cache"
    echo

    _log-info "📦 Verifying installed packages..."
    brew missing || return 1
    _log-success "✓ Verified installed packages"

    _log-inline-title "End of Homebrew Cleanup"
    echo
}

# 🔧 Checks the status of Homebrew on your system
# - Verifies installation
# - Runs 'brew doctor'
# - Checks for outdated packages
# 💡 Usage: homebrew-doctor
function homebrew-doctor() {

    _log-inline-title "Homebrew Doctor"

    _log-info "🔧 Checking Homebrew installation..."

    if ! command -v brew &>/dev/null; then
        _log-warning "⚠️  Homebrew is not installed"
        _log-hint "👉 You can install it with: homebrew-install"
        return 1
    fi
    _log-success "✓ Homebrew is installed"
    echo

    _log-info "🩺 Running 'brew doctor'..."
    brew doctor
    if [[ $? -ne 0 ]]; then
        _log-warning "⚠️  Homebrew reports issues. Run 'brew doctor' manually to review details"
        echo
        return 1
    else
        _log-success "✓ No major issues reported by Homebrew"
        echo
    fi

    _log-info "📦 Checking for brew outdated packages..."
    if [[ -n "$(brew outdated)" ]]; then
        _log-warning "⚠️  You have outdated packages"
        _log-hint "👉 Consider running 'brew outdated' to see which ones"
        _log-hint "👉 To upgrade, use: 'homebrew-maintain'"
        echo
    else
        _log-success "✓ All packages are up to date"
    fi

    _log-inline-title "End of Homebrew Doctor"
    echo
    return 0
}
