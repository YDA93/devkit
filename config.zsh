DEVKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-${0}}")" && pwd)"

export DEVKIT_ROOT
export DEVKIT_MODULES_DIR="$DEVKIT_ROOT/modules"
export DEVKIT_ENTRYPOINT="$DEVKIT_ROOT/bin/devkit.zsh"
