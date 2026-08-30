local M = {
  specs = {
    { src = "https://github.com/stevearc/conform.nvim" },
    { src = "https://github.com/mfussenegger/nvim-lint" },
    { src = "https://github.com/folke/ts-comments.nvim" },
  },
}

local function first_available(lint, candidates)
  for _, name in ipairs(candidates) do
    local linter = lint.linters[name]
    if linter then
      local command = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
      if command and vim.fn.executable(command) == 1 then
        return name
      end
    end
  end
end

function M.setup(pack)
  local use_conform = pack.use("conform", "conform.nvim", function()
    require("conform").setup({
      default_format_opts = { lsp_format = "fallback", timeout_ms = 3000 },
      formatters_by_ft = {
        css = { "prettierd", "prettier", stop_after_first = true },
        go = { "goimports", "gofmt", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        mdx = { "prettierd", "prettier", stop_after_first = true },
        python = { "ruff_format" },
        rust = { "rustfmt", lsp_format = "fallback" },
        sh = { "shfmt" },
        sql = { "sqlfluff" },
        toml = { "taplo" },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
      },
    })
  end)

  local function format()
    if use_conform() then
      require("conform").format({ async = true, lsp_format = "fallback" })
    end
  end
  vim.keymap.set("n", "<leader>cf", format, { desc = "Format buffer" })
  vim.api.nvim_create_user_command("Format", format, { desc = "Format current buffer" })

  local use_lint = pack.use("lint", "nvim-lint", function() end)
  local linters = {
    css = { "stylelint" },
    dockerfile = { "hadolint" },
    go = { "golangcilint" },
    javascript = { "eslint_d", "eslint" },
    javascriptreact = { "eslint_d", "eslint" },
    markdown = { "markdownlint-cli2", "markdownlint" },
    mdx = { "eslint_d", "eslint" },
    python = { "ruff" },
    rust = { "clippy" },
    sql = { "sqlfluff" },
    typescript = { "eslint_d", "eslint" },
    typescriptreact = { "eslint_d", "eslint" },
    yaml = { "yamllint" },
  }

  local function lint_buffer()
    if not use_lint() then return end
    local lint = require("lint")
    local name = first_available(lint, linters[vim.bo.filetype] or {})
    if not name then
      vim.notify("No configured linter is available for " .. vim.bo.filetype, vim.log.levels.WARN)
      return
    end
    lint.try_lint(name)
  end
  vim.keymap.set("n", "<leader>cL", lint_buffer, { desc = "Lint buffer" })
  vim.api.nvim_create_user_command("Lint", lint_buffer, { desc = "Lint current buffer" })

  pack.event("ts-comments", "ts-comments.nvim", "FileType", function()
    require("ts-comments").setup()
  end, {
    condition = function(event)
      return vim.bo[event.buf].buftype == "" and event.match ~= ""
    end,
  })
end

return M
