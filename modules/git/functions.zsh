# ------------------------------------------------------------------------------
# 🔧 Git Configuration & Diagnostics
# ------------------------------------------------------------------------------

# 🧾 Sets Git global user name, email, and core preferences
# - Prompts for user.name and user.email
# - Applies essential Git settings (no extras)
# 💡 Usage: git-setup
function git-setup() {
    echo "📛 Enter your Git user name:"
    read -r git_name

    echo "📧 Enter your Git email:"
    read -r git_email

    if [[ -z "$git_name" || -z "$git_email" ]]; then
        echo "❌ Git name and email cannot be empty. Aborting."
        return 1
    fi

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"

    git config --global core.editor "code --wait"
    git config --global core.autocrlf input
    git config --global core.excludesfile "$HOME/.gitignore_global"
    git config --global init.defaultBranch main

    git config --global filter.lfs.required true
    git config --global filter.lfs.clean "git-lfs clean -- %f"
    git config --global filter.lfs.smudge "git-lfs smudge -- %f"
    git config --global filter.lfs.process "git-lfs filter-process"

    git config --global diff.tool vscode
    git config --global difftool.vscode "code --wait --diff \$LOCAL \$REMOTE"
    git config --global difftool.vscode.cmd "code --wait --diff \$LOCAL \$REMOTE"

    git config --global color.ui auto
    git config --global pull.ff only

    echo "✅ Git global config has been updated."
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
