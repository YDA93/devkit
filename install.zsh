set -e

# ✅ Define install directory (default to ~/devkit)
DEVKIT_DIR="${DEVKIT_DIR:-$HOME/devkit}"

# ✅ Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "⛔ Git is required to install DevKit. Please install Git and try again."
    exit 1
fi

# ✅ If this script is being run remotely (not from local file), clone the repo
# Check if we are already in the cloned directory by checking if config.zsh exists
if [[ ! -f "$(dirname "$0")/config.zsh" ]]; then
    echo "📦 Cloning DevKit into $DEVKIT_DIR..."
    git clone https://github.com/YDA93/devkit.git "$DEVKIT_DIR"
    echo "🚀 Running DevKit installer from cloned directory..."
    exec zsh "$DEVKIT_DIR/install.zsh"
fi

# ✅ From this point onwards, we're inside the cloned repo and can continue as normal

echo "🚀 Checking for Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ Oh My Zsh already installed. Skipping installation."
else
    echo "🧩 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed."
fi

# ✅ Load config
source "$(cd "$(dirname "$0")" && pwd)/config.zsh"

# ✅ Define what we want to append to .zshrc
DEVKIT_LINE="source \"$DEVKIT_ENTRYPOINT\""

# ✅ Only add if it's not already there
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

# ✅ Launch a new shell
exec zsh -l
