vim9script

var script_candidates: list<string> = []

def Files(): any
  if executable('rg')
    return 'rg --files --hidden -g !.git -g !.hg'
  endif
  return filter(glob('**/*', false, true), (_, path) => filereadable(path))
enddef

def OpenFile(path: string)
  clap#sink#edit_with_open_action(path)
enddef

def OpenFiles(paths: list<string>)
  clap#sink#open_quickfix(map(copy(paths), (_, path) => ({filename: path})))
enddef

def PreviewFile()
  clap#preview#file(g:clap.display.getcurline())
enddef

def Filter(query: string, candidates: list<string>): list<string>
  var result = matchfuzzypos(candidates, query)
  g:__clap_fuzzy_matched_indices = result[1]
  return result[0]
enddef

def Typed()
  var query = g:clap.input.get()
  if empty(query)
    g:__clap_has_no_matches = false
    g:__clap_fuzzy_matched_indices = []
    g:clap.display.set_lines(script_candidates)
    clap#legacy#state#refresh_matches_count(len(script_candidates))
    g:clap#display_win.shrink_if_undersize()
  else
    clap#legacy#filter#on_typed(function(Filter), query, script_candidates)
  endif
enddef

def Initialize()
  script_candidates = g:clap.provider._apply_source()
  g:clap.display.initial_size = len(script_candidates)
  clap#picker#init(script_candidates, {}, false, false)
  Typed()
enddef

# Ripgrep's JSON protocol keeps paths, spaces and search text out of the shell.
var grep_job: job = null_job
var grep_timer = -1
var grep_generation = 0
var grep_items: dict<dict<any>> = {}
var grep_rows: list<string> = []
var grep_cwd = ''
var grep_errors: list<string> = []

def GrepStop()
  grep_generation += 1
  if grep_timer != -1
    timer_stop(grep_timer)
    grep_timer = -1
  endif
  if job_status(grep_job) ==# 'run'
    job_stop(grep_job)
  endif
enddef

def GrepShow()
  g:__clap_has_no_matches = empty(grep_rows)
  g:clap.display.set_lines(grep_rows)
  clap#legacy#state#refresh_matches_count(len(grep_rows))
  g:clap#display_win.shrink_if_undersize()
enddef

def GrepOutput(generation: number, channel: channel, line: string)
  if generation != grep_generation || len(grep_rows) >= 2000
    return
  endif
  var record = json_decode(line)
  if get(record, 'type', '') !=# 'match'
    return
  endif
  var data = record.data
  if !has_key(data.path, 'text') || !has_key(data.lines, 'text')
    return
  endif
  var path = data.path.text
  var column = get(get(data, 'submatches', [{}]), 0, {start: 0}).start + 1
  var contents = substitute(data.lines.text, '[\r\n]\+$', '', '')
  var row = path .. ':' .. data.line_number .. ':' .. column .. ':' .. contents
  grep_items[row] = {filename: simplify(grep_cwd .. '/' .. path), lnum: data.line_number, col: column, text: contents}
  add(grep_rows, row)
  if len(grep_rows) == 1 || len(grep_rows) % 100 == 0
    GrepShow()
  endif
  if len(grep_rows) == 2000
    job_stop(grep_job)
    echom 'PlanetVim: showing the first 2000 search matches; refine the query for more specific results'
  endif
enddef

def GrepError(generation: number, channel: channel, line: string)
  if generation == grep_generation && len(grep_errors) < 5
    add(grep_errors, line)
  endif
enddef

def GrepClosed(generation: number, channel: channel)
  if generation == grep_generation
    GrepShow()
    if empty(grep_rows) && !empty(grep_errors)
      g:clap.display.set_lines(grep_errors)
    endif
  endif
enddef

