" name_list should be list of strings: [ 'abc', 'def' ]
" address should be Number
function! calculator#function#Create(name_list, address) abort
  return { 'name_list': a:name_list, 'address': a:address }
endfunction
