# 🔍 Retrieves a string value from the settings file
# 💡 Usage: _settings-parser-get-string <key>
function _settings-parser-get-string() {
    local key="$1"
    jq -r --arg k "$key" '.[$k] // empty' "$CLI_SETTINGS_FILE"
}

# 🔍 Retrieves a boolean value from the settings file
# 💡 Usage: _settings-parser-get-bool <key>
function _settings-parser-get-bool() {
    local key="$1"
    local value
    value=$(jq -r --arg k "$key" '.[$k] // empty' "$CLI_SETTINGS_FILE")

    if [[ "$value" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

# 🔍 Retrieves an array value from the settings file (one element per line)
# 💡 Usage: _settings-parser-get-array <key>
function _settings-parser-get-array() {
    local key="$1"
    jq -r --arg k "$key" '.[$k] // empty | select(type == "array") | .[]' "$CLI_SETTINGS_FILE"
}

# 🔍 Retrieves a raw JSON value from the settings file
# 💡 Usage: _settings-parser-get-json <key>
function _settings-parser-get-json() {
    local key="$1"
    jq --arg k "$key" '.[$k] // empty' "$CLI_SETTINGS_FILE"
}

# ✏️  Sets a string value in the settings file
# 💡 Usage: _settings-parser-set-string <key> <value>
function _settings-parser-set-string() {
    local key="$1"
    local val="$2"
    local tmp="$(mktemp)"
    jq --arg k "$key" --arg val "$val" '.[$k] = $val' "$CLI_SETTINGS_FILE" >"$tmp" && mv "$tmp" "$CLI_SETTINGS_FILE"
    [[ $verbose -eq 1 ]] && echo "✓ Set $key = \"$val\" (string)"
}

# ✏️  Sets a boolean value in the settings file ("true" or "false")
# 💡 Usage: _settings-parser-set-bool <key> <true|false>
function _settings-parser-set-bool() {
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

# ✏️  Sets an array value in the settings file
# 💡 Usage: _settings-parser-set-array <key> <item1> <item2> ...
function _settings-parser-set-array() {
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

# ✏️  Sets a raw JSON value in the settings file
# 💡 Usage: _settings-parser-set-json <key> '<json_value>'
function _settings-parser-set-json() {
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
