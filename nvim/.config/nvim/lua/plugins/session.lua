local M = {
  specs = {
    { src = "https://github.com/folke/persistence.nvim" },
  },
}

local use

local function call(method, ...)
  if use and use() then
    return require("persistence")[method](...)
  end
end

--- Restore the session for the current directory.
function M.restore()
  call("load")
end

--- Restore the most recently saved session, regardless of directory.
function M.restore_last()
  call("load", { last = true })
end

--- Pick a session to restore.
function M.select()
  call("select")
end

--- Do not save the session when this Neovim exits.
function M.stop()
  call("stop")
end

function M.setup(pack)
  -- Session files store buffers, windows, and tabs, but not plugin state,
  -- local options, or terminals. Filetypes are re-detected on load.
  vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

  -- Load at startup so the VimLeavePre autocommand that saves the session is registered.
  use = pack.defer("persistence", "persistence.nvim", function()
    require("persistence").setup()
  end)

  local maps = {
    { "<leader>qs", M.restore, "Restore session" },
    { "<leader>qS", M.select, "Select session" },
    { "<leader>ql", M.restore_last, "Restore last session" },
    { "<leader>qd", M.stop, "Don't save current session" },
  }
  for _, mapping in ipairs(maps) do
    vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping[3] })
  end
end

return M
