" enable syntax highlighting
syntax on

" fancy line numbers
set nu rnu

" line length warning
set colorcolumn=80

" overlay signcol into line numbers
set signcolumn=yes

" better colors
set termguicolors

" indentation
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4 " spaces used per autoindent
set smartindent

" search
set ignorecase smartcase
set incsearch

" splits
set splitbelow
set splitright

" navigate buffers without losing unsaved work
set hidden

" edge scrolling
set scrolloff=8

" no swapfiles
set noswapfile

" better backup dir
set backupdir=/tmp// " // means dir info is saved in filename
set backup

" better undo dir
" TODO: mbbill/undotree
set undodir=/tmp//
set undofile

" mouse mode
set mouse=a

" allow per-project nvim config
set exrc
