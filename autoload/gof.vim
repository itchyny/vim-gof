" =============================================================================
" Filename: autoload/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/03 22:37:13.
" =============================================================================

function! gof#start() abort
  let [w, h] = [80, min([25, &lines - 5])]
  let bufnr = term_start(
        \ ['gof', '-tf', 'gof#tapi'],
        \ #{ hidden: 1, term_rows: h, term_cols: w, term_finish: 'close' }
        \ )
  call term_setapi(bufnr, 'gof#tapi')
  let winid = popup_create(
        \ bufnr,
        \ #{ maxwidth: w, maxheight: h, minwidth: w, minheight: h }
        \ )
endfunction

function! gof#tapi(bufnr, arg) abort
  call timer_start(50, {->execute('edit ' . a:arg.fullpath)})
endfunction
