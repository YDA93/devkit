# 🔗 Entrypoint CLI script for DevKit

# Load config
source "$HOME/devkit/config.zsh"

# Load core
source "$DEVKIT_ROOT/core/aliases.zsh"
source "$DEVKIT_ROOT/core/exports.zsh"
source "$DEVKIT_ROOT/core/functions.zsh"

# Enable Zsh glob features
setopt null_glob
setopt extended_glob

# Load modules
# ❗ NO quotes here ⬇
module_files=(${DEVKIT_MODULES_PATH}/**/*.zsh)

if [[ ${#module_files[@]} -eq 0 ]]; then
    echo "⚠️  No modules found to load."
else
    for file in "${module_files[@]}"; do
        source "$file"
    done
fi

[[ $ZSH_EVAL_CONTEXT == toplevel:* ]] && echo "✅ DevKit fully loaded!"
