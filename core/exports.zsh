# ─────────────────────────────────────────────
# 📦 Language & SDK Paths (optimized)
# ─────────────────────────────────────────────

# 🍺 Homebrew paths
if command -v brew &>/dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"

    export HOMEBREW_PREFIX="$(brew --prefix)"
    export HOMEBREW_OPT_PREFIX="$HOMEBREW_PREFIX/opt"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
fi

# 🧾 Extract top-level Homebrew formula from formulas.txt
if [[ -f "$DEVKIT_MODULES_PATH/homebrew/formulas.txt" ]]; then
    DEVKIT_REQUIRED_FORMULAE=$(awk '!/^#/ && NF' "$DEVKIT_MODULES_PATH/homebrew/formulas.txt")
    export DEVKIT_REQUIRED_FORMULAE
fi

# ☕ Java (latest openjdk@)
if LATEST_JAVA=$(echo "$DEVKIT_REQUIRED_FORMULAE" | grep '^openjdk@' | sort -V | tail -n 1); then
    JAVA_VERSION="${LATEST_JAVA#openjdk@}"
    JAVA_HOME_CANDIDATE=$(/usr/libexec/java_home -v "$JAVA_VERSION" 2>/dev/null)
    if [[ -n "$JAVA_HOME_CANDIDATE" ]]; then
        export JAVA_HOME="$JAVA_HOME_CANDIDATE"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi
fi

# 🐍 Python (latest python@)
if LATEST_PYTHON=$(echo "$DEVKIT_REQUIRED_FORMULAE" | grep '^python@' | sort -V | tail -n 1); then
    export PATH="$HOMEBREW_OPT_PREFIX/$LATEST_PYTHON/libexec/bin:$PATH"
fi

# 🟢 Node.js (latest node@)
if LATEST_NODE=$(echo "$DEVKIT_REQUIRED_FORMULAE" | grep '^node@' | sort -V | tail -n 1); then
    export PATH="$HOMEBREW_OPT_PREFIX/$LATEST_NODE/bin:$PATH"
    export LDFLAGS="-L$HOMEBREW_OPT_PREFIX/$LATEST_NODE/lib"
    export CPPFLAGS="-I$HOMEBREW_OPT_PREFIX/$LATEST_NODE/include"
fi

# 💎 Ruby
[[ -d "$HOMEBREW_OPT_PREFIX/ruby/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/ruby/bin:$PATH"

# 🐦 Flutter SDK
[[ -d "$HOMEBREW_OPT_PREFIX/flutter/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/flutter/bin:$PATH"

# 📦 Dart Pub
[[ -d "$HOMEBREW_OPT_PREFIX/.pub-cache/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/.pub-cache/bin:$PATH"

# 🐘 PostgreSQL (latest postgresql@)
if LATEST_PG=$(echo "$DEVKIT_REQUIRED_FORMULAE" | grep '^postgresql@' | sort -V | tail -n 1); then
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
