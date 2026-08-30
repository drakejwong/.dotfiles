local M = {}

function M.get(buf)
  buf = buf or 0
  local path = vim.api.nvim_buf_get_name(buf)
  path = path ~= "" and path or vim.uv.cwd()
  return vim.fs.root(path, { ".jj", ".git", "package.json", "go.mod", "Cargo.toml", "pyproject.toml" })
    or vim.uv.cwd()
end

return M
