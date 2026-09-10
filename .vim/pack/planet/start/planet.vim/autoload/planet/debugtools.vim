vim9script

var script_last_error = ''
var script_links = {'gdb-dashboard': 'https://github.com/cyrus-and/gdb-dashboard', 'gdb-unreal': 'https://dev.epicgames.com/documentation/en-us/unreal-engine/linux-development-requirements-for-unreal-engine',
     'gdb-pretty-printers': 'https://sourceware.org/gdb/current/onlinedocs/gdb.html/Pretty-Printing.html',
     'lldb': 'https://lldb.llvm.org/use/tutorial.html', 'rr': 'https://rr-project.org/', 'live-recorder': 'https://docs.undo.io/',
     'radare2': 'https://book.rada.re/', 'cutter': 'https://cutter.re/', 'gdb-kernel-setup': 'https://docs.kernel.org/process/debugging/gdb-kernel-debugging.html',
     'gdb-kernel': 'https://docs.kernel.org/process/debugging/gdb-kernel-debugging.html', 'kgdb': 'https://docs.kernel.org/process/debugging/kgdb.html',
     'kdb': 'https://docs.kernel.org/process/debugging/kgdb.html', 'debugfs': 'https://docs.kernel.org/filesystems/debugfs.html'}

export def LastError(): any
  return script_last_error
enddef

export def Value(options: any, key: any, prompt: any, default: any = ''): any
  var value: any = has_key(options, key) ? options[key] : inputdialog(prompt, default)
  if type(value) != v:t_string || empty(value) || value =~# '[\r\n]'
    throw 'PlanetVim: cancelled or invalid ' .. key
  endif
  return value
enddef

