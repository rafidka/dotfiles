# Dotfiles

Personal dotfiles for Zsh and Neovim.

## Features

- **Zsh configuration** with Oh-My-Zsh, syntax highlighting, and autosuggestions
- **Neovim configuration** with LSP, Treesitter, Telescope, and an AI sidebar
  (avante.nvim driven by opencode over ACP)
- **Modular design** - easy to customize and extend
- **Single entry point** - just add one line to your `.zshrc`
- **Self-contained** - no symlinks needed, everything stays in `~/dotfiles`

Neovim-only: plain Vim is not supported, and `vim`/`vi` are aliased to `nvim`.

## Installation

```bash
# Clone the repository
git clone https://github.com/rafidka/dotfiles.git ~/dotfiles

# Run the install script
cd ~/dotfiles
./install.sh

# Restart your shell
source ~/.zshrc

# Install Neovim plugins (auto-runs on first nvim launch, or manually)
nvim +PlugInstall +qall
```

`install.sh` is required on every machine, not just the first one. It writes the
wrapper at `~/.config/nvim/init.lua` that points Neovim at this repo; cloning
and sourcing `activate.sh` configures the shell but leaves Neovim with no
config at all.

If you re-run it from an already-configured shell it will abort at step 1,
because the Oh-My-Zsh installer refuses to run while `$ZSH` is set. Use
`ZSH= ./install.sh`.

## Structure

```
~/dotfiles/
├── activate.sh           # Entry point (source this from .zshrc)
├── install.sh            # First-time setup script
│
├── zsh/                  # Zsh configuration
│   ├── init.zsh          # Main orchestrator
│   ├── oh-my-zsh.zsh     # Oh-my-zsh setup (agnoster theme)
│   ├── aliases.zsh       # Shell aliases
│   ├── functions.zsh     # Custom functions
│   ├── history.zsh       # History settings
│   ├── path.zsh          # PATH configuration, EDITOR
│   ├── fzf.zsh           # FZF integration
│   └── local.zsh         # Machine-specific (gitignored)
│
└── nvim/                 # Neovim configuration
    ├── init.lua          # Entry point: vim-plug, options, keymaps
    ├── lua/              # Plugin setup, LSP, completion, avante
    └── after/ftplugin/   # Filetype-specific settings
```

## How It Works

- **Zsh**: Sourcing `activate.sh` sets `DOTFILES` and loads all zsh modules
- **Neovim**: `install.sh` writes a three-line wrapper to `~/.config/nvim/init.lua`
  that `dofile()`s `~/dotfiles/nvim/init.lua`, which puts our directory on the
  runtimepath - no symlinks needed!

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

#### GPG Signing

Run `gpg-unlock-all` to unlock every secret GPG signing key for Git and other
signing operations. The command uses pinentry for uncached passphrases and
warms the `gpg-agent` cache until its configured timeout expires. Run
`gpg-unlock-all --help` for detailed behavior and exit-status information.

### Neovim

Key mappings (Space is the leader key). Press `<Space>` for the which-key
popup, or `<Space><Space>` for a searchable list of everything.

| Mapping | Action |
|---------|--------|
| `<Space>ff` | Find files (Telescope) |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>e` | Toggle file explorer |
| `<Space>gg` | Open LazyGit |
| `<Space>aa` | Ask the AI sidebar (avante) |
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Show documentation |
| `<Space>cr` | Rename symbol |

See `AGENTS.md` for the full mapping table.

#### AI sidebar (avante + opencode)

`<Space>aa` opens the sidebar. It runs [opencode](https://opencode.ai) as an ACP
subprocess, so it reuses opencode's own auth, tools, permission prompts and
`AGENTS.md` rules — there is no separate API key to configure.

Because opencode is an ACP provider rather than one of avante's own LLM
providers, some avante features are unavailable:

- **`/compact` errors out.** Auto-compaction fails the same way, so long
  conversations break; start a fresh chat with `<Space>an` instead.
- **Token counts always read 0**, and inline suggestions (`<Space>as`) stay
  disabled.
- **Avante's own tools are bypassed** — Fast Apply, RAG and its MCP integration
  do nothing, since opencode's tools handle the work.

See *Known Issues* in `AGENTS.md` for the reasons.

## Customization

### Machine-specific settings

Create `~/dotfiles/zsh/local.zsh` for settings specific to your machine:

```zsh
# Example local.zsh
export JAVA_HOME="/usr/lib/jvm/java-17"
alias work="cd ~/work/my-project"
```

This file is gitignored so it won't be committed.

### Adding language servers

LSP is configured in `nvim/lua/nvim-config.lua`. Install the server binary,
then add it to the setup block there (pyright, ts_ls and bashls are wired up
already).

## Requirements

- Zsh (as your default shell)
- Git
- curl
- GnuPG 2.x (for `gpg-unlock-all`)
- Neovim 0.11+ (0.12+ for the avante AI sidebar)
- [Nerd Font](https://www.nerdfonts.com/) (for icons in Neovim/terminal)
- [opencode](https://opencode.ai) (for the avante AI sidebar)

## License

GPL-3.0
