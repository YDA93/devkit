# ─────────────────────────────────────────────
# 📦 Language & SDK Paths (optimized)
# ─────────────────────────────────────────────

# 🍺 Homebrew paths
export HOMEBREW_PREFIX="$(brew --prefix)"
export HOMEBREW_OPT_PREFIX="$HOMEBREW_PREFIX/opt"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"

# 🧾 Extract top-level Homebrew formulae from formulaes.txt
DEVKIT_REQUIRED_FORMULAE=$(awk '!/^#/ && NF' "$DEVKIT_MODULES_PATH/homebrew/formulaes.txt")

export DEVKIT_REQUIRED_FORMULAE

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
fi

# ☁️ Google Cloud SDK
[[ -d "$HOMEBREW_OPT_PREFIX/google-cloud-sdk/bin" ]] && export PATH="$HOMEBREW_OPT_PREFIX/google-cloud-sdk/bin:$PATH"

# 🤖 Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
