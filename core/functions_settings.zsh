# 🧩 Initializes the DevKit CLI settings file if it doesn't exist
# 💡 Usage: _devkit-settings-init
function _devkit-settings-init() {
    CLI_SETTINGS_FILE="$DEVKIT_ROOT/settings.json"

    if [[ ! -f "$CLI_SETTINGS_FILE" ]]; then
        _log-info "🛠️  Initializing settings file at $CLI_SETTINGS_FILE"
        echo '{}' >"$CLI_SETTINGS_FILE"
        _log-success "✅ Created new settings file."
    fi
}

# 🔁 Resets the DevKit CLI settings by deleting and reinitializing the file
# 💡 Usage: _devkit-settings-reset
function _devkit-settings-reset() {
    CLI_SETTINGS_FILE="$DEVKIT_ROOT/settings.json"
    # Delete the settings file if it exists
    if [[ -f "$CLI_SETTINGS_FILE" ]]; then
        rm "$CLI_SETTINGS_FILE"
        _log-success "✓ Deleted settings file: $CLI_SETTINGS_FILE"
    else
        _log-info "ℹ️  No settings file to delete."
    fi

    # Reinitialize the settings file
    _devkit-settings-init
}

# ⚙️  Gets or sets values in the DevKit CLI settings file
# 💡 Usage: _devkit-settings [get|set] <type> <key> [value...] [--v]
function _devkit-settings() {
    local verbose=0

    # Check if --v is present anywhere in the args
    for arg in "$@"; do
        if [[ "$arg" == "--v" ]]; then
            verbose=1
            break
        fi
    done

    # Remove --v from arguments so it doesn't interfere with logic
    set -- "${@/--v/}"

    local cmd="$1"

    _devkit-settings-init

    case "$cmd" in
    get)
        local type="$2"
        local key="$3"

        if [[ -z "$type" || -z "$key" ]]; then
            echo "Usage: settings get <type> <key>"
            return 1
        fi

        case "$type" in
        string)
            _settings-parser-get-string "$key"
            ;;
        bool)
            _settings-parser-get-bool "$key"
            return $? # ← propagate bool result
            ;;
        array)
            _settings-parser-get-array "$key"
            ;;
        json)
            _settings-parser-get-json "$key"
            ;;
        *)
            echo "Error: Unsupported type '$type'. Use string, bool, array, or json."
            return 1
            ;;
        esac
        return 0
        ;;
    set)
        local type="$2"
        local key="$3"
        shift 3

        if [[ -z "$type" || -z "$key" ]]; then
            echo "Usage: settings set <type> <key> [value...]"
            return 1
        fi

        local tmp="$(mktemp)"

        case "$type" in
        string)
            _settings-parser-set-string "$key" "$1"
            ;;
        bool)
            _settings-parser-set-bool "$key" "$1"
            ;;
        array)
            _settings-parser-set-array "$key" "$@"
            ;;
        json)
            _settings-parser-set-json "$key" "$1"
            ;;
        *)
            echo "Error: Unsupported type '$type'. Use string, bool, array, or json."
            return 1
            ;;
        esac
        return 0
        ;;
    *)
        echo "Usage: settings [get|set] ..."
        return 1
        ;;
    esac
}

# ⚙️  Interactive setup wizard for DevKit settings and optional apps
# 💡 Usage: devkit-settings-setup
function devkit-settings-setup() {
    # Get user inputs for settings
    _log-info "🔧 Please provide your details and select the apps you want to install."

    # Set up user details
    _devkit-settings-user-setup

    # Set up optional apps
    _devkit-settings-select-optional-apps mas optional_mas_apps.txt
    _devkit-settings-select-optional-apps cask optional_brew_casks.txt
    _devkit-settings-select-optional-apps formula optional_brew_formulas.txt

    if gum confirm "🌙 Would you like to use the cool night theme for your terminal?"; then
        _devkit-settings set bool use_cool_night_theme true
    else
        _devkit-settings set bool use_cool_night_theme false
        echo "👍 Keeping your current theme."
    fi

    _log-success "✓ Settings saved successfully."
    echo
}

# 👤 Prompts the user for full name and email, then saves them to settings
# 💡 Usage: _devkit-settings-user-setup
function _devkit-settings-user-setup() {
    # Load basic user info
    full_name=$(gum input --header "👤 Full Name" --value "$(_devkit-settings get string full_name)")
    email=$(gum input --header "📧 Email Address" --value "$(_devkit-settings get string email)")

    _devkit-settings set string full_name "$full_name"
    _devkit-settings set string email "$email"
}

# 📦 Displays selection menu for optional apps of a given type (mas, cask, formula)
# 💡 Usage: _devkit-settings-select-optional-apps <type> <file_name>
function _devkit-settings-select-optional-apps() {
    local type="$1"
    local file_name="$2"

    local file_path="$DEVKIT_ROOT/core/$file_name"
    local array_var="${type}_apps"
    local selected_var="selected_${type}_apps"

    # Dynamically create the array variable (mas_apps, cask_apps, etc.)
    _load-array-from-file "$file_path" "$array_var"

    # Show selection menu using dynamic array
    eval "_show-app-selection-menu \"$type\" \"\${${array_var}[@]}\""

    # Save the selected apps (also dynamic)
    eval "_devkit-settings set array \"$array_var\" \"\${${selected_var}[@]}\""
}

# 🧾 Displays an interactive checklist of apps to install, preserving prior selections
# 💡 Usage: _show-app-selection-menu <type> <apps...>
function _show-app-selection-menu() {
    local type=$1
    shift
    local apps=("$@")

    local choices=()
    local selected=()

    local selected_key="${type}_apps"
    local previously_selected=($(_devkit-settings get array "$selected_key"))

    for app in "${apps[@]}"; do
        local display="$app"

        if [[ "$type" == "mas" ]]; then
            IFS='|' read -r app_id app_name <<<"$app"
            display="$app_id|$app_name"
        fi

        choices+=("$display")

        if _array-contains "$display" "${previously_selected[@]}"; then
            selected+=("$display")
        fi
    done

    local header="🛍️  Select $type apps to install (use spacebar to select, enter to confirm):"

    local selected_apps=$(gum choose --no-limit --header="$header" --selected "$(
        IFS=,
        echo "${selected[*]}"
    )" "${choices[@]}")

    eval "selected_${type}_apps=(\${(@f)selected_apps})"
}
