local M = {
  specs = {
    {
      src = "https://github.com/saghen/blink.cmp",
      version = vim.version.range("1.*"),
    },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
  },
}

local use

function M.setup(pack)
  local plugins = { "friendly-snippets", "blink.cmp" }
  local function configure()
    require("blink.cmp").setup({
      keymap = {
        preset = "enter",
        ["<C-e>"] = { "fallback" },
        ["<C-k>"] = { "fallback" },
        ["<C-y>"] = { "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true },
      snippets = { preset = "default" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    })
  end

  use = pack.use("blink", plugins, configure)
  pack.event("blink", plugins, { "InsertEnter", "CmdlineEnter" }, configure)
end

function M.capabilities()
  if use and use() then
    return require("blink.cmp").get_lsp_capabilities()
  end
  return vim.lsp.protocol.make_client_capabilities()
end

return M
