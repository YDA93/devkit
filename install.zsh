set -e

# ✅ Config
DEVKIT_REPO="https://github.com/YDA93/devkit.git"
DEVKIT_DIR="${DEVKIT_DIR:-$HOME/devkit}"
FORCE_INSTALL=false

# ✅ Parse arguments
for arg in "$@"; do
    case $arg in
    --force)
        FORCE_INSTALL=true
        shift
        ;;
    esac
done

# ✅ Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "⛔ Git is required to install DevKit. Please install Git and try again."
    exit 1
fi

# ✅ Detect if we are running from curl (remote script)
if [[ ! -f "$(pwd)/config.zsh" ]]; then
    # 🧩 Running remotely, let's clone and hand off

    if [[ -d "$DEVKIT_DIR" && "$(ls -A "$DEVKIT_DIR")" ]]; then
        if [[ "$FORCE_INSTALL" == true ]]; then
            echo "⚠️  Removing existing DevKit directory at $DEVKIT_DIR..."
            rm -rf "$DEVKIT_DIR"
        else
            echo "⛔ DevKit directory '$DEVKIT_DIR' already exists and is not empty."
            echo "👉 Use --force to overwrite: sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/YDA93/devkit/main/install.zsh)\" -- --force"
            exit 1
        fi
    fi

    echo "📦 Cloning DevKit into $DEVKIT_DIR..."
    git clone "$DEVKIT_REPO" "$DEVKIT_DIR"

    echo "🚀 Running DevKit installer from cloned directory..."
    exec zsh "$DEVKIT_DIR/install.zsh" "$@"
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

# ✅ Load config
source "$(pwd)/config.zsh"

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

# ✅ Launch a new shell
exec zsh -l
