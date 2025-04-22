# ------------------------------------------------------------------------------
# 🎨 Powerlevel10k Installation & Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up Powerlevel10k with a custom configuration
# 💡 Usage: powerlevel10k-setup
function powerlevel10k-setup() {
    _log-inline_title "Meslo Nerd Font Install"
    font-install-meslo-nerd || return 1
    _log-inline_title "End of Meslo Nerd Font Install"
    echo

    _log-inline_title "Powerlevel10k Download"
    _log-info "⬇️ Downloading powerlevel10k from brew"
    brew install powerlevel10k
    _log-success "✓ Powerlevel10k installed successfully."
    _log-inline_title "End of Powerlevel10k Download"
    echo

    _log-inline_title "VS Code Font Set"
    code-font-set || return 1
    _log-inline_title "End of VS Code Font Set"
    echo

    _log-inline_title "Iterm2 Theme Setup"
    iterm2-theme-setup || return 1
    _log-inline_title "End of iTerm2 Theme Setup"
    echo

    _log-inline_title "Terminal Font Set"
    terminal-theme-setup
    _log-inline_title "End of Terminal Font Set"
    echo

    _log-success "✓ Powerlevel10k setup completed successfully."
    echo

}

# 🧹 Uninstalls Powerlevel10k
# 💡 Usage: powerlevel10k-uninstall
function powerlevel10k-uninstall() {
    _log-inline_title "Powerlevel10k Uninstall"
    _log-info "🧹 Uninstalling Powerlevel10k..."
    brew uninstall powerlevel10k
    _log-success "✓ Powerlevel10k uninstalled successfully."
    _log-inline_title "End of Powerlevel10k Uninstall"
    echo

    _log-inline_title "Meslo Nerd Font Uninstall"
    font-uninstall-meslo-nerd || return 1
    _log-inline_title "End of Meslo Nerd Font Uninstall"
    echo

    _log-inline_title "VS Code Font Unset"
    code-font-unset || return 1
    _log-inline_title "End of VS Code Font Unset"
    echo

    _log-inline_title "Iterm2 theme Uninstall"
    iterm2-theme-uninstall || return 1
    _log-inline_title "End of iTerm2 theme Uninstall"
    echo

    _log-inline_title "Terminal Font Unset"
    terminal-factory-reset || return 1
    _log-inline_title "End of Terminal Font Unset"
    echo

    _log-success "✓ Powerlevel10k uninstalled successfully."
    echo
}
