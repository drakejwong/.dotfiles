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
    -- TODO: put these in insert mode too
    {
      "<C-h>",
      function()
        require("tmux").move_left()
      end,
      desc = "Move Left (tmux)",
    },
    {
      "<C-j>",
      function()
        require("tmux").move_bottom()
      end,
      desc = "Move Down (tmux)",
    },
    {
      "<C-k>",
      function()
        require("tmux").move_top()
      end,
      desc = "Move Up (tmux)",
    },
    {
      "<C-l>",
      function()
        require("tmux").move_right()
      end,
      desc = "Move Right (tmux)",
    },
    {
      "<M-h>",
      function()
        require("tmux").resize_left()
      end,
      desc = "Resize Left (tmux)",
    },
    {
      "<M-j>",
      function()
        require("tmux").resize_bottom()
      end,
      desc = "Resize Down (tmux)",
    },
    {
      "<M-k>",
      function()
        require("tmux").resize_top()
      end,
      desc = "Resize Up (tmux)",
    },
    {
      "<M-l>",
      function()
        require("tmux").resize_right()
      end,
      desc = "Resize Right (tmux)",
    },
  },
}
