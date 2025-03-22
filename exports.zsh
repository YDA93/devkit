# Python version 3.11 Path
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

# Node version 22 Path
export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

# Java Path
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Ruby Path
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Flutter Path
export PATH="$PATH:/Users/yousefalmutairi/flutter/bin"

# Pub Path (for Dart & Flutter)
export PATH="$PATH:$HOME/.pub-cache/bin"

# CCACHE
export CCACHE_SLOPPINESS=clang_index_store,file_stat_matches,include_file_ctime,include_file_mtime,ivfsoverlay,pch_defines,modules,system_headers,time_macros
export CCACHE_FILECLONE=true
export CCACHE_DEPEND=true
export CCACHE_INODECACHE=true
export CCACHE_LOGFILE=/Users/yousefalmutairi/Desktop/dev/ccache.log
