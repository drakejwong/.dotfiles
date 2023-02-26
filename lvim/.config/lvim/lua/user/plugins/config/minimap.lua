local status_ok, map = pcall(require, "mini.map")
if not status_ok then
  return
end

map.setup {
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.gitsigns(),
    map.gen_integration.diagnostic({
      error = 'DiagnosticFloatingError',
      warn  = 'DiagnosticFloatingWarn',
      info  = 'DiagnosticFloatingInfo',
      hint  = 'DiagnosticFloatingHint',
    }),
  },
  symbols = {
    encode = map.gen_encode_symbols.dot('4x2'),
  },
  window = {
    side = 'right',
    width = 5, -- set to 1 for a pure scrollbar :)
    winblend = 50,
    show_integration_count = false,
  },
}

-- auto open for specific types
lvim.autocommands = {
  {
    {"BufEnter", "Filetype"},
    {
      desc = "Open mini.map and exclude some filetypes",
      pattern = { "*" },
      callback = function()
        local exclude_ft = {
          "qf",
          "NvimTree",
          "toggleterm",
          "TelescopePrompt",
          "alpha",
          "netrw",
        }
        if vim.tbl_contains(exclude_ft, vim.o.filetype) then
          vim.b.minimap_disable = true
          map.close()
        elseif vim.o.buftype == "" then
          map.open()
        end
      end,
    },
  },
}

lvim.builtin.which_key.mappings["m"] = {
  name = "+MiniMap",
  t = { "<cmd>lua MiniMap.toggle()<cr>", "Toggle" },
  s = { "<cmd>lua MiniMap.toggle_side()<cr>", "Toggle Side" },
  o = { "<cmd>lua MiniMap.open()<cr>", "Open" },
  c = { "<cmd>lua MiniMap.close()<cr>", "Close" },
  r = { "<cmd>lua MiniMap.refresh()<cr>", "Refresh" },
  f = { "<cmd>lua MiniMap.toggle_focus()<cr>", "Toggle Focus" },
}
