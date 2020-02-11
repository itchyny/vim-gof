" =============================================================================
" Filename: autoload/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2020/02/11 22:09:29.
" =============================================================================

function! gof#start(args) abort
  let command = ['gof', '-a', 'ctrl-t,ctrl-v', '-tf', 'gof#tapi']
  if a:args ==# 'mru'
    if filereadable(gof#mru_path())
      let command = [&shell, &shellcmdflag, 'cat ' .. shellescape(gof#mru_path()) .. ' | ' .. join(command, ' ')]
    else
      let command = [&shell, &shellcmdflag, 'true | ' .. join(command, ' ')]
    endif
  elseif s:is_git_repo()
    let command = [&shell, &shellcmdflag, 'git ls-files ' .. s:get_git_root() .. ' | ' .. join(command, ' ')]
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

function! s:get_git_root() abort
  let path = expand('%:p:h')
  let prev = ''
  while path !=# prev
    if !empty(getftype(path .. '/.git'))
      return path
    endif
    let prev = path
    let path = fnamemodify(path, ':h')
  endwhile
  return ''
endfunction

function! gof#tapi(bufnr, arg) abort
  let command = get({ 'ctrl-t': 'tabnew', 'ctrl-v': 'vnew' }, a:arg.action_key, 'edit')
  call timer_start(50, {->execute(command .. ' ' .. fnamemodify(a:arg.filename, ':p'))})
endfunction

let s:files = []
let s:files_map = {}
function! gof#mru_opened(name) abort
  if !empty(&buftype) || !filereadable(a:name)
    return
  endif
  let name = fnamemodify(a:name, ':~')
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
  if empty(s:files)
    return
  endif
  let path = gof#mru_path()
  let tmp = fnamemodify(path, ':r') .. '.' .. rand(srand()) .. '.txt'
  call writefile(
        \ extend(s:files,
        \   filter(gof#mru_list(),
        \     'get(s:files_map, v:val, v:true) &&
        \       (v:key % 10 > 0 || filereadable(fnamemodify(v:val, ":p")))'
        \   )
        \ )[:99999],
        \ tmp)
  call rename(tmp, path)
endfunction
