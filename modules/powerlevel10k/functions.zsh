# ------------------------------------------------------------------------------
# 🎨 Powerlevel10k Installation & Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up Powerlevel10k with a custom configuration
# 💡 Usage: powerlevel10k-setup
function powerlevel10k-setup() {
    _log_inline_title "Powerlevel10k Download"
    _log_info "⬇️ Downloading powerlevel10k from brew"
    brew install powerlevel10k || {
        _log_error "✗ Failed to install powerlevel10k."
        echo
        return 1
    }
    _log_success "✓ Powerlevel10k installed successfully."
    _log_inline_title "End of Powerlevel10k Download"
    echo

    _log_inline_title "Powerlevel10k Font Install"
    powerlevel10k-font-install || return 1
    _log_inline_title "End of Powerlevel10k Font Install"
    echo

    _log_inline_title "Powerlevel10k VS Code Font Set"
    powerlevel10k-vscode-font-set || return 1
    _log_inline_title "End of Powerlevel10k VS Code Font Set"
    echo

}

# 🧹 Uninstalls Powerlevel10k
# 💡 Usage: powerlevel10k-uninstall
function powerlevel10k-uninstall() {
    _log_inline_title "Powerlevel10k Uninstall"
    _log_info "🧹 Uninstalling Powerlevel10k..."
    brew uninstall powerlevel10k
    _log_success "✓ Powerlevel10k uninstalled successfully."
    _log_inline_title "End of Powerlevel10k Uninstall"
    echo

    _log_inline_title "Powerlevel10k Font Uninstall"
    powerlevel10k-font-uninstall || return 1
    _log_inline_title "End of Powerlevel10k Font Uninstall"
    echo

    _log_inline_title "Powerlevel10k VS Code Font Unset"
    powerlevel10k-vscode-font-unset || return 1
    _log_inline_title "End of Powerlevel10k VS Code Font Unset"
    echo

    _log_success "✓ Powerlevel10k uninstalled successfully."
    echo
}

# ------------------------------------------------------------------------------
# 🧩 Font Integration for Powerlevel10k
# ------------------------------------------------------------------------------

# 🖥️ Sets the Powerlevel10k terminal font to "MesloLGS NF"
# 💡 Usage: powerlevel10k-vscode-font-set
function powerlevel10k-vscode-font-set() {
    _log_info "🖥️ Setting Powerlevel10k terminal font to 'MesloLGS NF'..."
    SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
    TMP_FILE="${SETTINGS_FILE}.tmp"
    DESIRED_FONT="MesloLGS NF"

    # Check if the file exists and is valid JSON
    if ! jq empty "$SETTINGS_FILE" 2>/dev/null; then
        _log_error "✗ settings.json contains invalid JSON (e.g., trailing commas or syntax errors)."
        _log_hint "👉 Open it in VS Code to fix:"
        _log_hint "   code \"$SETTINGS_FILE\""
        echo
        return 1
    fi

    # Only update if the value differs
    CURRENT_FONT=$(jq -r '."terminal.integrated.fontFamily"' "$SETTINGS_FILE")
    if [[ "$CURRENT_FONT" == "$DESIRED_FONT" ]]; then
        _log_success "✓ Font already set to \"$DESIRED_FONT\". No changes made."
        echo
        return 0
    fi

    # Update safely
    jq --arg font "$DESIRED_FONT" '."terminal.integrated.fontFamily" = $font' "$SETTINGS_FILE" >"$TMP_FILE" &&
        mv "$TMP_FILE" "$SETTINGS_FILE" &&
        _log_success "✓ terminal.integrated.fontFamily set to \"$DESIRED_FONT\"" && echo
}

