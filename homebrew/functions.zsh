# 💾 Saves a list of top-level Homebrew packages (excluding dependencies)
# 📄 Output: ~/macOS/homebrew/packages.txt
function homebrew-save-packages() {
    local output="$HOME/macOS/homebrew/packages.txt"

    echo "🍺 Saving installed packages to $output"
    mkdir -p "$(dirname "$output")" # Ensure directory exists
    brew leaves >"$output"
    echo "✅ Saved installed packages to $output"
}

# 📦 Installs Homebrew packages from a saved list
# 📄 Input: ~/macOS/homebrew/packages.txt
function homebrew-install-packages() {
    local input="$HOME/macOS/homebrew/packages.txt"

    if [[ ! -f "$input" ]]; then
        echo "❌ Package list not found at $input"
        return 1
    fi

    echo "🍺 Installing packages from $input"
    xargs brew install <"$input"
    echo "✅ Installed packages from $input"
}
