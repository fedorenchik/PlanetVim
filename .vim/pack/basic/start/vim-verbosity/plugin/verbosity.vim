"--------------------------------------------------------------------------
" Verbosity
" VIM Plugin for toggling verbose mode and viewing the output
"--------------------------------------------------------------------------

" Functions
"--------------------------------------------------------------------------
function! verbosity#enable(...) abort
    if s:verbosity_enabled is 0
        call verbosity#addTimestamp(substitute('E-N-D', '-', '', 'g'))
    endif

    if v:count > 0
        let l:verbosity_level = v:count
    elseif a:0 > 0 && a:1 > 0
        let l:verbosity_level = a:1
    else
        let l:verbosity_level = s:verbosity_current_level
    endif

    let s:verbosity_current_level = l:verbosity_level
    let s:verbosity_current_file = verbosity#getNewFileName()
    let &verbosefile = s:verbosity_current_file
    let &verbose = l:verbosity_level
    call verbosity#addTimestamp(substitute('S-T-A-R-T', '-', '', 'g'))
    let s:verbosity_enabled = 1
    call verbosity#echoMessage('Enabled verbose logging at level ' . l:verbosity_level . ' on file ' . s:verbosity_current_file)
endfunction


function! verbosity#disable() abort
    let l:verbosity_was_enabled = s:verbosity_enabled
    let s:verbosity_enabled = 0
    call verbosity#echoMessage('Disabled verbose logging')

    if l:verbosity_was_enabled is 1
        call verbosity#addTimestamp(substitute('E-N-D', '-', '', 'g'))
    endif

    let &verbose = 0
    let &verbosefile = ''
endfunction


function! verbosity#toggle(...) abort
    if a:0 > 0
        let l:verbosity_level = a:1
    else
        let l:verbosity_level = 0
    endif

    if s:verbosity_enabled is 1
        call verbosity#disable()
    else
        call verbosity#enable(l:verbosity_level)
    endif
endfunction


function! verbosity#addTimestamp(label) abort
    if s:verbosity_current_file ==# ''
        return
    endif

    let l:black_hole = ''
    redir => l:black_hole
    silent echo repeat('=', 10) . ' ' . strftime('%F %T') . ' ' .
        \repeat('=', 10) . substitute(' V-E-R-B-O-S-E', '-', '', 'g') .
        \' ' . a:label .
        \' L' . s:verbosity_current_level .
        \' ' . repeat('=', 10)
    redir END
endfunction


function! verbosity#echoMessage(message) abort
    echohl Label
    echo a:message
    echohl None
endfunction


function! verbosity#openLastLog() abort
    if s:verbosity_current_file ==# ''
        echohl ErrorMsg
        echo 'No current verbose log file found'
        echohl None
        return
    end

    execute 'vsplit ' . s:verbosity_current_file
endfunction


function! verbosity#getDefaultLogLevel() abort
    if exists('g:verbosity_default_level')
        return g:verbosity_default_level
    endif

    return 10
endfunction


function! verbosity#getLogDirectory() abort
    if exists('g:verbosity_log_directory')
        let l:dir_path = g:verbosity_log_directory

        if !isdirectory(l:dir_path)
            call mkdir(l:dir_path, 'p', 0700)
        endif
    else
        let l:tmp_name = tempname()
        let l:dir_path = fnamemodify(l:tmp_name, ':h')
    endif

    return l:dir_path
endfunction


function! verbosity#getNewFileName() abort
    let l:date_time = strftime('%Y%m%d-%H%M%S')
    return s:verbosity_log_directory . '/vim-verbosity-' . l:date_time . '.log'
endfunction


function! verbosity#deleteAllLogs() abort
    let l:log_files = split(globpath(s:verbosity_log_directory, 'vim-verbosity-*.log'), '\n')

    for l:log_file in l:log_files
        call delete(l:log_file)
    endfor

    call verbosity#echoMessage('Deleted ' . len(l:log_files) . ' verbosity file(s)')
endfunction


