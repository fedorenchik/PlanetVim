vim9script

var script_byte_options = ['binary', 'fileencoding', 'fileformat', 'bomb', 'endofline', 'fixendofline']

def LocalOptions(buffer: any): any
  var options: any = {}
  for name in script_byte_options
    options[name] = getbufvar(buffer, '&' .. name)
  endfor
  options.empty = buffer == bufnr() && wordcount().bytes == 0
  return options
enddef

def LocalSetOptions(buffer: any, options: any): any
  for name in script_byte_options
    setbufvar(buffer, '&' .. name, options[name])
  endfor
  return 0
enddef

# Only the default xxd layout is accepted. xxd -r itself silently skips bad
# lines, so exit status alone cannot distinguish valid input from lost bytes.
def LocalValidate(lines: any): any
  var row: any
  var field: any
  var hex: any
  var groups: any
  var expected: any
  var ascii: any
  var offset: any
  if lines ==# [''] || empty(lines)
    return 0
  endif
  var end: any = 0
  for line in lines
    row = matchlist(line, '^\(\x\{8,}\): \(.*\)$')
    if empty(row)
      throw 'invalid HEX row: expected an xxd offset, byte columns and ASCII gutter'
    endif
    field = strpart(row[2], 0, 39)
    hex = substitute(field, ' ', '', 'g')
    if hex !~# '^\x\{2,32}\%$' || strlen(hex) % 2
      throw 'invalid HEX byte columns'
    endif
    groups = join(split(hex, '.\{4}\zs'), ' ')
    expected = groups .. repeat(' ', 39 - strlen(groups))
    ascii = strpart(row[2], 41)
    if field !=# expected || strpart(row[2], 39, 2) !=# '  ' || strlen(ascii) != strlen(hex) / 2 || ascii =~# '[^ -~]'
      throw 'invalid HEX row layout (use the default 16-byte xxd columns)'
    endif
    offset = str2nr(row[1], 16)
    if offset < end || strlen(row[1]) > 12
      throw 'HEX offsets must be ordered and must not overlap'
    endif
    end = offset + strlen(hex) / 2
    if end > get(g:, 'PV_hex_max_bytes', 64 * 1024 * 1024)
      throw 'HEX output exceeds g:PV_hex_max_bytes (default 64 MiB)'
    endif
  endfor
  return 0
enddef

def LocalRun(executable: any, reverse: any, input: any, output: any, directory: any): any
  var start: any
  var errors: any = directory .. '/errors.txt'
  var argv: any = [executable] + (reverse ? ['-r'] : []) + [input, output]
  var job: any = job_start(argv, {in_io: 'null', out_io: 'null', err_io: 'file', err_name: errors, stoponexit: 'kill'})
  if job_status(job) ==# 'fail'
    throw 'could not start xxd'
  endif
  start = reltime()
  while job_status(job) ==# 'run'
    if reltimefloat(reltime(start)) > 30
      job_stop(job, 'kill')
      throw 'xxd did not finish within 30 seconds'
    endif
    sleep 10m
  endwhile
  if job_info(job).exitval != 0 || !filereadable(output)
    throw 'xxd failed: ' .. (filereadable(errors) ? join(readfile(errors), ' ') :  'no output file')
  endif
  return 0
enddef

# Use Vim's native file reader/writer for encoding, NUL, BOM and line-ending
# handling. The temporary window never exposes partially converted source.
def LocalScratch(action: any, path: any, lines: any, options: any): any
  var encoding: any
  var result: any
  var original: any = win_getid()
  var scratch: any = 0
  var window: any = 0
  try
    # A separate tab also works when the current layout cannot fit a split.
    noautocmd keepalt tabnew
    window = win_getid()
    scratch = bufnr()
    setlocal noswapfile noundofile bufhidden=wipe
    setlocal key=
    if action ==# 'write'
      if !get(options, 'empty', 0)
        setline(1, empty(lines) ? [''] : lines)
      endif
      LocalSetOptions(scratch, options)
      setlocal nofixendofline
      execute 'noautocmd keepalt silent write! ' .. fnameescape(path)
      return {}
    endif
    encoding = empty(options.fileencoding) ? &encoding : options.fileencoding
    execute 'noautocmd keepalt silent edit! ' .. (options.binary ? '++bin' : '++nobin') .. ' ++enc=' .. encoding .. ' ++ff=' .. options.fileformat .. ' ++bad=keep ' .. fnameescape(path)
    scratch = bufnr()
    setlocal noswapfile noundofile bufhidden=wipe
    result = {lines: getline(1, '$'), options: LocalOptions(scratch)}
    result.options.fileencoding = options.fileencoding
    result.options.fixendofline = options.fixendofline
    return result
  finally
    if window > 0 && win_id2win(window) > 0
      win_execute(window, 'noautocmd close!')
    endif
    if scratch > 0 && bufexists(scratch)
      execute 'noautocmd silent! bwipeout! ' .. scratch
    endif
    noautocmd win_gotoid(original)
  endtry
  return 0
