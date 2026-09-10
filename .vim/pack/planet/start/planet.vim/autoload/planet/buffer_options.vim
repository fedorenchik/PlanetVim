scriptversion 4

func! planet#buffer_options#Encoding(action, encoding = v:null) abort
  let l:encoding = a:encoding is v:null ? planet#prompt#Ask(a:action ==# 'reopen' ? 'Reopen using encoding: ' : 'Encoding for next save: ', empty(&l:fileencoding) ? &encoding : &l:fileencoding) : a:encoding
  if l:encoding is v:null || empty(l:encoding) | return 0 | endif
  if l:encoding !~# '^[-a-zA-Z0-9_]\+$' | echomsg 'PlanetVim: invalid encoding name' | return 0 | endif
  if !exists('s:encodings')
    let s:encodings = ['utf8', 'utf16', 'utf16le', 'utf16be', 'ucs2', 'ucs2le', 'ucs4', 'ucs4le', 'latin1', 'ascii']
    if executable('iconv')
      let l:names = split(system('iconv -l'))
      if v:shell_error == 0
        call extend(s:encodings, map(l:names, {_, v -> substitute(tolower(v), '[-_/]', '', 'g')}))
      endif
    endif
  endif
  if index(s:encodings, substitute(tolower(l:encoding), '[-_]', '', 'g')) < 0
    echomsg 'PlanetVim: this build cannot convert to ' .. l:encoding
    return 0
  endif
  if a:action ==# 'reopen' | return planet#recovery#Reload(l:encoding) | endif
  if a:action !=# 'save' | throw 'PlanetVim: unknown encoding action' | endif
  let &l:fileencoding = l:encoding
  echomsg 'PlanetVim: the next save will use ' .. &l:fileencoding .. '; the file has not been written yet'
  return 1
endfunc

func! planet#buffer_options#Filetype(value = v:null) abort
  let l:value = a:value is v:null ? planet#prompt#Ask('Filetype for this buffer: ', &l:filetype, 'filetype') : a:value
  if l:value is v:null | return 0 | endif
  if !empty(l:value) && index(getcompletion('', 'filetype'), l:value) < 0
    echomsg 'PlanetVim: choose an installed filetype'
    return 0
  endif
  let &l:filetype = l:value
  return 1
endfunc

func! planet#buffer_options#Indent(option, value = v:null) abort
  if index(['tabstop', 'shiftwidth', 'softtabstop', 'textwidth'], a:option) < 0 | throw 'PlanetVim: invalid indentation option' | endif
  let l:value = a:value is v:null ? planet#prompt#Ask(a:option .. ' for this buffer: ', string(eval('&l:' .. a:option))) : string(a:value)
  if l:value is v:null || empty(l:value) | return 0 | endif
  if l:value !~# '^\d\+$' || (a:option ==# 'tabstop' && str2nr(l:value) == 0)
    echomsg 'PlanetVim: enter a nonnegative number (tabstop must be positive)'
    return 0
  endif
  return planet#preferences#Set(a:option, str2nr(l:value), 1)
endfunc

func! planet#buffer_options#Menus(group) abort
  if a:group ==# 'basic'
    an 110.186 📁&f.Encoding.Reopen\ As <Cmd>call planet#buffer_options#Encoding('reopen')<CR>
    an 110.186 📁&f.Encoding.Encoding\ for\ Next\ Save <Cmd>call planet#buffer_options#Encoding('save')<CR>
    an 110.186 📁&f.Encoding.Toggle\ BOM <Cmd>call planet#preferences#Toggle('bomb', 1)<CR>
    an 110.186 📁&f.Encoding.Current\ Encoding <Cmd>setlocal fileencoding? bomb? fileformat?<CR>
    an 110.186 📁&f.Encoding.Help <Cmd>help 'fileencoding'<CR>
  elseif a:group ==# 'settings'
    an 900.55 ⚙️&\\.Buffer.Filetype <Cmd>call planet#buffer_options#Filetype()<CR>
    for [l:label, l:option] in [['End-of-file newline', 'endofline'], ['Ensure final newline on save', 'fixendofline'], ['Read only', 'readonly'], ['Show whitespace', 'list'], ['Expand tabs to spaces', 'expandtab'], ['Auto indent', 'autoindent'], ['Preserve indent', 'preserveindent']]
      execute 'anoremenu 900.55 ⚙️&\\.Buffer.Toggle\ ' .. escape(l:label, ' ') .. " <Cmd>call planet#preferences#Toggle('" .. l:option .. "', 1)<CR>"
    endfor
    for l:option in ['tabstop', 'shiftwidth', 'softtabstop', 'textwidth']
      execute 'anoremenu 900.55 ⚙️&\\.Buffer.Indentation.' .. l:option .. " <Cmd>call planet#buffer_options#Indent('" .. l:option .. "')<CR>"
    endfor
    an 900.55 ⚙️&\\.Buffer.Current\ Values <Cmd>setlocal filetype? fileencoding? fileformat? endofline? fixendofline? readonly? list? expandtab? tabstop? shiftwidth? softtabstop?<CR>
  endif
endfunc
