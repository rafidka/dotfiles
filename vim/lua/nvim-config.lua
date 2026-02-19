-- nvim-config.lua - Neovim-specific configuration
-- This file is loaded only in Neovim (see vimrc)

-- Helper to check if a plugin is loaded
local function plugin_loaded(plugin)
    local ok, _ = pcall(require, plugin)
    return ok
end

--------------------------------------------------------------------------------
-- Catppuccin Colorscheme
--------------------------------------------------------------------------------
if plugin_loaded('catppuccin') then
    require('catppuccin').setup({
        flavour = 'mocha',  -- latte, frappe, macchiato, mocha
        transparent_background = false,
        integrations = {
            treesitter = true,
            native_lsp = {
                enabled = true,
            },
            cmp = true,
            gitsigns = true,
            nvimtree = true,
        },
    })
end

--------------------------------------------------------------------------------
-- Nvim-tree File Explorer
--------------------------------------------------------------------------------
if plugin_loaded('nvim-tree') then
    -- Disable netrw (vim's built-in file explorer)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require('nvim-tree').setup({
        sort = {
            sorter = 'case_sensitive',
        },
        view = {
            width = 35,
        },
        renderer = {
            group_empty = true,
            icons = {
                show = {
                    file = true,
                    folder = true,
                    folder_arrow = true,
                    git = true,
                },
            },
        },
        filters = {
            dotfiles = false,  -- Show dotfiles
            git_ignored = false,  -- Show git ignored files
        },
        git = {
            enable = true,
            ignore = false,
        },
        actions = {
            open_file = {
                quit_on_open = false,  -- Keep tree open when opening file
            },
        },
    })

    -- Keymaps
    vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { silent = true, desc = 'Toggle file explorer' })
    vim.keymap.set('n', '<Leader>fe', ':NvimTreeToggle<CR>', { silent = true, desc = 'Toggle file explorer' })
end

--------------------------------------------------------------------------------
-- Treesitter Configuration (new API for nvim-treesitter)
--------------------------------------------------------------------------------
if plugin_loaded('nvim-treesitter') then
    local ts = require('nvim-treesitter')

    -- Install parsers (async, runs in background)
    -- These will be installed to vim.fn.stdpath('data') .. '/site'
    ts.install({
        'python',
        'typescript',
        'javascript',
        'bash',
        'lua',
        'vim',
        'vimdoc',
        'json',
        'yaml',
        'toml',
        'markdown',
        'markdown_inline',
    })
end

-- Enable treesitter highlighting for supported filetypes
vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'python', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact',
        'bash', 'sh', 'lua', 'vim', 'json', 'yaml', 'toml', 'markdown',
    },
    callback = function()
        -- Only start if parser is available
        local ok = pcall(vim.treesitter.start)
        if ok then
            -- Enable treesitter-based folding
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            vim.wo.foldenable = false  -- Don't fold by default
        end
    end,
})

-- NOTE: Incremental selection was removed in the new nvim-treesitter rewrite.
-- The old API (nvim-treesitter.incremental_selection) no longer exists.

--------------------------------------------------------------------------------
-- LSP Configuration (nvim 0.11+ using vim.lsp.config)
--------------------------------------------------------------------------------

-- Diagnostic configuration
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Diagnostic signs
local signs = { Error = ' ', Warn = ' ', Hint = '󰌵 ', Info = ' ' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- LSP keymaps (set up when LSP attaches to buffer)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { noremap = true, silent = true, buffer = ev.buf }

        -- Navigation
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)

        -- Documentation
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

        -- Actions
        vim.keymap.set('n', '<Leader>lr', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<Leader>la', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<Leader>lf', function() vim.lsp.buf.format({ async = true }) end, opts)

        -- Diagnostics
        vim.keymap.set('n', '<Leader>ld', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    end,
})

-- Capabilities for autocompletion
local capabilities = vim.lsp.protocol.make_client_capabilities()
if plugin_loaded('cmp_nvim_lsp') then
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
end

-- Python (pyright)
-- TODO: Make venv detection dynamic per-buffer instead of at startup.
--       Currently detects .venv from getcwd() when neovim starts.
--       Could use root_dir detection or LspAttach autocmd to re-detect per project.
local function get_python_path()
    local venv = vim.fn.getcwd() .. '/.venv'
    if vim.fn.isdirectory(venv) == 1 then
        return venv .. '/bin/python'
    end
    return 'python3'
end

vim.lsp.config('pyright', {
    capabilities = capabilities,
    settings = {
        python = {
            pythonPath = get_python_path(),
            venvPath = vim.fn.getcwd(),
            venv = '.venv',
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = 'workspace',
            },
        },
    },
})

-- TypeScript/JavaScript (ts_ls)
vim.lsp.config('ts_ls', {
    capabilities = capabilities,
})

-- Bash (bashls)
vim.lsp.config('bashls', {
    capabilities = capabilities,
})

-- Enable the language servers
vim.lsp.enable({ 'pyright', 'ts_ls', 'bashls' })

--------------------------------------------------------------------------------
-- Autocompletion (nvim-cmp)
--------------------------------------------------------------------------------
if plugin_loaded('cmp') then
    local cmp = require('cmp')
    local luasnip_ok, luasnip = pcall(require, 'luasnip')

    cmp.setup({
        snippet = {
            expand = function(args)
                if luasnip_ok then
                    luasnip.lsp_expand(args.body)
                end
            end,
        },

        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip_ok and luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip_ok and luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        }),

        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        }, {
            { name = 'buffer' },
            { name = 'path' },
        }),

        formatting = {
            format = function(entry, vim_item)
                -- Source labels
                vim_item.menu = ({
                    nvim_lsp = '[LSP]',
                    luasnip = '[Snip]',
                    buffer = '[Buf]',
                    path = '[Path]',
                })[entry.source.name]
                return vim_item
            end,
        },
    })

    -- Command line completion
    cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = 'buffer' },
        },
    })

    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' },
        }, {
            { name = 'cmdline' },
        }),
    })
end

--------------------------------------------------------------------------------
-- Update which-key for LSP mappings (if available)
--------------------------------------------------------------------------------
vim.g.which_key_map = vim.g.which_key_map or {}
vim.g.which_key_map.l = {
    name = '+lsp',
    r = 'rename',
    a = 'code action',
    f = 'format',
    d = 'diagnostics',
}