def GrepStart(query: string, generation: number, timer: number)
  grep_timer = -1
  if generation != grep_generation
    return
  endif
  if !executable('rg')
    g:clap.display.set_lines(['Install ripgrep (rg) to search file contents'])
    return
  endif
  grep_job = job_start(['rg', '--json', '--smart-case', '--', query, '.'], {
    cwd: grep_cwd, in_io: 'null', err_cb: function(GrepError, [generation]),
    out_cb: function(GrepOutput, [generation]), close_cb: function(GrepClosed, [generation]),
  })
enddef

def GrepTyped()
  GrepStop()
  grep_rows = []
  grep_items = {}
  grep_errors = []
  grep_cwd = clap#rooter#working_dir()
  GrepShow()
  var query = g:clap.input.get()
  if !empty(query)
    grep_timer = timer_start(150, function(GrepStart, [query, grep_generation]))
  endif
enddef

def GrepSink(row: string)
  if has_key(grep_items, row)
    var item = grep_items[row]
    clap#sink#open_file(item.filename, item.lnum, item.col)
  endif
enddef

def GrepMany(rows: list<string>)
  clap#sink#open_quickfix(map(copy(rows), (_, row) => grep_items[row]))
enddef

def GrepPreview()
  var row = g:clap.display.getcurline()
  if has_key(grep_items, row)
    clap#preview#file(grep_items[row].filename)
  endif
enddef

def SelectProvider(selected: string)
  var id = matchstr(selected, '^[^:]*')
  timer_start(0, (_) => planet#picker#Clap(0, [id]))
enddef

export def Prepare()
  if clap#maple#is_available()
    return
  endif
  var provider = g:clap.provider._()
  # New Clap defaults send source lists to Maple. Restore local filtering
  # through provider hooks, including providers selected from its own palette.
  if has_key(provider, 'source') && !has_key(provider, 'init')
    provider.init = function(Initialize)
    provider.on_typed = function(Typed)
  endif
enddef

export def Clap(bang: number, arguments: list<string>)
  # Loading the public entry point also defines Clap's autoload directory.
  if !exists('*clap#')
    runtime autoload/clap.vim
  endif
  if !clap#maple#is_available() && !exists('g:clap_provider_providers')
    g:clap_provider_providers = copy(g:clap#provider#providers#)
    g:clap_provider_providers.sink = function(SelectProvider)
  endif
  var args = copy(arguments)
  var provider = get(args, 0, 'providers')
  var custom = get(g:, 'clap_provider_' .. provider, {})
  if !clap#maple#is_available() && has_key(custom, 'source')
    # Fill defaults before upstream injects its RPC callback; keep custom hooks.
    extend(custom, {init: function(Initialize), on_typed: function(Typed)}, 'keep')
  endif
  if !clap#maple#is_available() && !exists('g:clap_provider_' .. provider)
    if provider ==# 'files'
      g:clap_provider_files = {
        source: function(Files), sink: function(OpenFile),
        'sink*': function(OpenFiles), on_move: function(PreviewFile),
        filter: function(Filter), enable_rooter: true, support_open_action: true,
      }
    elseif provider ==# 'grep'
      g:clap_provider_grep = {init: function(GrepTyped), on_typed: function(GrepTyped),
        on_exit: function(GrepStop), sink: function(GrepSink), 'sink*': function(GrepMany),
        on_move: function(GrepPreview), support_open_action: true}
    elseif provider ==# 'filer'
      execute 'Fern . -reveal=%'
      return
    endif
  endif
  call('clap#', [bang] + args)
  if !clap#maple#is_available() && get(popup_getpos(get(g:clap.display, 'winid', 0)), 'visible', 0)
    # --query is now consumed by Maple. Local providers need the same input
    # applied explicitly, followed by their regular filtering hook.
    for argument in args
      if argument =~# '^--query='
        var query = strpart(argument, 8)
        g:clap.input.set(query ==# '@visual' ? clap#util#get_visual_selection() : clap#util#expand(query))
        g:clap.provider._().on_typed()
        break
      endif
    endfor
  endif
enddef
