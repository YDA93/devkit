# 📂 Loads lines from a file into an array variable by reference
# 💡 Usage: _load-array-from-file <file_path> <array_var_name>
function _load-array-from-file() {
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

# 🔍 Checks if an array contains a specific item
# 💡 Usage: _array-contains <item> <array...>
function _array-contains() {
    local item="$1"
    shift
    for element in "$@"; do
        [[ "$element" == "$item" ]] && return 0
    done
    return 1
}
