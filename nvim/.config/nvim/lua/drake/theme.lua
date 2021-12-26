function req_setup(arg)
  require(arg).setup()
end

-- colorscheme
local colorscheme = "onedark"

local status_ok, _ = pcall(req_setup, colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

-- lualine
require("lualine").setup {
  options = {
    theme = "onedark",
  }
}
