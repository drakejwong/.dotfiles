local M = {
  specs = {
    { src = "https://github.com/nvim-mini/mini.nvim" },
    { src = "https://github.com/folke/flash.nvim" },
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/gbprod/yanky.nvim" },
    { src = "https://github.com/monaqa/dial.nvim" },
  },
}

function M.setup(pack)
  local use_mini = pack.use("mini", "mini.nvim", function()
    require("mini.icons").setup()
    require("mini.icons").mock_nvim_web_devicons()
    require("mini.ai").setup({ n_lines = 500 })
    require("mini.pairs").setup()
    require("mini.surround").setup({
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    })
  end)
  use_mini()

  local use_flash = pack.use("flash", "flash.nvim", function()
    require("flash").setup()
  end)
  local flash_maps = {
    { { "n", "x", "o" }, "s", function() require("flash").jump() end, "Flash" },
    { { "n", "x", "o" }, "S", function() require("flash").treesitter() end, "Flash Treesitter" },
    { "o", "r", function() require("flash").remote() end, "Remote Flash" },
    { { "o", "x" }, "R", function() require("flash").treesitter_search() end, "Treesitter Search" },
  }
  for _, mapping in ipairs(flash_maps) do
    local mode, lhs, action, desc = unpack(mapping)
    vim.keymap.set(mode, lhs, function()
      if use_flash() then action() end
    end, { desc = desc })
  end

  pack.defer("which-key", "which-key.nvim", function()
    require("which-key").setup({ preset = "helix", delay = 500 })
    require("which-key").add({
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "file/find" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "search" },
      { "<leader>u", group = "ui" },
      { "<leader>x", group = "diagnostics" },
    })
  end)

  pack.defer("yanky", "yanky.nvim", function()
    require("yanky").setup({
      highlight = { timer = 150 },
      system_clipboard = { sync_with_ring = not vim.env.SSH_CONNECTION },
    })
  end)
  local yanky_maps = {
    { { "n", "x" }, "y", "<Plug>(YankyYank)", "Yank" },
    { { "n", "x" }, "p", "<Plug>(YankyPutAfter)", "Put after" },
    { { "n", "x" }, "P", "<Plug>(YankyPutBefore)", "Put before" },
    { "n", "[y", "<Plug>(YankyCycleForward)", "Previous yank" },
    { "n", "]y", "<Plug>(YankyCycleBackward)", "Next yank" },
  }
  for _, mapping in ipairs(yanky_maps) do
    vim.keymap.set(mapping[1], mapping[2], mapping[3], { desc = mapping[4], remap = true })
  end

  local use_dial = pack.use("dial", "dial.nvim", function()
    local augend = require("dial.augend")
    require("dial.config").augends:register_group({
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.constant.alias.bool,
        augend.semver.alias.semver,
      },
    })
  end)
  vim.keymap.set("n", "<C-a>", function()
    if use_dial() then require("dial.map").manipulate("increment", "normal") end
  end, { desc = "Increment" })
  vim.keymap.set("n", "<C-x>", function()
    if use_dial() then require("dial.map").manipulate("decrement", "normal") end
  end, { desc = "Decrement" })
end

return M
