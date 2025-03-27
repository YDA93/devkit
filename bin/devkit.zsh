# 🔗 Entrypoint CLI script for DevKit

# Load config
source "$HOME/devkit/config.zsh"

# Load core
core_files=(aliases.zsh exports.zsh functions.zsh)
for file in "${core_files[@]}"; do
    source "$DEVKIT_ROOT/core/$file"
done

# Load modules
# ❗ NO quotes here ⬇
module_files=(${DEVKIT_MODULES_PATH}/**/*.zsh)

if ((${#module_files[@]} == 0)); then
    echo "⚠️  No modules found to load."
else
    for file in "${module_files[@]}"; do
        source "$file"
    done
fi

if [[ $ZSH_EVAL_CONTEXT == toplevel:* ]] && [[ -t 1 ]]; then
    echo "✅ DevKit fully loaded!"
fi
