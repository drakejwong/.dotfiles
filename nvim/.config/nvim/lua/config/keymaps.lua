local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" })

local directions = {
  h = { wincmd = "h", name = "left" },
  j = { wincmd = "j", name = "down" },
  k = { wincmd = "k", name = "up" },
  l = { wincmd = "l", name = "right" },
}

for key, direction in pairs(directions) do
  map("n", "<C-" .. key .. ">", function()
    vim.cmd.wincmd(direction.wincmd)
  end, { desc = "Focus " .. direction.name })
end

map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

map("n", "<leader>w", "<cmd>noautocmd write<cr>", { desc = "Write without autocommands" })
map("n", "<leader>x", "<cmd>noautocmd xit<cr>", { desc = "Write and quit without autocommands" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
map({ "i", "n", "s", "x" }, "<C-s>", "<cmd>write<cr><esc>", { desc = "Save" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
map("n", "<leader>qq", "<cmd>quitall<cr>", { desc = "Quit all" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>buffer #<cr>", { desc = "Other buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

map("x", "<", "<gv")
map("x", ">", ">gv")
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Previous search result" })

map("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "<leader>xq", function()
  local open = vim.fn.getqflist({ winid = 0 }).winid ~= 0
  vim.cmd(open and "cclose" or "copen")
end, { desc = "Quickfix list" })

local function diagnostic_jump(count, severity)
  return function()
    vim.diagnostic.jump({ count = count * vim.v.count1, severity = severity, float = true })
  end
end

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", diagnostic_jump(1), { desc = "Next diagnostic" })
map("n", "[d", diagnostic_jump(-1), { desc = "Previous diagnostic" })
map("n", "]e", diagnostic_jump(1, vim.diagnostic.severity.ERROR), { desc = "Next error" })
map("n", "[e", diagnostic_jump(-1, vim.diagnostic.severity.ERROR), { desc = "Previous error" })

-- Emacs-style insert-mode movement and editing.
map("i", "<C-a>", "<Home>")
map("i", "<C-b>", "<Left>")
map("i", "<C-e>", "<End>")
map("i", "<C-f>", "<Right>")
map("i", "<M-b>", "<Esc>bi")
map("i", "<M-f>", "<Esc>lwi")
map("i", "<M-S-b>", "<Esc>Bi")
map("i", "<M-S-f>", "<Esc>lWi")
map("i", "<M-x>", "<Esc>:")
map("i", "<C-k>", "<Esc>lDa")
map("i", "<C-u>", "<Esc>d0xi")
map("i", "<C-y>", "<Esc>Pa")
map("i", "<C-x><C-s>", "<Esc>:write<cr>a")
