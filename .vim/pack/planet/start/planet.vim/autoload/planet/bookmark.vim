vim9script

# Bookmarks use native A-Z file marks and Vim's existing viminfo persistence.
export def Items(): list<dict<any>>
  return sort(filter(getmarklist(), (_, mark) => mark.mark =~# "^'[A-Z]$"),
    (a, b) => char2nr(a.mark[1]) - char2nr(b.mark[1]))
enddef

def Validate(name: string)
  if name !~# '^[A-Z]$'
    throw 'PlanetVim: a bookmark name must be one uppercase letter, A-Z'
  endif
enddef

def Choose(title: string): string
  var marks = Items()
  var choice = planet#prompt#Choose(title, mapnew(marks, (_, mark) =>
    printf('%s  %s:%d:%d', mark.mark[1], fnamemodify(mark.file, ':~:.'), mark.pos[1], mark.pos[2])))
  return choice < 0 ? '' : marks[choice].mark[1]
enddef

export def Set(name: any = null, next_free: bool = false): string
  if empty(expand('%:p')) || &buftype !=# ''
    throw 'PlanetVim: bookmarks require a named file buffer'
  endif
  var free = ''
  var used = mapnew(Items(), (_, mark) => mark.mark[1])
  for letter in split('ABCDEFGHIJKLMNOPQRSTUVWXYZ', '\zs')
    if index(used, letter) < 0
      free = letter
      break
    endif
  endfor
  var chosen = name
  if chosen == null
    if next_free
      if empty(free)
        echom 'PlanetVim: all 26 bookmarks are in use; choose Set / Replace to reuse one'
        return ''
      endif
      chosen = free
    else
      chosen = planet#prompt#Ask('Set / replace bookmark (A-Z): ', free)
    endif
  endif
  if chosen == null || empty(chosen) | return '' | endif
  Validate(chosen)
  execute 'normal! m' .. chosen
  echom 'PlanetVim: bookmark ' .. chosen .. ' set'
  return chosen
enddef

export def Jump(name: any = null, linewise: bool = false): number
  var chosen = name == null ? Choose('Go to bookmark') : name
  if chosen == null || empty(chosen) | return 0 | endif
  Validate(chosen)
  # Native jumps retain jumplist, modified-buffer and unopened-file behavior.
  execute 'normal! ' .. (linewise ? "'" : '`') .. chosen
  normal! zv
  return 1
enddef

export def Delete(name: any = null): number
  var chosen = name == null ? Choose('Delete bookmark') : name
  if chosen == null || empty(chosen) | return 0 | endif
  Validate(chosen)
  execute 'delmarks ' .. chosen
  return 1
enddef

export def List(): number
  var entries: list<dict<any>> = []
  for mark in Items()
    add(entries, {filename: mark.file, lnum: mark.pos[1], col: mark.pos[2],
      text: 'Bookmark ' .. mark.mark[1]})
  endfor
  setloclist(0, [], ' ', {title: 'Bookmarks (A-Z file marks)', items: entries})
  if empty(entries)
    echom 'PlanetVim: no bookmarks set; use mA through mZ'
  else
    lopen
  endif
  return len(entries)
enddef
