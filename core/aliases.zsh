# 🌐 Get the local IP address (Wi-Fi interface)
alias devkit-pc-ip-address="ipconfig getifaddr en0"

# 🔁 Restart the Mac immediately
alias devkit-pc-restart="sudo shutdown -r now"

# 📴 Shut down the Mac immediately
alias devkit-pc-shutdown="sudo shutdown -h now"

# 🐚 Restart into a clean Bash session
alias devkit-bash-reset="exec bash"

# 🔁 Restart the Terminal app (macOS only)
alias devkit-terminal-restart="osascript -e 'tell application \"Terminal\" to close every window' && exit"

# 🌍 Get the current public IP address
alias devkit-pc-public-ip="curl -s https://ipinfo.io/ip"

# 🧹 Flush the DNS cache (macOS)
alias devkit-pc-dns-flush="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder && _log_success '✅ DNS cache flushed.'"

# 📡 Ping Google DNS (check internet connection)
alias devkit-pc-ping="ping -c 4 8.8.8.8"

# 💻 Show macOS version info
alias devkit-pc-version="sw_vers"

# 🔋 Show battery status and health info
alias devkit-pc-battery="pmset -g batt"

# 💽 Show disk space usage in human-readable format
alias devkit-pc-disk="df -h"

# 📊 Show top system resource usage (CPU/RAM)
alias devkit-pc-stats="top -l 1 | head -n 10"

# 🧼 Clear system and user cache folders
alias devkit-pc-clear-cache="rm -rf ~/Library/Caches/* /Library/Caches/* && _log_success '🧹 Caches cleared.'"

# 🗑️ Empty the trash folder
alias devkit-pc-empty-trash="sudo rm -rf ~/.Trash/* && _log_success '🗑️ Trash emptied.'"

# 🐚 Show shell, interpreter, and version info
alias devkit-shell-info="echo \$SHELL && echo \$0 && echo \$ZSH_VERSION"
