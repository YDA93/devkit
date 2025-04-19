# ------------------------------------------------------------------------------
# 💻 VS Code Project Shortcuts
# ------------------------------------------------------------------------------

# ⚙️ Open VS Code settings.json
# 💡 Usage: code-settings
function code-settings() {
    local SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
    _log_info "⚙️ Opening VS Code settings..."
    code "$SETTINGS_PATH"
}

# 🧩 List installed VS Code extensions
# 💡 Usage: code-extensions
function code-extensions() {
    _log_info "🧩 Installed VS Code extensions:"
    code --list-extensions
}

# ♻️ Update all installed VS Code extensions
# 💡 Usage: code-extensions-update
function code-extensions-update() {
    _log_info "♻️  Updating all VS Code extensions..."
    code --update-extensions || {
        _log_error "✗ Failed to update extensions. Please check your VS Code installation."
        return 1
    }
    _log_success "✓ Extensions updated successfully!"
    echo
}

# 💾 Fully interactive backup of VS Code extensions with default filename (Zsh-compatible)
# 💡 Usage: code-extensions-backup
function code-extensions-backup() {
    gum style --border normal --margin "1 2" --padding "1 2" --foreground 212 --bold "💾 Let's backup your VS Code extensions!"

    # Suggest default filename with timestamp
    local DEFAULT_FILE="vscode-extensions-$(date +%Y-%m-%d).txt"

    # Prompt for backup directory
    BACKUP_DIR=$(gum input --placeholder "$(pwd)" --prompt "📂 Enter the directory to save the backup:")
    BACKUP_DIR="${BACKUP_DIR:-$(pwd)}"

    # Prompt for backup file name
    BACKUP_FILE=$(gum input --placeholder "$DEFAULT_FILE" --prompt "📄 Enter the backup file name:")
    BACKUP_FILE="${BACKUP_FILE:-$DEFAULT_FILE}"

    local BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

    # Confirm before proceeding
    if ! gum confirm "💾 Confirm backup to: $BACKUP_PATH ?"; then
        _log_error "✗ Backup cancelled."
        return 1
    fi

    # Perform backup with spinner
    gum spin --spinner dot --title "Backing up extensions..." -- \
        code --list-extensions >"$BACKUP_PATH"

    # Success message
    _log_success "✓ Backup complete at: $BACKUP_PATH"
}

# ♻️ Fully interactive restore of VS Code extensions with default filename (Zsh-compatible)
# 💡 Usage: code-extensions-restore
function code-extensions-restore() {
    gum style --border normal --margin "1 2" --padding "1 2" --foreground 212 --bold "♻️ Let's restore your VS Code extensions!"

    local DEFAULT_FILE="vscode-extensions-$(date +%Y-%m-%d).txt"

    # Prompt for backup directory
    BACKUP_DIR=$(gum input --placeholder "$(pwd)" --prompt "📂 Enter the directory of your backup file:")
    BACKUP_DIR="${BACKUP_DIR:-$(pwd)}"

    # Prompt for backup file name
    BACKUP_FILE=$(gum input --placeholder "$DEFAULT_FILE" --prompt "📄 Enter the backup file name:")
    BACKUP_FILE="${BACKUP_FILE:-$DEFAULT_FILE}"

    local BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

    # Validate backup file exists
    if [[ ! -f "$BACKUP_PATH" ]]; then
        _log_error "✗ Backup file not found at: $BACKUP_PATH"
        return 1
    fi

    _log_info "♻️ Restoring extensions from: $BACKUP_PATH ..."
    xargs -n1 code --install-extension <"$BACKUP_PATH"

    _log_success "✓ Extensions restored successfully!"
}

# 🧭 Opens a project from $HOME/Desktop/dev in VS Code
# - If no name is provided, lists available projects
# 💡 Usage: code-project <project_name>
function code-project() {
    local BASE_PATH="$HOME/Desktop/dev"
    local PROJECT_NAME=$1 # Get the first argument as project name

    # If no project is provided, list available projects
    if [[ -z "$PROJECT_NAME" ]]; then
        _log_info "📂 Available projects in $BASE_PATH:"
        ls -1 "$BASE_PATH"
        return 1
    fi

    # Define project path
    local PROJECT_PATH="$BASE_PATH/$PROJECT_NAME"

    # Check if the directory exists
    if [[ -d "$PROJECT_PATH" ]]; then
        _log_info "🚀 Opening project: $PROJECT_NAME"
        code "$PROJECT_PATH"
    else
        _log_error "✗ Project not found: $PROJECT_PATH"
        return 1
    fi
}

# 🧠 Provides tab completion for `code-project` based on available project names
# 💡 Auto-attached to code-project
function _code-project-completions() {
    local BASE_PATH="$HOME/Desktop/dev"
    COMPREPLY=($(compgen -W "$(ls -1 "$BASE_PATH")" -- "${COMP_WORDS[1]}"))
}

# 🧩 Enables tab completion for `code-project`
# 💡 Internal setup – no direct usage
complete -F _code-project-completions code-project

# 🖥️ Sets the Powerlevel10k terminal font to "MesloLGS NF"
# 💡 Usage: code-font-set
function code-font-set() {
    if [ ! -d "/Applications/Visual Studio Code.app" ]; then
        return 0
    fi

    _log_info "🖥️  Setting Powerlevel10k terminal font to 'MesloLGS NF'..."
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
# 💡 Usage: code-font-unset
function code-font-unset() {
    if [ ! -d "/Applications/Visual Studio Code.app" ]; then
        return 0
    fi
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
