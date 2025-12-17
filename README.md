# Homedir

Personal home directory configuration for Zsh and Vim.

## Features

- **Zsh configuration** with Oh-My-Zsh, syntax highlighting, and autosuggestions
- **Vim configuration** with CoC completion, NERDTree, fzf integration, and more
- **Modular design** - easy to customize and extend
- **Single entry point** - just add one line to your `.zshrc`
- **Self-contained** - no symlinks needed, everything stays in `~/homedir`

## Installation

```bash
# Clone the repository
git clone https://github.com/rafidka/homedir.git ~/homedir

# Run the install script
cd ~/homedir
./install.sh

# Restart your shell
source ~/.zshrc

# Install Vim plugins (auto-runs on first vim launch, or manually)
vim +PlugInstall +qall
```

## Structure

```
~/homedir/
├── activate.sh           # Entry point (source this from .zshrc)
├── install.sh            # First-time setup script
│
├── zsh/                  # Zsh configuration
│   ├── init.zsh          # Main orchestrator
│   ├── oh-my-zsh.zsh     # Oh-my-zsh setup (agnoster theme)
│   ├── aliases.zsh       # Shell aliases
│   ├── functions.zsh     # Custom functions
│   ├── history.zsh       # History settings
│   ├── path.zsh          # PATH configuration, VIMINIT
│   ├── fzf.zsh           # FZF integration
│   └── local.zsh         # Machine-specific (gitignored)
│
└── vim/                  # Vim configuration
    ├── vimrc             # Main config with vim-plug
    ├── coc.vim           # CoC completion config
    └── after/ftplugin/   # Filetype-specific settings
```

## How It Works

- **Zsh**: Sourcing `activate.sh` sets `HOMEDIR_ROOT` and loads all zsh modules
- **Vim**: The `VIMINIT` environment variable points vim to our vimrc, which sets up `runtimepath` to use our vim directory - no symlinks needed!

## Usage

### Zsh

The configuration activates automatically when you open a new terminal. Key features:

- **Theme**: agnoster (powerline-style)
- **Plugins**: git, zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions

#### Aliases

| Alias | Command |
|-------|---------|
| `ll` | `ls -lh` |
| `la` | `ls -lah` |
| `gs` | `git status` |
| `gd` | `git diff` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gp` | `git push` |
| `..` | `cd ..` |

#### Functions

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `t` | Go to ~/temp |
| `extract <file>` | Extract various archive formats |
| `gco` | Fuzzy checkout git branch |

### Vim

Key mappings (Space is the leader key):

| Mapping | Action |
|---------|--------|
| `<Space>ff` | Find files (fzf) |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>nt` | Toggle NERDTree |
| `<Space>nf` | Find current file in NERDTree |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show documentation |
| `<Space>rn` | Rename symbol |

## Customization

### Machine-specific settings

Create `~/homedir/zsh/local.zsh` for settings specific to your machine:

```zsh
# Example local.zsh
export JAVA_HOME="/usr/lib/jvm/java-17"
alias work="cd ~/work/my-project"
```

This file is gitignored so it won't be committed.

### Adding CoC language servers

After installation, add language servers for your languages:

```vim
:CocInstall coc-pyright      " Python
:CocInstall coc-tsserver     " TypeScript/JavaScript
:CocInstall coc-json         " JSON
:CocInstall coc-go           " Go
:CocInstall coc-rust-analyzer " Rust
```

## Requirements

- Zsh (as your default shell)
- Git
- curl
- Vim 8.0+ or Neovim
- [Nerd Font](https://www.nerdfonts.com/) (for icons in Vim/terminal)

## License

GPL-3.0
