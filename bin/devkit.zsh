# 🔗 Entrypoint CLI script for DevKit

# Load config
source "$HOME/devkit/config.zsh"

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
module_files=(${DEVKIT_MODULES_PATH}/**/*.zsh)

if ((${#module_files[@]} == 0)); then
    echo "⚠️  No modules found to load."
else
    for file in "${module_files[@]}"; do
        source "$file"
    done
fi

# Show message only if sourced directly in terminal
if [[ $ZSH_EVAL_CONTEXT == toplevel:* ]] && [[ -t 1 ]]; then
    echo "✅ DevKit fully loaded!"
fi
