# activate.sh - Main entry point for homedir configuration
# Usage: Add to your .zshrc: source ~/homedir/activate.sh

# Guard: Only run in Zsh
if [[ -z "$ZSH_VERSION" ]]; then
    echo "Error: homedir only supports Zsh. Current shell: $SHELL" >&2
    return 1
fi

# Set HOMEDIR_ROOT to the directory containing this script
# ${0:A:h} is zsh-specific: :A resolves to absolute path, :h gets the directory
export HOMEDIR_ROOT="${0:A:h}"

# Source zsh configuration
source "${HOMEDIR_ROOT}/zsh/init.zsh"
