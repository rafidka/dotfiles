# AGENTS.md - Guide for AI Coding Agents

Personal dotfiles for Zsh and Neovim. Clone to `~/dotfiles` and activate via
`source ~/dotfiles/activate.sh` in `.zshrc`. **Zsh-only**, no bash support.
**Neovim-only**, no plain Vim support.

## Validation Commands

```bash
bash -n install.sh              # Check bash script syntax
bash -n bin/<script>
zsh -n activate.sh              # Check zsh file syntax
zsh -n zsh/*.zsh
reload                          # Reload config (or: source ~/dotfiles/activate.sh)
nvim --headless +PlugStatus +qall   # Test Neovim plugin state
nvim --headless +"checkhealth" +qall
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
  path.zsh           # PATH, EDITOR
  fedora.zsh         # Fedora-specific config (sourced on Fedora only)
  aliases.zsh        # Shell aliases
  functions.zsh      # Shell functions
  local.zsh          # Machine-specific (gitignored)
nvim/
  init.lua           # Entry point: runtimepath, vim-plug, options, keymaps
  lua/
    nvim-config.lua        # Plugin setup, LSP, completion, avante
    nvim-config-vscode.lua # Minimal config for the VSCode extension
  after/ftplugin/    # Filetype-specific settings (.vim, read by Neovim)
```

## Activation Flow

```
~/.zshrc
  └─> source ~/dotfiles/activate.sh
        ├─> Check $ZSH_VERSION (error + return 1 if not zsh)
        ├─> Set DOTFILES="${0:A:h}"
        └─> source zsh/init.zsh
              ├─> path.zsh      (PATH, EDITOR)
              ├─> oh-my-zsh.zsh (framework, theme, plugins)
              ├─> history.zsh   (history settings)
              ├─> fzf.zsh       (fuzzy finder)
              ├─> functions.zsh (shell functions)
              ├─> aliases.zsh   (aliases)
              ├─> fedora.zsh    (Fedora only: adds fedora/bin to PATH)
              └─> local.zsh     (if exists)
```

## How Neovim Works (No Symlinks)

`install.sh` writes a three-line wrapper to `~/.config/nvim/init.lua` that
`dofile()`s our real config — the same pattern used for `~/.wezterm.lua`:

```lua
dofile(os.getenv("HOME") .. "/dotfiles/nvim/init.lua")
```

`nvim/init.lua` then locates itself and registers our directory on the
runtimepath, so `after/ftplugin/` and `lua/` are found:

```lua
local nvim_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')
vim.opt.runtimepath:prepend(nvim_dir)
vim.opt.runtimepath:append(nvim_dir .. '/after')
package.path = nvim_dir .. '/lua/?.lua;' .. package.path
```

This deliberately avoids `VIMINIT`: that variable is also honoured by plain
Vim, which cannot parse a Lua config, so a global `VIMINIT` would break every
direct `vim` invocation. `~/.config/nvim/` is read by Neovim only.

The wrapper is therefore load-bearing: on a machine where `install.sh` has
never run, Neovim starts with **no configuration at all** and looks broken in a
way unrelated to anything in `nvim/`. Sourcing `activate.sh` is not enough —
nothing in the zsh path creates the wrapper. To check or recreate it by hand:

```bash
cat ~/.config/nvim/init.lua          # should dofile ~/dotfiles/nvim/init.lua
mkdir -p ~/.config/nvim
printf 'dofile(os.getenv("HOME") .. "/dotfiles/nvim/init.lua")\n' > ~/.config/nvim/init.lua
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

### Neovim Config (nvim/init.lua, nvim/lua/*.lua)

Lua, 4-space indent, single-quoted strings, 80-column section banners:

```lua
--------------------------------------------------------------------------------
-- Section Name
--------------------------------------------------------------------------------
if has_nvim_011 and plugin_loaded('telescope') then
    require('telescope').setup({})
    vim.keymap.set('n', '<Leader>ff', builtin.find_files, { desc = 'Find files' })
