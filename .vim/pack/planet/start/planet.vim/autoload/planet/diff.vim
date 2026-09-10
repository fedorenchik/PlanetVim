scriptversion 4

func! planet#diff#Option(key, value) abort
  let l:values = filter(split(&diffopt, ','), {_, v -> v !=# a:key && stridx(v, a:key .. ':') != 0})
  if a:value isnot v:null
    call add(l:values, a:key .. (empty(a:value) ? '' : ':' .. a:value))
  endif
  let &diffopt = join(l:values, ',')
  return 1
endfunc

func! planet#diff#Context(...) abort
  let l:value = a:0 ? a:1 : planet#prompt#Ask('Diff context lines: ', matchstr(&diffopt, 'context:\zs\d\+'))
  if l:value is v:null || empty(l:value) | return 0 | endif
  if l:value !~# '^\d\+$'
    echom 'PlanetVim: enter a nonnegative number of context lines.'
    return 0
  endif
  return planet#diff#Option('context', l:value)
endfunc
