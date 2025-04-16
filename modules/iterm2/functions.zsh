# ------------------------------------------------------------------------------
# 🧩 iTerm2 Initialization & Integration
# ------------------------------------------------------------------------------

# 🖥️ Sets up iTerm2 with a custom dynamic profile and key bindings
# 💡 Usage: iterm2-setup
function iterm2-setup() {
    local source_path="$DEVKIT_MODULES_DIR/iterm2/natural_text_editing.json"
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ ! -f "$source_path" ]]; then
        _log_error "✗ Profile not found: $source_path"
        return 1
    fi

    mkdir -p "$target_dir" || {
        _log_error "✗ Failed to create iTerm2 DynamicProfiles directory."
        return 1
    }

    cp "$source_path" "$target_path" || {
        _log_error "✗ Failed to copy profile to: $target_path"
        return 1
    }

    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "natural-text-editing" || {
        _log_error "✗ Failed to set default iTerm2 profile."
        return 1
    }

    killall iTerm2 &>/dev/null

}
