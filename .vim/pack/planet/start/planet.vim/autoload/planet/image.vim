scriptversion 4
let s:package = expand('<sfile>:p:h:h:h')
let s:state = #{phase: 'idle', id: 0, path: '', error: ''}
let s:generation = 0
let s:job = v:null
let s:resize = -1

func! planet#image#Supported() abort
  return has('gui_running') && has('image') && (has('image_cairo') || has('image_gdk'))
endfunc

func! planet#image#State() abort
  return deepcopy(s:state)
endfunc

func! planet#image#Close() abort
  let s:generation += 1
  if s:resize != -1 | call timer_stop(s:resize) | let s:resize = -1 | endif
  if s:job isnot v:null && job_status(s:job) ==# 'run' | call job_stop(s:job, 'kill') | endif
  let l:id = s:state.id
  let s:state = #{phase: 'idle', id: 0, path: '', error: ''}
  if l:id | call popup_close(l:id) | endif
endfunc

func! s:Closed(id, result) abort
  if a:id == s:state.id | call planet#image#Close() | endif
endfunc

func! s:Filter(id, key) abort
  if index(["\<Esc>", 'q', "\<CR>"], a:key) >= 0
    call popup_close(a:id)
    return 1
  endif
  return 0
endfunc

func! s:Completed(context, job, status) abort
  try
    if a:context.generation != s:generation | return | endif
    let l:meta = filereadable(a:context.dir .. '/result.json') ? json_decode(join(readfile(a:context.dir .. '/result.json'), "\n")) : #{error: 'Image decoder failed or exceeded its resource limit'}
    if has_key(l:meta, 'error') | throw l:meta.error | endif
    let l:width = get(l:meta, 'width', 0)
    let l:height = get(l:meta, 'height', 0)
    if l:width < 1 || l:width > 1024 || l:height < 1 || l:height > 768 || getfsize(a:context.dir .. '/pixels.rgba') != l:width * l:height * 4
      throw 'Invalid image thumbnail'
    endif
    let s:state.id = popup_create('', #{image: #{data: readblob(a:context.dir .. '/pixels.rgba'), width: l:width, height: l:height},
          \ title: ' ' .. fnamemodify(s:state.path, ':t') .. ' — Esc closes ', pos: 'center', line: &lines / 2, col: &columns / 2,
          \ border: [], close: 'button', mapping: 0, filter: function('s:Filter'), callback: function('s:Closed')})
    let s:state.phase = 'ready'
    let s:state.width = l:width
    let s:state.height = l:height
  catch
    let s:state.phase = 'error'
    let s:state.error = v:exception
    echomsg 'PlanetVim image preview: ' .. v:exception
  finally
    call delete(a:context.dir, 'rf')
  endtry
endfunc

func! planet#image#Open(path = v:null) abort
  if !planet#image#Supported() | return planet#prompt#Unavailable('GTK GVim with +image and +image_cairo/+image_gdk', 'popup-image') | endif
  let l:path = a:path is v:null ? planet#prompt#Ask('Local image file: ', expand('%:p'), 'file') : a:path
  if l:path is v:null || empty(l:path) | return 0 | endif
  let l:path = fnamemodify(l:path, ':p')
  if !filereadable(l:path) || getfsize(l:path) > 32 * 1024 * 1024
    echomsg 'PlanetVim: choose a readable local image no larger than 32 MiB'
    return 0
  endif
  let l:python = planet#generate#Python()
  if empty(l:python) | return 0 | endif
  call planet#image#Close()
  let s:state = #{phase: 'loading', id: 0, path: l:path, error: ''}
  let l:dir = tempname()
  call mkdir(l:dir, '', 0o700)
  let l:cell = exists('*getcellpixels') ? getcellpixels() : [8, 16]
  let l:width = max([1, min([1024, (&columns - 6) * l:cell[0]])])
  let l:height = max([1, min([768, (&lines - 8) * l:cell[1]])])
  let l:context = #{dir: l:dir, generation: s:generation}
  let s:job = job_start(l:python + [s:package .. '/bin/image_preview.py', l:path, l:dir, string(l:width), string(l:height)],
        \ #{out_io: 'null', err_io: 'null', in_io: 'null', stoponexit: 'kill', exit_cb: function('s:Completed', [l:context])})
  if job_status(s:job) ==# 'fail'
    call delete(l:dir, 'rf')
    let s:state.phase = 'error'
    let s:state.error = 'Could not start image decoder'
    echomsg 'PlanetVim: ' .. s:state.error
    return 0
  endif
  return 1
endfunc

func! s:Resize(timer) abort
  let s:resize = -1
  if index(['loading', 'ready'], s:state.phase) >= 0 | call planet#image#Open(s:state.path) | endif
endfunc

func! planet#image#Resize() abort
  if s:resize != -1 | call timer_stop(s:resize) | endif
  if index(['loading', 'ready'], s:state.phase) >= 0 | let s:resize = timer_start(150, function('s:Resize')) | endif
endfunc

augroup PlanetVimImagePreview
  autocmd!
  autocmd VimResized * call planet#image#Resize()
  autocmd VimLeavePre * call planet#image#Close()
augroup END
