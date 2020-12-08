function g:RunAllTests()
  call g:EmptyInputTests()
  call g:CommentsTests()
  call g:SemicolonTests()
  call g:ArithmeticTests()
  call g:ComparisonOperatorsTests()
  call g:LogicalOperatorsTests()
  call g:VariablesTests()
  call g:LogicalKeywordsTests()
  call g:SwitchStatementTests()
  call g:FunctionDefinitionTests()
  call g:IfStatementTests()
  call g:WhileStatementTests()
  call g:FunctionsTests()
  call g:CalculatorStatusTests()
  call g:ConstantsTests()
  call g:MultipleInstructionsTests()

  if !empty(v:errors)
    call writefile(v:errors, "/dev/stdout")
    " cquit
  endif
endfunction

function g:EmptyInputTests()
  call assert_equal('', calculator#CalculatorInstruction('        '))
endfunction

function g:CommentsTests()
  call assert_equal('', calculator#CalculatorInstruction('   # test comment  '))
endfunction

function g:SemicolonTests()
  call assert_equal('', calculator#CalculatorInstruction(';'))
  call assert_equal('', calculator#CalculatorInstruction(';;'))
  call assert_equal('', calculator#CalculatorInstruction(';;;;;;;;;;'))
  call assert_equal('', calculator#CalculatorInstruction('  ;  '))
endfunction

function g:ArithmeticTests()
  call assert_equal('5.0', calculator#CalculatorInstruction('2 + 2 * 2 - 2 / 2'))
  call assert_equal('15.0', calculator#CalculatorInstruction('9 + 6'))
  call assert_equal('-5.0', calculator#CalculatorInstruction('3 - 8'))
  call assert_equal('-8.0', calculator#CalculatorInstruction('4 * -2'))
  call assert_equal('7.0', calculator#CalculatorInstruction('49 / 7'))
  call assert_equal('2.0', calculator#CalculatorInstruction('8 % 3'))
  call assert_equal('0.333333', calculator#CalculatorInstruction('1/3'))
  call assert_equal('0.666667', calculator#CalculatorInstruction('2/3'))
endfunction

function g:ComparisonOperatorsTests()
  call assert_equal('1', calculator#CalculatorInstruction('3 == 3'))
  call assert_equal('0', calculator#CalculatorInstruction('3 == 5'))
  call assert_equal('1', calculator#CalculatorInstruction('3 != 5'))
  call assert_equal('0', calculator#CalculatorInstruction('3 != 3'))
  call assert_equal('1', calculator#CalculatorInstruction('3 <= 5'))
  call assert_equal('1', calculator#CalculatorInstruction('3 <= 3'))
  call assert_equal('0', calculator#CalculatorInstruction('5 <= 3'))
  call assert_equal('1', calculator#CalculatorInstruction('3 < 5'))
  call assert_equal('0', calculator#CalculatorInstruction('3 < 3'))
  call assert_equal('0', calculator#CalculatorInstruction('5 < 3'))
  call assert_equal('1', calculator#CalculatorInstruction('5 >= 3'))
  call assert_equal('1', calculator#CalculatorInstruction('3 >= 3'))
  call assert_equal('0', calculator#CalculatorInstruction('3 >= 5'))
  call assert_equal('1', calculator#CalculatorInstruction('5 > 3'))
  call assert_equal('0', calculator#CalculatorInstruction('3 > 3'))
  call assert_equal('0', calculator#CalculatorInstruction('3 > 5'))
endfunction

function g:LogicalOperatorsTests()
  call assert_equal('1', calculator#CalculatorInstruction('true && true'))
  call assert_equal('0', calculator#CalculatorInstruction('true && false'))
  call assert_equal('0', calculator#CalculatorInstruction('false && true'))
  call assert_equal('0', calculator#CalculatorInstruction('false && false'))
  call assert_equal('1', calculator#CalculatorInstruction('true || true'))
  call assert_equal('1', calculator#CalculatorInstruction('true || false'))
  call assert_equal('1', calculator#CalculatorInstruction('false || true'))
  call assert_equal('0', calculator#CalculatorInstruction('false || false'))
  call assert_equal('0', calculator#CalculatorInstruction('!true'))
  call assert_equal('1', calculator#CalculatorInstruction('!false'))
endfunction

function g:VariablesTests()
  call assert_equal('5.0', calculator#CalculatorInstruction('a = 5'))
  call assert_equal('5.0', calculator#CalculatorInstruction('a'))
endfunction

function g:LogicalKeywordsTests()
  call assert_equal('1', calculator#CalculatorInstruction('true and true'))
  call assert_equal('0', calculator#CalculatorInstruction('true and false'))
  call assert_equal('0', calculator#CalculatorInstruction('false and true'))
  call assert_equal('0', calculator#CalculatorInstruction('false and false'))
  call assert_equal('1', calculator#CalculatorInstruction('true or true'))
  call assert_equal('1', calculator#CalculatorInstruction('true or false'))
  call assert_equal('1', calculator#CalculatorInstruction('false or true'))
  call assert_equal('0', calculator#CalculatorInstruction('false or false'))
  call assert_equal('0', calculator#CalculatorInstruction('not true'))
  call assert_equal('1', calculator#CalculatorInstruction('not false'))
endfunction

function g:SwitchStatementTests()
  call assert_equal('1.0', calculator#CalculatorInstruction('a = 1'))
  call assert_equal('1.0', calculator#CalculatorInstruction('switch (a) { case 0: 0; case 1: 1; }'))
endfunction

function g:FunctionDefinitionTests()
  call assert_equal('9.0', calculator#CalculatorInstruction('function fn(a, b) { return a + b; } call fn(4, 5)'))
  " call assert_equal('', calculator#CalculatorInstruction('function fn(a, b) { return a + b; }'))
  " call assert_equal('9.0', calculator#CalculatorInstruction('call fn(4, 5)'))
endfunction

function g:IfStatementTests()
  call assert_equal('1.0', calculator#CalculatorInstruction('a = 1'))
  call assert_equal('1.0', calculator#CalculatorInstruction('if (a == 1) { 1; } else { 0; }'))
endfunction

function g:WhileStatementTests()
  call assert_equal('5.0', calculator#CalculatorInstruction('a = 5'))
  call assert_equal('[4.0, 3.0, 2.0, 1.0, 0.0]', calculator#CalculatorInstruction('while (a > 0) { a = a - 1; }'))
endfunction

function g:FunctionsTests()
  let l:function_list = [ "abs", "acos", "asin", "atan", "ceil", "cos", "cosh", "exp", "floor", "log10", "round", "sin", "sinh", "sqrt", "tan", "tanh" ]
  for l:cur_fun in l:function_list
    let l:value_list = [ "-100.0", "-1.1", "-0.9", "-0.8", "-0.7", "-0.6", "-0.5", "-0.4", "-0.3", "-0.2", "-0.1", "0.0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.1", "2.0", "4.0", "10.0", "100.0" ]
    for l:cur_value in l:value_list
      let l:function_to_test = l:cur_fun .. "(" .. l:cur_value .. ")"
      let l:expected_result = string(eval(l:function_to_test))
      call assert_equal(l:expected_result, calculator#CalculatorInstruction(l:function_to_test))
      " call writefile([ "Testing " .. l:function_to_test ], "/dev/stdout")
      call writefile(v:errors, "/dev/stdout")
      let v:errors = []
    endfor
  endfor
  call assert_equal("1.107149", calculator#CalculatorInstruction("atan2(4, 2)"))
  call assert_equal("10.0", calculator#CalculatorInstruction("choose(5, 2)"))
  call assert_equal("57.29578", calculator#CalculatorInstruction("deg(1)"))
  call assert_equal("5.0", calculator#CalculatorInstruction("hypot(3, 4)"))
  call assert_equal("0.1", calculator#CalculatorInstruction("inv(10)"))
  call assert_equal("20.0", calculator#CalculatorInstruction("ldexp(5, 2)"))
  call assert_equal("10.0", calculator#CalculatorInstruction("lg(1024)"))
  call assert_equal("4.60517", calculator#CalculatorInstruction("ln(100)"))
  call assert_equal("3.0", calculator#CalculatorInstruction("log(1000, 10)"))
  call assert_equal("100.0", calculator#CalculatorInstruction("max(-1000, 100)"))
  call assert_equal("-100.0", calculator#CalculatorInstruction("min(1000, -100)"))
  call assert_equal("2.0", calculator#CalculatorInstruction("nrt(32, 5)"))
  call assert_equal("20.0", calculator#CalculatorInstruction("perms(5, 2)"))
  call assert_equal("32.0", calculator#CalculatorInstruction("pow(2, 5)"))
  call assert_equal("0.017453", calculator#CalculatorInstruction("rad(1)"))
  call assert_inrange(0.0, 1.0, str2float(calculator#CalculatorInstruction("rand()")))
  call assert_notequal("1.0", calculator#CalculatorInstruction("rand()"))
endfunction

function g:CalculatorStatusTests()
  call assert_equal("'OK'", calculator#CalculatorInstruction("status()"))
  call assert_equal("'{''a'': {''numerical_value'': 0.0, ''type_id'': 5}}'", calculator#CalculatorInstruction("vars()"))
endfunction

function g:ConstantsTests()
  call assert_equal('v:true', calculator#CalculatorInstruction('true'))
  call assert_equal('v:false', calculator#CalculatorInstruction('false'))
  call assert_equal('2.718282', calculator#CalculatorInstruction('e'))
  call assert_equal('3.141593', calculator#CalculatorInstruction('pi'))
  call assert_equal('1.618034', calculator#CalculatorInstruction('phi'))
endfunction

function g:MultipleInstructionsTests()
  call assert_equal('[4.0, 5.0]', calculator#CalculatorInstruction('{ 4; 5; }'))
  call assert_equal('[4.0, 5.0]', calculator#CalculatorInstruction('4; 5'))
endfunction
