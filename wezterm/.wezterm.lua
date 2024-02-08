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

local wsl_domains = wezterm.default_wsl_domains()
for _, domain in ipairs(wsl_domains) do
	if domain.name == "WSL:Ubuntu" then
		config.default_domain = domain.name
	end
end

-- tmux
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- move
	{
		key = "h",
		mods = "CTRL",
		action = wezterm.action({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "j",
		mods = "CTRL",
		action = wezterm.action({ ActivatePaneDirection = "Down" }),
	},
	{
		key = "k",
		mods = "CTRL",
		action = wezterm.action({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "l",
		mods = "CTRL",
		action = wezterm.action({ ActivatePaneDirection = "Right" }),
	},
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
		mods = "LEADER",
		key = "z",
		action = wezterm.action.TogglePaneZoomState,
	},
}

return config
