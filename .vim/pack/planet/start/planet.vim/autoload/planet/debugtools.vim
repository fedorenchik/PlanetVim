scriptversion 4

let s:last_error = ''
let s:links = {'gdb-dashboard': 'https://github.com/cyrus-and/gdb-dashboard',
      \ 'gdb-unreal': 'https://dev.epicgames.com/documentation/en-us/unreal-engine/linux-development-requirements-for-unreal-engine',
      \ 'gdb-pretty-printers': 'https://sourceware.org/gdb/current/onlinedocs/gdb.html/Pretty-Printing.html',
      \ 'lldb': 'https://lldb.llvm.org/use/tutorial.html', 'rr': 'https://rr-project.org/',
      \ 'live-recorder': 'https://docs.undo.io/', 'radare2': 'https://book.rada.re/',
      \ 'cutter': 'https://cutter.re/', 'gdb-kernel-setup': 'https://docs.kernel.org/process/debugging/gdb-kernel-debugging.html',
      \ 'gdb-kernel': 'https://docs.kernel.org/process/debugging/gdb-kernel-debugging.html',
      \ 'kgdb': 'https://docs.kernel.org/process/debugging/kgdb.html',
      \ 'kdb': 'https://docs.kernel.org/process/debugging/kgdb.html',
      \ 'debugfs': 'https://docs.kernel.org/filesystems/debugfs.html'}

func! planet#debugtools#LastError() abort
  return s:last_error
endfunc

func! planet#debugtools#Value(options, key, prompt, default = '') abort
  let l:value = has_key(a:options, a:key) ? a:options[a:key] : inputdialog(a:prompt, a:default)
  if type(l:value) != v:t_string || empty(l:value) || l:value =~# '[\r\n]'
    throw 'PlanetVim: cancelled or invalid ' .. a:key
  endif
  return l:value
endfunc

func! planet#debugtools#Tool(name, options = {}) abort
  let l:argv = get(a:options, 'tool', get(get(g:, 'PV_debug_tools', {}), a:name, [a:name]))
  if type(l:argv) == v:t_string | let l:argv = [l:argv] | endif
  if type(l:argv) != v:t_list || empty(l:argv)
        \ || !empty(filter(copy(l:argv), 'type(v:val) != v:t_string || v:val =~# "[\\r\\n]"'))
    throw 'PlanetVim: configure ' .. a:name .. ' as a nonempty executable argv list'
  endif
  if !executable(l:argv[0])
    throw 'PlanetVim: install ' .. a:name .. ' and add it to PATH, or set g:PV_debug_tools[' .. string(a:name) .. '] to its executable argv'
  endif
  return copy(l:argv)
endfunc

func! s:GdbQuote(path) abort
  if a:path =~# '[\r\n]' | throw 'PlanetVim: GDB paths cannot contain line breaks' | endif
  return '"' .. escape(fnamemodify(a:path, ':p'), '\"') .. '"'
endfunc

func! s:Profiles() abort
  let l:file = planet#paths#Config('debugtools') .. '/profiles.json'
  return filereadable(l:file) ? json_decode(join(readfile(l:file), "\n")) : {}
endfunc

