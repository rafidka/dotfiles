# zsh/init.zsh - Main zsh initialization
# This file is sourced by activate.sh

# Order matters! PATH should come first, then oh-my-zsh, then everything else

# 1. PATH modifications (before oh-my-zsh so plugins can find tools)
source "${HOMEDIR_ROOT}/zsh/path.zsh"

# 2. Oh-my-zsh setup (this must come early as it sets up the shell environment)
source "${HOMEDIR_ROOT}/zsh/oh-my-zsh.zsh"

# 3. History configuration
source "${HOMEDIR_ROOT}/zsh/history.zsh"

# 4. FZF configuration
source "${HOMEDIR_ROOT}/zsh/fzf.zsh"

# 5. Custom functions
source "${HOMEDIR_ROOT}/zsh/functions.zsh"

# 6. Aliases (last, so they can use functions)
source "${HOMEDIR_ROOT}/zsh/aliases.zsh"

# 7. Local overrides (machine-specific, gitignored)
[[ -f "${HOMEDIR_ROOT}/zsh/local.zsh" ]] && source "${HOMEDIR_ROOT}/zsh/local.zsh" || true
