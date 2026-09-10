vim9script

var script_state: dict<any> = {}

export def Encoding(action: any, arg_encoding: any = v:null): any
  var names: any
  var encoding: any = arg_encoding == null ? planet#prompt#Ask(action ==# 'reopen' ? 'Reopen using encoding: ' : 'Encoding for next save: ',
       empty(&l:fileencoding) ? &encoding : &l:fileencoding) : arg_encoding
  if encoding == null || empty(encoding)
    return 0
  endif
  if encoding !~# '^[-a-zA-Z0-9_]\+$'
    echomsg 'PlanetVim: invalid encoding name'
    return 0
  endif
  if !has_key(script_state, 'encodings')
    script_state.encodings = ['utf8', 'utf16', 'utf16le', 'utf16be', 'ucs2', 'ucs2le', 'ucs4', 'ucs4le', 'latin1', 'ascii']
    if executable('iconv')
      names = split(system('iconv -l'))
      if v:shell_error == 0
        extend(script_state.encodings, map(names, (_, lambda_v) => substitute(tolower(lambda_v), '[-_/]', '', 'g')))
      endif
    endif
  endif
  if index(script_state.encodings, substitute(tolower(encoding), '[-_]', '', 'g')) < 0
    echomsg 'PlanetVim: this build cannot convert to ' .. encoding
    return 0
  endif
  if action ==# 'reopen'
    return planet#recovery#Reload(encoding)
  endif
  if action !=# 'save'
    throw 'PlanetVim: unknown encoding action'
  endif
  &l:fileencoding = encoding
  echomsg 'PlanetVim: the next save will use ' .. &l:fileencoding .. '; the file has not been written yet'
  return 1
enddef

export def Filetype(arg_value: any = v:null): any
  var value: any = arg_value == null ? planet#prompt#Ask('Filetype for this buffer: ', &l:filetype, 'filetype') : arg_value
  if value == null
    return 0
  endif
  if !empty(value) && index(getcompletion('', 'filetype'), value) < 0
    echomsg 'PlanetVim: choose an installed filetype'
    return 0
  endif
  &l:filetype = value
  return 1
enddef

export def Indent(option: any, arg_value: any = v:null): any
  if index(['tabstop', 'shiftwidth', 'softtabstop', 'textwidth'], option) < 0
    throw 'PlanetVim: invalid indentation option'
  endif
  var value: any = arg_value == null ? planet#prompt#Ask(option .. ' for this buffer: ', string(eval('&l:' .. option))) : string(arg_value)
  if value == null || empty(value)
    return 0
  endif
  if value !~# '^\d\+$' || (option ==# 'tabstop' && str2nr(value) == 0)
    echomsg 'PlanetVim: enter a nonnegative number (tabstop must be positive)'
    return 0
  endif
  return planet#preferences#Set(option, str2nr(value), 1)
enddef

export def Menus(group: any): any
  var option: any
  if group ==# 'basic'
    PlanetMenu an 110.186 📁&f.Encoding.Reopen\ As <Cmd>call planet#buffer_options#Encoding('reopen')<CR>
    PlanetMenu an 110.186 📁&f.Encoding.Encoding\ for\ Next\ Save <Cmd>call planet#buffer_options#Encoding('save')<CR>
    PlanetMenu an 110.186 📁&f.Encoding.Toggle\ BOM <Cmd>call planet#preferences#Toggle('bomb', 1)<CR>
    PlanetMenu an 110.186 📁&f.Encoding.Current\ Encoding <Cmd>setlocal fileencoding? bomb? fileformat?<CR>
    PlanetMenu an 110.186 📁&f.Encoding.Help <Cmd>help 'fileencoding'<CR>
  elseif group ==# 'settings'
    PlanetMenu an 900.55 ⚙️&\\.Buffer.Filetype <Cmd>call planet#buffer_options#Filetype()<CR>
    for [label, item_option] in [['End-of-file newline', 'endofline'], ['Ensure final newline on save', 'fixendofline'], ['Read only', 'readonly'], ['Show whitespace', 'list'], ['Expand tabs to spaces', 'expandtab'], ['Auto indent', 'autoindent'], ['Preserve indent', 'preserveindent']]
      option = item_option
      execute 'PlanetMenu anoremenu 900.55 ⚙️&\\.Buffer.Toggle\ ' .. escape(label, ' ') .. " <Cmd>call planet#preferences#Toggle('" .. option .. "', 1)<CR>"
    endfor
    for item_option in ['tabstop', 'shiftwidth', 'softtabstop', 'textwidth']
      option = item_option
      execute 'PlanetMenu anoremenu 900.55 ⚙️&\\.Buffer.Indentation.' .. option .. " <Cmd>call planet#buffer_options#Indent('" .. option .. "')<CR>"
    endfor
    PlanetMenu an 900.55 ⚙️&\\.Buffer.Current\ Values <Cmd>setlocal filetype? fileencoding? fileformat? endofline? fixendofline? readonly? list? expandtab? tabstop? shiftwidth? softtabstop?<CR>
  endif
  return 0
enddef
