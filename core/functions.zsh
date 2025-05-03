# ------------------------------------------------------------------------------
# 🧰 DevKit Support Utilities
# ------------------------------------------------------------------------------

# 🚀 Sets up full devkit environment (tools, SDKs, configs)
# 💡 Usage: devkit-setup [--quiet]
function devkit-setup() {

    local log_dir="$DEVKIT_ROOT/logs/devkit/setup"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    # {
    _confirm-or-abort "Are you sure you want to set up your devkit environment?" "$@" || return 1

    # Welcome message
    gum style --border double --margin "2 4" --padding "1 4" --bold --align center --foreground 39 "👋 Welcome to DevKit CLI Setup!

    🚀 We’ll prepare your system and guide you step by step.
    Sit tight while we set everything up for you."

    local total_steps=11
    local step=1

    _log-step update $step $total_steps "DevKit CLI" devkit-cli-update || return 1
    ((step++))

    _log-step setup $step $total_steps "DevKit Settings" devkit-settings-setup || return 1
    ((step++))

    _log-step setup $step $total_steps "Software Updates Check" devkit-macos-update || return 1
    ((step++))
    _log-step setup $step $total_steps "Git Configuration" git-setup || return 1
    ((step++))
    _log-step setup $step $total_steps "Homebrew and Packages" homebrew-setup || return 1
    ((step++))

    _confirm-or-abort "🧩 Configure apps like VS Code and press Enter to continue." "$@" || return 1

    if _devkit-settings get bool use_cool_night_theme; then
        _log-step setup $step $total_steps "Terminal Theme" terminal-theme-setup || return 1
        ((step++))
        _log-step setup $step $total_steps "iTerm2 Theme" iterm2-theme-setup || return 1
        ((step++))
    else
        _log-step setup $step $total_steps "Terminal Theme" _log-info "Skipping Terminal Theme setup" || return 1
        ((step++))
        _log-step setup $step $total_steps "iTerm2 Theme" _log-info "Skipping iTerm2 Theme setup" || return 1
        ((step++))
    fi

    _log-step setup $step $total_steps "NPM Setup" npm-setup || return 1
    ((step++))
    _log-step setup $step $total_steps "Mac App Store Applications" mas-setup || return 1
    ((step++))
    _log-step setup $step $total_steps "Xcode and Command Line Tools" xcode-setup || return 1
    ((step++))
    _log-step setup $step $total_steps "Flutter Android SDK Setup" flutter-android-sdk-setup || return 1
    ((step++))

    gum style --border double --padding "1 4" --margin "2 0" --foreground 42 --bold --align center "✓ DevKit environment setup complete!"

    # } 2>&1 | tee -a "$log_file"

}

# 🔄 Updates devkit tools (Flutter, Homebrew, gcloud, NPM, etc.)
# 💡 Usage: devkit-update
function devkit-update() {
    local log_dir="$DEVKIT_ROOT/logs/devkit/update"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    # {
    local total_steps=10
    local step=1
    gum style --border double --margin "1 4" --padding "1 4" --bold --align center --foreground 39 "🔄 Running DevKit Update

    We’ll keep things fast and make sure you're up to date."

    _log-step update $step $total_steps "DevKit CLI" devkit-cli-update || return
    ((step++))
    _log-step update $step $total_steps "Homebrew and Packages" homebrew-maintain || return 1
    ((step++))
    _log-step update $step $total_steps "pip (Python)" bash -c 'pip3 install --upgrade pip setuptools wheel' || return 1
    ((step++))
    _log-step update $step $total_steps "gcloud CLI" gcloud components update --quiet || return 1
    ((step++))
    _log-step update $step $total_steps "Flutter SDK" flutter upgrade --force || return 1
    ((step++))
    _log-step update $step $total_steps "NPM and Dependencies" bash -c 'npm install -g npm@latest; npm-check -g -u' || return 1
    ((step++))
    _log-step update $step $total_steps "CocoaPods" pod repo update || return 1
    ((step++))
    _log-step update $step $total_steps "Rosetta (Intel Compatibility)" softwareupdate --install-rosetta --agree-to-license || return 1
    ((step++))
    _log-step update $step $total_steps "VS Code Extensions" code-extensions-update || return 1
    ((step++))
    _log-step update $step $total_steps "App Store Apps (via mas-cli)" mas-maintain || return 1

    gum style --border rounded --margin "1 2" --padding "1 4" --bold --align center --foreground 42 "✓ DevKit Update Complete!

    Your environment is fresh and ready to go."

    # } 2>&1 | tee -a "$log_file"
}

# 🧪 Full diagnostic on dev environment (gcloud, Xcode, Firebase, etc.)
# 💡 Usage: devkit-doctor
function devkit-doctor() {
    local log_dir="$DEVKIT_ROOT/logs/devkit/doctor"
    mkdir -p "$log_dir"
    local log_file="$log_dir/$(date +'%Y%m%d%H%M%S').log"

    # {

    # Check for missing tools
    devkit-tools-check || return 1

    # Homebrew Checks
    homebrew-doctor || return 1

    # Xcode Checks
    xcode-doctor || return 1

    # Git Checks
    git-doctor || return 1

    # PostgreSQL Checks
    postgres-doctor || return 1

    # NPM Checks
    npm-doctor || return 1

    # Firebase Checks
    firebase-doctor || return 1

    # Shell
    _log-info "🔹 Checking default shell..."
    [[ "$SHELL" == *"zsh" ]] && _log-success "✓ Default shell is set to zsh" ||
        _log-warning "⚠️  Zsh is not your default shell. Set it with: chsh -s $(which zsh)"

    echo

    # PATH Sanity
    _log-info "🔹 Checking if /usr/local/bin is included in PATH"
    echo "$PATH" | grep -q "/usr/local/bin" &&
        _log-success "✓ /usr/local/bin is in PATH" ||
        _log-warning "⚠️  /usr/local/bin is missing from PATH"

    echo

    # } 2>&1 | tee -a "$log_file"
}
