" =============================================================================
" Filename: plugin/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/04 00:58:34.
" =============================================================================

if exists('g:loaded_gof') || !has('patch-8.2.0191')
  finish
endif
let g:loaded_gof = 1

command! -nargs=* Gof call gof#start(<q-args>)

if get(g:, 'gof_mru')
  augroup gof-mru
    autocmd!
    autocmd BufWinEnter,BufWritePost * call gof#mru_opened(expand('<afile>:p'))
    autocmd VimLeavePre * call gof#mru_save()
  augroup END
endif
