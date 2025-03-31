# ─────────────────────────────────────────────
# ⚙️  CCache Configuration
# ─────────────────────────────────────────────
export CCACHE_SLOPPINESS="clang_index_store,file_stat_matches,include_file_ctime,include_file_mtime,ivfsoverlay,pch_defines,modules,system_headers,time_macros"
export CCACHE_FILECLONE=true
export CCACHE_DEPEND=true
export CCACHE_INODECACHE=true

CCACHE_LOGDIR="$DEVKIT_ROOT/logs/ccache"
mkdir -p "$CCACHE_LOGDIR"
export CCACHE_LOGFILE="$CCACHE_LOGDIR/ccache.log"
