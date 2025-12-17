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

# Ctrl-F: Search file contents with ag and fzf, open in vim
fzf-ag-content-widget() {
    if ! command -v ag &> /dev/null; then
        zle -M "ag (silver searcher) is not installed"
        return 1
    fi
    if ! command -v fzf &> /dev/null; then
        zle -M "fzf is not installed"
        return 1
    fi

    local result file line
    result=$(ag --nobreak --noheading --color . 2>/dev/null | \
        fzf --ansi --delimiter=: \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null || head -100 {1}' \
            --preview-window '+{2}-10')

    if [[ -n "$result" ]]; then
        file=$(echo "$result" | awk -F: '{print $1}')
        line=$(echo "$result" | awk -F: '{print $2}')
        BUFFER="${EDITOR:-vim} ${(q)file} +$line"
        zle accept-line
        return
    fi
    zle reset-prompt
}
zle -N fzf-ag-content-widget
bindkey '^F' fzf-ag-content-widget

# Ctrl-G: Fuzzy git status - select modified files to open in vim
fzf-git-status-widget() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        zle -M "Not in a git repository"
        return 1
    fi

    local files
    files=$(git status -s | fzf --ansi --multi \
        --preview 'git diff --color=always {2}' \
        --preview-window 'right:60%' | awk '{print $2}')

    if [[ -n "$files" ]]; then
        BUFFER="${EDITOR:-vim} ${files}"
        zle accept-line
        return
    fi
    zle reset-prompt
}
zle -N fzf-git-status-widget
bindkey '^G' fzf-git-status-widget
