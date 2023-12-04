# Python Path
export PATH="/opt/homebrew/opt/python@3.10/libexec/bin:$PATH"

# Java Path
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Flutter Path
export PATH="$PATH:/Users/yousefalmutairi/flutter/bin"

# Ruby Path
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# Pub Path
export PATH="$PATH":"$HOME/.pub-cache/bin"
export CCACHE_SLOPPINESS=clang_index_store,file_stat_matches,include_file_ctime,include_file_mtime,ivfsoverlay,pch_defines,modules,system_headers,time_macros
export CCACHE_FILECLONE=true
export CCACHE_DEPEND=true
export CCACHE_INODECACHE=true
export CCACHE_LOGFILE=/Users/yousefalmutairi/Desktop/dev/ccache.log
