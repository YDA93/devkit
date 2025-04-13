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

# 🔄 Checks for and installs macOS updates
# 💡 Usage: _check-software-updates
function _check-software-updates() {
    # 🛠️ Installs all available macOS software updates (system + security)
    _log_info "🔍 Checking for macOS software updates..."

    # Check for available software updates
    available_updates=$(softwareupdate -l 2>&1)

    if echo "$available_updates" | grep -q "No new software available"; then
        _log_success "✅ No updates available."
        _log_separator
        return 0
    else
        _log_info "⬇️  Updates available. Installing now..."
        softwareupdate -ia --verbose
        _log_success "✅ Updates installed successfully."
        _log_info "🔁 A system restart may be required to complete installation."
        _log_warning "⚠️  Please reboot your Mac and then re-run: devkit-pc-setup"
        _log_separator
        return 1 # Signal that a reboot is needed
    fi
}
