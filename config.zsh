# 🧩 Main entrypoint (works safely in Zsh)
export DEVKIT_ROOT="$(cd "$(dirname "$0")" && pwd)"
export DEVKIT_MODULES_DIR="$DEVKIT_ROOT/modules"
export DEVKIT_ENTRYPOINT="$DEVKIT_ROOT/bin/devkit.zsh"
