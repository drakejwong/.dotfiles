-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd([[
  let g:clipboard = {
  \ 'name': 'WSLClipboard',
  \ 'copy': {
  \   '+': 'wl-copy',
  \   '*': 'wl-copy',
  \ },
  \ 'paste': {
  \   '+': 'wl-paste --no-newline',
  \   '*': 'wl-paste --no-newline',
  \ },
  \ 'cache_enabled': 0
  \ }
]])
