# zsh/history.zsh - History configuration

HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

# History options
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first when trimming
setopt HIST_IGNORE_DUPS          # Ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicates from history
setopt HIST_IGNORE_SPACE         # Ignore commands starting with space
setopt HIST_FIND_NO_DUPS         # No duplicates when searching history
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY               # Show command before executing from history
setopt SHARE_HISTORY             # Share history between sessions
setopt INC_APPEND_HISTORY        # Add commands immediately to history
