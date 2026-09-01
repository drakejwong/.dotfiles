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
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Previous hunk")
        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last hunk")
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview hunk inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>ghB", gs.blame, "Blame buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff file")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff file against previous commit")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
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
