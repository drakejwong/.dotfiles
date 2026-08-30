local M = {
  specs = {
    { src = "https://github.com/ibhagwan/fzf-lua" },
  },
}

local use

local function run(method, opts)
  if use and use() then
    require("fzf-lua")[method](opts or {})
  end
end

M.run = run

function M.files(opts) run("files", opts) end
function M.grep(opts) run("live_grep", opts) end
function M.oldfiles(opts) run("oldfiles", opts) end

function M.setup(pack)
  use = pack.use("fzf", { "mini.nvim", "fzf-lua" }, function()
    require("fzf-lua").setup({
      "fzf-native",
      fzf_opts = { ["--layout"] = "reverse-list" },
      winopts = { preview = { layout = "vertical" } },
    })
  end)

  local root = require("config.root")
  local maps = {
    { "<leader><space>", "files", function() return { cwd = root.get() } end, "Find files" },
    { "<leader>ff", "files", function() return { cwd = root.get() } end, "Find files (root)" },
    { "<leader>fF", "files", nil, "Find files (cwd)" },
    { "<leader>fg", "git_files", nil, "Git files" },
    { "<leader>fr", "oldfiles", nil, "Recent files" },
    { "<leader>/", "live_grep", function() return { cwd = root.get() } end, "Grep" },
    { "<leader>sg", "live_grep", function() return { cwd = root.get() } end, "Grep (root)" },
    { "<leader>sG", "live_grep", nil, "Grep (cwd)" },
    { "<leader>sb", "lines", nil, "Buffer lines" },
    { "<leader>sB", "grep_curbuf", nil, "Grep buffer" },
    { "<leader>sh", "helptags", nil, "Help" },
    { "<leader>sk", "keymaps", nil, "Keymaps" },
    { "<leader>sd", "diagnostics_document", nil, "Buffer diagnostics" },
    { "<leader>sD", "diagnostics_workspace", nil, "Workspace diagnostics" },
    { "<leader>sq", "quickfix", nil, "Quickfix" },
    { "<leader>,", "buffers", nil, "Buffers" },
  }
  for _, mapping in ipairs(maps) do
    local lhs, method, opts, desc = unpack(mapping)
    vim.keymap.set("n", lhs, function()
      if use() then require("fzf-lua")[method](opts and opts() or {}) end
    end, { desc = desc })
  end
end

return M
