# zsh/oh-my-zsh.zsh - Oh-My-Zsh configuration

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme configuration
ZSH_THEME="agnoster"

# Plugins to load
plugins=(
    git
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
)

# Oh-my-zsh settings
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"

# Load oh-my-zsh
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    echo "Warning: oh-my-zsh not found. Run install.sh to set it up." >&2
fi

# Custom prompt modifications (after oh-my-zsh loads)
# Override agnoster prompt segments if desired

# Context segment: show user@host only when relevant
prompt_context() {
    if [[ -n "$HOMEDIR_PROMPT_LABEL" ]]; then
        prompt_segment red default "$HOMEDIR_PROMPT_LABEL"
    elif [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        prompt_segment red default "%(!.%{%F{yellow}%}.)$USER@%m"
    fi
}

# Python virtualenv display
prompt_virtualenv() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        prompt_segment blue black "($(basename $VIRTUAL_ENV))"
    elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        prompt_segment blue black "(c:$CONDA_DEFAULT_ENV)"
    fi
}
