# ------------------------------------------------------------------------------
# 🛒 Mac App Store (mas-cli) Utilities
# ------------------------------------------------------------------------------

# 💾 Saves a filtered list of App Store apps (excludes cask-preferred ones)
# 📄 Output: $DEVKIT_MODULES_DIR/mas/apps.txt
# 💡 Usage: mas-save-apps
function mas-save-apps() {
    _log-inline-title "App Store Apps Saving"
    local output="$DEVKIT_MODULES_DIR/mas/apps.txt"
    mkdir -p "$(dirname "$output")"

    # Cask-preferred keywords (lowercase, no spaces)
    local cask_preferred_keywords=(
        whatsapp onedrive skype zoom postman
        microsoft visualstudiocode pgadmin docker
        chatgpt flutter
    )

    _log-info "💾 Saving App Store apps to $output"

    mas list | while read -r id name version; do
        local clean_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')

        local skip=false
        for keyword in "${cask_preferred_keywords[@]}"; do
            if [[ "$clean_name" == *"$keyword"* ]]; then
                skip=true
                break
            fi
        done

        $skip || echo "$id  $name"
    done >"$output"

    _log-success "✓ Saved App Store apps to $output"
    _log-inline-title "End of App Store Apps Saving"
    echo
}

# 📦 Installs apps listed in apps.txt using mas (if not already installed)
# - Skips apps already in /Applications
# - Format: <app_id> <app_name> (separated by spaces or tabs)
# 💡 Usage: mas-install-apps
function mas-install-apps() {
    _log-inline-title "App Store Installation"
    local input="$DEVKIT_MODULES_DIR/mas/apps.txt"

    if [[ ! -f "$input" ]]; then
        _log-error "✗ App list not found at $input"
        return 1
    fi

    _log-info "📦 Installing App Store apps from $input"

    while read -r app_id app_name; do
        [[ -z "$app_id" || "$app_id" =~ ^# ]] && continue
        [[ -z "$app_name" ]] && {
            _log-warning "⚠️  Skipping: missing app name for ID $app_id"
            continue
        }

        install-if-missing "$app_name" "$app_id"
    done <"$input"

    _log-success "✓ App Store app installation complete."
    _log-inline-title "End of App Store Installation"
    echo
}

function _get-app-name-from-id() {
    local app_id="$1"
    curl -s "https://itunes.apple.com/lookup?id=$app_id" |
        grep -o '"trackName":"[^"]*"' |
        sed 's/"trackName":"\(.*\)"/\1/'
}

# 📦 Installs App Store apps based on settings.json (dynamic app list)
# - Installs only apps marked as "y" (mas_install_<id>)
# - Gets app name dynamically via `mas info`
# 💡 Usage: mas-install-from-settings
function mas-install-from-settings() {

    _log-inline-title "App Store Installation from Settings"

    local settings_file="$DEVKIT_ROOT/settings.json"

    if [[ ! -f "$settings_file" ]]; then
        _log-error "✗ Settings file not found at $settings_file"
        _log-hint "💡 Run: devkit-settings-setup"
        return 1
    fi

    _log-info "🛍️  Installing selected Mac App Store apps from $settings_file"
    echo ""

    _get-app-name-from-id() {
        local app_id="$1"
        curl -s "https://itunes.apple.com/lookup?id=$app_id" |
            grep -o '"trackName":"[^"]*"' |
            sed 's/"trackName":"\(.*\)"/\1/'
    }

    mas_app_entries=($(_devkit-settings get array mas_apps))

    for entry in "${mas_app_entries[@]}"; do
        # Use a subshell to safely split on '|'
        app_id=$(echo "$entry" | cut -d '|' -f 1)
        app_name=$(echo "$entry" | cut -d '|' -f 2-)

        [[ -z "$app_id" ]] && continue

        _log-info "🛍️  $app_name ($app_id)"
        install-if-missing "$app_name" "$app_id"
        sleep 2
    done

    echo ""
    _log-success "✓ App Store app installation (from settings) complete."
    _log-inline-title "End of App Store Installation from Settings"
    echo
}

# 🔄 Updates installed App Store apps via mas
# 💡 Usage: mas-maintain
function mas-maintain() {
    _log-inline-title "App Store Maintenance"

    _log-info "🔍 Checking for App Store updates..."
    mas outdated || return 1
    _log-success "✓ App Store apps are up to date."
    echo
    _log-info "⬆️  Upgrading App Store apps..."
    mas upgrade || return 1
    _log-success "✓ App Store apps updated."

    _log-inline-title "End of App Store Maintenance"
    echo
}

# ⚙️ Full mas setup: installs saved apps and applies updates
# 💡 Usage: mas-setup
function mas-setup() {
    mas-install-apps || return 1
    mas-install-from-settings || return 1
    mas-maintain || return 1
}

# 🔍 Checks if an app is installed via mas
# 💡 Usage: mas-is-installed <app_name> <app_id>
function install-if-missing() {
    local app_name="$1"
    local app_id="$2"

    if [[ -z "$app_name" || -z "$app_id" ]]; then
        _log-error "✗ Missing app name or ID. Usage: install-if-missing <app_name> <app_id>"
        return 1
    fi

    if [[ ! -d "/Applications/$app_name.app" ]]; then
        mas install $app_id || {
            _log-error "✗ Failed to install $app_name. Please check the App Store ID."
            return 1
        }
        _log-success "✓ Installed $app_name"
    else
        _log-success "✓ $app_name already installed"
    fi
}
