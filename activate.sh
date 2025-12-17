# activate.sh - Main entry point for dotfiles configuration
# Usage: Add to your .zshrc: source ~/dotfiles/activate.sh

# Guard: Only run in Zsh
if [[ -z "$ZSH_VERSION" ]]; then
    echo "Error: dotfiles only supports Zsh. Current shell: $SHELL" >&2
    return 1
fi

# Set DOTFILES to the directory containing this script
# ${0:A:h} is zsh-specific: :A resolves to absolute path, :h gets the directory
export DOTFILES="${0:A:h}"

# Source zsh configuration
source "${DOTFILES}/zsh/init.zsh"
