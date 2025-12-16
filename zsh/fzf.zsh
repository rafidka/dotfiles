# zsh/fzf.zsh - FZF configuration

# Source fzf if installed
if [[ -f "${HOME}/.fzf.zsh" ]]; then
    source "${HOME}/.fzf.zsh"
fi

# FZF default options
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Use fd if available for faster file finding
if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Alt-C: cd into selected directory
if command -v fd &> /dev/null; then
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# Preview file contents with bat if available
if command -v bat &> /dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
fi
