
source $HOME/.config/nvim/keybindings.vim
source $HOME/.config/nvim/sets.vim
source $HOME/.config/nvim/telescope.vim
source $HOME/.config/nvim/vimwiki.vim

" ------- PLUGINS -------
call plug#begin('$HOME/.config/nvim/plugged')

" onedark theme
Plug 'joshdick/onedark.vim'

" git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" lightline
Plug 'itchyny/lightline.vim'

" vimwiki
Plug 'vimwiki/vimwiki'

" css color preview
Plug 'ap/vim-css-color'

" change brackets and stuff fast
Plug 'tpope/vim-surround'

" schmovin
Plug 'justinmk/vim-sneak'
Plug 'vimoxide/vim-quickscope'

" Plug 'nvim-lua/popup.nvim'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim'
" Plug 'vimwiki/vimwiki'

call plug#end()

" set colorscheme
colorscheme onedark

" set status bar colorscheme
let g:lightline = { 'colorscheme': 'one' }
