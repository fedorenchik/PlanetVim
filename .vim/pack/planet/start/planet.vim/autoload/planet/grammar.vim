vim9script
def LocalQuote(argument: any): any
  if !has('win32')
    return '"' .. escape(argument, '\"') .. '"'
  endif
  var quoted: any = '"'
  var slashes: any = 0
  for char in split(argument, '\zs')
    if char ==# '\'
      slashes += 1
    elseif char ==# '"'
      quoted ..= repeat('\', 2 * slashes + 1) .. '"'
      slashes = 0
    else
      quoted ..= repeat('\', slashes) .. char
      slashes = 0
    endif
  endfor
  return quoted .. repeat('\', 2 * slashes) .. '"'
enddef

export def Configure(): any
  var adapter: any
  var argv: any = get(g:, 'PV_languagetool_argv', [get(g:, 'PV_languagetool_command', 'languagetool')])
  if type(argv) != v:t_list || empty(argv) || !empty(filter(copy(argv), (_, lambda_value) => type(lambda_value) != v:t_string)) || !executable(argv[0])
    echohl WarningMsg
    echom 'PlanetVim: Install the local LanguageTool CLI and Java, or set g:PV_languagetool_argv to a native executable argument list.'
    echohl None
    return 0
  endif
  var python: any = planet#generate#Python()
  if empty(python)
    return 0
  endif
  g:PV_grammar_error_file = planet#paths#SessionState('grammar') .. '/' .. getpid() .. '.log'
  adapter = python + [planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/languagetool.py',
    '--timeout=' .. get(g:, 'PV_grammar_timeout', 60), '--error-file=' .. g:PV_grammar_error_file]
    + mapnew(argv, (_, argument) => '--backend-arg=' .. argument)
  # Grammarous uses native job_start(String), not a shell. The real backend
  # arguments are passed literally and launched as a native List by our adapter.
  g:grammarous#languagetool_cmd = join(map(adapter, (_, lambda_value) => LocalQuote(lambda_value)), ' ')
  g:grammarous#jar_dir = planet#paths#Cache('grammar/jars')
  return 1
enddef
