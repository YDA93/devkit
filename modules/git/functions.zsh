# ------------------------------------------------------------------------------
# 🔧 Git Configuration & Diagnostics
# ------------------------------------------------------------------------------

# 🧾 Sets Git global user name, email, and core preferences
# - Prompts for user.name and user.email
# - Applies essential Git settings (no extras)
# 💡 Usage: git-setup
function git-setup() {
    _log_info "🔧 Setting up Git global configuration..."

    $full_name=devkit-settings get string full_name
    $email=devkit-settings get string email

    if [[ -z "$full_name" || -z "$email" ]]; then
        _log_error "✗ Name or email missing from settings file. Aborting."
        return 1
    fi

    git config --global user.name "$full_name"
    git config --global user.email "$email"

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

    _log_success "✓ Git global config has been updated."
    echo
}

# 🩺 Checks if Git is properly installed and configured
# - Verifies Git is installed
# - Checks user.name, user.email, and global .gitignore
# - Ensures an SSH key exists and GitHub connection works
# 💡 Usage: git-doctor
function git-doctor() {
    _log_info "🔧 Checking Git..."

    if ! command -v git &>/dev/null; then
        _log_warning "⚠️  Git is not installed."
        _log_hint "💡 Install with: brew install git"
        return 1
    fi
    _log_success "✓ Git is installed."
    echo

    _log_info "🔧 Checking Git configuration..."
    if [[ -z $(git config user.name) || -z $(git config user.email) ]]; then
        _log_warning "⚠️  Git user.name or user.email not configured"
        _log_hint "💡 Set them with:"
        _log_hint "   git config --global user.name \"Your Name\""
        _log_hint "   git config --global user.email \"you@example.com\""
        echo
    else
        _log_success "✓ Git user.name and user.email are set"
        echo
    fi

    _log_info "📝 Checking for global .gitignore..."
    if git config --get core.excludesfile &>/dev/null; then
        _log_success "✓ Global .gitignore is configured"
        echo
    else
        _log_warning "⚠️  No global .gitignore set"
        _log_hint "💡 Tip: git config --global core.excludesfile ~/.gitignore_global"
        echo
    fi

    _log_info "🔧 Checking SSH key..."
    if [[ -f ~/.ssh/id_rsa.pub || -f ~/.ssh/id_ed25519.pub ]]; then
        _log_success "✓ SSH key found"
        echo
    else
        _log_warning "⚠️  No SSH key found in ~/.ssh/"
        _log_hint "💡 Generate one with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
        echo
    fi

    _log_info "🔐 Testing SSH connection to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        _log_success "✓ SSH connection to GitHub works"
        echo
    else
        _log_warning "⚠️  SSH connection to GitHub failed or requires verification"
        _log_hint "💡 Run: ssh -T git@github.com to test manually"
        echo
    fi

    return 0
}
