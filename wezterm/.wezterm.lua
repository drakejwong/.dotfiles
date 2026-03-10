local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.hide_tab_bar_if_only_one_tab = true

config.font = wezterm.font({
	family = "Hack Nerd Font",
})

config.color_scheme = "tokyonight"

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.inactive_pane_hsb = {
	hue = 1.0,
	saturation = 0.8,
	brightness = 0.5,
}

local wsl_domains = wezterm.default_wsl_domains()
for _, domain in ipairs(wsl_domains) do
	if domain.name == "WSL:Ubuntu" then
		config.default_domain = domain.name
	end
end

config.unix_domains = {
	{
		name = "wsl",
		-- Override the default path to match the default on the host win32
		-- filesystem.  This will allow the host to connect into the WSL
		-- container.
		socket_path = "/mnt/c/Users/drake/.local/share/wezterm/sock",
		-- NTFS permissions will always be "wrong", so skip that check
		skip_permissions_check = true,
	},
}

-- Ctrl+hjkl: pass through to zellij/nvim if running, otherwise navigate wezterm panes
local direction_keys = { h = "Left", j = "Down", k = "Up", l = "Right" }

local function pane_nav(key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(win, pane)
			local name = pane:get_foreground_process_name() or ""
			if name:find("zellij") or name:find("n?vim") then
				win:perform_action(wezterm.action.SendKey({ key = key, mods = "CTRL" }), pane)
			else
				win:perform_action(wezterm.action.ActivatePaneDirection(direction_keys[key]), pane)
			end
		end),
	}
end

------------------
------ KEYS ------
------------------
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- Ctrl+hjkl: nvim > zellij > wezterm
	pane_nav("h"),
	pane_nav("j"),
	pane_nav("k"),
	pane_nav("l"),
	-- LEADER move (explicit wezterm pane nav)
	{ key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	-- LEADER resize
	{ key = "H", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Left", 3 } }) },
	{ key = "J", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Down", 3 } }) },
	{ key = "K", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Up", 3 } }) },
	{ key = "L", mods = "LEADER", action = wezterm.action({ AdjustPaneSize = { "Right", 3 } }) },
	-- swap
	{
		key = "{",
		mods = "LEADER|SHIFT",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	-- split
	{
		key = "-",
		mods = "LEADER",
		action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
	},
	{
		key = "|",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
	},
	-- zoom
	{
		mods = "LEADER|CTRL",
		key = "s",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		mods = "LEADER",
		key = "z",
		action = wezterm.action.TogglePaneZoomState,
	},
	--- disable alt+enter
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

local act = wezterm.action

config.mouse_bindings = {
	-- Single click select: do NOT auto-copy to clipboard
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.Nop,
	},
	-- Double click (word select): do NOT auto-copy to clipboard
	{
		event = { Up = { streak = 2, button = "Left" } },
		mods = "NONE",
		action = act.Nop,
	},
	-- Triple click (line select): do NOT auto-copy to clipboard
	{
		event = { Up = { streak = 3, button = "Left" } },
		mods = "NONE",
		action = act.Nop,
	},

	-- SHIFT-Click opens hyperlinks
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SHIFT",
		action = act.OpenLinkAtMouseCursor,
	},

	-- Disable the 'Down' event of SHIFT-Click to avoid weird program behaviors
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "SHIFT",
		action = act.Nop,
	},
}

return config
