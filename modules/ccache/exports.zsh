# ─────────────────────────────────────────────
# ⚙️  CCache Configuration
# ─────────────────────────────────────────────
export CCACHE_SLOPPINESS="clang_index_store,file_stat_matches,include_file_ctime,include_file_mtime,ivfsoverlay,pch_defines,modules,system_headers,time_macros"
export CCACHE_FILECLONE=true
export CCACHE_DEPEND=true
export CCACHE_INODECACHE=true
export CCACHE_LOGFILE="$DEVKIT_ROOT/ccache.log"
