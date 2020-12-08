" data is one of:
" * {}
" * { 'address': Number }
" * { 'name': String }
" * { 'name': String, 'parameters': Number }
" * { 'value': ... }
" * { 'user_function': { ... returned by calculator#function#Create() } }
function! calculator#directive#Create(token_id, data) abort
  let l:directive = { 'directive_id': a:token_id }
  if empty(a:data)
    return l:directive
  endif
  if has_key(a:data, 'address')
    let l:directive.address = a:data.address
  endif
  if has_key(a:data, 'name')
    let l:directive.name = a:data.name
  endif
  if has_key(a:data, 'parameters')
    let l:directive.parameters = a:data.parameters
  endif
  if has_key(a:data, 'value')
    let l:directive.value = a:data.value
  endif
  if has_key(a:data, 'user_function')
    let l:directive.user_function = a:data.user_function
  endif
  return l:directive
endfunction
