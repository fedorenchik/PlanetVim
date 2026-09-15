vim9script

var latest: dict<any> = {}

export def Auto(command: any): string
  var name = type(command) == v:t_list ? command[0] : matchstr(command, '^\s*\zs[^ ]*')
  name = fnamemodify(name, ':t')
  if index(['cmake', 'make', 'gmake', 'ninja', 'gcc', 'g++', 'cc', 'c++', 'clang', 'clang++',
      'clang-tidy', 'clazy', 'cppcheck', 'scons', 'meson', 'cargo'], name) >= 0
    return 'compiler'
  elseif name =~# '^pytest\|^python'
    return 'python'
  endif
  return ''
enddef

export def Capture(context: dict<any>, channel: any, message: string)
  if !empty(context.log_file)
    writefile(split(message, "\n", 1), context.log_file, 'ab')
  endif
enddef

export def Parse(lines: list<string>, cwd: string, parser: string): list<any>
  var clean = map(copy(lines), (_, line) => substitute(substitute(line, '\e\[[0-9;?]*[[:alpha:]]', '', 'g'), '\r$', '', ''))
  var items: list<any> = []
  var pending: dict<any> = {}
  var directories = [cwd]
  for line in clean
    var directory = matchlist(line, '^\s*\%(g\?make\)\%([^:]*\): \(Entering\|Leaving\) directory [''`]\(.*\)[''`]$')
    if !empty(directory)
      if directory[1] ==# 'Entering'
        add(directories, planet#run#Path(directory[2], directories[-1]))
      elseif len(directories) > 1
        remove(directories, -1)
      endif
      continue
    endif
    var match = matchlist(line, '^\(.\{-}\):\(\d\+\):\%(\(\d\+\):\)\?\s*\(fatal error\|error\|warning\|note\):\s*\(.*\)$')
    if !empty(match)
      add(items, {filename: planet#run#Path(match[1], directories[-1]), lnum: str2nr(match[2]), col: str2nr(match[3]),
        type: match[4] ==# 'warning' ? 'W' : match[4] ==# 'note' ? 'I' : 'E', text: match[5]})
      continue
    endif
    match = matchlist(line, '^\%(/[^:]*ld[^:]*:\s*\)\?\(.\{-}\):\(\d\+\):\s*\(undefined reference.*\|multiple definition.*\)$')
    if !empty(match)
      add(items, {filename: planet#run#Path(match[1], directories[-1]), lnum: str2nr(match[2]), type: 'E', text: match[3]})
      continue
    endif
    match = matchlist(line, '^CMake \(Error\|Warning\)\%(([^)]*)\)\? at \(.\{-}\):\(\d\+\)\%([ :].*\)\?:$')
    if !empty(match)
      pending = {filename: planet#run#Path(match[2], cwd), lnum: str2nr(match[3]), type: match[1] ==# 'Error' ? 'E' : 'W', text: line}
      add(items, pending)
      continue
    endif
    if !empty(pending) && line =~# '^  \S'
      pending.text ..= ' ' .. trim(line)
      pending = {}
    endif
    if parser ==# 'python'
      match = matchlist(line, '^\s*File "\(.*\)", line \(\d\+\)\%(,.*\)\?$')
      if !empty(match)
        pending = {filename: planet#run#Path(match[1], cwd), lnum: str2nr(match[2]), type: 'E', text: trim(line)}
        add(items, pending)
      elseif !empty(items) && line =~# '^\w\+\%(Error\|Exception\):'
        items[-1].text = line
      endif
    endif
  endfor
  return items
enddef

export def Finish(context: dict<any>)
  var result = context.result
  if empty(context.parser) || !filereadable(context.log_file)
    return
  endif
  # Keep the complete raw log on disk; bound parsing memory for enormous builds.
  var lines = readfile(context.log_file, '', -50000)
  var items = Parse(lines, result.cwd, context.parser)
  var title = result.project .. ' [' .. result.configuration .. '] ' .. result.command
  setqflist([], ' ', {title: title, items: items, context: {project: result.project,
    output: context.buffer, log_file: context.log_file, status: result.status}})
  result.quickfix_id = getqflist({id: 0}).id
  result.diagnostics = items
  latest[result.project] = {title: title, items: items, log_file: context.log_file}
enddef

export def Show()
  var result = planet#term#Result(bufnr())
  var root = planet#project#Root()
  if has_key(result, 'diagnostics')
    setqflist([], ' ', {title: result.command, items: result.diagnostics})
  elseif has_key(latest, root)
    setqflist([], ' ', {title: latest[root].title, items: latest[root].items})
  else
    echom 'PlanetVim: no parsed command diagnostics in this project yet.'
    return
  endif
  copen
enddef

export def Log()
  var path = get(planet#term#Result(bufnr()), 'log_file', get(get(latest, planet#project#Root(), {}), 'log_file', ''))
  if empty(path) || !filereadable(path)
    echom 'PlanetVim: no retained command log available.'
    return
  endif
  execute 'view ' .. fnameescape(path)
enddef
