scriptversion 4

let s:byte_options = ['binary', 'fileencoding', 'fileformat', 'bomb', 'endofline', 'fixendofline']

func! s:Options(buffer) abort
  let l:options = {}
  for l:name in s:byte_options
    let l:options[l:name] = getbufvar(a:buffer, '&' .. l:name)
  endfor
  let l:options.empty = a:buffer == bufnr() && wordcount().bytes == 0
  return l:options
endfunc

func! s:SetOptions(buffer, options) abort
  for l:name in s:byte_options
    call setbufvar(a:buffer, '&' .. l:name, a:options[l:name])
  endfor
endfunc

" Only the default xxd layout is accepted. xxd -r itself silently skips bad
" lines, so exit status alone cannot distinguish valid input from lost bytes.
func! s:Validate(lines) abort
  if a:lines ==# [''] || empty(a:lines)
    return
  endif
  let l:end = 0
  for l:line in a:lines
    let l:row = matchlist(l:line, '^\(\x\{8,}\): \(.*\)$')
    if empty(l:row)
      throw 'invalid HEX row: expected an xxd offset, byte columns and ASCII gutter'
    endif
    let l:field = strpart(l:row[2], 0, 39)
    let l:hex = substitute(l:field, ' ', '', 'g')
    if l:hex !~# '^\x\{2,32}\%$' || strlen(l:hex) % 2
      throw 'invalid HEX byte columns'
    endif
    let l:groups = join(split(l:hex, '.\{4}\zs'), ' ')
    let l:expected = l:groups .. repeat(' ', 39 - strlen(l:groups))
    let l:ascii = strpart(l:row[2], 41)
    if l:field !=# l:expected || strpart(l:row[2], 39, 2) !=# '  '
          \ || strlen(l:ascii) != strlen(l:hex) / 2 || l:ascii =~# '[^ -~]'
      throw 'invalid HEX row layout (use the default 16-byte xxd columns)'
    endif
    let l:offset = str2nr(l:row[1], 16)
    if l:offset < l:end || strlen(l:row[1]) > 12
      throw 'HEX offsets must be ordered and must not overlap'
    endif
    let l:end = l:offset + strlen(l:hex) / 2
    if l:end > get(g:, 'PV_hex_max_bytes', 64 * 1024 * 1024)
      throw 'HEX output exceeds g:PV_hex_max_bytes (default 64 MiB)'
    endif
  endfor
endfunc

