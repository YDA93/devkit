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

# 💾 Saves lists of top-level Homebrew formulae and casks
# 📄 Output: $DEVKIT_MODULES_PATH/homebrew/formulaes.txt and casks.txt
function homebrew-save-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formulae_output="$base_dir/formulaes.txt"
    local casks_output="$base_dir/casks.txt"

    echo "🍺 Saving installed Homebrew formulae to $formulae_output"
    echo "🧴 Saving installed Homebrew casks to $casks_output"
    mkdir -p "$base_dir"

    brew list --formula --installed-on-request >"$formulae_output"
    brew list --cask >"$casks_output"

    echo "✅ Saved installed packages:"
    echo "   📄 Formulae: $formulae_output"
    echo "   📄 Casks:    $casks_output"
}

# 📦 Installs Homebrew formulae and casks from saved package lists
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/formulaes.txt and casks.txt
function homebrew-install-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formulae_input="$base_dir/formulaes.txt"
    local casks_input="$base_dir/casks.txt"

    if [[ ! -f "$formulae_input" && ! -f "$casks_input" ]]; then
        echo "❌ No package lists found in $base_dir"
        return 1
    fi

    if [[ -f "$formulae_input" ]]; then
        echo "🍺 Installing Homebrew formulae from $formulae_input"
        xargs brew install --formula <"$formulae_input" || {
            echo "❌ Failed to install formulae. Please check the list."
            return 1
        }
    fi

    if [[ -f "$casks_input" ]]; then
        echo "🧴 Installing Homebrew casks from $casks_input"
        xargs brew install --cask <"$casks_input" || {
            echo "❌ Failed to install casks. Please check the list."
            return 1
        }
    fi

    echo "✅ Finished installing Homebrew packages"
}

# 🔥 Uninstalls Homebrew formulae and casks not listed in formulaes.txt / casks.txt
# 🧹 Prompts for confirmation before uninstalling each package
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/formulaes.txt and casks.txt
function homebrew-prune-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formulae_file="$base_dir/formulaes.txt"
    local casks_file="$base_dir/casks.txt"

    if [[ ! -f "$formulae_file" && ! -f "$casks_file" ]]; then
        echo "❌ No package lists found in $base_dir"
        return 1
    fi

    echo "🧹 Checking for Homebrew packages to uninstall..."

    local current_formulae=($(brew list --formula --installed-on-request))
    local current_casks=($(brew list --cask))

    local desired_formulae=()
    local desired_casks=()

    # Read formulae
    if [[ -f "$formulae_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_formulae+=("$line")
        done <"$formulae_file"
    fi

    # Read casks
    if [[ -f "$casks_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_casks+=("$line")
        done <"$casks_file"
    fi

    # Prune formulae
    for pkg in "${current_formulae[@]}"; do
        if ! printf '%s\n' "${desired_formulae[@]}" | grep -qx "$pkg"; then
            if _confirm_or_abort "Uninstall formula \"$pkg\"? It's not in formulaes.txt." "$@"; then
                echo "❌ Uninstalling formula: $pkg"
                brew uninstall --ignore-dependencies "$pkg"
            else
                echo "⏭️ Skipping formula: $pkg"
            fi
        fi
    done

    # Prune casks
    for cask in "${current_casks[@]}"; do
        if ! printf '%s\n' "${desired_casks[@]}" | grep -qx "$cask"; then
            if _confirm_or_abort "Uninstall cask \"$cask\"? It's not in casks.txt." "$@"; then
                echo "❌ Uninstalling cask: $cask"
                brew uninstall --cask "$cask"
            else
                echo "⏭️ Skipping cask: $cask"
            fi
        fi
    done

    echo "✅ Cleanup complete. Only packages from the saved lists remain."
}
# ⚙️ Runs the full Homebrew environment setup:
#    - Prunes unlisted formulae and casks
#    - Installs listed formulae and casks
#    - Resets Zsh configuration
function homebrew-setup() {
    homebrew-install || return 1
    homebrew-prune-packages || return 1
    homebrew-install-packages || return 1
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
