" =============================================================================
" Filename: autoload/gof.vim
" Author: itchyny
" License: MIT License
" Last Change: 2023/01/31 08:37:47.
" =============================================================================

function! gof#start(args) abort
  if a:args ==# 'mru'
    let input = ' < ' .. (filereadable(gof#mru_path()) ? shellescape(gof#mru_path()) : '<(:)')
  elseif empty(system('git rev-parse'))
    let input = ' < <(git ls-files --deduplicate "$(git rev-parse --show-toplevel)")'
  else
    let input = ''
  endif
  botright call term_start(
        \ [&shell, &shellcmdflag, 'gof -a ctrl-t,ctrl-v -tf gof#tapi' .. input],
        \ #{ term_rows: max([&lines / 4, 10]), term_finish: 'close', term_api: 'gof#tapi' }
        \ )
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
  if name !~# get(g:, 'gof_mru_ignore_pattern', '$^')
    call insert(s:files, name, 0)
  endif
  let s:files_map[name] = v:false
  call gof#mru_debounce_save()
endfunction

function! gof#mru_path() abort
  let data_home = has('win32') && exists('$LOCALAPPDATA') ? $LOCALAPPDATA
        \ : exists('$XDG_DATA_HOME') ? $XDG_DATA_HOME : expand('~/.local/share')
  let dir = data_home .. '/vim-gof'
  call mkdir(dir, 'p', 0700)
  return dir .. '/mru.txt'
endfunction

function! gof#mru_list() abort
  let path = gof#mru_path()
  return filereadable(path) ? readfile(path) : []
endfunction

let s:timer_id = 0
function! gof#mru_debounce_save() abort
  call timer_stop(s:timer_id)
  let s:timer_id = timer_start(3 * 60 * 1000, 'gof#mru_save')
  augroup gof-mru-save
    autocmd!
    autocmd VimLeavePre * call gof#mru_save()
  augroup END
endfunction

function! gof#mru_save(...) abort
  let path = gof#mru_path()
  let tmp = fnamemodify(path, ':r') .. '.' .. rand(srand()) .. '.txt'
  call writefile(
        \ extend(s:files,
        \   filter(gof#mru_list(),
        \     'get(s:files_map, v:val, v:true) &&
        \       (v:key % 10 > 0 || glob(fnamemodify(v:val, ":p")) !=# "" &&
        \        v:val !~# get(g:, "gof_mru_ignore_pattern", "$^"))'
        \   )
        \ )[:99999],
        \ tmp)
  call rename(tmp, path)
  let s:files = []
  let s:files_map = {}
  augroup gof-mru-save
    autocmd!
  augroup END
endfunction
