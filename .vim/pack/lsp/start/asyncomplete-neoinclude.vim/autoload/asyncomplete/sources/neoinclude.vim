function! asyncomplete#sources#neoinclude#completor(opt, ctx)
    let l:typed = a:ctx['typed']
    let l:startcol = neoinclude#file_include#get_complete_position(l:typed)
    let l:matches = neoinclude#file_include#get_include_files(l:typed)
    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol+1, l:matches)
endfunction

function! asyncomplete#sources#neoinclude#get_source_options(opts)
   return a:opts
endfunction
