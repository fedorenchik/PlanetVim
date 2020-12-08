" look_ahead is returned by token#Create
" { 'id': id, 'name': 'name', 'value': value }
let s:look_ahead = {}
let g:calculator_parser_function_map = {}
let g:calculator_parser_directive_list = []

function! calculator#parser#Start(is_expression) abort
  let s:look_ahead = {}
  let g:calculator_parser_function_map = {}
  let g:calculator_parser_directive_list = []

  let s:look_ahead = calculator#scanner#NextToken()
  call add(g:calculator_parser_directive_list,
        \ calculator#directive#Create(
        \ g:calculator_token_Goto, { 'address': 0 }))
  if a:is_expression
    call calculator#parser#Expression()
  else
    call calculator#parser#InstructionList()
  endif
  call calculator#parser#Match(g:calculator_token_EndOfFile)
  " FIXME: set first address to the first instruction
  let g:calculator_parser_directive_list[0].address = 1
endfunction

function! calculator#parser#Match(token_id) abort
  if a:token_id == g:calculator_token_Semicolon
    if s:look_ahead.id != g:calculator_token_Semicolon
      if !calculator#scanner#HadNewline()
        call calculator#error#SyntaxError('Parse error: Wrong token: ' ..
              \ string(s:look_ahead.id) .. ', expected: ' .. string(a:token_id))
      endif
    endif
  elseif s:look_ahead.id != a:token_id
    call calculator#error#SyntaxError('Parse error: Wrong token: ' ..
          \ string(s:look_ahead.id) .. ', expected: ' .. string(a:token_id))
  endif
  let s:look_ahead = calculator#scanner#NextToken()
endfunction

function! calculator#parser#FunctionDefinition() abort
  call calculator#parser#Match(g:calculator_token_Function)
  let l:name = s:look_ahead.name
  call calculator#parser#Match(g:calculator_token_Name)
  call calculator#parser#Match(g:calculator_token_LeftParenthesis)
  let l:name_list = calculator#parser#NameList()
  call calculator#parser#Match(g:calculator_token_RightParenthesis)
  let l:skip_function_index = len(g:calculator_parser_directive_list)
  call add(g:calculator_parser_directive_list, calculator#directive#Create(
        \ g:calculator_token_Goto, {'address': 0}))
  let l:start_address = len(g:calculator_parser_directive_list)
  let l:user_function = calculator#function#Create(l:name_list, l:start_address)
  call add(g:calculator_parser_directive_list, calculator#directive#Create(
        \ g:calculator_token_Function, { 'user_function': l:user_function }))
  call calculator#parser#Match(g:calculator_token_LeftBrace)
  call calculator#parser#BlockInstruction()
  call calculator#parser#Match(g:calculator_token_RightBrace)
  call add(g:calculator_parser_directive_list, calculator#directive#Create(
        \ g:calculator_token_Return, {}))
  let g:calculator_parser_directive_list[l:skip_function_index].address =
        \ len(g:calculator_parser_directive_list)
  "TODO: also check for built-in functions
  call calculator#error#Check(!has_key(g:calculator_parser_function_map, l:name),
        \ 'function "' . l:name . "' already defined")
  let g:calculator_parser_function_map[l:name] = l:user_function
endfunction

function! calculator#parser#NameList() abort
  let l:name_list = []
  while s:look_ahead.id != g:calculator_token_RightParenthesis
    let l:name = s:look_ahead.name
    if index(l:name_list, l:name) != -1
      call calculator#error#SemanticError(
            \ 'parameter "' . l:name . '" defined twice')
    endif
    call add(l:name_list, l:name)
    call calculator#parser#Match(g:calculator_token_Name)
    if s:look_ahead.id == g:calculator_token_RightParenthesis
      break
    endif
    call calculator#parser#Match(g:calculator_token_Comma)
  endwhile
  return l:name_list
endfunction

function! calculator#parser#BlockInstruction() abort
  while s:look_ahead.id != g:calculator_token_RightBrace
    call calculator#parser#Instruction()
  endwhile
