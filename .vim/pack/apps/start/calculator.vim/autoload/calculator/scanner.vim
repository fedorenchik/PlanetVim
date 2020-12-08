let s:buffer = ''
let s:value_map = {}
let s:keyword_map = {}
let s:token_list = []
let s:had_newline = v:false

function! calculator#scanner#Init() abort
  " tokens
  call add(s:token_list, [ '+', g:calculator_token_Add ] )
  call add(s:token_list, [ '-', g:calculator_token_Subtract ] )
  call add(s:token_list, [ '*', g:calculator_token_Multiply ] )
  call add(s:token_list, [ '/', g:calculator_token_Divide ] )
  call add(s:token_list, [ '%', g:calculator_token_Modulus ] )
  call add(s:token_list, [ '==', g:calculator_token_Equal ] )
  call add(s:token_list, [ '!=', g:calculator_token_NotEqual ] )
  call add(s:token_list, [ '<=', g:calculator_token_LessThanEqual ] )
  call add(s:token_list, [ '<', g:calculator_token_LessThan ] )
  call add(s:token_list, [ '>=', g:calculator_token_GreaterThanEqual ] )
  call add(s:token_list, [ '>', g:calculator_token_GreaterThan ] )
  call add(s:token_list, [ '(', g:calculator_token_LeftParenthesis ] )
  call add(s:token_list, [ ')', g:calculator_token_RightParenthesis ] )
  call add(s:token_list, [ '{', g:calculator_token_LeftBrace ] )
  call add(s:token_list, [ '}', g:calculator_token_RightBrace ] )
  call add(s:token_list, [ '[', g:calculator_token_LeftBracket ] )
  call add(s:token_list, [ ']', g:calculator_token_RightBracket ] )
  call add(s:token_list, [ '=', g:calculator_token_Assign ] )
  call add(s:token_list, [ ',', g:calculator_token_Comma ] )
  call add(s:token_list, [ ';', g:calculator_token_Semicolon ] )
  call add(s:token_list, [ ':', g:calculator_token_Colon ] )
  call add(s:token_list, [ '&&', g:calculator_token_And ] )
  call add(s:token_list, [ '||', g:calculator_token_Or ] )
  call add(s:token_list, [ '!', g:calculator_token_Not ] )
  lockvar s:token_list

  " keywords
  let s:keyword_map['and'] = g:calculator_token_And
  let s:keyword_map['call'] = g:calculator_token_Call
  let s:keyword_map['case'] = g:calculator_token_Case
  let s:keyword_map['default'] = g:calculator_token_Default
  let s:keyword_map['else'] = g:calculator_token_Else
  let s:keyword_map['function'] = g:calculator_token_Function
  let s:keyword_map['if'] = g:calculator_token_If
  let s:keyword_map['not'] = g:calculator_token_Not
  let s:keyword_map['or'] = g:calculator_token_Or
  let s:keyword_map['return'] = g:calculator_token_Return
  let s:keyword_map['switch'] = g:calculator_token_Switch
  let s:keyword_map['while'] = g:calculator_token_While

  " functions
  let s:keyword_map['abs'] = g:calculator_token_Abs
  let s:keyword_map['acos'] = g:calculator_token_Acos
  let s:keyword_map['asin'] = g:calculator_token_Asin
  let s:keyword_map['atan'] = g:calculator_token_Atan
  let s:keyword_map['atan2'] = g:calculator_token_Atan2
  let s:keyword_map['ceil'] = g:calculator_token_Ceil
  let s:keyword_map['choose'] = g:calculator_token_Choose
  let s:keyword_map['cos'] = g:calculator_token_Cos
  let s:keyword_map['cosh'] = g:calculator_token_Cosh
  let s:keyword_map['deg'] = g:calculator_token_Deg
  let s:keyword_map['exp'] = g:calculator_token_Exp
  let s:keyword_map['floor'] = g:calculator_token_Floor
  let s:keyword_map['hypot'] = g:calculator_token_Hypot
  let s:keyword_map['inv'] = g:calculator_token_Inv
  let s:keyword_map['ldexp'] = g:calculator_token_Ldexp
  let s:keyword_map['lg'] = g:calculator_token_Lg
  let s:keyword_map['ln'] = g:calculator_token_Ln
  let s:keyword_map['log'] = g:calculator_token_Log
  let s:keyword_map['log10'] = g:calculator_token_Log10
  let s:keyword_map['max'] = g:calculator_token_Max
  let s:keyword_map['min'] = g:calculator_token_Min
  let s:keyword_map['nrt'] = g:calculator_token_Nrt
  let s:keyword_map['perms'] = g:calculator_token_Perms
  let s:keyword_map['pow'] = g:calculator_token_Pow
  let s:keyword_map['rad'] = g:calculator_token_Rad
  let s:keyword_map['rand'] = g:calculator_token_Rand
  let s:keyword_map['round'] = g:calculator_token_Round
  let s:keyword_map['sin'] = g:calculator_token_Sin
  let s:keyword_map['sinh'] = g:calculator_token_Sinh
  let s:keyword_map['sqrt'] = g:calculator_token_Sqrt
  let s:keyword_map['tan'] = g:calculator_token_Tan
  let s:keyword_map['tanh'] = g:calculator_token_Tanh

  let s:keyword_map['hex'] = g:calculator_token_Hex
  let s:keyword_map['oct'] = g:calculator_token_Oct
  let s:keyword_map['bin'] = g:calculator_token_Bin
  let s:keyword_map['dec'] = g:calculator_token_Dec
  let s:keyword_map['int'] = g:calculator_token_Int
  let s:keyword_map['float'] = g:calculator_token_Float
  let s:keyword_map['status'] = g:calculator_token_Status
  let s:keyword_map['vars'] = g:calculator_token_Vars
  lockvar s:keyword_map

  " constants
  let s:value_map['true'] = v:true
  let s:value_map['false'] = v:false
  let s:value_map['e'] = g:calculator_constant_e
  let s:value_map['pi'] = g:calculator_constant_pi
  let s:value_map['phi'] = g:calculator_constant_phi
  lockvar s:value_map
