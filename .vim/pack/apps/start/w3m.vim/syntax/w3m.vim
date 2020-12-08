" File: syntax/w3m.vim
" Last Modified: 2012.04.03
" Author: yuratomo (twitter @yusetomo)

if version < 700
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match	w3mMark /[\*\+\-\#="]/
syn match	w3mNumber /^ *[0-9]\+\./
syn match w3mDate /\<[0-9]\{1,4}�N[0-9]\{1,2}��[0-9]\{1,2}��/
syn match w3mBracket1 /�u\_.\{-0,30}�v/
syn match w3mBracket2 /�w\_.\{-0,30}�x/
syn match w3mBracket3 /�y\_.\{-0,30}�z/
syn keyword w3mCopylight Copyright
syn match w3mUrl contained "\vhttps?://[[:alnum:]][-[:alnum:]]*[[:alnum:]]?(\.[[:alnum:]][-[:alnum:]]*[[:alnum:]]?)*\.[[:alpha:]][-[:alnum:]]*[[:alpha:]]?(:\d+)?(/[^[:space:]]*)?$"
syn match w3mUrl "http[s]\=://\S*"

hi default link w3mMark Function
hi default link w3mNumber Number
hi default link w3mDate Define
hi default link w3mBracket1 Macro
hi default link w3mBracket2 Macro
hi default link w3mBracket3 Macro
hi default link w3mCopylight Keyword
hi default link w3mUrl Comment
hi default link w3mTitle Comment

let b:current_syntax = 'w3m'
