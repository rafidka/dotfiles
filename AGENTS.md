# AGENTS.md - Guide for AI Coding Agents

Personal dotfiles for Zsh and Vim. Clone to `~/dotfiles` and activate via
`source ~/dotfiles/activate.sh` in `.zshrc`. **Zsh-only**, no bash support.

## Validation Commands

```bash
bash -n install.sh              # Check bash script syntax
bash -n bin/<script>
zsh -n activate.sh              # Check zsh file syntax
zsh -n zsh/*.zsh
reload                          # Reload config (or: source ~/dotfiles/activate.sh)
vim -u vim/vimrc +PlugStatus +qall  # Test vim config
```

## Directory Structure

```
activate.sh          # Entry point (zsh guard, sets DOTFILES, sources init.zsh)
install.sh           # First-time setup (bash)
bin/                 # Executable scripts (added to PATH)
fedora/              # Fedora-specific tools (only loaded on Fedora)
  bin/               # Fedora-specific scripts
  toolbox/           # Toolbox container definitions
zsh/
  init.zsh           # Sources modules in order
  path.zsh           # PATH, EDITOR, VIMINIT
  fedora.zsh         # Fedora-specific config (sourced on Fedora only)
  aliases.zsh        # Shell aliases
  functions.zsh      # Shell functions
  local.zsh          # Machine-specific (gitignored)
vim/
  vimrc              # Main vim config (shared vim/neovim)
  lua/               # Neovim-specific Lua config
    nvim-config.lua  # Treesitter, LSP, completion setup
  after/ftplugin/    # Filetype-specific settings
```

## Activation Flow

```
~/.zshrc
  └─> source ~/dotfiles/activate.sh
        ├─> Check $ZSH_VERSION (error + return 1 if not zsh)
        ├─> Set DOTFILES="${0:A:h}"
        └─> source zsh/init.zsh
              ├─> path.zsh      (PATH, EDITOR, VIMINIT)
              ├─> oh-my-zsh.zsh (framework, theme, plugins)
              ├─> history.zsh   (history settings)
              ├─> fzf.zsh       (fuzzy finder)
              ├─> functions.zsh (shell functions)
              ├─> aliases.zsh   (aliases)
              ├─> fedora.zsh    (Fedora only: adds fedora/bin to PATH)
              └─> local.zsh     (if exists)
```

## How Vim Works (No Symlinks)

1. `zsh/path.zsh` sets `VIMINIT="source ${DOTFILES}/vim/vimrc"`
2. Vim reads `VIMINIT` and sources our vimrc
3. `vim/vimrc` uses `expand('<sfile>:p:h')` to find its directory
4. Sets `runtimepath` to include our vim directory

```vim
let s:vimdir = expand('<sfile>:p:h')
execute 'set runtimepath^=' . s:vimdir
execute 'set runtimepath+=' . s:vimdir . '/after'
```

## Code Style

### Bash Scripts (bin/, install.sh)

```bash
#!/bin/bash
set -euo pipefail

show_help() {
    cat << EOF
Usage: script [OPTIONS] ARGUMENTS
Description here.
EOF
}
```

**Patterns:**
- Always `set -euo pipefail` at top
- Use `[[ ]]` for conditionals, `command -v` to check commands
- Quote variables: `"$var"`, use `${var:-default}` for defaults
- Use `${1:-}` for safe positional args with `set -u`
- Errors to stderr: `echo "Error: msg" >&2`, exit 1 on error

### Zsh Files (zsh/*.zsh)

```zsh
# zsh/example.zsh - Brief description
# No shebang - sourced, not executed

if [[ ! -f "$1" ]]; then
    echo "Error: message" >&2
    return 1  # Use return, not exit (files are sourced)
fi
```

**Patterns:**
- No shebang (files are sourced)
- Use `return` not `exit`
- Zsh syntax allowed: `${0:A:h}`, `${var:=default}`
- Header comment: `# zsh/filename.zsh - Description`

### Shell Functions

```zsh
# Brief description
function_name() {
    local var="value"  # Always use local
    # implementation
}
```

### Python Scripts (bin/pq, etc.)

```python
#!/usr/bin/env python3
"""Script description. Usage: ..."""
import sys

def main():
    if len(sys.argv) > 1 and sys.argv[1] in ('-h', '--help'):
        print(__doc__)
        sys.exit(0)
    # implementation

if __name__ == '__main__':
    main()
```

