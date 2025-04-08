set -e

echo "🚀 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "✅ Oh My Zsh installed."

# Define what we want to append to .zshrc
DEVKIT_LINE='source "$PWD/devkit/bin/devkit.zsh"'

# Only add if it's not already there
if ! grep -Fxq "$DEVKIT_LINE" "$HOME/.zshrc"; then
    echo "➕ Adding DevKit source to ~/.zshrc..."
    echo "" >>"$HOME/.zshrc"
    echo "$DEVKIT_LINE" >>"$HOME/.zshrc"
else
    echo "ℹ️  DevKit already sourced in ~/.zshrc. Skipping."
fi

echo "🔁 Reloading ~/.zshrc..."
source "$HOME/.zshrc"

echo "✅ DevKit loaded and ready!"