# 🧹 Unsets the Powerlevel10k terminal font in VS Code settings
# 💡 Usage: powerlevel10k-vscode-font-unset
function powerlevel10k-vscode-font-unset() {
    _log_info "🧹 Unsetting Powerlevel10k terminal font in VS Code settings..."
    SETTINGS_FILE="$HOME/Library/Application Support/Code/User/settings.json"
    TMP_FILE="${SETTINGS_FILE}.tmp"

    # Check if the file exists and is valid JSON
    if ! jq empty "$SETTINGS_FILE" 2>/dev/null; then
        _log_error "✗ settings.json contains invalid JSON (e.g., trailing commas or syntax errors)."
        _log_hint "👉 Open it in VS Code to fix:"
        _log_hint "   code \"$SETTINGS_FILE\""
        echo
        return 1
    fi

    # Only update if the value differs
    CURRENT_FONT=$(jq -r '."terminal.integrated.fontFamily"' "$SETTINGS_FILE")
    if [[ "$CURRENT_FONT" != "null" ]]; then
        jq 'del(."terminal.integrated.fontFamily")' "$SETTINGS_FILE" >"$TMP_FILE" &&
            mv "$TMP_FILE" "$SETTINGS_FILE" &&
            _log_success "✓ terminal.integrated.fontFamily removed"
    else
        _log_success "✓ Font already unset. No changes made."
    fi
    echo
}

# 🖥️ Installs the Meslo Nerd Font for Powerlevel10k
# 💡 Usage: powerlevel10k-font-install
function powerlevel10k-font-install() {
    _log_info "⬇️  Installing Meslo Nerd Font for Powerlevel10k..."
    local FONT_DIR="$HOME/Library/Fonts"
    local BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
    local FILES=(
        "MesloLGS NF Regular.ttf"
        "MesloLGS NF Bold.ttf"
        "MesloLGS NF Italic.ttf"
        "MesloLGS NF Bold Italic.ttf"
    )

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
# 💡 Usage: powerlevel10k-font-uninstall
function powerlevel10k-font-uninstall() {
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

# Set the Terminal font for the current default profile
function powerlevel10k-terminal-font-set() {
    _log_info "🖥️ Setting Terminal font to 'MesloLGS NF'..."
    # Font to apply — make sure it's installed on the system (e.g., via Nerd Fonts)
    local FONT_NAME="MesloLGS NF"
    local PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"

    # Convert the plist to XML so we can read it reliably
    _log_info "📦 Converting Terminal plist to XML (if needed)..."
    plutil -convert xml1 "$PLIST" 2>/dev/null

    # Get the current default profile
    _log_info "🔍 Determining the default Terminal profile..."
    local PROFILE
    PROFILE=$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null)

    # If the profile wasn't found, abort
    if [[ -z "$PROFILE" ]]; then
        _log_error "✗ Could not determine the default Terminal profile."
        echo
        return 1
    fi
    _log_info "🔍 Current default profile: $PROFILE"

    _log_info "🎹 Enabling 'Use Option as Meta key' for profile \"$PROFILE\"..."

    # Escape single quotes inside $PROFILE (just in case)
    SAFE_PROFILE=$(echo "$PROFILE" | sed "s/'/\\\\'/g")

    # Convert to XML to ensure we can safely read keys
    plutil -convert xml1 "$PLIST" 2>/dev/null

    # Check if key exists
    if /usr/libexec/PlistBuddy -c "Print :'Window Settings':'$SAFE_PROFILE':useOptionAsMetaKey" "$PLIST" &>/dev/null; then
        _log_info "🔄 'useOptionAsMetaKey' already exists. Updating to true..."
        /usr/libexec/PlistBuddy -c "Set :'Window Settings':'$SAFE_PROFILE':useOptionAsMetaKey true" "$PLIST"
    else
        _log_info "➕ Adding 'useOptionAsMetaKey' as a new key..."
        /usr/libexec/PlistBuddy -c "Add :'Window Settings':'$SAFE_PROFILE':useOptionAsMetaKey bool true" "$PLIST"
    fi

    # Apply the font and enable "Use Option as Meta key"
    _log_info "🛠️  Setting font \"$FONT_NAME\" and enabling Option-as-Meta for Profile \"$PROFILE\"..."
    osascript <<EOF
tell application "Terminal"
    set profileSettings to settings set "$PROFILE"
    set font name of profileSettings to "$FONT_NAME"
end tell
EOF

    # Set as both default and startup profile (safe redundancy)
    _log_info "📌 Confirming \"$PROFILE\" as default and startup profile..."
    defaults write com.apple.Terminal "Default Window Settings" -string "$PROFILE"
    defaults write com.apple.Terminal "Startup Window Settings" -string "$PROFILE"

    _log_success "✓ All done! Font updated and Option-as-Meta enabled."
    _log_hint "👉 Restart Terminal to see the changes."
}