end
```

**Patterns:**
- Guard every plugin block with `plugin_loaded('<require-name>')`, and add
  `has_nvim_011` / `has_nvim_012` when the plugin needs a newer Neovim
- Keymaps go immediately after the corresponding `setup()`, never in a central
  list, and always carry a `desc` (which-key and `<Space>fk` read it)
- Command-string keymaps take `silent = true`; function keymaps omit it

Filetype plugins stay Vimscript (`nvim/after/ftplugin/*.vim`) and use
`setlocal`:
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
| Lua locals | lowercase_underscores | `local nvim_dir` |

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
**New Neovim plugin:** Add `Plug('author/plugin')` in `nvim/init.lua`, then a
guarded setup block in `nvim/lua/nvim-config.lua`
**New filetype:** Create `nvim/after/ftplugin/<type>.vim` with `setlocal`
**New Fedora tool:** Create in `fedora/bin/` or `fedora/toolbox/`

## Constraints

- **Zsh-only**: Guard in activate.sh rejects other shells
- **Neovim-only**: No plain Vim support; `vim`/`vi` are aliased to `nvim`
- **No symlinks**: `~/.config/nvim/init.lua` is a wrapper that `dofile()`s ours
- **Self-contained**: All files in `~/dotfiles/`
- **local.zsh gitignored**: Machine-specific settings go there
- **Use return not exit**: In sourced files, `exit` closes the shell
- **install.sh required per machine**: Only it creates the Neovim and WezTerm
  wrappers; cloning plus `activate.sh` gives you a working shell but an
  unconfigured editor

## Known Issues

Pre-existing rough edges. Each is deliberate or unfixed, not an oversight —
check here before "fixing" one.

### install.sh aborts when `$ZSH` is exported

Step 1 shells out to the Oh-My-Zsh installer, which refuses to run when `$ZSH`
already points at an existing install, and `set -e` turns that into a hard exit.
Since our shell config exports `ZSH`, re-running `install.sh` from a configured
shell never reaches the later steps — including the Neovim wrapper. Work around
it with `ZSH= ./install.sh`, or create the wrapper by hand (see *How Neovim
Works*).

### Avante is degraded under an ACP provider

`provider = 'opencode'` is an ACP provider, and several avante features resolve
the provider through its own LLM table, which has no entry for an ACP name:

- **`/compact` errors** with `Failed to find provider: opencode`. Auto-compaction
  hits the same path, so long chats break too — start a new chat (`<Space>an`)
  instead. Fixing it means setting `memory_summary_provider` to a real LLM
  provider, which reintroduces an API key.
- **`auto_suggestions` must stay `false`** and **`enable_token_counting` stays
  `false`** (counts always read 0). Both are set explicitly in
  `nvim/lua/nvim-config.lua` for this reason.
- **Avante's own tooling is inert**: Fast Apply, the RAG service, its MCP
  integration, `auto_approve_tool_permissions` and the diff/apply workflow all
  route through a tool list the ACP path never sends. opencode's own tools and
  permission prompts do the work instead. Avoid `<Space>as` and `<Space>aR`.

### avante's build.sh is not executable upstream

Committed mode 644, so the documented `'do': './build.sh'` hook always fails
with `Permission denied`. `nvim/init.lua` invokes it as `bash ./build.sh`. The
prebuilt Rust library it fetches is mandatory: ACP mode needs `avante_templates`
for the system prompt and dies on the first message without it.

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
| `ZSH` | Path to oh-my-zsh (`~/.oh-my-zsh`) |
| `EDITOR` | Default editor (nvim) |
| `VISUAL` | Default visual editor (nvim) |

### Neovim Plugins

Loaded everywhere, including inside the VSCode extension:
- **vim-commentary**, **vim-surround** - Editing utilities

Standalone Neovim only:
- **catppuccin** - Colorscheme (treesitter-aware, mocha flavour)
- **nvim-tree** - File explorer sidebar
- **nvim-web-devicons** - File icons
- **lualine.nvim** - Statusline
- **which-key.nvim** - Keybinding helper
- **bufferline.nvim** - Tab bar with buffer management
- **lazygit.nvim** - LazyGit integration
- **diffview.nvim** - Git diff viewer
- **persistence.nvim** - Session management (auto-save/restore)

Requires Neovim 0.11+:
- **telescope.nvim** + **plenary.nvim** - Fuzzy finder
- **nvim-treesitter** - Better syntax highlighting
- **nvim-lspconfig** - LSP configuration
- **nvim-cmp** (+ cmp-nvim-lsp, cmp-buffer, cmp-path, cmp-cmdline) - Completion
- **LuaSnip** + **cmp_luasnip** - Snippets (required by nvim-cmp)

Requires Neovim 0.12+:
- **avante.nvim** - AI assistant sidebar, driven by opencode over ACP
- **nui.nvim** - UI component library (required by avante)
- **render-markdown.nvim** - Renders markdown in the avante sidebar
- **img-clip.nvim** - Paste images into avante prompts

### Key Mappings (Leader = Space)

| Mapping | Action |
|---------|--------|
| `<Space>` | Show which-key popup (wait 500ms) |
| `<Space><Space>` | Shortcut picker (Telescope) |
| **File/Find (`<Space>f`)** | |
| `<Space>ff` | Find files |
| `<Space>fc` | Find in files (ripgrep) |
| `<Space>fb` | List buffers |
| `<Space>fg` | Find git files |
| `<Space>fh` | File history |
| `<Space>fs` | Document symbols |
| `<Space>fd` | Diagnostics |
| `<Space>fk` | All keymaps |
| `<Space>fr` | Resume last search |
| `<Space>fe` / `<Space>e` | File explorer |
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
| `<Space>gg` | Open LazyGit |
| `<Space>gd` | Open diff view |
| `<Space>gh` | File git history |
| `<Space>gH` | Branch git history |
| `<Space>gf` | LazyGit file history |
| `<Space>gq` | Close diff view |
| **LSP (`<Space>l`)** | |
| `<Space>lr` | LSP rename |
| `<Space>la` | LSP code action |
| `<Space>lf` | LSP format |
| `<Space>ld` | LSP diagnostics (on LSP attach) |
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
| **AI (`<Space>a`, neovim 0.12+)** | |
| `<Space>aa` | Ask avante |
| `<Space>at` | Toggle avante sidebar |
| `<Space>af` | Focus avante sidebar |
| `<Space>ar` | Refresh avante sidebar |
| `<Space>an` | New avante chat |
| `<Space>ah` | Select chat history |
| `<Space>aS` | Stop current request |
| `<Space>ac` | Add current buffer to context (in sidebar) |
| `<Space>aB` | Add all buffers to context (in sidebar) |
| `<Space>aM` | Select agent model |
| `<Space>am` | Select agent mode |
| **Quick Actions** | |
| `<Space>w` / `q` / `x` | Save / Quit / Save+Quit |
| `<Space>/` | Search in buffer |
| `<Space>y` / `p` / `P` | System clipboard yank/paste |
| **Navigation** | |
| `[d` / `]d` | Previous/next diagnostic |
| `gd` | Go to definition (neovim LSP) |
| `gr` | Find references (neovim LSP) |
| `K` | Hover documentation (neovim LSP) |

### Shell Functions

| Function | Description |
|----------|-------------|
| `mkcd <dir>` | Create directory and cd into it |
| `t` | cd to ~/temp (creates if needed) |
| `extract <file>` | Extract various archive formats |
| `fzf_search_content` | Search file contents, open in nvim |

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
| `gpg-unlock-all` | Unlock all GPG signing keys for Git signing |
