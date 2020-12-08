let s:value_stack = []
let s:value_map = {}
let s:value_map_stack = []
let s:return_address_stack = []

function! calculator#evaluator#Start() abort
  let s:value_stack = []
  let s:value_map_stack = []
  let s:return_address_stack = []

  " call add(s:value_stack, string(g:calculator_parser_directive_list))

  let l:directive_index = 0

  while v:true
    if l:directive_index >= len(g:calculator_parser_directive_list)
      return s:value_stack
    endif
    let l:directive = g:calculator_parser_directive_list[l:directive_index]
    let l:directive_id = l:directive.directive_id

    if l:directive_id == g:calculator_token_Function
      let l:user_function = l:directive.user_function
      lockvar! l:user_function
      let l:name_list = l:user_function.name_list
      lockvar! l:name_list
      for list_index in range(len(l:name_list) - 1, 0, -1)
        let l:name = l:name_list[list_index]
        let s:value_map[l:name] = remove(s:value_stack, -1)
      endfor
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Call
      let l:name = l:directive.name
      call calculator#error#Check(has_key(
            \ g:calculator_parser_function_map, l:name),
            \ 'missing function: "' . l:name . '"')
      let l:user_function = g:calculator_parser_function_map[l:name]
      call calculator#error#Check(
            \ l:directive.parameters == len(l:user_function.name_list),
            \ 'invalid number of parameters')
      call add(s:return_address_stack, l:directive_index + 1)
      call add(s:value_map_stack, s:value_map)
      let s:value_map = {}
      let l:directive_index = l:user_function.address
    elseif l:directive_id == g:calculator_token_Return
      if !empty(s:return_address_stack)
        let s:value_map = remove(s:value_map_stack, -1)
        let l:directive_index = remove(s:return_address_stack, -1)
      else
        return s:value_stack
      endif
    elseif l:directive_id == g:calculator_token_IfNotGoto
      let l:value = remove(s:value_stack, -1)
      call calculator#evaluator#CheckType(g:calculator_token_IfNotGoto, l:value)
      if !l:value.boolean_value
        let l:directive_index = l:directive.address
      else
        let l:directive_index = l:directive_index + 1
      endif
    elseif l:directive_id == g:calculator_token_Goto
      let l:directive_index = l:directive.address
    elseif l:directive_id == g:calculator_token_Case
      let l:switch_var = s:value_map[l:directive.name]
      let l:value = remove(s:value_stack, -1)
      let l:result_value = calculator#evaluator#Evaluate2(
            \ g:calculator_token_Equal, l:switch_var, l:value)
      call add(s:value_stack, l:result_value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Abs ||
          \ l:directive_id == g:calculator_token_Acos ||
          \ l:directive_id == g:calculator_token_Asin ||
          \ l:directive_id == g:calculator_token_Atan ||
          \ l:directive_id == g:calculator_token_Ceil ||
          \ l:directive_id == g:calculator_token_Cos ||
          \ l:directive_id == g:calculator_token_Cosh ||
          \ l:directive_id == g:calculator_token_Deg ||
          \ l:directive_id == g:calculator_token_Exp ||
          \ l:directive_id == g:calculator_token_Floor ||
          \ l:directive_id == g:calculator_token_Inv ||
          \ l:directive_id == g:calculator_token_Lg ||
          \ l:directive_id == g:calculator_token_Ln ||
          \ l:directive_id == g:calculator_token_Log10 ||
          \ l:directive_id == g:calculator_token_Rad ||
          \ l:directive_id == g:calculator_token_Round ||
          \ l:directive_id == g:calculator_token_Sin ||
          \ l:directive_id == g:calculator_token_Sinh ||
          \ l:directive_id == g:calculator_token_Sqrt ||
          \ l:directive_id == g:calculator_token_Tan ||
          \ l:directive_id == g:calculator_token_Tanh ||
          \ l:directive_id == g:calculator_token_Hex ||
          \ l:directive_id == g:calculator_token_Oct ||
          \ l:directive_id == g:calculator_token_Bin ||
          \ l:directive_id == g:calculator_token_Dec ||
          \ l:directive_id == g:calculator_token_Int ||
          \ l:directive_id == g:calculator_token_Float
      let l:value = remove(s:value_stack, -1)
      call calculator#evaluator#CheckType(l:directive_id, l:value)
      let l:result_value =
            \ calculator#evaluator#Evaluate(l:directive_id, l:value)
      call add(s:value_stack, l:result_value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Atan2 ||
          \ l:directive_id == g:calculator_token_Choose ||
          \ l:directive_id == g:calculator_token_Hypot ||
          \ l:directive_id == g:calculator_token_Ldexp ||
          \ l:directive_id == g:calculator_token_Log ||
          \ l:directive_id == g:calculator_token_Max ||
          \ l:directive_id == g:calculator_token_Min ||
          \ l:directive_id == g:calculator_token_Nrt ||
          \ l:directive_id == g:calculator_token_Perms ||
          \ l:directive_id == g:calculator_token_Pow
      let l:right_value = remove(s:value_stack, -1)
      let l:left_value = remove(s:value_stack, -1)
      call calculator#evaluator#CheckType2(l:directive_id,
            \ l:left_value, l:right_value)
      let l:result_value = calculator#evaluator#Evaluate2(l:directive_id,
            \ l:left_value, l:right_value)
      call add(s:value_stack, l:result_value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Status ||
          \ l:directive_id == g:calculator_token_Rand ||
          \ l:directive_id == g:calculator_token_Vars
      let l:result_value = calculator#evaluator#Evaluate0(l:directive_id)
      call add(s:value_stack, l:result_value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Assign
      let l:value = remove(s:value_stack, -1)
      let s:value_map[l:directive.name] = l:value
      call add(s:value_stack, l:value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Or ||
          \ l:directive_id == g:calculator_token_And ||
          \ l:directive_id == g:calculator_token_Equal ||
          \ l:directive_id == g:calculator_token_NotEqual ||
          \ l:directive_id == g:calculator_token_LessThan ||
          \ l:directive_id == g:calculator_token_LessThanEqual ||
          \ l:directive_id == g:calculator_token_GreaterThan ||
          \ l:directive_id == g:calculator_token_GreaterThanEqual ||
          \ l:directive_id == g:calculator_token_Add ||
          \ l:directive_id == g:calculator_token_Subtract ||
          \ l:directive_id == g:calculator_token_Multiply ||
          \ l:directive_id == g:calculator_token_Divide ||
          \ l:directive_id == g:calculator_token_Modulus
      let l:right_value = remove(s:value_stack, -1)
      let l:left_value = remove(s:value_stack, -1)
      call calculator#evaluator#CheckType2(l:directive_id,
            \ l:left_value, l:right_value)
      let l:result_value = calculator#evaluator#Evaluate2(l:directive_id,
            \ l:left_value, l:right_value)
      call add(s:value_stack, l:result_value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Not ||
          \ l:directive_id == g:calculator_token_UnaryAdd ||
          \ l:directive_id == g:calculator_token_UnarySubtract
      let l:value = remove(s:value_stack, -1)
      call calculator#evaluator#CheckType(l:directive_id, l:value)
      let l:result_value =
            \ calculator#evaluator#Evaluate(l:directive_id, l:value)
      call add(s:value_stack, l:result_value)
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Name
      let l:name = l:directive.name
      call calculator#error#Check(has_key(s:value_map, l:name),
            \ "no such variable: '" .. l:name .. "', have: " ..
            \ string(s:value_map) .. "")
      call add(s:value_stack, s:value_map[l:name])
      let l:directive_index = l:directive_index + 1
    elseif l:directive_id == g:calculator_token_Value
      call add(s:value_stack, l:directive.value)
      let l:directive_index = l:directive_index + 1
    endif
  endwhile
endfunction

function! calculator#evaluator#CheckType(directive_id, value) abort
  if a:directive_id == g:calculator_token_IfNotGoto
    call calculator#error#Check(a:value.type_id == g:calculator_value_TypeBoolean,
          \ "not a boolean value in condition")
  elseif a:directive_id == g:calculator_token_Abs ||
        \ a:directive_id == g:calculator_token_Acos ||
        \ a:directive_id == g:calculator_token_Asin ||
        \ a:directive_id == g:calculator_token_Atan ||
        \ a:directive_id == g:calculator_token_Ceil ||
        \ a:directive_id == g:calculator_token_Cos ||
        \ a:directive_id == g:calculator_token_Cosh ||
        \ a:directive_id == g:calculator_token_Deg ||
        \ a:directive_id == g:calculator_token_Exp ||
        \ a:directive_id == g:calculator_token_Floor ||
        \ a:directive_id == g:calculator_token_Inv ||
        \ a:directive_id == g:calculator_token_Lg ||
        \ a:directive_id == g:calculator_token_Ln ||
        \ a:directive_id == g:calculator_token_Log10 ||
        \ a:directive_id == g:calculator_token_Rad ||
        \ a:directive_id == g:calculator_token_Round ||
        \ a:directive_id == g:calculator_token_Sin ||
        \ a:directive_id == g:calculator_token_Sinh ||
        \ a:directive_id == g:calculator_token_Sqrt ||
        \ a:directive_id == g:calculator_token_Tan ||
        \ a:directive_id == g:calculator_token_Tanh ||
        \ a:directive_id == g:calculator_token_Hex ||
        \ a:directive_id == g:calculator_token_Oct ||
        \ a:directive_id == g:calculator_token_Bin ||
        \ a:directive_id == g:calculator_token_Dec ||
        \ a:directive_id == g:calculator_token_Int ||
        \ a:directive_id == g:calculator_token_Float
    call calculator#error#Check(a:value.type_id == g:calculator_value_TypeNumerical,
          \ "not a numerical value")
  elseif a:directive_id == g:calculator_token_Not
    call calculator#error#Check(a:value.type_id == g:calculator_value_TypeBoolean,
          \ "not a boolean value")
  elseif a:directive_id == g:calculator_token_UnaryAdd ||
        \ a:directive_id == g:calculator_token_UnarySubtract
    call calculator#error#Check(a:value.type_id == g:calculator_value_TypeNumerical,
          \ "not a numerical value")
  endif
