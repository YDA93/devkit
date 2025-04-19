# 🖥️ Sets the Terminal theme and font to "MesloLGS NF" and applies the "Cool Night" theme
# 💡 Usage: terminal-theme-setup
function terminal-theme-setup() {
    font-install-meslo-nerd || return 1
    _log_info "🖥️  Applying Terminal theme and font: 'MesloLGS NF'..."
    local FONT_NAME="MesloLGS NF"
    local PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
    local THEME_FILE="$DEVKIT_MODULES_DIR/iterm2/cool-night.terminal"

    _log_info "📄 Ensuring Terminal plist is in XML format..."
    plutil -convert xml1 "$PLIST" 2>/dev/null || {
        _log_error "❌ Failed to convert Terminal plist to XML format."
        return 1
    }

    _log_info "🎨 Importing Terminal theme \"$THEME_FILE\"..."
    open "$THEME_FILE" || {
        _log_error "❌ Failed to open Terminal theme file: $THEME_FILE"
        return 1
    }
    sleep 1 # Give Terminal time to register the new theme

    local THEME_NAME
    THEME_NAME=$(basename "$THEME_FILE" .terminal)

    _log_info "🎛️  Configuring 'Use Option as Meta key' for profile \"$THEME_NAME\"..."
    local SAFE_THEME_NAME
    SAFE_THEME_NAME=$(echo "$THEME_NAME" | sed "s/'/\\\\'/g")

    if /usr/libexec/PlistBuddy -c "Print :'Window Settings':'$SAFE_THEME_NAME':useOptionAsMetaKey" "$PLIST" &>/dev/null; then
        _log_info "🔁 Key 'useOptionAsMetaKey' found. Updating to 'true'..."
        /usr/libexec/PlistBuddy -c "Set :'Window Settings':'$SAFE_THEME_NAME':useOptionAsMetaKey true" "$PLIST" || {
            _log_error "❌ Failed to update 'useOptionAsMetaKey'."
            return 1
        }
    else
        _log_info "➕ Key 'useOptionAsMetaKey' not found. Adding it..."
        /usr/libexec/PlistBuddy -c "Add :'Window Settings':'$SAFE_THEME_NAME':useOptionAsMetaKey bool true" "$PLIST" || {
            _log_error "❌ Failed to add 'useOptionAsMetaKey'."
            return 1
        }
    fi

    _log_info "🔠 Applying font \"$FONT_NAME\" to \"$THEME_NAME\"..."
    osascript <<EOF
tell application "Terminal"
    set profileSettings to settings set "$THEME_NAME"
    set font name of profileSettings to "$FONT_NAME"
    repeat with w in windows
    try
        if (name of current settings of w) is "$THEME_NAME" then
            close w
        end if
    end try
    end repeat
end tell
EOF

    _log_info "📌 Setting \"$THEME_NAME\" as default and startup profile..."
    defaults write com.apple.Terminal "Default Window Settings" -string "$THEME_NAME" || {
        _log_error "❌ Failed to set Default Window Settings."
        return 1
    }
    defaults write com.apple.Terminal "Startup Window Settings" -string "$THEME_NAME" || {
        _log_error "❌ Failed to set Startup Window Settings."
        return 1
    }
    sleep 1
    _log_success "🎉 Terminal theme and font successfully applied!"
    _log_hint "💡 Please restart macOS Terminal and iTerm2 to apply the full changes."
    echo
}

# 🧹 Reset terminal to factory defaults
# 💡 Usage: terminal-factory-reset
function terminal-factory-reset() {
    local PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"
    local SAVED_STATE="$HOME/Library/Saved Application State/com.apple.Terminal.savedState"

    _log_info "🗑️ Removing Terminal preferences..."
    rm -f "$PLIST"

    _log_info "🧼 Removing saved Terminal window state..."
    rm -rf "$SAVED_STATE"

    _log_success "✅ Terminal has been reset to factory defaults."
    _log_hint "💡 Please restart macOS Terminal to apply the full changes."
}

# ------------------------------------------------------------------------------
# 🧩 Font Integration for Powerlevel10k
# ------------------------------------------------------------------------------

# 🖥️ Installs the Meslo Nerd Font for Powerlevel10k
# 💡 Usage: font-install-meslo-nerd
function font-install-meslo-nerd() {
    _log_info "⬇️  Installing Meslo Nerd Font for Powerlevel10k..."
    local FONT_DIR="$HOME/Library/Fonts"
    local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local FILES=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

    # Early return if all fonts already exist
    local all_exist=true
    for FILE in "${FILES[@]}"; do
        if [[ ! -f "$FONT_DIR/$FILE" ]]; then
            all_exist=false
            break
        fi
    done

    if [[ "$all_exist" == true ]]; then
        _log_success "✓ Meslo Nerd Font is already fully installed. Skipping download."
        echo
        return 0
    fi

    mkdir -p "$FONT_DIR" || {
        _log_error "✗ Failed to create font directory: $FONT_DIR"
        return 1
    }

    for FILE in "${FILES[@]}"; do
        local DEST="$FONT_DIR/$FILE"
        if [[ -f "$DEST" ]]; then
            _log_success "✓ Font already installed: $FILE"
        else
            echo "⬇️  Downloading: $FILE"
            if curl -fsSL "$BASE_URL/${FILE// /%20}" -o "$DEST"; then
                _log_success "✓ Installed: $FILE"
            else
                _log_error "✗ Failed to download: $FILE"
                return 1
            fi
        fi
    done

    _log_success "✓ Meslo Nerd Font installed successfully."
    echo
}

# 🧹 Uninstalls the Meslo Nerd Font for Powerlevel10k
# 💡 Usage: font-uninstall-meslo-nerd
function font-uninstall-meslo-nerd() {
    _log_info "🧹 Uninstalling Meslo Nerd Font for Powerlevel10k..."
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
                _log_success "✓ Uninstalled: $FILE" ||
                _log_error "✗ Failed to uninstall: $FILE"
        else
            _log_success "✓ Font not found: $FILE"
        fi
    done

    _log_success "✓ Meslo Nerd Font uninstalled successfully."
    echo
}
