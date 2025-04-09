set -e

# ✅ Config
DEVKIT_REPO="https://github.com/YDA93/devkit.git"
DEVKIT_DIR="${DEVKIT_DIR:-$HOME/devkit}"
FORCE_INSTALL=false
INTERNAL_FROM_CLONE=false

# ✅ Parse arguments
for arg in "$@"; do
    case $arg in
    --force)
        FORCE_INSTALL=true
        shift
        ;;
    --internal-from-clone)
        INTERNAL_FROM_CLONE=true
        shift
        ;;
    esac
done

# ✅ Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "⛔ Git is required to install DevKit. Please install Git and try again."
    exit 1
fi

# ✅ If running from clone, skip clone step
if [[ "$INTERNAL_FROM_CLONE" == false ]]; then
    if [[ -d "$DEVKIT_DIR" && "$(ls -A "$DEVKIT_DIR")" ]]; then
        if [[ "$FORCE_INSTALL" == true ]]; then
            echo "⚠️  Removing existing DevKit directory at $DEVKIT_DIR..."
            rm -rf "$DEVKIT_DIR"
        else
            echo "⛔ DevKit directory '$DEVKIT_DIR' already exists and is not empty."
            echo "👉 Use --force to overwrite: zsh -c \"\$(curl -fsSL https://raw.githubusercontent.com/YDA93/devkit/main/install.zsh)\" -- --force"
            exit 1
        fi
    fi

    echo "📦 Cloning DevKit into $DEVKIT_DIR..."
    git clone "$DEVKIT_REPO" "$DEVKIT_DIR"

    echo "🚀 Running DevKit installer from cloned directory..."
    exec zsh "$DEVKIT_DIR/install.zsh" --internal-from-clone "$@"
fi

# ✅ From this point, we're inside the cloned DevKit repo
echo "🚀 Checking for Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "✅ Oh My Zsh already installed. Skipping installation."
else
    echo "🧩 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "✅ Oh My Zsh installed."
fi

# ✅ Set DEVKIT_ROOT explicitly before sourcing config
export DEVKIT_ROOT="$(pwd)"
source "$DEVKIT_ROOT/config.zsh"

# ✅ Confirm DEVKIT_ROOT for debugging (optional)
echo "ℹ️  DEVKIT_ROOT is set to: $DEVKIT_ROOT"

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
echo "👉 Please restart your terminal or run: source ~/.zshrc"
echo "You can start using DevKit by typing: devkit"
echo ""

# ✅ Launch a new shell
exec zsh -l
