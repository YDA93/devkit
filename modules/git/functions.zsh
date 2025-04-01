# ------------------------------------------------------------------------------
# 🔧 Git Configuration & Diagnostics
# ------------------------------------------------------------------------------

# 🔄 Syncs your custom .gitconfig to the global Git config
# - Backs up any existing ~/.gitconfig (unless it's already a symlink)
# - Creates a symlink from your custom path
# 💡 Usage: git-sync-config
function git-sync-config() {
    local source="$DEVKIT_MODULES_PATH/git/.gitconfig"
    local target="$HOME/.gitconfig"

    if [[ ! -f "$source" ]]; then
        echo "❌ Custom .gitconfig not found at: $source"
        return 1
    fi

    # Backup existing ~/.gitconfig if it's not already a symlink
    if [[ -f "$target" && ! -L "$target" ]]; then
        mv "$target" "$target.backup.$(date +%s)"
        echo "📦 Backed up existing ~/.gitconfig"
    fi

    # Create symlink
    ln -sf "$source" "$target"
    echo "✅ Linked $source → $target"
}

# 🩺 Checks if Git is properly installed and configured
# - Verifies Git is installed
# - Checks user.name, user.email, and global .gitignore
# - Ensures an SSH key exists and GitHub connection works
# 💡 Usage: git-doctor
function git-doctor() {
    echo "🔧 Checking Git..."

    if ! command -v git &>/dev/null; then
        echo "⚠️  Git is not installed."
        echo "💡 Install with: brew install git"
        return 1
    fi

    echo "🔧 Checking Git configuration..."
    if [[ -z $(git config user.name) || -z $(git config user.email) ]]; then
        echo "⚠️  Git user.name or user.email not configured"
        echo "💡 Set them with:"
        echo "   git config --global user.name \"Your Name\""
        echo "   git config --global user.email \"you@example.com\""
    else
        echo "✅ Git user.name and user.email are set"
    fi

    echo "📝 Checking for global .gitignore..."
    if git config --get core.excludesfile &>/dev/null; then
        echo "✅ Global .gitignore is configured"
    else
        echo "⚠️  No global .gitignore set"
        echo "💡 Tip: git config --global core.excludesfile ~/.gitignore_global"
    fi

    echo "🔧 Checking SSH key..."
    if [[ -f ~/.ssh/id_rsa.pub || -f ~/.ssh/id_ed25519.pub ]]; then
        echo "✅ SSH key found"
    else
        echo "⚠️  No SSH key found in ~/.ssh/"
        echo "💡 Generate one with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    fi

    echo "🔐 Testing SSH connection to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        echo "✅ SSH connection to GitHub works"
    else
        echo "⚠️  SSH connection to GitHub failed or requires verification"
        echo "💡 Run: ssh -T git@github.com to test manually"
    fi

    return 0
}
