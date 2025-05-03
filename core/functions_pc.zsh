# 🌐 Display both local and public IP addresses of this machine
# 📡 Local IP (from Wi-Fi interface `en0`), 🌍 Public IP (from external service)
# 💡 Usage: devkit-pc-ip-address
function devkit-pc-ip-address() {
    _log-info "🔹 Fetching local IP address (Wi-Fi interface: en0)..."
    local local_ip
    local_ip=$(ipconfig getifaddr en0) || {
        _log-error "✗ Failed to retrieve local IP address"
        return 1
    }
    _log-success "Local IP address: $local_ip"
    echo ""

    _log-info "🔹 Fetching public IP address..."
    local public_ip
    public_ip=$(curl -s https://ipinfo.io/ip) || {
        _log-error "✗ Failed to retrieve public IP address"
        return 1
    }
    _log-success "Public IP address: $public_ip"
}

# 🧼 Clear system and user cache directories
# ⚠️ Requires appropriate permissions to clear `/Library/Caches`
# 💡 Usage: devkit-pc-clear-cache
function devkit-pc-clear-cache() {
    _log-info "🔹 Clearing system and user cache folders..."

    rm -rf ~/Library/Caches/* /Library/Caches/* || {
        _log-error "✗ Failed to clear cache folders"
        return 1
    }

    _log-success "✓ Caches cleared"
}

# 🗑️ Empty the user's Trash folder
# ⚠️ Uses sudo to ensure all items are removed (some may be protected)
# 💡 Usage: devkit-pc-empty-trash
function devkit-pc-empty-trash() {
    _log-info "🔹 Emptying Trash folder..."

    sudo rm -rf ~/.Trash/* || {
        _log-error "✗ Failed to empty Trash"
        return 1
    }

    _log-success "✓ Trash emptied"
}

# 💻 Show macOS version information (Product name, version, build)
# 💡 Usage: devkit-pc-version
function devkit-pc-version() {
    _log-info "🔹 Fetching macOS version information..."

    sw_vers || {
        _log-error "✗ Failed to retrieve macOS version info"
        return 1
    }
}

# 🔋 Display battery status and health details (charge %, time remaining, condition)
# 💡 Usage: devkit-pc-battery
function devkit-pc-battery() {
    _log-info "🔹 Fetching battery status..."

    pmset -g batt || {
        _log-error "✗ Failed to retrieve battery info"
        return 1
    }
}

# 💽 Show disk space usage for all mounted volumes in human-readable format
# 💡 Usage: devkit-pc-disk
function devkit-pc-disk() {
    _log-info "🔹 Fetching disk usage information..."

    df -h || {
        _log-error "✗ Failed to retrieve disk usage"
        return 1
    }
}

# 📊 Display snapshot of top CPU and memory resource usage
# 🧠 Shows first 10 lines of `top` output for quick overview
# 💡 Usage: devkit-pc-stats
function devkit-pc-stats() {
    _log-info "🔹 Fetching system resource usage..."

    top -l 1 | head -n 10 || {
        _log-error "✗ Failed to retrieve system stats"
        return 1
    }
}

# 🧹 Flush the DNS cache on macOS to clear outdated or incorrect DNS records
# 🛠️ Useful for resolving DNS-related connectivity issues
# 💡 Usage: devkit-pc-dns-flush
function devkit-pc-dns-flush() {
    _log-info "🔹 Flushing DNS cache..."

    sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder || {
        _log-error "✗ Failed to flush DNS cache"
        return 1
    }

    _log-success "✓ DNS cache flushed"
}

# 📡 Ping Google's public DNS server (8.8.8.8) to test internet connectivity
# 💡 Usage: devkit-pc-ping
function devkit-pc-ping() {
    _log-info "🔹 Pinging 8.8.8.8 (Google DNS)..."

    ping -c 4 8.8.8.8 || {
        _log-error "✗ Ping failed. No internet connection or DNS issue"
        return 1
    }

    _log-success "✓ Internet connection appears active"
}