func! s:Remember(id, options) abort
  let l:profiles = s:Profiles()
  let l:profiles[a:id] = a:options
  call writefile([json_encode(l:profiles)], planet#paths#Config('debugtools') .. '/profiles.json')
endfunc

func! s:KernelSetup(options, root) abort
  let l:vmlinux = planet#debugtools#Value(a:options, 'vmlinux', 'Kernel vmlinux with debug symbols:', a:root .. '/vmlinux')
  if !filereadable(l:vmlinux) | throw 'PlanetVim: build a kernel with debug symbols first; vmlinux is missing' | endif
  let l:helper = planet#debugtools#Value(a:options, 'helper', 'Kernel GDB helper:', a:root .. '/vmlinux-gdb.py')
  if !filereadable(l:helper) | throw 'PlanetVim: enable CONFIG_GDB_SCRIPTS and build the kernel GDB scripts first' | endif
  let l:file = planet#paths#Config('debugtools') .. '/kernel-' .. sha256(a:root)[:15] .. '.gdb'
  call writefile(['file ' .. s:GdbQuote(l:vmlinux), 'source ' .. s:GdbQuote(l:helper)], l:file)
  call s:Remember('gdb-kernel', {'init': l:file, 'vmlinux': l:vmlinux, 'cwd': a:root})
  execute 'edit ' .. fnameescape(l:file)
  echom 'PlanetVim: kernel symbols configured. Use gdb kernel or kgdb and enter the target endpoint to connect.'
  return l:file
endfunc

func! planet#debugtools#Run(id, options = {}) abort
  let s:last_error = ''
  try
    if !has_key(s:links, a:id) | throw 'PlanetVim: unknown debug tool ' .. a:id | endif
    let l:options = extend(get(s:Profiles(), a:id, {}), a:options, 'force')
    let l:root = get(l:options, 'cwd', planet#run#Project().root)
    if !isdirectory(l:root) | throw 'PlanetVim: working directory does not exist' | endif
    if a:id ==# 'gdb-kernel-setup'
      return s:KernelSetup(l:options, l:root)
    elseif a:id ==# 'debugfs'
      let l:path = planet#debugtools#Value(l:options, 'path', 'Mounted debugfs directory:', '/sys/kernel/debug')
      if !isdirectory(l:path) | throw 'PlanetVim: debugfs is not mounted or not accessible at ' .. l:path | endif
      if exists(':Fern') == 2
        tabnew
        execute 'Fern ' .. fnameescape(l:path)
      else
        execute 'tabedit ' .. fnameescape(l:path)
      endif
      return 1
    elseif index(['gdb-dashboard', 'gdb-unreal', 'gdb-pretty-printers'], a:id) >= 0
      let l:path = planet#debugtools#Value(l:options, 'init', 'Select the installed ' .. a:id .. ' GDB/Python script:')
      if !filereadable(l:path) | throw 'PlanetVim: the selected GDB extension script does not exist' | endif
      let l:argv = planet#debugtools#Tool('gdb', l:options) + ['--quiet', '--nx', '-x', fnamemodify(l:path, ':p')]
      let l:options.init = fnamemodify(l:path, ':p')
    elseif index(['gdb-kernel', 'kgdb'], a:id) >= 0
      let l:vmlinux = planet#debugtools#Value(l:options, 'vmlinux', 'Kernel vmlinux with debug symbols:', l:root .. '/vmlinux')
      if !filereadable(l:vmlinux) | throw 'PlanetVim: vmlinux is missing; use Setup GDB for Kernel first' | endif
      let l:target = planet#debugtools#Value(l:options, 'target', 'GDB remote endpoint (host:port or serial device):', ':1234')
      if l:target !~# '^[-a-zA-Z0-9_./:\[\]]\+$' | throw 'PlanetVim: invalid GDB remote endpoint' | endif
      let l:argv = planet#debugtools#Tool('gdb', l:options) + ['--quiet', '--nx', l:vmlinux]
      if has_key(l:options, 'init') && filereadable(l:options.init)
        let l:argv += ['-x', l:options.init]
      endif
      let l:argv += ['-ex', 'target remote ' .. l:target]
    elseif a:id ==# 'kdb'
      let l:device = planet#debugtools#Value(l:options, 'device', 'Serial device for the configured KDB console:', '/dev/ttyUSB0')
      let l:baud = planet#debugtools#Value(l:options, 'baud', 'Serial baud rate:', '115200')
      if l:baud !~# '^\d\+$' | throw 'PlanetVim: baud rate must be numeric' | endif
      let l:argv = has('win32') ? planet#debugtools#Tool('plink', l:options) + ['-serial', l:device, '-sercfg', l:baud]
            \ : planet#debugtools#Tool('picocom', l:options) + ['--baud', l:baud, l:device]
    else
      let l:tool = {'lldb': 'lldb', 'rr': 'rr', 'live-recorder': 'live-record', 'radare2': 'r2', 'cutter': 'cutter'}[a:id]
      let l:program = planet#debugtools#Value(l:options, 'program', 'Program to open with ' .. l:tool .. ':')
      if !filereadable(l:program) | throw 'PlanetVim: selected program does not exist' | endif
      let l:argv = planet#debugtools#Tool(l:tool, l:options)
      if a:id ==# 'rr' | let l:argv += ['record'] | endif
      let l:argv += [fnamemodify(l:program, ':p')]
      let l:options.program = fnamemodify(l:program, ':p')
    endif
    let l:arguments = get(l:options, 'args', [])
    if type(l:arguments) != v:t_list || !empty(filter(copy(l:arguments), 'type(v:val) != v:t_string'))
      throw 'PlanetVim: debug program args must be an argv list'
    endif
    call s:Remember(a:id, l:options)
    return a:id ==# 'cutter' ? planet#term#RunGuiApp(l:argv + l:arguments, l:root)
          \ : planet#term#RunArgv(l:argv + l:arguments, v:false, v:false, v:false, l:root)
  catch
    let s:last_error = v:exception
    echom s:last_error
    if has_key(s:links, a:id) | echom 'Setup guide: ' .. s:links[a:id] | endif
    return 0
  endtry
endfunc
