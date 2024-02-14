return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    config = function()
      require("smart-splits").setup({
      })
    end,
  },
  keys = {
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left({ at_edge = 'stop' })
      end,
      desc = "Move Left (smart splits)",
    },
    {
      "<C-j>",
      function()
      require("smart-splits").move_cursor_down({ at_edge = 'stop' })
      end,
      desc = "Move Down (smart splits)",
    },
    {
      "<C-k>",
      function()
      require("smart-splits").move_cursor_up({ at_edge = 'stop' })
      end,
      desc = "Move Up (smart splits)",
    },
    {
      "<C-l>",
      function()
      require("smart-splits").move_cursor_right({ at_edge = 'stop' })
      end,
      desc = "Move Right (smart splits)",
    },
    {
      "<M-h>",
      function()
      require("smart-splits").resize_left({ at_edge = 'stop' })
      end,
      desc = "Resize Left (smart splits)",
    },
    {
      "<M-j>",
      function()
      require("smart-splits").resize_bottom({ at_edge = 'stop' })
      end,
      desc = "Resize Down (smart splits)",
    },
    {
      "<M-k>",
      function()
      require("smart-splits").resize_top({ at_edge = 'stop' })
      end,
      desc = "Resize Up (smart splits)",
    },
    {
      "<M-l>",
      function()
      require("smart-splits").resize_right({ at_edge = 'stop' })
      end,
      desc = "Resize Right (smart splits)",
    },
  },
}
