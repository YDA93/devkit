# 💾 Saves a list of top-level Homebrew packages (excluding dependencies)
# 📄 Output: ~/devkit/homebrew/packages.txt
function homebrew-save-packages() {
    local output="$HOME/devkit/homebrew/packages.txt"

    echo "🍺 Saving installed packages to $output"
    mkdir -p "$(dirname "$output")" # Ensure directory exists
    brew leaves >"$output"
    echo "✅ Saved installed packages to $output"
}

# 📦 Installs Homebrew packages from a saved list
# 📄 Input: ~/devkit/homebrew/packages.txt
function homebrew-install-packages() {
    local input="$HOME/devkit/homebrew/packages.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ Package list not found at $input"
        return 1
    fi

    echo "🍺 Installing packages from $input"
    xargs brew install <"$input"
    echo "✅ Installed packages from $input"
}

# 🔥 Uninstalls Homebrew packages not in packages.txt (with confirmation)
function homebrew-prune-packages() {
    local file="$HOME/devkit/homebrew/packages.txt"

    if [[ ! -f "$file" ]]; then
        echo "❌ Package list not found at $file"
        return 1
    fi

    echo "🧹 Checking for packages to uninstall..."

    # Current top-level packages
    local current_leaves=($(brew leaves))
    # Desired packages from file
    local desired_packages=($(cat "$file"))

    for pkg in "${current_leaves[@]}"; do
        if ! printf '%s\n' "${desired_packages[@]}" | grep -qx "$pkg"; then
            if confirm_or_abort "Uninstall \"$pkg\"? It is not listed in packages.txt." "$@"; then
                echo "❌ Uninstalling: $pkg"
                brew uninstall --ignore-dependencies "$pkg"
            else
                echo "⏭️ Skipping: $pkg"
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
