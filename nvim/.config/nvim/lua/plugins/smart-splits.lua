local function navigate(direction)
  local win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. direction)
  if vim.api.nvim_get_current_win() == win and vim.env.ZELLIJ then
    local dir_map = { h = "left", j = "down", k = "up", l = "right" }
    vim.fn.system({ "zellij", "action", "move-focus", dir_map[direction] })
  end
end

vim.keymap.set("n", "<C-h>", function() navigate("h") end, { desc = "Navigate left" })
vim.keymap.set("n", "<C-j>", function() navigate("j") end, { desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", function() navigate("k") end, { desc = "Navigate up" })
vim.keymap.set("n", "<C-l>", function() navigate("l") end, { desc = "Navigate right" })

return {
  { "mrjones2014/smart-splits.nvim", enabled = false },
}
