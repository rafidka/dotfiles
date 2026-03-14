-- wezterm/wezterm.lua - WezTerm terminal configuration
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Watch this file for changes so hot-reload works via the ~/.wezterm.lua wrapper
wezterm.add_to_config_reload_watch_list(os.getenv("HOME") .. "/dotfiles/wezterm/wezterm.lua")

-- ---------------------------------------------------------------------------
-- OS Detection
-- ---------------------------------------------------------------------------
local triple = wezterm.target_triple or ""
local IS_MAC = triple:find("darwin") ~= nil
local IS_LINUX = triple:find("linux") ~= nil

-- ---------------------------------------------------------------------------
-- Color Scheme
-- ---------------------------------------------------------------------------
config.color_scheme = "Builtin Tango Dark"

-- ---------------------------------------------------------------------------
-- Font
-- ---------------------------------------------------------------------------
local emoji_font = IS_MAC and "Apple Color Emoji" or "Noto Color Emoji"
config.font = wezterm.font_with_fallback({
	{ family = "MesloLGS NF", weight = "Regular" },
	"JetBrains Mono",
	"Cascadia Code",
	"FiraCode Nerd Font",
	"Symbols Nerd Font",
	emoji_font,
})
config.font_size = IS_MAC and 14.0 or 11.0
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- ---------------------------------------------------------------------------
-- Cursor
-- ---------------------------------------------------------------------------
config.default_cursor_style = "SteadyBar"

-- ---------------------------------------------------------------------------
-- Window Appearance
-- ---------------------------------------------------------------------------
config.initial_cols = 140
config.initial_rows = 40
config.window_background_opacity = 1.0
config.window_padding = {
	left = 8,
	right = "2cell",
	top = 4,
	bottom = 4,
}

if IS_MAC then
	config.window_decorations = "RESIZE"
	config.native_macos_fullscreen_mode = false
end

-- ---------------------------------------------------------------------------
-- Scroll
-- ---------------------------------------------------------------------------
config.enable_scroll_bar = true
config.scrollback_lines = 100000

-- ---------------------------------------------------------------------------
-- Tab Bar
-- ---------------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

-- ---------------------------------------------------------------------------
-- Performance
-- ---------------------------------------------------------------------------
config.front_end = "WebGpu"
config.animation_fps = 120
config.max_fps = 120

-- ---------------------------------------------------------------------------
-- Alt / Option Key Behavior
-- ---------------------------------------------------------------------------
-- On macOS, keep Option composing so special characters still work.
-- On Linux, disable compose so Alt-* keybindings fire cleanly.
config.send_composed_key_when_left_alt_is_pressed = IS_MAC
config.send_composed_key_when_right_alt_is_pressed = IS_MAC

-- ---------------------------------------------------------------------------
-- Keybindings
-- ---------------------------------------------------------------------------
-- Helper: define a binding once with per-OS modifiers.
--   key(key, mac_mods, linux_mods, action)
-- Pass nil for a modifier to skip that OS.
local function key(k, mac_mods, linux_mods, action)
	if IS_MAC and mac_mods then
		return { key = k, mods = mac_mods, action = action }
	elseif IS_LINUX and linux_mods then
		return { key = k, mods = linux_mods, action = action }
	end
	return nil
end

-- Helper: define a binding that uses the same modifiers on both platforms.
local function key_both(k, mods, action)
	return { key = k, mods = mods, action = action }
end

-- Collect non-nil entries into a list.
local function collect(...)
	local t = {}
	for _, v in ipairs({ ... }) do
		if v then
			t[#t + 1] = v
		end
	end
	return t
end

local act = wezterm.action

config.keys = collect(
	-- Tab navigation
	key("h", "CMD", "ALT", act.ActivateTabRelative(-1)),
	key("n", "CMD", "ALT", act.ActivateTabRelative(1)),

	-- Move tab left/right
	key("h", "CMD|ALT", "ALT|SUPER", act.MoveTabRelative(-1)),
	key("n", "CMD|ALT", "ALT|SUPER", act.MoveTabRelative(1)),

	-- New tab
	key("t", "CMD", "ALT", act.SpawnTab("CurrentPaneDomain")),

	-- Close tab
	key("w", "CMD", "ALT", act.CloseCurrentTab({ confirm = true })),

	-- Clear scrollback
	key("k", "CMD", "ALT", act.Multiple({
		act.ClearScrollback("ScrollbackAndViewport"),
	})),

	-- Toggle fullscreen
	key("Enter", "CMD", "ALT", act.ToggleFullScreen),

	-- Shift+Enter sends ESC+CR (for Claude Code)
	key_both("Enter", "SHIFT", act.SendString("\x1b\r")),

	-- Scroll
	key_both("PageUp", "NONE", act.ScrollByPage(-1)),
	key_both("PageDown", "NONE", act.ScrollByPage(1)),
	key_both("Home", "CTRL", act.ScrollToTop),
	key_both("End", "CTRL", act.ScrollToBottom)
)

-- ---------------------------------------------------------------------------
-- Mouse Bindings
-- ---------------------------------------------------------------------------
config.mouse_bindings = {
	-- Ctrl-click (macOS) / Ctrl-click (Linux) opens URLs
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

-- ---------------------------------------------------------------------------
-- Tab Title Formatting
-- ---------------------------------------------------------------------------
local MAX_TITLE_LEN = 70

local function get_title(tab)
	if tab.tab_title and #tab.tab_title > 0 then
		return tab.tab_title
	end
	return tab.active_pane and tab.active_pane.title or ""
end

local function clamp(s, n)
	s = s or ""
	return (#s > n) and s:sub(1, n) or s
end

local SEPARATOR = "\u{2502}" -- thin vertical line: │
local TAB_BG = "#333333"
local TAB_FG = "#808080"
local ACTIVE_BG = "#0040a0"
local ACTIVE_FG = "#c0c0c0"
local SEP_FG = "#555555"

wezterm.on("format-tab-title", function(tab)
	local title = get_title(tab)

	-- If no title, try to extract the process name from the active pane.
	if title == "" and tab.active_pane then
		local process = tab.active_pane.foreground_process_name or ""
		title = process:match("([^/\\]+)$") or "shell"
	end

	local index = tab.tab_index + 1
	local short = clamp(title, MAX_TITLE_LEN)
	local label = "  " .. index .. ": " .. short .. "  "

	local bg = tab.is_active and ACTIVE_BG or TAB_BG
	local fg = tab.is_active and ACTIVE_FG or TAB_FG

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = label },
		{ Background = { Color = "none" } },
		{ Foreground = { Color = SEP_FG } },
		{ Text = SEPARATOR },
	}
end)

-- ---------------------------------------------------------------------------
return config
