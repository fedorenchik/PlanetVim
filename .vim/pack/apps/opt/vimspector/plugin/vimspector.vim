" vimspector - A multi-language debugging system for Vim
" Copyright 2018 Ben Jackson
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"   http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" Boilerplate {{{
let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:restore_cpo()
  let &cpoptions=s:save_cpo
  unlet s:save_cpo
endfunction

if exists( 'g:loaded_vimpector' )
  call s:restore_cpo()
  finish
endif
"}}}

let g:loaded_vimpector = 1
let g:vimspector_home = expand( '<sfile>:p:h:h' )

let s:mappings = get( g:, 'vimspector_enable_mappings', '' )

nnoremap <silent> <Plug>VimspectorContinue
      \ :<c-u>call vimspector#Continue()<CR>
nnoremap <silent> <Plug>VimspectorStop
      \ :<c-u>call vimspector#Stop()<CR>
nnoremap <silent> <Plug>VimspectorRestart
      \ :<c-u>call vimspector#Restart()<CR>
nnoremap <silent> <Plug>VimspectorPause
      \ :<c-u>call vimspector#Pause()<CR>
nnoremap <silent> <Plug>VimspectorToggleBreakpoint
      \ :<c-u>call vimspector#ToggleBreakpoint()<CR>
nnoremap <silent> <Plug>VimspectorToggleConditionalBreakpoint
      \ :<c-u>call vimspector#ToggleBreakpoint(
                    \ { 'condition': input( 'Enter condition expression: ' ),
                    \   'hitCondition': input( 'Enter hit count expression: ' ) }
                    \ )<CR>
nnoremap <silent> <Plug>VimspectorAddFunctionBreakpoint
      \ :<c-u>call vimspector#AddFunctionBreakpoint( expand( '<cexpr>' ) )<CR>
nnoremap <silent> <Plug>VimspectorStepOver
      \ :<c-u>call vimspector#StepOver()<CR>
nnoremap <silent> <Plug>VimspectorStepInto
      \ :<c-u>call vimspector#StepInto()<CR>
nnoremap <silent> <Plug>VimspectorStepOut
      \ :<c-u>call vimspector#StepOut()<CR>

nnoremap <silent> <Plug>VimspectorRunToCursor
      \ :<c-u>call vimspector#RunToCursor()<CR>

" Eval for normal mode
nnoremap <silent> <Plug>VimspectorBalloonEval
      \ :<c-u>call vimspector#ShowEvalBalloon( 0 )<CR>
" And for visual modes
xnoremap <silent> <Plug>VimspectorBalloonEval
      \ :<c-u>call vimspector#ShowEvalBalloon( 1 )<CR>

if s:mappings ==# 'VISUAL_STUDIO'
  nmap <F5>         <Plug>VimspectorContinue
  nmap <S-F5>       <Plug>VimspectorStop
  nmap <C-S-F5>     <Plug>VimspectorRestart
  nmap <F6>         <Plug>VimspectorPause
  nmap <F9>         <Plug>VimspectorToggleBreakpoint
  nmap <S-F9>       <Plug>VimspectorAddFunctionBreakpoint
  nmap <F10>        <Plug>VimspectorStepOver
  nmap <F11>        <Plug>VimspectorStepInto
  nmap <S-F11>      <Plug>VimspectorStepOut
elseif s:mappings ==# 'HUMAN'
  nmap <F5>         <Plug>VimspectorContinue
  nmap <F3>         <Plug>VimspectorStop
  nmap <F4>         <Plug>VimspectorRestart
  nmap <F6>         <Plug>VimspectorPause
  nmap <F9>         <Plug>VimspectorToggleBreakpoint
  nmap <leader><F9> <Plug>VimspectorToggleConditionalBreakpoint
  nmap <F8>         <Plug>VimspectorAddFunctionBreakpoint
  nmap <leader><F8> <Plug>VimspectorRunToCursor
  nmap <F10>        <Plug>VimspectorStepOver
  nmap <F11>        <Plug>VimspectorStepInto
  nmap <F12>        <Plug>VimspectorStepOut
endif

command! -bar -nargs=1 -complete=custom,vimspector#CompleteExpr
      \ VimspectorWatch
      \ call vimspector#AddWatch( <f-args> )
command! -bar -nargs=? -complete=custom,vimspector#CompleteOutput
      \ VimspectorShowOutput
      \ call vimspector#ShowOutput( <f-args> )
command! -bar
      \ VimspectorToggleLog
      \ call vimspector#ToggleLog()
command! -nargs=1 -complete=custom,vimspector#CompleteExpr
      \ VimspectorEval
      \ call vimspector#Evaluate( <f-args> )
command! -bar
      \ VimspectorReset
      \ call vimspector#Reset( { 'interactive': v:true } )

" Installer commands
command! -bar -bang -nargs=* -complete=custom,vimspector#CompleteInstall
      \ VimspectorInstall
      \ call vimspector#Install( <q-bang>, <f-args> )
command! -bar -bang -nargs=*
      \ VimspectorUpdate
      \ call vimspector#Update( <q-bang>, <f-args> )
command! -bar -nargs=0
      \ VimspectorAbortInstall
      \ call vimspector#AbortInstall()



" Dummy autocommands so that we can call this whenever
augroup VimspectorUserAutoCmds
  autocmd!
  autocmd User VimspectorUICreated      silent
  autocmd User VimspectorTerminalOpened silent
  autocmd user VimspectorJumpedToFrame  silent
  autocmd user VimspectorDebugEnded     silent
augroup END

" FIXME: Only register this _while_ debugging is active
augroup Vimspector
  autocmd!
  autocmd BufNew * call vimspector#OnBufferCreated( expand( '<afile>' ) )
augroup END

" boilerplate {{{
call s:restore_cpo()
" }}}

