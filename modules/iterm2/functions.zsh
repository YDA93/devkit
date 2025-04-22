# ------------------------------------------------------------------------------
# 🧩 iTerm2 Installation & Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up iTerm2 with a custom profile and font
# 💡 Usage: iterm2-setup
function iterm2-setup() {
    _log-inline_title "Iterm2 Download"
    _log-info "⬇️ Downloading iTerm2 from brew"
    brew install --cask iterm2 || {
        _log-error "✗ Failed to install iTerm2."
        echo
        return 1
    }
    _log-success "✓ iTerm2 installed successfully."
    _log-inline_title "End of iTerm2 Download"
    echo

    powerlevel10k-setup || return 1

    _log-success "✓ iTerm2 setup completed successfully."

    _log-hint "💡 Please restart both Terminal and iTerm2 to fully apply the changes."
    echo
}

# 🧹 Uninstalls iTerm2 and its profile and font
# 💡 Usage: iterm2-uninstall
function iterm2-uninstall() {
    _log-inline_title "Iterm2 Uninstall"
    _log-info "🧹 Uninstalling iTerm2..."
    brew uninstall --cask iterm2
    _log-success "✓ iTerm2 uninstalled successfully."
    _log-inline_title "End of iTerm2 Uninstall"
    echo

    powerlevel10k-uninstall || return 1

    _log-success "✓ iTerm2 uninstalled successfully."
    echo
}

# ------------------------------------------------------------------------------
# 👤 iTerm2 Theme Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up iTerm2 with a custom dynamic profile and key bindings
# 💡 Usage: iterm2-theme-setup
function iterm2-theme-setup() {
    if [ ! -d "/Applications/iTerm.app" ]; then
        return 0
    fi

    font-install-meslo-nerd || return 1

    _log-info "🖥️  Setting up iTerm2 theme..."

    local source_path="$DEVKIT_MODULES_DIR/iterm2/natural_text_editing.json"
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ ! -f "$source_path" ]]; then
        _log-error "✗ Profile not found: $source_path"
        echo
        return 1
    fi

    mkdir -p "$target_dir" || {
        _log-error "✗ Failed to create iTerm2 DynamicProfiles directory."
        echo
        return 1
    }

    cp "$source_path" "$target_path" || {
        _log-error "✗ Failed to copy profile to: $target_path"
        echo
        return 1
    }

    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "natural-text-editing" || {
        _log-error "✗ Failed to set default iTerm2 profile."
        echo
        return 1
    }

    _log-success "✓ iTerm2 theme installed successfully. Please close and reopen iTerm2 to apply the changes."
    echo
}

# 🧹 Uninstalls iTerm2 Theme
# 💡 Usage: iterm2-theme-uninstall
function iterm2-theme-uninstall() {
    _log-info "🧹 Uninstalling iTerm2 theme..."
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ -f "$target_path" ]]; then
        rm "$target_path" || {
            _log-error "✗ Failed to remove iTerm2 profile: $target_path"
            echo
            return 1
        }
    else
        _log-info "✓ No iTerm2 profile found to remove."
        return 0
    fi

    defaults delete com.googlecode.iterm2 "Default Bookmark Guid"

    _log-success "✓ iTerm2 theme uninstalled successfully."
    echo
}
