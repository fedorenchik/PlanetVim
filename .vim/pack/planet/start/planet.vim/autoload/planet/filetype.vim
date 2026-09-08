scriptversion 4

func! s:Set(option, value) abort
  if !has_key(b:PV_filetype_options, a:option)
    let b:PV_filetype_options[a:option] = eval('&l:' .. a:option)
  endif
  execute 'let &l:' .. a:option .. ' = a:value'
endfunc

func! s:Map(mode, lhs, rhs, abbreviation = v:false, recursive = v:false) abort
  let l:previous = maparg(a:lhs, a:mode, a:abbreviation, 1)
  call add(b:PV_filetype_maps, {'mode': a:mode, 'lhs': a:lhs,
        \ 'abbreviation': a:abbreviation,
        \ 'previous': get(l:previous, 'buffer', 0) ? l:previous : {}})
  let l:command = a:mode .. (a:recursive ? '' : 'nore') .. (a:abbreviation ? 'abbrev' : 'map')
  execute l:command .. ' <buffer> ' .. a:lhs .. ' ' .. a:rhs
endfunc

func! planet#filetype#Undo() abort
  for l:item in get(b:, 'PV_filetype_maps', [])
    execute 'silent! ' .. l:item.mode .. 'un' .. (l:item.abbreviation ? 'abbrev' : 'map')
          \ .. ' <buffer> ' .. l:item.lhs
    if !empty(l:item.previous)
      call mapset(l:item.mode, l:item.abbreviation, l:item.previous)
    endif
  endfor
  for [l:option, l:value] in items(get(b:, 'PV_filetype_options', {}))
    execute 'let &l:' .. l:option .. ' = l:value'
  endfor
  if exists('b:PV_filetype_undo')
    let b:undo_ftplugin = b:PV_filetype_undo
  endif
  unlet! b:PV_filetype_options b:PV_filetype_maps b:PV_filetype_undo
endfunc

func! planet#filetype#Apply() abort
  call planet#filetype#Undo()
  let b:PV_filetype_options = {}
  let b:PV_filetype_maps = []
  let b:PV_filetype_undo = get(b:, 'undo_ftplugin', '')
  " Restore our overrides before the upstream ftplugin clears its own options.
  let b:undo_ftplugin = 'call planet#filetype#Undo()'
        \ .. (empty(b:PV_filetype_undo) ? '' : ' | ' .. b:PV_filetype_undo)
  let l:ft = &filetype
  if l:ft ==# 'cmake'
    call s:Set('keywordprg', ':CMakeHelpPopup')
    call s:Set('balloonexpr', 'cmakehelp#balloonexpr()')
    call s:Map('n', '<leader>k', '<Plug>(cmake-help-online)', v:false, v:true)
    call s:Map('n', '<leader>K', '<Plug>(cmake-help)', v:false, v:true)
  elseif index(['c', 'cpp'], l:ft) >= 0
    call s:Set('foldmethod', 'syntax')
    call s:Set('colorcolumn', l:ft ==# 'c' ? '80' : '120')
    if get(g:, 'PV_c_style_shortcuts', 1)
      for [l:lhs, l:rhs] in items({'#e': '#endif', '#d': '#define', '#i': '#include', '#n': '#ifndef'})
        call s:Map('i', l:lhs, l:rhs, v:true)
      endfor
      if l:ft ==# 'cpp'
        for [l:lhs, l:rhs] in items({',,': '<<', ';b': 'std::begin', ';c': 'std::cout',
              \ ';e': 'std::end', ';m': 'std::map', ';s': 'std::string', ';v': 'std::vector'})
          call s:Map('i', l:lhs, l:rhs, v:true)
        endfor
        call s:Map('i', ';;', '::')
      endif
    endif
  endif
  if index(['dockerfile', 'python', 'qmake'], l:ft) >= 0
    call s:Set('expandtab', 1)
    call s:Set('tabstop', 4)
    call s:Set('shiftwidth', 4)
  endif
  if index(['help', 'markdown', 'text'], l:ft) >= 0
    call s:Set('colorcolumn', '+0')
  endif
  if l:ft ==# 'markdown'
    call s:Map('n', '<A-t>', '<Cmd>Vista!! toc<CR>')
    " Vim's Markdown ftplugin supplies its folding expression when enabled.
    if !empty(&foldexpr) && &foldexpr !=# '0'
      call s:Set('foldmethod', 'expr')
    endif
  elseif l:ft ==# 'sh'
    call s:Set('formatoptions', &formatoptions .. 'croql')
    call s:Set('include', '^\s*\%(\.\|source\)\s')
    call s:Set('define', '\<\%(\i\+\s*()\)\@=')
  elseif l:ft ==# 'text'
    call s:Set('textwidth', 72)
    call s:Set('linebreak', 1)
    call s:Set('breakindent', 1)
    call s:Set('complete', &complete .. ',k,s')
    call s:Set('spell', 1)
  elseif l:ft ==# 'vim'
    call s:Set('foldmethod', 'marker')
    call s:Set('foldlevel', 0)
  endif
  if index(['text', 'markdown'], l:ft) >= 0 && stridx(&formatoptions, 't') < 0
    call s:Set('formatoptions', &formatoptions .. 't')
  endif
  if empty(&omnifunc)
    call s:Set('omnifunc', 'syntaxcomplete#Complete')
  endif
  if empty(&completefunc)
    call s:Set('completefunc', 'syntaxcomplete#Complete')
  endif
endfunc
