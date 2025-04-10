# Check if DEVKIT_ROOT is already set (e.g., by install.zsh)
# If not, determine the DevKit root directory dynamically based on the current script location
# This ensures compatibility when sourcing config.zsh directly, outside of the installer
if [ -z "$DEVKIT_ROOT" ]; then
    # Get the directory of the currently executing script
    export DEVKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" && pwd)"
fi

export DEVKIT_MODULES_DIR="$DEVKIT_ROOT/modules"
export DEVKIT_ENTRYPOINT="$DEVKIT_ROOT/bin/devkit.zsh"