endfunction

function! calculator#evaluator#CheckType2(directive_id, value1, value2) abort
  if a:directive_id == g:calculator_token_Atan2 ||
        \ a:directive_id == g:calculator_token_Choose ||
        \ a:directive_id == g:calculator_token_Hypot ||
        \ a:directive_id == g:calculator_token_Ldexp ||
        \ a:directive_id == g:calculator_token_Log ||
        \ a:directive_id == g:calculator_token_Max ||
        \ a:directive_id == g:calculator_token_Min ||
        \ a:directive_id == g:calculator_token_Nrt ||
        \ a:directive_id == g:calculator_token_Perms ||
        \ a:directive_id == g:calculator_token_Pow
    call calculator#error#Check(a:value1.type_id == g:calculator_value_TypeNumerical &&
          \ a:value2.type_id == g:calculator_value_TypeNumerical,
          \ "non-numerical values in numerical expression")
  elseif a:directive_id == g:calculator_token_Or ||
        \ a:directive_id == g:calculator_token_And
    call calculator#error#Check(a:value1.type_id == g:calculator_value_TypeBoolean &&
          \ a:value2.type_id == g:calculator_value_TypeBoolean,
          \ "non-boolean values in boolean expression")
  elseif a:directive_id == g:calculator_token_Add ||
        \ a:directive_id == g:calculator_token_Subtract ||
        \ a:directive_id == g:calculator_token_Multiply ||
        \ a:directive_id == g:calculator_token_Divide ||
        \ a:directive_id == g:calculator_token_Modulus
    call calculator#error#Check(a:value1.type_id == g:calculator_value_TypeNumerical &&
          \ a:value2.type_id == g:calculator_value_TypeNumerical,
          \ "non-numerical values in numerical expression")
  elseif a:directive_id == g:calculator_token_Equal ||
        \ a:directive_id == g:calculator_token_NotEqual ||
        \ a:directive_id == g:calculator_token_LessThan ||
        \ a:directive_id == g:calculator_token_LessThanEqual ||
        \ a:directive_id == g:calculator_token_GreaterThan ||
        \ a:directive_id == g:calculator_token_GreaterThanEqual
    call calculator#error#Check(a:value1.type_id == g:calculator_value_TypeNumerical &&
          \ a:value2.type_id == g:calculator_value_TypeNumerical,
          \ "non-numerical values in numerical expression")
  endif
