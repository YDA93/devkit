# Reload Zsh config
alias zsh-reload="source ~/.zshrc"

# Restart shell session
alias zsh-reset="exec zsh"

# Edit Zsh config
alias zsh-edit="code ~/.zshrc" # or use nano/vim if you prefer

# Show current shell path
alias zsh-which="echo $SHELL"

# Add Date and Time to the prompt
if [[ "$PROMPT" != *"%D{%d/%b/%y} %D{%L:%M:%S %p}"* ]]; then
    PROMPT='%{$fg[yellow]%}%D{%d/%b/%y} %D{%L:%M:%S %p} '$PROMPT
fi
