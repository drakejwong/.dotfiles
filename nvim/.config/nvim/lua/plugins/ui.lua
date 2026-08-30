local M = {
  specs = {
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/akinsho/bufferline.nvim" },
    { src = "https://github.com/folke/noice.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
  },
}

function M.setup(pack)
  local use_snacks = pack.use("snacks", { "mini.nvim", "snacks.nvim" }, function()
    require("snacks").setup({
      animate = { enabled = false },
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = require("plugins.dashboard").header(),
          keys = {
            { icon = " ", key = "f", desc = "Find file", action = function() require("plugins.fzf").files() end },
            { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
            { icon = " ", key = "r", desc = "Recent files", action = function() require("plugins.fzf").oldfiles() end },
            { icon = " ", key = "g", desc = "Find text", action = function() require("plugins.fzf").grep() end },
            { icon = " ", key = "c", desc = "Config", action = function()
              require("plugins.fzf").files({ cwd = vim.fn.stdpath("config") })
            end },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        -- Snacks' default startup section requires lazy.nvim's statistics module.
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
        },
      },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      terminal = { enabled = true },
      words = { enabled = true },
    })
  end)
  use_snacks()

  pack.load("tokyonight.nvim")
  local ok = pcall(vim.cmd.colorscheme, "tokyonight-moon")
  if not ok then vim.cmd.colorscheme("habamax") end

  vim.keymap.set("n", "<leader>e", function()
    if use_snacks() then Snacks.explorer({ cwd = require("config.root").get() }) end
  end, { desc = "Explorer (root)" })
  vim.keymap.set("n", "<leader>E", function()
    if use_snacks() then Snacks.explorer() end
  end, { desc = "Explorer (cwd)" })
  vim.keymap.set({ "n", "t" }, "<C-/>", function()
    if use_snacks() then Snacks.terminal.toggle(nil, { cwd = require("config.root").get() }) end
  end, { desc = "Terminal" })
  vim.keymap.set("n", "<leader>gg", function()
    if use_snacks() then Snacks.terminal("jj", { cwd = require("config.root").get() }) end
  end, { desc = "Jujutsu terminal" })

  pack.defer("lualine", { "mini.nvim", "lualine.nvim" }, function()
    require("lualine").setup({
      options = { globalstatus = true, theme = "auto" },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = { { "diagnostics" }, { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end)

  pack.defer("bufferline", { "mini.nvim", "snacks.nvim", "bufferline.nvim" }, function()
    require("bufferline").setup({
      options = {
        always_show_bufferline = false,
        diagnostics = "nvim_lsp",
        close_command = function(buf) Snacks.bufdelete(buf) end,
        right_mouse_command = function(buf) Snacks.bufdelete(buf) end,
      },
    })
  end)

  pack.defer("noice", { "nui.nvim", "snacks.nvim", "noice.nvim" }, function()
    require("noice").setup({
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = { bottom_search = true, command_palette = true, long_message_to_split = true },
    })
  end)
end

return M