endfunction

function! calculator#evaluator#Evaluate(directive_id, value) abort
  if a:directive_id == g:calculator_token_Abs
    return calculator#value#Create({'numerical_value': abs(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Acos
    return calculator#value#Create({'numerical_value': acos(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Asin
    return calculator#value#Create({'numerical_value': asin(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Atan
    return calculator#value#Create({'numerical_value': atan(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Ceil
    return calculator#value#Create({'numerical_value': ceil(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Cos
    return calculator#value#Create({'numerical_value': cos(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Cosh
    return calculator#value#Create({'numerical_value': cosh(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Deg
    return calculator#value#Create({'numerical_value':
          \ a:value.numerical_value * 180 / g:calculator_constant_pi })
  elseif a:directive_id == g:calculator_token_Exp
    return calculator#value#Create({'numerical_value': exp(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Floor
    return calculator#value#Create({'numerical_value': floor(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Inv
    return calculator#value#Create({'numerical_value': 1 / a:value.numerical_value})
  elseif a:directive_id == g:calculator_token_Lg
    return calculator#value#Create({'numerical_value':
          \ log(a:value.numerical_value) / log(2)})
  elseif a:directive_id == g:calculator_token_Ln
    return calculator#value#Create({'numerical_value': log(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Log10
    return calculator#value#Create({'numerical_value': log10(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Rad
    return calculator#value#Create({'numerical_value':
          \ a:value.numerical_value * g:calculator_constant_pi / 180 })
  elseif a:directive_id == g:calculator_token_Round
    return calculator#value#Create({'numerical_value': round(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Sin
    return calculator#value#Create({'numerical_value': sin(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Sinh
    return calculator#value#Create({'numerical_value': sinh(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Sqrt
    return calculator#value#Create({'numerical_value': sqrt(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Tan
    return calculator#value#Create({'numerical_value': tan(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Tanh
    return calculator#value#Create({'numerical_value': tanh(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Hex
    "TODO FIXME
    return calculator#value#Create({'numerical_value': abs(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Oct
    "TODO FIXME
    return calculator#value#Create({'numerical_value': abs(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Bin
    "TODO FIXME
    return calculator#value#Create({'numerical_value': abs(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Dec
    "TODO FIXME
    return calculator#value#Create({'numerical_value': abs(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Int
    return calculator#value#Create({'numerical_value': float2nr(a:value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Float
    return calculator#value#Create({'numerical_value': a:value.numerical_value})
  elseif a:directive_id == g:calculator_token_Not
    return calculator#value#Create({'boolean_value': !a:value.boolean_value})
  elseif a:directive_id == g:calculator_token_UnaryAdd
    return calculator#value#Create({'numerical_value': +a:value.numerical_value})
  elseif a:directive_id == g:calculator_token_UnarySubtract
    return calculator#value#Create({'numerical_value': -a:value.numerical_value})
  endif
