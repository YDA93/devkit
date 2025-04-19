function _settings_parser_get_string() {
    local key="$1"
    jq -r --arg k "$key" '.[$k] // empty' "$CLI_SETTINGS_FILE"
}

function _settings_parser_get_bool() {
    local key="$1"
    jq -r --arg k "$key" '.[$k] // empty' "$CLI_SETTINGS_FILE"
}

function _settings_parser_get_array() {
    local key="$1"
    jq -r --arg k "$key" '.[$k] // empty | select(type == "array") | .[]' "$CLI_SETTINGS_FILE"
}

function _settings_parser_get_json() {
    local key="$1"
    jq --arg k "$key" '.[$k] // empty' "$CLI_SETTINGS_FILE"
}

function _settings_parser_set_string() {
    local key="$1"
    local val="$2"
    local tmp="$(mktemp)"
    jq --arg k "$key" --arg val "$val" '.[$k] = $val' "$CLI_SETTINGS_FILE" >"$tmp" && mv "$tmp" "$CLI_SETTINGS_FILE"
    [[ $verbose -eq 1 ]] && echo "✓ Set $key = \"$val\" (string)"
}

function _settings_parser_set_bool() {
    local key="$1"
    local val="$2"
    if [[ "$val" != "true" && "$val" != "false" ]]; then
        echo "Error: Boolean must be 'true' or 'false'"
        return 1
    fi
    local tmp="$(mktemp)"
    jq --arg k "$key" --argjson val "$val" '.[$k] = $val' "$CLI_SETTINGS_FILE" >"$tmp" && mv "$tmp" "$CLI_SETTINGS_FILE"
    [[ $verbose -eq 1 ]] && echo "✓ Set $key = $val (boolean)"
}

function _settings_parser_set_array() {
    local key="$1"
    shift
    local array_json
    if [[ "$#" -eq 0 ]]; then
        array_json="[]"
    else
        array_json=$(printf '%s\n' "$@" | jq -R . | jq -s .)
    fi
    local tmp="$(mktemp)"
    jq --arg k "$key" --argjson val "$array_json" '.[$k] = $val' "$CLI_SETTINGS_FILE" >"$tmp" && mv "$tmp" "$CLI_SETTINGS_FILE"
    [[ $verbose -eq 1 ]] && echo "✓ Set $key = $array_json (array)"
}

function _settings_parser_set_json() {
    local key="$1"
    local val="$2"
    if [[ "$val" != \{* && "$val" != \[* ]]; then
        echo "Error: JSON value must start with '{' or '['"
        return 1
    fi
    local tmp="$(mktemp)"
    jq --arg k "$key" --argjson val "$val" '.[$k] = $val' "$CLI_SETTINGS_FILE" >"$tmp" && mv "$tmp" "$CLI_SETTINGS_FILE"
    [[ $verbose -eq 1 ]] && echo "✓ Set $key = $val (raw JSON)"
}
