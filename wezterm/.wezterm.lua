local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
	font = wezterm.font({ family = "Hack Nerd Font" }),
}

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

return config
