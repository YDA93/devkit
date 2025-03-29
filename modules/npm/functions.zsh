# 📦 Saves a list of top-level global npm packages (excluding dependencies)
# 📄 Output: /$DEVKIT_MODULES_PATH/npm/packages.txt
function npm-save-packages() {
    local output="$DEVKIT_MODULES_PATH/npm/packages.txt"
    echo "📦 Saving global npm packages to $output"
    mkdir -p "$(dirname "$output")"

    npm list -g --depth=0 --parseable |
        tail -n +2 |
        awk -F/ '{print $NF}' \
            >"$output"

    echo "✅ Saved npm packages to $output"
}

# 📦 Installs global npm packages from saved list
# 📄 Input: /$DEVKIT_MODULES_PATH/npm/packages.txt
function npm-install-packages() {
    local input="$DEVKIT_MODULES_PATH/npm/packages.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ Package list not found at $input"
        return 1
    fi

    echo "📦 Installing global npm packages from $input"
    xargs npm install -g <"$input"
    echo "✅ Installed global npm packages"
}

# 🔥 Uninstalls global npm packages not in packages.txt (with confirmation)
function npm-prune-packages() {
    local file="$DEVKIT_MODULES_PATH/npm/packages.txt"

    if [[ ! -f "$file" ]]; then
        echo "❌ Package list not found at $file"
        return 1
    fi

    echo "🧹 Checking for npm packages to uninstall..."

    local current_pkgs=($(npm list -g --depth=0 --parseable | tail -n +2 | awk -F/ '{print $NF}'))
    local saved_pkgs=($(cat "$file"))

    for pkg in "${current_pkgs[@]}"; do
        if ! printf '%s\n' "${saved_pkgs[@]}" | grep -qx "$pkg"; then
            if _confirm_or_abort "Uninstall \"$pkg\"? It is not listed in packages.txt." "$@"; then
                echo "❌ Uninstalling: $pkg"
                npm uninstall -g "$pkg"
            else
                echo "⏭️ Skipping: $pkg"
            fi
        fi
    done

    echo "✅ npm cleanup complete."
}

function npm-setup() {
    npm-prune-packages || return 1
    npm-install-packages || return 1
}

function npm-list-packages() {
    echo "📦 Installed global npm packages:"
    npm list -g
}
