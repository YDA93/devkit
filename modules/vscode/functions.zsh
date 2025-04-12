# ------------------------------------------------------------------------------
# 💻 VS Code Project Shortcuts
# ------------------------------------------------------------------------------

# ⚙️ Open VS Code settings.json
# 💡 Usage: code-settings
function code-settings() {
    local SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
    echo "⚙️ Opening VS Code settings..."
    code "$SETTINGS_PATH"
}

# 🧩 List installed VS Code extensions
# 💡 Usage: code-extensions
function code-extensions() {
    echo "🧩 Installed VS Code extensions:"
    code --list-extensions
}

# ♻️ Update all installed VS Code extensions
# 💡 Usage: code-extensions-update
function code-extensions-update() {
    echo "♻️  Updating all VS Code extensions..."
    code --update-extensions
}

# 💾 Fully interactive backup of VS Code extensions with default filename (Zsh-compatible)
# 💡 Usage: code-extensions-backup
function code-extensions-backup() {
    echo "💾 Let's backup your VS Code extensions!"

    # Suggest default filename with timestamp
    local DEFAULT_FILE="vscode-extensions-$(date +%Y-%m-%d).txt"

    echo "📂 Enter the directory to save the backup (default: current directory):"
    read BACKUP_DIR
    BACKUP_DIR="${BACKUP_DIR:-$(pwd)}"

    echo "📄 Enter the backup file name (default: $DEFAULT_FILE):"
    read BACKUP_FILE
    BACKUP_FILE="${BACKUP_FILE:-$DEFAULT_FILE}"

    local BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

    echo "💾 Backing up extensions to: $BACKUP_PATH ..."
    code --list-extensions >"$BACKUP_PATH"

    _log_success "✅ Backup complete at: $BACKUP_PATH"
}

# ♻️ Fully interactive restore of VS Code extensions with default filename (Zsh-compatible)
# 💡 Usage: code-extensions-restore
function code-extensions-restore() {
    echo "♻️ Let's restore your VS Code extensions!"

    local DEFAULT_FILE="vscode-extensions-$(date +%Y-%m-%d).txt"

    echo "📂 Enter the directory of your backup file (default: current directory):"
    read BACKUP_DIR
    BACKUP_DIR="${BACKUP_DIR:-$(pwd)}"

    echo "📄 Enter the backup file name (default: $DEFAULT_FILE):"
    read BACKUP_FILE
    BACKUP_FILE="${BACKUP_FILE:-$DEFAULT_FILE}"

    local BACKUP_PATH="$BACKUP_DIR/$BACKUP_FILE"

    if [[ ! -f "$BACKUP_PATH" ]]; then
        _log_error "❌ Backup file not found at: $BACKUP_PATH"
        return 1
    fi

    echo "♻️ Restoring extensions from: $BACKUP_PATH ..."
    xargs -n1 code --install-extension <"$BACKUP_PATH"

    _log_success "✅ Extensions restored successfully!"
}

# 🧭 Opens a project from $HOME/Desktop/dev in VS Code
# - If no name is provided, lists available projects
# 💡 Usage: code-project <project_name>
function code-project() {
    local BASE_PATH="$HOME/Desktop/dev"
    local PROJECT_NAME=$1 # Get the first argument as project name

    # If no project is provided, list available projects
    if [[ -z "$PROJECT_NAME" ]]; then
        echo "📂 Available projects in $BASE_PATH:"
        ls -1 "$BASE_PATH"
        return 1
    fi

    # Define project path
    local PROJECT_PATH="$BASE_PATH/$PROJECT_NAME"

    # Check if the directory exists
    if [[ -d "$PROJECT_PATH" ]]; then
        echo "🚀 Opening project: $PROJECT_NAME"
        code "$PROJECT_PATH"
    else
        _log_error "❌ Project not found: $PROJECT_PATH"
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