enddef

def LocalHex(reverse: any): any
  var input: any
  var output: any
  var decoded: any
  var newlines: any
  var newoptions: any
  if !&modifiable || &buftype !=# ''
    echomsg 'PlanetVim: HEX conversion requires an editable file buffer.'
    return 0
  endif
  var xxd: any = get(g:, 'xxdprogram', exepath('xxd'))
  if empty(xxd) && has('win32')
    xxd = fnamemodify(v:progpath, ':h') .. '/xxd.exe'
  endif
  if !executable(xxd)
    echomsg 'PlanetVim: install xxd or set g:xxdprogram to its executable path.'
    return 0
  endif
  var source: any = bufnr()
  var window: any = win_getid()
  var tick: any = b:changedtick
  var view: any = winsaveview()
  var lines: any = getline(1, '$')
  var options: any = LocalOptions(source)
  var state: any = get(b:, 'PV_hex_state', {options: extend(copy(options), {binary: 1, fileencoding: '', fileformat: 'unix', bomb: 0}), filetype: ''})
  var directory: any = ''
  try
    if reverse
      LocalValidate(lines)
    endif
    directory = tempname()
    mkdir(directory, 'p', 0o700)
    input = directory .. '/input'
    output = directory .. '/output'
    if reverse
      writefile(lines ==# [''] ? [] : lines, input)
    else
      LocalScratch('write', input, lines, options)
    endif
    LocalRun(xxd, reverse, input, output, directory)
    if reverse
      decoded = LocalScratch('read', output, [], state.options)
      LocalScratch('write', directory .. '/roundtrip', decoded.lines, decoded.options)
      if readblob(directory .. '/roundtrip') !=# readblob(output)
        throw 'decoded bytes cannot be represented in the original file encoding; source HEX was preserved'
      endif
      newlines = decoded.lines
      newoptions = decoded.options
    else
      newlines = readfile(output)
      LocalValidate(newlines)
      newoptions = {binary: 0, fileencoding: 'utf-8', fileformat: 'unix', bomb: 0, endofline: 1, fixendofline: 1, empty: empty(newlines)}
    endif
    if !bufexists(source) || getbufvar(source, 'changedtick') != tick
      throw 'source changed during conversion; source was preserved'
    endif
    newlines = empty(newlines) ? [''] : newlines
    if newoptions.empty
      deletebufline(source, 1, '$')
    elseif setbufline(source, 1, newlines)
      throw 'could not replace source buffer'
    endif
    if len(getbufline(source, 1, '$')) > len(newlines)
      silent! undojoin
      deletebufline(source, len(newlines) + 1, '$')
    endif
    LocalSetOptions(source, newoptions)
    setbufvar(source, '&modified', 1)
    if reverse
      setbufvar(source, '&filetype', state.filetype)
      unlet! b:PV_hex_state
    else
      b:PV_hex_state = {options: options, filetype: &filetype}
      setlocal filetype=xxd
    endif
    win_execute(window, 'call winrestview(' .. string(view) .. ')')
    return 1
  catch
    echohl ErrorMsg
    echomsg 'PlanetVim: HEX conversion failed: ' .. v:exception
    echohl None
    return 0
  finally
    if !empty(directory)
      delete(directory, 'rf')
    endif
  endtry
  return 0
enddef

export def XxdToHex(): any
  return LocalHex(v:false)
enddef

export def XxdFromHex(): any
  return LocalHex(v:true)
enddef
