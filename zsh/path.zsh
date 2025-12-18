# zsh/path.zsh - PATH modifications and environment variables

# Helper function to prepend to PATH only if directory exists and not already in PATH
path_prepend() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}

# Helper function to append to PATH only if directory exists and not already in PATH
path_append() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$PATH:$1"
    fi
}

# User's local bin directories (higher priority)
path_prepend "${HOME}/.local/bin"
path_prepend "${HOME}/bin"

# Dotfiles bin directory
path_prepend "${DOTFILES}/bin"

# Common development tools
path_prepend "${HOME}/.cargo/bin"      # Rust
path_prepend "${HOME}/go/bin"          # Go

# FZF (if installed in standard location)
[[ -d "${HOME}/.fzf/bin" ]] && path_prepend "${HOME}/.fzf/bin"

# Default editor
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"

# Vim configuration - use VIMINIT to source our vimrc without symlinks
export VIMINIT="source ${DOTFILES}/vim/vimrc"