endfunction

function! calculator#parser#InstructionList() abort
  while s:look_ahead.id != g:calculator_token_EndOfFile
    call calculator#parser#Instruction()
  endwhile
endfunction

function! calculator#parser#Instruction() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_Function
    call calculator#parser#FunctionDefinition()
  elseif l:token_id == g:calculator_token_Call
    call calculator#parser#CallExpression()
    call calculator#parser#Match(g:calculator_token_Semicolon)
  elseif l:token_id == g:calculator_token_Return
    call calculator#parser#Match(g:calculator_token_Return)
    if s:look_ahead.id != g:calculator_token_Semicolon
      call calculator#parser#Expression()
    endif
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Return, {}))
    call calculator#parser#Match(g:calculator_token_Semicolon)
  elseif l:token_id == g:calculator_token_If
    call calculator#parser#Match(g:calculator_token_If)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    let l:if_not_index = len(g:calculator_parser_directive_list)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_IfNotGoto, { 'address': 0 }))
    call calculator#parser#Instruction()
    if s:look_ahead.id == g:calculator_token_Else
      call calculator#parser#Match(g:calculator_token_Else)
      let l:else_index = len(g:calculator_parser_directive_list)
      call add(g:calculator_parser_directive_list, calculator#directive#Create(
            \ g:calculator_token_Goto, { 'address': 0}))
      let g:calculator_parser_directive_list[l:if_not_index].address =
            \ len(g:calculator_parser_directive_list)
      call calculator#parser#Instruction()
      let g:calculator_parser_directive_list[l:else_index].address =
            \ len(g:calculator_parser_directive_list)
    else
      let g:calculator_parser_directive_list[l:if_not_index].address =
            \ len(g:calculator_parser_directive_list)
    endif
  elseif l:token_id == g:calculator_token_Switch
    call calculator#parser#Match(g:calculator_token_Switch)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    let l:switch_var = s:look_ahead.name
    call calculator#parser#Match(g:calculator_token_Name)
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call calculator#parser#Match(g:calculator_token_LeftBrace)
    let l:end_indexes = []
    while s:look_ahead.id == g:calculator_token_Case
      call calculator#parser#Match(g:calculator_token_Case)
      call calculator#parser#Expression()
      call calculator#parser#Match(g:calculator_token_Colon)
      call add(g:calculator_parser_directive_list, calculator#directive#Create(
            \ g:calculator_token_Case, { 'name': l:switch_var }))
      let l:if_not_index = len(g:calculator_parser_directive_list)
      call add(g:calculator_parser_directive_list, calculator#directive#Create(
            \ g:calculator_token_IfNotGoto, { 'address': 0 }))
      call calculator#parser#Instruction()
      let l:end_index = len(g:calculator_parser_directive_list)
      call add(l:end_indexes, l:end_index)
      call add(g:calculator_parser_directive_list, calculator#directive#Create(
            \ g:calculator_token_Goto, { 'address': 0 }))
      let g:calculator_parser_directive_list[l:if_not_index].address =
            \ len(g:calculator_parser_directive_list)
    endwhile
    if s:look_ahead.id == g:calculator_token_Default
      call calculator#parser#Match(g:calculator_token_Default)
      call calculator#parser#Match(g:calculator_token_Colon)
      call calculator#parser#Instruction()
    endif
    for index in l:end_indexes
      let g:calculator_parser_directive_list[index].address =
            \ len(g:calculator_parser_directive_list)
    endfor
    call calculator#parser#Match(g:calculator_token_RightBrace)
  elseif l:token_id == g:calculator_token_While
    call calculator#parser#Match(g:calculator_token_While)
    let l:while_index = len(g:calculator_parser_directive_list)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    let l:if_not_index = len(g:calculator_parser_directive_list)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_IfNotGoto, { 'address': 0 }))
    call calculator#parser#Instruction()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Goto, { 'address': l:while_index }))
    let g:calculator_parser_directive_list[l:if_not_index].address =
          \ len(g:calculator_parser_directive_list)
  elseif l:token_id == g:calculator_token_LeftBrace
    call calculator#parser#Match(g:calculator_token_LeftBrace)
    call calculator#parser#BlockInstruction()
    call calculator#parser#Match(g:calculator_token_RightBrace)
  elseif l:token_id == g:calculator_token_Name
    let l:name = s:look_ahead.name
    call calculator#parser#Match(g:calculator_token_Name)
    if s:look_ahead.id == g:calculator_token_Assign
      call calculator#parser#Match(g:calculator_token_Assign)
      call calculator#parser#Expression()
      call add(g:calculator_parser_directive_list, calculator#directive#Create(
            \ g:calculator_token_Assign, { 'name': l:name }))
    else
      call add(g:calculator_parser_directive_list, calculator#directive#Create(
            \ g:calculator_token_Name, { 'name': l:name }))
    endif
  else
    " call calculator#error#SyntaxError('')
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Semicolon)
  endif
