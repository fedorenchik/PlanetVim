scriptversion 4

func! planet#display#Popup(key, value) abort
  if !exists('+pumopt') | return planet#prompt#Unavailable('completion popup appearance', "'pumopt'") | endif
  if index(['border', 'opacity'], a:key) < 0 | throw 'PlanetVim: invalid popup setting' | endif
  let l:flags = filter(split(&pumopt, ','), {_, value -> stridx(value, a:key .. ':') != 0})
  if !empty(a:value) | call add(l:flags, a:key .. ':' .. a:value) | endif
  return planet#preferences#Set('pumopt', join(l:flags, ','))
endfunc

func! planet#display#Padding() abort
  if !exists('+scrolloffpad') | return planet#prompt#Unavailable('cursor padding at file boundaries', "'scrolloffpad'") | endif
  call planet#preferences#Set('scrolloffpad', &scrolloffpad > 0 ? 0 : 1, 1)
  if &scrolloffpad > 0 && &scrolloff == 0 | setlocal scrolloff=2 | endif
endfunc

func! planet#display#Click(info) abort
  if get(a:info, 'button', '') ==# 'l' && win_gotoid(get(a:info, 'winid', 0))
    call planet#actions#Open()
  endif
  return 0
endfunc

func! planet#display#Status(kind) abort
  if a:kind ==# 'restore'
    if exists('w:PV_display_status')
      let &l:statusline = w:PV_display_status.line
      if exists('+statuslineopt') | let &l:statuslineopt = w:PV_display_status.options | endif
      unlet w:PV_display_status
    endif
    return 1
  endif
  if index(['multiline', 'clickable'], a:kind) < 0 | throw 'PlanetVim: invalid status-line preset' | endif
  if a:kind ==# 'multiline' && !exists('+statuslineopt') | return planet#prompt#Unavailable('multiline status lines', "'statuslineopt'") | endif
  if a:kind ==# 'clickable' && !has('statusline_click') | return planet#prompt#Unavailable('clickable status lines', 'stl-%[FuncName]') | endif
  if !exists('w:PV_display_status')
    let w:PV_display_status = #{line: &l:statusline, options: exists('+statuslineopt') ? &l:statuslineopt : ''}
  endif
  let &l:statusline = '%f %h%m%r%=%l:%c %P'
  if a:kind ==# 'multiline'
    let &l:statuslineopt = 'maxheight:2'
    let &l:statusline ..= '%@%y %{&fileencoding} %{&fileformat}'
  else
    if exists('+statuslineopt') | let &l:statuslineopt = 'maxheight:1' | endif
    let &l:statusline = '%[planet#display#Click] Find Menu Action %[] ' .. &l:statusline
  endif
  return 1
endfunc

func! planet#display#Menus(group) abort
  if a:group ==# 'basic'
    an 170.18 📺&v.Image\ Preview.Open\ Local\ Image <Cmd>call planet#image#Open()<CR>
    an 170.18 📺&v.Image\ Preview.Close <Cmd>call planet#image#Close()<CR>
    an 170.18 📺&v.Image\ Preview.Help <Cmd>help popup-image<CR>
  else
    an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.Rounded\ Border <Cmd>call planet#display#Popup('border', 'round')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.No\ Border <Cmd>call planet#display#Popup('border', '')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.Opacity\ 85% <Cmd>call planet#display#Popup('opacity', '85')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Completion\ Popup.Opaque <Cmd>call planet#display#Popup('opacity', '100')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Toggle\ Cursor\ Padding <Cmd>call planet#display#Padding()<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Two\ Lines\ (this\ window) <Cmd>call planet#display#Status('multiline')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Clickable\ Actions\ (this\ window) <Cmd>call planet#display#Status('clickable')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Restore <Cmd>call planet#display#Status('restore')<CR>
    an 970.65 ⚙️&\\.Advanced\ Display.Status\ Line.Help <Cmd>help status-line<CR>
  endif
endfunc
