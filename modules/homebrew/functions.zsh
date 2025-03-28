function homebrew-install() {
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "Homebrew installation failed."
            return 1
        }
    else
        echo "Homebrew is already installed."
    fi

    # Verify Homebrew is working
    if ! brew --version &>/dev/null; then
        echo "Homebrew seems to be installed but not working properly."
        return 1
    fi

    echo "✅ Homebrew is installed and working."
}

# 💾 Saves a list of top-level Homebrew packages (formulae + casks)
# 📄 Output: $DEVKIT_MODULES_PATH/homebrew/packages.txt
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

# 📦 Installs Homebrew formulae and casks from a saved package list
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/packages.txt
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

# 🔥 Uninstalls Homebrew formulae and casks not listed in packages.txt
# 🧹 Prompts for confirmation before uninstalling each package
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/packages.txt
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

# ⚙️ Runs the full Homebrew environment setup:
#    - Prunes unlisted formulae and casks
#    - Installs listed formulae and casks
#    - Runs npm-setup as part of the environment bootstrapping
function homebrew-setup() {
    homebrew-install
    homebrew-prune-packages
    homebrew-install-packages
    npm-setup
}

# 📋 Lists all currently installed Homebrew packages (formulae and casks)
function homebrew-list-packages() {
    echo "🍺 Installed Homebrew packages:"
    brew list
}

# ♻️ Performs full Homebrew maintenance:
#    - Checks system health
#    - Updates Homebrew and all packages
#    - Upgrades formulae and casks
#    - Removes unused dependencies and cleans up
function homebrew-maintain() {
    echo "🩺 Checking system health..."
    brew doctor || echo "⚠️ brew doctor reported issues."

    echo "⬆️  Updating Homebrew..."
    brew update

    echo "🔄 Upgrading formulae..."
    brew upgrade

    echo "🧴 Upgrading casks..."
    brew upgrade --cask

    echo "🧹 Autoremoving unused dependencies..."
    brew autoremove

    echo "🗑️ Cleaning up old versions and cache..."
    brew cleanup -s --prune=7

    echo "📦 Verifying installed packages..."
    brew missing || echo "✅ No missing dependencies."

    echo "✅ Homebrew maintenance complete!"
}