endfunction

function! calculator#parser#ExpressionList() abort
  let l:size = 0
  while s:look_ahead.id != g:calculator_token_RightParenthesis
    call calculator#parser#Expression()
    let l:size += 1
    if s:look_ahead.id == g:calculator_token_RightParenthesis
      break
    endif
    call calculator#parser#Match(g:calculator_token_Comma)
  endwhile
  return l:size
endfunction

function! calculator#parser#Expression() abort
  call calculator#parser#AndExpression()
  call calculator#parser#ExpressionRest()
endfunction

function! calculator#parser#ExpressionRest() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_Or
    call calculator#parser#Match(g:calculator_token_Or)
    call calculator#parser#AndExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Or, {}))
    call calculator#parser#ExpressionRest()
  endif
endfunction

function! calculator#parser#AndExpression() abort
  call calculator#parser#RelationExpression()
  call calculator#parser#AndExpressionRest()
endfunction

function! calculator#parser#AndExpressionRest() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_And
    call calculator#parser#Match(g:calculator_token_And)
    call calculator#parser#RelationExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_And, {}))
    call calculator#parser#AndExpressionRest()
  endif
endfunction

function! calculator#parser#RelationExpression() abort
  call calculator#parser#TermExpression()
  call calculator#parser#RelationExpressionRest()
endfunction

function! calculator#parser#RelationExpressionRest() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_Equal ||
        \ l:token_id == g:calculator_token_NotEqual ||
        \ l:token_id == g:calculator_token_LessThan ||
        \ l:token_id == g:calculator_token_LessThanEqual ||
        \ l:token_id == g:calculator_token_GreaterThan ||
        \ l:token_id == g:calculator_token_GreaterThanEqual
    call calculator#parser#Match(l:token_id)
    call calculator#parser#TermExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ l:token_id, {}))
    call calculator#parser#RelationExpressionRest()
  endif
endfunction

function! calculator#parser#TermExpression() abort
  call calculator#parser#FactorExpression()
  call calculator#parser#TermExpressionRest()
endfunction

function! calculator#parser#TermExpressionRest() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_Add ||
        \ l:token_id == g:calculator_token_Subtract
    call calculator#parser#Match(l:token_id)
    call calculator#parser#FactorExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ l:token_id, {}))
    call calculator#parser#TermExpressionRest()
  endif
endfunction

function! calculator#parser#FactorExpression() abort
  call calculator#parser#PrefixExpression()
  call calculator#parser#FactorExpressionRest()
endfunction

function! calculator#parser#FactorExpressionRest() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_Multiply ||
        \ l:token_id == g:calculator_token_Divide ||
        \ l:token_id == g:calculator_token_Modulus
    call calculator#parser#Match(l:token_id)
    call calculator#parser#PrefixExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ l:token_id, {}))
    call calculator#parser#FactorExpressionRest()
  endif
endfunction

