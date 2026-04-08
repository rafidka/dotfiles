-- nvim-config.lua - Neovim-specific configuration
-- This file is loaded only in Neovim (see vimrc)

-- Check if running in VSCode
if vim.g.vscode then
    require('nvim-config-vscode')
    return
end

-- Check Neovim version
local nvim_version = vim.version()
local has_nvim_011 = nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 11)

if not has_nvim_011 then
    vim.notify(
        'Neovim < 0.11 detected. Some features (LSP, completion, telescope, treesitter) are disabled.\n' ..
        'Upgrade to Neovim 0.11+ for full functionality.',
        vim.log.levels.WARN
    )
end

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
            bufferline = true,
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
if has_nvim_011 and plugin_loaded('telescope') then
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
    -- Format: [category] Action description
    local shortcuts = {
        -- File/Find
        { key = 'ff',  desc = '[find] Files in project',           cmd = 'Telescope find_files' },
        { key = 'fg',  desc = '[find] Git tracked files',          cmd = 'Telescope git_files' },
        { key = 'fb',  desc = '[find] Open buffers',               cmd = 'Telescope buffers' },
        { key = 'fc',  desc = '[find] Content in files (grep)',    cmd = 'Telescope live_grep' },
        { key = 'fh',  desc = '[find] Recently opened files',      cmd = 'Telescope oldfiles' },
        { key = 'fs',  desc = '[find] Symbols in document',        cmd = 'Telescope lsp_document_symbols' },
        { key = 'fd',  desc = '[find] Diagnostics (errors/warns)', cmd = 'Telescope diagnostics' },
        { key = 'fk',  desc = '[find] Keymaps',                    cmd = 'Telescope keymaps' },
        { key = 'fr',  desc = '[find] Resume last search',         cmd = 'Telescope resume' },
        { key = 'e',   desc = '[file] Toggle explorer sidebar',    cmd = 'NvimTreeToggle' },
        -- Search/Replace
        { key = 'ss',  desc = '[search] Grep in project',          cmd = 'Telescope live_grep' },
        { key = 'sw',  desc = '[search] Word under cursor',        cmd = 'Telescope grep_string' },
        { key = 'sb',  desc = '[search] Fuzzy find in buffer',     cmd = 'Telescope current_buffer_fuzzy_find' },
        { key = 'sr',  desc = '[search] Replace in buffer (:%s/)', cmd = '%s/' },
        { key = 'sn',  desc = '[search] Clear highlight',          cmd = 'nohlsearch' },
        -- Code/Refactor
        { key = 'cf',  desc = '[code] Format buffer',              cmd = 'lua vim.lsp.buf.format()' },
        { key = 'cr',  desc = '[code] Rename symbol',              cmd = 'lua vim.lsp.buf.rename()' },
        { key = 'ca',  desc = '[code] Actions menu',               cmd = 'lua vim.lsp.buf.code_action()' },
        { key = 'cd',  desc = '[code] Show line diagnostics',      cmd = 'lua vim.diagnostic.open_float()' },
        { key = 'ci',  desc = '[code] Organize imports',           cmd = 'lua vim.lsp.buf.code_action({ apply = true, filter = function(a) return a.title:match("import") end })' },
        -- Git
        { key = 'gg',  desc = '[git] Open LazyGit',                cmd = 'LazyGit' },
        { key = 'gd',  desc = '[git] Diff view (working tree)',    cmd = 'DiffviewOpen' },
        { key = 'gh',  desc = '[git] File history',                cmd = 'DiffviewFileHistory %' },
        { key = 'gH',  desc = '[git] Branch history',              cmd = 'DiffviewFileHistory' },
        { key = 'gf',  desc = '[git] File history (LazyGit)',      cmd = 'LazyGitFilterCurrentFile' },
        { key = 'gq',  desc = '[git] Close diff view',             cmd = 'DiffviewClose' },
        -- LSP
        { key = 'lr',  desc = '[lsp] Rename symbol',               cmd = 'lua vim.lsp.buf.rename()' },
        { key = 'la',  desc = '[lsp] Code actions',                cmd = 'lua vim.lsp.buf.code_action()' },
        { key = 'lf',  desc = '[lsp] Format buffer',               cmd = 'lua vim.lsp.buf.format()' },
        { key = 'ld',  desc = '[lsp] Line diagnostics',            cmd = 'lua vim.diagnostic.open_float()' },
        -- Tabs (bufferline)
        { key = 'th',  desc = '[tab] Previous tab',                cmd = 'BufferLineCyclePrev' },
        { key = 'tn',  desc = '[tab] Next tab',                    cmd = 'BufferLineCycleNext' },
        { key = 'td',  desc = '[tab] Close current tab',           cmd = 'bprevious | bdelete #' },
        { key = 'to',  desc = '[tab] Close other tabs',            cmd = 'BufferLineCloseOthers' },
        { key = 'tl',  desc = '[tab] Close tabs to left',          cmd = 'BufferLineCloseLeft' },
        { key = 'tr',  desc = '[tab] Close tabs to right',         cmd = 'BufferLineCloseRight' },
        { key = 'tp',  desc = '[tab] Pin/unpin tab',               cmd = 'BufferLineTogglePin' },
        { key = 'ts',  desc = '[tab] Pick tab (letter)',           cmd = 'BufferLinePick' },
        { key = 'tf',  desc = '[tab] Find tab (fuzzy)',            cmd = 'Telescope buffers' },
        { key = 'tD',  desc = '[tab] Pick tab to close',           cmd = 'BufferLinePickClose' },
        { key = 't1',  desc = '[tab] Go to tab 1',                 cmd = 'BufferLineGoToBuffer 1' },
        { key = 't2',  desc = '[tab] Go to tab 2',                 cmd = 'BufferLineGoToBuffer 2' },
        { key = 't3',  desc = '[tab] Go to tab 3',                 cmd = 'BufferLineGoToBuffer 3' },
        -- Session
        { key = 'qs',  desc = '[session] Restore for cwd',         cmd = "lua require('persistence').load()" },
        { key = 'ql',  desc = '[session] Restore last',            cmd = "lua require('persistence').load({ last = true })" },
        { key = 'qS',  desc = '[session] Save current',            cmd = "lua require('persistence').save()" },
        { key = 'qd',  desc = '[session] Disable auto-save',       cmd = "lua require('persistence').stop()" },
        -- UI Toggles
        { key = 'un',  desc = '[ui] Toggle line numbers',          cmd = 'set number!' },
        { key = 'ur',  desc = '[ui] Toggle relative numbers',      cmd = 'set relativenumber!' },
        { key = 'uw',  desc = '[ui] Toggle word wrap',             cmd = 'set wrap!' },
        { key = 'us',  desc = '[ui] Toggle spell check',           cmd = 'set spell!' },
        { key = 'ul',  desc = '[ui] Toggle whitespace chars',      cmd = 'set list!' },
        { key = 'uc',  desc = '[ui] Toggle cursor line',           cmd = 'set cursorline!' },
        { key = 'ud',  desc = '[ui] Toggle diagnostics',           cmd = 'lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())' },
        { key = 'ut',  desc = '[ui] Toggle treesitter highlight',  cmd = 'lua if vim.b.ts_highlight then vim.treesitter.stop() else vim.treesitter.start() end; vim.b.ts_highlight = not vim.b.ts_highlight' },
        -- Buffer/Search
        { key = '/',   desc = '[search] Fuzzy search in buffer',   cmd = 'Telescope current_buffer_fuzzy_find' },
        -- Quick actions
        { key = 'w',   desc = '[quick] Save file',                 cmd = 'w' },
        { key = 'q',   desc = '[quick] Quit window',               cmd = 'q' },
        { key = 'x',   desc = '[quick] Save and quit',             cmd = 'x' },
        { key = 'ap',  desc = '[python] Autopep8 format',          cmd = 'Autopep8' },
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

    -- Search/Replace shortcuts (<Leader>s)
    vim.keymap.set('n', '<Leader>sr', ':%s/', { desc = 'Search & replace' })
    vim.keymap.set('n', '<Leader>sR', ':%s/<C-r><C-w>/', { desc = 'Replace word under cursor' })
    vim.keymap.set('n', '<Leader>sw', builtin.grep_string, { desc = 'Search word under cursor' })
    vim.keymap.set('n', '<Leader>ss', builtin.live_grep, { desc = 'Search in project' })
    vim.keymap.set('v', '<Leader>ss', function()
        -- Get visual selection
        vim.cmd('noau normal! "vy"')
        local text = vim.fn.getreg('v')
        text = string.gsub(text, '\n', '')
        builtin.grep_string({ search = text })
    end, { desc = 'Search selection' })
    vim.keymap.set('n', '<Leader>sn', ':nohlsearch<CR>', { silent = true, desc = 'Clear search highlight' })
    vim.keymap.set('n', '<Leader>sb', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })

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
        { '<Leader>t', group = 'tabs' },
        { '<Leader>l', group = 'lsp' },
        { '<Leader>g', group = 'git' },
        { '<Leader>a', group = 'actions' },
        { '<Leader>s', group = 'search' },
        { '<Leader>c', group = 'code' },
        { '<Leader>u', group = 'ui' },
        { '<Leader>q', group = 'session/quit' },
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
-- Code/Refactor Shortcuts (<Leader>c)
--------------------------------------------------------------------------------
-- These provide convenient aliases for common code actions
-- (Some overlap with <Leader>l LSP shortcuts intentionally for discoverability)

