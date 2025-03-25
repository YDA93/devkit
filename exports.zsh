# ─────────────────────────────────────────────
# 📦 Language & SDK Paths
# ─────────────────────────────────────────────

# 🐍 Python 3.11
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

# 🟢 Node.js 22
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# ☕️ Java 11
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# 💎 Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# 🐦 Flutter SDK
export PATH="$PATH:$HOME/flutter/bin"

# 📦 Dart Pub (used by Flutter/Dart)
export PATH="$PATH:$HOME/.pub-cache/bin"

# ─────────────────────────────────────────────
# ⚙️  CCache Configuration
# ─────────────────────────────────────────────
export CCACHE_SLOPPINESS="clang_index_store,file_stat_matches,include_file_ctime,include_file_mtime,ivfsoverlay,pch_defines,modules,system_headers,time_macros"
export CCACHE_FILECLONE=true
export CCACHE_DEPEND=true
export CCACHE_INODECACHE=true
export CCACHE_LOGFILE="$HOME/Desktop/dev/ccache.log"
