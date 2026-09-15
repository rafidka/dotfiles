-- nvim/init.lua - Main Neovim configuration
-- Loaded via a thin wrapper at ~/.config/nvim/init.lua that dofile()s this
-- file (created by install.sh, same pattern as ~/.wezterm.lua), so no symlink
-- is needed and plain Vim never sees this config. Requires vim-plug, which is
-- bootstrapped below on first launch.

--------------------------------------------------------------------------------
-- Locate this config and register it on the runtimepath
--------------------------------------------------------------------------------
-- Resolve our own directory so the config works regardless of how it was
-- loaded. Falls back to $DOTFILES when the source path is unavailable.
local nvim_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h')
if nvim_dir == '' or vim.fn.isdirectory(nvim_dir) == 0 then
    nvim_dir = vim.env.DOTFILES .. '/nvim'
end

vim.opt.runtimepath:prepend(nvim_dir)
vim.opt.runtimepath:append(nvim_dir .. '/after')
-- Make our lua/ directory importable (require('nvim-config')).
package.path = nvim_dir .. '/lua/?.lua;' .. nvim_dir .. '/lua/?/init.lua;' .. package.path

--------------------------------------------------------------------------------
-- Bootstrap vim-plug
--------------------------------------------------------------------------------
local plug_path = nvim_dir .. '/autoload/plug.vim'
if vim.fn.empty(vim.fn.glob(plug_path)) == 1 then
    vim.fn.system({
        'curl', '-fLo', plug_path, '--create-dirs',
        'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
    })
    vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        command = 'PlugInstall --sync | source $MYVIMRC',
    })
end

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------
local nvim_version = vim.version()
local has_nvim_011 = nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 11)
local has_nvim_012 = nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 12)

local Plug = vim.fn['plug#']

vim.fn['plug#begin'](nvim_dir .. '/plugged')

-- Editing enhancements (also loaded inside the VSCode extension)
Plug('tpope/vim-commentary')
Plug('tpope/vim-surround')

if not vim.g.vscode then
    -- Colorscheme (treesitter-aware)
    Plug('catppuccin/nvim', { as = 'catppuccin' })

    -- File explorer
    Plug('nvim-tree/nvim-web-devicons')
    Plug('nvim-tree/nvim-tree.lua')

    -- Statusline
    Plug('nvim-lualine/lualine.nvim')

    -- Which-key
    Plug('folke/which-key.nvim')

    -- Buffer line (tab bar)
    Plug('akinsho/bufferline.nvim', { tag = '*' })

    -- Git
    Plug('kdheepak/lazygit.nvim')
    Plug('sindrets/diffview.nvim')

    -- Session management
    Plug('folke/persistence.nvim')

    if has_nvim_011 then
        -- Fuzzy finder
        Plug('nvim-lua/plenary.nvim')
        Plug('nvim-telescope/telescope.nvim')

        -- Treesitter (better syntax highlighting)
        Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

        -- LSP
        Plug('neovim/nvim-lspconfig')

        -- Autocompletion
        Plug('hrsh7th/nvim-cmp')
        Plug('hrsh7th/cmp-nvim-lsp')
        Plug('hrsh7th/cmp-buffer')
        Plug('hrsh7th/cmp-path')
        Plug('hrsh7th/cmp-cmdline')

        -- Snippets (required for nvim-cmp)
        Plug('L3MON4D3/LuaSnip')
        Plug('saadparwaiz1/cmp_luasnip')

        -- AI assistant (avante.nvim, driven by opencode over ACP)
        -- Guarded on 0.12: avante force-quits Neovim on older versions.
        -- The build fetches the prebuilt Rust library and is NOT optional (ACP
        -- mode needs avante_templates for the system prompt). Invoked via bash
        -- because upstream commits build.sh without the executable bit.
        if has_nvim_012 then
            Plug('MunifTanjim/nui.nvim')
            Plug('MeanderingProgrammer/render-markdown.nvim')
            Plug('HakonHarnes/img-clip.nvim')
            Plug('avante-corp/avante.nvim', { branch = 'main', ['do'] = 'bash ./build.sh' })
        end
    else
        vim.notify(
            'Neovim < 0.11 detected. Skipping: telescope, treesitter, LSP, completion, avante.\n' ..
            'Install Neovim 0.11+ for full functionality.',
            vim.log.levels.WARN
        )
    end
end

vim.fn['plug#end']()

--------------------------------------------------------------------------------
-- General settings
--------------------------------------------------------------------------------
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.showmatch = true
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'
vim.opt.hidden = true

-- Indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true

--------------------------------------------------------------------------------
-- Standalone-only settings (skipped inside the VSCode extension)
--------------------------------------------------------------------------------
if not vim.g.vscode then
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.cursorline = true
    vim.opt.signcolumn = 'yes'
    vim.opt.shortmess:append('c')
    vim.opt.scrolloff = 5
    vim.opt.mouse = 'a'
    vim.opt.updatetime = 300
    vim.opt.textwidth = 80

    -- Backups (disabled - use git instead)
    vim.opt.backup = false
    vim.opt.writebackup = false
    vim.opt.swapfile = false

    -- Persistent undo
    vim.opt.undofile = true
    vim.opt.undodir = nvim_dir .. '/undodir'
    if vim.fn.isdirectory(vim.o.undodir) == 0 then
        vim.fn.mkdir(vim.o.undodir, 'p')
    end

    -- Colour scheme
    vim.opt.termguicolors = true
    vim.opt.background = 'dark'

    -- Cursor shape
    vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'

    -- Timings: mapped sequences (which-key popup) vs terminal key codes
    vim.opt.timeoutlen = 500
    vim.opt.ttimeoutlen = 10
end

--------------------------------------------------------------------------------
-- Leader
--------------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--------------------------------------------------------------------------------
-- Essential key mappings (all environments)
--------------------------------------------------------------------------------
vim.keymap.set('n', '<Leader>w', ':w<CR>', { silent = true, desc = 'Save' })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { silent = true, desc = 'Quit' })
vim.keymap.set('n', '<Leader>x', ':x<CR>', { silent = true, desc = 'Save and quit' })

-- Move lines up/down in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move selection up' })

-- Keep the cursor centred when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Half page down (centred)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Half page up (centred)' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next match (centred)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous match (centred)' })

-- Search for the visual selection
vim.keymap.set('v', '//', [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], { desc = 'Search selection' })

--------------------------------------------------------------------------------
-- Standalone-only key mappings (skipped inside the VSCode extension)
--------------------------------------------------------------------------------
if not vim.g.vscode then
    -- System clipboard
    vim.keymap.set({ 'n', 'v' }, '<Leader>y', '"+y', { desc = 'Clipboard yank' })
    vim.keymap.set({ 'n', 'v' }, '<Leader>p', '"+p', { desc = 'Clipboard paste' })
    vim.keymap.set('n', '<Leader>P', '"+P', { desc = 'Clipboard paste before' })

    -- Window navigation
    vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
    vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
    vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
    vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Window right' })
end

--------------------------------------------------------------------------------
-- Plugin configuration and everything else
--------------------------------------------------------------------------------
require('nvim-config')
