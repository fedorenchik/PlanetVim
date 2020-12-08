" Location:     autoload/calculator.vim
" Maintainer:   Leonid V. Fedorenchik <leonid@fedorenchik.com>

if !exists('g:loaded_autoload_calculator')
  call calculator#token#Init()
  call calculator#constant#Init()
  call calculator#scanner#Init()
endif
let g:loaded_autoload_calculator = 1

function! calculator#CalculatorOpen() abort
  execute 'topleft keepalt new'
  setlocal buftype=prompt
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal filetype=calculator
  augroup calculator_window
    autocmd!
    autocmd QuitPre <buffer> setlocal nomodified
  augroup END
  call prompt_setprompt(bufnr(''), g:calculator_prompt)
  call prompt_setcallback(bufnr(''), function('calculator#CalculatorEvaluate'))
  startinsert
  setlocal nomodified
endfunction

function! calculator#CalculatorEvaluate(text) abort
  if a:text == 'exit' || a:text == 'quit'
    stopinsert
    quit
  else
    let l:ret = calculator#CalculatorInstruction(a:text)
    if !empty(l:ret)
      call append(line('$') - 1, l:ret)
      setlocal nomodified
    endif
  endif
endfunction

function! calculator#CalculatorInstruction(text)
  let l:text = substitute(a:text, '#.*$', '', '')
  let l:text = substitute(l:text, '\s*$', '', '')
  let l:text = substitute(l:text, '^\s*', '', '')
  if (empty(l:text))
    return ''
  endif
  try
    call calculator#scanner#Start(l:text)
    let l:is_expression = v:false
    call calculator#parser#Start(l:is_expression)
    let l:ret_val_stack = calculator#evaluator#Start()
    if empty(l:ret_val_stack)
      return ''
    elseif len(l:ret_val_stack) == 1
      if l:ret_val_stack[0].type_id == g:calculator_value_TypeNumerical
        return string(l:ret_val_stack[0].numerical_value)
      elseif l:ret_val_stack[0].type_id == g:calculator_value_TypeBoolean
        return string(l:ret_val_stack[0].boolean_value)
      elseif l:ret_val_stack[0].type_id == g:calculator_value_TypeString
        return string(l:ret_val_stack[0].string_value)
      elseif l:ret_val_stack[0].type_id == g:calculator_value_TypeVoid
        return 'null'
      else
        return 'ERROR: Impossible type returned'
      endif
    else
      let l:ret_str = '['
      for value in l:ret_val_stack
        if value.type_id == g:calculator_value_TypeNumerical
          let l:ret_str ..= string(value.numerical_value) .. ', '
        elseif value.type_id == g:calculator_value_TypeBoolean
          let l:ret_str ..= string(value.boolean_value) .. ', '
        elseif value.type_id == g:calculator_value_TypeString
          let l:ret_str ..= string(value.string_value) .. ', '
        elseif value.type_id == g:calculator_value_TypeVoid
          let l:ret_str ..= 'null, '
        else
          let l:ret_str ..= '[ERROR: Impossible type returned], '
        endif
      endfor
      let l:ret_str = strpart(l:ret_str, 0, strlen(l:ret_str) - 2)
      let l:ret_str ..= ']'
      return l:ret_str
    endif
  catch
    return ['ERROR: ' .. v:exception, 'AT: ' .. v:throwpoint]
  endtry
endfunction
