function! calculator#constant#Init() abort
  let g:calculator_constant_e = 2.7182818284590452353602874713527
  let g:calculator_constant_pi = 3.1415926535897932384626433
  let g:calculator_constant_phi = 1.61803398874989484820

  lockvar g:calculator_constant_e
  lockvar g:calculator_constant_pi
  lockvar g:calculator_constant_phi
endfunction
