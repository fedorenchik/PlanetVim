scriptversion 4

func! s:Quote(argument) abort
  if !has('win32')
    return '"' .. escape(a:argument, '\"') .. '"'
  endif
  let l:quoted = '"'
  let l:slashes = 0
  for l:char in split(a:argument, '\zs')
    if l:char ==# '\'
      let l:slashes += 1
    elseif l:char ==# '"'
      let l:quoted ..= repeat('\', 2 * l:slashes + 1) .. '"'
      let l:slashes = 0
    else
      let l:quoted ..= repeat('\', l:slashes) .. l:char
      let l:slashes = 0
    endif
  endfor
  return l:quoted .. repeat('\', 2 * l:slashes) .. '"'
endfunc

func! planet#grammar#Configure() abort
  let l:argv = get(g:, 'PV_languagetool_argv', [get(g:, 'PV_languagetool_command', 'languagetool')])
  if type(l:argv) != v:t_list || empty(l:argv)
        \ || !empty(filter(copy(l:argv), {_, value -> type(value) != v:t_string})) || !executable(l:argv[0])
    echohl WarningMsg
    echom 'PlanetVim: Install the local LanguageTool CLI and Java, or set g:PV_languagetool_argv to a native executable argument list.'
    echohl None
    return 0
  endif
  let l:python = planet#generate#Python()
  if empty(l:python)
    return 0
  endif
  let g:PV_grammar_error_file = planet#paths#State('grammar') .. '/' .. getpid() .. '.log'
  let l:settings = json_encode(#{argv: l:argv, timeout: get(g:, 'PV_grammar_timeout', 60), error_file: g:PV_grammar_error_file})
  let l:config = planet#paths#Cache('grammar') .. '/' .. sha256(l:settings)[:20] .. '.json'
  if !filereadable(l:config)
    " Repeated/parallel checks share immutable settings, never a file being
    " truncated while an earlier subprocess is opening it.
    let l:temporary = l:config .. '.tmp-' .. getpid()
    try
      call writefile([l:settings], l:temporary)
      if rename(l:temporary, l:config) != 0 && !filereadable(l:config)
        throw 'Could not save LanguageTool adapter settings'
      endif
    finally
      call delete(l:temporary)
    endtry
  endif
  let l:adapter = l:python + [planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/languagetool.py', '--config', l:config]
  " Grammarous uses native job_start(String), not a shell. The real backend
  " arguments live in JSON and are launched as a native List by our adapter.
  let g:grammarous#languagetool_cmd = join(map(l:adapter, {_, value -> s:Quote(value)}), ' ')
  let g:grammarous#jar_dir = planet#paths#Cache('grammar/jars')
  return 1
endfunc
