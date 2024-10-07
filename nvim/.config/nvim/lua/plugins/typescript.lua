return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
        "prisma",
        "css",
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- add tsx and treesitter
      -- stylua: ignore
      vim.list_extend(opts.ensure_installed, {
        "eslint_d",
        "prisma-language-server",
        "prettierd",
        "rustywind",
        "semgrep", -- TODO: move to global config
        "stylelint-lsp",
        "sqlfluff",
        "tailwindcss-language-server",
      })
    end,
  },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     servers = {
  --       vtsls = {
  --         root_dir = require('lspconfig.util').root_pattern(".git"),
  --         settings = {
  --           typescript = {
  --             inlayHints = {
  --               enumMemberValues = { enabled = false },
  --               functionLikeReturnTypes = { enabled = false },
  --               parameterNames = { enabled = false },
  --               parameterTypes = { enabled = false },
  --               propertyDeclarationTypes = { enabled = false },
  --               variableTypes = { enabled = false },
  --             },
  --           }
  --         },
  --       },
  --     },
  --   },
  -- },
}
