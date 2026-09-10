vim9script
var script_package = expand('<script>:p:h:h:h')
var script_state = {phase: 'idle', id: 0, path: '', error: ''}
var script_generation = 0
var script_job: any = v:null
var script_resize = -1

export def Supported(): any
  return has('gui_running') && has('image') && (has('image_cairo') || has('image_gdk'))
enddef

export def State(): any
  return deepcopy(script_state)
enddef

export def Close(): any
  script_generation += 1
  if script_resize != -1
    timer_stop(script_resize)
    script_resize = -1
  endif
  if script_job != null && job_status(script_job) ==# 'run'
    job_stop(script_job, 'kill')
  endif
  var id: any = script_state.id
  script_state = {phase: 'idle', id: 0, path: '', error: ''}
  if id != 0
    popup_close(id)
  endif
  return 0
enddef

def LocalClosed(id: any, result: any): any
  if id == script_state.id
    planet#image#Close()
  endif
  return 0
enddef

def LocalFilter(id: any, key: any): any
  if index(["\<Esc>", 'q', "\<CR>"], key) >= 0
    popup_close(id)
    return 1
  endif
  return 0
enddef

def LocalCompleted(context: any, job: any, status: any): any
  var meta: any
  var width: any
  var height: any
  try
    if context.generation != script_generation
      return 0
    endif
    meta = filereadable(context.dir .. '/result.json') ? json_decode(join(readfile(context.dir .. '/result.json'), "\n")) : {error: 'Image decoder failed or exceeded its resource limit'}
    if has_key(meta, 'error')
      throw meta.error
    endif
    width = get(meta, 'width', 0)
    height = get(meta, 'height', 0)
    if width < 1 || width > 1024 || height < 1 || height > 768 || getfsize(context.dir .. '/pixels.rgba') != width * height * 4
      throw 'Invalid image thumbnail'
    endif
    script_state.id = popup_create('', {image:  {data:  readblob(context.dir .. '/pixels.rgba'), width:  width, height:  height},  title:  ' ' .. fnamemodify(script_state.path, ':t') .. ' — Esc closes ', pos:  'center', line:  &lines / 2, col:  &columns / 2,  border:  [], close:  'button', mapping:  0, filter:  function(LocalFilter), callback:  function(LocalClosed)})
    script_state.phase = 'ready'
    script_state.width = width
    script_state.height = height
  catch
    script_state.phase = 'error'
    script_state.error = v:exception
    echomsg 'PlanetVim image preview: ' .. v:exception
  finally
    delete(context.dir, 'rf')
  endtry
  return 0
enddef

export def Open(arg_path: any = v:null): any
  if !planet#image#Supported()
    return planet#prompt#Unavailable('GTK GVim with +image and +image_cairo/+image_gdk', 'popup-image')
  endif
  var path: any = arg_path == null ? planet#prompt#Ask('Local image file: ', expand('%:p'), 'file') : arg_path
  if path == null || empty(path)
    return 0
  endif
  path = fnamemodify(path, ':p')
  if !filereadable(path) || getfsize(path) > 32 * 1024 * 1024
    echomsg 'PlanetVim: choose a readable local image no larger than 32 MiB'
    return 0
  endif
  var python: any = planet#generate#Python()
  if empty(python)
    return 0
  endif
  planet#image#Close()
  script_state = {phase: 'loading', id: 0, path: path, error: ''}
  var dir: any = tempname()
  mkdir(dir, '', 0o700)
  var cell: any = exists('*getcellpixels') ? call('getcellpixels', []) : [8, 16]
  var width: any = max([1, min([1024, (&columns - 6) * cell[0]])])
  var height: any = max([1, min([768, (&lines - 8) * cell[1]])])
  var context: any = {dir: dir, generation: script_generation}
  script_job = job_start(python + [script_package .. '/bin/image_preview.py', path, dir, string(width), string(height)], {out_io: 'null', err_io: 'null', in_io: 'null', stoponexit: 'kill', exit_cb: function(LocalCompleted, [context])})
  if job_status(script_job) ==# 'fail'
    delete(dir, 'rf')
    script_state.phase = 'error'
    script_state.error = 'Could not start image decoder'
    echomsg 'PlanetVim: ' .. script_state.error
    return 0
  endif
  return 1
enddef

def LocalResize(timer: any): any
  script_resize = -1
  if index(['loading', 'ready'], script_state.phase) >= 0
    planet#image#Open(script_state.path)
  endif
  return 0
enddef

export def Resize(): any
  if script_resize != -1
    timer_stop(script_resize)
  endif
  if index(['loading', 'ready'], script_state.phase) >= 0
    script_resize = timer_start(150, function(LocalResize))
  endif
  return 0
enddef

augroup PlanetVimImagePreview
  autocmd!
  autocmd VimResized * call planet#image#Resize()
  autocmd VimLeavePre * call planet#image#Close()
augroup END
