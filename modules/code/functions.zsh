# ------------------------------------------------------------------------------
# 💻 VS Code Project Shortcuts
# ------------------------------------------------------------------------------

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
        echo "❌ Project not found: $PROJECT_PATH"
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
