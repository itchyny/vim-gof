" =============================================================================
" Filename: plugin/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/03 22:22:04.
" =============================================================================

if exists('g:loaded_gof') || !has('patch-8.2.0191')
  finish
endif
let g:loaded_gof = 1

command! Gof call gof#start()