vim.keymap.set('n', '<Leader>cf', function()
    vim.lsp.buf.format({ async = true })
end, { desc = 'Format buffer' })
vim.keymap.set('n', '<Leader>cr', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
vim.keymap.set('v', '<Leader>ca', vim.lsp.buf.code_action, { desc = 'Code action (visual)' })
vim.keymap.set('n', '<Leader>cd', vim.diagnostic.open_float, { desc = 'Line diagnostics' })
vim.keymap.set('n', '<Leader>ci', function()
    -- Organize imports (works with pyright and ts_ls)
    vim.lsp.buf.code_action({
        apply = true,
        filter = function(action)
            return action.title:match('import') or action.title:match('Import')
        end,
    })
end, { desc = 'Organize imports' })

--------------------------------------------------------------------------------
-- Bufferline (Tab Bar)
--------------------------------------------------------------------------------
if plugin_loaded('bufferline') then
    require('bufferline').setup({
        options = {
            mode = 'buffers',
            style_preset = require('bufferline').style_preset.default,
            numbers = 'ordinal',  -- Show buffer numbers for <Leader>t1-9
            close_command = 'bdelete! %d',
            right_mouse_command = 'bdelete! %d',
            left_mouse_command = 'buffer %d',
            middle_mouse_command = 'bdelete! %d',
            indicator = {
                icon = '▎',
                style = 'icon',
            },
            buffer_close_icon = '󰅖',
            modified_icon = '●',
            close_icon = '',
            left_trunc_marker = '',
            right_trunc_marker = '',
            max_name_length = 30,
            max_prefix_length = 15,
            truncate_names = true,
            tab_size = 18,
            diagnostics = 'nvim_lsp',
            diagnostics_update_in_insert = false,
            diagnostics_indicator = function(count, level)
                local icon = level:match('error') and ' ' or ' '
                return ' ' .. icon .. count
            end,
            offsets = {
                {
                    filetype = 'NvimTree',
                    text = 'File Explorer',
                    text_align = 'center',
                    separator = true,
                },
            },
            color_icons = true,
            show_buffer_icons = true,
            show_buffer_close_icons = true,
            show_close_icon = false,
            show_tab_indicators = true,
            show_duplicate_prefix = true,
            separator_style = 'slant',
            enforce_regular_tabs = false,
            always_show_bufferline = true,
            hover = {
                enabled = true,
                delay = 200,
                reveal = { 'close' },
            },
            sort_by = 'insert_at_end',
        },
        -- Use catppuccin highlights if available
        highlights = (function()
            local ok, catppuccin = pcall(require, 'catppuccin.groups.integrations.bufferline')
            if ok then
                return catppuccin.get()
            end
            return {}
        end)(),
    })

    -- Tab navigation shortcuts (<Leader>t)
    vim.keymap.set('n', '<Leader>th', ':BufferLineCyclePrev<CR>', { silent = true, desc = 'Previous tab' })
    vim.keymap.set('n', '<Leader>tn', ':BufferLineCycleNext<CR>', { silent = true, desc = 'Next tab' })
    vim.keymap.set('n', '<Leader>td', ':bprevious<CR>:bdelete #<CR>', { silent = true, desc = 'Close tab' })
    vim.keymap.set('n', '<Leader>to', ':BufferLineCloseOthers<CR>', { silent = true, desc = 'Close other tabs' })
    vim.keymap.set('n', '<Leader>tl', ':BufferLineCloseLeft<CR>', { silent = true, desc = 'Close tabs to the left' })
    vim.keymap.set('n', '<Leader>tr', ':BufferLineCloseRight<CR>', { silent = true, desc = 'Close tabs to the right' })
    vim.keymap.set('n', '<Leader>tp', ':BufferLineTogglePin<CR>', { silent = true, desc = 'Pin/unpin tab' })
    vim.keymap.set('n', '<Leader>ts', ':BufferLinePick<CR>', { silent = true, desc = 'Pick tab' })
    vim.keymap.set('n', '<Leader>tD', ':BufferLinePickClose<CR>', { silent = true, desc = 'Pick tab to close' })
    vim.keymap.set('n', '<Leader>tf', ':Telescope buffers<CR>', { silent = true, desc = 'Find tab' })

    -- Jump to tab by number
    vim.keymap.set('n', '<Leader>t1', ':BufferLineGoToBuffer 1<CR>', { silent = true, desc = 'Go to tab 1' })
    vim.keymap.set('n', '<Leader>t2', ':BufferLineGoToBuffer 2<CR>', { silent = true, desc = 'Go to tab 2' })
    vim.keymap.set('n', '<Leader>t3', ':BufferLineGoToBuffer 3<CR>', { silent = true, desc = 'Go to tab 3' })
    vim.keymap.set('n', '<Leader>t4', ':BufferLineGoToBuffer 4<CR>', { silent = true, desc = 'Go to tab 4' })
    vim.keymap.set('n', '<Leader>t5', ':BufferLineGoToBuffer 5<CR>', { silent = true, desc = 'Go to tab 5' })
    vim.keymap.set('n', '<Leader>t6', ':BufferLineGoToBuffer 6<CR>', { silent = true, desc = 'Go to tab 6' })
    vim.keymap.set('n', '<Leader>t7', ':BufferLineGoToBuffer 7<CR>', { silent = true, desc = 'Go to tab 7' })
    vim.keymap.set('n', '<Leader>t8', ':BufferLineGoToBuffer 8<CR>', { silent = true, desc = 'Go to tab 8' })
    vim.keymap.set('n', '<Leader>t9', ':BufferLineGoToBuffer 9<CR>', { silent = true, desc = 'Go to tab 9' })
end

--------------------------------------------------------------------------------
-- UI Toggle Shortcuts (<Leader>u)
--------------------------------------------------------------------------------
local function toggle_option(opt)
    return function()
        vim.o[opt] = not vim.o[opt]
        vim.notify(opt .. ': ' .. tostring(vim.o[opt]), vim.log.levels.INFO)
    end
end

vim.keymap.set('n', '<Leader>un', toggle_option('number'), { desc = 'Toggle line numbers' })
vim.keymap.set('n', '<Leader>ur', toggle_option('relativenumber'), { desc = 'Toggle relative numbers' })
vim.keymap.set('n', '<Leader>uw', toggle_option('wrap'), { desc = 'Toggle word wrap' })
vim.keymap.set('n', '<Leader>us', toggle_option('spell'), { desc = 'Toggle spell check' })
vim.keymap.set('n', '<Leader>ul', toggle_option('list'), { desc = 'Toggle list chars' })
vim.keymap.set('n', '<Leader>uc', toggle_option('cursorline'), { desc = 'Toggle cursor line' })

vim.keymap.set('n', '<Leader>ud', function()
    local enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not enabled)
    vim.notify('Diagnostics: ' .. tostring(not enabled), vim.log.levels.INFO)
end, { desc = 'Toggle diagnostics' })

