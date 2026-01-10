# zsh/functions.zsh - Custom shell functions

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick temp directory
t() {
    local tmpdir="${HOME}/temp"
    mkdir -p "$tmpdir"
    cd "$tmpdir"
}

# Extract various archive formats
extract() {
    if [[ ! -f "$1" ]]; then
        echo "'$1' is not a valid file" >&2
        return 1
    fi

    case "$1" in
        *.tar.bz2)   tar xjf "$1"    ;;
        *.tar.gz)    tar xzf "$1"    ;;
        *.tar.xz)    tar xJf "$1"    ;;
        *.bz2)       bunzip2 "$1"    ;;
        *.rar)       unrar x "$1"    ;;
        *.gz)        gunzip "$1"     ;;
        *.tar)       tar xf "$1"     ;;
        *.tbz2)      tar xjf "$1"    ;;
        *.tgz)       tar xzf "$1"    ;;
        *.zip)       unzip "$1"      ;;
        *.Z)         uncompress "$1" ;;
        *.7z)        7z x "$1"       ;;
        *)           echo "Cannot extract '$1': unknown format" >&2; return 1 ;;
    esac
}

# Search file contents with fzf and open in vim
fzf_search_content() {
    if ! command -v fzf &> /dev/null; then
        echo "fzf is not installed" >&2
        return 1
    fi

    local file line
    if command -v rg &> /dev/null; then
        read -r file line <<< $(rg --line-number --no-heading . 2>/dev/null | fzf --delimiter=: --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null || head -100 {1}' | awk -F: '{print $1, $2}')
    else
        read -r file line <<< $(grep -rn . 2>/dev/null | fzf | awk -F: '{print $1, $2}')
    fi

    if [[ -n "$file" ]]; then
        ${EDITOR:-vim} "$file" "+$line"
    fi
}

# # Fuzzy checkout git branch
# gco() {
#     if ! command -v fzf &> /dev/null; then
#         echo "fzf is not installed" >&2
#         return 1
#     fi
# 
#     local branches branch
#     branches=$(git branch -a --color=always | grep -v HEAD) || return
#     branch=$(echo "$branches" | fzf --ansi --preview 'git log --oneline --graph --color=always $(echo {} | sed "s/.* //" | sed "s#remotes/[^/]*/##")' | sed "s/.* //" | sed "s#remotes/[^/]*/##")
# 
#     if [[ -n "$branch" ]]; then
#         git checkout "$branch"
#     fi
# }
