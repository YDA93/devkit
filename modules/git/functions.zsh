# 🔄 Syncs your custom .gitconfig to the system/global Git config
#    - Backs up existing ~/.gitconfig if present
#    - Symlinks from your custom path to ~/.gitconfig

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

function git-doctor() {
    # Git Config
    echo "🔧 Checking Git configuration..."
    if [[ -z $(git config user.name) || -z $(git config user.email) ]]; then
        echo "⚠️  Git user.name or user.email not configured"
    else
        echo "✅ Git user.name and user.email are set"
    fi

    # SSH Key
    echo "🔧 Checking SSH key..."
    [[ -f ~/.ssh/id_rsa.pub || -f ~/.ssh/id_ed25519.pub ]] &&
        echo "✅ SSH key found" ||
        echo "⚠️  No SSH key found in ~/.ssh/"
}
