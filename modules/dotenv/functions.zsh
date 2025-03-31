# Checks if a specific environment variable exists and is non-empty in a .env file.
#
# Usage:
#   environment-variable-exists [variable_name] [env_file]
function environment-variable-exists() {
    local var_name="$1"
    local env_file="${2:-.env}"

    # Check if file exists
    if [[ ! -f "$env_file" ]]; then
        echo "❌ Error: File not found – $env_file"
        return 1
    fi

    # Check if the variable is present
    if ! grep -q "^${var_name}=" "$env_file"; then
        echo "❌ Error: $var_name is not defined in $env_file"
        return 1
    fi

    # Check if the variable is not empty
    if grep -q "^${var_name}=$" "$env_file"; then
        echo "❌ Error: $var_name is defined but empty in $env_file"
        return 1
    fi

    return 0
}

# Updates or adds a key-value pair in the .env file.
#
# Usage:
#   environment-variable-set [key] [value]
function environment-variable-set() {
    local key="$1"
    local value="$2"
    local env_file=".env"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "❌ Error: Key or value is missing!"
        echo "Usage: environment-variable-set [key] [value]"
        return 1
    fi

    # Ensure .env file exists
    if [ ! -f "$env_file" ]; then
        echo "❌ Error: .env file not found."
        return 1
    fi

    echo "🔹 Setting $key=\"$value\" in $env_file..."

    # Escape forward slashes and ampersands for sed replacement
    local escaped_value
    escaped_value=$(printf '%s\n' "$value" | sed -e 's/[\/&]/\\&/g')

    if grep -q "^$key=" "$env_file"; then
        # Key exists, update it (handles values with or without quotes)
        sed -i '' -E "s|^$key=.*|$key=\"$escaped_value\"|" "$env_file"
    else
        # Key doesn't exist, append it
        echo "$key=\"$value\"" >>"$env_file"
    fi

    echo "✅ $key successfully set."
}

# environment-variable-get – Retrieve the value of a variable from a .env file
#
# Usage:
#   environment-variable-get KEY [--env-file path] [--preserve-quotes] [--raw]
#
# Flags:
#   --env-file         Path to the .env file (default: ".env")
#   --preserve-quotes  Preserve surrounding quotes
#   --raw              Output raw value (preserve escape sequences like \n)
function environment-variable-get() {
    local key=""
    local env_file=".env"
    local preserve_quotes=false
    local raw_output=false

    # Parse args
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
        --env-file)
            env_file="$2"
            shift 2
            ;;
        --preserve-quotes)
            preserve_quotes=true
            shift
            ;;
        --raw)
            raw_output=true
            shift
            ;;
        -*)
            echo "❌ Unknown option: $1" >&2
            return 1
            ;;
        *)
            if [[ -z "$key" ]]; then
                key="$1"
            else
                echo "❌ Unexpected argument: $1" >&2
                return 1
            fi
            shift
            ;;
        esac
    done

    if [[ -z "$key" ]]; then
        echo "❌ Error: No key provided."
        return 1
    fi

    if [[ ! -f "$env_file" ]]; then
        echo "❌ Error: File not found – $env_file"
        return 1
    fi

    local value
    value=$(grep "^${key}=" "$env_file" | cut -d'=' -f2-)

    if [[ "$preserve_quotes" != true ]]; then
        value="${value#\"}"
        value="${value%\"}"
    fi

    if [[ -z "$value" ]]; then
        echo "❌ Error: $key is not defined or empty in $env_file"
        return 1
    fi

    if [[ "$raw_output" == true ]]; then
        printf '%s\n' "$value"
    else
        echo "$value"
    fi
}
