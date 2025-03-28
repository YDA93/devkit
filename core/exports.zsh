# ─────────────────────────────────────────────
# 📦 Language & SDK Paths
# ─────────────────────────────────────────────

# 🍺 Homebrew opt prefix
export HOMEBREW_OPT_PREFIX="$(brew --prefix)/opt"

# /opt/homebrew/Cellar
export HOMEBREW_CELLAR="$(brew --prefix)/Cellar"

# ☕️ Java (latest) from the system
export JAVA_HOME=$(/usr/libexec/java_home -v 23)
export PATH="$JAVA_HOME/bin:$PATH"

# 🐍 Python 3.11
export PATH="$HOMEBREW_OPT_PREFIX/python@3.11/libexec/bin:$PATH"

# 🟢 Node.js 22
export PATH="$HOMEBREW_OPT_PREFIX/node@22/bin:$PATH"

# 💎 Ruby
export PATH="$HOMEBREW_OPT_PREFIX/ruby/bin:$PATH"

# 🐦 Flutter SDK
export PATH="$HOMEBREW_OPT_PREFIX/flutter/bin:$PATH"

# 📦 Dart Pub (used by Flutter/Dart)
export PATH="$HOMEBREW_OPT_PREFIX/.pub-cache/bin:$PATH"

# 🐘 PostgreSQL 16
export PATH="$HOMEBREW_OPT_PREFIX/postgresql@16/bin:$PATH"

# ☁️ Google Cloud SDK
export PATH="$HOMEBREW_OPT_PREFIX/google-cloud-sdk/bin:$PATH"

# 🤖 Android SDK root path (created by Android Studio or CLI tools)
export ANDROID_HOME="$HOME/Library/Android/sdk"

# 🛠️ Android SDK tools (sdkmanager, adb, etc.)
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