" Custom syntax highlighting
"--------------------------------------------------------------------------
function! verbosity#applySyntaxHighlighting() abort
    " Headers
    syn match VerbosityHeader /\v^\={10} [0-9-]+ [0-9:]+ \={10} \w+ \w+ L\d+ \={10}/ contains=VerbosityHeaderBlock,VerbosityTimestamp,VerbosityStartMessage,VerbosityEndMessage
    syn match VerbosityHeaderBlock contained /\v\={10}/
    syn match VerbosityTimestamp contained /\v[0-9-]+ [0-9:]+/
    syn match VerbosityStartMessage contained /\vV[E]R[B]O[S]E [S]T[A]R[T] L\d+/
    syn match VerbosityEndMessage contained /\vV[E]R[B]O[S]E [E]N[D] L\d+/

    " Enable/Disable echos
    syn match VerbosityStartEcho /\v^E[n]a[b]l[e]d [v]e[r]b[o]s[e] logging at.+$/
    syn match VerbosityEndEcho /\v^D[i]s[a]b[l]e[d] [v]e[r]b[o]s[e] logging$/

    " Auto commands
    syn match VerbosityExecuteLine /\v^(E[x]e[c]u[t]i[n]g|c[o]n[t]i[n]u[i]n[g] in) \w+ A[u]t[o] commands for "[^"]*"$/ contains=VerbosityAutoName,VerbosityString
    syn match VerbosityAuto /\v^a[u]t[o]c[o]m[m]a[n]d /
    syn match VerbosityAutoName contained /\v[gn] \w+ A/ms=s+2,me=e-2

    " Functions
    syn match VerbosityFunctionLine /\v^(c[a]l[l]i[n]g|c[o]n[t]i[n]u[i]n[g] in) [f]u[n]c[t]i[o]n .+$/ contains=VerbosityFunctionName,VerbosityString,VerbosityHashNumber
    syn match VerbosityFunctionReturnLine /\v^f[u]n[c]t[i]o[n] [^ ]+ r[e]t[u]r[n]i[n]g .+$/ contains=VerbosityFunctionName,VerbosityString,VerbosityHashNumber
    syn match VerbosityFunctionName contained /\vo[n] [^ (]+/ms=s+3
    syn match VerbosityFunctionCounter /\v^l[i]n[e] \d+:/

    " Errors
    syn match VerbosityError /\v^E\d+: .+$/

    " Constants
    syn match VerbosityString contained /\v("[^"]*"|'[^']*')/
    syn match VerbosityHashNumber contained /\v#\d+/

    " Highlight group links
    hi def link VerbosityHeaderBlock Comment
    hi def link VerbosityTimestamp Label
    hi def link VerbosityStartMessage DiffAdded
    hi def link VerbosityEndMessage DiffRemoved
    hi def link VerbosityStartEcho DiffAdded
    hi def link VerbosityEndEcho DiffRemoved
    hi def link VerbosityExecuteLine Title
    hi def link VerbosityAuto Keyword
    hi def link VerbosityAutoName Keyword
    hi def link VerbosityFunctionLine Title
    hi def link VerbosityFunctionReturnLine Title
    hi def link VerbosityFunctionName Identifier
    hi def link VerbosityFunctionCounter Comment
    hi def link VerbosityError ErrorMsg
    hi def link VerbosityString String
    hi def link VerbosityHashNumber Number
endfunction


" Variable definitions
"--------------------------------------------------------------------------
let s:verbosity_enabled = 0
let s:verbosity_current_level = verbosity#getDefaultLogLevel()
let s:verbosity_current_file = ''
let s:verbosity_log_directory = verbosity#getLogDirectory()


" Plug mappings
"--------------------------------------------------------------------------
nnoremap <silent> <Plug>(verbosity-enable) :<c-u>call verbosity#enable()<CR>
nnoremap <silent> <Plug>(verbosity-disable) :call verbosity#disable()<CR>
nnoremap <silent> <Plug>(verbosity-toggle) :<c-u>call verbosity#toggle()<CR>
nnoremap <silent> <Plug>(verbosity-open-last) :call verbosity#openLastLog()<CR>
nnoremap <silent> <Plug>(verbosity-delete-all) :call verbosity#deleteAllLogs()<CR>


" Default key bindings
"--------------------------------------------------------------------------
nmap <silent> [oV <Plug>(verbosity-enable)
nmap <silent> ]oV <Plug>(verbosity-disable)
nmap <silent> =oV <Plug>(verbosity-toggle)
nmap <silent> goV <Plug>(verbosity-open-last)
nmap <silent> doV <Plug>(verbosity-delete-all)


" Commands
"--------------------------------------------------------------------------
command! -count=0 VerbosityEnable :call verbosity#enable(<count>)
command! -count=0 VerbosityDisable :call verbosity#disable()
command! -count=0 VerbosityToggle :call verbosity#toggle(<count>)
command! VerbosityOpenLast :call verbosity#openLastLog()
command! VerbosityDeleteAll :call verbosity#deleteAllLogs()


" Autocommands
"--------------------------------------------------------------------------
augroup verbosity
    au!
    au BufNewFile,BufRead vim-verbosity-*.log call verbosity#applySyntaxHighlighting()
augroup end
