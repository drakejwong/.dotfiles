vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true
vim.g.loaded_fzf = 1

-- This configuration does not use legacy remote-plugin providers.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.filetype.add({
  extension = { mdx = "mdx" },
  filename = {
    ["buf.yaml"] = "buf-config",
    ["buf.gen.yaml"] = "buf-config",
    ["buf.policy.yaml"] = "buf-config",
    ["buf.lock"] = "buf-config",
  },
})
vim.treesitter.language.register("markdown", "mdx")
vim.treesitter.language.register("yaml", "buf-config")

local opt = vim.opt

opt.autowrite = false
opt.clipboard = "unnamedplus"
local has_local_clipboard = vim.fn.has("mac") == 1
  or vim.fn.executable("wl-copy") == 1
  or vim.fn.executable("xclip") == 1
  or vim.fn.executable("xsel") == 1
vim.g.osc52_clipboard = (vim.env.SSH_CONNECTION ~= nil) or not has_local_clipboard
if vim.g.osc52_clipboard then
  -- Over SSH, or on a box with no clipboard tool, copy through OSC 52 so the
  -- local terminal (Ghostty, also inside Herdr) receives yanks. Paste returns
  -- the last copied text: most terminals block or prompt on OSC 52 reads.
  local osc52 = require("vim.ui.clipboard.osc52")
  local cache = {}
  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      cache[reg] = { lines, regtype }
      send(lines, regtype)
    end
  end
  local function paste(reg)
    return function()
      return cache[reg] or { {}, "v" }
    end
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  }
end
opt.completeopt = { "menu", "menuone", "noselect" }
opt.conceallevel = 2
opt.confirm = true
opt.cursorline = true
opt.expandtab = true
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = "v:lua.vim.treesitter.foldtext()"
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep --smart-case"
opt.ignorecase = true
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.laststatus = 3
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.modeline = false
opt.mouse = "a"
opt.number = true
opt.pumblend = 10
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 4
opt.shiftround = true
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.smoothscroll = true
opt.spelllang = { "en" }
opt.splitbelow = true
opt.splitkeep = "screen"
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.wrap = false

vim.g.markdown_recommended_style = 0