func! s:Run(executable, reverse, input, output, directory) abort
  let l:errors = a:directory .. '/errors.txt'
  let l:argv = [a:executable] + (a:reverse ? ['-r'] : []) + [a:input, a:output]
  let l:job = job_start(l:argv, #{in_io:'null', out_io:'null', err_io:'file', err_name:l:errors, stoponexit:'kill'})
  if job_status(l:job) ==# 'fail'
    throw 'could not start xxd'
  endif
  let l:start = reltime()
  while job_status(l:job) ==# 'run'
    if reltimefloat(reltime(l:start)) > 30
      call job_stop(l:job, 'kill')
      throw 'xxd did not finish within 30 seconds'
    endif
    sleep 10m
  endwhile
  if job_info(l:job).exitval != 0 || !filereadable(a:output)
    throw 'xxd failed: ' .. (filereadable(l:errors) ? join(readfile(l:errors), ' ') : 'no output file')
  endif
endfunc

" Use Vim's native file reader/writer for encoding, NUL, BOM and line-ending
" handling. The temporary window never exposes partially converted source.
func! s:Scratch(action, path, lines, options) abort
  let l:original = win_getid()
  let l:scratch = 0
  let l:window = 0
  try
    " A separate tab also works when the current layout cannot fit a split.
    noautocmd keepalt tabnew
    let l:window = win_getid()
    let l:scratch = bufnr()
    setlocal noswapfile noundofile bufhidden=wipe
    setlocal key=
    if a:action ==# 'write'
      if !get(a:options, 'empty', 0)
        call setline(1, empty(a:lines) ? [''] : a:lines)
      endif
      call s:SetOptions(l:scratch, a:options)
      setlocal nofixendofline
      execute 'noautocmd keepalt silent write! ' .. fnameescape(a:path)
      return {}
    endif
    let l:encoding = empty(a:options.fileencoding) ? &encoding : a:options.fileencoding
    execute 'noautocmd keepalt silent edit! ' .. (a:options.binary ? '++bin' : '++nobin')
          \ .. ' ++enc=' .. l:encoding .. ' ++ff=' .. a:options.fileformat .. ' ++bad=keep ' .. fnameescape(a:path)
    let l:scratch = bufnr()
    setlocal noswapfile noundofile bufhidden=wipe
    let l:result = #{lines:getline(1, '$'), options:s:Options(l:scratch)}
    let l:result.options.fileencoding = a:options.fileencoding
    let l:result.options.fixendofline = a:options.fixendofline
    return l:result
  finally
    if l:window > 0 && win_id2win(l:window) > 0
      call win_execute(l:window, 'noautocmd close!')
    endif
    if l:scratch > 0 && bufexists(l:scratch)
      execute 'noautocmd silent! bwipeout! ' .. l:scratch
    endif
    noautocmd call win_gotoid(l:original)
  endtry
endfunc

func! s:Hex(reverse) abort
  if !&modifiable || &buftype !=# ''
    echomsg 'PlanetVim: HEX conversion requires an editable file buffer.'
    return 0
  endif
  let l:xxd = get(g:, 'xxdprogram', exepath('xxd'))
  if empty(l:xxd) && has('win32')
    let l:xxd = fnamemodify(v:progpath, ':h') .. '/xxd.exe'
  endif
  if !executable(l:xxd)
    echomsg 'PlanetVim: install xxd or set g:xxdprogram to its executable path.'
    return 0
  endif
  let l:source = bufnr()
  let l:window = win_getid()
  let l:tick = b:changedtick
  let l:view = winsaveview()
  let l:lines = getline(1, '$')
  let l:options = s:Options(l:source)
  let l:state = get(b:, 'PV_hex_state', #{options:extend(copy(l:options), #{binary:1, fileencoding:'', fileformat:'unix', bomb:0}), filetype:''})
  let l:directory = ''
  try
    if a:reverse
      call s:Validate(l:lines)
    endif
    let l:directory = tempname()
    call mkdir(l:directory, 'p', 0o700)
    let l:input = l:directory .. '/input'
    let l:output = l:directory .. '/output'
    if a:reverse
      call writefile(l:lines ==# [''] ? [] : l:lines, l:input)
    else
      call s:Scratch('write', l:input, l:lines, l:options)
    endif
    call s:Run(l:xxd, a:reverse, l:input, l:output, l:directory)
    if a:reverse
      let l:decoded = s:Scratch('read', l:output, [], l:state.options)
      call s:Scratch('write', l:directory .. '/roundtrip', l:decoded.lines, l:decoded.options)
      if readblob(l:directory .. '/roundtrip') !=# readblob(l:output)
        throw 'decoded bytes cannot be represented in the original file encoding; source HEX was preserved'
      endif
      let l:newlines = l:decoded.lines
      let l:newoptions = l:decoded.options
    else
      let l:newlines = readfile(l:output)
      call s:Validate(l:newlines)
      let l:newoptions = #{binary:0, fileencoding:'utf-8', fileformat:'unix', bomb:0, endofline:1, fixendofline:1, empty:empty(l:newlines)}
    endif
    if !bufexists(l:source) || getbufvar(l:source, 'changedtick') != l:tick
      throw 'source changed during conversion; source was preserved'
    endif
    let l:newlines = empty(l:newlines) ? [''] : l:newlines
    if l:newoptions.empty
      call deletebufline(l:source, 1, '$')
    elseif setbufline(l:source, 1, l:newlines)
      throw 'could not replace source buffer'
    endif
    if len(getbufline(l:source, 1, '$')) > len(l:newlines)
      silent! undojoin
      call deletebufline(l:source, len(l:newlines) + 1, '$')
    endif
    call s:SetOptions(l:source, l:newoptions)
    call setbufvar(l:source, '&modified', 1)
    if a:reverse
      call setbufvar(l:source, '&filetype', l:state.filetype)
      unlet! b:PV_hex_state
    else
      let b:PV_hex_state = #{options:l:options, filetype:&filetype}
      setlocal filetype=xxd
    endif
    call win_execute(l:window, 'call winrestview(' .. string(l:view) .. ')')
    return 1
  catch
    echohl ErrorMsg | echomsg 'PlanetVim: HEX conversion failed: ' .. v:exception | echohl None
    return 0
  finally
    if !empty(l:directory)
      call delete(l:directory, 'rf')
    endif
  endtry
endfunc

func! planet#tools#XxdToHex() abort
  return s:Hex(v:false)
endfunc

func! planet#tools#XxdFromHex() abort
  return s:Hex(v:true)
endfunc
