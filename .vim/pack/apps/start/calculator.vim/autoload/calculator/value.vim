let g:calculator_value_TypeVoid =            v:t_none
let g:calculator_value_TypeNumerical =       v:t_float
let g:calculator_value_TypeBoolean =         v:t_bool
let g:calculator_value_TypeString =          v:t_string
lockvar g:calculator_value_TypeVoid
lockvar g:calculator_value_TypeNumerical
lockvar g:calculator_value_TypeBoolean
lockvar g:calculator_value_TypeString

" data is one of:
" * {}
" * { 'numerical_value': Float }
" * { 'boolean_value': v:true or v:false }
" * { 'string_value': String }
function! calculator#value#Create(data) abort
  let l:value = { 'type_id': g:calculator_value_TypeVoid }
  if has_key(a:data, 'numerical_value')
    let l:value.type_id = g:calculator_value_TypeNumerical
    let l:value.numerical_value = a:data.numerical_value
  elseif has_key(a:data, 'boolean_value')
    let l:value.type_id = g:calculator_value_TypeBoolean
    let l:value.boolean_value = a:data.boolean_value
  elseif has_key(a:data, 'string_value')
    let l:value.type_id = g:calculator_value_TypeString
    let l:value.string_value = a:data.string_value
  else
    call calculator#error#InternalError('Wrong Value: ' . string(a:data))
  endif
  return l:value
endfunction
