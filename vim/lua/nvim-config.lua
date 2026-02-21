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
            telescope = { enabled = true },
            which_key = true,
            diffview = true,
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
-- Telescope (Fuzzy Finder)
--------------------------------------------------------------------------------
if plugin_loaded('telescope') then
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    telescope.setup({
        defaults = {
            prompt_prefix = '   ',
            selection_caret = '  ',
            layout_strategy = 'horizontal',
            layout_config = {
                horizontal = {
                    preview_width = 0.55,
                },
            },
            mappings = {
                i = {
                    ['<C-j>'] = 'move_selection_next',
                    ['<C-k>'] = 'move_selection_previous',
                    ['<Esc>'] = 'close',
                },
            },
        },
        pickers = {
            find_files = {
                hidden = true,
                file_ignore_patterns = { '.git/', 'node_modules/', '.venv/', '__pycache__/' },
            },
        },
    })

    -- Custom shortcut picker (curated list with descriptions)
    local shortcuts = {
        { key = 'ff',  desc = 'Find files',              cmd = 'Telescope find_files' },
        { key = 'fg',  desc = 'Git files',               cmd = 'Telescope git_files' },
        { key = 'fb',  desc = 'Buffers',                 cmd = 'Telescope buffers' },
        { key = 'fc',  desc = 'Search content (grep)',   cmd = 'Telescope live_grep' },
        { key = 'fh',  desc = 'File history',            cmd = 'Telescope oldfiles' },
        { key = 'fs',  desc = 'Document symbols',        cmd = 'Telescope lsp_document_symbols' },
        { key = 'fd',  desc = 'Diagnostics',             cmd = 'Telescope diagnostics' },
        { key = 'e',   desc = 'File explorer',           cmd = 'NvimTreeToggle' },
        { key = 'w',   desc = 'Save',                    cmd = 'w' },
        { key = 'q',   desc = 'Quit',                    cmd = 'q' },
        { key = 'x',   desc = 'Save and quit',           cmd = 'x' },
        { key = 'bd',  desc = 'Delete buffer',           cmd = 'bdelete' },
        { key = '/',   desc = 'Search in buffer',        cmd = 'Telescope current_buffer_fuzzy_find' },
        { key = 'gg',  desc = 'LazyGit',                 cmd = 'LazyGit' },
        { key = 'gd',  desc = 'Diff view',               cmd = 'DiffviewOpen' },
        { key = 'gh',  desc = 'File git history',        cmd = 'DiffviewFileHistory %' },
        { key = 'lr',  desc = 'LSP rename',              cmd = 'lua vim.lsp.buf.rename()' },
        { key = 'la',  desc = 'LSP code action',         cmd = 'lua vim.lsp.buf.code_action()' },
        { key = 'lf',  desc = 'LSP format',              cmd = 'lua vim.lsp.buf.format()' },
        { key = 'ap',  desc = 'Autopep8 format',         cmd = 'Autopep8' },
    }

    local function shortcut_picker()
        pickers.new({}, {
            prompt_title = 'Shortcuts',
            finder = finders.new_table({
                results = shortcuts,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = string.format('%-6s  %s', entry.key, entry.desc),
                        ordinal = entry.key .. ' ' .. entry.desc,
                    }
                end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    if selection then
                        vim.cmd(selection.value.cmd)
                    end
                end)
                return true
            end,
        }):find()
    end

    -- Keymaps (matching fzf.vim style)
    vim.keymap.set('n', '<Leader>ff', builtin.find_files, { desc = 'Find files' })
    vim.keymap.set('n', '<Leader>fg', builtin.git_files, { desc = 'Git files' })
    vim.keymap.set('n', '<Leader>fb', builtin.buffers, { desc = 'Buffers' })
    vim.keymap.set('n', '<Leader>fc', builtin.live_grep, { desc = 'Search content (grep)' })
    vim.keymap.set('n', '<Leader>fh', builtin.oldfiles, { desc = 'File history' })
    vim.keymap.set('n', '<Leader>fs', builtin.lsp_document_symbols, { desc = 'Document symbols' })
    vim.keymap.set('n', '<Leader>fr', builtin.resume, { desc = 'Resume last search' })
    vim.keymap.set('n', '<Leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })

    -- Additional useful pickers
    vim.keymap.set('n', '<Leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
    vim.keymap.set('n', '<Leader>fk', builtin.keymaps, { desc = 'All keymaps' })

    -- Quick access (double leader) - curated shortcut picker
    vim.keymap.set('n', '<Leader><Leader>', shortcut_picker, { desc = 'Shortcuts' })
end

--------------------------------------------------------------------------------
-- Lualine (Statusline)
--------------------------------------------------------------------------------
if plugin_loaded('lualine') then
    require('lualine').setup({
        options = {
            theme = 'catppuccin',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { { 'filename', path = 1 } },  -- Relative path
            lualine_x = { 'encoding', 'fileformat', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
        },
        extensions = { 'nvim-tree' },
    })
end

--------------------------------------------------------------------------------
-- Which-Key (Keybinding Helper)
--------------------------------------------------------------------------------
if plugin_loaded('which-key') then
    local wk = require('which-key')

    wk.setup({
        delay = 500,
        icons = {
            mappings = false,
        },
    })

    -- Register key groups
    wk.add({
        { '<Leader>f', group = 'file/find' },
        { '<Leader>b', group = 'buffer' },
        { '<Leader>l', group = 'lsp' },
        { '<Leader>g', group = 'git' },
        { '<Leader>a', group = 'actions' },
    })
end

--------------------------------------------------------------------------------
-- Lazygit
--------------------------------------------------------------------------------
if plugin_loaded('lazygit') then
    vim.keymap.set('n', '<Leader>gg', ':LazyGit<CR>', { silent = true, desc = 'Open LazyGit' })
    vim.keymap.set('n', '<Leader>gf', ':LazyGitFilterCurrentFile<CR>', { silent = true, desc = 'LazyGit file history' })
end

--------------------------------------------------------------------------------
-- Diffview
--------------------------------------------------------------------------------
if plugin_loaded('diffview') then
    require('diffview').setup({
        use_icons = true,
    })

    vim.keymap.set('n', '<Leader>gd', ':DiffviewOpen<CR>', { silent = true, desc = 'Open diff view' })
    vim.keymap.set('n', '<Leader>gh', ':DiffviewFileHistory %<CR>', { silent = true, desc = 'File history' })
    vim.keymap.set('n', '<Leader>gH', ':DiffviewFileHistory<CR>', { silent = true, desc = 'Branch history' })
    vim.keymap.set('n', '<Leader>gq', ':DiffviewClose<CR>', { silent = true, desc = 'Close diff view' })
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