export def Tool(name: any, options: any = {}): any
  var argv: any = get(options, 'tool', get(get(g:, 'PV_debug_tools', {}), name, [name]))
  if type(argv) == v:t_string
    argv = [argv]
  endif
  if type(argv) != v:t_list || empty(argv) || !empty(filter(copy(argv), (_, value) => type(value) != v:t_string || value =~# '[\r\n]'))
    throw 'PlanetVim: configure ' .. name .. ' as a nonempty executable argv list'
  endif
  if !executable(argv[0])
    throw 'PlanetVim: install ' .. name .. ' and add it to PATH, or set g:PV_debug_tools[' .. string(name) .. '] to its executable argv'
  endif
  return copy(argv)
enddef

def LocalGdbQuote(path: any): any
  if path =~# '[\r\n]'
    throw 'PlanetVim: GDB paths cannot contain line breaks'
  endif
  return '"' .. escape(fnamemodify(path, ':p'), '\"') .. '"'
enddef

def LocalProfiles(): any
  var file: any = planet#paths#Config('debugtools') .. '/profiles.json'
  return filereadable(file) ? json_decode(join(readfile(file), "\n")) : {}
enddef

def LocalRemember(id: any, options: any): any
  var profiles: any = LocalProfiles()
  profiles[id] = options
  writefile([json_encode(profiles)], planet#paths#Config('debugtools') .. '/profiles.json')
  return 0
enddef

def LocalKernelSetup(options: any, root: any): any
  var vmlinux: any = planet#debugtools#Value(options, 'vmlinux', 'Kernel vmlinux with debug symbols:', root .. '/vmlinux')
  if !filereadable(vmlinux)
    throw 'PlanetVim: build a kernel with debug symbols first; vmlinux is missing'
  endif
  var helper: any = planet#debugtools#Value(options, 'helper', 'Kernel GDB helper:', root .. '/vmlinux-gdb.py')
  if !filereadable(helper)
    throw 'PlanetVim: enable CONFIG_GDB_SCRIPTS and build the kernel GDB scripts first'
  endif
  var file: any = planet#paths#Config('debugtools') .. '/kernel-' .. sha256(root)[ : 15] .. '.gdb'
  writefile(['file ' .. LocalGdbQuote(vmlinux), 'source ' .. LocalGdbQuote(helper)], file)
  LocalRemember('gdb-kernel', {'init': file, 'vmlinux': vmlinux, 'cwd': root})
  execute 'edit ' .. fnameescape(file)
  echom 'PlanetVim: kernel symbols configured. Use gdb kernel or kgdb and enter the target endpoint to connect.'
  return file
enddef

export def Run(id: any, arg_options: any = {}): any
  var options: any
  var root: any
  var path: any
  var argv: any
  var vmlinux: any
  var target: any
  var device: any
  var baud: any
  var tool: any
  var program: any
  var arguments: any
  script_last_error = ''
  try
    if !has_key(script_links, id)
      throw 'PlanetVim: unknown debug tool ' .. id
    endif
    options = extend(get(LocalProfiles(), id, {}), arg_options, 'force')
    root = get(options, 'cwd', planet#run#Project().root)
    if !isdirectory(root)
      throw 'PlanetVim: working directory does not exist'
    endif
    if id ==# 'gdb-kernel-setup'
      return LocalKernelSetup(options, root)
    elseif id ==# 'debugfs'
      path = planet#debugtools#Value(options, 'path', 'Mounted debugfs directory:', '/sys/kernel/debug')
      if !isdirectory(path)
        throw 'PlanetVim: debugfs is not mounted or not accessible at ' .. path
      endif
      if exists(':Fern') == 2
        tabnew
        execute 'Fern ' .. fnameescape(path)
      else
        execute 'tabedit ' .. fnameescape(path)
      endif
      return 1
    elseif index(['gdb-dashboard', 'gdb-unreal', 'gdb-pretty-printers'], id) >= 0
      path = planet#debugtools#Value(options, 'init', 'Select the installed ' .. id .. ' GDB/Python script:')
      if !filereadable(path)
        throw 'PlanetVim: the selected GDB extension script does not exist'
      endif
      argv = planet#debugtools#Tool('gdb', options) + ['--quiet', '--nx', '-x', fnamemodify(path, ':p')]
      options.init = fnamemodify(path, ':p')
    elseif index(['gdb-kernel', 'kgdb'], id) >= 0
      vmlinux = planet#debugtools#Value(options, 'vmlinux', 'Kernel vmlinux with debug symbols:', root .. '/vmlinux')
      if !filereadable(vmlinux)
        throw 'PlanetVim: vmlinux is missing; use Setup GDB for Kernel first'
      endif
      target = planet#debugtools#Value(options, 'target', 'GDB remote endpoint (host:port or serial device):', ':1234')
      if target !~# '^[-a-zA-Z0-9_./:\[\]]\+$'
        throw 'PlanetVim: invalid GDB remote endpoint'
      endif
      argv = planet#debugtools#Tool('gdb', options) + ['--quiet', '--nx', vmlinux]
      if has_key(options, 'init') && filereadable(options.init)
        argv += ['-x', options.init]
      endif
      argv += ['-ex', 'target remote ' .. target]
    elseif id ==# 'kdb'
      device = planet#debugtools#Value(options, 'device', 'Serial device for the configured KDB console:', '/dev/ttyUSB0')
      baud = planet#debugtools#Value(options, 'baud', 'Serial baud rate:', '115200')
      if baud !~# '^\d\+$'
        throw 'PlanetVim: baud rate must be numeric'
      endif
      argv = has('win32') ? planet#debugtools#Tool('plink', options) + ['-serial', device, '-sercfg', baud] : planet#debugtools#Tool('picocom', options) + ['--baud', baud, device]
    else
      tool = {'lldb': 'lldb', 'rr': 'rr', 'live-recorder': 'live-record', 'radare2': 'r2', 'cutter': 'cutter'}[id]
      program = planet#debugtools#Value(options, 'program', 'Program to open with ' .. tool .. ':')
      if !filereadable(program)
        throw 'PlanetVim: selected program does not exist'
      endif
      argv = planet#debugtools#Tool(tool, options)
      if id ==# 'rr'
        argv += ['record']
      endif
      argv += [fnamemodify(program, ':p')]
      options.program = fnamemodify(program, ':p')
    endif
    arguments = get(options, 'args', [])
    if type(arguments) != v:t_list || !empty(filter(copy(arguments), (_, value) => type(value) != v:t_string))
      throw 'PlanetVim: debug program args must be an argv list'
    endif
    LocalRemember(id, options)
    return id ==# 'cutter' ? planet#term#RunGuiApp(argv + arguments, root) : planet#term#RunArgv(argv + arguments, v:false, v:false, v:false, root)
  catch
    script_last_error = v:exception
    echom script_last_error
    if has_key(script_links, id)
      echom 'Setup guide: ' .. script_links[id]
    endif
    return 0
  endtry
enddef
