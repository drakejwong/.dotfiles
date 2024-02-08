return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    config = function()
      require("smart-splits").setup({
        multiplexer_integration = "WezTerm",
      })
    end,
  },
  keys = {
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Move Left (smart splits)",
    },
    {
      "<C-j>",
      function()
      require("smart-splits").move_cursor_down()
      end,
      desc = "Move Down (smart splits)",
    },
    {
      "<C-k>",
      function()
      require("smart-splits").move_cursor_up()
      end,
      desc = "Move Up (smart splits)",
    },
    {
      "<C-l>",
      function()
      require("smart-splits").move_cursor_right()
      end,
      desc = "Move Right (smart splits)",
    },
    {
      "<M-h>",
      function()
      require("smart-splits").resize_left()
      end,
      desc = "Resize Left (smart splits)",
    },
    {
      "<M-j>",
      function()
      require("smart-splits").resize_bottom()
      end,
      desc = "Resize Down (smart splits)",
    },
    {
      "<M-k>",
      function()
      require("smart-splits").resize_top()
      end,
      desc = "Resize Up (smart splits)",
    },
    {
      "<M-l>",
      function()
      require("smart-splits").resize_right()
      end,
      desc = "Resize Right (smart splits)",
    },
  },
}
