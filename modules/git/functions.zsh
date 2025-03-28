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
