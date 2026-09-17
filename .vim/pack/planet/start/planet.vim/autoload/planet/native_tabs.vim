vim9script

var library = ''
var connection: channel
var armed = -1

export def Library(): string
  if exists('g:PV_native_tabs_library') | return g:PV_native_tabs_library | endif
  var root = get(g:, 'PV_root', expand('<script>:p:h:h:h:h:h:h:h:h'))
  var installed = root .. '/lib/planetvim-tabmenu.so'
  return filereadable(installed) ? installed : root .. '/build/native/planetvim-tabmenu.so'
enddef

def Eligible(): bool
  if &guitabtooltip !=# '%{g:GuiTabTooltip()}' || stridx(&guioptions, 'e') < 0
      || getcmdwintype() != '' || pumvisible()
      || !empty(filter(popup_list(), (_, popup) => get(popup_getpos(popup), 'visible', false)))
    return false
  endif
  return index(['n', 'nt', 'ntT', 'niI', 'niR', 'niV', 'i', 'v', 'V', "\<C-V>", 's', 'S', "\<C-S>", 't'], mode(1)) >= 0
enddef

export def Sync()
  if !get(g:, 'PV_native_tabs_active', false) | return | endif
  var value = Eligible() ? 1 : 0
  if value != armed
    try
      libcallnr(library, 'pv_tabs_enable', value)
      armed = value
    catch
      Stop()
      g:PV_native_tabs_status = 'helper unavailable; restart GVim after updating or reinstalling'
    endtry
  endif
enddef

export def Tag(tab: number)
  # Called during GTK redraw, after that page and its label exist. Constant
  # work per rendered tab; never save sessions or inspect buffers here.
  var id = gettabvar(tab, 'PV_tab_id', '')
  try
    libcallnr(library, 'pv_tabs_tag', tab .. ' ' .. (empty(id) ? '0' : id))
  catch
    Stop()
    g:PV_native_tabs_status = 'helper unavailable; restart GVim after updating or reinstalling'
  endtry
enddef

def Receive(ch: channel, message: string)
  if !get(g:, 'PV_native_tabs_active', false) || ch != connection || !Eligible()
      || message !~ '^\d\+ \d\+$'
    return
  endif
  var fields = split(message)
  try
    if libcallnr(library, 'pv_tabs_fresh', str2nr(fields[0])) != 1
        || planet#tab#Find(fields[1]) == 0
      return
    endif
    planet#tab_menu#Show(fields[1])
  catch
    echohl WarningMsg
    echom 'PlanetVim tab menu: ' .. v:exception
    echohl None
  endtry
enddef

def Disconnected(ch: channel)
  if ch == connection && get(g:, 'PV_native_tabs_active', false)
    Stop()
    g:PV_native_tabs_status = 'helper disconnected; use :PlanetNativeTabs on to reconnect'
  endif
enddef

export def Stop()
  g:PV_native_tabs_active = false
  augroup PlanetVimNativeTabs
    autocmd!
  augroup END
  if !empty(library)
    try
      libcallnr(library, 'pv_tabs_stop', 0)
    catch
      # If an uninstall removed the library path, closing the socket below
      # makes its resident capture handler fall back to Vim's stock menu.
    endtry
  endif
  if index(['open', 'buffered'], ch_status(connection)) >= 0 | ch_close(connection) | endif
  armed = -1
  g:PV_native_tabs_status = 'disabled'
enddef

export def Start(): bool
  if get(g:, 'PV_native_tabs_active', false) | return true | endif
  g:PV_native_tabs_status = 'unavailable; run make native-tabs and reinstall'
  if !get(g:, 'PV_native_tabs', true)
    g:PV_native_tabs_status = 'disabled by g:PV_native_tabs'
    return false
  endif
  if !has('gui_running') || !has('gui_gtk3') || !has('libcall') || !has('channel')
      || has('win32') || has('macunix') || !filereadable(Library())
    return false
  endif
  if &guitabtooltip !=# '%{g:GuiTabTooltip()}'
    g:PV_native_tabs_status = 'requires PlanetVim guitabtooltip for stable tab identity'
    return false
  endif
  library = Library()
  try
    if libcallnr(library, 'pv_tabs_abi', 0) != 1 | throw 'incompatible helper ABI' | endif
    var socket_path = tempname()
    var result = libcallnr(library, 'pv_tabs_start', socket_path)
    if result != 1 | throw 'helper initialization failed: ' .. result | endif
    connection = ch_open('unix:' .. socket_path, {mode: 'nl', callback: Receive, close_cb: Disconnected})
    if ch_status(connection) != 'open' | throw 'could not connect to helper' | endif
    planet#tab#Track()
    g:PV_native_tabs_active = true
    g:PV_native_tabs_status = 'enabled'
    augroup PlanetVimNativeTabs
      autocmd!
      autocmd ModeChanged,SafeState,CompleteChanged,CompleteDone,CmdwinEnter,CmdwinLeave * planet#native_tabs#Sync()
      autocmd OptionSet guitabtooltip,guioptions planet#native_tabs#Sync()
      autocmd TabNew,SessionLoadPost * planet#tab#Track()
      autocmd VimLeavePre * planet#native_tabs#Stop()
    augroup END
    Sync()
    redrawtabline
    return true
  catch
    var error = v:exception
    try
      Stop()
    catch
      g:PV_native_tabs_active = false
    endtry
    g:PV_native_tabs_status = error
    return false
  endtry
enddef

export def Configure(action: string = 'status')
  if action ==# 'on'
    g:PV_native_tabs = true
    Start()
  elseif action ==# 'off'
    g:PV_native_tabs = false
    Stop()
  elseif action !=# '' && action !=# 'status'
    throw 'PlanetVim: use PlanetNativeTabs on, off, or status'
  endif
  echo 'PlanetVim native tabs: ' .. get(g:, 'PV_native_tabs_status', 'not initialized')
enddef