endfunction

function! calculator#evaluator#Evaluate2(directive_id, left_value, right_value) abort
  if a:directive_id == g:calculator_token_Atan2
    return calculator#value#Create({'numerical_value':
          \ atan2(a:left_value.numerical_value, a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Choose
    return calculator#value#Create({'numerical_value':
          \ calculator#evaluator#Factorial(a:left_value.numerical_value) /
          \ calculator#evaluator#Factorial(a:left_value.numerical_value -
          \ a:right_value.numerical_value) /
          \ calculator#evaluator#Factorial(a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Hypot
    return calculator#value#Create({'numerical_value':
          \ sqrt(a:left_value.numerical_value * a:left_value.numerical_value +
          \     a:right_value.numerical_value * a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Ldexp
    return calculator#value#Create({'numerical_value':
          \ a:left_value.numerical_value * pow(2, a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Log
    return calculator#value#Create({'numerical_value':
          \ log(a:left_value.numerical_value) / log(a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Max
    return calculator#value#Create({'numerical_value':
          \ (a:left_value.numerical_value > a:right_value.numerical_value) ?
          \ a:left_value.numerical_value : a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Min
    return calculator#value#Create({'numerical_value':
          \ (a:left_value.numerical_value < a:right_value.numerical_value) ?
          \ a:left_value.numerical_value : a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Nrt
    return calculator#value#Create({'numerical_value':
          \ pow(a:left_value.numerical_value, 1 / a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Perms
    return calculator#value#Create({'numerical_value':
          \ calculator#evaluator#Factorial(a:left_value.numerical_value) /
          \ calculator#evaluator#Factorial(a:left_value.numerical_value -
          \ a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Pow
    return calculator#value#Create({'numerical_value':
          \ pow(a:left_value.numerical_value, a:right_value.numerical_value)})
  elseif a:directive_id == g:calculator_token_Or
    return calculator#value#Create({'boolean_value':
          \ a:left_value.boolean_value || a:right_value.boolean_value})
  elseif a:directive_id == g:calculator_token_And
    return calculator#value#Create({'boolean_value':
          \ a:left_value.boolean_value && a:right_value.boolean_value})
  elseif a:directive_id == g:calculator_token_Equal
    return calculator#value#Create({'boolean_value':
          \ a:left_value.numerical_value == a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_NotEqual
    return calculator#value#Create({'boolean_value':
          \ a:left_value.numerical_value != a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_LessThan
    return calculator#value#Create({'boolean_value':
          \ a:left_value.numerical_value < a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_LessThanEqual
    return calculator#value#Create({'boolean_value':
          \ a:left_value.numerical_value <= a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_GreaterThan
    return calculator#value#Create({'boolean_value':
          \ a:left_value.numerical_value > a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_GreaterThanEqual
    return calculator#value#Create({'boolean_value':
          \ a:left_value.numerical_value >= a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Add
    return calculator#value#Create({'numerical_value':
          \ a:left_value.numerical_value + a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Subtract
    return calculator#value#Create({'numerical_value':
          \ a:left_value.numerical_value - a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Multiply
    return calculator#value#Create({'numerical_value':
          \ a:left_value.numerical_value * a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Divide
    return calculator#value#Create({'numerical_value':
          \ a:left_value.numerical_value / a:right_value.numerical_value})
  elseif a:directive_id == g:calculator_token_Modulus
    return calculator#value#Create({'numerical_value':
          \ fmod(a:left_value.numerical_value, a:right_value.numerical_value)})
  endif
endfunction

function! calculator#evaluator#Evaluate0(directive_id) abort
  if a:directive_id == g:calculator_token_Status
    return calculator#value#Create({'string_value': 'OK'})
  elseif a:directive_id == g:calculator_token_Rand
    return calculator#value#Create({'numerical_value':
          \ system("echo $RANDOM") / 32768.0 })
  elseif a:directive_id == g:calculator_token_Vars
    return calculator#value#Create({'string_value': string(s:value_map)})
  endif
endfunction

function! calculator#evaluator#Factorial(number) abort
  let l:cur = a:number
  let l:result = 1.0
  while l:cur > 0
    let l:result = l:result * l:cur
    let l:cur = l:cur - 1
  endwhile
  return l:result
endfunction
