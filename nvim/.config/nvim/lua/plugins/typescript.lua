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
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ---@type lspconfig.options.tsserver
        tsserver = {
          root_dir = require('lspconfig.util').root_pattern(".git"),
          keys = {
            {
              "<leader>cR",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.removeUnused.ts" },
                    diagnostics = {},
                  },
                })
              end,
              desc = "Remove Unused Imports",
            },
          },
          ---@diagnostic disable-next-line: missing-fields
          settings = {
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
      },
    },
  },
}
