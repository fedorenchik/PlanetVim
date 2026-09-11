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
      # This is the upstream ripgrep provider retained for installations
      # without Maple; it supports the same --query argument.
      args[0] = 'live_grep'
    elseif provider ==# 'filer'
      execute 'Fern . -reveal=%'
      return
    endif
  endif
  if !clap#maple#is_available() && !has_key(g:clap#provider_alias, 'grep')
    g:clap#provider_alias.grep = 'live_grep'
  endif
  call('clap#', [bang] + args)
enddef
