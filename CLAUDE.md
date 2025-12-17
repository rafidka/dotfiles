# CLAUDE.md - Project Guide for Claude

This file provides context for Claude (AI assistant) when working with this repository.

## Project Overview

This is a personal dotfiles repository for Zsh and Vim configuration. It is designed to be cloned to `~/dotfiles` and activated with a single line in `.zshrc`.

**Key Design Decisions:**
- **Zsh-only**: No bash support. If sourced in a non-zsh shell, it prints an error and returns (not exits, since it's sourced)
- **Single entry point**: User adds `source ~/dotfiles/activate.sh` to their `.zshrc`
- **Modular zsh config**: Each concern (path, history, aliases, etc.) is in its own file
- **No symlinks**: Vim uses `VIMINIT` environment variable to source vimrc, and vimrc sets up `runtimepath` - no symlinks needed
- **Self-contained**: Everything lives in `~/dotfiles`, plugins install into `~/dotfiles/vim/`
- **Machine-specific overrides**: `zsh/local.zsh` is gitignored for per-machine settings

## Directory Structure

```
~/dotfiles/
├── activate.sh           # Entry point - checks for zsh, sets DOTFILES, sources init.zsh
├── install.sh            # First-time setup (oh-my-zsh, plugins, fzf)
├── zsh/
│   ├── init.zsh          # Orchestrator - sources all modules in correct order
│   ├── path.zsh          # PATH modifications, EDITOR, VIMINIT
│   ├── oh-my-zsh.zsh     # Oh-my-zsh config (agnoster theme, plugins)
│   ├── history.zsh       # Zsh history settings (1M entries, shared history)
│   ├── fzf.zsh           # FZF configuration and keybindings
│   ├── functions.zsh     # Shell functions (mkcd, t, extract, gco, fzf_search_content)
│   ├── aliases.zsh       # Aliases (git, navigation, utilities)
│   └── local.zsh         # Machine-specific overrides (gitignored, optional)
└── vim/
    ├── vimrc             # Main vim config - sets runtimepath, loads plugins
    ├── autoload/         # vim-plug installed here (gitignored)
    ├── plugged/          # Plugins installed here (gitignored)
    ├── undodir/          # Persistent undo files (gitignored)
    └── after/ftplugin/   # Filetype-specific settings
        ├── python.vim    # 88-col, 4-space indent
        ├── go.vim        # 120-col, tabs
        ├── typescript.vim # 100-col, 2-space indent
        ├── javascript.vim # 100-col, 2-space indent
        ├── java.vim      # 120-col, 4-space indent
        └── gitcommit.vim # 72-col, spell check
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

## How Vim Configuration Works (No Symlinks)

Instead of symlinks, we use environment variables:

1. **`zsh/path.zsh`** sets `VIMINIT="source ${DOTFILES}/vim/vimrc"`
2. When vim starts, it reads `VIMINIT` and sources our vimrc
3. **`vim/vimrc`** uses `expand('<sfile>:p:h')` to determine its directory
4. It then sets `runtimepath` to include our vim directory
5. This allows ftplugin, autoload, and plugins to work without symlinks

```vim
" In vim/vimrc:
let s:vimdir = expand('<sfile>:p:h')
execute 'set runtimepath^=' . s:vimdir
execute 'set runtimepath+=' . s:vimdir . '/after'
```

**Note**: This means vim only uses our config when `VIMINIT` is set (i.e., when the shell sources activate.sh). Running vim from a different shell without activate.sh sourced will use default vim settings.

## Key Environment Variables

- `DOTFILES` - Absolute path to the dotfiles directory (set by activate.sh)
- `VIMINIT` - Tells vim to source our vimrc (set by path.zsh)
- `ZSH` - Path to oh-my-zsh installation (`~/.oh-my-zsh`)
- `EDITOR` / `VISUAL` - Default editor (vim)

## Vim Plugins (via vim-plug)

- **vim-code-dark** - VSCode-like colorscheme
- **vim-airline** - Status line
- **fzf.vim** - Fuzzy finder integration
- **python-syntax** - Enhanced Python syntax highlighting
- **vim-commentary**, **vim-surround**, **vim-fugitive** - Utilities
- **vim-autopep8** - Python formatting
- **vim-gitgutter** - Git diff indicators in gutter

## Vim Key Mappings (Space = Leader)

| Mapping | Action |
|---------|--------|
| `<Space>ff` | Find files |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>fg` | Find git files |
| `<Space>fh` | File history |
| `<Space>ap` | Run autopep8 on current file |
| `[b` / `]b` | Previous/next buffer |

## Oh-My-Zsh Configuration

- **Theme**: agnoster
- **Plugins**: git, colored-man-pages, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions

## Shell Functions

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `t` | cd to ~/temp (creates if needed) |
| `extract <file>` | Extract various archive formats |
| `gco` | Fuzzy git branch checkout |
| `fzf_search_content` | Search file contents, open in vim |

## Common Tasks

### Adding a new alias
Edit `zsh/aliases.zsh`

### Adding a new function
Edit `zsh/functions.zsh`

### Adding machine-specific configuration
Create `zsh/local.zsh` (this file is gitignored)

### Adding a new Vim plugin
Add `Plug 'author/plugin'` to `vim/vimrc` in the plug#begin/end block, then run `:PlugInstall`

### Adding a new filetype configuration
Create `vim/after/ftplugin/<filetype>.vim`

## Code Style

- Shell scripts use `#!/usr/bin/env bash` or are sourced (no shebang for .zsh files)
- Use `[[ ]]` for conditionals (bash/zsh compatible)
- Use `command -v` instead of `which` for checking command existence
- Use `return` (not `exit`) in sourced scripts
- Zsh-specific features (like `${0:A:h}`) are only used in .zsh files
- Vim uses `s:` prefix for script-local variables

## Testing Changes

After making changes:
1. Open a new terminal, or
2. Run `source ~/dotfiles/activate.sh` to reload (or just `reload` alias)

For vim changes, restart vim or run `:source ~/dotfiles/vim/vimrc`
