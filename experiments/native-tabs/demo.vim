vim9script noclear

# Opt-in experiment, sourced after the GUI opens; never part of normal startup.
if !has('gui_running') || !has('gui_gtk3') || !has('libcall') || !has('channel')
  throw 'Native tab experiment requires running GTK3 GVim with libcall and channel'
endif
if get(g:, 'PV_native_tabs_demo_loaded', false)
  finish
endif
const library = get(g:, 'PV_native_tabs_library',
  expand('<script>:p:h:h:h') .. '/build/planetvim-native-tabs.so')
var connection: channel
var pending_window = 0

def Action(action: string)
  var destination = win_id2tabwin(pending_window)[0]
  if destination == 0
    echom 'Clicked tab was closed'
    return
  endif
  if action == 'activate'
    execute 'tabnext ' .. destination
  elseif action == 'path'
    setreg('+', fnamemodify(bufname(winbufnr(pending_window)), ':p'))
  endif
  g:PV_native_tabs_action = {action: action, tab: destination, active: tabpagenr()}
enddef

def Receive(ch: channel, message: string)
  if message !~ '^\d\+ \d\+ \d\+$' | return | endif
  var event = map(split(message), (_, value) => str2nr(value))
  if len(event) != 3 || event[2] != tabpagenr('$') || getcmdwintype() != '' | return | endif
  var target = event[1]
  if target < 1 || target > tabpagenr('$') | return | endif
  # A window ID survives later tab renumbering. This does not yet protect the
  # earlier GTK-to-channel delivery interval; see the experiment's limitations.
  pending_window = win_getid(tabpagewinnr(target), target)
  g:PV_native_tabs_event = {tab: target, active: tabpagenr(), mode: mode(), sequence: event[0]}
  if !empty(menu_info(']PVNativeTab'))
    aunmenu ]PVNativeTab
  endif
  execute 'anoremenu ]PVNativeTab.Tab\ ' .. target .. ' <Nop>'
  execute 'amenu disable ]PVNativeTab.Tab\ ' .. target
  anoremenu ]PVNativeTab.Activate\ Clicked\ Tab <Cmd>call <SID>Action('activate')<CR>
  anoremenu ]PVNativeTab.Copy\ File\ Path <Cmd>call <SID>Action('path')<CR>
  popup! ]PVNativeTab
enddef

def g:PVNativeTabsStop()
  try
    if index(['open', 'buffered'], ch_status(connection)) >= 0
      ch_close(connection)
    endif
  finally
    libcallnr(library, 'pv_tabs_stop', 0)
  endtry
  if !empty(menu_info(']PVNativeTab'))
    aunmenu ]PVNativeTab
  endif
  g:PV_native_tabs_status = 'stopped'
enddef

def g:PVNativeTabsStart()
  g:PVNativeTabsStop()
  var socket_path = tempname()
  var installed = libcallnr(library, 'pv_tabs_start', socket_path)
  if installed != 1 | throw 'GTK helper installation failed: ' .. installed | endif
  try
    connection = ch_open('unix:' .. socket_path, {mode: 'nl', callback: Receive})
    g:PV_native_tabs_status = ch_status(connection)
    if g:PV_native_tabs_status != 'open'
      throw 'Could not connect to the native tab helper'
    endif
  catch
    libcallnr(library, 'pv_tabs_stop', 0)
    throw 'Native tab experiment: ' .. v:exception
  endtry
enddef

g:PVNativeTabsStart()
g:PV_native_tabs_demo_loaded = true
augroup PVNativeTabExperiment
  autocmd!
  autocmd VimLeavePre * g:PVNativeTabsStop()
augroup END
