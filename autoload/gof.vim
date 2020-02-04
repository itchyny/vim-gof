" =============================================================================
" Filename: autoload/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/04 21:21:39.
" =============================================================================

function! gof#start(args) abort
  let command = ['gof', '-tf', 'gof#tapi']
  if a:args ==# 'mru'
    let command = [&shell, &shellcmdflag, 'cat ' .. shellescape(gof#mru_path()) .. ' | gof -tf gof#tapi']
  elseif s:is_git_repo()
    let command = [&shell, &shellcmdflag, 'git ls-files | gof -tf gof#tapi']
  endif
  botright call term_start(
        \ command,
        \ #{ term_rows: max([&lines / 4, 10]), term_finish: 'close', term_api: 'gof#tapi' }
        \ )
endfunction

function! s:is_git_repo() abort
  silent! call system('git rev-parse')
  return v:shell_error == 0
endfunction

function! gof#tapi(bufnr, arg) abort
  call timer_start(50, {->execute('edit ' .. s:expand(a:arg.filename))})
endfunction

function! s:expand(path) abort
  if a:path =~# '^[~]'
    return $HOME .. a:path[1:]
  endif
  return a:path
endfunction

let s:files = []
let s:files_map = {}
function! gof#mru_opened(name) abort
  if !filereadable(a:name)
    return
  endif
  let name = s:unexpand(a:name)
  call filter(s:files, {->v:val !=# name})
  call insert(s:files, name, 0)
  let s:files_map[name] = v:false
endfunction

function! s:unexpand(path) abort
  if stridx(a:path, $HOME) == 0
    return '~' .. a:path[len($HOME):]
  endif
  return a:path
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
