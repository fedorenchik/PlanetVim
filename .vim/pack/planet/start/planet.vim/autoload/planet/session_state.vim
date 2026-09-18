vim9script

# Native persistence follows the session owner; preferences and the MRU index do
# not. Capture exact global options so leaving a session restores user overrides.
var global_options: dict<string> = {}
var directory = ''

def Options(): dict<string>
  return {directory: &directory, backupdir: &backupdir, undodir: &undodir,
    viewdir: &viewdir, viminfofile: &viminfofile}
enddef

def Apply(options: dict<string>)
  &directory = options.directory
  &backupdir = options.backupdir
  &undodir = options.undodir
  &viewdir = options.viewdir
  &viminfofile = options.viminfofile
enddef

export def Flush()
  if &viminfofile !=# 'NONE' && !empty(&viminfo)
    wviminfo
  endif
enddef

export def Prepare(file: string)
  var base = fnamemodify(file, ':p:h')
  for child in ['undo', 'swap', 'backup', 'views']
    mkdir(base .. '/' .. child, 'p', 0o700)
  endfor
enddef

def ClearMemory()
  planet#session_lists#Clear()
  for history in ['cmd', 'search', 'expr', 'input', 'debug']
    histdel(history)
  endfor
  for register in split('0123456789abcdefghijklmnopqrstuvwxyz/-"', '\zs')
    setreg(register, '')
  endfor
  delmarks A-Z0-9
  for window in getwininfo()
    win_execute(window.winid, 'clearjumps')
  endfor
  v:oldfiles = []
enddef

def ReadInfo()
  if &viminfofile ==# 'NONE' || !filereadable(&viminfofile) || empty(&viminfo)
    return
  endif
  var original = &viminfo
  try
    # The session snapshot owns the buffer list, not viminfo's optional % list.
    &viminfo = join(filter(split(&viminfo, ','), (_, entry) => entry !~# '^%'), ',')
    rviminfo!
  finally
    &viminfo = original
  endtry
enddef

def RebindBuffers(preserve: bool)
  var current = bufnr()
  var view = winsaveview()
  var fixed = getwinvar(0, '&winfixbuf', false)
  try
    if fixed
      set nowinfixbuf
    endif
    for buffer in getbufinfo({'bufloaded': 1})
      if getbufvar(buffer.bufnr, '&buftype') !=# '' || empty(buffer.name)
        continue
      endif
      if getbufvar(buffer.bufnr, '&swapfile')
        # Changing 'directory' alone does not relocate existing swap files.
        setbufvar(buffer.bufnr, '&swapfile', false)
        setbufvar(buffer.bufnr, '&swapfile', true)
      endif
      if preserve && getbufvar(buffer.bufnr, '&undofile')
        execute 'noautocmd keepalt keepjumps hide buffer ' .. buffer.bufnr
        execute 'silent wundo! ' .. fnameescape(undofile(buffer.name))
      endif
    endfor
  finally
    if bufexists(current)
      execute 'noautocmd keepalt keepjumps hide buffer ' .. current
      winrestview(view)
    endif
    if fixed
      set winfixbuf
    endif
  endtry
enddef

# Call Flush before replacing buffers. Startup runs before Vim reads viminfo;
# Save As retains current registers, history and undo as an independent copy.
export def Use(file: string, preserve: bool = false, startup: bool = false, reload: bool = false)
  if empty(global_options)
    global_options = Options()
  endif
  var next = empty(file) ? '' : fnamemodify(file, ':p:h')
  var options = copy(global_options)
  if !empty(next)
    Prepare(file)
    options = {directory: escape(next .. '/swap', ',') .. '//',
      backupdir: escape(next .. '/backup', ',') .. '//',
      undodir: escape(next .. '/undo', ',') .. '//',
      viewdir: next .. '/views', viminfofile: next .. '/viminfo'}
  endif
  if next ==# directory && !reload
    Apply(options)
    return
  endif
  if !startup
    planet#tab#Cleanup()
    if !preserve
      ClearMemory()
    endif
  endif
  directory = next
  g:PV_session_state_dir = directory
  Apply(options)
  if !startup
    RebindBuffers(preserve)
    if preserve
      if &viminfofile !=# 'NONE' && !empty(&viminfo)
        wviminfo!
      endif
    else
      ReadInfo()
    endif
  endif
enddef
