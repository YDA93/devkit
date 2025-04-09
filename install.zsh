set -e

echo "🚀 Checking for Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ Oh My Zsh already installed. Skipping installation."
else
    echo "🧩 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed."
fi

# Load config
source "$(cd "$(dirname "$0")" && pwd)/config.zsh"

# Define what we want to append to .zshrc
DEVKIT_LINE="source \"$DEVKIT_ENTRYPOINT\""

# Only add if it's not already there
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

exec zsh -l
