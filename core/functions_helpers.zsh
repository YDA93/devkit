# 🔄 Checks for and installs macOS updates
# 💡 Usage: _check-software-updates
function _check-software-updates() {
    # 🛠️ Installs all available macOS software updates (system + security)
    _log-info "🔍 Checking for macOS software updates..."

    # Check for available software updates
    available_updates=$(softwareupdate -l 2>&1)

    if echo "$available_updates" | grep -q "No new software available"; then
        _log-success "✓ No updates available."
        echo
        return 0
    else
        _log-info "⬇️  Updates available. Installing now..."
        softwareupdate -ia --verbose
        _log-success "✓ Updates installed successfully."
        _log-info "🔁 A system restart may be required to complete installation."
        _log-warning "⚠️  Please reboot your Mac and then re-run: devkit-pc-setup"
        echo
        return 1 # Signal that a reboot is needed
    fi
}
