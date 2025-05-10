# Check if gum is available and store the result
command -v gum >/dev/null 2>&1 && GUM_AVAILABLE=1 || GUM_AVAILABLE=0

# ANSI color codes for fallback
RED='\033[0;31m'
GREEN='\033[38;5;49m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT_GRAY='\033[0;37m'
NO_COLOR='\033[0m'

# ✅ Prints a success message
# 💡 Usage: _log-success "Message"
function _log-success() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 42 "$@"
    else
        echo -e "${GREEN}$@${NO_COLOR}"
    fi
}

# ❌ Prints an error message
# 💡 Usage: _log-error "Message"
function _log-error() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 196 "$@"
    else
        echo -e "${RED}$@${NO_COLOR}"
    fi
}

# ⚠️ Prints a warning message
# 💡 Usage: _log-warning "Message"
function _log-warning() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 220 "$@"
    else
        echo -e "${YELLOW}$@${NO_COLOR}"
    fi
}

# ℹ️ Prints an informational message
# 💡 Usage: _log-info "Message"
function _log-info() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground 33 "$@"
    else
        echo -e "${CYAN}$@${NO_COLOR}"
    fi
}

# ℹ️ Prints an informational message (orange tone to match 🔸)
# 💡 Usage: _log-info "Message"
function _log-info-2() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground 208 "$@"
    else
        echo -e "\033[38;5;208m$@${NO_COLOR}"
    fi
}

# 💡 Prints a hint or tip message
# 💡 Usage: _log-hint "Message"
function _log-hint() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground 245 "$@"
    else
        echo -e "${LIGHT_GRAY}$@${NO_COLOR}"
    fi
}

# 🧩 Prints a section separator
# 💡 Usage: _log-separator [style...] [color]
# Styles:
#   - double   : uses double line character
#   - divided  : adds spacing between characters
# Color:
#   - Pass any number (e.g., 196) to set foreground color
function _log-separator() {
    local styles=("$@")
    local char="─"
    local separator=""
    local divided=false
    local color_code="245" # default light gray
    local color_fallback="${LIGHT_GRAY}"

    # Parse styles and color
    for style in "${styles[@]}"; do
        case "$style" in
        double)
            char="═"
            ;;
        divided)
            divided=true
            ;;
        '' | *[!0-9]*)
            # Not a number, skip
            ;;
        *)
            # If it's a number, treat it as color
            color_code="$style"
            color_fallback="\033[38;5;${color_code}m"
            ;;
        esac
    done

    # Build the separator
    if [[ $divided == true ]]; then
        for _ in {1..30}; do
            separator+="$char "
        done
        separator="${separator%" "}" # remove trailing space
    else
        for _ in {1..40}; do
            separator+="$char"
        done
    fi

    # Print with Gum or fallback
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --foreground "$color_code" "$separator"
    else
        echo -e "${color_fallback}${separator}${NO_COLOR}"
    fi
}

# 🖨️ Prints a section title (without a box)
# 💡 Usage: _log-title "Title"
function _log-title() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        _log-separator
        gum style --bold --foreground 51 "$@"
        _log-separator
    else
        echo -e "${CYAN}────────────────────────────────────────${NO_COLOR}"
        echo -e "${PURPLE}$@${NO_COLOR}"
        echo -e "${CYAN}────────────────────────────────────────${NO_COLOR}"
    fi
}

# 🖨️ Prints a stylized section title to terminal (Gum version)
# 💡 Usage: _log-section-title "Title"
function _log-section-title() {
    local title="$1"

    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style \
            --border normal \
            --padding "0 2" \
            --margin "0 0" \
            --bold \
            --foreground 33 \
            "$title"
    else
        echo -e "${CYAN}$title${NO_COLOR}"
    fi
}

# 🎉 Prints a final summary banner
# 💡 Usage: _log-summary "Summary text"
function _log-summary() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --border double --padding "1 3" --margin "2 0" --bold --foreground 42 "$@"
    else
        echo -e "${GREEN}$@${NO_COLOR}"
    fi
}

# ❓ Prints a question or prompt message
# 💡 Usage: _log-question "Question text"
function _log-question() {
    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --bold --foreground 45 "❓ $@"
    else
        echo -e "${BLUE}❓ $@${NO_COLOR}"
    fi
}

# 🔧 Logs a step with visible progress/status indicators (Gum, no spinner)
# 💡 Usage: _log-step <mode: setup|update> <step_number> <step_total> "Label" <command>
function _log-step() {
    local mode="$1" # setup or update
    local step_number="$2"
    local step_total="$3"
    local name="$4"
    shift 4

    local prefix="($step_number/$step_total)"

    # Choose wording based on mode
    local action
    if [[ "$mode" == "setup" ]]; then
        action="Setting up"
    else
        action="Updating"
    fi

    # Start step: show starting message
    echo
    _log-heading info "$prefix 🔧 $action $name"

    # Run the command
    if ! "$@"; then
        _log-heading error "$prefix ✗ $action failed: $name"
        return 1
    fi
    _log-separator 245 # double + divided, gray
}

# 🧩 Prints an inline title with light dividers
# 💡 Usage: _log-inline-title "Your title"
function _log-inline-title() {
    local title="$1"
    local divider="➖"
    local side_length=3

    local line
    for _ in $(seq 1 $side_length); do
        line+="$divider"
    done

    echo -e "$line $title $line"
}

# 🖨️ Prints a heading with a border (Gum version)
# 💡 Usage: _log-heading <type: info|error> "Heading text"
function _log-heading() {
    local type="$1"
    local title="$2"

    local color_code
    local color_fallback

    case "$type" in
    info)
        color_code=226
        color_fallback="${YELLOW}"
        ;;
    error)
        color_code=196
        color_fallback="${RED}"
        ;;
    *)
        color_code=226 # Default to info
        color_fallback="${YELLOW}"
        ;;
    esac

    if [[ $GUM_AVAILABLE -eq 1 ]]; then
        gum style --border rounded --padding "0 2" --margin "0 0" --foreground "$color_code" --bold "$title"
    else
        echo -e "${color_fallback}${title}${NO_COLOR}"
    fi
}

# 🧪 Runs a command, aborts if it fails, and prints custom messages
# 💡 Usage: _run-or-abort "Label" "Success Msg" <command>
function _run-or-abort() {
    local description="$1"
    local success_msg="$2"
    shift 2

    _log-info "$description..."
    "$@"
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        _log-error "✗ Failed: $description"
        return $exit_code
    fi
    if [ -n "$success_msg" ]; then
        _log-success "$success_msg"
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
            _log-info "🔹 Aborting action"
            echo
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
