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

# 💾 Saves lists of top-level Homebrew formula and casks
# 📄 Output: $DEVKIT_MODULES_PATH/homebrew/formulas.txt and casks.txt
function homebrew-save-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formula_output="$base_dir/formulas.txt"
    local casks_output="$base_dir/casks.txt"

    echo "🍺 Saving installed Homebrew formula to $formula_output"
    echo "🧴 Saving installed Homebrew casks to $casks_output"
    mkdir -p "$base_dir"

    brew list --formula --installed-on-request >"$formula_output"
    brew list --cask >"$casks_output"

    echo "✅ Saved installed packages:"
    echo "   📄 Formulae: $formula_output"
    echo "   📄 Casks:    $casks_output"
}

# 📦 Installs Homebrew formula and casks from saved package lists
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/formulas.txt and casks.txt
function homebrew-install-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formula_input="$base_dir/formulas.txt"
    local casks_input="$base_dir/casks.txt"

    if [[ ! -f "$formula_input" && ! -f "$casks_input" ]]; then
        echo "❌ No package lists found in $base_dir"
        return 1
    fi

    if [[ -f "$formula_input" ]]; then
        echo "🍺 Installing Homebrew formula from $formula_input"
        xargs brew install --formula <"$formula_input" || {
            echo "❌ Failed to install formula. Please check the list."
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

    brew cleanup
    brew autoremove

    echo "✅ Finished installing Homebrew packages"
}

# 🔥 Uninstalls Homebrew formula and casks not listed in formulas.txt / casks.txt
# 🧹 Prompts for confirmation before uninstalling each package
# 📄 Input: $DEVKIT_MODULES_PATH/homebrew/formulas.txt and casks.txt
function homebrew-prune-packages() {
    local base_dir="$DEVKIT_MODULES_PATH/homebrew"
    local formula_file="$base_dir/formulas.txt"
    local casks_file="$base_dir/casks.txt"

    if [[ ! -f "$formula_file" && ! -f "$casks_file" ]]; then
        echo "❌ No package lists found in $base_dir"
        return 1
    fi

    echo "🧹 Checking for Homebrew packages to uninstall..."

    local current_formula=($(brew list --formula --installed-on-request))
    local current_casks=($(brew list --cask))

    local desired_formula=()
    local desired_casks=()

    # Read formula
    if [[ -f "$formula_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_formula+=("$line")
        done <"$formula_file"
    fi

    # Read casks
    if [[ -f "$casks_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" || "$line" =~ ^# ]] && continue
            desired_casks+=("$line")
        done <"$casks_file"
    fi

    # Prune formula
    for pkg in "${current_formula[@]}"; do
        if ! printf '%s\n' "${desired_formula[@]}" | grep -qx "$pkg"; then
            if _confirm-or-abort "Uninstall formula \"$pkg\"? It's not in formulas.txt." "$@"; then
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
            if _confirm-or-abort "Uninstall cask \"$cask\"? It's not in casks.txt." "$@"; then
                echo "❌ Uninstalling cask: $cask"
                brew uninstall --cask "$cask"
            else
                echo "⏭️ Skipping cask: $cask"
            fi
        fi
    done

    brew cleanup
    brew autoremove

    echo "✅ Cleanup complete. Only packages from the saved lists remain."
}
# ⚙️ Runs the full Homebrew environment setup:
#    - Prunes unlisted formula and casks
#    - Installs listed formula and casks
#    - Resets Zsh configuration
function homebrew-setup() {
    homebrew-install || return 1
    homebrew-prune-packages || return 1
    homebrew-install-packages || return 1
}

# 📋 Lists all currently installed Homebrew packages (formula and casks)
function homebrew-list-packages() {
    echo "🍺 Installed Homebrew formula:"
    brew list --formula --installed-on-request
    echo "🧴 Installed Homebrew casks:"
    brew list --cask
}

# ♻️ Performs full Homebrew maintenance:
#    - Checks system health
#    - Updates Homebrew and all packages
#    - Upgrades formula and casks
#    - Removes unused dependencies and cleans up
function homebrew-maintain() {
    echo "🩺 Checking system health..."
    brew doctor || echo "⚠️ brew doctor reported issues."

    echo "⬆️  Updating Homebrew..."
    brew update

    echo "🔄 Upgrading formula..."
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

# homebrew-doctor: Checks the status of Homebrew on your system.
# - Verifies that Homebrew is installed.
# - Runs 'brew doctor' to detect potential issues.
# - Checks for outdated packages and suggests maintenance tips.
# Provides clear, helpful output and guidance if problems are found.
function homebrew-doctor() {
    echo "🔧 Checking Homebrew..."

    if ! command -v brew &>/dev/null; then
        echo "⚠️  Homebrew is not installed."
        echo "👉 You can install it with: homebrew-install"
        return 1
    fi

    echo "🩺 Running 'brew doctor'..."
    brew doctor
    if [[ $? -ne 0 ]]; then
        echo "⚠️  Homebrew reports issues. Run 'brew doctor' manually to review details."
        return 1
    else
        echo "✅ No major issues reported by Homebrew."
    fi

    echo "📦 Checking for outdated packages..."
    if [[ -n "$(brew outdated)" ]]; then
        echo "⚠️  You have outdated packages."
        echo "👉 Consider running 'brew outdated' to see which ones."
        echo "👉 To upgrade, use: 'homebrew-maintain'"
    else
        echo "✅ All packages are up to date."
    fi

    return 0
}