vim.keymap.set('n', '<Leader>ut', function()
    if vim.b.ts_highlight then
        vim.treesitter.stop()
        vim.b.ts_highlight = false
        vim.notify('Treesitter highlighting: off', vim.log.levels.INFO)
    else
        vim.treesitter.start()
        vim.b.ts_highlight = true
        vim.notify('Treesitter highlighting: on', vim.log.levels.INFO)
    end
end, { desc = 'Toggle treesitter highlight' })

--------------------------------------------------------------------------------
-- Session Management (persistence.nvim)
--------------------------------------------------------------------------------
if plugin_loaded('persistence') then
    require('persistence').setup({
        dir = vim.fn.stdpath('state') .. '/sessions/',
        options = { 'buffers', 'curdir', 'tabpages', 'winsize' },
    })

    vim.keymap.set('n', '<Leader>qs', function()
        require('persistence').load()
    end, { desc = 'Restore session (cwd)' })

    vim.keymap.set('n', '<Leader>ql', function()
        require('persistence').load({ last = true })
    end, { desc = 'Restore last session' })

    vim.keymap.set('n', '<Leader>qd', function()
        require('persistence').stop()
        vim.notify('Session auto-save disabled', vim.log.levels.INFO)
    end, { desc = "Don't save session" })

    vim.keymap.set('n', '<Leader>qS', function()
        require('persistence').save()
        vim.notify('Session saved', vim.log.levels.INFO)
    end, { desc = 'Save session' })
end

--------------------------------------------------------------------------------
-- Treesitter Configuration (new API for nvim-treesitter)
--------------------------------------------------------------------------------
if has_nvim_011 and plugin_loaded('nvim-treesitter') then
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
if has_nvim_011 then
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
end

-- NOTE: Incremental selection was removed in the new nvim-treesitter rewrite.
-- The old API (nvim-treesitter.incremental_selection) no longer exists.

--------------------------------------------------------------------------------
-- LSP Configuration (nvim 0.11+ using vim.lsp.config)
--------------------------------------------------------------------------------
if has_nvim_011 then

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

end

--------------------------------------------------------------------------------
-- Autocompletion (nvim-cmp)
--------------------------------------------------------------------------------
if has_nvim_011 and plugin_loaded('cmp') then
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


