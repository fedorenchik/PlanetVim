scriptversion 4
let s:root = expand("<sfile>:p:h:h:h:h:h:h:h:h")

func! s:Directory(kind, name) abort
  let l:key = 'PV_' .. a:kind .. '_dir'
  if !has_key(g:, l:key)
    let l:override = getenv('PLANETVIM_' .. toupper(a:kind) .. '_DIR')
    if l:override isnot v:null && !empty(l:override)
      let g:[l:key] = l:override
    elseif has('win32')
      let l:base = empty($LOCALAPPDATA) ? expand('~/AppData/Local') : $LOCALAPPDATA
      let g:[l:key] = l:base .. '/PlanetVim/' .. a:kind
    else
      let l:xdg = {'config': ['XDG_CONFIG_HOME', '~/.config'],
            \ 'state': ['XDG_STATE_HOME', '~/.local/state'],
            \ 'cache': ['XDG_CACHE_HOME', '~/.cache']}[a:kind]
      let l:base = getenv(l:xdg[0])
      let g:[l:key] = (l:base is v:null || empty(l:base) ? expand(l:xdg[1]) : l:base) .. '/planetvim'
    endif
  endif
  let l:path = substitute(fnamemodify(g:[l:key], ':p'), '[/\\]\+$', '', '') .. (empty(a:name) ? '' : '/' .. a:name)
  if !isdirectory(l:path)
    call mkdir(l:path, 'p', 0o700)
  endif
  return substitute(l:path, '[/\\]\+$', '', '')
endfunc

func! planet#paths#Config(name = '') abort
  return s:Directory('config', a:name)
endfunc

func! planet#paths#State(name = '') abort
  return s:Directory('state', a:name)
endfunc

func! planet#paths#Cache(name = '') abort
  return s:Directory('cache', a:name)
endfunc

func! planet#paths#Root() abort
  return get(g:, 'PV_root', s:root)
endfunc
