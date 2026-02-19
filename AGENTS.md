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
zsh/
  init.zsh           # Sources modules in order
  path.zsh           # PATH, EDITOR, VIMINIT
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
- **vim-airline** - Status line
- **fzf.vim** - Fuzzy finder integration
- **python-syntax** - Enhanced Python highlighting
- **vim-commentary**, **vim-surround**, **vim-fugitive** - Utilities
- **vim-autopep8** - Python formatting
- **vim-gitgutter** - Git diff in gutter
- **vim-which-key** - Shows available keybindings popup

**Neovim-only plugins:**
- **nvim-tree** - File explorer sidebar
- **nvim-web-devicons** - File icons
- **nvim-treesitter** - Better syntax highlighting
- **nvim-lspconfig** - LSP configuration
- **nvim-cmp** - Autocompletion (with buffer, path, cmdline sources)
- **LuaSnip** - Snippet engine

### Vim Key Mappings (Leader = Space)

| Mapping | Action |
|---------|--------|
| `<Space>` | Show which-key popup (wait 500ms) |
| `<Space><Space>` | FZF shortcut picker |
| `<Space>ff` | Find files |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>fg` | Find git files |
| `<Space>fh` | File history |
| `<Space>fe` | File explorer (neovim) |
| `<Space>e` | File explorer (neovim) |
| `<Space>/` | Clear search highlight |
| `<Space>y` | Yank to system clipboard |
| `<Space>p` | Paste from system clipboard |
| `<Space>ap` | Run autopep8 |
| `[b` / `]b` | Previous/next buffer |
| `gd` | Go to definition (neovim LSP) |
| `gr` | Find references (neovim LSP) |
| `K` | Hover documentation (neovim LSP) |
| `<Space>lr` | LSP rename (neovim) |
| `<Space>la` | LSP code action (neovim) |
| `<Space>lf` | LSP format (neovim) |
| `[d` / `]d` | Previous/next diagnostic (neovim) |

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
