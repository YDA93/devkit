# Usage: _load_array_from_file "file_path" array_name
function _load_array_from_file() {
    local file="$1"
    local __resultvar="$2"

    if [[ ! -f "$file" ]]; then
        eval "$__resultvar=()"
        return
    fi

    local lines=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        lines+=("$line")
    done <"$file"

    eval "$__resultvar=(\"\${lines[@]}\")"
}

# Function to check if a value is in an array
function _array_contains() {
    local item="$1"
    shift
    for element in "$@"; do
        [[ "$element" == "$item" ]] && return 0
    done
    return 1
}
