let g:calculator_error_LineNo = 1

function! calculator#error#Error(message) abort
  throw 'calculator: ' .. a:message
endfunction

function! calculator#error#InternalError(message) abort
  call calculator#error#Error('Internal error: ' .. a:message .. '.')
endfunction

function! calculator#error#SyntaxError(message) abort
  call calculator#error#Error('Syntax error at line ' ..
        \ g:calculator_error_LineNo .. ': ' .. a:message .. '.')
endfunction

function! calculator#error#SemanticError(message) abort
  call calculator#error#Error('Semantic error: ' .. a:message .. '.')
endfunction

function! calculator#error#Check(condition, message) abort
  if !a:condition
    call calculator#error#SemanticError(a:message)
  endif
endfunction
