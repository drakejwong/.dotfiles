local M = {
  specs = {
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/windwp/nvim-ts-autotag" },
  },
}

local languages = {
  "bash",
  "css",
  "dockerfile",
  "go",
  "gomod",
  "html",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "sql",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

function M.setup(pack)
  local use = pack.use("treesitter", {
    "nvim-treesitter",
    "nvim-treesitter-textobjects",
    "nvim-treesitter-context",
    "nvim-ts-autotag",
  }, function()
    require("nvim-treesitter").setup()
    require("treesitter-context").setup({ max_lines = 4, multiline_threshold = 2 })
    require("nvim-ts-autotag").setup()
    require("nvim-treesitter-textobjects").setup({
      move = { enable = true, set_jumps = true },
    })
  end)

  vim.api.nvim_create_user_command("TSInstallConfigured", function()
    if use() then
      require("nvim-treesitter").install(languages, { summary = true }):wait(300000)
    end
  end, { desc = "Install configured Treesitter parsers" })

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("config_treesitter", { clear = true }),
    callback = function(event)
      if vim.bo[event.buf].buftype ~= "" or event.match == "" then
        return
      end
      if not use() then
        return
      end
      local ok = pcall(vim.treesitter.start, event.buf)
      if ok then
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end,
  })

  local moves = {
    ["]f"] = { "goto_next_start", "@function.outer", "Next function" },
    ["]c"] = { "goto_next_start", "@class.outer", "Next class" },
    ["[f"] = { "goto_previous_start", "@function.outer", "Previous function" },
    ["[c"] = { "goto_previous_start", "@class.outer", "Previous class" },
  }
  for key, move in pairs(moves) do
    vim.keymap.set({ "n", "x", "o" }, key, function()
      if use() then
        require("nvim-treesitter-textobjects.move")[move[1]](move[2], "textobjects")
      end
    end, { desc = move[3] })
  end
end

return M
