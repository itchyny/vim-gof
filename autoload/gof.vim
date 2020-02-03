" =============================================================================
" Filename: autoload/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/04 01:40:01.
" =============================================================================

function! gof#start(args) abort
  let command = ['gof', '-tf', 'gof#tapi']
  if a:args ==# 'mru'
    let command = [&shell, &shellcmdflag, 'cat ' .. shellescape(gof#mru_path()) .. ' | gof -tf gof#tapi']
  endif
  let [w, h] = [80, min([25, &lines - 5])]
  let bufnr = term_start(
        \ command,
        \ #{ hidden: 1, term_rows: h, term_cols: w, term_finish: 'close' }
        \ )
  call term_setapi(bufnr, 'gof#tapi')
  call popup_create(
        \ bufnr,
        \ #{ maxwidth: w, maxheight: h, minwidth: w, minheight: h }
        \ )
endfunction

function! gof#tapi(bufnr, arg) abort
  call timer_start(50, {->execute('edit ' .. expand(a:arg.filename))})
endfunction

let s:files = []
let s:files_map = {}
function! gof#mru_opened(name) abort
  if !filereadable(a:name)
    return
  endif
  let name = a:name
  let home = $HOME
  if len(name) > len(home) && name[:len(home)-1] == home
    let name = '~' .. name[len(home):]
  endif
  call filter(s:files, {->v:val !=# name})
  call insert(s:files, name, 0)
  let s:files_map[name] = v:false
endfunction

function! gof#mru_path() abort
  let cache_home = exists('$XDG_CACHE_HOME') ? $XDG_CACHE_HOME : $HOME .. '/.cache'
  let dir = cache_home .. '/vim-gof'
  call mkdir(dir, 'p', 0700)
  return dir .. '/mru.txt'
endfunction

function! gof#mru_list() abort
  let path = gof#mru_path()
  return filereadable(path) ? readfile(path) : []
endfunction

function! gof#mru_save() abort
  eval s:files->extend(
        \   gof#mru_list()->filter('get(s:files_map, v:val, v:true)')
        \ )[:99999]->writefile(gof#mru_path())
endfunction
