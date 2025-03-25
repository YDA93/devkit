# ─────────────────────────────────────────────
# ☁️ Google Cloud SDK Setup
# ─────────────────────────────────────────────

# Add gcloud to PATH if available
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# Enable gcloud CLI completion
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi
