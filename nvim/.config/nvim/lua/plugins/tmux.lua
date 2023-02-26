return {
  "aserowy/tmux.nvim",
  opts = {
    navigation = {
      cycle_navigation = false,
      enable_default_keybindings = false,
    },
    resize = {
      enable_default_keybindings = false,
    },
  },
  keys = {
    {
      "<C-h>",
      function()
        require("tmux").move_left()
      end,
    },
    {
      "<C-j>",
      function()
        require("tmux").move_bottom()
      end,
    },
    {
      "<C-k>",
      function()
        require("tmux").move_top()
      end,
    },
    {
      "<C-l>",
      function()
        require("tmux").move_right()
      end,
    },

    {
      "<M-h>",
      function()
        require("tmux").resize_left()
      end,
    },
    {
      "<M-j>",
      function()
        require("tmux").resize_bottom()
      end,
    },
    {
      "<M-k>",
      function()
        require("tmux").resize_top()
      end,
    },
    {
      "<M-l>",
      function()
        require("tmux").resize_right()
      end,
    },
  },
}
