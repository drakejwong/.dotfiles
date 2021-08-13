source $HOME/.config/nvim/keybindings.vim
source $HOME/.config/nvim/sets.vim
source $HOME/.config/nvim/telescope.vim
source $HOME/.config/nvim/vimwiki.vim

" Plugins will be downloaded udner the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Declare the list of plugins.
Plug 'tpope/vim-sensible'
Plug 'junegunn/seoul256.vim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'vimwiki/vimwiki'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()
