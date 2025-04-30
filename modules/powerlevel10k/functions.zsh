# ------------------------------------------------------------------------------
# 🎨 Powerlevel10k Installation & Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up Powerlevel10k with a custom configuration
# 💡 Usage: powerlevel10k-set-font-meslo-nerd
function powerlevel10k-set-font-meslo-nerd() {
    _log-inline-title "Meslo Nerd Font Install"
    font-install-meslo-nerd || return 1
    _log-inline-title "End of Meslo Nerd Font Install"
    echo

    _log-inline-title "VS Code Font Set"
    code-font-set || return 1
    _log-inline-title "End of VS Code Font Set"
    echo

    _log-inline-title "iTerm2 Font Set"
    iterm2-set-font-meslo-nerd || return 1
    _log-inline-title "End of iTerm2 Font Set"
    echo

    _log-inline-title "Terminal Font Set"
    terminal-set-font-meslo-nerd || return 1
    _log-inline-title "End of Terminal Font Set"
    echo
}

# 🧹 Uninstalls Powerlevel10k
# 💡 Usage: powerlevel10k-unset-font-meslo-nerd
function powerlevel10k-unset-font-meslo-nerd() {
    _log-inline-title "Meslo Nerd Font Uninstall"
    font-uninstall-meslo-nerd || return 1
    _log-inline-title "End of Meslo Nerd Font Uninstall"
    echo

    _log-inline-title "VS Code Font Unset"
    code-font-unset || return 1
    _log-inline-title "End of VS Code Font Unset"
    echo

    _log-inline-title "iTerm2 Font Unset"
    iterm2-set-font-default || return 1
    _log-inline-title "End of iTerm2 Font Unset"
    echo

    _log-inline-title "Terminal Font Unset"
    terminal-set-font-default || return 1
    _log-inline-title "End of Terminal Font Unset"
    echo
}
