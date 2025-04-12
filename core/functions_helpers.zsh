# 🔧 Logs a step with visible progress/status indicators (Gum, no spinner)
# 💡 Usage: _log-update-step "Label" <command>
function _log-update-step() {
    local name="$1"
    shift

    gum style --border rounded --padding "0 2" --margin "1 0" --foreground 33 --bold "🔧 Updating $name"

    if "$@"; then
        echo
        gum style --border rounded --padding "0 2" --margin "1 0" --foreground 42 --bold "✅ Update complete: $name"
    else
        echo
        gum style --border rounded --padding "0 2" --margin "1 0" --foreground 196 --bold "❌ Update failed: $name"
    fi
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
        _log_error "❌ Failed: $description"
        return $exit_code
    fi
    if [ -n "$success_msg" ]; then
        _log_success "$success_msg"
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

    if gum confirm "$message"; then
        return 0
    else
        echo "Aborting action."
        return 1
    fi
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

# 🖨️ Prints a stylized section title to terminal (Gum version)
# 💡 Usage: _print_section_title "Title"
function _print_section_title() {
    local title="$1"

    gum style \
        --border normal \
        --padding "0 2" \
        --margin "1 0" \
        --bold \
        --foreground 33 \
        "$title"
}

# 🔄 Checks for and installs macOS updates
# 💡 Usage: _check-software-updates
function _check-software-updates() {
    # 🛠️ Installs all available macOS software updates (system + security)
    _log_info "🔍 Checking for macOS software updates..."

    # Check for available software updates
    available_updates=$(softwareupdate -l 2>&1)

    if echo "$available_updates" | grep -q "No new software available"; then
        _log_success "✅ No updates available. Skipping installation."
        return 0
    else
        _log_info "⬇️  Updates available. Installing now..."
        softwareupdate -ia --verbose
        _log_success "✅ Updates installed successfully."
        _log_info "🔁 A system restart may be required to complete installation."
        _log_warning "⚠️  Please reboot your Mac and then re-run: devkit-pc-setup"
        return 1 # Signal that a reboot is needed
    fi
}

# ✅ Success message
function _log_success() {
    gum style --bold --foreground 42 "$@"
}

# ❌ Error message
function _log_error() {
    gum style --bold --foreground 196 "$@"
}

# ⚠️ Warning message
function _log_warning() {
    gum style --bold --foreground 220 "$@"
}

# ℹ️ Info message
function _log_info() {
    gum style --foreground 33 "$@"
}

# 💡 Hint or tip
function _log_hint() {
    gum style --foreground 245 "$@"
}

# 🏁 Section separator
function _log_separator() {
    gum style --foreground 245 "────────────────────────────────────────"
}

# 🖨️ Section title (without box)
function _log_title() {
    gum style --bold --foreground 51 "$@"
}

# 🎉 Final summary banner
function _log_summary() {
    gum style --border double --padding "1 3" --margin "2 0" --bold --foreground 42 "$@"
}

# ❓ Question or prompt message
function _log_question() {
    gum style --bold --foreground 45 "❓ $@"
}
