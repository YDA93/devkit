# ─────────────────────────────────────────────
# 🌍 Base Environment
# ─────────────────────────────────────────────
source "$HOME/macOS/external_completions.zsh" # CLI completions
source "$HOME/macOS/exports.zsh"              # Environment variables
source "$HOME/macOS/replacements.zsh"         # Command overrides

# ─────────────────────────────────────────────
# 🍏 macOS Essentials
# ─────────────────────────────────────────────
source "$HOME/macOS/aliases.zsh"
source "$HOME/macOS/functions.zsh"

# ─────────────────────────────────────────────
# 🐘 Postgres
# ─────────────────────────────────────────────
source "$HOME/macOS/postgres/functions.zsh"

# ─────────────────────────────────────────────
# 🐍 Python
# ─────────────────────────────────────────────
source "$HOME/macOS/python/aliases.zsh"

# ─────────────────────────────────────────────
# 🌐 Django
# ─────────────────────────────────────────────
source "$HOME/macOS/django/aliases.zsh"
source "$HOME/macOS/django/functions.zsh"

# ─────────────────────────────────────────────
# 🐦 Flutter
# ─────────────────────────────────────────────
source "$HOME/macOS/flutter/aliases.zsh"
source "$HOME/macOS/flutter/functions.zsh"

# ─────────────────────────────────────────────
# 🐙 GitHub
# ─────────────────────────────────────────────
source "$HOME/macOS/github/functions.zsh"

# ─────────────────────────────────────────────
# 💻 Prompt Styling
# ─────────────────────────────────────────────
source "$HOME/macOS/prompts.zsh"

# ─────────────────────────────────────────────
# ☁️ Google Cloud
# ─────────────────────────────────────────────
source "$HOME/macOS/gcloud/aliases.zsh"
source "$HOME/macOS/gcloud/functions.zsh"
source "$HOME/macOS/gcloud/functions_storage_buckets.zsh"
source "$HOME/macOS/gcloud/functions_cloud_sql.zsh"
source "$HOME/macOS/gcloud/functions_cloud_run.zsh"
source "$HOME/macOS/gcloud/functions_secret_manager.zsh"
source "$HOME/macOS/gcloud/functions_artifact_registry.zsh"
source "$HOME/macOS/gcloud/functions_compute_engine.zsh"
source "$HOME/macOS/gcloud/functions_cloud_scheduler.zsh"

# ─────────────────────────────────────────────
# 🧪 Dotenv Helpers
# ─────────────────────────────────────────────
source "$HOME/macOS/dotenv/functions.zsh"

# ─────────────────────────────────────────────
# 💻 Code Utilities
# ─────────────────────────────────────────────
source "$HOME/macOS/code/functions.zsh"