**Patterns:**
- Module docstring with usage
- Type hints: `def func(data: str) -> str:`
- Errors to stderr: `print("Error: ...", file=sys.stderr)`

### Vim Config (vim/vimrc, vim/after/ftplugin/*.vim)

```vim
" Description
let s:vimdir = expand('<sfile>:p:h')  " s: prefix for script-local
set option=value
```

Filetype plugins use `setlocal`:
```vim
setlocal textwidth=88
setlocal expandtab tabstop=4
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Bin scripts | lowercase-hyphenated | `docker-shell` |
| Zsh files | lowercase.zsh | `aliases.zsh` |
| Shell functions | lowercase_underscores | `path_prepend` |
| Shell variables | UPPER_SNAKE | `DOTFILES` |
| Local variables | lowercase | `local tmpdir` |
| Vim script-local | s: prefix | `s:vimdir` |

## Error Handling

```bash
# Check command exists
command -v docker &>/dev/null || { echo "Error: Docker not found" >&2; exit 1; }

# Check file/dir exists
[[ -f "$1" ]] || { echo "Error: File not found" >&2; return 1; }
[[ -d "$path" ]] || { echo "Error: Dir not found" >&2; exit 1; }
```

## Adding Components

**New alias:** Edit `zsh/aliases.zsh`, add under appropriate section
**New function:** Edit `zsh/functions.zsh`, add brief comment above
**New bin script:** Create in `bin/`, include `show_help()`, support `-h/--help`
**New vim plugin:** Add `Plug 'author/plugin'` in `vim/vimrc`
**New filetype:** Create `vim/after/ftplugin/<type>.vim` with `setlocal`
**New Fedora tool:** Create in `fedora/bin/` or `fedora/toolbox/`

## Constraints

- **Zsh-only**: Guard in activate.sh rejects other shells
- **No symlinks**: Vim uses `VIMINIT` env var, not `~/.vimrc`
- **Self-contained**: All files in `~/dotfiles/`
- **local.zsh gitignored**: Machine-specific settings go there
- **Use return not exit**: In sourced files, `exit` closes the shell

## Cross-Platform

```bash
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
else
    # Linux
fi
```

Used for: `ls` colors, `ps` syntax, clipboard commands.

## Fedora-Specific

Files in `fedora/` directory are only loaded on Fedora systems. Detection uses `/etc/os-release`:

```bash
if grep -qi "^ID=fedora" /etc/os-release 2>/dev/null; then
    # Fedora-specific config
