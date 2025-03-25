# Checks if a specific environment variable exists and is non-empty in a .env file.
#
# Usage:
#   environment_variable_exists [variable_name] [env_file]
function environment_variable_exists() {
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
#   environment_variable_set [key] [value]
function environment_variable_set() {
    local key="$1"
    local value="$2"
    local env_file=".env"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo "❌ Error: Key or value is missing!"
        echo "Usage: environment_variable_set [key] [value]"
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
