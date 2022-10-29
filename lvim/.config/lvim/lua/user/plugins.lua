-- Additional Plugins
lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  { "christoomey/vim-tmux-navigator" },
  { "hkupty/iron.nvim" },
  { "kevinhwang91/nvim-bqf" },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    module = "persistence",
    config = function()
      require("persistence").setup()
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
}
