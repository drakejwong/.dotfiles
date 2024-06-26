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

-- nvim smart splits
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	Left = "h",
	Down = "j",
	Up = "k",
	Right = "l",
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

------------------
------ KEYS ------
------------------
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	-- move
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
  {
    key = "h",
    mods = "LEADER",
    action = wezterm.action({ ActivatePaneDirection = "Left" }),
  },
  {
    key = "j",
    mods = "LEADER",
    action = wezterm.action({ ActivatePaneDirection = "Down" }),
  },
  {
    key = "k",
    mods = "LEADER",
    action = wezterm.action({ ActivatePaneDirection = "Up" }),
  },
  {
    key = "l",
    mods = "LEADER",
    action = wezterm.action({ ActivatePaneDirection = "Right" }),
  },
	-- resize
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
  {
    key = "H",
    mods = "LEADER",
    action = wezterm.action({ AdjustPaneSize = { "Left", 3 } }),
  },
  {
    key = "J",
    mods = "LEADER",
    action = wezterm.action({ AdjustPaneSize = { "Down", 3 } }),
  },
  {
    key = "K",
    mods = "LEADER",
    action = wezterm.action({ AdjustPaneSize = { "Up", 3 } }),
  },
  {
    key = "L",
    mods = "LEADER",
    action = wezterm.action({ AdjustPaneSize = { "Right", 3 } }),
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

local act = wezterm.action;

config.mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event={Up={streak=1, button="Left"}},
    mods="NONE",
    action=act.CompleteSelection("PrimarySelection"),
  },

  -- and make SHIFT-Click open hyperlinks
  {
    event={Up={streak=1, button="Left"}},
    mods="SHIFT",
    action=act.OpenLinkAtMouseCursor,
  },

  -- Disable the 'Down' event of SHIFT-Click to avoid weird program behaviors
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SHIFT',
    action = act.Nop,
  }
}

return config
