# ─────────────────────────────────────────────
# 📦 Language & SDK Paths (optimized)
# ─────────────────────────────────────────────

# 🍺 Homebrew paths
eval "$(/opt/homebrew/bin/brew shellenv)"

if command -v brew &>/dev/null; then
    export HOMEBREW_PREFIX="$(brew --prefix)"
    export HOMEBREW_OPT_PREFIX="$HOMEBREW_PREFIX/opt"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# Enable Powerlevel10k instant prompt (safe for Bash shells)
if [ -n "$ZSH_VERSION" ]; then
    eval 'p10k_file="${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"'
    [[ -r "$p10k_file" ]] && source "$p10k_file"
fi

# Safely source Powerlevel10k if it exists
p10k_theme_path="$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
if [[ -f "$p10k_theme_path" ]]; then
    source "$p10k_theme_path"
fi

# To customize prompt, run `p10k configure` or edit "$DEVKIT_MODULES_DIR/powerlevel10k/.p10k.zsh".
[[ ! -f "$DEVKIT_MODULES_DIR/powerlevel10k/.p10k.zsh" ]] || source "$DEVKIT_MODULES_DIR/powerlevel10k/.p10k.zsh"

# 🧾 Extract top-level Homebrew formula from formulas.txt
if [[ -f "$DEVKIT_MODULES_DIR/homebrew/formulas.txt" ]]; then
    DEVKIT_REQUIRED_FORMULA=$(awk '!/^#/ && NF' "$DEVKIT_MODULES_DIR/homebrew/formulas.txt")
    export DEVKIT_REQUIRED_FORMULA
fi

# ☕ Java (latest openjdk@)
if LATEST_JAVA=$(echo "$DEVKIT_REQUIRED_FORMULA" | grep '^openjdk@' | sort -V | tail -n 1); then
    JAVA_VERSION="${LATEST_JAVA#openjdk@}"
    JAVA_HOME_CANDIDATE=$(/usr/libexec/java_home -v "$JAVA_VERSION" 2>/dev/null)
    if [[ -n "$JAVA_HOME_CANDIDATE" ]]; then
        export JAVA_HOME="$JAVA_HOME_CANDIDATE"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
fi

# 🐍 Python (latest python@)
if LATEST_PYTHON=$(echo "$DEVKIT_REQUIRED_FORMULA" | grep '^python@' | sort -V | tail -n 1); then
    # Python 3.11 is the default version
    # Change python@3.11 to $LATEST_PYTHON if you want to use the latest version
    export PATH="$HOMEBREW_OPT_PREFIX/python@3.11/libexec/bin:$PATH"
fi

# 🟢 Node.js (latest node@)
if LATEST_NODE=$(echo "$DEVKIT_REQUIRED_FORMULA" | grep '^node@' | sort -V | tail -n 1); then
    export PATH="$HOMEBREW_OPT_PREFIX/$LATEST_NODE/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_OPT_PREFIX/$LATEST_NODE/lib"
    export CPPFLAGS="-I$HOMEBREW_OPT_PREFIX/$LATEST_NODE/include"
fi

# 💎 Ruby
[[ -d "$HOMEBREW_OPT_PREFIX/ruby/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/ruby/bin:$PATH"

# 🐦 Flutter SDK
[[ -d "$HOMEBREW_OPT_PREFIX/flutter/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/flutter/bin:$PATH"

# 📦 Dart Pub
[[ -d "$HOME/.pub-cache/bin" ]] && export PATH="$HOME/.pub-cache/bin:$PATH"

# 🐘 PostgreSQL (latest postgresql@)
if LATEST_PG=$(echo "$DEVKIT_REQUIRED_FORMULA" | grep '^postgresql@' | sort -V | tail -n 1); then
    export PATH="$HOMEBREW_OPT_PREFIX/$LATEST_PG/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_OPT_PREFIX/$LATEST_PG/lib"
    export CPPFLAGS="-I$HOMEBREW_OPT_PREFIX/$LATEST_PG/include"
fi

# ☁️ Google Cloud SDK
[[ -d "$HOMEBREW_OPT_PREFIX/google-cloud-sdk/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/google-cloud-sdk/bin:$PATH"

# 🤖 Android SDK
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# Use ccache for compilers
[[ -d "$HOMEBREW_OPT_PREFIX/ccache/libexec" ]] && export PATH="$HOMEBREW_OPT_PREFIX/ccache/libexec:$PATH"

# Enable ngrok shell completion
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi
