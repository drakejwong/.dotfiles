return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "python",
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- add tsx and treesitter
      -- stylua: ignore
      vim.list_extend(opts.ensure_installed, {
        "blue",
        "isort",
        "pyright",
      })
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      vim.list_extend(opts.sources, {
        nls.builtins.formatting.blue,
        nls.builtins.formatting.isort,
      })
    end,
  },
}
