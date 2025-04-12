# 🔧 Logs a step with visible progress/status indicators
# 💡 Usage: _log-update-step "Label" <command>
function _log-update-step() {
    local name="$1" # First argument: display name for logging
    shift           # Remaining arguments: command to execute

    echo "\n--------------------------------------------------"
    echo -e "🔧 Starting update: $name"
    echo "--------------------------------------------------"

    # Run the update command(s)
    if "$@"; then
        echo "--------------------------------------------------"
        echo "✅ Update successful: $name"
    else
        echo "--------------------------------------------------"
        echo "❌ Update failed: $name"
    fi

    echo "--------------------------------------------------"
}

# 🧪 Runs a command, aborts if it fails, and prints custom messages
# 💡 Usage: _run-or-abort "Label" "Success Msg" <command>
function _run-or-abort() {
    local description="$1"
    local success_msg="$2"
    shift 2

    echo "$description..."
    "$@"
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo "❌ Failed: $description"
        return $exit_code
    fi
    if [ -n "$success_msg" ]; then
        echo "$success_msg"
        echo ""
    fi
}

# 🛑 Asks the user for confirmation before continuing
# 💡 Usage: _confirm-or-abort "Prompt?" [--quiet]
function _confirm-or-abort() {
    local message="$1"
    shift # Remove the first argument (message) from the list

    # Check if --quiet flag is present
    for arg in "$@"; do
        if [[ "$arg" == "--quiet" ]]; then
            return 0
        fi
    done

    local CONFIRM=""
    while true; do
        # Properly print message first, then prompt on next line
        printf "%s\n(yes/no): " "$message"

        if [[ -n "$BASH_VERSION" ]]; then
            read CONFIRM
        else
            read "? " CONFIRM
        fi

        case "$CONFIRM" in
        yes)
            return 0
            ;;
        no)
            echo "Aborting action."
            return 1
            ;;
        *)
            echo "❌ Please type 'yes' or 'no'."
            ;;
        esac
    done
}

function _read_setting_from_file() {
    local key=$1
    local file=$2
    grep "^$key=" "$file" | cut -d '"' -f2
}

function _show_app_selection_menu() {
    local type=$1
    shift
    local apps=("$@")
    local choices=()
    local selected=()

    for app in "${apps[@]}"; do
        local app_key=""
        if [[ "$type" == "mas" ]]; then
            IFS='|' read -r app_id app_name <<<"$app"
            choices+=("$app_id|$app_name")
            app_key="mas_install_$app_id"
        else
            choices+=("$app")
            app_key="${type}_install_${app//-/_}"
        fi

        if grep -q "^$app_key=\"y\"" "$cloned_settings_file"; then
            selected+=("$app")
        fi
    done

    local header="🛍️  Select $type apps to install (use spacebar to select, enter to confirm):"
    local selected_apps=$(gum choose --no-limit --header="$header" "${choices[@]}" --selected "$(
        IFS=,
        echo "${selected[*]}"
    )")

    # ✅ Zsh-compatible array assignment
    eval "selected_${type}_apps=(\${(@f)selected_apps})"

}

function _append_app_selections_to_settings() {
    local type=$1
    shift
    local apps=("$@")
    eval "local selected_apps=(\"\${selected_${type}_apps[@]}\")"

    for app in "${apps[@]}"; do
        local app_key=""
        local match_found="n"
        local comparable_app="${app// /}" # Remove all spaces

        if [[ "$type" == "mas" ]]; then
            IFS='|' read -r app_id app_name <<<"$app"
            app_key="mas_install_$app_id"
            comparable_app="${app_id}|${app_name// /}" # Format as it appears from selection
        else
            app_key="${type}_install_${app//-/_}" # Standardize key
            comparable_app="${app// /}"
        fi

        for selected in "${selected_apps[@]}"; do
            local clean_selected="${selected// /}" # Clean up spaces from the selected items
            if [[ "$clean_selected" == "$comparable_app" ]]; then
                match_found="y"
                break
            fi
        done

        echo "$app_key=\"$match_found\"" >>"$settings_file"
    done
    echo "" >>"$settings_file"
}

# 🖨️ Prints a stylized section title to terminal
# 💡 Usage: _print_section_title "Title"
function _print_section_title() {
    local title="$1"
    local line_length=$((${#title} + 4))
    local border=$(printf '─%.0s' $(seq 1 $line_length))

    echo
    echo "┌$border┐"
    echo "│ $title"
    echo "└$border┘"
}

# 🔄 Checks for and installs macOS updates
# 💡 Usage: _check-software-updates
function _check-software-updates() {
    # 🛠️ Installs all available macOS software updates (system + security)
    echo "🔍 Checking for macOS software updates..."

    # Check for available software updates
    available_updates=$(softwareupdate -l 2>&1)

    if echo "$available_updates" | grep -q "No new software available"; then
        echo "✅ No updates available. Skipping installation."
        return 0
    else
        echo "⬇️  Updates available. Installing now..."
        softwareupdate -ia --verbose
        echo "✅ Updates installed successfully."
        echo "🔁 A system restart may be required to complete installation."
        echo "⚠️  Please reboot your Mac and then re-run: devkit-pc-setup"
        return 1 # Signal that a reboot is needed
    fi
}
