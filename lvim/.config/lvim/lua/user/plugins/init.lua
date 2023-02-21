lvim.plugins = {
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  { "hkupty/iron.nvim" },
  { "kevinhwang91/nvim-bqf" },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    config = function()
      require("persistence").setup()
    end,
  },
  { "nvim-treesitter/nvim-treesitter-context" },
  { "j-hui/fidget.nvim" },
  { "ggandor/leap.nvim" },
  { "nacro90/numb.nvim" },
  { "aserowy/tmux.nvim" },
  { "echasnovski/mini.nvim" },
  { "kylechui/nvim-surround" },
  { "sindrets/diffview.nvim" },
}

-- plugin config
require("user.plugins.config.bqf")
require("user.plugins.config.fidget")
require("user.plugins.config.iron")
require("user.plugins.config.leap")
require("user.plugins.config.minimap")
require("user.plugins.config.tmux")
require("user.plugins.config.tscontext")

-- oneline config
-- require("mini.surround").setup()
require("numb").setup()
require("nvim-surround").setup()
