function! calculator#token#Init() abort
  " special
  let g:calculator_token_EndOfFile =           1
  let g:calculator_token_Goto =                2
  let g:calculator_token_IfNotGoto =           3
  " tokens
  let g:calculator_token_Add =                 1001
  let g:calculator_token_Assign =              1002
  let g:calculator_token_Colon =               1003
  let g:calculator_token_Comma =               1004
  let g:calculator_token_Divide =              1005
  let g:calculator_token_Equal =               1006
  let g:calculator_token_GreaterThanEqual =    1007
  let g:calculator_token_GreaterThan =         1008
  let g:calculator_token_LeftBrace =           1009
  let g:calculator_token_LeftBracket =         1010
  let g:calculator_token_LeftParenthesis =     1011
  let g:calculator_token_LessThan =            1012
  let g:calculator_token_LessThanEqual =       1013
  let g:calculator_token_Modulus =             1014
  let g:calculator_token_Multiply =            1015
  let g:calculator_token_NotEqual =            1016
  let g:calculator_token_RightBrace =          1017
  let g:calculator_token_RightBracket =        1018
  let g:calculator_token_RightParenthesis =    1019
  let g:calculator_token_Semicolon =           1020
  let g:calculator_token_Subtract =            1021
  let g:calculator_token_UnaryAdd =            1022
  let g:calculator_token_UnarySubtract =       1023
  " keywords
  let g:calculator_token_And =                 2001
  let g:calculator_token_Call =                2002
  let g:calculator_token_Case =                2003
  let g:calculator_token_Default =             2004
  let g:calculator_token_Else =                2005
  let g:calculator_token_Function =            2006
  let g:calculator_token_If =                  2007
  let g:calculator_token_Not =                 2008
  let g:calculator_token_Or =                  2009
  let g:calculator_token_Return =              2010
  let g:calculator_token_Switch =              2011
  let g:calculator_token_While =               2012
  " functions
  let g:calculator_token_Abs =                 3001
  let g:calculator_token_Acos =                3002
  let g:calculator_token_Asin =                3003
  let g:calculator_token_Atan =                3004
  let g:calculator_token_Atan2 =               3005
  let g:calculator_token_Ceil =                3006
  let g:calculator_token_Choose =              3007
  let g:calculator_token_Cos =                 3008
  let g:calculator_token_Cosh =                3009
  let g:calculator_token_Deg =                 3010
  let g:calculator_token_Exp =                 3011
  let g:calculator_token_Floor =               3012
  let g:calculator_token_Hypot =               3013
  let g:calculator_token_Inv =                 3014
  let g:calculator_token_Ldexp =               3015
  let g:calculator_token_Lg =                  3016
  let g:calculator_token_Ln =                  3017
  let g:calculator_token_Log =                 3018
  let g:calculator_token_Log10 =               3019
  let g:calculator_token_Max =                 3020
  let g:calculator_token_Min =                 3021
  let g:calculator_token_Nrt =                 3022
  let g:calculator_token_Perms =               3023
  let g:calculator_token_Pow =                 3024
  let g:calculator_token_Rad =                 3025
  let g:calculator_token_Rand =                3026
  let g:calculator_token_Round =               3027
  let g:calculator_token_Sin =                 3028
  let g:calculator_token_Sinh =                3029
  let g:calculator_token_Sqrt =                3030
  let g:calculator_token_Tan =                 3031
  let g:calculator_token_Tanh =                3032
  let g:calculator_token_Hex =                 3033
  let g:calculator_token_Oct =                 3034
  let g:calculator_token_Bin =                 3035
  let g:calculator_token_Dec =                 3036
  let g:calculator_token_Int =                 3037
  let g:calculator_token_Float =               3038
  let g:calculator_token_Status =              3039
  let g:calculator_token_Vars =                3040
  " values
  let g:calculator_token_Name =                5001
  let g:calculator_token_Value =               5002

  " make all tokens constant
  lockvar g:calculator_token_EndOfFile
  lockvar g:calculator_token_Goto
  lockvar g:calculator_token_IfNotGoto
  lockvar g:calculator_token_Add
  lockvar g:calculator_token_Assign
  lockvar g:calculator_token_Colon
  lockvar g:calculator_token_Comma
  lockvar g:calculator_token_Divide
  lockvar g:calculator_token_Equal
  lockvar g:calculator_token_GreaterThanEqual
  lockvar g:calculator_token_GreatorThan
  lockvar g:calculator_token_LeftBrace
  lockvar g:calculator_token_LeftBracket
  lockvar g:calculator_token_LeftParenthesis
  lockvar g:calculator_token_LessThan
  lockvar g:calculator_token_LessThanEqual
  lockvar g:calculator_token_Modulus
  lockvar g:calculator_token_Multiply
  lockvar g:calculator_token_NotEqual
  lockvar g:calculator_token_RightBrace
  lockvar g:calculator_token_RightBracket
  lockvar g:calculator_token_RightParenthesis
  lockvar g:calculator_token_Semicolon
  lockvar g:calculator_token_Subtract
  lockvar g:calculator_token_UnaryAdd
  lockvar g:calculator_token_UnarySubtract
  lockvar g:calculator_token_And
  lockvar g:calculator_token_Call
  lockvar g:calculator_token_Case
  lockvar g:calculator_token_Default
  lockvar g:calculator_token_Else
  lockvar g:calculator_token_Function
  lockvar g:calculator_token_If
  lockvar g:calculator_token_Not
  lockvar g:calculator_token_Or
  lockvar g:calculator_token_Return
  lockvar g:calculator_token_Switch
  lockvar g:calculator_token_While
  lockvar g:calculator_token_Abs
  lockvar g:calculator_token_Acos
  lockvar g:calculator_token_Asin
  lockvar g:calculator_token_Atan
  lockvar g:calculator_token_Atan2
  lockvar g:calculator_token_Ceil
  lockvar g:calculator_token_Choose
  lockvar g:calculator_token_Cos
  lockvar g:calculator_token_Cosh
  lockvar g:calculator_token_Deg
  lockvar g:calculator_token_Exp
  lockvar g:calculator_token_Floor
  lockvar g:calculator_token_Hypot
  lockvar g:calculator_token_Inv
  lockvar g:calculator_token_Ldexp
  lockvar g:calculator_token_Lg
  lockvar g:calculator_token_Ln
  lockvar g:calculator_token_Log
  lockvar g:calculator_token_Log10
  lockvar g:calculator_token_Max
  lockvar g:calculator_token_Min
  lockvar g:calculator_token_Nrt
  lockvar g:calculator_token_Perms
  lockvar g:calculator_token_Pow
  lockvar g:calculator_token_Rad
  lockvar g:calculator_token_Rand
  lockvar g:calculator_token_Round
  lockvar g:calculator_token_Sin
  lockvar g:calculator_token_Sinh
  lockvar g:calculator_token_Sqrt
  lockvar g:calculator_token_Tan
  lockvar g:calculator_token_Tanh
  lockvar g:calculator_token_Hex
  lockvar g:calculator_token_Oct
  lockvar g:calculator_token_Bin
  lockvar g:calculator_token_Dec
  lockvar g:calculator_token_Int
  lockvar g:calculator_token_Float
  lockvar g:calculator_token_Status
  lockvar g:calculator_token_Vars
  lockvar g:calculator_token_Name
  lockvar g:calculator_token_Value
endfunction

" id must be one of g:calculator_token_* variables
" name_or_value is one of {} or { 'name': 'var_name' } or { 'value': ...}
function! calculator#token#Create(token_id, name_or_value) abort
  let l:new_token = { 'id': a:token_id }
  if empty(a:name_or_value)
    return l:new_token
  elseif has_key(a:name_or_value, 'name')
    let l:new_token.name = a:name_or_value.name
    return l:new_token
  elseif has_key(a:name_or_value, 'value')
    let l:new_token.value = a:name_or_value.value
    return l:new_token
  else
    let l:new_token.name_or_value = name_or_value
    call calculator#error#InternalError('Wrong Token: ' . string(l:new_token))
  endif
endfunction
