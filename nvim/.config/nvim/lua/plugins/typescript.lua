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
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      vim.list_extend(opts.sources, {
        nls.builtins.code_actions.eslint_d,
        -- nls.builtins.code_actions.refactoring, -- TODO: move to global config
        -- nls.builtins.diagnostics.codespell, -- TODO: move to global config
        -- nls.builtins.diagnostics.jshint,
        -- nls.builtins.diagnostics.semgrep, -- TODO: move to global config
        -- nls.builtins.diagnostics.standardts, -- TODO: not supported by mason
        -- nls.builtins.diagnostics.stylelint,
        -- nls.builtins.diagnostics.tsc,
        nls.builtins.formatting.eslint_d,
        -- nls.builtins.formatting.prettierd, -- prettier is too opinionated
        nls.builtins.formatting.rustywind,
        -- nls.builtins.formatting.sqlfluff.with({ extra_args = { "--dialect", "postgres" } }), -- TODO: move to global config
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },
}
