let mapleader = " "

noremap! <M-Backspace> <C-w>

" macos
" vnoremap <leader>cp :w !pbcopy<CR><CR>
" linux
" vnoremap <leader>cp :w !pbcopy<CR><CR>

nnoremap <silent> <M-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <M-j> :TmuxNavigateDown<cr>
nnoremap <silent> <M-k> :TmuxNavigateUp<cr>
nnoremap <silent> <M-l> :TmuxNavigateRight<cr>

" exclude paragraph jump from jump list
nnoremap <silent> } :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
nnoremap <silent> { :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

" abbreviations
iab <expr> tdt strftime("%Y-%m-%d")

iab onai ## Objectives<CR><CR>## Notes<CR><CR>## Action Items<CR>

let g:clipboard = {
            \   'name': 'myClipboard',
            \   'copy': {
            \      '+': ['tmux', 'load-buffer', '-'],
            \      '*': ['tmux', 'load-buffer', '-'],
            \    },
            \   'paste': {
            \      '+': ['tmux', 'save-buffer', '-'],
            \      '*': ['tmux', 'save-buffer', '-'],
            \   },
            \   'cache_enabled': 0,
            \ }
