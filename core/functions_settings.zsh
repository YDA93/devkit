# ------------------------------------------------------------------------------
# 🧩 Devkit Settings
# ------------------------------------------------------------------------------

# Initialize the settings file if it doesn't exist
# Usage: settings init
function devkit-settings-init() {
    CLI_SETTINGS_FILE="$DEVKIT_ROOT/settings.json"

    if [[ ! -f "$CLI_SETTINGS_FILE" ]]; then
        _log_info "🛠️  Initializing settings file at $CLI_SETTINGS_FILE"
        echo '{}' >"$CLI_SETTINGS_FILE"
        _log_success "✅ Created new settings file."
    fi
}

function devkit-settings-reset() {
    CLI_SETTINGS_FILE="$DEVKIT_ROOT/settings.json"
    # Delete the settings file if it exists
    if [[ -f "$CLI_SETTINGS_FILE" ]]; then
        rm "$CLI_SETTINGS_FILE"
        _log_success "✓ Deleted settings file: $CLI_SETTINGS_FILE"
    else
        _log_info "ℹ️  No settings file to delete."
    fi

    # Reinitialize the settings file
    devkit-settings-init
}

function devkit-settings() {
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

    devkit-settings-init

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
            _settings_parser_get_string "$key"
            ;;
        bool)
            _settings_parser_get_bool "$key"
            ;;
        array)
            _settings_parser_get_array "$key"
            ;;
        json)
            _settings_parser_get_json "$key"
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
            _settings_parser_set_string "$key" "$1"
            ;;
        bool)
            _settings_parser_set_bool "$key" "$1"
            ;;
        array)
            _settings_parser_set_array "$key" "$@"
            ;;
        json)
            _settings_parser_set_json "$key" "$1"
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

# 🧰 Initializes your CLI by asking user for name, email, and app selections (multi-select)
# - Stores results in ~/devkit/settings.json
# 💡 Usage: devkit-settings-setup
function devkit-settings-setup() {
    # Get user inputs for settings
    _log_info "🔧 Please provide your details and select the apps you want to install."

    # Set up user details
    _devkit-settings-user-setup

    # Set up optional apps
    _devkit-settings-select-optional-apps mas optional_mas_apps.txt
    _devkit-settings-select-optional-apps cask optional_brew_casks.txt
    _devkit-settings-select-optional-apps formula optional_brew_formulas.txt

    _log_success "✓ Settings saved successfully."
    echo
}

function _devkit-settings-user-setup() {
    # Load basic user info
    full_name=$(gum input --header "👤 Full Name" --value "$(devkit-settings get string full_name)")
    email=$(gum input --header "📧 Email Address" --value "$(devkit-settings get string email)")

    devkit-settings set string full_name "$full_name"
    devkit-settings set string email "$email"
}

function _devkit-settings-select-optional-apps() {
    local type="$1"
    local file_name="$2"

    local file_path="$DEVKIT_ROOT/core/$file_name"
    local array_var="${type}_apps"
    local selected_var="selected_${type}_apps"

    # Dynamically create the array variable (mas_apps, cask_apps, etc.)
    _load_array_from_file "$file_path" "$array_var"

    # Show selection menu using dynamic array
    eval "_show_app_selection_menu \"$type\" \"\${${array_var}[@]}\""

    # Save the selected apps (also dynamic)
    eval "devkit-settings set array \"$array_var\" \"\${${selected_var}[@]}\""
}

function _show_app_selection_menu() {
    local type=$1
    shift
    local apps=("$@")

    local choices=()
    local selected=()

    local selected_key="${type}_apps"
    local previously_selected=($(devkit-settings get array "$selected_key"))

    for app in "${apps[@]}"; do
        local display="$app"

        if [[ "$type" == "mas" ]]; then
            IFS='|' read -r app_id app_name <<<"$app"
            display="$app_id|$app_name"
        fi

        choices+=("$display")

        if _array_contains "$display" "${previously_selected[@]}"; then
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
