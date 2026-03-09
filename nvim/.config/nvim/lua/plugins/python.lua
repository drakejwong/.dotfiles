vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.keymap.set("n", "<leader>cf", "<cmd>!uv run ruff format %<CR>", {
      buffer = true, -- Makes it local to this buffer
      desc = "Run ruff on current file",
    })
  end,
})

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
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- add tsx and treesitter
      -- stylua: ignore
      vim.list_extend(opts.ensure_installed, {
        "ruff",
        "isort",
        "basedpyright",
      })
    end,
  },
}
