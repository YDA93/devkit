# 🖥️ Sets the Terminal theme and font to "MesloLGS NF" and applies the "Cool Night" theme
# 💡 Usage: terminal-theme-setup
function terminal-theme-setup() {
    font-install-meslo-nerd || return 1
    _log-info "🖥️  Applying Terminal theme and font: 'MesloLGS NF'..."
    local THEME_FILE="$DEVKIT_MODULES_DIR/iterm2/cool-night.terminal"

    _log-info "🎨 Importing Terminal theme \"$THEME_FILE\"..."
    open "$THEME_FILE" || {
        _log-error "❌ Failed to open Terminal theme file: $THEME_FILE"
        return 1
    }
    sleep 1 # Give Terminal time to register the new theme

    local THEME_NAME
    THEME_NAME=$(basename "$THEME_FILE" .terminal)

    _log-info "📌 Setting \"$THEME_NAME\" as default and startup profile..."
    defaults write com.apple.Terminal "Default Window Settings" -string "$THEME_NAME" || {
        _log-error "❌ Failed to set Default Window Settings."
        return 1
    }
    defaults write com.apple.Terminal "Startup Window Settings" -string "$THEME_NAME" || {
        _log-error "❌ Failed to set Startup Window Settings."
        return 1
    }

    # Close the current Terminal window quietly
    (osascript -e 'tell application "Terminal" to close first window' &>/dev/null &)
    sleep 1

    _log-success "🎉 Terminal theme and font successfully applied!"
    _log-hint "💡 Please restart macOS Terminal and iTerm2 to apply the full changes."
}

# 🧹 Reset terminal to factory defaults
# 💡 Usage: terminal-factory-reset
function terminal-factory-reset() {
    local PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
    local SAVED_STATE="$HOME/Library/Saved Application State/com.apple.Terminal.savedState"

    _log-info "🗑️ Removing Terminal preferences..."
    rm -f "$PLIST"

    _log-info "🧼 Removing saved Terminal window state..."
    rm -rf "$SAVED_STATE"

    _log-success "✅ Terminal has been reset to factory defaults."
    _log-hint "💡 Please restart macOS Terminal to apply the full changes."
}

# ------------------------------------------------------------------------------
# 🧩 Font Integration for Powerlevel10k
# ------------------------------------------------------------------------------

# 🖥️ Checks if Meslo Nerd Font is installed
# 💡 Usage: font-is-installed-meslo-nerd
function font-is-installed-meslo-nerd() {
    local FONT_DIR="$HOME/Library/Fonts"
    local FILES=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

    for FILE in "${FILES[@]}"; do
        if [[ ! -f "$FONT_DIR/$FILE" ]]; then
            return 1 # Returns 1 if any file is missing
        fi
    done

    return 0 # Returns 0 if all files are found
}

# 🖥️ Installs the Meslo Nerd Font for Powerlevel10k
# 💡 Usage: font-install-meslo-nerd
function font-install-meslo-nerd() {
    _log-info "⬇️  Installing Meslo Nerd Font for Powerlevel10k..."
    local FONT_DIR="$HOME/Library/Fonts"
    local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local FILES=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

    # Early return if all fonts already exist by using the is_font_installed function
    if font-is-installed-meslo-nerd; then
        _log-success "✓ Meslo Nerd Font is already fully installed. Skipping download."
        echo
        return 0
    fi

    mkdir -p "$FONT_DIR" || {
        _log-error "✗ Failed to create font directory: $FONT_DIR"
        return 1
    }

    for FILE in "${FILES[@]}"; do
        local DEST="$FONT_DIR/$FILE"
        if [[ -f "$DEST" ]]; then
            _log-success "✓ Font already installed: $FILE"
        else
            echo "⬇️  Downloading: $FILE"
            if curl -fsSL "$BASE_URL/${FILE// /%20}" -o "$DEST"; then
                _log-success "✓ Installed: $FILE"
            else
                _log-error "✗ Failed to download: $FILE"
                return 1
            fi
        fi
    done

    _log-success "✓ Meslo Nerd Font installed successfully."
    echo
}

# 🧹 Uninstalls the Meslo Nerd Font for Powerlevel10k
# 💡 Usage: font-uninstall-meslo-nerd
function font-uninstall-meslo-nerd() {
    _log-info "🧹 Uninstalling Meslo Nerd Font for Powerlevel10k..."
    local FONT_DIR="$HOME/Library/Fonts"
    local FILES=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

    for FILE in "${FILES[@]}"; do
        local DEST="$FONT_DIR/$FILE"
        if [[ -f "$DEST" ]]; then
            rm "$DEST" &&
                _log-success "✓ Uninstalled: $FILE" ||
                _log-error "✗ Failed to uninstall: $FILE"
        else
            _log-success "✓ Font not found: $FILE"
        fi
    done

    _log-success "✓ Meslo Nerd Font uninstalled successfully."
    echo
}
