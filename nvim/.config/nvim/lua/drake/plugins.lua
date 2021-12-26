----- PACKER INIT -----
local fn = vim.fn

-- autoinstall packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  vim.notify("Installing packer close and reopen Neovim...")
  vim.cmd [[packadd packer.nvim]]
end

-- reload upon writing to plugins.lua
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- pcall to prevent error on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  vim.notify("require packer failed! expected for initial bootstrap!")
  return
end

-- packer use popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

----- PLUGINS -----
return packer.startup(function(use)
  -- packerception
  use "wbthomason/packer.nvim"

  -- theme
  use "monsonjeremy/onedark.nvim"
  use {
    "nvim-lualine/lualine.nvim",
    requires = {"kyazdani42/nvim-web-devicons", opt = true}
  }

  -- git
  use "airblade/vim-gitgutter"
  use "tpope/vim-fugitive"
  use "tpope/vim-rhubarb"

  -- file explorer
  use {
    "ms-jpq/chadtree",
    branch = "chad",
    run = ":CHADdeps"
  }
  -- required by lots of stuff
  use "nvim-lua/popup.nvim"
  use "nvim-lua/plenary.nvim"

  -- telescope
  use "nvim-telescope/telescope.nvim"
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make"
  }

  -- vimwiki
  use "vimwiki/vimwiki"

  -- css color pre
  use "ap/vim-css-color"

  -- surroundings niceties
  use "jiangmiao/auto-pairs"
  use "rstacruz/vim-closer"
  use "tpope/vim-endwise"
  use "tpope/vim-surround"

  -- comments
  use "tpope/vim-commentary"

  -- schmoovin
  use "justinmk/vim-sneak"
  use "vimoxide/vim-quickscope"

  -- tmux pane nav
  use "christoomey/vim-tmux-navigator"

  -- cmp
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-cmdline"
  use "saadparwaiz1/cmp_luasnip"
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-nvim-lua"

  -- snippets
  use "L3MON4D3/LuaSnip"
  use "rafamadriz/friendly-snippets"
  -- use "SirVer/ultisnips"
  -- use "quangnguyen30192/cmp-nvim-ultisnips"
  -- use "honza/vim-snippets"

  -- LSP
  use "neovim/nvim-lspconfig"
  use {
    "williamboman/nvim-lsp-installer",
    run = ":LspInstall --sync pyright tsserver html cssls jsonls sumneko_lua graphql sqlls"
  }

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate"
  }

  ------------------------------------------
  -- keep under all plugins for bootstrap --
  ------------------------------------------
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
