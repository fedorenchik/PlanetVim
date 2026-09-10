vim9script
def LocalSet(option: any, value: any): any
  if !has_key(b:PV_filetype_options, option)
    b:PV_filetype_options[option] = eval('&l:' .. option)
  endif
  execute '&l:' .. option .. ' = ' .. string(value)
  return 0
enddef

def LocalMap(mode: any, lhs: any, rhs: any, abbreviation: any = v:false, recursive: any = v:false): any
  var previous: any = maparg(lhs, mode, abbreviation, 1)
  add(b:PV_filetype_maps, {'mode': mode, 'lhs': lhs, 'abbreviation': abbreviation, 'previous': get(previous, 'buffer', 0) ? previous : {}})
  var command: any = mode .. (recursive ? '' : 'nore') .. (abbreviation ? 'abbrev' : 'map')
  execute command .. ' <buffer> ' .. lhs .. ' ' .. rhs
  return 0
enddef

export def Undo(): any
  for item in get(b:, 'PV_filetype_maps', [])
    execute 'silent! ' .. item.mode .. 'un' .. (item.abbreviation ? 'abbrev' : 'map') .. ' <buffer> ' .. item.lhs
    if !empty(item.previous)
      mapset(item.mode, item.abbreviation, item.previous)
    endif
  endfor
  for [option, value] in items(get(b:, 'PV_filetype_options', {}))
    execute '&l:' .. option .. ' = ' .. string(value)
  endfor
  if exists('b:PV_filetype_undo')
    b:undo_ftplugin = b:PV_filetype_undo
  endif
  unlet! b:PV_filetype_options b:PV_filetype_maps b:PV_filetype_undo
  return 0
enddef

export def Apply(): any
  var lhs: any
  var rhs: any
  planet#filetype#Undo()
  b:PV_filetype_options = {}
  b:PV_filetype_maps = []
  b:PV_filetype_undo = get(b:, 'undo_ftplugin', '')
  # Restore our overrides before the upstream ftplugin clears its own options.
  b:undo_ftplugin = 'call planet#filetype#Undo()'  .. (empty(b:PV_filetype_undo) ? '' :  ' | ' .. b:PV_filetype_undo)
  var ft: any = &filetype
  if ft ==# 'cmake'
    LocalSet('keywordprg', ':CMakeHelpPopup')
    LocalSet('balloonexpr', 'cmakehelp#balloonexpr()')
    LocalMap('n', '<leader>k', '<Plug>(cmake-help-online)', v:false, v:true)
    LocalMap('n', '<leader>K', '<Plug>(cmake-help)', v:false, v:true)
  elseif index(['c', 'cpp'], ft) >= 0
    LocalSet('foldmethod', 'syntax')
    LocalSet('colorcolumn', ft ==# 'c' ? '80' : '120')
    if get(g:, 'PV_c_style_shortcuts', 1)
      for [item_lhs, item_rhs] in items({'#e': '#endif', '#d': '#define', '#i': '#include', '#n': '#ifndef'})
        lhs = item_lhs
        rhs = item_rhs
        LocalMap('i', lhs, rhs, v:true)
      endfor
      if ft ==# 'cpp'
        for [item_lhs, item_rhs] in items({',,': '<<', ';b': 'std::begin', ';c': 'std::cout', ';e': 'std::end', ';m': 'std::map', ';s': 'std::string', ';v': 'std::vector'})
          lhs = item_lhs
          rhs = item_rhs
          LocalMap('i', lhs, rhs, v:true)
        endfor
        LocalMap('i', ';;', '::')
      endif
    endif
  endif
  if index(['dockerfile', 'python', 'qmake'], ft) >= 0
    LocalSet('expandtab', 1)
    LocalSet('tabstop', 4)
    LocalSet('shiftwidth', 4)
  endif
  if index(['help', 'markdown', 'text'], ft) >= 0
    LocalSet('colorcolumn', '+0')
  endif
  if ft ==# 'markdown'
    LocalMap('n', '<A-t>', '<Cmd>Vista!! toc<CR>')
    # Vim's Markdown ftplugin supplies its folding expression when enabled.
    if !empty(&foldexpr) && &foldexpr !=# '0'
      LocalSet('foldmethod', 'expr')
    endif
  elseif ft ==# 'sh'
    LocalSet('formatoptions', &formatoptions .. 'croql')
    LocalSet('include', '^\s*\%(\.\|source\)\s')
    LocalSet('define', '\<\%(\i\+\s*()\)\@=')
  elseif ft ==# 'text'
    LocalSet('textwidth', 72)
    LocalSet('linebreak', 1)
    LocalSet('breakindent', 1)
    LocalSet('complete', &complete .. ',k,s')
    LocalSet('spell', 1)
  elseif ft ==# 'vim'
    LocalSet('foldmethod', 'marker')
    LocalSet('foldlevel', 0)
  endif
  if index(['text', 'markdown'], ft) >= 0 && stridx(&formatoptions, 't') < 0
    LocalSet('formatoptions', &formatoptions .. 't')
  endif
  if empty(&omnifunc)
    LocalSet('omnifunc', 'syntaxcomplete#Complete')
  endif
  if empty(&completefunc)
    LocalSet('completefunc', 'syntaxcomplete#Complete')
  endif
  return 0
enddef
