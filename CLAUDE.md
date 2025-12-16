# CLAUDE.md - Project Guide for Claude

This file provides context for Claude (AI assistant) when working with this repository.

## Project Overview

This is a personal dotfiles repository for Zsh and Vim configuration. It is designed to be cloned to `~/homedir` and activated with a single line in `.zshrc`.

**Key Design Decisions:**
- **Zsh-only**: No bash support. If sourced in a non-zsh shell, it prints an error and returns (not exits, since it's sourced)
- **Single entry point**: User adds `source ~/homedir/activate.sh` to their `.zshrc`
- **Modular zsh config**: Each concern (path, history, aliases, etc.) is in its own file
- **Vim symlinks**: Vim configs are symlinked to `~/.vim/` because Vim's plugin system requires files in specific locations
- **Machine-specific overrides**: `zsh/local.zsh` is gitignored for per-machine settings

## Directory Structure

```
~/homedir/
├── activate.sh           # Entry point - checks for zsh, sets HOMEDIR_ROOT, sources init.zsh
├── install.sh            # First-time setup (oh-my-zsh, plugins, fzf, vim symlinks)
├── zsh/
│   ├── init.zsh          # Orchestrator - sources all modules in correct order
│   ├── path.zsh          # PATH modifications, EDITOR variable
│   ├── oh-my-zsh.zsh     # Oh-my-zsh config (agnoster theme, plugins)
│   ├── history.zsh       # Zsh history settings (1M entries, shared history)
│   ├── fzf.zsh           # FZF configuration and keybindings
│   ├── functions.zsh     # Shell functions (mkcd, t, extract, gco, fzf_search_content)
│   ├── aliases.zsh       # Aliases (git, navigation, utilities)
│   └── local.zsh         # Machine-specific overrides (gitignored, optional)
└── vim/
    ├── vimrc             # Main vim config with vim-plug plugins
    ├── coc.vim           # CoC (completion) configuration
    └── ftplugin/         # Filetype-specific settings (symlinked to ~/.vim/after/ftplugin)
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
  └─> source ~/homedir/activate.sh
        ├─> Check $ZSH_VERSION (error + return 1 if not zsh)
        ├─> Set HOMEDIR_ROOT="${0:A:h}"
        └─> source zsh/init.zsh
              ├─> path.zsh      (PATH, EDITOR)
              ├─> oh-my-zsh.zsh (framework, theme, plugins)
              ├─> history.zsh   (history settings)
              ├─> fzf.zsh       (fuzzy finder)
              ├─> functions.zsh (shell functions)
              ├─> aliases.zsh   (aliases)
              └─> local.zsh     (if exists)
```

## Key Environment Variables

- `HOMEDIR_ROOT` - Absolute path to the homedir directory (set by activate.sh)
- `ZSH` - Path to oh-my-zsh installation (`~/.oh-my-zsh`)
- `EDITOR` / `VISUAL` - Default editor (vim)

## Vim Symlinks (created by install.sh)

| Symlink | Target |
|---------|--------|
| `~/.vim/vimrc` | `~/homedir/vim/vimrc` |
| `~/.vim/coc.vim` | `~/homedir/vim/coc.vim` |
| `~/.vim/after/ftplugin` | `~/homedir/vim/ftplugin` |
| `~/.vimrc` | Contains `source ~/.vim/vimrc` |

## Vim Plugins (via vim-plug)

- **vim-code-dark** - VSCode-like colorscheme
- **NERDTree** - File explorer with git integration and devicons
- **vim-airline** - Status line
- **fzf.vim** - Fuzzy finder integration
- **coc.nvim** - LSP-based completion engine
- **python-syntax**, **vim-go** - Language support
- **vim-commentary**, **vim-surround**, **vim-fugitive** - Utilities
- **editorconfig-vim**, **vim-autopep8** - Formatting

## Vim Key Mappings (Space = Leader)

| Mapping | Action |
|---------|--------|
| `<Space>ff` | Find files |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>nt` | Toggle NERDTree |
| `<Space>nf` | Find file in NERDTree |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show documentation |
| `<Space>rn` | Rename symbol |
| `[g` / `]g` | Previous/next diagnostic |

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
Create `vim/ftplugin/<filetype>.vim`

### Installing CoC language servers
Run in vim: `:CocInstall coc-pyright coc-tsserver coc-json coc-go`

## Code Style

- Shell scripts use `#!/usr/bin/env bash` or are sourced (no shebang for .zsh files)
- Use `[[ ]]` for conditionals (bash/zsh compatible)
- Use `command -v` instead of `which` for checking command existence
- Use `return` (not `exit`) in sourced scripts
- Zsh-specific features (like `${0:A:h}`) are only used in .zsh files

## Testing Changes

After making changes:
1. Open a new terminal, or
2. Run `source ~/homedir/activate.sh` to reload

For vim changes, restart vim or run `:source ~/.vim/vimrc`