function! calculator#parser#PrefixExpression() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_Add
    call calculator#parser#Match(g:calculator_token_Add)
    call calculator#parser#PrefixExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_UnaryAdd, {}))
  elseif l:token_id == g:calculator_token_Subtract
    call calculator#parser#Match(g:calculator_token_Subtract)
    call calculator#parser#PrefixExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_UnarySubtract, {}))
  elseif l:token_id == g:calculator_token_Not
    call calculator#parser#Match(g:calculator_token_Not)
    call calculator#parser#PrefixExpression()
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Not, {}))
  else
    call calculator#parser#PrimaryExpression()
  endif
endfunction

function! calculator#parser#PrimaryExpression() abort
  let l:token_id = s:look_ahead.id
  if l:token_id == g:calculator_token_LeftParenthesis
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
  elseif l:token_id == g:calculator_token_Value
    let l:value = s:look_ahead.value
    call calculator#parser#Match(g:calculator_token_Value)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Value, { 'value': l:value }))
  elseif l:token_id == g:calculator_token_Name
    let l:name = s:look_ahead.name
    call calculator#parser#Match(g:calculator_token_Name)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Name, { 'name': l:name }))
  elseif l:token_id == g:calculator_token_Call
    call calculator#parser#CallExpression()
  elseif l:token_id == g:calculator_token_Abs
    call calculator#parser#Match(g:calculator_token_Abs)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Abs, {}))
  elseif l:token_id == g:calculator_token_Acos
    call calculator#parser#Match(g:calculator_token_Acos)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Acos, {}))
  elseif l:token_id == g:calculator_token_Asin
    call calculator#parser#Match(g:calculator_token_Asin)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Asin, {}))
  elseif l:token_id == g:calculator_token_Atan
    call calculator#parser#Match(g:calculator_token_Atan)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Atan, {}))
  elseif l:token_id == g:calculator_token_Atan2
    call calculator#parser#Match(g:calculator_token_Atan2)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Atan2, {}))
  elseif l:token_id == g:calculator_token_Ceil
    call calculator#parser#Match(g:calculator_token_Ceil)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Ceil, {}))
  elseif l:token_id == g:calculator_token_Choose
    call calculator#parser#Match(g:calculator_token_Choose)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Choose, {}))
  elseif l:token_id == g:calculator_token_Cos
    call calculator#parser#Match(g:calculator_token_Cos)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Cos, {}))
  elseif l:token_id == g:calculator_token_Cosh
    call calculator#parser#Match(g:calculator_token_Cosh)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Cosh, {}))
  elseif l:token_id == g:calculator_token_Deg
    call calculator#parser#Match(g:calculator_token_Deg)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Deg, {}))
  elseif l:token_id == g:calculator_token_Exp
    call calculator#parser#Match(g:calculator_token_Exp)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Exp, {}))
  elseif l:token_id == g:calculator_token_Floor
    call calculator#parser#Match(g:calculator_token_Floor)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Floor, {}))
  elseif l:token_id == g:calculator_token_Hypot
    call calculator#parser#Match(g:calculator_token_Hypot)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Hypot, {}))
  elseif l:token_id == g:calculator_token_Inv
    call calculator#parser#Match(g:calculator_token_Inv)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Inv, {}))
  elseif l:token_id == g:calculator_token_Ldexp
    call calculator#parser#Match(g:calculator_token_Ldexp)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Ldexp, {}))
  elseif l:token_id == g:calculator_token_Lg
    call calculator#parser#Match(g:calculator_token_Lg)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Lg, {}))
  elseif l:token_id == g:calculator_token_Ln
    call calculator#parser#Match(g:calculator_token_Ln)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Ln, {}))
  elseif l:token_id == g:calculator_token_Log
    call calculator#parser#Match(g:calculator_token_Log)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Log, {}))
  elseif l:token_id == g:calculator_token_Log10
    call calculator#parser#Match(g:calculator_token_Log10)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Log10, {}))
  elseif l:token_id == g:calculator_token_Max
    call calculator#parser#Match(g:calculator_token_Max)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Max, {}))
  elseif l:token_id == g:calculator_token_Min
    call calculator#parser#Match(g:calculator_token_Min)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Min, {}))
  elseif l:token_id == g:calculator_token_Nrt
    call calculator#parser#Match(g:calculator_token_Nrt)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Nrt, {}))
  elseif l:token_id == g:calculator_token_Perms
    call calculator#parser#Match(g:calculator_token_Perms)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Perms, {}))
  elseif l:token_id == g:calculator_token_Pow
    call calculator#parser#Match(g:calculator_token_Pow)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_Comma)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Pow, {}))
  elseif l:token_id == g:calculator_token_Rad
    call calculator#parser#Match(g:calculator_token_Rad)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Rad, {}))
  elseif l:token_id == g:calculator_token_Rand
    call calculator#parser#Match(g:calculator_token_Rand)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Rand, {}))
  elseif l:token_id == g:calculator_token_Round
    call calculator#parser#Match(g:calculator_token_Round)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Round, {}))
  elseif l:token_id == g:calculator_token_Sin
    call calculator#parser#Match(g:calculator_token_Sin)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Sin, {}))
  elseif l:token_id == g:calculator_token_Sinh
    call calculator#parser#Match(g:calculator_token_Sinh)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Sinh, {}))
  elseif l:token_id == g:calculator_token_Sqrt
    call calculator#parser#Match(g:calculator_token_Sqrt)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Sqrt, {}))
  elseif l:token_id == g:calculator_token_Tan
    call calculator#parser#Match(g:calculator_token_Tan)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Tan, {}))
  elseif l:token_id == g:calculator_token_Tanh
    call calculator#parser#Match(g:calculator_token_Tanh)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Tanh, {}))
  elseif l:token_id == g:calculator_token_Hex
    call calculator#parser#Match(g:calculator_token_Hex)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Hex, {}))
  elseif l:token_id == g:calculator_token_Oct
    call calculator#parser#Match(g:calculator_token_Oct)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Oct, {}))
  elseif l:token_id == g:calculator_token_Bin
    call calculator#parser#Match(g:calculator_token_Bin)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Bin, {}))
  elseif l:token_id == g:calculator_token_Dec
    call calculator#parser#Match(g:calculator_token_Dec)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Dec, {}))
  elseif l:token_id == g:calculator_token_Int
    call calculator#parser#Match(g:calculator_token_Int)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Int, {}))
  elseif l:token_id == g:calculator_token_Float
    call calculator#parser#Match(g:calculator_token_Float)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Expression()
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Float, {}))
  elseif l:token_id == g:calculator_token_Status
    call calculator#parser#Match(g:calculator_token_Status)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Status, {}))
  elseif l:token_id == g:calculator_token_Vars
    call calculator#parser#Match(g:calculator_token_Vars)
    call calculator#parser#Match(g:calculator_token_LeftParenthesis)
    call calculator#parser#Match(g:calculator_token_RightParenthesis)
    call add(g:calculator_parser_directive_list, calculator#directive#Create(
          \ g:calculator_token_Vars, {}))
  elseif l:token_id == g:calculator_token_Semicolon
    " skip next semicolon ';'
  else
    call calculator#error#SyntaxError('Unexpected token: ' ..
          \ string(l:token_id))
  endif
endfunction

function! calculator#parser#CallExpression() abort
  call calculator#parser#Match(g:calculator_token_Call)
  let l:name = s:look_ahead.name
  call calculator#parser#Match(g:calculator_token_Name)
  call calculator#parser#Match(g:calculator_token_LeftParenthesis)
  let l:size = calculator#parser#ExpressionList()
  call calculator#parser#Match(g:calculator_token_RightParenthesis)
  call add(g:calculator_parser_directive_list, calculator#directive#Create(
        \ g:calculator_token_Call, { 'name': l:name, 'parameters': l:size }))
endfunction
