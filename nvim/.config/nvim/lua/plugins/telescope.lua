return {
  {
    "telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end,
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
        keys = {
          {
            "<leader>sf",
            "<cmd>Telescope file_browser path=%:p:h=%:p:h<CR>", -- use path of current file
            desc = "Browse Files",
          },
        },
        config = function()
          require("telescope").load_extension("file_browser")
        end,
      },
    },
  },
}
