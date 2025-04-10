set -e # Exit immediately if any command exits with a non-zero status

# Configuration
DEVKIT_REPO="https://github.com/YDA93/devkit.git"
DEVKIT_DIR="${DEVKIT_DIR:-$HOME/devkit}" # Allow overriding target install directory via ENV variable

# Check if Git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "⛔ Git is required to install DevKit. Please install Git and try again."
    exit 1
fi

# Determine the directory of this script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if running from within the target install directory
if [[ "$SCRIPT_DIR" != "$DEVKIT_DIR" ]]; then
    # If DevKit directory exists and is not empty, prompt user before overwriting
    if [[ -d "$DEVKIT_DIR" && "$(ls -A "$DEVKIT_DIR")" ]]; then
        echo "⚠️  DevKit directory '$DEVKIT_DIR' already exists and is not empty."
        echo ""
        echo -n "❓ Do you want to overwrite it? [y/N]: "
        read user_choice
        case "$user_choice" in
        [Yy]*)
            echo "🧹 Removing existing DevKit directory..."
            rm -rf "$DEVKIT_DIR"
            ;;
        *)
            echo "🚫 Installation cancelled by user."
            exit 1
            ;;
        esac
    fi

    echo "📦 Cloning DevKit into $DEVKIT_DIR..."
    git clone "$DEVKIT_REPO" "$DEVKIT_DIR"

    echo "🚀 Relaunching installer from cloned directory..."
    exec zsh "$DEVKIT_DIR/install.zsh"
fi

# Set the root directory for DevKit to this script's location
export DEVKIT_ROOT="$SCRIPT_DIR"

# Load additional configuration
source "$DEVKIT_ROOT/config.zsh"

# Ensure Oh My Zsh is installed (required dependency)
echo "🚀 Checking for Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh already installed. Skipping installation."
else
    echo "🧩 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "Oh My Zsh installed."
fi

# Prepare the line to source DevKit in .zshrc
DEVKIT_LINE="source \"$DEVKIT_ENTRYPOINT\""

# Add DevKit to .zshrc if not already present
if ! grep -Fxq "$DEVKIT_LINE" "$HOME/.zshrc"; then
    echo "➕ Adding DevKit source to ~/.zshrc..."
    {
        echo ""
        echo "# 🔧 DevKit setup (added by installer)"
        echo "$DEVKIT_LINE"
    } >>"$HOME/.zshrc"
else
    echo "ℹ️  DevKit already sourced in ~/.zshrc. Skipping."
fi

# Final success message
echo ""
echo "🎉 Installation complete!"
echo ""

# Apply the changes immediately and run initial setup
source ~/.zshrc && devkit-pc-setup
