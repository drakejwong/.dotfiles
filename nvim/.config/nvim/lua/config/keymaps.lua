-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

map("n", "<leader>w", "<cmd>w<CR>")
map("n", "<leader>h", "<cmd>noh<CR>")

-- Emacs keybindings in insert mode
map("i", "<C-a>", "<Home>")
map("i", "<C-b>", "<Left>")
map("i", "<C-e>", "<End>")
map("i", "<C-f>", "<Right>")
map("i", "â", "<C-Left>") -- â is <Alt-B>
map("i", "æ", "<C-Right>") -- æ is <Alt-F>
map("i", "<A-x>", "<Esc>:")
map("i", "<A-f>", "<Esc>lwi")
map("i", "<A-b>", "<Esc>bi")
map("i", "<A-S-f>", "<Esc>lWi")
map("i", "<A-S-b>", "<Esc>Bi")
map("i", "<C-K>", "<Esc>lDa")
map("i", "<C-U>", "<Esc>d0xi")
map("i", "<C-Y>", "<Esc>Pa")
map("i", "<C-X><C-S>", "<Esc>:w<CR>a")