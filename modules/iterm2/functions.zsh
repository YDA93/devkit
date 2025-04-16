# ------------------------------------------------------------------------------
# 🧩 iTerm2 Installation & Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up iTerm2 with a custom profile and font
# 💡 Usage: iterm2-setup
function iterm2-setup() {
    _log_inline_title "Iterm2 Download"
    _log_info "⬇️ Downloading iTerm2 from brew"
    brew install --cask iterm2 || {
        _log_error "✗ Failed to install iTerm2."
        echo
        return 1
    }
    _log_success "✓ iTerm2 installed successfully."
    _log_inline_title "End of iTerm2 Download"
    echo

    powerlevel10k-setup || return 1

    _log_inline_title "Iterm2 Profile Setup"
    iterm2-profile-setup || return 1
    _log_inline_title "End of iTerm2 Profile Setup"
    echo

    _log_success "✓ iTerm2 setup completed successfully."

    _log_hint "💡 Please restart both Terminal and iTerm2 to fully apply the changes."
    echo
}

# 🧹 Uninstalls iTerm2 and its profile and font
# 💡 Usage: iterm2-uninstall
function iterm2-uninstall() {
    _log_inline_title "Iterm2 Uninstall"
    _log_info "🧹 Uninstalling iTerm2..."
    brew uninstall --cask iterm2
    _log_success "✓ iTerm2 uninstalled successfully."
    _log_inline_title "End of iTerm2 Uninstall"
    echo

    _log_inline_title "Iterm2 Profile Uninstall"
    iterm2-profile-uninstall || return 1
    _log_inline_title "End of iTerm2 Profile Uninstall"
    echo

    powerlevel10k-uninstall || return 1

    _log_success "✓ iTerm2 uninstalled successfully."
    echo
}

# ------------------------------------------------------------------------------
# 👤 iTerm2 Profile Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up iTerm2 with a custom dynamic profile and key bindings
# 💡 Usage: iterm2-profile-setup
function iterm2-profile-setup() {
    _log_info "🖥️ Setting up iTerm2 profile..."

    local source_path="$DEVKIT_MODULES_DIR/iterm2/natural_text_editing.json"
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ ! -f "$source_path" ]]; then
        _log_error "✗ Profile not found: $source_path"
        echo
        return 1
    fi

    mkdir -p "$target_dir" || {
        _log_error "✗ Failed to create iTerm2 DynamicProfiles directory."
        echo
        return 1
    }

    cp "$source_path" "$target_path" || {
        _log_error "✗ Failed to copy profile to: $target_path"
        echo
        return 1
    }

    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "natural-text-editing" || {
        _log_error "✗ Failed to set default iTerm2 profile."
        echo
        return 1
    }

    _log_success "✓ iTerm2 profile installed successfully. Please restart iTerm2."
    echo

    if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        iterm2-restart-via-terminal
    else
        _log_info "Restarting iTerm2 from outside (e.g. Terminal)..."
        osascript -e 'tell application "iTerm" to quit'
        sleep 1
        open -a iTerm
    fi
}

# 🔁 Restarts iTerm2 from Terminal.app without killing its own shell
# 💡 Usage: iterm2-restart-via-terminal
function iterm2-restart-via-terminal() {
    _log_info "🔁 Restarting iTerm2 via Terminal.app proxy..."
    defaults write com.googlecode.iterm2 PromptOnQuit -bool false

    echo
    _log_hint "⚠️  macOS may ask for permission to allow Terminal and iTerm to control each other."
    _log_hint "👉 To allow automation:"
    _log_hint "   System Settings → Privacy & Security → Automation"
    echo

    if gum confirm "👉 Open Automation settings now?"; then
        open "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation"
        if ! gum confirm "👉 Restart iTerm2 now?"; then
            _log_info "⏸️  Skipping iTerm2 restart."
            return 0
        fi
    fi

    osascript <<'EOF'
tell application "Terminal"
  activate
  if not (exists window 1) then
    do script ""
  end if
  do script "
    echo '🛠 Quitting iTerm2...';
    osascript -e 'tell application \"iTerm\" to quit';
    sleep 1;

    echo '🚀 Reopening iTerm2...';
    open -a iTerm;

    echo '📡 Waiting for iTerm2 to come online...';
    while ! pgrep -x iTerm2 >/dev/null; do sleep 0.5; done;

    echo '🧹 Asking iTerm2 to close this Terminal window...';
    osascript -e '
      tell application \"iTerm\"
        delay 1
        tell current window
          tell current session
            write text \"sleep 2.5; osascript -e \\\"tell application \\\\\\\"Terminal\\\\\\\" to close front window\\\"; exit\"
          end tell
          create tab with default profile
        end tell
      end tell
    ';
  " in front window
end tell
EOF
}

# 🧹 Uninstalls iTerm2 profile
# 💡 Usage: iterm2-profile-uninstall
function iterm2-profile-uninstall() {
    _log_info "🧹 Uninstalling iTerm2 profile..."
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ -f "$target_path" ]]; then
        rm "$target_path" || {
            _log_error "✗ Failed to remove iTerm2 profile: $target_path"
            echo
            return 1
        }
    else
        _log_info "✓ No iTerm2 profile found to remove."
    fi

    defaults delete com.googlecode.iterm2 "Default Bookmark Guid"

    _log_success "✓ iTerm2 profile uninstalled successfully."
    echo
}
