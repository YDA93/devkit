# 🧩 Main entrypoint (works safely in Zsh)

# Get the directory of this config.zsh file, reliably
DEVKIT_CONFIG_DIR="${0:A:h}"

export DEVKIT_ROOT="$DEVKIT_CONFIG_DIR"
export DEVKIT_MODULES_DIR="$DEVKIT_ROOT/modules"
export DEVKIT_ENTRYPOINT="$DEVKIT_ROOT/bin/devkit.zsh"
