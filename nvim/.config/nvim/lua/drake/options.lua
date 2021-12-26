local options = {
    -- numbaz
    number = true,
    relativenumber = true,

    -- line length warning
    colorcolumn = "80",

    -- highlight current row
    cursorline = true,

    -- column width
    numberwidth = 4,
    signcolumn = "yes", -- overlay signcol into line numbers

    -- better colors
    termguicolors = true,

    -- indentation
    tabstop = 4,
    softtabstop = 4,
    expandtab = true,
    shiftwidth = 4,
    smartindent = true,

    -- text search
    ignorecase = true,
    smartcase = true,
    incsearch = true,

    -- intuititive splits
    splitbelow = true,
    splitright = true,

    -- nav buffers without losing unsaved work
    hidden = true,

    -- edge scrolling
    scrolloff = 8,
    wrap = false,
    sidescrolloff = 8,

    -- swap, backup, undo
    swapfile = false,
    writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    backup = true,
    backupdir = vim.fn.stdpath "data" .. "/backup//", -- // means dir info is saved in filename
    undofile = true,
    undodir = vim.fn.stdpath "data" .. "/undo//",
 
    -- mouse mode
    mouse = "a",

    -- per-project config
    exrc = true,

    -- system clipboard (doesn't seem to work over ssh/tmux)
    clipboard = "unnamedplus",

    -- more room to show cmd messages
    cmdheight = 2,

    -- cmp stuff
    -- completeopt = { "menuone", "noselect" },

    -- show formatters like `` in markdown
    conceallevel = 0,

    -- default file encoding
    fileencoding = "utf-8",

    -- pop-up menu height
    pumheight = 10,

    -- refresh rate for completion, gitgutter, etc.
    updatetime = 250,
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- spellcheck
vim.api.nvim_exec([[ autocmd BufRead,BufNewFile *.md setlocal spell ]], false)
vim.api.nvim_exec([[ autocmd FileType gitcommit setlocal spell ]], false)


----- window-level options ------


----- buffer-level options ------
