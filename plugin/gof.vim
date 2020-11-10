" =============================================================================
" Filename: plugin/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/11/11 03:03:36.
" =============================================================================

if exists('g:loaded_gof') || !has('patch-8.1.2080') || !executable('gof')
  finish
endif
let g:loaded_gof = 1

command! -nargs=* Gof call gof#start(<q-args>)

if get(g:, 'gof_mru')
  augroup gof-mru
    autocmd!
    autocmd BufWinEnter,BufWritePost * call gof#mru_opened(expand('<afile>:p'))
  augroup END
endif
