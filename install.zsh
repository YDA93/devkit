set -e

# ✅ Config
DEVKIT_REPO="https://github.com/YDA93/devkit.git"
DEVKIT_DIR="${DEVKIT_DIR:-$HOME/devkit}"

# ✅ Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "⛔ Git is required to install DevKit. Please install Git and try again."
    exit 1
fi

# ✅ Check if we are inside cloned directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ✅ Detect if running from inside the cloned repository
if [[ "$SCRIPT_DIR" != "$DEVKIT_DIR" ]]; then
    # ✅ First time: check if directory exists
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

    echo "🚀 Running DevKit installer from cloned directory..."
    exec zsh "$DEVKIT_DIR/install.zsh"
fi

# ✅ Set DEVKIT_ROOT
export DEVKIT_ROOT="$SCRIPT_DIR"

# ✅ Source config
source "$DEVKIT_ROOT/config.zsh"

# ✅ Confirm DEVKIT_ROOT for debugging
echo "ℹ️  DEVKIT_ROOT is set to: $DEVKIT_ROOT"

# ✅ Check for Oh My Zsh
echo "🚀 Checking for Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ Oh My Zsh already installed. Skipping installation."
else
    echo "🧩 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed."
fi

# ✅ Define what we want to append to .zshrc
DEVKIT_LINE="source \"$DEVKIT_ENTRYPOINT\""

# ✅ Add DevKit to .zshrc if not already added
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

echo "✅ DevKit loaded and ready!"

# ✅ Final success message
echo ""
echo "🎉 Installation complete!"
echo ""

source ~/.zshrc && devkit-pc-setup
