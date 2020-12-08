let s:initialized = 0
function! asyncomplete#sources#necosyntax#completor(opt, ctx)
    if !s:initialized
        call necosyntax#initialize()
        let s:initialized = 1
    endif

    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']

    let l:kw = matchstr(l:typed, '\w\+$')
    let l:kwlen = len(l:kw)

    let l:matches = map(necosyntax#gather_candidates(),'{"word":v:val,"dup":1,"icase":1,"menu": "[Syntax]"}')
    let l:startcol = l:col - l:kwlen

    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! asyncomplete#sources#necosyntax#get_source_options(opts)
   return a:opts
endfunction
