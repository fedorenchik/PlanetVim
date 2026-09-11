vim9script

export def Action(action: string): number
  if &filetype !=# 'fern'
    echom 'PlanetVim: open the file manager and select a node before using this action'
    return 0
  endif
  if index(['preview', 'expand-tree:stay', 'collapse', 'clipboard-paste-confirm'], action) < 0
    throw 'PlanetVim: unknown file manager action: ' .. action
  endif
  feedkeys("\<Plug>(fern-action-" .. action .. ')', 'm')
  return 1
enddef
