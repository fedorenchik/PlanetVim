vim9script
var script_root = expand("<sfile>:p:h:h:h:h:h:h:h:h")

def LocalDirectory(kind: string, name: string): string
  var override: any
  var base: any
  var xdg: any
  var key: any = 'PV_' .. kind .. '_dir'
  if !has_key(g:, key)
    override = getenv('PLANETVIM_' .. toupper(kind) .. '_DIR')
    if override != null && !empty(override)
      g:[key] = override
    elseif has('win32')
      base = empty($LOCALAPPDATA) ? expand('~/AppData/Local') : $LOCALAPPDATA
      g:[key] = base .. '/PlanetVim/' .. kind
    else
      xdg = {'config': ['XDG_CONFIG_HOME', '~/.config'], 'state': ['XDG_STATE_HOME', '~/.local/state'], 'cache': ['XDG_CACHE_HOME', '~/.cache']}[kind]
      base = getenv(xdg[0])
      g:[key] = (base == null || empty(base) ? expand(xdg[1]) :  base) .. '/planetvim'
    endif
  endif
  var path: any = substitute(fnamemodify(g:[key], ':p'), '[/\\]\+$', '', '') .. (empty(name) ? '' : '/' .. name)
  if !isdirectory(path)
    mkdir(path, 'p', 0o700)
  endif
  return substitute(path, '[/\\]\+$', '', '')
enddef

export def Config(name: string = ''): string
  return LocalDirectory('config', name)
enddef

export def State(name: string = ''): string
  return LocalDirectory('state', name)
enddef

export def Cache(name: string = ''): string
  return LocalDirectory('cache', name)
enddef

export def Root(): string
  return get(g:, 'PV_root', script_root)
enddef

# Escape one entry for runtimepath/packpath/globpath, not for native file APIs.
# Apostrophes invoke shell expansion on Unix. On Windows a backslash before an
# apostrophe becomes a path separator after settings adds 39 to 'isfname'.
export def Runtime(path: string): string
  return escape(path, has('win32') ? ',' : ",'")
enddef
