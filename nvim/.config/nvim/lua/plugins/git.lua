local M = {
  specs = {
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/sindrets/diffview.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
  },
}

function M.setup(pack)
  pack.event("gitsigns", "gitsigns.nvim", { "BufReadPre", "BufNewFile" }, function()
    require("gitsigns").setup({
      current_line_blame = false,
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc, opts)
          vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, desc = desc }, opts or {}))
        end
        map("n", "]h", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, "Next hunk", { expr = true })
        map("n", "[h", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, "Previous hunk", { expr = true })
        map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>ghb", gs.blame_line, "Blame line")
        map("n", "<leader>ghd", gs.diffthis, "Diff file")
      end,
    })
  end, {
    condition = function(event)
      return vim.bo[event.buf].buftype == "" and vim.api.nvim_buf_get_name(event.buf) ~= ""
    end,
  })

  local use_diffview = pack.use("diffview", { "plenary.nvim", "diffview.nvim" })
  vim.keymap.set("n", "<leader>gd", function()
    if use_diffview() then vim.cmd.DiffviewOpen() end
  end, { desc = "Diff view" })
  vim.keymap.set("n", "<leader>gD", function()
    if use_diffview() then vim.cmd.DiffviewOpen("origin/HEAD...") end
  end, { desc = "Diff against origin" })
  vim.keymap.set("n", "<leader>gh", function()
    if use_diffview() then vim.cmd.DiffviewFileHistory("%") end
  end, { desc = "File history" })
  vim.keymap.set("n", "<leader>gH", function()
    if use_diffview() then vim.cmd.DiffviewFileHistory() end
  end, { desc = "Repository history" })
end

return M
