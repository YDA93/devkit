# 💾 Saves a list of top-level Homebrew packages (excluding dependencies)
# 📄 Output: /$DEVKIT_MODULES_PATH/homebrew/packages.txt
function homebrew-save-packages() {
    local output="$DEVKIT_MODULES_PATH/homebrew/packages.txt"

    echo "🍺 Saving installed packages to $output"
    mkdir -p "$(dirname "$output")"

    {
        echo "# Formulae"
        brew leaves
        echo
        echo "# Casks"
        brew list --cask
    } >"$output"

    echo "✅ Saved installed packages to $output"
}

# 📦 Installs Homebrew packages from a saved list
# 📄 Input: /$DEVKIT_MODULES_PATH/homebrew/packages.txt
function homebrew-install-packages() {
    local input="$DEVKIT_MODULES_PATH/homebrew/packages.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ Package list not found at $input"
        return 1
    fi

    echo "🍺 Installing packages from $input"

    local section=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^# ]] && section="$line" && continue
        [[ -z "$line" ]] && continue

        if [[ "$section" == "# Formulae" ]]; then
            brew install "$line"
        elif [[ "$section" == "# Casks" ]]; then
            brew install --cask "$line"
        fi
    done <"$input"

    echo "✅ Installed packages from $input"
}

# 🔥 Uninstalls Homebrew packages not in packages.txt (with confirmation)
function homebrew-prune-packages() {
    local file="$DEVKIT_MODULES_PATH/homebrew/packages.txt"

    if [[ ! -f "$file" ]]; then
        echo "❌ Package list not found at $file"
        return 1
    fi

    echo "🧹 Checking for packages to uninstall..."

    local current_formulae=($(brew leaves))
    local current_casks=($(brew list --cask))

    local section=""
    local desired_formulae=()
    local desired_casks=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^# ]] && section="$line" && continue
        [[ -z "$line" ]] && continue

        if [[ "$section" == "# Formulae" ]]; then
            desired_formulae+=("$line")
        elif [[ "$section" == "# Casks" ]]; then
            desired_casks+=("$line")
        fi
    done <"$file"

    # Prune formulae not in the desired list
    for pkg in "${current_formulae[@]}"; do
        if ! printf '%s\n' "${desired_formulae[@]}" | grep -qx "$pkg"; then
            if _confirm_or_abort "Uninstall formula \"$pkg\"? It's not in packages.txt." "$@"; then
                echo "❌ Uninstalling formula: $pkg"
                brew uninstall --ignore-dependencies "$pkg"
            else
                echo "⏭️ Skipping formula: $pkg"
            fi
        fi
    done

    # Prune casks not in the desired list
    for cask in "${current_casks[@]}"; do
        if ! printf '%s\n' "${desired_casks[@]}" | grep -qx "$cask"; then
            if _confirm_or_abort "Uninstall cask \"$cask\"? It's not in packages.txt." "$@"; then
                echo "❌ Uninstalling cask: $cask"
                brew uninstall --cask "$cask"
            else
                echo "⏭️ Skipping cask: $cask"
            fi
        fi
    done

    echo "✅ Cleanup complete. Only packages from packages.txt remain."
}

function homebrew-setup() {
    homebrew-prune-packages
    homebrew-install-packages
    npm-setup
}

function homebrew-list-packages() {
    echo "🍺 Installed Homebrew packages:"
    brew list
}
