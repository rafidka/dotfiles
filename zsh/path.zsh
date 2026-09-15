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

# Default editor (Neovim only - see nvim/init.lua)
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"

# Neovim finds our config through the ~/.config/nvim/init.lua wrapper that
# install.sh writes, so no VIMINIT and no symlinks are needed here. Unset it in
# case an older version of these dotfiles exported it into this shell: it would
# now point at a deleted file, and plain Vim cannot parse our Lua config anyway.
unset VIMINIT

# Python REPL startup file
export PYTHONSTARTUP="${DOTFILES}/python/pythonrc.py"

