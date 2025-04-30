# ------------------------------------------------------------------------------
# 👤 iTerm2 Theme Setup
# ------------------------------------------------------------------------------

# 🖥️ Sets up iTerm2 with a custom dynamic profile and key bindings
# 💡 Usage: iterm2-theme-setup
function iterm2-theme-setup() {
    if [ ! -d "/Applications/iTerm.app" ]; then
        return 0
    fi

    font-install-meslo-nerd || return 1

    _log-info "🖥️  Setting up iTerm2 theme..."

    local source_path="$DEVKIT_MODULES_DIR/iterm2/natural_text_editing.json"
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ ! -f "$source_path" ]]; then
        _log-error "✗ Profile not found: $source_path"
        echo
        return 1
    fi

    mkdir -p "$target_dir" || {
        _log-error "✗ Failed to create iTerm2 DynamicProfiles directory."
        echo
        return 1
    }

    cp "$source_path" "$target_path" || {
        _log-error "✗ Failed to copy profile to: $target_path"
        echo
        return 1
    }

    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "natural-text-editing" || {
        _log-error "✗ Failed to set default iTerm2 profile."
        echo
        return 1
    }

    _log-success "✓ iTerm2 theme installed successfully. Please close and reopen iTerm2 to apply the changes."
    echo
}

# 🧹 Uninstalls iTerm2 Theme
# 💡 Usage: iterm2-theme-uninstall
function iterm2-theme-uninstall() {
    _log-info "🧹 Uninstalling iTerm2 theme..."
    local target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local target_path="$target_dir/natural_text_editing.json"

    if [[ -f "$target_path" ]]; then
        rm "$target_path" || {
            _log-error "✗ Failed to remove iTerm2 profile: $target_path"
            echo
            return 1
        }
    else
        _log-info "✓ No iTerm2 profile found to remove."
        return 0
    fi

    defaults delete com.googlecode.iterm2 "Default Bookmark Guid"

    _log-success "✓ iTerm2 theme uninstalled successfully."
    echo
}

# 🖥️  Set iTerm2’s default profile to Meslo Nerd Font (Regular, 13 pt)
# 💡  Usage:  iterm2-set-font-meslo-nerd
function iterm2-set-font-meslo-nerd() {
    _log-info "🖥️  Setting iTerm2 font to MesloLGS-NF-Regular 11..."
    # Returns 0 (success) if the first profile uses exactly MesloLGS-NF-Regular 11,
    # otherwise returns 1.
    function check_iterm_font() {
        local want="MesloLGS-NF-Regular 11"
        local plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

        # read the Normal Font key of profile 0
        local have
        have=$(/usr/libexec/PlistBuddy \
            -c 'Print :"New Bookmarks":0:"Normal Font"' \
            "$plist" 2>/dev/null) || return 1

        [[ "$have" == "$want" ]] && return 0 || return 1
    }

    if check_iterm_font; then
        _log-success "✓ iTerm2 font already set to MesloLGS-NF-Regular 11"
        return 0
    fi

    local plist=~/Library/Preferences/com.googlecode.iterm2.plist
    local size=11

    # 1.  Grab the GUID of the default profile
    local guid
    guid=$(/usr/libexec/PlistBuddy -c "Print :'Default Bookmark Guid'" "$plist" 2>/dev/null) ||
        {
            echo "⚠️  Cannot read $plist"
            return 1
        }
    guid=${guid//[$'\t\r\n ']/}

    # 2.  Find the array index that owns that GUID
    local idx
    for i in {0..99}; do
        local g=$(/usr/libexec/PlistBuddy -c "Print :'New Bookmarks':$i:Guid" "$plist" 2>/dev/null) || break
        [[ ${g//[$'\t\r\n ']/} == "$guid" ]] && {
            idx=$i
            break
        }
    done
    [[ $idx =~ ^[0-9]+$ ]] || {
        _log-warning "⚠️  Default profile not found."
        return 1
    }

    # 3.  Apply the font to both ASCII and non-ASCII slots
    /usr/libexec/PlistBuddy \
        -c "Set :'New Bookmarks':$idx:'Normal Font' 'MesloLGS-NF-Regular $size'" \
        -c "Set :'New Bookmarks':$idx:'Non Ascii Font' 'MesloLGS-NF-Regular $size'" \
        "$plist" || return

    # 4.  Flush the prefs cache so the change sticks
    killall cfprefsd &>/dev/null
    _log-success "✓ iTerm2 font set to MesloLGS-NF-Regular $size (will show after you restart iTerm2)"
}

# 🖥️  Restore iTerm2’s default profile font (clears any override)
# 💡  Usage:  iterm2-set-font-default
function iterm2-set-font-default() {
    local plist=~/Library/Preferences/com.googlecode.iterm2.plist # prefs live here  [oai_citation:1‡iterm2.com](https://iterm2.com/faq.html?utm_source=chatgpt.com)

    # 1. get GUID of the default profile
    local guid=$(/usr/libexec/PlistBuddy -c "Print :'Default Bookmark Guid'" "$plist" 2>/dev/null) ||
        {
            echo "⚠️  Cannot read $plist"
            return 1
        }
    guid=${guid//[$'\t\r\n ']/}

    # 2. find its index inside the New Bookmarks array
    local idx
    for i in {0..99}; do
        local g=$(/usr/libexec/PlistBuddy -c "Print :'New Bookmarks':$i:Guid" "$plist" 2>/dev/null) || break
        [[ ${g//[$'\t\r\n ']/} == "$guid" ]] && {
            idx=$i
            break
        }
    done
    [[ $idx =~ ^[0-9]+$ ]] || {
        echo "⚠️  Default profile not found."
        return 1
    }

    # 3. delete the two font keys to revert to Monaco 12
    /usr/libexec/PlistBuddy \
        -c "Delete :'New Bookmarks':$idx:'Normal Font'" \
        -c "Delete :'New Bookmarks':$idx:'Non Ascii Font'" \
        "$plist" 2>/dev/null

    # 4. flush the prefs cache
    killall cfprefsd &>/dev/null
    echo "✓ Default profile font cleared (will show Monaco 12 after you restart iTerm2)"
}
