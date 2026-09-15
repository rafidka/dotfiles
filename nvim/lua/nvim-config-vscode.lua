-- nvim-config-vscode.lua - Minimal Neovim configuration for VSCode
-- Only essential Vim editing enhancements

local vscode = require('vscode')

-- Basic Vim settings
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Search settings
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true

-- Other settings
vim.opt.showmatch = true
vim.opt.wildmenu = true
vim.opt.wildmode = 'longest:full,full'

-- Leader key
vim.g.mapleader = ' '

-- Essential keymaps

-- Clear search highlight
vim.keymap.set('n', '<Leader>/', ':nohlsearch<CR>', { silent = true, desc = 'Clear search highlight' })

-- Save and quit
vim.keymap.set('n', '<Leader>w', ':w<CR>', { silent = true, desc = 'Save' })
vim.keymap.set('n', '<Leader>q', ':q<CR>', { silent = true, desc = 'Quit' })
vim.keymap.set('n', '<Leader>x', ':x<CR>', { silent = true, desc = 'Save and quit' })

-- Move lines up/down in visual mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move line up' })

-- Keep cursor centered when scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down centered' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up centered' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next match centered' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous match centered' })

-- VSCode integration (find files)
vim.keymap.set('n', '<Leader>ff', function() vscode.action('workbench.action.quickOpen') end, { desc = 'Find files (VSCode)' })

-- Visual selection search
vim.keymap.set('v', '//', "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>", { desc = 'Search visual selection' })