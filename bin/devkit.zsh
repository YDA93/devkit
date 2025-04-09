# 🔗 Entrypoint CLI script for DevKit

# Load config
source "$(cd "$(dirname "$0")" && pwd)/../config.zsh"

# Load core files dynamically
core_files=(${DEVKIT_ROOT}/core/*.zsh)

if ((${#core_files[@]} == 0)); then
    echo "⚠️  No core files found to load."
else
    for file in "${core_files[@]}"; do
        source "$file"
    done
fi

# Load module files recursively
module_files=(${DEVKIT_MODULES_DIR}/**/*.zsh)

if ((${#module_files[@]} == 0)); then
    echo "⚠️  No modules found to load."
else
    for file in "${module_files[@]}"; do
        source "$file"
    done
fi

# Check if DevKit is fully set up
if ! devkit-is-setup --quiet; then
    echo "⛔ DevKit is not fully set up."
    echo "👉 Please run: devkit-pc-setup"
fi