fi
```

**fedora/bin/** - Scripts added to PATH on Fedora only
**fedora/toolbox/** - Containerfile definitions for `toolbox create`

---

## Reference

### Environment Variables

| Variable | Description |
|----------|-------------|
| `DOTFILES` | Absolute path to dotfiles directory |
| `VIMINIT` | Tells vim to source our vimrc |
| `ZSH` | Path to oh-my-zsh (`~/.oh-my-zsh`) |
| `EDITOR` | Default editor (vim) |

### Vim Plugins

- **vim-code-dark** - VSCode-like colorscheme
- **vim-airline** - Status line (vim-only)
- **fzf.vim** - Fuzzy finder integration (vim-only)
- **python-syntax** - Enhanced Python highlighting
- **vim-commentary**, **vim-surround**, **vim-fugitive** - Utilities
- **vim-autopep8** - Python formatting
- **vim-gitgutter** - Git diff in gutter
- **vim-which-key** - Shows available keybindings popup (vim-only)

**Neovim-only plugins:**
- **nvim-tree** - File explorer sidebar
- **nvim-web-devicons** - File icons
- **nvim-treesitter** - Better syntax highlighting
- **nvim-lspconfig** - LSP configuration
- **nvim-cmp** - Autocompletion (with buffer, path, cmdline sources)
- **LuaSnip** - Snippet engine
- **telescope.nvim** - Fuzzy finder (replaces fzf.vim)
- **lualine.nvim** - Statusline (replaces vim-airline)
- **which-key.nvim** - Keybinding helper (replaces vim-which-key)
- **lazygit.nvim** - LazyGit integration
- **diffview.nvim** - Git diff viewer
- **persistence.nvim** - Session management (auto-save/restore)
- **bufferline.nvim** - Tab bar with buffer management

### Vim Key Mappings (Leader = Space)

| Mapping | Action |
|---------|--------|
| `<Space>` | Show which-key popup (wait 500ms) |
| `<Space><Space>` | Shortcut picker (FZF in vim, Telescope in neovim) |
| **File/Find (`<Space>f`)** | |
| `<Space>ff` | Find files |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>fg` | Find git files |
| `<Space>fh` | File history |
| `<Space>fs` | Document symbols (neovim) |
| `<Space>fd` | Diagnostics (neovim) |
| `<Space>fk` | All keymaps (neovim) |
| `<Space>fr` | Resume last search (neovim) |
| `<Space>fe` / `<Space>e` | File explorer (neovim) |
| **Search (`<Space>s`)** | |
| `<Space>ss` | Search in project (grep) |
| `<Space>sw` | Search word under cursor |
| `<Space>sb` | Search in buffer |
| `<Space>sr` | Search & replace |
| `<Space>sR` | Replace word under cursor |
| `<Space>sn` | Clear search highlight |
| **Code (`<Space>c`)** | |
| `<Space>cf` | Format buffer |
| `<Space>cr` | Rename symbol |
| `<Space>ca` | Code action |
| `<Space>cd` | Line diagnostics |
| `<Space>ci` | Organize imports |
| **Git (`<Space>g`)** | |
| `<Space>gg` | Open LazyGit (neovim) |
| `<Space>gd` | Open diff view (neovim) |
| `<Space>gh` | File git history (neovim) |
| `<Space>gH` | Branch git history (neovim) |
| `<Space>gf` | LazyGit file history (neovim) |
| `<Space>gq` | Close diff view (neovim) |
| **LSP (`<Space>l`)** | |
| `<Space>lr` | LSP rename (neovim) |
| `<Space>la` | LSP code action (neovim) |
| `<Space>lf` | LSP format (neovim) |
| `<Space>ld` | LSP diagnostics (neovim) |
| **Tabs (`<Space>t`)** | |
| `<Space>th` | Previous tab |
| `<Space>tn` | Next tab |
| `<Space>td` | Close current tab |
| `<Space>to` | Close other tabs |
| `<Space>tl` / `tr` | Close tabs left/right |
| `<Space>tp` | Pin/unpin tab |
| `<Space>ts` | Pick tab (letter indicators) |
| `<Space>tf` | Find tab (fuzzy search) |
| `<Space>t1-9` | Jump to tab 1-9 |
| **UI Toggles (`<Space>u`)** | |
| `<Space>un` | Toggle line numbers |
| `<Space>ur` | Toggle relative numbers |
| `<Space>uw` | Toggle word wrap |
| `<Space>us` | Toggle spell check |
| `<Space>ul` | Toggle list chars |
| `<Space>uc` | Toggle cursor line |
| `<Space>ud` | Toggle diagnostics |
| `<Space>ut` | Toggle treesitter highlight |
| **Session (`<Space>q`)** | |
| `<Space>qs` | Restore session (cwd) |
| `<Space>ql` | Restore last session |
| `<Space>qS` | Save session |
| `<Space>qd` | Don't save session |
| **Quick Actions** | |
| `<Space>w` / `q` / `x` | Save / Quit / Save+Quit |
| `<Space>/` | Clear highlight (vim) / Search in buffer (neovim) |
| `<Space>y` / `p` / `P` | System clipboard yank/paste |
| `<Space>ap` | Run autopep8 |
| **Navigation** | |
| `[d` / `]d` | Previous/next diagnostic (neovim) |
| `gd` | Go to definition (neovim LSP) |
| `gr` | Find references (neovim LSP) |
| `K` | Hover documentation (neovim LSP) |

### Shell Functions

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `t` | cd to ~/temp (creates if needed) |
| `extract <file>` | Extract various archive formats |
| `fzf_search_content` | Search file contents, open in vim |

### Bin Scripts

| Command | Description |
|---------|-------------|
| `help [category]` | Show aliases, functions, scripts |
| `docker-shell <name>` | Shell into container (partial match) |
| `docker-clean` | Remove all containers and images |
| `docker-purge` | Remove ALL Docker resources |
| `ffind <pattern>` | Fuzzy find files/directories |
| `ffind-fzf [query]` | Interactive file finder with fzf |
| `mem_usage <proc>` | Memory usage by process name |
| `proctree [user]` | Show process tree for user |
| `pyclean [dir]` | Remove .venv, __pycache__, .pyc |
| `pq [file]` | Convert Python literals to JSON |
| `sumcol [col]` | Sum numeric column from stdin |
| `dotenv-export [file]` | Export .env as shell commands |
| `topspace [N] [path]` | List N largest files/dirs |
| `gsget <gs://path>` | Download from Google Cloud Storage |
