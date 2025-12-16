# zsh/aliases.zsh - Shell aliases

# --- Directory listing ---
if [[ "$(uname)" == "Darwin" ]]; then
    alias ls='ls -GF'
else
    alias ls='ls --color=auto -F'
fi
alias ll='ls -lh'
alias la='ls -lah'
alias l='ls -1'

# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# --- Git shortcuts ---
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline -20'
alias glg='git log --oneline --graph --all'
alias gb='git branch'
alias gst='git stash'
alias gstp='git stash pop'

# --- System monitoring ---
if [[ "$(uname)" == "Darwin" ]]; then
    alias topmem='ps aux -m | head -20'
    alias topcpu='ps aux -r | head -20'
else
    alias topmem='ps aux --sort=-%mem | head -20'
    alias topcpu='ps aux --sort=-%cpu | head -20'
fi

# --- Utilities ---
alias newpass='openssl rand -base64 32'
alias py='python3'
alias ipy='ipython'
alias cls='clear'

# --- Clipboard (Linux) ---
if [[ "$(uname)" == "Linux" ]] && command -v xclip &> /dev/null; then
    alias xcopy='xclip -selection clipboard'
    alias xpaste='xclip -selection clipboard -o'
fi

# --- Quick edit ---
alias zshrc='${EDITOR:-vim} ~/.zshrc'
alias vimrc='${EDITOR:-vim} ~/.vim/vimrc'
alias homedirrc='${EDITOR:-vim} ${HOMEDIR_ROOT}/zsh/local.zsh'

# --- Grep with color ---
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# --- Safety ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