endfunction

function! calculator#scanner#HadNewline() abort
  return s:had_newline
endfunction

function! calculator#scanner#Start(text) abort
  let s:buffer = a:text
  let s:buffer ..= "\0"
endfunction

function! calculator#scanner#NextToken() abort
  let s:had_newline = v:false
  while v:true
    if s:buffer[0] == '\n'
      let g:calculator_error_LineNo += 1
      let s:buffer = strpart(s:buffer, 1)
      let s:had_newline = v:true
    elseif s:buffer[0] =~ '\s'
      let s:buffer = substitute(s:buffer, '\s*', '', '')
    elseif s:buffer[0] == '#'
      let s:buffer = substitute(s:buffer, '#.\{-}$', '', '')
    else
      break
    endif
  endwhile

  if s:buffer[0] == "\0"
    let s:had_newline = v:true
    return calculator#token#Create(g:calculator_token_EndOfFile, {})
  endif

  for [t, i] in s:token_list
    if match(s:buffer, t) == 0
      let s:buffer = strpart(s:buffer, strchars(t))
      return calculator#token#Create(i, {})
    endif
  endfor

  if match(s:buffer, '^[[:alpha:]_]') == 0
    let l:word = matchstr(s:buffer, '^[[:alnum:]_]\+')
    let s:buffer = strpart(s:buffer, strchars(l:word))
    if has_key(s:keyword_map, l:word)
      return calculator#token#Create(s:keyword_map[l:word], {})
    elseif has_key(s:value_map, l:word)
      if type(s:value_map[l:word]) == v:t_float
        return calculator#token#Create(g:calculator_token_Value,
              \ { 'value': calculator#value#Create({ 'numerical_value':
              \ s:value_map[l:word] }) })
      elseif type(s:value_map[l:word]) == v:t_bool
        return calculator#token#Create(g:calculator_token_Value,
              \ { 'value': calculator#value#Create({ 'boolean_value':
              \ s:value_map[l:word] }) })
      endif
    else
      return calculator#token#Create(g:calculator_token_Name,
            \ { 'name': l:word })
    endif
  endif

  if match(s:buffer, '^"') == 0
    let s:buffer = strpart(s:buffer, 1)
    if match(s:buffer, '"') == -1
      call calculator#error#SyntaxError('unfinished string')
    endif
    let l:length = match(s:buffer, '"')
    let l:string = strpart(s:buffer, 0, l:length)
    let s:buffer = strpart(s:buffer, l:length + 1)
    return calculator#token#Create(g:calculator_token_Value,
          \ { 'value': calculator#value#Create({ 'string_value': l:string }) })
  endif

  if match(s:buffer, '^[[:digit:]]') == 0
    let l:digit_str = matchstr(s:buffer, '^[[:digit:]]\+\.\?[[:digit:]]*')
    let s:buffer = strpart(s:buffer, strchars(l:digit_str))
    return calculator#token#Create(g:calculator_token_Value,
          \ { 'value': calculator#value#Create({ 'numerical_value':
          \ str2float(l:digit_str) }) })
  endif

  call calculator#error#SyntaxError('Unknown token: ' ..
        \ strpart(s:buffer, 0, 5) .. '...')
endfunction
