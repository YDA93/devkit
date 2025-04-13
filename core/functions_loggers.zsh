# Check if gum is available and store the result
command -v gum >/dev/null 2>&1 && GUM_AVAILABLE=1 || GUM_AVAILABLE=0

# ANSI color codes for fallback
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
NO_COLOR='\033[0m'

# ✅ Prints a success message
# 💡 Usage: _log_success "Message"
function _log_success() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 42 "$@"
    else
        echo -e "${GREEN}$@${NO_COLOR}"
    fi
}

# ❌ Prints an error message
# 💡 Usage: _log_error "Message"
function _log_error() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 196 "$@"
    else
        echo -e "${RED}$@${NO_COLOR}"
    fi
}

# ⚠️ Prints a warning message
# 💡 Usage: _log_warning "Message"
function _log_warning() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 220 "$@"
    else
        echo -e "${YELLOW}$@${NO_COLOR}"
    fi
}

# ℹ️ Prints an informational message
# 💡 Usage: _log_info "Message"
function _log_info() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground 33 "$@"
    else
        echo -e "${CYAN}$@${NO_COLOR}"
    fi
}

# 💡 Prints a hint or tip message
# 💡 Usage: _log_hint "Message"
function _log_hint() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground 245 "$@"
    else
        echo -e "${LIGHT_GRAY}$@${NO_COLOR}"
    fi
}

# 🏁 Prints a section separator
# 💡 Usage: _log_separator
function _log_separator() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground 245 "────────────────────────────────────────"
    else
        echo -e "${LIGHT_GRAY}────────────────────────────────────────${NO_COLOR}"
    fi
}

# 🖨️ Prints a section title (without a box)
# 💡 Usage: _log_title "Title"
function _log_title() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 51 "$@"
    else
        echo -e "${PURPLE}$@${NO_COLOR}"
    fi
}

# 🖨️ Prints a stylized section title to terminal (Gum version)
# 💡 Usage: _log_section_title "Title"
function _log_section_title() {
    local title="$1"

    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style \
            --border normal \
            --padding "0 2" \
            --margin "1 0" \
            --bold \
            --foreground 33 \
            "$title"
    else
        echo -e "${CYAN}$title${NO_COLOR}"
    fi
}

# 🎉 Prints a final summary banner
# 💡 Usage: _log_summary "Summary text"
function _log_summary() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --border double --padding "1 3" --margin "2 0" --bold --foreground 42 "$@"
    else
        echo -e "${GREEN}$@${NO_COLOR}"
    fi
}

# ❓ Prints a question or prompt message
# 💡 Usage: _log_question "Question text"
function _log_question() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 45 "❓ $@"
    else
        echo -e "${BLUE}❓ $@${NO_COLOR}"
    fi
}

# 🔧 Logs a step with visible progress/status indicators (Gum, no spinner)
# 💡 Usage: _log-update-step "Label" <command>
function _log-update-step() {
    local name="$1"
    shift

    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --border rounded --padding "0 2" --margin "1 0" --foreground 33 --bold "🔧 Updating $name"
    else
        echo -e "${CYAN}🔧 Updating $name${NO_COLOR}"
    fi

    if "$@"; then
        echo
        if [[ $GUM_AVAILABLE -eq 1 ]]; then
            gum style --border rounded --padding "0 2" --margin "1 0" --foreground 42 --bold "✅ Update complete: $name"
        else
            echo -e "${GREEN}✅ Update complete: $name${NO_COLOR}"
        fi
    else
        echo
        if [[ $GUM_AVAILABLE -eq 1 ]]; then
            gum style --border rounded --padding "0 2" --margin "1 0" --foreground 196 --bold "❌ Update failed: $name"
        else
            echo -e "${RED}❌ Update failed: $name${NO_COLOR}"
        fi
    fi
}

# 🧪 Runs a command, aborts if it fails, and prints custom messages
# 💡 Usage: _run-or-abort "Label" "Success Msg" <command>
function _run-or-abort() {
    local description="$1"
    local success_msg="$2"
    shift 2

    echo "$description..."
    "$@"
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        _log_error "❌ Failed: $description"
        return $exit_code
    fi
    if [ -n "$success_msg" ]; then
        _log_success "$success_msg"
        echo ""
    fi
}

# 🛑 Asks the user for confirmation before continuing
# 💡 Usage: _confirm-or-abort "Prompt?" [--quiet]
function _confirm-or-abort() {
    local message="$1"
    shift # Remove the first argument (message) from the list

    # Check if --quiet flag is present
    for arg in "$@"; do
        if [[ "$arg" == "--quiet" ]]; then
            return 0
        fi
    done

    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        if gum confirm "$message"; then
            return 0
        else
            _log_info "Aborting action."
            return 1
        fi
    else
        echo -e "${BLUE}❓ $message (y/n)${NO_COLOR}"
        read -r response
        case "$response" in
        [Yy]*) return 0 ;;
        *)
            echo -e "${CYAN}Aborting action.${NO_COLOR}"
            return 1
            ;;
        esac
    fi
}
