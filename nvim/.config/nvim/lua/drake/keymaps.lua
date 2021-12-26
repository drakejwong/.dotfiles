local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap


----- NORMAL -----

-- remap leader
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- explore
-- keymap("n", "<leader>e", ":Lexplore 30<CR>", opts) -- broke
keymap("n", "<leader>e", ":CHADopen<CR>", opts) -- woke

-- write
keymap("n", "<leader>w", ":write<CR>", opts)

-- exclude paragraph jump from jump list
keymap("n", "}", ':<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>', opts)
keymap("n", "{", ':<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>', opts)

-- tmux nav
keymap("n", "<M-h>", ":TmuxNavigateLeft<cr>", opts)
keymap("n", "<M-j>", ":TmuxNavigateDown<cr>", opts)
keymap("n", "<M-k>", ":TmuxNavigateUp<cr>", opts)
keymap("n", "<M-l>", ":TmuxNavigateRight<cr>", opts)

-- telescope
keymap("n", "<leader>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", opts)
keymap("n", "<leader>fg", "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
keymap("n", "<leader>fc", "<cmd>lua require('telescope.builtin').command_history(require('telescope.themes').get_dropdown())<cr>", opts)
keymap("n", "<leader>fj", "<cmd>lua require('telescope.builtin').jumplist()<cr>", opts)
keymap("n", "<leader>fq", "<cmd>lua require('telescope.builtin').quickfix()<cr>", opts)
keymap("n", "<leader>fl", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", opts)
keymap("n", "<leader>gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", opts)
keymap("n", "<leader>gs", "<cmd>lua require('telescope.builtin').git_status()<cr>", opts)
keymap("n", "<leader>ft", "<cmd>lua require('telescope.builtin').treesitter()<cr>", opts)

----- INSERT -----

-- word backspace
keymap("!", "<M-Backspace>", "<C-w>", opts)


----- VISUAL -----

-- indent group
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==gv", opts)
keymap("v", "<A-k>", ":m .-2<CR>==gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)
keymap("v", "p", '"_dP', opts)
