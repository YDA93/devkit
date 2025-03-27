# ─────────────────────────────────────────────
# 🌍 Base Environment
# ─────────────────────────────────────────────
source "$HOME/devkit/exports.zsh"

# ─────────────────────────────────────────────
# 🍏 devkit Essentials
# ─────────────────────────────────────────────
source "$HOME/devkit/aliases.zsh"
source "$HOME/devkit/functions.zsh"

# ─────────────────────────────────────────────
# 🐘 Postgres
# ─────────────────────────────────────────────
source "$HOME/devkit/postgres/functions.zsh"

# ─────────────────────────────────────────────
# 🐍 Python
# ─────────────────────────────────────────────
source "$HOME/devkit/python/aliases.zsh"

# ─────────────────────────────────────────────
# 🌐 Django
# ─────────────────────────────────────────────
source "$HOME/devkit/django/aliases.zsh"
source "$HOME/devkit/django/functions.zsh"

# ─────────────────────────────────────────────
# 🐦 Flutter
# ─────────────────────────────────────────────
source "$HOME/devkit/flutter/aliases.zsh"
source "$HOME/devkit/flutter/functions.zsh"

# ─────────────────────────────────────────────
# 🐙 GitHub
# ─────────────────────────────────────────────
source "$HOME/devkit/github/functions.zsh"

# ─────────────────────────────────────────────
# 💻 Prompt Styling
# ─────────────────────────────────────────────
source "$HOME/devkit/prompts.zsh"

# ─────────────────────────────────────────────
# ☁️ Google Cloud
# ─────────────────────────────────────────────
source "$HOME/devkit/gcloud/aliases.zsh"
source "$HOME/devkit/gcloud/functions.zsh"
source "$HOME/devkit/gcloud/functions_storage_buckets.zsh"
source "$HOME/devkit/gcloud/functions_cloud_sql.zsh"
source "$HOME/devkit/gcloud/functions_cloud_run.zsh"
source "$HOME/devkit/gcloud/functions_secret_manager.zsh"
source "$HOME/devkit/gcloud/functions_artifact_registry.zsh"
source "$HOME/devkit/gcloud/functions_compute_engine.zsh"
source "$HOME/devkit/gcloud/functions_cloud_scheduler.zsh"

# ─────────────────────────────────────────────
# 🧪 Dotenv Helpers
# ─────────────────────────────────────────────
source "$HOME/devkit/dotenv/functions.zsh"

# ─────────────────────────────────────────────
# 💻 Code Utilities
# ─────────────────────────────────────────────
source "$HOME/devkit/code/functions.zsh"

# ─────────────────────────────────────────────
# 🍺 Homebrew
# ─────────────────────────────────────────────
source "$HOME/devkit/homebrew/functions.zsh"

# ─────────────────────────────────────────────
# 📦 NPM
# ─────────────────────────────────────────────
source "$HOME/devkit/npm/functions.zsh"

# ─────────────────────────────────────────────
# 📦 Ccache
# ─────────────────────────────────────────────
source "$HOME/devkit/ccache/exports.zsh"
