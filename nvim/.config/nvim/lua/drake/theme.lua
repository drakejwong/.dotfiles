-- colorscheme
require("onedark").setup({
  functionStyle = "italic",
  sidebars = {"qf", "vista_kind", "terminal", "packer"},
  transparent = true,
})

-- lualine
require("lualine").setup {
  options = {
    theme = "onedark",
  }
}
