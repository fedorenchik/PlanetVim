" Vimball Archiver by Charles E. Campbell
UseVimball
finish
autoload/conque_gdb.vim	[[[1
607

" dependency
if !exists('g:plugin_conque_gdb_loaded')
    runtime! plugin/conque_gdb.vim
endif

if exists('g:autoload_conque_gdb_loaded') || g:ConqueGdb_Disable
    finish
endif

let g:autoload_conque_gdb_loaded = 1

" Path to gdb python scripts
let s:SCRIPT_DIR = expand("<sfile>:h") . '/conque_gdb/'

" Conque term terminal object
let s:gdb = {'idx': 1, 'active': 0, 'buffer_number': -1}

" Buffer number of the current source file, opened by gdb
let s:src_buf = -1

" Window number of the current source file, opened by gdb
let s:src_bufwin = -1

" True if the terminal being opened currently is a gdb terminal
let s:is_gdb_startup = 0

" Name of the sign showing up when a break point has been reached
let s:SIGN_POINTER = 'conque_gdb_sign_pointer'

" Sign name of enabled break points
let s:SIGN_ENABLED = 'conque_gdb_break_enabled'

" Sign name of disabled break points
let s:SIGN_DISABLED = 'conque_gdb_break_disabled'

" Start pointer sign from this value
let s:SIGN_POINTER_VAL = 15605

" Current id of the break point pointer sign
let s:sign_pointer_id = s:SIGN_POINTER_VAL

" Name of the file containing the sign which will be removed next
let s:sign_file = ''

" Line number of current sign
let s:sign_line = -1

" List of buffers opened by ConqueGdb
let s:opened_buffers = {}

" OS platform ('unix') or ('win')
let s:platform = ''

" Python version
let s:py = ''

" How to execute gdb
let s:gdb_command = ''

" true if gdb supports python
let g:conque_gdb_gdb_py_support = 0

" Which python object to use for terminal emulating ('ConqueGdb()') for Unix
" and ('ConqueSoleGdb()') for Windows
let s:term_object = ''

" Original path to the GDB executable
let s:orig_gdb_path = g:ConqueGdb_GdbExe

" Define the current gdb break point sign
sil exe 'sign define ' . s:SIGN_POINTER . ' linehl=Search'

" Define sign for enabled break points
sil exe 'sign define ' . s:SIGN_ENABLED . ' text=>> texthl=ErrorMsg'

" Define sign for disabled break points
sil exe 'sign define ' . s:SIGN_DISABLED . ' text=>> texthl=WarningMsg'

" How to escape file names before passing them to python.
function! s:escape_to_py_file(fname)
    let l:fname = a:fname
    let l:fname = substitute(l:fname, '\\', '\\\\\\\\', 'g')
    let l:fname = substitute(l:fname, '"', '\\"', 'g')
    return l:fname
endfunction

" Attempt to escape file names before opening them for edit/view
function! s:escape_to_shell_file(fname)
    if s:platform != 'win'
        let l:fname = substitute(a:fname, '\\', '\\\\', 'g')
        let l:fname = substitute(l:fname, '"', '\\"', 'g')
        let l:fname = substitute(l:fname, '`', '\\`', 'g')
        let l:fname = substitute(l:fname, ' ', '\\ ', 'g')
        let l:fname = substitute(l:fname, '*', '\\*', 'g')
        let l:fname = substitute(l:fname, '#', '\\#', 'g')
        let l:fname = substitute(l:fname, '{', '\\{', 'g')
        let l:fname = substitute(l:fname, '}', '\\}', 'g')
        let l:fname = substitute(l:fname, '[', '\\[', 'g')
        let l:fname = substitute(l:fname, ']', '\\]', 'g')
    else
        let l:fname = a:fname
    endif
    return l:fname
endfunction

" Python substitutes the "'" character with "\n" before calling vim functions.
" Use this function to substitute it back again!
function! s:file_from_python(fname)
    return substitute(a:fname, "\n", "'", 'g')
endfunction

" Place a break point sign indicating there is a gdb break point at
" file a:fname, line number a:lineno.
" a:enabled == 0 if the break point should be marked as disabled.
function! conque_gdb#set_breakpoint_sign(id, fname, lineno, enabled)
    let l:fname = s:file_from_python(a:fname)

    let l:bufname = bufname(l:fname)
    if l:bufname == ""
        return
    endif

    if a:enabled == 'y'
        let l:name = s:SIGN_ENABLED
    else
        let l:name = s:SIGN_DISABLED
    endif
    try
        sil exe 'sign place ' . a:id . ' line=' . a:lineno . ' name=' . l:name . ' buffer=' . bufnr(l:bufname)
    catch
    endtry
endfunction

" Remove the break point sign with id a:id in file a:fname.
function! conque_gdb#remove_breakpoint_sign(id, fname)
    let l:fname = s:file_from_python(a:fname)
    
    let l:bufname = bufname(l:fname)
    if l:bufname == ""
        return
    endif

    try
        sil exe 'sign unplace ' . a:id . ' buffer=' . bufnr(l:bufname)
    catch
    endtry
endfunction

" Place sign indication a break point has been hit and the execution has
" stopped in file a:fname, line number a:lineno.
function! s:set_pointer(id, fname, lineno)
    let l:bufname = bufname(a:fname)
    if l:bufname == ""
        return
    endif
    try
        sil exe 'sign place ' . a:id . ' line=' . a:lineno . ' name=' . s:SIGN_POINTER . ' buffer=' . bufnr(l:bufname)
    catch
        echohl WarningMsg | echomsg 'ConqueGdb: Unable to place sign in source file ' . a:fname | echohl None
    endtry
endfunction

" Remove previous sign that indicated where the execution was stopped.
function! conque_gdb#remove_prev_pointer()
    if s:sign_file != ''
        let l:bufname = bufname(s:sign_file)
        if l:bufname == ""
            return
        endif

        try
            sil exe 'sign unplace ' . s:sign_pointer_id . ' buffer=' . bufnr(l:bufname)
        catch
        endtry

		let s:sign_file = ''
    endif
endfunction

" Set a new sign in file a:fname at line number a:lineno.
" And remove the previous sign
function! conque_gdb#update_pointer(fname, lineno)
    let l:next_pointer_id = s:sign_pointer_id % 2 + s:SIGN_POINTER_VAL
    if a:fname != ''
        call s:set_pointer(l:next_pointer_id, a:fname, a:lineno)
    endif
    call conque_gdb#remove_prev_pointer()
    let s:sign_pointer_id = l:next_pointer_id
    let s:sign_file = a:fname
    let s:sign_line = a:lineno
endfunction

function! s:buf_update()
    if s:platform != 'win'
        if col(".") == col("$")
            call feedkeys("\<Right>")
        else
            call feedkeys("\<Right>\<Left>")
        endif
    endif
endfunction

" Remove a written buffer from the list of buffers ConqueGdb has opened
function! s:src_buf_written()
    try
        sil autocmd! conque_gdb_src_write_augroup BufWritePre <buffer>
        if has_key(s:opened_buffers, bufnr("%"))
            call remove(s:opened_buffers, bufnr("%"))
        endif
    catch
    endtry
endfunction

" Open file a:fname at line number a:lineno.
" a:perm specifies how to open the file 
" read only ('r') or read-write ('w').
function! s:open_file(fname, lineno, perm)
    let l:fbufname = bufname(a:fname)
    if l:fbufname == "" || !bufloaded(bufnr(l:fbufname))
        let l:opened_by_gdb = 1
    else
        let l:opened_by_gdb = 0
    endif

    if bufexists(a:fname)
        let l:method = 'buffer ' . bufnr(bufname(a:fname))
    elseif a:perm == 'w'
        let l:method = 'edit ' . a:fname
    else
        let l:method = 'view ' . a:fname
    endif

    if bufwinnr(s:src_buf) == bufwinnr(s:gdb.buffer_number)
        if !l:opened_by_gdb && bufwinnr(l:fbufname) != -1
            sil noautocmd wincmd p
            sil exe 'noautocmd ' . bufwinnr(l:fbufname) . 'wincmd w'
        else
            sil exe 'noautocmd ' . get(g:conque_gdb_src_splits, g:ConqueGdb_SrcSplit, g:conque_gdb_default_split)
        endif
    elseif bufwinnr(s:src_buf) == -1
        sil exe get(g:conque_gdb_src_splits, g:ConqueGdb_SrcSplit, g:conque_gdb_default_split)
    elseif winbufnr(s:src_bufwin) == s:src_buf
        sil noautocmd wincmd p
        sil exe 'noautocmd ' . s:src_bufwin . 'wincmd w'
    else
        sil noautocmd wincmd p
        sil exe 'noautocmd ' . bufwinnr(s:src_buf) . 'wincmd w'
    endif

    sil exe 'noautocmd ' . l:method

    let s:src_buf = bufnr("%")
    let s:src_bufwin = winnr()

    if l:opened_by_gdb
        let s:opened_buffers[s:src_buf] = 1
        augroup conque_gdb_src_write_augroup
        autocmd conque_gdb_src_write_augroup BufWritePre <buffer> call s:src_buf_written()
        augroup END
        if g:conque_gdb_gdb_py_support
            sil exe s:py . ' ' . s:gdb.var . '.place_file_breakpoints("' . s:escape_to_py_file(expand('%:p')) . '")'
        endif
    endif

    " For some reason vim doesn't always detect the file type.
    " So we do it manually here if we have opened the file.
    if l:opened_by_gdb
        sil filetype detect
    else
        sil exe 'set filetype=' . &filetype
    endif
endfunction

" Move the gdb break point sign to file a:fname, line number a:lineno
" The "\n" character is interpreted as "'".
function! conque_gdb#breakpoint(fname, lineno)
    let l:fname_py = s:file_from_python(a:fname)
    let l:lineno = a:lineno

    if filewritable(l:fname_py)
        let l:perm = 'w'
    elseif filereadable(l:fname_py)
        let l:perm = 'r'
    else
        let l:perm = ''
    endif

    let l:fname = s:escape_to_shell_file(l:fname_py)

    if l:perm != ''
        let l:last_win = winnr()
        let l:last_buf = bufnr("%")
        call s:open_file(l:fname, l:lineno, l:perm)

        sil noautocmd wincmd p
        sil exe 'noautocmd ' . s:src_bufwin . 'wincmd w'
        sil exe ':' . a:lineno
        sil normal! zz

        call conque_gdb#update_pointer(l:fname_py, l:lineno) 
        call s:buf_update()

        if l:last_buf != winbufnr(l:last_win)
            let l:last = bufwinnr(l:last_buf)
            if l:last != -1
                let l:last_win = l:last
            endif
        endif
        sil noautocmd wincmd p
        sil exe 'noautocmd ' . l:last_win . ' wincmd w'
    else
        " Gdb should detect that the file can't be opened. This should not happen.
        echohl WarningMsg | echomsg 'ConqueGdb: Unable to open file ' . a:fname | echohl None
        let l:fname = ''
        let l:lineno = 0
    endif
endfunction

" Get command to execute gdb on Unix
function! s:get_unix_gdb()
    if g:ConqueGdb_GdbExe != ''
        let l:gdb_exe = g:ConqueGdb_GdbExe
    else
        let l:gdb_exe = 'gdb'
    endif
    if !executable(l:gdb_exe)
        return ''
    endif

    let pyresp = "'PYYES'"
    sil let l:gdb_py_support = system(l:gdb_exe . ' -q -batch -ex "python print(' . pyresp . ')"')
    if l:gdb_py_support =~ ".*PYYES\n.*"
        " Gdb has python support
        let g:conque_gdb_gdb_py_support = 1
        return l:gdb_exe . ' -f -x ' . s:SCRIPT_DIR . 'conque_gdb_gdb.py'
    else
        " No python pupport
        let g:conque_gdb_gdb_py_support = 0
        return l:gdb_exe . ' -f'
    endif
endfunction

" Get command to execute gdb on Windows
function! s:get_win_gdb()
    let g:conque_gdb_gdb_py_support = 0

    if g:ConqueGdb_GdbExe != ''
        if executable(g:ConqueGdb_GdbExe)
            return g:ConqueGdb_GdbExe
        else
            return ''
        endif
    endif

    let sys_paths = split($PATH, ';')

    " Try to add path to MinGW gdb.exe
    call add(sys_paths, 'C:\MinGW\bin')
    call reverse(sys_paths)

    " check if gdb.exe is in paths
    for path in sys_paths
        let cand = path . '\gdb.exe'
        if executable(cand)
            return cand . ' -f'
        endif
    endfor

    return ''
endfunction

" Return command to execute gdb
function! s:get_gdb_command()
    if s:platform != 'win'
        return s:get_unix_gdb()
    endif
    return s:get_win_gdb()
endfunction

" Open a new gdb terminal.
" If a gdb terminal is already running then open this and do not open a new one.
function! conque_gdb#open(...)
    let s:src_buf = bufnr("%")
    let l:start_cmds = get(a:000, 1, [])

    if bufloaded(s:gdb.buffer_number) && s:gdb.active
        echohl WarningMsg | echomsg "GDB already running" | echohl None

        if bufwinnr(s:gdb.buffer_number) == -1
            " Open the existing gdb buffer with the start commands
            for c in l:start_cmds
                sil exe c
            endfor 
            sil exe 'buffer ' . s:gdb.buffer_number
        else
            " Move cursor to the visible gdb window
            sil exe bufwinnr(s:gdb.buffer_number) . 'wincmd w'
        endif

        if g:ConqueTerm_InsertOnEnter == 1
            startinsert!
        endif
    else
        " Find out if gdb was found on the system
        if s:gdb_command == ''
            echohl WarningMsg
            echomsg "ConqueGdb: Unable to find gdb executable, see :help ConqueGdb_GdbExe and :help ConqueGdbExe for more information."
            echohl None
            return
        endif

        " Find out which gdb command script gdb should execute on startup.
        sil let l:enable_confirm = system(s:gdb_command . ' -q -batch -ex "show confirm"')
        if l:enable_confirm =~ '.*\s\+[Oo][Nn]\W.*'
            let l:extra = ' -x ' . s:SCRIPT_DIR . 'gdbinit_confirm.gdb '
        else
            let l:extra = ' -x ' . s:SCRIPT_DIR . 'gdbinit_no_confirm.gdb '
        endif

        " Don't let user use the TUI feature. It does not work with ConqueGdb.
        let l:user_args = get(a:000, 0, '')
        if l:user_args =~ '\(.*\s\+\|^\)-\+tui\($\|\s\+.*\)'
            echohl WarningMsg
            echomsg 'ConqueGdb: GDB Text User Interface (--tui) is not supported'
            echohl None
            return
        endif

        let l:gdb_cmd = s:gdb_command . l:extra . l:user_args
        let s:is_gdb_startup = 1
        try
            let s:gdb = conque_term#open(l:gdb_cmd, l:start_cmds, get(a:000, 2, 0), get(a:000, 3, 1), s:term_object)
            sil exe 'file ConqueGDB\#' . s:gdb.idx
        catch
        endtry
        let s:is_gdb_startup = 0
    endif
	let s:src_bufwin = winnr("#")
endfunction

" Send a command to the gdb subprocess.
function! conque_gdb#command(cmd)
    if !(bufloaded(s:gdb.buffer_number) && s:gdb.active)
        echohl WarningMsg | echomsg "GDB is not running" | echohl None
        return
    endif

    if bufwinnr(s:gdb.buffer_number) == -1
        let s:src_buf = bufnr("%")
        let s:src_bufwin = winnr()
        sil exe 'noautocmd ' . get(g:conque_gdb_src_splits, g:ConqueGdb_SrcSplit, g:conque_gdb_default_split)
        sil exe 'noautocmd wincmd w'
        sil exe 'noautocmd buffer ' . s:gdb.buffer_number
        sil exe 'noautocmd wincmd p'
    endif

    let l:win = winnr()
    let l:buf_win = bufwinnr(s:gdb.buffer_number)
    if l:win != l:buf_win
        sil noautocmd wincmd p
        sil exe 'noautocmd ' . l:buf_win . 'wincmd w'
        let l:go_back = 1
    else
        let l:go_back = 0
    endif

    if g:ConqueGdb_SaveHistory
        let l:cmd_prefix = ''
    else
        let l:cmd_prefix = 'server '
    endif
    call s:gdb.writeln(l:cmd_prefix . a:cmd)

    if s:platform == 'win'
        exe 'sleep ' . g:ConqueGdb_ReadTimeout . 'ms'
    endif
    call s:gdb.read(g:ConqueGdb_ReadTimeout)

    if l:go_back
        sil noautocmd wincmd p
	    sil exe 'noautocmd ' . l:win . 'wincmd w'
    endif
endfunction

" print word under cursor.
" Only supported on Unix where gdb supports the python API.
function! conque_gdb#print_word(cword)
    if a:cword != ''
        call conque_gdb#command("print " . a:cword)
    endif
endfunction

" Set/Clear break point in file a:fullfile, line a:line
" Note that this is only supported on Unix where gdb has support for the
" python API.
function! conque_gdb#toggle_breakpoint(fullfile, line)
	let l:command = "clear "
    if bufloaded(s:gdb.buffer_number) || s:gdb.active
        sil exe s:py . ' ' . s:gdb.var . '.vim_toggle_breakpoint("' . s:escape_to_py_file(a:fullfile) .'","'. a:line .'")'
    endif
    call conque_gdb#command(l:command . a:fullfile . ':' . a:line)
endfunction

" Restore state of script to indicate gdb has terminated
function! s:restore()
    try
        autocmd! conque_gdb_augroup
        call conque_gdb#remove_prev_pointer()
        if g:conque_gdb_gdb_py_support
            sil exe s:py . ' ' . s:gdb.var . '.remove_all_signs()'
        endif
    catch
    endtry
    let s:src_buf = -1
    let s:src_bufwin = -1
    let s:sign_file = ''
    let s:sign_line = -1
endfunction

" Delete buffers opened by ConqueGdb
function! conque_gdb#delete_opened_buffers()
    for buf in keys(s:opened_buffers)
        try
            sil exe 'bdelete ' . buf
        catch
        endtry
    endfor
    let s:opened_buffers = {}
endfunction

" Called on BufWinEnter to find out when the user opens a new buffer in the
" source window. Use this window for source code when break points are hit.
function! s:buf_win_enter()
    if winnr() == s:src_bufwin
        if bufwinnr(s:src_buf) != -1
            let s:src_bufwin = bufwinnr(s:src_buf)
        else
            let s:src_buf = bufnr("%")
        endif
    endif
endfunction

" Called on BufReadPost.
" Place sign indicating where there are break points in the newly opened file
" if necessary. Maybe the sign indicating where the execution has stopped
" should be placed in this file also.
function! s:buf_read_post()
    let l:sign_bufname = bufname(s:sign_file)
    if l:sign_bufname != "" && bufnr(l:sign_bufname) == bufnr("%")
        call conque_gdb#update_pointer(s:sign_file, s:sign_line)
    endif
    if g:conque_gdb_gdb_py_support
        sil exe s:py . ' ' . s:gdb.var . '.place_file_breakpoints("' . s:escape_to_py_file(expand('%:p')) . '")'
    endif
endfunction

" Called after new conque terminals start up
function! conque_gdb#after_startup(term)
    if s:is_gdb_startup
        " The gdb terminal has started up
        augroup conque_gdb_augroup
        autocmd!
        autocmd conque_gdb_augroup BufUnload <buffer> call s:restore()
        autocmd conque_gdb_augroup BufWinEnter * call s:buf_win_enter()
        autocmd conque_gdb_augroup BufReadPost * call s:buf_read_post()
        augroup END
    endif
endfunction

" Called when the programs inside conque terminals terminate
function! conque_gdb#after_close(term)
    if a:term.idx == s:gdb.idx
        call s:restore()
    endif
endfunction

" Function to load the python files and setup the script.
" This must be done before calling any other function in this script.
function! conque_gdb#load_python()
    if conque_term#dependency_check(0)
        let s:py = conque_term#get_py()
        if has('unix')
            let s:platform = 'unix'
            let s:term_object = 'ConqueGdb()'
            exe s:py . "file " . s:SCRIPT_DIR . "conque_gdb.py"
        else
            let s:platform = 'win'
            let s:term_object = 'ConqueSoleGdb()'
            exe s:py . "file " . s:SCRIPT_DIR . "conque_sole_gdb.py"
        endif
    endif
    let s:gdb_command = s:get_gdb_command()
endfunction

" Change path to GDB executable at runtime.
function! conque_gdb#change_gdb_exe(gdb_path)
    if a:gdb_path == ""
        let g:ConqueGdb_GdbExe = s:orig_gdb_path
    else
        let g:ConqueGdb_GdbExe = a:gdb_path
    endif
    let s:gdb_command = s:get_gdb_command()
endfunction

call conque_term#register_function('after_startup', 'conque_gdb#after_startup')
call conque_term#register_function('after_close', 'conque_gdb#after_close')
autoload/conque_term.vim	[[[1
1656
" FILE:     autoload/conque_term.vim {{{
" AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
" WEBSITE:  http://conque.googlecode.com
" MODIFIED: 2011-09-12
" VERSION:  2.3, for Vim 7.0
" LICENSE:
" Conque - Vim terminal/console emulator
" Copyright (C) 2009-2011 Nico Raffo 
"
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}

" **********************************************************************************************************
" **** GLOBAL INITIALIZATION *******************************************************************************
" **********************************************************************************************************

" {{{

" Don't source twice
if exists('g:ConqueTerm_TermLoaded')
    finish
endif
let g:ConqueTerm_TermLoaded = 1

" load plugin file if it hasn't already been loaded (e.g. conque_term#foo() is used in .vimrc)
if !exists('g:ConqueTerm_Loaded')
    runtime! plugin/conque_term.vim
endif

" path to conque install directories
let s:scriptdir = expand("<sfile>:h") . '/'
let s:scriptdirpy = expand("<sfile>:h") . '/conque_term/'

" global list of terminal instances
let s:term_obj = {'idx': 1, 'var': '', 'is_buffer': 1, 'active': 1, 'buffer_name': '', 'buffer_number' : -1, 'command': ''}
let g:ConqueTerm_Terminals = {}

" global lists of registered functions
let s:hooks = { 'after_startup': [], 'buffer_enter': [], 'buffer_leave': [], 'after_keymap': [], 'after_close': [] }

" Number of currently opened terminals
let s:term_count = 0

" required for session support
if g:ConqueTerm_SessionSupport == 1
    set sessionoptions+=globals
    try
        sil! let s:saved_terminals = eval(g:ConqueTerm_TerminalsString)
    catch
        let s:saved_terminals = {}
    endtry
endif

" more session support
let g:ConqueTerm_TerminalsString = ''

" init terminal counter
let g:ConqueTerm_Idx = 0

" to save the users &updatetime. This is not a constant
let s:save_updatetime = &updatetime

" if nonzero restore the &updatetime when all terminals are closed
let s:reset_updatetime = 1

" have we called the init() function yet?
let s:initialized = 0

" }}}

" **********************************************************************************************************
" **** SYSTEM DETECTION ************************************************************************************
" **********************************************************************************************************

" {{{

" Display various error messages
function! conque_term#fail(feature) " {{{

    " create a new buffer
    new
    setlocal buftype=nofile
    setlocal nonumber
    setlocal foldcolumn=0
    setlocal wrap
    setlocal noswapfile

    " missing vim features
    if a:feature == 'python'

        call append('$', 'Conque ERROR: Python interface cannot be loaded')
        call append('$', '')

        if !executable("python")
            call append('$', 'Your version of Vim appears to be installed without the Python interface. In ')
            call append('$', 'addition, you may need to install Python.')
        else
            call append('$', 'Your version of Vim appears to be installed without the Python interface.')
        endif

        call append('$', '')

        if has('unix') == 1
            call append('$', "You are using a Unix-like operating system. Most, if not all, of the popular ")
            call append('$', "Linux package managers have Python-enabled Vim available. For example ")
            call append('$', "vim-gnome or vim-gtk on Ubuntu will get you everything you need.")
            call append('$', "")
            call append('$', "If you are compiling Vim from source, make sure you use the --enable-pythoninterp ")
            call append('$', "configure option. You will also need to install Python and the Python headers.")
            call append('$', "")
            call append('$', "If you are using OS X, MacVim will give you Python support by default.")
        else
            call append('$', "You appear to be using Windows. The official Vim 7.3 installer available at ")
            call append('$', "http://www.vim.org comes with the required Python interfaces. You will also ")
            call append('$', "need to install Python 2.7 and/or Python 3.1, both available at http://www.python.org")
        endif

    elseif a:feature == 'python_exe'

        call append('$', "Conque ERROR: Can't find Python executable")
        call append('$', "")
        call append('$', "Conque needs to know the full path to python.exe on Windows systems. By default, ")
        call append('$', "Conque will check your system path as well as the most common installation path ")
        call append('$', "C:\\PythonXX\\python.exe. To fix this error either:")
        call append('$', "")
        call append('$', "Set the g:ConqueTerm_PyExe option in your .vimrc. E.g.")
        call append('$', "        let g:ConqueTerm_PyExe = 'C:\Program Files\Python27\python.exe'")
        call append('$', "")
        call append('$', "Add the directory where you installed python to your system path. This isn't a bad ")
        call append('$', "idea in general.")

    elseif a:feature == 'ctypes'

        call append('$', 'Conque ERROR: Python cannot load the ctypes module')
        call append('$', "")
        call append('$', "Conque requires the 'ctypes' python module. This has been a standard module since Python 2.5.")
        call append('$', "")
        call append('$', "The recommended fix is to make sure you're using the latest official GVim version 7.3, ")
        call append('$', "and have at least one of the two compatible versions of Python installed, ")
        call append('$', "2.7 or 3.1. You can download the GVim 7.3 installer from http://www.vim.org. You ")
        call append('$', "can download the Python 2.7 or 3.1 installer from http://www.python.org")

    endif

endfunction " }}}

" Go through various system checks before attempting to launch conque
function! conque_term#dependency_check(...) " {{{
    let show_messages = get(a:000, 0, 1)

    " don't recheck the second time 'round
    if s:initialized == 1
        return 1
    endif

    " choose a python version
    let s:py = ''
    if g:ConqueTerm_PyVersion == 3
        let pytest = 'python3'
    else
        let pytest = 'python'
        let g:ConqueTerm_PyVersion = 2
    endif

    " first test the requested version
    if has(pytest)
        if pytest == 'python3'
            let s:py = 'py3'
        else
            let s:py = 'py'
        endif

    " otherwise use the other version
    else
        let py_alternate = 5 - g:ConqueTerm_PyVersion
        if py_alternate == 3
            let pytest = 'python3'
        else
            let pytest = 'python'
        endif
        if has(pytest)
            if show_messages
                echohl WarningMsg | echomsg "Python " . g:ConqueTerm_PyVersion . " interface is not installed, using Python " . py_alternate . " instead" | echohl None
            endif
            let g:ConqueTerm_PyVersion = py_alternate
            if pytest == 'python3'
                let s:py = 'py3'
            else
                let s:py = 'py'
            endif
        endif
    endif

    " test if we actually found a python version
    if s:py == ''
        if show_messages
            call conque_term#fail('python')
        endif
        return 0
    endif

    " quick and dirty platform declaration
    if has('unix') == 1
        let s:platform = 'unix'
        sil exe s:py . " CONQUE_PLATFORM = 'unix'"
    else
        let s:platform = 'windows'
        sil exe s:py . " CONQUE_PLATFORM = 'windows'"
    endif

    " if we're using Windows, make sure ctypes is available
    if s:platform == 'windows'
        try
            sil exe s:py . " import ctypes"
        catch
            if show_messages
                call conque_term#fail('ctypes')
            endif
            return 0
        endtry
    endif

    " if we're using Windows, make sure we can finde python executable
    if s:platform == 'windows' && conque_term#find_python_exe() == ''
        if show_messages
            call conque_term#fail('python_exe')
        endif
        return 0
    endif

    " check for global cursorhold/cursormove events
    let o = ''
    silent redir => o
    silent autocmd CursorHoldI,CursorMovedI
    redir END
    for line in split(o, "\n")
        if line =~ '^ ' || line =~ '^--' || line =~ 'matchparen'
            continue
        endif
        if g:ConqueTerm_StartMessages && show_messages
            echohl WarningMsg | echomsg "Warning: Global CursorHoldI and CursorMovedI autocommands may cause ConqueTerm to run slowly." | echohl None
        endif
    endfor

    " check for compatible mode
    if &compatible == 1 && show_messages
        echohl WarningMsg | echomsg "Warning: Conque may not function normally in 'compatible' mode." | echohl None
    endif

    " check for fast mode
    if g:ConqueTerm_FastMode
        sil exe s:py . " CONQUE_FAST_MODE = True"
    else
        sil exe s:py . " CONQUE_FAST_MODE = False"
    endif

    " if we're all good, load python files
    call conque_term#load_python()

    return 1

endfunction " }}}

" }}}

" **********************************************************************************************************
" **** STARTUP MESSAGES ************************************************************************************
" **********************************************************************************************************

" {{{
"if g:ConqueTerm_StartMessages
"    let msg_file = s:scriptdirpy . 'version.vim'
"    let msg_show = 1
"    let msg_ct = 1
"
"    " we can write to conque term directory
"    if filewritable(s:scriptdirpy) == 2
"
"        if filewritable(msg_file)
"
"            " read current message file
"            try
"                silent execute "source " . msg_file
"                if exists('g:ConqueTerm_MsgCt') && exists('g:ConqueTerm_MsgVer')
"                    if g:ConqueTerm_MsgVer == g:ConqueTerm_Version && g:ConqueTerm_MsgCt > 2
"                        let msg_show = 0
"                    else
"                        let msg_ct = g:ConqueTerm_MsgCt + 1
"                    endif
"                endif
"            catch
"            endtry
"        endif
"
"        " update message file
"        if msg_show
"            let file_contents = ['let g:ConqueTerm_MsgCt = ' . msg_ct, 'let g:ConqueTerm_MsgVer = ' . g:ConqueTerm_Version]
"            call writefile(file_contents, msg_file)
"        endif
"    endif
"
"    " save our final decision
"    let g:ConqueTerm_StartMessages = msg_show
"endif
" }}}

" **********************************************************************************************************
" **** WINDOWS VK CODES ************************************************************************************
" **********************************************************************************************************

" Windows Virtual Key Codes  {{{
let s:windows_vk = {
\    'VK_ADD' : 107,
\    'VK_APPS' : 93,
\    'VK_ATTN' : 246,
\    'VK_BACK' : 8,
\    'VK_BROWSER_BACK' : 166,
\    'VK_BROWSER_FORWARD' : 167,
\    'VK_CANCEL' : 3,
\    'VK_CAPITAL' : 20,
\    'VK_CLEAR' : 12,
\    'VK_CONTROL' : 17,
\    'VK_CONVERT' : 28,
\    'VK_CRSEL' : 247,
\    'VK_DECIMAL' : 110,
\    'VK_DELETE' : 46,
\    'VK_DIVIDE' : 111,
\    'VK_DOWN' : 40,
\    'VK_DOWN_CTL' : '40;1024',
\    'VK_END' : 35,
\    'VK_EREOF' : 249,
\    'VK_ESCAPE' : 27,
\    'VK_EXECUTE' : 43,
\    'VK_EXSEL' : 248,
\    'VK_F1' : 112,
\    'VK_F10' : 121,
\    'VK_F11' : 122,
\    'VK_F12' : 123,
\    'VK_F13' : 124,
\    'VK_F14' : 125,
\    'VK_F15' : 126,
\    'VK_F16' : 127,
\    'VK_F17' : 128,
\    'VK_F18' : 129,
\    'VK_F19' : 130,
\    'VK_F2' : 113,
\    'VK_F20' : 131,
\    'VK_F21' : 132,
\    'VK_F22' : 133,
\    'VK_F23' : 134,
\    'VK_F24' : 135,
\    'VK_F3' : 114,
\    'VK_F4' : 115,
\    'VK_F5' : 116,
\    'VK_F6' : 117,
\    'VK_F7' : 118,
\    'VK_F8' : 119,
\    'VK_F9' : 120,
\    'VK_FINAL' : 24,
\    'VK_HANGEUL' : 21,
\    'VK_HANGUL' : 21,
\    'VK_HANJA' : 25,
\    'VK_HELP' : 47,
\    'VK_HOME' : 36,
\    'VK_INSERT' : 45,
\    'VK_JUNJA' : 23,
\    'VK_KANA' : 21,
\    'VK_KANJI' : 25,
\    'VK_LBUTTON' : 1,
\    'VK_LCONTROL' : 162,
\    'VK_LEFT' : 37,
\    'VK_LEFT_CTL' : '37;1024',
\    'VK_LMENU' : 164,
\    'VK_LSHIFT' : 160,
\    'VK_LWIN' : 91,
\    'VK_MBUTTON' : 4,
\    'VK_MEDIA_NEXT_TRACK' : 176,
\    'VK_MEDIA_PLAY_PAUSE' : 179,
\    'VK_MEDIA_PREV_TRACK' : 177,
\    'VK_MENU' : 18,
\    'VK_MODECHANGE' : 31,
\    'VK_MULTIPLY' : 106,
\    'VK_NEXT' : 34,
\    'VK_NONAME' : 252,
\    'VK_NONCONVERT' : 29,
\    'VK_NUMLOCK' : 144,
\    'VK_NUMPAD0' : 96,
\    'VK_NUMPAD1' : 97,
\    'VK_NUMPAD2' : 98,
\    'VK_NUMPAD3' : 99,
\    'VK_NUMPAD4' : 100,
\    'VK_NUMPAD5' : 101,
\    'VK_NUMPAD6' : 102,
\    'VK_NUMPAD7' : 103,
\    'VK_NUMPAD8' : 104,
\    'VK_NUMPAD9' : 105,
\    'VK_OEM_CLEAR' : 254,
\    'VK_PA1' : 253,
\    'VK_PAUSE' : 19,
\    'VK_PLAY' : 250,
\    'VK_PRINT' : 42,
\    'VK_PRIOR' : 33,
\    'VK_PROCESSKEY' : 229,
\    'VK_RBUTTON' : 2,
\    'VK_RCONTROL' : 163,
\    'VK_RETURN' : 13,
\    'VK_RIGHT' : 39,
\    'VK_RIGHT_CTL' : '39;1024',
\    'VK_RMENU' : 165,
\    'VK_RSHIFT' : 161,
\    'VK_RWIN' : 92,
\    'VK_SCROLL' : 145,
\    'VK_SELECT' : 41,
\    'VK_SEPARATOR' : 108,
\    'VK_SHIFT' : 16,
\    'VK_SNAPSHOT' : 44,
\    'VK_SPACE' : 32,
\    'VK_SUBTRACT' : 109,
\    'VK_TAB' : 9,
\    'VK_UP' : 38,
\    'VK_UP_CTL' : '38;1024',
\    'VK_VOLUME_DOWN' : 174,
\    'VK_VOLUME_MUTE' : 173,
\    'VK_VOLUME_UP' : 175,
\    'VK_XBUTTON1' : 5,
\    'VK_XBUTTON2' : 6,
\    'VK_ZOOM' : 251
\   }
" }}}

" **********************************************************************************************************
" **** ACTUAL CONQUE FUNCTIONS!  ***************************************************************************
" **********************************************************************************************************

" {{{

" launch conque
function! conque_term#open(...) "{{{
    let command = get(a:000, 0, '')
    let vim_startup_commands = get(a:000, 1, [])
    let return_to_current  = get(a:000, 2, 0)
    let is_buffer  = get(a:000, 3, 1)
    
    if has('unix')
        let term_type = get(a:000, 4, 'Conque()')
    else
        let term_type = get(a:000, 4, 'ConqueSole()')
    endif

    " dependency check
    if !conque_term#dependency_check()
        return 0
    endif

    " switch to buffer if needed
    if is_buffer && return_to_current
      let save_sb = &switchbuf
      sil set switchbuf=usetab
      let current_buffer = bufname("%")
    endif

    " bare minimum validation
    if s:py == ''
        echohl WarningMsg | echomsg "Conque requires the Python interface to be installed. See :help ConqueTerm for more information." | echohl None
        return 0
    endif
    if empty(command)
        echohl WarningMsg | echomsg "Invalid usage: no program path given. Use :ConqueTerm YOUR PROGRAM, e.g. :ConqueTerm ipython" | echohl None
        return 0
    else
        let cmd_args = split(command, '[^\\]\@<=\s')
        let cmd_args[0] = substitute(cmd_args[0], '\\ ', ' ', 'g')
        if !executable(cmd_args[0])
            echohl WarningMsg | echomsg "Not an executable: " . cmd_args[0] | echohl None
            return 0
        endif
    endif

    " initialize global identifiers
    let g:ConqueTerm_Idx += 1
    let g:ConqueTerm_Var = 'ConqueTerm_' . g:ConqueTerm_Idx
    let g:ConqueTerm_BufName = substitute(command, ' ', '\\ ', 'g') . "\\ -\\ " . g:ConqueTerm_Idx

    " initialize global mappings if needed
    call conque_term#init()

    " set Vim buffer window options
    if is_buffer
        call conque_term#set_buffer_settings(command, vim_startup_commands)

        let b:ConqueTerm_Idx = g:ConqueTerm_Idx
        let b:ConqueTerm_Var = g:ConqueTerm_Var
    endif

    " save terminal instance
    let t_obj = conque_term#create_terminal_object(g:ConqueTerm_Idx, is_buffer, g:ConqueTerm_BufName, command)
    let g:ConqueTerm_Terminals[g:ConqueTerm_Idx] = t_obj

    " required for session support
    let g:ConqueTerm_TerminalsString = string(g:ConqueTerm_Terminals)

    " open command
    try
        let options = {}
        let options["TERM"] = g:ConqueTerm_TERM
        let options["CODE_PAGE"] = g:ConqueTerm_CodePage
        let options["color"] = g:ConqueTerm_Color
        let options["offset"] = 0 " g:ConqueTerm_StartMessages * 10

        if s:platform == 'unix'
            " Initialize conque terminal object
            sil execute s:py . ' ' . g:ConqueTerm_Var . ' = ' . term_type
            sil execute s:py . ' ' . g:ConqueTerm_Var . ".open()"
        else
            " find python.exe and communicator
            let py_exe = conque_term#find_python_exe()
            let py_vim = s:scriptdirpy . 'conque_sole_communicator.py'
            sil execute s:py . ' ' . g:ConqueTerm_Var . ' = ' . term_type
            sil execute s:py . ' ' . g:ConqueTerm_Var . ".open()"

            if g:ConqueTerm_ColorMode == 'conceal'
                call conque_term#init_conceal_color()
            endif
        endif
    catch
        echohl WarningMsg | echomsg "An error occurred: " . command | echohl None
        return 0
    endtry

    " set key mappings and auto commands 
    if is_buffer
        call conque_term#set_mappings('start')
    endif

    if s:term_count == 0
        let s:save_updatetime = &updatetime
    endif
    let s:term_count = s:term_count + 1

    " call user defined functions
    call conque_term#call_hooks('after_startup', t_obj)

    " switch to buffer if needed
    if is_buffer && return_to_current
        sil exe ":sb " . current_buffer
        sil exe ":set switchbuf=" . save_sb
    elseif is_buffer
        startinsert!
    endif

    return t_obj

endfunction "}}}

" open(), but no buffer
function! conque_term#subprocess(command) " {{{
    
    let t_obj = conque_term#open(a:command, [], 0, 0)
    if !exists('b:ConqueTerm_Var')
        call conque_term#on_blur(0)
        sil exe s:py . ' ' . g:ConqueTerm_Var . '.idle()'
    endif
    return t_obj

endfunction " }}}

" set buffer options
function! conque_term#set_buffer_settings(command, vim_startup_commands) "{{{

    " optional hooks to execute, e.g. 'split'
    for h in a:vim_startup_commands
        sil exe h
    endfor
    sil exe 'edit ++enc=utf-8 ' . g:ConqueTerm_BufName

    " buffer settings 
    setlocal fileencoding=utf-8 " file encoding, even tho there's no file
    setlocal nopaste           " conque won't work in paste mode
    setlocal buftype=nofile    " this buffer is not a file, you can't save it
    setlocal nonumber          " hide line numbers
    if v:version >= 703
        setlocal norelativenumber " hide relative line numbers (VIM >= 7.3)
    endif
    setlocal foldcolumn=0      " reasonable left margin
    setlocal nowrap            " default to no wrap (esp with MySQL)
    setlocal noswapfile        " don't bother creating a .swp file
    setlocal scrolloff=0       " don't use buffer lines. it makes the 'clear' command not work as expected
    setlocal sidescrolloff=0   " don't use buffer lines. it makes the 'clear' command not work as expected
    setlocal sidescroll=1      " don't use buffer lines. it makes the 'clear' command not work as expected
    setlocal foldmethod=manual " don't fold on {{{}}} and stuff
    setlocal bufhidden=hide    " when buffer is no longer displayed, don't wipe it out
    setlocal noreadonly        " this is not actually a readonly buffer
    if v:version >= 703
        setlocal conceallevel=3
        setlocal concealcursor=nic
    endif
    if g:ConqueTerm_ReadUnfocused
        set cpoptions+=I       " Don't remove autoindent when moving cursor up and down
    endif
    setfiletype conque_term    " useful
    sil exe "setlocal syntax=" . g:ConqueTerm_Syntax

    " temporary global settings go in here
    call conque_term#on_focus(1)

endfunction " }}}

" send normal character key press to terminal
function! conque_term#key_press() "{{{
    sil exe s:py . ' ' . b:ConqueTerm_Var . ".write_buffered_ord(" . char2nr(v:char) . ")"
    sil let v:char = ''
endfunction " }}}



" set key mappings and auto commands
function! conque_term#set_mappings(action) "{{{

    " set action {{{
    if a:action == 'toggle'
        if exists('b:conque_on') && b:conque_on == 1
            let l:action = 'stop'
            echohl WarningMsg | echomsg "Terminal is paused" | echohl None
        else
            let l:action = 'start'
            echohl WarningMsg | echomsg "Terminal is resumed" | echohl None
        endif
    else
        let l:action = a:action
    endif

    " if mappings are being removed, add 'un'
    let map_modifier = 'nore'
    if l:action == 'stop'
        let map_modifier = 'un'
    endif
    " }}}

    " auto commands {{{
    if l:action == 'stop'
        sil exe 'autocmd! ' . b:ConqueTerm_Var

    else
        sil exe 'augroup ' . b:ConqueTerm_Var

        " handle unexpected closing of shell, passes HUP to parent and all child processes
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' BufDelete <buffer> call g:ConqueTerm_Terminals[' . b:ConqueTerm_Idx . '].close()'
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' BufUnload <buffer> call g:ConqueTerm_Terminals[' . b:ConqueTerm_Idx . '].close()'

        " check for resized/scrolled buffer when entering buffer
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' BufEnter <buffer> ' . s:py . ' ' . b:ConqueTerm_Var . '.update_window_size()'
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' VimResized ' . s:py . ' ' . b:ConqueTerm_Var . '.update_window_size()'

        sil exe 'autocmd ' . b:ConqueTerm_Var . ' BufEnter <buffer> call conque_term#on_focus()'
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' BufLeave <buffer> call conque_term#on_blur(1)'

        " reposition cursor when going into insert mode
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' InsertEnter <buffer> ' . s:py . ' ' . b:ConqueTerm_Var . '.insert_enter()'
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' InsertEnter <buffer> call s:insert_enter()'
        sil exe 'autocmd ' . b:ConqueTerm_Var . ' InsertLeave <buffer> call s:insert_leave()'

        " How to poll for more output
        if g:ConqueTerm_ReadUnfocused
            sil exe 'autocmd ' . b:ConqueTerm_Var . ' CursorHoldI <buffer> call conque_term#read_all(1)'
            sil exe 'autocmd ' . b:ConqueTerm_Var . ' CursorHold <buffer> call conque_term#read_all(0)'
        else
            sil exe 'autocmd ' . b:ConqueTerm_Var . ' CursorHoldI <buffer> ' . s:py . ' ' .  b:ConqueTerm_Var . '.auto_read()'
        endif
    endif
    " }}}

    " map ASCII 1-31 {{{
    for c in range(1, 31)
        " <Esc>
        if c == 27 || c == 3
            continue
        endif
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-' . nr2char(64 + c) . '> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(' . c . ')<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-' . nr2char(64 + c) . '>'
        endif
    endfor

    if exists('g:ConqueTerm_Interrupt')
        " Use user defined key binding to send interrupt to terminal in normal and insert mode
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_Interrupt . ' <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(3)<CR>'
            sil exe 'n' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_Interrupt . ' <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(3)<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_Interrupt
            sil exe 'n' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_Interrupt
        endif
    else
        " Use default key binding to send interrupt to terminal in normal and insert mode
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-c> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(3)<CR>'
            sil exe 'n' . map_modifier . 'map <silent> <buffer> <C-c> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(3)<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-c>'
            sil exe 'n' . map_modifier . 'map <silent> <buffer> <C-c>'
        endif
    endif

    " leave insert mode
    if !exists('g:ConqueTerm_EscKey') || g:ConqueTerm_EscKey =~ '<[Ee][Ss][Cc]>'
        " use <Esc><Esc> to send <Esc> to terminal
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc><Esc> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(27)<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc><Esc>'
        endif
    else
        " use <Esc> to send <Esc> to terminal
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_EscKey . ' <Esc>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_ord(27)<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> ' . g:ConqueTerm_EscKey
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Esc>'
        endif
    endif

    " Map <C-w> in insert mode
    if exists('g:ConqueTerm_CWInsert') && g:ConqueTerm_CWInsert == 1
        inoremap <silent> <buffer> <C-w> <Esc><C-w>
    endif
    " }}}

    " map 33 and beyond {{{
    if exists('##InsertCharPre') && g:ConqueTerm_InsertCharPre == 1
        if l:action == 'start'
            autocmd InsertCharPre <buffer> call conque_term#key_press()
        else
            autocmd! InsertCharPre <buffer>
        endif
    else
        for i in range(33, 127)
            " <Bar>
            if i == 124
                if l:action == 'start'
                    sil exe "i" . map_modifier . "map <silent> <buffer> <Bar> <C-o>:" . s:py . ' ' . b:ConqueTerm_Var . ".write_ord(124)<CR>"
                else
                    sil exe "i" . map_modifier . "map <silent> <buffer> <Bar>"
                endif
                continue
            endif
            if l:action == 'start'
                sil exe "i" . map_modifier . "map <silent> <buffer> " . nr2char(i) . " <C-o>:" . s:py . ' ' . b:ConqueTerm_Var . ".write_ord(" . i . ")<CR>"
            else
                sil exe "i" . map_modifier . "map <silent> <buffer> " . nr2char(i)
            endif
        endfor
    endif
    " }}}

    " Special keys {{{
    if l:action == 'start'
        if s:platform == 'unix'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <BS> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x08"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Space> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u(" "))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-BS> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x08"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Space> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u(" "))<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Up> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[A"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Down> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[B"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Right> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[C"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Left> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[D"))<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Up> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[A"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Down> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[B"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Right> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[C"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Left> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[D"))<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Up> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[A"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Down> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[B"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Right> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[C"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Left> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[D"))<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Home> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1bOH"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <End> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1bOF"))<CR>'
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <BS> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x08"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Space> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u(" "))<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-BS> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x08"))<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Space> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u(" "))<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Up> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_UP . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Down> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_DOWN . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Right> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_RIGHT . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Left> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_LEFT . ')<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Up> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_UP . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Down> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_DOWN . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Right> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_RIGHT . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Left> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_LEFT . ')<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Up> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk("' . s:windows_vk.VK_UP_CTL . '")<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Down> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk("' . s:windows_vk.VK_DOWN_CTL . '")<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Right> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk("' . s:windows_vk.VK_RIGHT_CTL . '")<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Left> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk("' . s:windows_vk.VK_LEFT_CTL . '")<CR>'

            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Del> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_DELETE . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <Home> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_HOME . ')<CR>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <End> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_END . ')<CR>'
        endif
    else
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <BS>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Space>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-BS>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Space>'

        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Up>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Down>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Right>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Left>'

        sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Up>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Down>' 
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Right>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <S-Left>'

        sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Up>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Down>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Right>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <C-Left>'

        sil exe 'i' . map_modifier . 'map <silent> <buffer> <Home>'
        sil exe 'i' . map_modifier . 'map <silent> <buffer> <End>'
    endif
    " }}}

    " <F-> keys {{{
    if g:ConqueTerm_SendFunctionKeys
        if l:action == 'start'
            if s:platform == 'unix'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F1>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[11~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F2>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[12~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F3>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("1b[13~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F4>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[14~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F5>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[15~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F6>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[17~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F7>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[18~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F8>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[19~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F9>  <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[20~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F10> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[21~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F11> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[23~"))<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F12> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write(u("\x1b[24~"))<CR>'
            else
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F1> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F1 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F2> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F2 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F3> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F3 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F4> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F4 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F5> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F5 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F6> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F6 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F7> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F7 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F8> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F8 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F9> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F9 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F10> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F10 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F11> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F11 . ')<CR>'
                sil exe 'i' . map_modifier . 'map <silent> <buffer> <F12> <C-o>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_vk(' . s:windows_vk.VK_F12 . ')<CR>'
            endif
        else
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F1>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F2>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F3>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F4>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F5>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F6>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F7>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F8>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F9>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F10>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F11>'
            sil exe 'i' . map_modifier . 'map <silent> <buffer> <F12>'
        endif
    endif
    " }}}

    " various global mappings {{{
    " don't overwrite existing mappings
    if l:action == 'start'
        if maparg(g:ConqueTerm_SendVisKey, 'v') == ''
          sil exe 'v' . map_modifier . 'map <silent> ' . g:ConqueTerm_SendVisKey . ' :<C-u>call conque_term#send_selected(visualmode())<CR>'
        endif
        if maparg(g:ConqueTerm_SendFileKey, 'n') == ''
          sil exe 'n' . map_modifier . 'map <silent> ' . g:ConqueTerm_SendFileKey . ' :<C-u>call conque_term#send_file()<CR>'
        endif
    endif
    " }}}

    " remap paste keys {{{
    if l:action == 'start'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> p :' . s:py . ' ' . b:ConqueTerm_Var . '.write_expr("@@")<CR>a'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> P :' . s:py . ' ' . b:ConqueTerm_Var . '.write_expr("@@")<CR>a'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> ]p :' . s:py . ' ' . b:ConqueTerm_Var . '.write_expr("@@")<CR>a'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> [p :' . s:py . ' ' . b:ConqueTerm_Var . '.write_expr("@@")<CR>a'
    else
        sil exe 'n' . map_modifier . 'map <silent> <buffer> p'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> P'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> ]p'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> [p'
    endif
    if has('gui_running') == 1
        if l:action == 'start'
            sil exe 'i' . map_modifier . 'map <buffer> <S-Insert> <Esc>:' . s:py . ' ' . b:ConqueTerm_Var . '.write_expr("@+")<CR>a'
            sil exe 'i' . map_modifier . 'map <buffer> <S-Help> <Esc>:<C-u>' . s:py . ' ' . b:ConqueTerm_Var . '.write_expr("@+")<CR>a'
        else
            sil exe 'i' . map_modifier . 'map <buffer> <S-Insert>'
            sil exe 'i' . map_modifier . 'map <buffer> <S-Help>'
        endif
    endif
    " }}}

    " disable other normal mode keys which insert text {{{
    if l:action == 'start'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> r :echo "Replace mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> R :echo "Replace mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> c :echo "Change mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> C :echo "Change mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> s :echo "Change mode disabled in shell."<CR>'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> S :echo "Change mode disabled in shell."<CR>'
    else
        sil exe 'n' . map_modifier . 'map <silent> <buffer> r'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> R'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> c'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> C'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> s'
        sil exe 'n' . map_modifier . 'map <silent> <buffer> S'
    endif
    " }}}

    " set conque as on or off {{{
    if l:action == 'start'
        let b:conque_on = 1
    else
        let b:conque_on = 0
    endif
    " }}}

    " map command to toggle terminal key mappings {{{
    if a:action == 'start'
        sil exe 'nnoremap ' . g:ConqueTerm_ToggleKey . ' :<C-u>call conque_term#set_mappings("toggle")<CR>'
    endif
    " }}}

    " call user defined functions
    if l:action == 'start'
        call conque_term#call_hooks('after_keymap', conque_term#get_instance())
    endif

endfunction " }}}

" Initialize global mappings. Should only be called once per Vim session
function! conque_term#init() " {{{

    if s:initialized == 1
        return
    endif

    augroup ConqueTerm

    " abort any remaining running terminals when Vim exits
    autocmd ConqueTerm VimLeave * call conque_term#close_all()

    " read more output when this isn't the current buffer
    if g:ConqueTerm_ReadUnfocused == 1
        autocmd ConqueTerm CursorHold * call conque_term#read_all(0)
    endif

    let s:initialized = 1

endfunction " }}}

function! s:buffer_update(insert_mode) "{{{
    " restart updatetime
    if a:insert_mode
        if col(".") == col("$")
          call feedkeys("\<Right>", "n")
        else
          call feedkeys("\<Right>\<Left>", "n")
        endif
    else
        call feedkeys("f\e", "n")
    endif
endfunction " }}}

" read from all known conque buffers
function! conque_term#read_all(insert_mode) "{{{

    let term_running = 0
    let buffer = bufnr("%")

    for i in range(1, g:ConqueTerm_Idx)
        try
            if !g:ConqueTerm_Terminals[i].active
                continue
            endif

            let term_running = 1

            if g:ConqueTerm_Terminals[i].buffer_number == buffer
                sil exe s:py . ' ' .  b:ConqueTerm_Var . '.auto_read(False)'
            else
                call g:ConqueTerm_Terminals[i].read(1)
            endif

            if !g:ConqueTerm_Terminals[i].is_buffer && exists('*g:ConqueTerm_Terminals[i].callback')
                call g:ConqueTerm_Terminals[i].callback(output)
            endif
        catch
            " probably a deleted buffer
        endtry
    endfor

    if term_running
        call s:buffer_update(a:insert_mode)
    endif

endfunction "}}}

" close all subprocesses
function! conque_term#close_all() "{{{

    for i in range(1, g:ConqueTerm_Idx)
        try
            call g:ConqueTerm_Terminals[i].close()
        catch
            " probably a deleted buffer
        endtry
    endfor

endfunction "}}}

" gets called when user enters conque buffer.
" Useful for making temp changes to global config
function! conque_term#on_focus(...) " {{{

    let startup = get(a:000, 0, 0)

    " Disable NeoComplCache. It has global hooks on CursorHold and CursorMoved :-/
    let s:NeoComplCache_WasEnabled = exists(':NeoComplCacheLock')
    if s:NeoComplCache_WasEnabled == 2
        NeoComplCacheLock
    endif
 
    if g:ConqueTerm_ReadUnfocused == 1
        autocmd! ConqueTerm CursorHoldI *
        autocmd! ConqueTerm CursorHold *
    endif

    " resume subprocess fast polling
    if startup == 0 && exists('b:ConqueTerm_Var')
        sil exe s:py . ' ' . g:ConqueTerm_Var . '.resume()'
    endif

    " call user defined functions
    if startup == 0
        call conque_term#call_hooks('buffer_enter', conque_term#get_instance())
    endif

    " if configured, go into insert mode
    if g:ConqueTerm_InsertOnEnter == 1
        startinsert!
    endif

endfunction " }}}

function! s:set_term_updatetime(time)
    if a:time
        sil exe 'set updatetime=' . a:time
    endif
    let s:reset_updatetime = a:time
endfunction

function! s:insert_enter() " {{{
    call s:set_term_updatetime(g:ConqueTerm_FocusedUpdateTime)
endfunction " }}}

function! s:insert_leave() " {{{
    call s:set_term_updatetime(g:ConqueTerm_UnfocusedUpdateTime)
endfunction " }}}

" gets called when user exits conque buffer.
" Useful for resetting changes to global config
function! conque_term#on_blur(is_buffer) " {{{
    " re-enable NeoComplCache if needed
    if exists('s:NeoComplCache_WasEnabled') && exists(':NeoComplCacheUnlock') && s:NeoComplCache_WasEnabled == 2
        NeoComplCacheUnlock
    endif

    " turn off subprocess fast polling
    if exists('b:ConqueTerm_Var')
        sil exe s:py . ' ' . b:ConqueTerm_Var . '.idle()'
    endif

    " reset poll interval
    if g:ConqueTerm_ReadUnfocused
        call s:set_term_updatetime(g:ConqueTerm_UnfocusedUpdateTime)
        autocmd ConqueTerm CursorHoldI * call conque_term#read_all(1)
        autocmd ConqueTerm CursorHold * call conque_term#read_all(0)
    elseif s:reset_updatetime
        sil exe 'set updatetime=' . s:save_updatetime
    endif

    " call user defined functions
    call conque_term#call_hooks('buffer_leave', conque_term#get_instance())

endfunction " }}}

" bell event (^G)
function! conque_term#bell() " {{{
    if g:ConqueTerm_ShowBell
        echohl WarningMsg | echomsg "BELL!" | echohl None
    endif
endfunction " }}}

" register function to be called at conque events
function! conque_term#register_function(event, function_name) " {{{

    if !has_key(s:hooks, a:event)
        echomsg 'No such event: ' . a:event
        return
    endif

    if !exists('*' . a:function_name)
        echomsg 'No such function: ' . a:function_name)
        return
    endif

    " register the function
    call add(s:hooks[a:event], function(a:function_name))

endfunction " }}}

" call hooks for an event
function! conque_term#call_hooks(event, t_obj) " {{{

    for Fu in s:hooks[a:event]
        call Fu(a:t_obj)
    endfor

endfunction " }}}

" }}}

" **********************************************************************************************************
" **** Windows only functions ******************************************************************************
" **********************************************************************************************************

" {{{

" find python.exe in windows
function! conque_term#find_python_exe() " {{{

    " first check configuration for custom value
    if g:ConqueTerm_PyExe != '' && executable(g:ConqueTerm_PyExe)
        return g:ConqueTerm_PyExe
    endif

    let sys_paths = split($PATH, ';')

    " get exact python version
    sil exe ':' . s:py . ' import sys, vim'
    sil exe ':' . s:py . ' vim.command("let g:ConqueTerm_PyVersion = " + str(sys.version_info[0]) + str(sys.version_info[1]))'

    " ... and add to path list
    call add(sys_paths, 'C:\Python' . g:ConqueTerm_PyVersion)
    call reverse(sys_paths)

    " check if python.exe is in paths
    for path in sys_paths
        let cand = path . '\' . 'python.exe'
        if executable(cand)
            return cand
        endif
    endfor

    echohl WarningMsg | echomsg "Unable to find python.exe, see :help ConqueTerm_PythonExe for more information" | echohl None

    return ''

endfunction " }}}

" initialize concealed colors
function! conque_term#init_conceal_color() " {{{

    highlight link ConqueCCBG Normal

    " foreground colors, low intensity
    syn region ConqueCCF000 matchgroup=ConqueConceal start="\esf000;" end="\eef000;" concealends contains=ConqueCCBG
    syn region ConqueCCF00c matchgroup=ConqueConceal start="\esf00c;" end="\eef00c;" concealends contains=ConqueCCBG
    syn region ConqueCCF0c0 matchgroup=ConqueConceal start="\esf0c0;" end="\eef0c0;" concealends contains=ConqueCCBG
    syn region ConqueCCF0cc matchgroup=ConqueConceal start="\esf0cc;" end="\eef0cc;" concealends contains=ConqueCCBG
    syn region ConqueCCFc00 matchgroup=ConqueConceal start="\esfc00;" end="\eefc00;" concealends contains=ConqueCCBG
    syn region ConqueCCFc0c matchgroup=ConqueConceal start="\esfc0c;" end="\eefc0c;" concealends contains=ConqueCCBG
    syn region ConqueCCFcc0 matchgroup=ConqueConceal start="\esfcc0;" end="\eefcc0;" concealends contains=ConqueCCBG
    syn region ConqueCCFccc matchgroup=ConqueConceal start="\esfccc;" end="\eefccc;" concealends contains=ConqueCCBG

    " foreground colors, high intensity
    syn region ConqueCCF000 matchgroup=ConqueConceal start="\esf000;" end="\eef000;" concealends contains=ConqueCCBG
    syn region ConqueCCF00f matchgroup=ConqueConceal start="\esf00f;" end="\eef00f;" concealends contains=ConqueCCBG
    syn region ConqueCCF0f0 matchgroup=ConqueConceal start="\esf0f0;" end="\eef0f0;" concealends contains=ConqueCCBG
    syn region ConqueCCF0ff matchgroup=ConqueConceal start="\esf0ff;" end="\eef0ff;" concealends contains=ConqueCCBG
    syn region ConqueCCFf00 matchgroup=ConqueConceal start="\esff00;" end="\eeff00;" concealends contains=ConqueCCBG
    syn region ConqueCCFf0f matchgroup=ConqueConceal start="\esff0f;" end="\eeff0f;" concealends contains=ConqueCCBG
    syn region ConqueCCFff0 matchgroup=ConqueConceal start="\esfff0;" end="\eefff0;" concealends contains=ConqueCCBG
    syn region ConqueCCFfff matchgroup=ConqueConceal start="\esffff;" end="\eeffff;" concealends contains=ConqueCCBG

    " background colors, low intensity
    syn region ConqueCCB000 matchgroup=ConqueCCBG start="\esb000;" end="\eeb000;" concealends
    syn region ConqueCCB00c matchgroup=ConqueCCBG start="\esb00c;" end="\eeb00c;" concealends
    syn region ConqueCCB0c0 matchgroup=ConqueCCBG start="\esb0c0;" end="\eeb0c0;" concealends
    syn region ConqueCCB0cc matchgroup=ConqueCCBG start="\esb0cc;" end="\eeb0cc;" concealends
    syn region ConqueCCBc00 matchgroup=ConqueCCBG start="\esbc00;" end="\eebc00;" concealends
    syn region ConqueCCBc0c matchgroup=ConqueCCBG start="\esbc0c;" end="\eebc0c;" concealends
    syn region ConqueCCBcc0 matchgroup=ConqueCCBG start="\esbcc0;" end="\eebcc0;" concealends
    syn region ConqueCCBccc matchgroup=ConqueCCBG start="\esbccc;" end="\eebccc;" concealends

    " background colors, high intensity
    syn region ConqueCCB000 matchgroup=ConqueCCBG start="\esb000;" end="\eeb000;" concealends
    syn region ConqueCCB00f matchgroup=ConqueCCBG start="\esb00f;" end="\eeb00f;" concealends
    syn region ConqueCCB0f0 matchgroup=ConqueCCBG start="\esb0f0;" end="\eeb0f0;" concealends
    syn region ConqueCCB0ff matchgroup=ConqueCCBG start="\esb0ff;" end="\eeb0ff;" concealends
    syn region ConqueCCBf00 matchgroup=ConqueCCBG start="\esbf00;" end="\eebf00;" concealends
    syn region ConqueCCBf0f matchgroup=ConqueCCBG start="\esbf0f;" end="\eebf0f;" concealends
    syn region ConqueCCBff0 matchgroup=ConqueCCBG start="\esbff0;" end="\eebff0;" concealends
    syn region ConqueCCBfff matchgroup=ConqueCCBG start="\esbfff;" end="\eebfff;" concealends


    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

    "highlight link ConqueCCConceal Error

    " foreground colors, low intensity
    highlight ConqueCCF000 guifg=#000000
    highlight ConqueCCF00c guifg=#0000cc
    highlight ConqueCCF0c0 guifg=#00cc00
    highlight ConqueCCF0cc guifg=#00cccc
    highlight ConqueCCFc00 guifg=#cc0000
    highlight ConqueCCFc0c guifg=#cc00cc
    highlight ConqueCCFcc0 guifg=#cccc00
    highlight ConqueCCFccc guifg=#cccccc

    " foreground colors, high intensity
    highlight ConqueCCF000 guifg=#000000
    highlight ConqueCCF00f guifg=#0000ff
    highlight ConqueCCF0f0 guifg=#00ff00
    highlight ConqueCCF0ff guifg=#00ffff
    highlight ConqueCCFf00 guifg=#ff0000
    highlight ConqueCCFf0f guifg=#ff00ff
    highlight ConqueCCFff0 guifg=#ffff00
    highlight ConqueCCFfff guifg=#ffffff

    " background colors, low intensity
    highlight ConqueCCB000 guibg=#000000
    highlight ConqueCCB00c guibg=#0000cc
    highlight ConqueCCB0c0 guibg=#00cc00
    highlight ConqueCCB0cc guibg=#00cccc
    highlight ConqueCCBc00 guibg=#cc0000
    highlight ConqueCCBc0c guibg=#cc00cc
    highlight ConqueCCBcc0 guibg=#cccc00
    highlight ConqueCCBccc guibg=#cccccc

    " background colors, high intensity
    highlight ConqueCCB000 guibg=#000000
    highlight ConqueCCB00f guibg=#0000ff
    highlight ConqueCCB0f0 guibg=#00ff00
    highlight ConqueCCB0ff guibg=#00ffff
    highlight ConqueCCBf00 guibg=#ff0000
    highlight ConqueCCBf0f guibg=#ff00ff
    highlight ConqueCCBff0 guibg=#ffff00
    highlight ConqueCCBfff guibg=#ffffff

    " background colors, low intensity
    highlight link ConqueCCB000 ConqueCCBG
    highlight link ConqueCCB00c ConqueCCBG
    highlight link ConqueCCB0c0 ConqueCCBG
    highlight link ConqueCCB0cc ConqueCCBG
    highlight link ConqueCCBc00 ConqueCCBG
    highlight link ConqueCCBc0c ConqueCCBG
    highlight link ConqueCCBcc0 ConqueCCBG
    highlight link ConqueCCBccc ConqueCCBG

    " background colors, high intensity
    highlight link ConqueCCB000 ConqueCCBG
    highlight link ConqueCCB00f ConqueCCBG
    highlight link ConqueCCB0f0 ConqueCCBG
    highlight link ConqueCCB0ff ConqueCCBG
    highlight link ConqueCCBf00 ConqueCCBG
    highlight link ConqueCCBf0f ConqueCCBG
    highlight link ConqueCCBff0 ConqueCCBG
    highlight link ConqueCCBfff ConqueCCBG

endfunction " }}}

" }}}

" **********************************************************************************************************
" **** Add-on features *************************************************************************************
" **********************************************************************************************************

" {{{

" send selected text from another buffer
function! conque_term#send_selected(type) "{{{

    " get most recent/relevant terminal
    let term = conque_term#get_instance()

    " shove visual text into @@ register
    let reg_save = @@
    sil exe "normal! `<" . a:type . "`>y"
    let @@ = substitute(@@, '^[\r\n]*', '', '')
    let @@ = substitute(@@, '[\r\n]*$', '', '')

    " go to terminal buffer
    call term.focus()

    " execute yanked text
    call term.write(@@)

    " reset original values
    let @@ = reg_save

    " scroll buffer left
    startinsert!
    normal! 0zH

endfunction "}}}

function! conque_term#send_file() "{{{

    let file_lines = readfile(expand('%:p'))
    if type(file_lines) == 3 && len(file_lines) > 0
        let term = conque_term#get_instance()
        call term.focus()

        for line in file_lines
            call term.writeln(line)
        endfor
    else
        echomsg 'Could not read file: ' . expand('%:p')
    endif

endfunction "}}}


function! conque_term#exec_file() "{{{

    let current_file = expand('%:p')
    if !executable(current_file)
        echomsg "Could not run " . current_file . ". Not an executable."
        return
    endif
    sil exe ':ConqueTermSplit ' . current_file

endfunction "}}}


" called on SessionLoadPost event
function! conque_term#resume_session() " {{{
    " Session support is currently not working
    return 
    if g:ConqueTerm_SessionSupport == 1

        " make sure terminals exist
        if !exists('s:saved_terminals') || type(s:saved_terminals) != 4
            return
        endif

        " rebuild terminals
        for idx in keys(s:saved_terminals)

            " don't recreate inactive terminals
            if s:saved_terminals[idx].active == 0
                continue
            endif

            " check we're in the right buffer
            let bufname = substitute(s:saved_terminals[idx].buffer_name, '\', '', 'g')
            if bufname != bufname("%")
                continue
            endif

            " reopen command
            call conque_term#open(s:saved_terminals[idx].command)

        endfor

    endif
endfunction " }}}

" }}}

" **********************************************************************************************************
" **** "API" functions *************************************************************************************
" **********************************************************************************************************

" {{{

" Write to a conque terminal buffer
function! s:term_obj.write(...) dict " {{{

    let text = get(a:000, 0, '')
    let jump_to_buffer = get(a:000, 1, 0)

    " if we're not in terminal buffer, pass flag to not position the cursor
    sil exe s:py . ' ' . self.var . '.write_expr("text", False, False)'

    " move cursor to conque buffer
    if jump_to_buffer
        call self.focus()
    endif

endfunction " }}}

" same as write() but adds a newline
function! s:term_obj.writeln(...) dict " {{{

    let text = get(a:000, 0, '')
    let jump_to_buffer = get(a:000, 1, 0)

    call self.write(text . "\r", jump_to_buffer)

endfunction " }}}

" move cursor to terminal buffer
function! s:term_obj.focus() dict " {{{

    let save_sb = &switchbuf
    sil set switchbuf=usetab
    sil exe 'sb ' . self.buffer_number
    sil exe ":set switchbuf=" . save_sb
    startinsert!

endfunction " }}}

" read from terminal buffer and return string
function! s:term_obj.read(...) dict " {{{

    sil exe s:py . ' if not ' . self.var . '.proc.is_alive(): vim.command("call conque_term#get_instance(' . self.idx . ').close()")'

    let read_time = get(a:000, 0, 1)
    let update_buffer = get(a:000, 1, self.is_buffer)

    if update_buffer 
        let term_win = bufwinnr(self.buffer_number)
        if term_win == -1
            " Don't read when the buffer window isn't visible
            return ''
        endif

        let last_win = winnr()

        " Keep users previous window
        sil noautocmd wincmd p
        " Focus to the terminal window
        sil exe 'noautocmd ' . term_win . 'wincmd w'

        let up_py = 'True'
    else
        let up_py = 'False'
    endif

    let output = ''
   
    " read!
    sil exec s:py . " conque_tmp = " . self.var . ".read(timeout = " . read_time . ", set_cursor = " . up_py . ", return_output = True, update_buffer = " . up_py . ")"

    " ftw!
    try
        let pycode = "\nif conque_tmp:\n    conque_tmp = re.sub('\\\\\\\\', '\\\\\\\\\\\\\\\\', conque_tmp)\n    conque_tmp = re.sub('\"', '\\\\\\\\\"', conque_tmp)\n    vim.command('let output = \"' + conque_tmp + '\"')\n"
        sil exec s:py . pycode
    catch
        " d'oh
    endtry
    
    if update_buffer
        sil exec s:py . ' ' . self.var . '.update_window()'

        " First go to the users previous window (#)
        sil noautocmd wincmd p
        " Next go to the users last window (%)
        sil exe 'noautocmd ' . last_win . 'wincmd w'
    endif

    return output
endfunction " }}}

" set output callback
function! s:term_obj.set_callback(callback_func) dict " {{{

    let g:ConqueTerm_Terminals[self.idx].callback = function(a:callback_func)

endfunction " }}}

" close subprocess with ABORT signal
function! s:term_obj.close() dict " {{{

    let last_buf = bufnr("%")
    sil exe 'noautocmd buffer ' . self.buffer_number

    " kill process
    try
        sil exe s:py . ' ' . self.var . '.abort()'
    catch
        " probably already dead
    endtry

    " delete buffer if option is set
    if self.is_buffer
        try
            call conque_term#set_mappings('stop')
        catch
        endtry
        if exists('g:ConqueTerm_CloseOnEnd') && g:ConqueTerm_CloseOnEnd && buflisted(self.buffer_number)
            sil exe 'bwipeout ' . self.buffer_number
            stopinsert
        endif
    endif

    " mark ourselves as inactive
    let self.active = 0

    " rebuild session options
    let g:ConqueTerm_TerminalsString = string(g:ConqueTerm_Terminals)

    " Reset update time if this is the last terminal
    if s:term_count <= 1
        if s:reset_updatetime
            sil exe 'set updatetime=' . s:save_updatetime
        endif
        let s:term_count = 0
    else
        let s:term_count = s:term_count - 1
    endif

    " call user defined functions
    call conque_term#call_hooks('after_close', self)

    if last_buf != self.buffer_number
        sil exe 'noautocmd buffer ' . last_buf
    endif

endfunction " }}}

" create a new terminal object
function! conque_term#create_terminal_object(...) " {{{

    " find conque buffer to update
    let buf_num = get(a:000, 0, 0)
    if buf_num > 0
        let pvar = 'ConqueTerm_' . buf_num
    elseif exists('b:ConqueTerm_Var')
        let pvar = b:ConqueTerm_Var
        let buf_num = b:ConqueTerm_Idx
    else
        let pvar = g:ConqueTerm_Var
        let buf_num = g:ConqueTerm_Idx
    endif

    " is ther a buffer?
    let is_buffer = get(a:000, 1, 1)

    " the buffer name
    let bname = get(a:000, 2, '')

    " the command
    let command = get(a:000, 3, '')

    " parse out the program name (not perfect)
    let arg_split = split(command, '[^\\]\@<=\s')
    let arg_split[0] = substitute(arg_split[0], '\\ ', ' ', 'g')
    let slash_split = split(arg_split[0], '[/\\]')
    let prg_name = substitute(slash_split[-1], '\(.*\)\..*', '\1', '')

    let l:t_obj = copy(s:term_obj)
    let l:t_obj.is_buffer = is_buffer
    let l:t_obj.idx = buf_num
    let l:t_obj.buffer_name = bname
    let l:t_obj.buffer_number = bufnr("%")
    let l:t_obj.var = pvar
    let l:t_obj.command = command
    let l:t_obj.program_name = prg_name

    return l:t_obj

endfunction " }}}

" get an existing terminal instance
function! conque_term#get_instance(...) " {{{

    " find conque buffer to update
    let buf_num = get(a:000, 0, 0)

    if exists('g:ConqueTerm_Terminals[buf_num]')
        
    elseif exists('b:ConqueTerm_Var')
        let buf_num = b:ConqueTerm_Idx
    else
        let buf_num = g:ConqueTerm_Idx
    endif

    return g:ConqueTerm_Terminals[buf_num]

endfunction " }}}

" Get python version
function! conque_term#get_py() " {{{
    return s:py
endfunction " }}}

" }}}

" **********************************************************************************************************
" **** PYTHON **********************************************************************************************
" **********************************************************************************************************

function! conque_term#load_python() " {{{

    sil exec s:py . "file " . s:scriptdirpy . "conque_globals.py"
    sil exec s:py . "file " . s:scriptdirpy . "conque.py"
    if s:platform == 'windows'
        sil exec s:py . "file " . s:scriptdirpy . "conque_win32_util.py"
        sil exec s:py . "file " . s:scriptdirpy . "conque_sole_shared_memory.py"
        sil exec s:py . "file " . s:scriptdirpy . "conque_sole.py"
        sil exec s:py . "file " . s:scriptdirpy . "conque_sole_wrapper.py"
    else
        sil exec s:py . "file " . s:scriptdirpy . "conque_screen.py"
        sil exec s:py . "file " . s:scriptdirpy . "conque_subprocess.py"
    endif

endfunction " }}}

" vim:foldmethod=marker
autoload/conque_gdb/conque_gdb.py	[[[1
294
import re, collections

# Marks that a breakpoint has been hit
GDB_BREAK_MARK = '\x1a\x1a'

# Marks that a program opened by gdb has terminated
GDB_EXIT_MARK = '\x1a\x19'

# Marks a prompt has started and stopped
GDB_PROMPT_MARK = '\x1a\x18'

GDB_BREAK_REGEX = re.compile('.*' + GDB_BREAK_MARK + '.*')

GDB_EXIT_REGEX = re.compile('.*' + GDB_EXIT_MARK + '.*')

GDB_PROMPT_REGEX = re.compile('.*' + GDB_PROMPT_MARK + '.*')

GET_BPS_REGEX = re.compile('(bkpt\s*?\=\s*?\{.*?(?:["].*?["])+?\s*?\]?\s*?\}(?!\s*?,\s*?\{).*?)', re.I)

GET_ATTR_STR = '\s*?\=\s*?["](.*?)["].*?'

ATTR_LINE_REGEX = re.compile('(line' + GET_ATTR_STR + ')', re.I)
ATTR_FILE_REGEX = re.compile('(fullname' + GET_ATTR_STR + ')', re.I)
ATTR_NUM_REGEX = re.compile('(number' + GET_ATTR_STR + ')', re.I)
ATTR_ENABLE_REGEX = re.compile('(enabled' + GET_ATTR_STR + ')', re.I)
ATTR_TYPE_REGEX = re.compile('(type' + GET_ATTR_STR + ')', re.I)

IS_BREAKPOINT_REGEX = re.compile('.*breakpoint.*', re.I)

class RegisteredBreakpoint:
    def __init__(self, fname, line, enable):
        self.filename = fname
        self.lineno = line
        self.enabled = enable

    def __str__(self):
        return self.filename + ':' + self.lineno + ',' + self.enabled

class RegisteredBpDict(collections.MutableMapping):
    def __init__(self):
        self.r_breaks = dict()
        self.lookups = dict()

    def lookup(self, filename, line):
        if filename in self.lookups:
            if line in self.lookups[filename]:
                return self.lookups[filename][line]
        return []

    def get_lookups(self):
        return self.lookups

    def get_equal_breakpoints(self, bp):
        return self.lookups[bp.filename][bp.lineno]

    def get_file_breakpoints(self, filename):
        if filename in self.lookups:
            return self.lookups[filename]
        return dict()

    def __getitem__(self, key):
        return self.r_breaks[self.__keytransform__(key)]

    def __setitem__(self, key, r_bp):
        if r_bp.filename in self.lookups:
            if r_bp.lineno in self.lookups[r_bp.filename]:
                self.lookups[r_bp.filename][r_bp.lineno].append(r_bp)
            else:
                self.lookups[r_bp.filename][r_bp.lineno] = [r_bp]
        else:
            self.lookups[r_bp.filename] = {r_bp.lineno : [r_bp]}
        self.r_breaks[self.__keytransform__(key)] = r_bp

    def __delitem__(self, key):
        del self.r_breaks[self.__keytransform__(key)]

    def __iter__(self):
        return iter(self.r_breaks)

    def __len__(self):
        return len(self.r_breaks)

    def __keytransform__(self, key):
        return key

class ConqueGdb(Conque):
    """
    Unix specific implementation of the Conque class needed by the Conque GDB terminal.
    """
    # File name and linenumber of next break point
    breakpoint = None

    # Indicates whether a program opened by gdb has terminated
    inferior_exit = False

    # Internal string before the gdb prompt
    prompt = None

    # True if we are adding to the prompt string
    is_prompt = False

    # Breakpoints which have been registered to exist
    registered_breakpoints = RegisteredBpDict()

    # Mapping from linenumber + filename to a tuple containing the id of the sign 
    # placed there and whether the breakpoint is enabled ('y') or disabled ('n')
    lookup_sign_ids = dict()

    # Id number of the next sign to place. Start from 15607 FTW!
    next_sign_id = 15607

    def plain_text(self, input):
        """
        Append plain text to a gdb break point or the vim buffer.
        """
        if self.breakpoint != None:
            self.append_breakpoint(input)
        elif GDB_BREAK_REGEX.match(input):
            self.begin_breakpoint()
            self.plain_text(input.split(GDB_BREAK_MARK, 1)[1])
        elif GDB_EXIT_REGEX.match(input):
            self.handle_inferior_exit()
            self.plain_text(input.split(GDB_EXIT_MARK, 1)[1])
        elif GDB_PROMPT_REGEX.match(input):
            sp = input.split(GDB_PROMPT_MARK)
            if sp[0] != '':
                self.plain_text(sp[0])
                self.ctl_nl()
            self.toggle_prompt()
            self.plain_text(sp[1])
        elif self.prompt != None:
            self.append_prompt(input)
        else:
            super(ConqueGdb, self).plain_text(input)

    def ctl_nl(self):
        """
        Append new line to vim buffer or finalize a break point.
        """
        if self.breakpoint != None:
            self.finalize_breakpoint()
        elif self.is_prompt:
            self.is_prompt = False
        elif self.inferior_exit:
            self.finalize_inferior_exit()
        else:
            super(ConqueGdb, self).ctl_nl()

    def toggle_prompt(self):
        self.is_prompt = True
        if (self.prompt == None):
            self.prompt = ''
        else:
            self.finalize_prompt()
            self.prompt = None

    def append_prompt(self, string):
        self.is_prompt = True
        self.prompt += string

    def bp_to_look_key(self, bp):
        return bp.filename + "\n" + bp.lineno

    def look_key_split(self, look_key):
        return look_key.split("\n")

    def look_key_filename(self, look_key):
        return look_key.split("\n")[0]

    def get_bp_attribute(self, bp, regex):
        return regex.findall(bp)[0][1].strip()

    def convert_to_vim_file(self, filename):
        return filename.replace("'", "\n").replace("\\\\", "\\")

    def place_sign(self, breakpoints, line):
        enabled = 'n'
        for bp in breakpoints:
            if bp.enabled == 'y':
                enabled = 'y'
                break

        old = self.lookup_sign_ids.get(line)
        if old:
            vim.command("call conque_gdb#remove_breakpoint_sign('%d','%s')" % (old[0], self.convert_to_vim_file(bp.filename)))
        self.lookup_sign_ids[line] = (self.next_sign_id, enabled)
        bp = breakpoints[0]
        vim.command("call conque_gdb#set_breakpoint_sign('%d','%s','%s','%s')" % (self.next_sign_id, self.convert_to_vim_file(bp.filename), bp.lineno, enabled))
        self.next_sign_id += 1

    def remove_sign(self, id, line):
        fname = self.look_key_filename(line)
        vim.command("call conque_gdb#remove_breakpoint_sign('%d','%s')" % (id, self.convert_to_vim_file(fname)))

    def unplace_sign(self, line):
        id = self.lookup_sign_ids[line][0]
        self.remove_sign(id, line)
        del self.lookup_sign_ids[line]

    def reset_registered_breakpoints(self):
        new_breakpoints = RegisteredBpDict()
        changed_lines = set()

        bps = GET_BPS_REGEX.findall(self.prompt.replace('\\"', '\\x1a'))
        for bp in bps:
            try:
                num = self.get_bp_attribute(bp, ATTR_NUM_REGEX)
                enable = self.get_bp_attribute(bp, ATTR_ENABLE_REGEX)
                if num in self.registered_breakpoints.keys():
                    if enable == self.registered_breakpoints[num].enabled:
                        new_breakpoints[num] = self.registered_breakpoints[num]
                        del self.registered_breakpoints[num]
                    else:
                        breakpoint = self.registered_breakpoints[num]
                        del self.registered_breakpoints[num]
                        breakpoint.enabled = enable
                        new_breakpoints[num] = breakpoint
                        changed_lines.add(self.bp_to_look_key(breakpoint))
                else:
                    type = self.get_bp_attribute(bp, ATTR_TYPE_REGEX)
                    if not IS_BREAKPOINT_REGEX.match(type):
                        continue
                    fname = self.get_bp_attribute(bp, ATTR_FILE_REGEX).replace('\\x1a', '"')
                    line = self.get_bp_attribute(bp, ATTR_LINE_REGEX)
                    breakpoint = RegisteredBreakpoint(fname, line, enable)
                    new_breakpoints[num] = breakpoint
                    changed_lines.add(self.bp_to_look_key(breakpoint))
            except:
                pass
        for breakpoint in self.registered_breakpoints.values():
            changed_lines.add(self.bp_to_look_key(breakpoint))

        self.registered_breakpoints = new_breakpoints
        return changed_lines

    def apply_breakpoint_changes(self, changed_lines):
        for line in changed_lines:
            (fname, lineno) = self.look_key_split(line)
            equal_bps = self.registered_breakpoints.lookup(fname, lineno)
            if len(equal_bps) == 0:
                self.unplace_sign(line)
            elif line in self.lookup_sign_ids:
                (old_id, old_enabled) = self.lookup_sign_ids[line]
                self.place_sign(equal_bps, line)
                self.remove_sign(old_id, line)
            else:
                self.place_sign(equal_bps, line)

    def finalize_prompt(self):
        changed_lines = self.reset_registered_breakpoints()
        self.apply_breakpoint_changes(changed_lines)

    def place_file_breakpoints(self, filename):
        files_dict = self.registered_breakpoints.get_lookups()
        bp_dict = self.registered_breakpoints.get_file_breakpoints(filename)
        for bps in bp_dict.values():
            self.place_sign(bps, self.bp_to_look_key(bps[0]))

    def remove_all_signs(self):
        files_dict = self.registered_breakpoints.get_lookups()
        for bp_dict in files_dict.values():
            for bps in bp_dict.values():
                self.unplace_sign(self.bp_to_look_key(bps[0]))

    def vim_toggle_breakpoint(self, filename, line):
        bps = self.registered_breakpoints.lookup(filename, line)
        if len(bps) == 0:
            vim.command('let l:command = "break "')

    def begin_breakpoint(self):
        self.breakpoint = ''

    def append_breakpoint(self, string):
        self.breakpoint += string

    def handle_inferior_exit(self):
        """
        Handle termination of process running in gdb.
        """
        self.inferior_exit = True
        # Remove break point sign pointer from vim (if any)
        vim.command('call conque_gdb#remove_prev_pointer()')

    def finalize_breakpoint(self):
        """
        Extract file name and line number from a gdb break point.
        And send it to the conque gdb vim script.
        """
        sp = self.breakpoint.rsplit(':', 4)
        self.breakpoint = None
        vim.command("call conque_gdb#breakpoint('%s','%s')" % (self.convert_to_vim_file(sp[0]), sp[1]))

    def finalize_inferior_exit(self):
        self.inferior_exit = False
autoload/conque_gdb/conque_gdb_gdb.py	[[[1
17
import gdb, os, signal

def exit_handler(event):
    """
    Print '\x1a\x19' to gdb buffer to indicate a process has terminated.
    """
    print('\x1a\x19')

def prompt_hook(prompt):
    print('\x1a\x18')
    gdb.execute('interp mi "-break-list"')
    print('\x1a\x18')

gdb.events.exited.connect(exit_handler)
gdb.prompt_hook = prompt_hook

gdb.execute('source ' + os.path.dirname(os.path.abspath(__file__)) + '/conque_gdb.gdb', False, True)
autoload/conque_gdb/conque_sole_gdb.py	[[[1
82
import re
import os

# Marks that a breakpoint has been hit
GDB_BREAK_MARK_SOLE = 0x2192

# Marks end of breakpoint output from gdb
GDB_BREAK_END_REGEX = re.compile('^\(gdb\)\s*')

class ConqueSoleGdb(ConqueSole):
    """
    Windows specific implementation of the ConqueSole class needed by the Conque GDB terminal.
    """

    # File name and line number of next break point
    breakpoint = None
    
    # Indicates whether a breakpoint is currently being constructed
    is_building_bp = False

    # Specifies whether we have lost a break point, and we must wait for it to appear again
    # -1 if we are not waiting, otherwise contains the line number of the break point we wait for
    waiting_for_bp = -1

    # Line number of the most recent breakpoint hit
    last_bp_line = -1

    # Line number of the current breakpoint being processed
    curr_bp_line = -1 

    def is_breakpoint(self, text):
        return ord(text[0]) == GDB_BREAK_MARK_SOLE and ord(text[1]) == GDB_BREAK_MARK_SOLE

    def append_breakpoint(self, text):
        """
        Append text to the break point being created currently or finalize the breakpoint
        """

        if GDB_BREAK_END_REGEX.match(text):
            self.finalize_breakpoint()
        else:
            self.breakpoint += text
            text = ' ' * len(text)
        return text

    def start_breakpoint(self, text, line):
        """
        Indicate a new breakpoint is being processed
        """

        self.is_building_bp = True
        self.curr_bp_line = line
        self.breakpoint = text[2:]
        return ' ' * len(text)

    def finalize_breakpoint(self):
        """
        Extract file name and line number from a gdb break point.
        And send it to the conque gdb vim script.
        """

        self.is_building_bp = False
        if (self.curr_bp_line > self.last_bp_line and not self.waiting_for_bp != -1) or \
                self.curr_bp_line == self.waiting_for_bp:
            self.last_bp_line = self.curr_bp_line
            self.waiting_for_bp = -1
            sp = self.breakpoint.rsplit(':', 4)
            if os.path.isfile(sp[0]):
                vim.command("call conque_gdb#breakpoint('%s','%s')" % (sp[0], sp[1]))
            else:
                self.waiting_for_bp = self.curr_bp_line

    def plain_text(self, line_nr, text, attributes, stats):
        """
        Append plain text to a gdb break point or the vim buffer.
        """

        if self.is_breakpoint(text):
            text = self.start_breakpoint(text, line_nr)
        elif self.is_building_bp:
            text = self.append_breakpoint(text)
        super(ConqueSoleGdb, self).plain_text(line_nr, text, attributes, stats)
autoload/conque_gdb/gdbinit_confirm.gdb	[[[1
24
set confirm off

set prompt (gdb) 
define set prompt
  echo set prompt is not supported by ConqueGdb\n
end

define set annotate
  echo set annotate is not supported by ConqueGdb\n
end

define layout
  echo layout command is not supported by ConqueGdb\n
end

define tui
  echo tui command is not supported by ConqueGdb\n
end

define refresh
  echo refresh command is not supported by ConqueGdb\n
end

set confirm on
autoload/conque_gdb/gdbinit_no_confirm.gdb	[[[1
20
set prompt (gdb) 
define set prompt
  echo set prompt is not supported by ConqueGdb\n
end

define set annotate
  echo set annotate is not supported by ConqueGdb\n
end

define layout
  echo layout command is not supported by ConqueGdb\n
end

define tui
  echo tui command is not supported by ConqueGdb\n
end

define refresh
  echo refresh command is not supported by ConqueGdb\n
end
autoload/conque_gdb/conque_gdb.gdb	[[[1
12

define set annotate
  echo set annotate is not supported by ConqueGdb\n
end

define layout
  echo layout command is not supported by ConqueGdb\n
end

define tui
  echo tui command is not supported by ConqueGdb\n
end
autoload/conque_term/conque.py	[[[1
1176
# FILE:     autoload/conque_term/conque.py 
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
Vim terminal emulator.

This class is the main interface between Vim and the terminal application. It 
handles both updating the Vim buffer with new output and accepting new keyboard
input from the Vim user.

Although this class was originally designed for a Unix terminal environment, it
has been extended by the ConqueSole class for Windows.

Usage:
    term = Conque()
    term.open('/bin/bash', {'TERM': 'vt100'})
    term.write("ls -lha\r")
    term.read()
    term.close()
"""

import vim
import re
import math
import time


class Conque(object):

    # screen object
    screen = None

    # subprocess object
    proc = None

    # terminal dimensions and scrolling region
    columns = 80 # same as $COLUMNS
    lines = 24 # same as $LINES
    working_columns = 80 # can be changed by CSI ? 3 l/h
    working_lines = 24 # can be changed by CSI r

    # top/bottom of the scroll region
    top = 1 # relative to top of screen
    bottom = 24 # relative to top of screen

    # cursor position
    l = 1 # current cursor line
    c = 1 # current cursor column

    # autowrap mode
    autowrap = True

    # absolute coordinate mode
    absolute_coords = True

    # tabstop positions
    tabstops = []

    # enable colors
    enable_colors = True

    # color changes
    color_changes = {}

    # color history
    color_history = {}

    # color highlight cache
    highlight_groups = {}

    # prune terminal colors
    color_pruning = True

    # don't wrap table output
    unwrap_tables = True

    # wrap CUF/CUB around line breaks
    wrap_cursor = False

    # do we need to move the cursor?
    cursor_set = False

    # current character set, ascii or graphics
    character_set = 'ascii'

    # used for auto_read actions
    read_count = 0

    # input buffer, array of ordinals
    input_buffer = []

    def open(self):
        """ Start program and initialize this instance. 

        Arguments:
        command -- Command string to execute, e.g. '/bin/bash --login'
        options -- Dictionary of environment vars to set and other options.

        """
        # get arguments
        command = vim.eval('command')
        options = vim.eval('options')

        # create terminal screen instance
        self.screen = ConqueScreen()

        # int vars
        self.columns = vim.current.window.width
        self.lines = vim.current.window.height
        self.working_columns = vim.current.window.width
        self.working_lines = vim.current.window.height
        self.bottom = vim.current.window.height

        # offset first line to make room for startup messages
        if int(options['offset']) > 0:
            self.l = int(options['offset'])

        # init color
        self.enable_colors = int(options['color']) and not CONQUE_FAST_MODE

        # init tabstops
        self.init_tabstops()

        # open command
        self.proc = ConqueSubprocess()
        self.proc.open(command, {'TERM': options['TERM'], 'CONQUE': '1', 'LINES': str(self.lines), 'COLUMNS': str(self.columns)})

        # send window size signal, in case LINES/COLUMNS is ignored
        self.update_window_size(True)


    def write(self, input, set_cursor=True, read=True):
        """ Write a unicode string to the subprocess. 

        set_cursor -- Position the cursor in the current buffer when finished
        read -- Check program for new output when finished

        """
        # check if window size has changed
        if not CONQUE_FAST_MODE:
            self.update_window_size()

        # write and read
        self.proc.write(input)

        # read output immediately
        if read:
            self.read(1, set_cursor)



    def write_ord(self, input, set_cursor=True, read=True):
        """ Write a single character to the subprocess, using an unicode ordinal. """

        if CONQUE_PYTHON_VERSION == 2:
            self.write(unichr(input), set_cursor, read)
        else:
            self.write(chr(input), set_cursor, read)
        


    def write_expr(self, expr, set_cursor=True, read=True):
        """ Write the value of a Vim expression to the subprocess. """

        if CONQUE_PYTHON_VERSION == 2:
            try:
                val = vim.eval(expr)
                self.write(unicode(val, CONQUE_VIM_ENCODING, 'ignore'), set_cursor, read)
            except:

                pass
        else:
            try:
                # XXX - Depending on Vim to deal with encoding, sadly
                self.write(vim.eval(expr), set_cursor, read)
            except:

                pass


    def write_latin1(self, input, set_cursor=True, read=True):
        """ Write latin-1 string to conque. Very ugly, shood be removed. """
        # XXX - this whole method is a hack, to be removed soon

        if CONQUE_PYTHON_VERSION == 2:
            try:
                input_unicode = input.decode('latin-1', 'ignore')
                self.write(input_unicode.encode('utf-8', 'ignore'), set_cursor, read)
            except:
                return
        else:
            self.write(input, set_cursor, read)


    def write_buffered_ord(self, chr):
        """ Add character ordinal to input buffer. In case we're not allowed to modify buffer a time of input. """
        self.input_buffer.append(chr)


    def read(self, timeout=1, set_cursor=True, return_output=False, update_buffer=True):
        """ Read new output from the subprocess and update the Vim buffer.

        Arguments:
        timeout -- Milliseconds to wait before reading input
        set_cursor -- Set the cursor position in the current buffer when finished
        return_output -- Return new subprocess STDOUT + STDERR as a string
        update_buffer -- Update the current Vim buffer with the new output

        This method goes through the following rough steps:
            1. Get new output from subprocess
            2. Split output string into control codes, escape sequences, or plain text
            3. Loop over and process each chunk, updating the Vim buffer as we go

        """
        output = ''

        # this may not actually work
        try:

            # read from subprocess and strip null characters
            output = self.proc.read(timeout)

            if output == '':
                return output

            # for bufferless terminals
            if not update_buffer:
                return output



            # strip null characters. I'm still not sure why they appear
            output = output.replace(chr(0), '')

            # split input into individual escape sequences, control codes, and text output
            chunks = CONQUE_SEQ_REGEX.split(output)



            # if there were no escape sequences, skip processing and treat entire string as plain text
            if len(chunks) == 1:
                self.plain_text(chunks[0])

            # loop through and process escape sequences
            else:
                for s in chunks:
                    if s == '':
                        continue




                    # Check for control character match 
                    if CONQUE_SEQ_REGEX_CTL.match(s[0]):

                        nr = ord(s[0])
                        if nr in CONQUE_CTL:
                            getattr(self, 'ctl_' + CONQUE_CTL[nr])()
                        else:

                            pass

                    # check for escape sequence match 
                    elif CONQUE_SEQ_REGEX_CSI.match(s):

                        if s[-1] in CONQUE_ESCAPE:
                            csi = self.parse_csi(s[2:])

                            getattr(self, 'csi_' + CONQUE_ESCAPE[s[-1]])(csi)
                        else:

                            pass

                    # check for title match 
                    elif CONQUE_SEQ_REGEX_TITLE.match(s):

                        self.change_title(s[2], s[4:-1])

                    # check for hash match 
                    elif CONQUE_SEQ_REGEX_HASH.match(s):

                        if s[-1] in CONQUE_ESCAPE_HASH:
                            getattr(self, 'hash_' + CONQUE_ESCAPE_HASH[s[-1]])()
                        else:

                            pass

                    # check for charset match 
                    elif CONQUE_SEQ_REGEX_CHAR.match(s):

                        if s[-1] in CONQUE_ESCAPE_CHARSET:
                            getattr(self, 'charset_' + CONQUE_ESCAPE_CHARSET[s[-1]])()
                        else:

                            pass

                    # check for other escape match 
                    elif CONQUE_SEQ_REGEX_ESC.match(s):

                        if s[-1] in CONQUE_ESCAPE_PLAIN:
                            getattr(self, 'esc_' + CONQUE_ESCAPE_PLAIN[s[-1]])()
                        else:

                            pass

                    # else process plain text 
                    else:
                        self.plain_text(s)

            # set cusor position
            if set_cursor:
                self.screen.set_cursor(self.l, self.c)

            # we need to set the cursor position
            self.cursor_set = False

        except:


            pass

        if return_output:
            if CONQUE_PYTHON_VERSION == 3:
                return output
            else:
                return output.encode(CONQUE_VIM_ENCODING, 'replace')


    def auto_read(self, reset_timer = True):
        """ Poll program for more output. 

        Since Vim doesn't have a reliable event system that can be triggered when new
        output is available, we have to continually poll the subprocess instead. This
        method is called many times a second when the terminal buffer is active, so it
        needs to be very fast and efficient.

        The feedkeys portion is required to reset Vim's timer system. The timer is used
        to execute this command, typically set to go off after 50 ms of inactivity.

        """

        # process buffered input if any
        if len(self.input_buffer):
            for chr in self.input_buffer:
                self.write_ord(chr, set_cursor=False, read=False)
            self.input_buffer = []
            self.read(1)

        if not self.proc.is_alive():
            vim.command('call conque_term#get_instance().close()')
            return

        # check subprocess status, but not every time since it's CPU expensive
        if self.read_count % 32 == 0:
            if self.read_count > 512:
                self.read_count = 0

                # trim color history occasionally if desired
                if self.enable_colors and self.color_pruning:
                    self.prune_colors()

        # ++
        self.read_count += 1

        # read output
        self.read(1)

        if reset_timer:
            try:
                # reset timer
                if self.c == vim.eval('col("$")'):
                    vim.command('call feedkeys("\<Right>", "n")')
                else:
                    vim.command('call feedkeys("\<Right>\<Left>", "n")')
            except:
                pass

        # stop here if cursor doesn't need to be moved
        if self.cursor_set:
            return

        # otherwise set cursor position
        try:
            self.set_cursor(self.l, self.c)
        except:
            pass

        self.cursor_set = True


    def plain_text(self, input):
        """ Write text output to Vim buffer.

  
        This method writes a string of characters without any control characters or escape sequences
        to the Vim buffer. In simple terms, it writes the input string to the buffer starting at the
        current cursor position, wrapping the text to a new line if needed. It also triggers the 
        terminal coloring methods if needed.


        """
        # translate input into graphics character set if needed
        if self.character_set == 'graphics':
            old_input = input
            input = u('')
            for i in range(0, len(old_input)):
                chrd = ord(old_input[i])


                try:
                    if chrd > 255:

                        input = input + old_input[i]
                    else:
                        input = input + uchr(CONQUE_GRAPHICS_SET[chrd])
                except:

                    pass



        # get current line from Vim buffer
        current_line = self.screen[self.l]

        # pad current line with spaces, if it's shorter than cursor position
        if len(current_line) < self.c:
            current_line = current_line + ' ' * (self.c - len(current_line))

        # if line is wider than screen
        if self.c + len(input) - 1 > self.working_columns:

            # Table formatting hack
            if self.unwrap_tables and CONQUE_TABLE_OUTPUT.match(input):
                self.screen[self.l] = current_line[:self.c - 1] + input + current_line[self.c + len(input) - 1:]
                self.apply_color(self.c, self.c + len(input))
                self.c += len(input)
                return


            diff = self.c + len(input) - self.working_columns - 1

            # if autowrap is enabled
            if self.autowrap:
                self.screen[self.l] = current_line[:self.c - 1] + input[:-1 * diff]
                self.apply_color(self.c, self.working_columns)
                self.ctl_nl()
                self.ctl_cr()
                remaining = input[-1 * diff:]

                self.plain_text(remaining)
            else:
                self.screen[self.l] = current_line[:self.c - 1] + input[:-1 * diff - 1] + input[-1]
                self.apply_color(self.c, self.working_columns)
                self.c = self.working_columns

        # no autowrap
        else:
            self.screen[self.l] = current_line[:self.c - 1] + input + current_line[self.c + len(input) - 1:]
            self.apply_color(self.c, self.c + len(input))
            self.c += len(input)



    def apply_color(self, start, end, line=0):
        """ Apply terminal colors to buffer for a range of characters in a single line. 

        When a text attribute escape sequence is encountered during input processing, the
        attributes are recorded in the dictionary self.color_changes. After those attributes
        have been applied, the changes are recorded in a second dictionary self.color_history.

  
        This method inspects both dictionaries to calculate any syntax highlighting 
        that needs to be executed to render the text attributes in the Vim buffer.


        """


        # stop here if coloration is disabled
        if not self.enable_colors:
            return

        # allow custom line nr to be passed
        if line:
            buffer_line = line
        else:
            buffer_line = self.get_buffer_line(self.l)

        # check for previous overlapping coloration

        to_del = []
        if buffer_line in self.color_history:
            for i in range(len(self.color_history[buffer_line])):
                syn = self.color_history[buffer_line][i]

                if syn['start'] >= start and syn['start'] < end:

                    vim.command('syn clear ' + syn['name'])
                    to_del.append(i)
                    # outside
                    if syn['end'] > end:

                        self.exec_highlight(buffer_line, end, syn['end'], syn['highlight'])
                elif syn['end'] > start and syn['end'] <= end:

                    vim.command('syn clear ' + syn['name'])
                    to_del.append(i)
                    # outside
                    if syn['start'] < start:

                        self.exec_highlight(buffer_line, syn['start'], start, syn['highlight'])

        # remove overlapped colors
        if len(to_del) > 0:
            to_del.reverse()
            for di in to_del:
                del self.color_history[buffer_line][di]

        # if there are no new colors
        if len(self.color_changes) == 0:
            return

        # build the color attribute string
        highlight = ''
        for attr in self.color_changes.keys():
            highlight = highlight + ' ' + attr + '=' + self.color_changes[attr]

        # execute the highlight
        self.exec_highlight(buffer_line, start, end, highlight)


    def exec_highlight(self, buffer_line, start, end, highlight):
        """ Execute the Vim commands for a single syntax highlight """

        syntax_name = 'ConqueHighLightAt_%d_%d_%d_%d' % (self.proc.pid, self.l, start, len(self.color_history) + 1)
        syntax_options = 'contains=ALLBUT,ConqueString,MySQLString,MySQLKeyword oneline'
        syntax_region = 'syntax match %s /\%%%dl\%%>%dc.\{%d}\%%<%dc/ %s' % (syntax_name, buffer_line, start - 1, end - start, end + 1, syntax_options)

        # check for cached highlight group
        hgroup = 'ConqueHL_%d' % (abs(hash(highlight)))
        if hgroup not in self.highlight_groups:
            syntax_group = 'highlight %s %s' % (hgroup, highlight)
            self.highlight_groups[hgroup] = hgroup
            vim.command(syntax_group)

        # link this syntax match to existing highlight group
        syntax_highlight = 'highlight link %s %s' % (syntax_name, self.highlight_groups[hgroup])



        vim.command(syntax_region)
        vim.command(syntax_highlight)

        # add syntax name to history
        if not buffer_line in self.color_history:
            self.color_history[buffer_line] = []

        self.color_history[buffer_line].append({'name': syntax_name, 'start': start, 'end': end, 'highlight': highlight})


    def prune_colors(self):
        """ Remove old syntax highlighting from the Vim buffer

        The kind of syntax highlighting required for terminal colors can make
        Conque run slowly. The prune_colors() method will remove old highlight definitions
        to keep the maximum number of highlight rules within a reasonable range.

        """


        buffer_line = self.get_buffer_line(self.l)
        ks = list(self.color_history.keys())

        for line in ks:
            if line < buffer_line - CONQUE_MAX_SYNTAX_LINES:
                for syn in self.color_history[line]:
                    vim.command('syn clear ' + syn['name'])
                del self.color_history[line]




    ###############################################################################################
    # Control functions 

    def ctl_nl(self):
        """ Process the newline control character. """
        # if we're in a scrolling region, scroll instead of moving cursor down
        if self.lines != self.working_lines and self.l == self.bottom:
            del self.screen[self.top]
            self.screen.insert(self.bottom, '')
        elif self.l == self.bottom:
            self.screen.append('')
        else:
            self.l += 1

        self.color_changes = {}

    def ctl_cr(self):
        """ Process the carriage return control character. """
        self.c = 1

        self.color_changes = {}

    def ctl_bs(self):
        """ Process the backspace control character. """
        if self.c > 1:
            self.c += -1

    def ctl_soh(self):
        """ Process the start of heading control character. """
        pass

    def ctl_stx(self):
        pass

    def ctl_bel(self):
        """ Process the bell control character. """
        vim.command('call conque_term#bell()')

    def ctl_tab(self):
        """ Process the tab control character. """
        # default tabstop location
        ts = self.working_columns

        # check set tabstops
        for i in range(self.c, len(self.tabstops)):
            if self.tabstops[i]:
                ts = i + 1
                break



        self.c = ts

    def ctl_so(self):
        """ Process the shift out control character. """
        self.character_set = 'graphics'

    def ctl_si(self):
        """ Process the shift in control character. """
        self.character_set = 'ascii'



    ###############################################################################################
    # CSI functions 

    def csi_font(self, csi):
        """ Process the text attribute escape sequence. """
        if not self.enable_colors:
            return

        # defaults to 0
        if len(csi['vals']) == 0:
            csi['vals'] = [0]

        # 256 xterm color foreground
        if len(csi['vals']) == 3 and csi['vals'][0] == 38 and csi['vals'][1] == 5:
            self.color_changes['ctermfg'] = str(csi['vals'][2])
            self.color_changes['guifg'] = '#' + self.xterm_to_rgb(csi['vals'][2])

        # 256 xterm color background
        elif len(csi['vals']) == 3 and csi['vals'][0] == 48 and csi['vals'][1] == 5:
            self.color_changes['ctermbg'] = str(csi['vals'][2])
            self.color_changes['guibg'] = '#' + self.xterm_to_rgb(csi['vals'][2])

        # 16 colors
        else:
            for val in csi['vals']:
                if val in CONQUE_FONT:

                    # ignore starting normal colors
                    if CONQUE_FONT[val]['normal'] and len(self.color_changes) == 0:

                        continue
                    # clear color changes
                    elif CONQUE_FONT[val]['normal']:

                        self.color_changes = {}
                    # save these color attributes for next plain_text() call
                    else:

                        for attr in CONQUE_FONT[val]['attributes'].keys():
                            if attr in self.color_changes and (attr == 'cterm' or attr == 'gui'):
                                self.color_changes[attr] += ',' + CONQUE_FONT[val]['attributes'][attr]
                            else:
                                self.color_changes[attr] = CONQUE_FONT[val]['attributes'][attr]


    def csi_clear_line(self, csi):
        """ Process the line clear escape sequence. """


        # this escape defaults to 0
        if len(csi['vals']) == 0:
            csi['val'] = 0




        # 0 means cursor right
        if csi['val'] == 0:
            self.screen[self.l] = self.screen[self.l][0:self.c - 1]

        # 1 means cursor left
        elif csi['val'] == 1:
            self.screen[self.l] = ' ' * (self.c) + self.screen[self.l][self.c:]

        # clear entire line
        elif csi['val'] == 2:
            self.screen[self.l] = ''

        # clear colors
        if csi['val'] == 2 or (csi['val'] == 0 and self.c == 1):
            buffer_line = self.get_buffer_line(self.l)
            if buffer_line in self.color_history:
                for syn in self.color_history[buffer_line]:
                    vim.command('syn clear ' + syn['name'])





    def csi_cursor_right(self, csi):
        """ Process the move cursor right escape sequence. """
        # we use 1 even if escape explicitly specifies 0
        if csi['val'] == 0:
            csi['val'] = 1




        if self.wrap_cursor and self.c + csi['val'] > self.working_columns:
            self.l += int(math.floor((self.c + csi['val']) / self.working_columns))
            self.c = (self.c + csi['val']) % self.working_columns
            return

        self.c = self.bound(self.c + csi['val'], 1, self.working_columns)


    def csi_cursor_left(self, csi):
        """ Process the move cursor left escape sequence. """
        # we use 1 even if escape explicitly specifies 0
        if csi['val'] == 0:
            csi['val'] = 1

        if self.wrap_cursor and csi['val'] >= self.c:
            self.l += int(math.floor((self.c - csi['val']) / self.working_columns))
            self.c = self.working_columns - (csi['val'] - self.c) % self.working_columns
            return

        self.c = self.bound(self.c - csi['val'], 1, self.working_columns)


    def csi_cursor_to_column(self, csi):
        """ Process the move cursor to column escape sequence. """
        self.c = self.bound(csi['val'], 1, self.working_columns)


    def csi_cursor_up(self, csi):
        """ Process the move cursor up escape sequence. """
        self.l = self.bound(self.l - csi['val'], self.top, self.bottom)

        self.color_changes = {}


    def csi_cursor_down(self, csi):
        """ Process the move cursor down escape sequence. """
        self.l = self.bound(self.l + csi['val'], self.top, self.bottom)

        self.color_changes = {}


    def csi_clear_screen(self, csi):
        """ Process the clear screen escape sequence. """
        # default to 0
        if len(csi['vals']) == 0:
            csi['val'] = 0

        # 2 == clear entire screen
        if csi['val'] == 2:
            self.l = 1
            self.c = 1
            self.screen.clear()

        # 0 == clear down
        elif csi['val'] == 0:
            for l in range(self.bound(self.l + 1, 1, self.lines), self.lines + 1):
                self.screen[l] = ''

            # clear end of current line
            self.csi_clear_line(self.parse_csi('K'))

        # 1 == clear up
        elif csi['val'] == 1:
            for l in range(1, self.bound(self.l, 1, self.lines + 1)):
                self.screen[l] = ''

            # clear beginning of current line
            self.csi_clear_line(self.parse_csi('1K'))

        # clear coloration
        if csi['val'] == 2 or csi['val'] == 0:
            buffer_line = self.get_buffer_line(self.l)
            for line in self.color_history.keys():
                if line >= buffer_line:
                    for syn in self.color_history[line]:
                        vim.command('syn clear ' + syn['name'])

        self.color_changes = {}


    def csi_delete_chars(self, csi):
        self.screen[self.l] = self.screen[self.l][:self.c] + self.screen[self.l][self.c + csi['val']:]


    def csi_add_spaces(self, csi):
        self.screen[self.l] = self.screen[self.l][: self.c - 1] + ' ' * csi['val'] + self.screen[self.l][self.c:]


    def csi_cursor(self, csi):
        if len(csi['vals']) == 2:
            new_line = csi['vals'][0]
            new_col = csi['vals'][1]
        else:
            new_line = 1
            new_col = 1

        if self.absolute_coords:
            self.l = self.bound(new_line, 1, self.lines)
        else:
            self.l = self.bound(self.top + new_line - 1, self.top, self.bottom)

        self.c = self.bound(new_col, 1, self.working_columns)
        if self.c > len(self.screen[self.l]):
            self.screen[self.l] = self.screen[self.l] + ' ' * (self.c - len(self.screen[self.l]))



    def csi_set_coords(self, csi):
        if len(csi['vals']) == 2:
            new_start = csi['vals'][0]
            new_end = csi['vals'][1]
        else:
            new_start = 1
            new_end = vim.current.window.height

        self.top = new_start
        self.bottom = new_end
        self.working_lines = new_end - new_start + 1

        # if cursor is outside scrolling region, reset it
        if self.l < self.top:
            self.l = self.top
        elif self.l > self.bottom:
            self.l = self.bottom

        self.color_changes = {}


    def csi_tab_clear(self, csi):
        # this escape defaults to 0
        if len(csi['vals']) == 0:
            csi['val'] = 0



        if csi['val'] == 0:
            self.tabstops[self.c - 1] = False
        elif csi['val'] == 3:
            for i in range(0, self.columns + 1):
                self.tabstops[i] = False


    def csi_set(self, csi):
        # 132 cols
        if csi['val'] == 3:
            self.csi_clear_screen(self.parse_csi('2J'))
            self.working_columns = 132

        # relative_origin
        elif csi['val'] == 6:
            self.absolute_coords = False

        # set auto wrap
        elif csi['val'] == 7:
            self.autowrap = True


        self.color_changes = {}


    def csi_reset(self, csi):
        # 80 cols
        if csi['val'] == 3:
            self.csi_clear_screen(self.parse_csi('2J'))
            self.working_columns = 80

        # absolute origin
        elif csi['val'] == 6:
            self.absolute_coords = True

        # reset auto wrap
        elif csi['val'] == 7:
            self.autowrap = False


        self.color_changes = {}




    ###############################################################################################
    # ESC functions 

    def esc_scroll_up(self):
        self.ctl_nl()

        self.color_changes = {}


    def esc_next_line(self):
        self.ctl_nl()
        self.c = 1


    def esc_set_tab(self):

        if self.c <= len(self.tabstops):
            self.tabstops[self.c - 1] = True


    def esc_scroll_down(self):
        if self.l == self.top:
            del self.screen[self.bottom]
            self.screen.insert(self.top, '')
        else:
            self.l += -1

        self.color_changes = {}




    ###############################################################################################
    # HASH functions 

    def hash_screen_alignment_test(self):
        self.csi_clear_screen(self.parse_csi('2J'))
        self.working_lines = self.lines
        for l in range(1, self.lines + 1):
            self.screen[l] = 'E' * self.working_columns



    ###############################################################################################
    # CHARSET functions 

    def charset_us(self):
        self.character_set = 'ascii'

    def charset_uk(self):
        self.character_set = 'ascii'

    def charset_graphics(self):
        self.character_set = 'graphics'



    ###############################################################################################
    # Random stuff 

    def set_cursor(self, line, col):
        """ Set cursor position in the Vim buffer.

        Note: the line and column numbers are relative to the top left corner of the 
        visible screen. Not the line number in the Vim buffer.

        """
        self.screen.set_cursor(line, col)

    def change_title(self, key, val):
        """ Change the Vim window title. """


        if key == '0' or key == '2':

            vim.command('setlocal statusline=' + re.escape(val))
            try:
                vim.command('set titlestring=' + re.escape(val))
            except:
                pass

    def update_window(self, force=False):
        """
        Update Conque buffer size attributes if needed.
        """
        if force or vim.current.window.width != self.columns or vim.current.window.height != self.lines:

            # reset all window size attributes to default
            self.columns = vim.current.window.width
            self.lines = vim.current.window.height
            self.working_columns = vim.current.window.width
            self.working_lines = vim.current.window.height
            self.bottom = vim.current.window.height

            # reset screen object attributes
            self.l = self.screen.reset_size(self.l)

            # reset tabstops
            self.init_tabstops()

            return True

        return False

    def update_window_size(self, force=False):
        """ Check and save the current buffer dimensions.

        If the buffer size has changed, the update_window_size() method both updates
        the Conque buffer size attributes as well as sending the new dimensions to the
        subprocess pty.

        """
        if self.update_window(force):
            # signal process that screen size has changed
            self.proc.window_resize(self.lines, self.columns)

    def insert_enter(self):
        """ Run commands when user enters insert mode. """

        # check window size
        self.update_window_size()

        # we need to set the cursor position
        self.cursor_set = False

    def init_tabstops(self):
        """ Intitialize terminal tabstop positions. """
        for i in range(0, self.columns + 1):
            if i % 8 == 0:
                self.tabstops.append(True)
            else:
                self.tabstops.append(False)

    def idle(self):
        """ Called when this terminal becomes idle. """
        pass

    def resume(self):
        """ Called when this terminal is no longer idle. """
        pass
        pass

    def close(self):
        """ End the process running in the terminal. """
        self.abort()

    def abort(self):
        """ Forcefully end the process running in the terminal. """
        self.proc.signal(1)
        self.poll_wait_for_proc(10);

    def poll_wait_for_proc(self, tries):
        """ Try 'tries' times to see if self.proc has become a zombie
		such that we can reclaim its resources. Wait for 2ms before each try.
		"""
        pid = self.proc.getpid()
        try:
            for i in range(tries):
                time.sleep(0.02)
                if os.waitpid(pid, os.WNOHANG)[0]:
                    break;
        except:
            pass
        



    ###############################################################################################
    # Utility 

    def parse_csi(self, s):
        """ Parse an escape sequence into it's meaningful values. """

        attr = {'key': s[-1], 'flag': '', 'val': 1, 'vals': []}

        if len(s) == 1:
            return attr

        full = s[0:-1]

        if full[0] == '?':
            full = full[1:]
            attr['flag'] = '?'

        if full != '':
            vals = full.split(';')
            for val in vals:

                val = re.sub("\D", "", val)

                if val != '':
                    attr['vals'].append(int(val))

        if len(attr['vals']) == 1:
            attr['val'] = int(attr['vals'][0])

        return attr


    def bound(self, val, min, max):
        """ TODO: This probably exists as a builtin function. """
        if val > max:
            return max

        if val < min:
            return min

        return val


    def xterm_to_rgb(self, color_code):
        """ Translate a terminal color number into a RGB string. """
        if color_code < 16:
            ascii_colors = ['000000', 'CD0000', '00CD00', 'CDCD00', '0000EE', 'CD00CD', '00CDCD', 'E5E5E5',
                   '7F7F7F', 'FF0000', '00FF00', 'FFFF00', '5C5CFF', 'FF00FF', '00FFFF', 'FFFFFF']
            return ascii_colors[color_code]

        elif color_code < 232:
            cc = int(color_code) - 16

            p1 = "%02x" % (math.floor(cc / 36) * (255 / 5))
            p2 = "%02x" % (math.floor((cc % 36) / 6) * (255 / 5))
            p3 = "%02x" % (math.floor(cc % 6) * (255 / 5))

            return p1 + p2 + p3
        else:
            grey_tone = "%02x" % math.floor((255 / 24) * (color_code - 232))
            return grey_tone + grey_tone + grey_tone




    def get_buffer_line(self, line):
        """ Get the buffer line number corresponding to the supplied screen line number. """
        return self.screen.get_buffer_line(line)


autoload/conque_term/conque_globals.py	[[[1
317
# FILE:     autoload/conque_term/conque_globals.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""Common global constants and functions for Conque."""

import sys
import re


# PYTHON VERSION
CONQUE_PYTHON_VERSION = sys.version_info[0]

# Encoding

try:
    # Vim's character encoding
    import vim
    CONQUE_VIM_ENCODING = vim.eval('&encoding')

except:
    CONQUE_VIM_ENCODING = 'utf-8'


def u(str_val, str_encoding='utf-8', errors='strict'):
    """ Foolhardy attempt to make unicode string syntax compatible with both python 2 and 3. """

    if not str_val:
        str_val = ''

    if CONQUE_PYTHON_VERSION == 3:
        return str_val

    else:
        return unicode(str_val, str_encoding, errors)

def uchr(str):
    """ Foolhardy attempt to make unicode string syntax compatible with both python 2 and 3. """

    if CONQUE_PYTHON_VERSION == 3:
        return chr(str)

    else:
        return unichr(str)


# Logging
















# Unix escape sequence settings

CONQUE_CTL = {
     1: 'soh', # start of heading
     2: 'stx', # start of text
     7: 'bel', # bell
     8: 'bs',  # backspace
     9: 'tab', # tab
    10: 'nl',  # new line
    13: 'cr',  # carriage return
    14: 'so',  # shift out
    15: 'si'   # shift in
}
#    11 : 'vt',  # vertical tab
#    12 : 'ff',  # form feed

# Escape sequences
CONQUE_ESCAPE = {
    'm': 'font',
    'J': 'clear_screen',
    'K': 'clear_line',
    '@': 'add_spaces',
    'A': 'cursor_up',
    'B': 'cursor_down',
    'C': 'cursor_right',
    'D': 'cursor_left',
    'G': 'cursor_to_column',
    'H': 'cursor',
    'P': 'delete_chars',
    'f': 'cursor',
    'g': 'tab_clear',
    'r': 'set_coords',
    'h': 'set',
    'l': 'reset'
}
#    'L': 'insert_lines',
#    'M': 'delete_lines',
#    'd': 'cusor_vpos',

# Alternate escape sequences, no [
CONQUE_ESCAPE_PLAIN = {
    'D': 'scroll_up',
    'E': 'next_line',
    'H': 'set_tab',
    'M': 'scroll_down'
}
#    'N': 'single_shift_2',
#    'O': 'single_shift_3',
#    '=': 'alternate_keypad',
#    '>': 'numeric_keypad',
#    '7': 'save_cursor',
#    '8': 'restore_cursor',

# Character set escape sequences, with "("
CONQUE_ESCAPE_CHARSET = {
    'A': 'uk',
    'B': 'us',
    '0': 'graphics'
}

# Uber alternate escape sequences, with # or ?
CONQUE_ESCAPE_QUESTION = {
    '1h': 'new_line_mode',
    '3h': '132_cols',
    '4h': 'smooth_scrolling',
    '5h': 'reverse_video',
    '6h': 'relative_origin',
    '7h': 'set_auto_wrap',
    '8h': 'set_auto_repeat',
    '9h': 'set_interlacing_mode',
    '1l': 'set_cursor_key',
    '2l': 'set_vt52',
    '3l': '80_cols',
    '4l': 'set_jump_scrolling',
    '5l': 'normal_video',
    '6l': 'absolute_origin',
    '7l': 'reset_auto_wrap',
    '8l': 'reset_auto_repeat',
    '9l': 'reset_interlacing_mode'
}

CONQUE_ESCAPE_HASH = {
    '8': 'screen_alignment_test'
}
#    '3': 'double_height_top',
#    '4': 'double_height_bottom',
#    '5': 'single_height_single_width',
#    '6': 'single_height_double_width',

CONQUE_GRAPHICS_SET = [
    0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007,
    0x0008, 0x0009, 0x000A, 0x000B, 0x000C, 0x000D, 0x000E, 0x000F,
    0x0010, 0x0011, 0x0012, 0x0013, 0x0014, 0x0015, 0x0016, 0x0017,
    0x0018, 0x0019, 0x001A, 0x001B, 0x001C, 0x001D, 0x001E, 0x001F,
    0x0020, 0x0021, 0x0022, 0x0023, 0x0024, 0x0025, 0x0026, 0x0027,
    0x0028, 0x0029, 0x002A, 0x2192, 0x2190, 0x2191, 0x2193, 0x002F,
    0x2588, 0x0031, 0x0032, 0x0033, 0x0034, 0x0035, 0x0036, 0x0037,
    0x0038, 0x0039, 0x003A, 0x003B, 0x003C, 0x003D, 0x003E, 0x003F,
    0x0040, 0x0041, 0x0042, 0x0043, 0x0044, 0x0045, 0x0046, 0x0047,
    0x0048, 0x0049, 0x004A, 0x004B, 0x004C, 0x004D, 0x004E, 0x004F,
    0x0050, 0x0051, 0x0052, 0x0053, 0x0054, 0x0055, 0x0056, 0x0057,
    0x0058, 0x0059, 0x005A, 0x005B, 0x005C, 0x005D, 0x005E, 0x00A0,
    0x25C6, 0x2592, 0x2409, 0x240C, 0x240D, 0x240A, 0x00B0, 0x00B1,
    0x2591, 0x240B, 0x2518, 0x2510, 0x250C, 0x2514, 0x253C, 0xF800,
    0xF801, 0x2500, 0xF803, 0xF804, 0x251C, 0x2524, 0x2534, 0x252C,
    0x2502, 0x2264, 0x2265, 0x03C0, 0x2260, 0x00A3, 0x00B7, 0x007F,
    0x0080, 0x0081, 0x0082, 0x0083, 0x0084, 0x0085, 0x0086, 0x0087,
    0x0088, 0x0089, 0x008A, 0x008B, 0x008C, 0x008D, 0x008E, 0x008F,
    0x0090, 0x0091, 0x0092, 0x0093, 0x0094, 0x0095, 0x0096, 0x0097,
    0x0098, 0x0099, 0x009A, 0x009B, 0x009C, 0x009D, 0x009E, 0x009F,
    0x00A0, 0x00A1, 0x00A2, 0x00A3, 0x00A4, 0x00A5, 0x00A6, 0x00A7,
    0x00A8, 0x00A9, 0x00AA, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x00AF,
    0x00B0, 0x00B1, 0x00B2, 0x00B3, 0x00B4, 0x00B5, 0x00B6, 0x00B7,
    0x00B8, 0x00B9, 0x00BA, 0x00BB, 0x00BC, 0x00BD, 0x00BE, 0x00BF,
    0x00C0, 0x00C1, 0x00C2, 0x00C3, 0x00C4, 0x00C5, 0x00C6, 0x00C7,
    0x00C8, 0x00C9, 0x00CA, 0x00CB, 0x00CC, 0x00CD, 0x00CE, 0x00CF,
    0x00D0, 0x00D1, 0x00D2, 0x00D3, 0x00D4, 0x00D5, 0x00D6, 0x00D7,
    0x00D8, 0x00D9, 0x00DA, 0x00DB, 0x00DC, 0x00DD, 0x00DE, 0x00DF,
    0x00E0, 0x00E1, 0x00E2, 0x00E3, 0x00E4, 0x00E5, 0x00E6, 0x00E7,
    0x00E8, 0x00E9, 0x00EA, 0x00EB, 0x00EC, 0x00ED, 0x00EE, 0x00EF,
    0x00F0, 0x00F1, 0x00F2, 0x00F3, 0x00F4, 0x00F5, 0x00F6, 0x00F7,
    0x00F8, 0x00F9, 0x00FA, 0x00FB, 0x00FC, 0x00FD, 0x00FE, 0x00FF
]

# Font codes
CONQUE_FONT = {
    0: {'description': 'Normal (default)', 'attributes': {'cterm': 'NONE', 'ctermfg': 'NONE', 'ctermbg': 'NONE', 'gui': 'NONE', 'guifg': 'NONE', 'guibg': 'NONE'}, 'normal': True},
    1: {'description': 'Bold', 'attributes': {'cterm': 'BOLD', 'gui': 'BOLD'}, 'normal': False},
    4: {'description': 'Underlined', 'attributes': {'cterm': 'UNDERLINE', 'gui': 'UNDERLINE'}, 'normal': False},
    5: {'description': 'Blink (appears as Bold)', 'attributes': {'cterm': 'BOLD', 'gui': 'BOLD'}, 'normal': False},
    7: {'description': 'Inverse', 'attributes': {'cterm': 'REVERSE', 'gui': 'REVERSE'}, 'normal': False},
    8: {'description': 'Invisible (hidden)', 'attributes': {'ctermfg': '0', 'ctermbg': '0', 'guifg': '#000000', 'guibg': '#000000'}, 'normal': False},
    22: {'description': 'Normal (neither bold nor faint)', 'attributes': {'cterm': 'NONE', 'gui': 'NONE'}, 'normal': True},
    24: {'description': 'Not underlined', 'attributes': {'cterm': 'NONE', 'gui': 'NONE'}, 'normal': True},
    25: {'description': 'Steady (not blinking)', 'attributes': {'cterm': 'NONE', 'gui': 'NONE'}, 'normal': True},
    27: {'description': 'Positive (not inverse)', 'attributes': {'cterm': 'NONE', 'gui': 'NONE'}, 'normal': True},
    28: {'description': 'Visible (not hidden)', 'attributes': {'ctermfg': 'NONE', 'ctermbg': 'NONE', 'guifg': 'NONE', 'guibg': 'NONE'}, 'normal': True},
    30: {'description': 'Set foreground color to Black', 'attributes': {'ctermfg': '16', 'guifg': '#000000'}, 'normal': False},
    31: {'description': 'Set foreground color to Red', 'attributes': {'ctermfg': '1', 'guifg': '#ff0000'}, 'normal': False},
    32: {'description': 'Set foreground color to Green', 'attributes': {'ctermfg': '2', 'guifg': '#00ff00'}, 'normal': False},
    33: {'description': 'Set foreground color to Yellow', 'attributes': {'ctermfg': '3', 'guifg': '#ffff00'}, 'normal': False},
    34: {'description': 'Set foreground color to Blue', 'attributes': {'ctermfg': '4', 'guifg': '#0000ff'}, 'normal': False},
    35: {'description': 'Set foreground color to Magenta', 'attributes': {'ctermfg': '5', 'guifg': '#990099'}, 'normal': False},
    36: {'description': 'Set foreground color to Cyan', 'attributes': {'ctermfg': '6', 'guifg': '#009999'}, 'normal': False},
    37: {'description': 'Set foreground color to White', 'attributes': {'ctermfg': '7', 'guifg': '#ffffff'}, 'normal': False},
    39: {'description': 'Set foreground color to default (original)', 'attributes': {'ctermfg': 'NONE', 'guifg': 'NONE'}, 'normal': True},
    40: {'description': 'Set background color to Black', 'attributes': {'ctermbg': '16', 'guibg': '#000000'}, 'normal': False},
    41: {'description': 'Set background color to Red', 'attributes': {'ctermbg': '1', 'guibg': '#ff0000'}, 'normal': False},
    42: {'description': 'Set background color to Green', 'attributes': {'ctermbg': '2', 'guibg': '#00ff00'}, 'normal': False},
    43: {'description': 'Set background color to Yellow', 'attributes': {'ctermbg': '3', 'guibg': '#ffff00'}, 'normal': False},
    44: {'description': 'Set background color to Blue', 'attributes': {'ctermbg': '4', 'guibg': '#0000ff'}, 'normal': False},
    45: {'description': 'Set background color to Magenta', 'attributes': {'ctermbg': '5', 'guibg': '#990099'}, 'normal': False},
    46: {'description': 'Set background color to Cyan', 'attributes': {'ctermbg': '6', 'guibg': '#009999'}, 'normal': False},
    47: {'description': 'Set background color to White', 'attributes': {'ctermbg': '7', 'guibg': '#ffffff'}, 'normal': False},
    49: {'description': 'Set background color to default (original).', 'attributes': {'ctermbg': 'NONE', 'guibg': 'NONE'}, 'normal': True},
    90: {'description': 'Set foreground color to Black', 'attributes': {'ctermfg': '8', 'guifg': '#000000'}, 'normal': False},
    91: {'description': 'Set foreground color to Red', 'attributes': {'ctermfg': '9', 'guifg': '#ff0000'}, 'normal': False},
    92: {'description': 'Set foreground color to Green', 'attributes': {'ctermfg': '10', 'guifg': '#00ff00'}, 'normal': False},
    93: {'description': 'Set foreground color to Yellow', 'attributes': {'ctermfg': '11', 'guifg': '#ffff00'}, 'normal': False},
    94: {'description': 'Set foreground color to Blue', 'attributes': {'ctermfg': '12', 'guifg': '#0000ff'}, 'normal': False},
    95: {'description': 'Set foreground color to Magenta', 'attributes': {'ctermfg': '13', 'guifg': '#990099'}, 'normal': False},
    96: {'description': 'Set foreground color to Cyan', 'attributes': {'ctermfg': '14', 'guifg': '#009999'}, 'normal': False},
    97: {'description': 'Set foreground color to White', 'attributes': {'ctermfg': '15', 'guifg': '#ffffff'}, 'normal': False},
    100: {'description': 'Set background color to Black', 'attributes': {'ctermbg': '8', 'guibg': '#000000'}, 'normal': False},
    101: {'description': 'Set background color to Red', 'attributes': {'ctermbg': '9', 'guibg': '#ff0000'}, 'normal': False},
    102: {'description': 'Set background color to Green', 'attributes': {'ctermbg': '10', 'guibg': '#00ff00'}, 'normal': False},
    103: {'description': 'Set background color to Yellow', 'attributes': {'ctermbg': '11', 'guibg': '#ffff00'}, 'normal': False},
    104: {'description': 'Set background color to Blue', 'attributes': {'ctermbg': '12', 'guibg': '#0000ff'}, 'normal': False},
    105: {'description': 'Set background color to Magenta', 'attributes': {'ctermbg': '13', 'guibg': '#990099'}, 'normal': False},
    106: {'description': 'Set background color to Cyan', 'attributes': {'ctermbg': '14', 'guibg': '#009999'}, 'normal': False},
    107: {'description': 'Set background color to White', 'attributes': {'ctermbg': '15', 'guibg': '#ffffff'}, 'normal': False}
}


# regular expression matching (almost) all control sequences
CONQUE_SEQ_REGEX = re.compile("(\x1b\[?\??#?[0-9;]*[a-zA-Z0-9@=>]|\x1b\][0-9];.*?\x07|[\x01-\x0f]|\x1b\([AB0])")
CONQUE_SEQ_REGEX_CTL = re.compile("^[\x01-\x0f]$")
CONQUE_SEQ_REGEX_CSI = re.compile("^\x1b\[")
CONQUE_SEQ_REGEX_TITLE = re.compile("^\x1b\]")
CONQUE_SEQ_REGEX_HASH = re.compile("^\x1b#")
CONQUE_SEQ_REGEX_ESC = re.compile("^\x1b.$")
CONQUE_SEQ_REGEX_CHAR = re.compile("^\x1b[()]")

# match table output
CONQUE_TABLE_OUTPUT = re.compile("^\s*\|\s.*\s\|\s*$|^\s*\+[=+-]+\+\s*$")

# basic terminal colors
CONQUE_COLOR_SEQUENCE = (
    '000', '009', '090', '099', '900', '909', '990', '999',
    '000', '00f', '0f0', '0ff', 'f00', 'f0f', 'ff0', 'fff'
)


# Windows subprocess constants

# shared memory size
CONQUE_SOLE_BUFFER_LENGTH = 1000
CONQUE_SOLE_INPUT_SIZE = 1000
CONQUE_SOLE_STATS_SIZE = 1000
CONQUE_SOLE_COMMANDS_SIZE = 255
CONQUE_SOLE_RESCROLL_SIZE = 255
CONQUE_SOLE_RESIZE_SIZE = 255

# interval of screen redraw
# larger number means less frequent
CONQUE_SOLE_SCREEN_REDRAW = 50

# interval of full buffer redraw
# larger number means less frequent
CONQUE_SOLE_BUFFER_REDRAW = 500

# interval of full output bucket replacement
# larger number means less frequent, 1 = every time
CONQUE_SOLE_MEM_REDRAW = 1000

# maximum number of lines with terminal colors
# ignored if g:ConqueTerm_Color = 2
CONQUE_MAX_SYNTAX_LINES = 200

# windows input splitting on special keys
CONQUE_WIN32_REGEX_VK = re.compile("(\x1b\[[0-9;]+VK)")

# windows attribute string splitting
CONQUE_WIN32_REGEX_ATTR = re.compile("((.)\\2*)", re.DOTALL)

# special key attributes
CONQUE_VK_ATTR_CTRL_PRESSED = u('1024')


autoload/conque_term/conque_screen.py	[[[1
236
# FILE:     autoload/conque_term/conque_screen.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
ConqueScreen is an extention of the vim.current.buffer object

Unix terminal escape sequences usually reference line numbers relative to the 
top of the visible screen. However the visible portion of the Vim buffer
representing the terminal probably doesn't start at the first line of the 
buffer.

The ConqueScreen class allows access to the Vim buffer with screen-relative
line numbering. And handles a few other related tasks, such as setting the
correct cursor position.

  E.g.:
    s = ConqueScreen()
    ...
    s[5] = 'Set 5th line in terminal to this line'
    s.append('Add new line to terminal')
    s[5] = 'Since previous append() command scrolled the terminal down, this is a different line than first cb[5] call'

"""

import vim

class ConqueScreen(object):

    # the buffer
    buffer = None

    # screen and scrolling regions
    screen_top = 1

    # screen width
    screen_width = 80
    screen_height = 80

    # char encoding for vim buffer
    screen_encoding = 'utf-8'


    def __init__(self):
        """ Initialize screen size and character encoding. """

        self.buffer = vim.current.buffer

        # initialize screen size
        self.screen_top = 1
        self.screen_width = vim.current.window.width
        self.screen_height = vim.current.window.height

        # save screen character encoding type
        self.screen_encoding = vim.eval('&fileencoding')


    def __len__(self):
        """ Define the len() function for ConqueScreen objects. """
        return len(self.buffer)


    def __getitem__(self, key):
        """ Define value access for ConqueScreen objects. """
        buffer_line = self.get_real_idx(key)

        # if line is past buffer end, add lines to buffer
        if buffer_line >= len(self.buffer):
            for i in range(len(self.buffer), buffer_line + 1):
                self.append(' ')

        return u(self.buffer[buffer_line], 'utf-8')


    def __setitem__(self, key, value):
        """ Define value assignments for ConqueScreen objects. """
        buffer_line = self.get_real_idx(key)

        if CONQUE_PYTHON_VERSION == 2:
            val = value.encode(self.screen_encoding)
        else:
            # XXX / Vim's python3 interface doesn't accept bytes object
            val = str(value)

        # if line is past end of screen, append
        if buffer_line == len(self.buffer):
            self.buffer.append(val)
        else:
            self.buffer[buffer_line] = val


    def __delitem__(self, key):
        """ Define value deletion for ConqueScreen objects. """
        del self.buffer[self.screen_top + key - 2]


    def append(self, value):
        """ Define value appending for ConqueScreen objects. """

        if len(self.buffer) > self.screen_top + self.screen_height - 1:
            self.buffer[len(self.buffer) - 1] = value
        else:
            self.buffer.append(value)

        if len(self.buffer) > self.screen_top + self.screen_height - 1:
            self.screen_top += 1

        if vim.current.buffer.number == self.buffer.number:
            vim.command('normal! G')


    def insert(self, line, value):
        """ Define value insertion for ConqueScreen objects. """

        l = self.screen_top + line - 2
        try:
            self.buffer.append(value, l)
        except:
            self.buffer[l:l] = [value]


    def get_top(self):
        """ Get the Vim line number representing the top of the visible terminal. """
        return self.screen_top


    def get_real_idx(self, line):
        """ Get the zero index Vim line number corresponding to the provided screen line. """
        return (self.screen_top + line - 2)


    def get_buffer_line(self, line):
        """ Get the Vim line number corresponding to the provided screen line. """
        return (self.screen_top + line - 1)


    def set_screen_width(self, width):
        """ Set the screen width. """
        self.screen_width = width


    def clear(self):
        """ Clear the screen. Does not clear the buffer, just scrolls down past all text. """

        self.screen_width = width
        self.buffer.append(' ')
        vim.command('normal! Gzt')
        self.screen_top = len(self.buffer)


    def set_cursor(self, line, column):
        """ Set cursor position. """

        # figure out line
        buffer_line = self.screen_top + line - 1
        if buffer_line > len(self.buffer):
            for l in range(len(self.buffer) - 1, buffer_line):
                self.buffer.append('')

        # figure out column
        real_column = column
        if len(self.buffer[buffer_line - 1]) < real_column:
            self.buffer[buffer_line - 1] = self.buffer[buffer_line - 1] + ' ' * (real_column - len(self.buffer[buffer_line - 1]))

        if not CONQUE_FAST_MODE:
            # set cursor at byte index of real_column'th character
            vim.command('call cursor(' + str(buffer_line) + ', byteidx(getline(' + str(buffer_line) + '), ' + str(real_column) + '))')

        else:
            # old version
            # python version is occasionally grumpy
            try:
                vim.current.window.cursor = (buffer_line, real_column - 1)
            except:
                vim.command('call cursor(' + str(buffer_line) + ', ' + str(real_column) + ')')


    def reset_size(self, line):
        """ Change screen size """





        # save cursor line number
        buffer_line = self.screen_top + line

        # reset screen size
        self.screen_width = vim.current.window.width
        self.screen_height = vim.current.window.height
        self.screen_top = len(self.buffer) - vim.current.window.height + 1
        if self.screen_top < 1:
            self.screen_top = 1


        # align bottom of buffer to bottom of screen
        vim.command('normal! ' + str(self.screen_height) + 'kG')
        
        ret = buffer_line - self.screen_top
        if ret > self.screen_height:
            ret = self.screen_height

        # return new relative line number
        return ret


    def align(self):
        """ align bottom of buffer to bottom of screen """
        vim.command('normal! ' + str(self.screen_height) + 'kG')


autoload/conque_term/conque_sole.py	[[[1
461
# FILE:     autoload/conque_term/conque_sole.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
Windows Console Emulator

This is the main interface to the Windows emulator. It reads new output from the background console
and updates the Vim buffer.
"""

import vim


class ConqueSole(Conque):

    window_top = None
    window_bottom = None

    color_cache = {}
    attribute_cache = {}
    color_mode = None
    color_conceals = {}

    buffer = None
    encoding = None

    # counters for periodic rendering
    buffer_redraw_ct = 1
    screen_redraw_ct = 1

    # line offset, shifts output down
    offset = 0


    def open(self):
        """ Start command and initialize this instance

        Arguments:
        command - Command string, e.g. "Powershell.exe"
        options - Dictionary of config options
        python_exe - Path to the python.exe executable. Usually C:\PythonXX\python.exe
        communicator_py - Path to subprocess controller script in user's vimfiles directory
      
        """
        # get arguments
        command = vim.eval('command')
        options = vim.eval('options')
        python_exe = vim.eval('py_exe')
        communicator_py = vim.eval('py_vim')

        # init size
        self.columns = vim.current.window.width
        self.lines = vim.current.window.height
        self.window_top = 0
        self.window_bottom = vim.current.window.height - 1

        # color mode
        self.color_mode = vim.eval('g:ConqueTerm_ColorMode')

        # line offset
        self.offset = int(options['offset'])

        # init color
        self.enable_colors = options['color'] and not CONQUE_FAST_MODE

        # open command
        self.proc = ConqueSoleWrapper()
        self.proc.open(command, self.lines, self.columns, python_exe, communicator_py, options)

        self.buffer = vim.current.buffer
        self.screen_encoding = vim.eval('&fileencoding')


    def read(self, timeout=1, set_cursor=True, return_output=False, update_buffer=True):
        """ Read from console and update Vim buffer. """

        try:
            stats = self.proc.get_stats()

            if not stats:
                return

            # disable screen and buffer redraws in fast mode
            if not CONQUE_FAST_MODE:
                self.buffer_redraw_ct += 1
                self.screen_redraw_ct += 1

            update_top = 0
            update_bottom = 0
            lines = []

            # full buffer redraw, our favorite!
            #if self.buffer_redraw_ct == CONQUE_SOLE_BUFFER_REDRAW:
            #    self.buffer_redraw_ct = 0
            #    update_top = 0
            #    update_bottom = stats['top_offset'] + self.lines
            #    (lines, attributes) = self.proc.read(update_top, update_bottom)
            #    if return_output:
            #        output = self.get_new_output(lines, update_top, stats)
            #    if update_buffer:
            #        for i in range(update_top, update_bottom + 1):
            #            if CONQUE_FAST_MODE:
            #                self.plain_text(i, lines[i], None, stats)
            #            else:
            #                self.plain_text(i, lines[i], attributes[i], stats)

            # full screen redraw
            if stats['cursor_y'] + 1 != self.l or stats['top_offset'] != self.window_top or self.screen_redraw_ct >= CONQUE_SOLE_SCREEN_REDRAW:

                self.screen_redraw_ct = 0
                update_top = self.window_top
                update_bottom = max([stats['top_offset'] + self.lines + 1, stats['cursor_y']])
                (lines, attributes) = self.proc.read(update_top, update_bottom - update_top + 1)
                if return_output:
                    output = self.get_new_output(lines, update_top, stats)
                if update_buffer:
                    for i in range(update_top, update_bottom + 1):
                        if CONQUE_FAST_MODE:
                            self.plain_text(i, lines[i - update_top], None, stats)
                        else:
                            self.plain_text(i, lines[i - update_top], attributes[i - update_top], stats)


            # single line redraw
            else:
                update_top = stats['cursor_y']
                (lines, attributes) = self.proc.read(update_top, 1)
                if return_output:
                    output = self.get_new_output(lines, update_top, stats)
                if update_buffer:
                    if lines[0].rstrip() != u(self.buffer[update_top].rstrip()):
                        if CONQUE_FAST_MODE:
                            self.plain_text(update_top, lines[0], None, stats)
                        else:
                            self.plain_text(update_top, lines[0], attributes[0], stats)


            # reset current position
            self.window_top = stats['top_offset']
            self.l = stats['cursor_y'] + 1
            self.c = stats['cursor_x'] + 1

            # reposition cursor if this seems plausible
            if set_cursor:
                self.set_cursor(self.l, self.c)

            if return_output:
                return output

        except:

            pass


    def get_new_output(self, lines, update_top, stats):
        """ Calculate the "new" output from this read. Fake but useful """

        if not (stats['cursor_y'] + 1 > self.l or (stats['cursor_y'] + 1 == self.l and stats['cursor_x'] + 1 > self.c)):
            return ""






        try:
            num_to_return = stats['cursor_y'] - self.l + 2

            lines = lines[self.l - update_top - 1:]


            new_output = []

            # first line
            new_output.append(lines[0][self.c - 1:].rstrip())

            # the rest
            for i in range(1, num_to_return):
                new_output.append(lines[i].rstrip())

        except:

            pass



        return "\n".join(new_output)


    def plain_text(self, line_nr, text, attributes, stats):
        """ Write plain text to Vim buffer. """





        # handle line offset
        line_nr += self.offset

        self.l = line_nr + 1 

        # remove trailing whitespace
        text = text.rstrip()

        # if we're using concealed text for color, then s- is weird
        if self.color_mode == 'conceal':

            text = self.add_conceal_color(text, attributes, stats, line_nr)


        # deal with character encoding
        if CONQUE_PYTHON_VERSION == 2:
            val = text.encode(self.screen_encoding)
        else:
            # XXX / Vim's python3 interface doesn't accept bytes object
            val = str(text)

        # update vim buffer
        if len(self.buffer) <= line_nr:
            self.buffer.append(val)
        else:
            self.buffer[line_nr] = val

        if self.enable_colors and not self.color_mode == 'conceal' and line_nr > self.l - CONQUE_MAX_SYNTAX_LINES:
            relevant = attributes[0:len(text)]
            if line_nr not in self.attribute_cache or self.attribute_cache[line_nr] != relevant:
                self.do_color(attributes=relevant, stats=stats)
                self.attribute_cache[line_nr] = relevant


    def add_conceal_color(self, text, attributes, stats, line_nr):
        """ Add 'conceal' color strings to output text """

        # stop here if coloration is disabled
        if not self.enable_colors:
            return text

        # if no colors for this line, clear everything out
        if len(attributes) == 0 or attributes == u(chr(stats['default_attribute'])) * len(attributes):
            return text

        new_text = ''
        self.color_conceals[line_nr] = []

        attribute_chunks = CONQUE_WIN32_REGEX_ATTR.findall(attributes)
        offset = 0
        ends = []
        for attr in attribute_chunks:
            attr_num = ord(attr[1])
            ends = []
            if attr_num != stats['default_attribute']:

                color = self.translate_color(attr_num)

                new_text += chr(27) + 'sf' + color['fg_code'] + ';'
                ends.append(chr(27) + 'ef' + color['fg_code'] + ';')
                self.color_conceals[line_nr].append(offset)

                if attr_num > 15:
                    new_text += chr(27) + 'sb' + color['bg_code'] + ';'
                    ends.append(chr(27) + 'eb' + color['bg_code'] + ';')
                    self.color_conceals[line_nr].append(offset)

            new_text += text[offset:offset + len(attr[0])]

            # close color regions
            ends.reverse()
            for i in range(0, len(ends)):
                self.color_conceals[line_nr].append(len(new_text))
                new_text += ends[i]

            offset += len(attr[0])

        return new_text


    def do_color(self, start=0, end=0, attributes='', stats=None):
        """ Convert Windows console attributes into Vim syntax highlighting """

        # if no colors for this line, clear everything out
        if len(attributes) == 0 or attributes == u(chr(stats['default_attribute'])) * len(attributes):
            self.color_changes = {}
            self.apply_color(1, len(attributes), self.l)
            return

        attribute_chunks = CONQUE_WIN32_REGEX_ATTR.findall(attributes)
        offset = 0
        for attr in attribute_chunks:
            attr_num = ord(attr[1])
            if attr_num != stats['default_attribute']:
                self.color_changes = self.translate_color(attr_num)
                self.apply_color(offset + 1, offset + len(attr[0]) + 1, self.l)
            offset += len(attr[0])


    def translate_color(self, attr):
        """ Convert Windows console attributes into RGB colors """

        # check for cached color
        if attr in self.color_cache:
            return self.color_cache[attr]






        # convert attribute integer to bit string
        bit_str = bin(attr)
        bit_str = bit_str.replace('0b', '')

        # slice foreground and background portions of bit string
        fg = bit_str[-4:].rjust(4, '0')
        bg = bit_str[-8:-4].rjust(4, '0')

        # ok, first create foreground #rbg
        red = int(fg[1]) * 204 + int(fg[0]) * int(fg[1]) * 51
        green = int(fg[2]) * 204 + int(fg[0]) * int(fg[2]) * 51
        blue = int(fg[3]) * 204 + int(fg[0]) * int(fg[3]) * 51
        fg_str = "#%02x%02x%02x" % (red, green, blue)
        fg_code = "%02x%02x%02x" % (red, green, blue)
        fg_code = fg_code[0] + fg_code[2] + fg_code[4]

        # ok, first create foreground #rbg
        red = int(bg[1]) * 204 + int(bg[0]) * int(bg[1]) * 51
        green = int(bg[2]) * 204 + int(bg[0]) * int(bg[2]) * 51
        blue = int(bg[3]) * 204 + int(bg[0]) * int(bg[3]) * 51
        bg_str = "#%02x%02x%02x" % (red, green, blue)
        bg_code = "%02x%02x%02x" % (red, green, blue)
        bg_code = bg_code[0] + bg_code[2] + bg_code[4]

        # build value for color_changes

        color = {'guifg': fg_str, 'guibg': bg_str}

        if self.color_mode == 'conceal':
            color['fg_code'] = fg_code
            color['bg_code'] = bg_code

        self.color_cache[attr] = color

        return color


    def write_vk(self, vk_code):
        """ write virtual key code to shared memory using proprietary escape seq """

        self.proc.write_vk(vk_code)

    def update_window(self, force=False):
        # This magically works
        vim.command("normal! i")


    def update_window_size(self, tell_subprocess = True):
        """ Resize underlying console if Vim buffer size has changed """

        if vim.current.window.width != self.columns or vim.current.window.height != self.lines:

            # reset all window size attributes to default
            self.columns = vim.current.window.width
            self.lines = vim.current.window.height
            self.working_columns = vim.current.window.width
            self.working_lines = vim.current.window.height
            self.bottom = vim.current.window.height
            
            if tell_subprocess:
                self.proc.window_resize(vim.current.window.height, vim.current.window.width)


    def set_cursor(self, line, column):
        """ Update cursor position in Vim buffer """



        # handle offset
        line += self.offset

        # shift cursor position to handle concealed text
        if self.enable_colors and self.color_mode == 'conceal':
            if line - 1 in self.color_conceals:
                for c in self.color_conceals[line - 1]:
                    if c < column:
                        column += 7
                    else:
                        break



        # figure out line
        buffer_line = line
        if buffer_line > len(self.buffer):
            for l in range(len(self.buffer) - 1, buffer_line):
                self.buffer.append('')

        # figure out column
        real_column = column
        if len(self.buffer[buffer_line - 1]) < real_column:
            self.buffer[buffer_line - 1] = self.buffer[buffer_line - 1] + ' ' * (real_column - len(self.buffer[buffer_line - 1]))

        # python version is occasionally grumpy
        try:
            vim.current.window.cursor = (buffer_line, real_column - 1)
        except:
            vim.command('call cursor(' + str(buffer_line) + ', ' + str(real_column) + ')')


    def idle(self):
        """ go into idle mode """

        self.proc.idle()


    def resume(self):
        """ resume from idle mode """

        self.proc.resume()


    def close(self):
        """ end console subprocess """
        self.proc.close()


    def abort(self):
        """ end subprocess forcefully """
        self.proc.close()


    def get_buffer_line(self, line):
        """ get buffer line """
        return line


# vim:foldmethod=marker
autoload/conque_term/conque_sole_communicator.py	[[[1
183
# FILE:     autoload/conque_term/conque_sole_communicator.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""

ConqueSoleCommunicator

This script will create a new Windows console and start the requested program 
inside of it. This process is launched independently from the parent Vim
program, so it has no access to the vim module.

The main loop in this script reads data from the console and syncs it onto 
blocks of memory shared with the Vim process. In this way the Vim process
and this script can communicate with each other.

"""

import time
import sys

from conque_globals import *
from conque_win32_util import *
from conque_sole_subprocess import *
from conque_sole_shared_memory import *

##############################################################
# only run if this file was run directly

if __name__ == '__main__':

    # attempt to catch ALL exceptions to fend of zombies
    try:

        # simple arg validation

        if len(sys.argv) < 5:

            exit()

        # maximum time this thing reads. 0 means no limit. Only for testing.
        max_loops = 0

        # read interval, in seconds
        sleep_time = 0.01

        # idle read interval, in seconds
        idle_sleep_time = 0.10

        # are we idled?
        is_idle = False

        # mem key
        mem_key = sys.argv[1]

        # console width
        console_width = int(sys.argv[2])

        # console height
        console_height = int(sys.argv[3])

        # code page
        code_page = int(sys.argv[4])

        # code page
        fast_mode = int(sys.argv[5])

        # the actual subprocess to run
        cmd_line = " ".join(sys.argv[6:])


        # width and height
        options = {'LINES': console_height, 'COLUMNS': console_width, 'CODE_PAGE': code_page, 'FAST_MODE': fast_mode}



        # set initial idle status
        shm_command = ConqueSoleSharedMemory(CONQUE_SOLE_COMMANDS_SIZE, 'command', mem_key, serialize=True)
        shm_command.create('write')

        cmd = shm_command.read()
        if cmd:

            if cmd['cmd'] == 'idle':
                is_idle = True
                shm_command.clear()


        ##############################################################
        # Create the subprocess

        proc = ConqueSoleSubprocess()
        res = proc.open(cmd_line, mem_key, options)

        if not res:

            exit()

        ##############################################################
        # main loop!

        loops = 0

        while True:

            # check for idle/resume
            if is_idle or loops % 25 == 0:

                # check process health
                if not proc.is_alive():

                    proc.close()
                    break

                # check for change in buffer focus
                cmd = shm_command.read()
                if cmd:

                    if cmd['cmd'] == 'idle':
                        is_idle = True
                        shm_command.clear()

                    elif cmd['cmd'] == 'resume':
                        is_idle = False
                        shm_command.clear()


            # sleep between loops if moderation is requested
            if sleep_time > 0:
                if is_idle:
                    time.sleep(idle_sleep_time)
                else:
                    time.sleep(sleep_time)

            # write, read, etc
            proc.write()
            proc.read()

            # increment loops, and exit if max has been reached
            loops += 1
            if max_loops and loops >= max_loops:

                break

        ##############################################################
        # all done!



        proc.close()

    # if an exception was thrown, croak
    except:

        proc.close()


# vim:foldmethod=marker
autoload/conque_term/conque_sole_shared_memory.py	[[[1
210
# FILE:     autoload/conque_term/conque_sole_shared_memory.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
Wrapper class for shared memory between Windows python processes

Adds a small amount of functionality to the standard mmap module.

"""

import mmap
import sys

# PYTHON VERSION
CONQUE_PYTHON_VERSION = sys.version_info[0]

if CONQUE_PYTHON_VERSION == 2:
    import cPickle as pickle
else:
    import pickle


class ConqueSoleSharedMemory():

    # is the data being stored not fixed length
    fixed_length = False

    # maximum number of bytes per character, for fixed width blocks
    char_width = 1

    # fill memory with this character when clearing and fixed_length is true
    FILL_CHAR = None

    # serialize and unserialize data automatically
    serialize = False

    # size of shared memory, in bytes / chars
    mem_size = None

    # size of shared memory, in bytes / chars
    mem_type = None

    # unique key, so multiple console instances are possible
    mem_key = None

    # mmap instance
    shm = None

    # character encoding, dammit
    encoding = 'utf-8'

    # pickle terminator
    TERMINATOR = None


    def __init__(self, mem_size, mem_type, mem_key, fixed_length=False, fill_char=' ', serialize=False, encoding='utf-8'):
        """ Initialize new shared memory block instance

        Arguments:
        mem_size -- Memory size in characters, depends on encoding argument to calcuate byte size
        mem_type -- Label to identify what will be stored
        mem_key -- Unique, probably random key to identify this block
        fixed_length -- If set to true, assume the data stored will always fill the memory size
        fill_char -- Initialize memory block with this character, only really helpful with fixed_length blocks
        serialize -- Automatically serialize data passed to write. Allows storing non-byte data
        encoding -- Character encoding to use when storing character data

        """
        self.mem_size = mem_size
        self.mem_type = mem_type
        self.mem_key = mem_key
        self.fixed_length = fixed_length
        self.fill_char = fill_char
        self.serialize = serialize
        self.encoding = encoding
        self.TERMINATOR = str(chr(0)).encode(self.encoding)

        if CONQUE_PYTHON_VERSION == 3:
            self.FILL_CHAR = fill_char
        else:
            self.FILL_CHAR = unicode(fill_char)

        if fixed_length and encoding == 'utf-8':
            self.char_width = 4


    def create(self, access='write'):
        """ Create a new block of shared memory using the mmap module. """

        if access == 'write':
            mmap_access = mmap.ACCESS_WRITE
        else:
            mmap_access = mmap.ACCESS_READ

        name = "conque_%s_%s" % (self.mem_type, self.mem_key)

        self.shm = mmap.mmap(0, self.mem_size * self.char_width, name, mmap_access)

        if not self.shm:
            return False
        else:
            return True


    def read(self, chars=1, start=0):
        """ Read data from shared memory.

        If this is a fixed length block, read 'chars' characters from memory. 
        Otherwise read up until the TERMINATOR character (null byte).
        If this memory is serialized, unserialize it automatically.

        """
        # go to start position
        self.shm.seek(start * self.char_width)

        if self.fixed_length:
            chars = chars * self.char_width
        else:
            chars = self.shm.find(self.TERMINATOR)

        if chars == 0:
            return ''

        shm_str = self.shm.read(chars)

        # return unpickled byte object
        if self.serialize:
            return pickle.loads(shm_str)

        # decode byes in python 3
        if CONQUE_PYTHON_VERSION == 3:
            return str(shm_str, self.encoding)

        # encoding
        if self.encoding != 'ascii':
            shm_str = unicode(shm_str, self.encoding)

        return shm_str


    def write(self, text, start=0):
        """ Write data to memory.

        If memory is fixed length, simply write the 'text' characters at 'start' position.
        Otherwise write 'text' characters and append a null character.
        If memory is serializable, do so first.

        """
        # simple scenario, let pickle create bytes
        if self.serialize:
            if CONQUE_PYTHON_VERSION == 3:
                tb = pickle.dumps(text, 0)
            else:
                tb = pickle.dumps(text, 0).encode(self.encoding)

        else:
            tb = text.encode(self.encoding, 'replace')

        # write to memory
        self.shm.seek(start * self.char_width)

        if self.fixed_length:
            self.shm.write(tb)
        else:
            self.shm.write(tb + self.TERMINATOR)


    def clear(self, start=0):
        """ Clear memory block using self.fill_char. """

        self.shm.seek(start)

        if self.fixed_length:
            self.shm.write(str(self.fill_char * self.mem_size * self.char_width).encode(self.encoding))
        else:
            self.shm.write(self.TERMINATOR)


    def close(self):
        """ Close/destroy memory block. """

        self.shm.close()


autoload/conque_term/conque_sole_subprocess.py	[[[1
762
# FILE:     autoload/conque_term/conque_sole_subprocess.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

""" ConqueSoleSubprocess

Creates a new subprocess with it's own (hidden) console window.

Mirrors console window text onto a block of shared memory (mmap), along with
text attribute data. Also handles translation of text input into the format
Windows console expects.

Sample Usage:

    sh = ConqueSoleSubprocess()
    sh.open("cmd.exe", "unique_str")

    shm_in = ConqueSoleSharedMemory(mem_key = "unique_str", mem_type = "input", ...)
    shm_out = ConqueSoleSharedMemory(mem_key = "unique_str", mem_type = "output", ...)

    output = shm_out.read(...)
    shm_in.write("dir\r")
    output = shm_out.read(...)

"""

import time
import re
import os
import ctypes

from conque_globals import *
from conque_win32_util import *
from conque_sole_shared_memory import *


class ConqueSoleSubprocess():

    # subprocess handle and pid
    handle = None
    pid = None

    # input / output handles
    stdin = None
    stdout = None

    # size of console window
    window_width = 160
    window_height = 40

    # max lines for the console buffer
    buffer_width = 160
    buffer_height = 100

    # keep track of the buffer number at the top of the window
    top = 0
    line_offset = 0

    # buffer height is CONQUE_SOLE_BUFFER_LENGTH * output_blocks
    output_blocks = 1

    # cursor position
    cursor_line = 0
    cursor_col = 0

    # console data, array of lines
    data = []

    # console attribute data, array of array of int
    attributes = []
    attribute_cache = {}

    # default attribute
    default_attribute = 7

    # shared memory objects
    shm_input = None
    shm_output = None
    shm_attributes = None
    shm_stats = None
    shm_command = None
    shm_rescroll = None
    shm_resize = None

    # are we still a valid process?
    is_alive = True

    # running in fast mode
    fast_mode = 0

    # used for periodic execution of screen and memory redrawing
    screen_redraw_ct = 0
    mem_redraw_ct = 0


    def open(self, cmd, mem_key, options={}):
        """ Create subproccess running in hidden console window. """



        self.reset = True

        try:
            # if we're already attached to a console, then unattach
            try:
                ctypes.windll.kernel32.FreeConsole()
            except:
                pass

            # set buffer height
            self.buffer_height = CONQUE_SOLE_BUFFER_LENGTH

            if 'LINES' in options and 'COLUMNS' in options:
                self.window_width = options['COLUMNS']
                self.window_height = options['LINES']
                self.buffer_width = options['COLUMNS']

            # fast mode
            self.fast_mode = options['FAST_MODE']

            # console window options
            si = STARTUPINFO()

            # hide window
            si.dwFlags |= STARTF_USESHOWWINDOW
            si.wShowWindow = SW_HIDE
            #si.wShowWindow = SW_MINIMIZE

            # process options
            flags = NORMAL_PRIORITY_CLASS | CREATE_NEW_PROCESS_GROUP | CREATE_UNICODE_ENVIRONMENT | CREATE_NEW_CONSOLE

            # created process info
            pi = PROCESS_INFORMATION()



            # create the process!
            res = ctypes.windll.kernel32.CreateProcessW(None, u(cmd), None, None, 0, flags, None, u('.'), ctypes.byref(si), ctypes.byref(pi))





            # process info
            self.pid = pi.dwProcessId
            self.handle = pi.hProcess




            # attach ourselves to the new console
            # console is not immediately available
            for i in range(10):
                time.sleep(0.25)
                try:

                    res = ctypes.windll.kernel32.AttachConsole(self.pid)






                    break
                except:

                    pass

            # get input / output handles
            self.stdout = ctypes.windll.kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
            self.stdin = ctypes.windll.kernel32.GetStdHandle(STD_INPUT_HANDLE)

            # set buffer size
            size = COORD(self.buffer_width, self.buffer_height)
            res = ctypes.windll.kernel32.SetConsoleScreenBufferSize(self.stdout, size)







            # prev set size call needs to process
            time.sleep(0.2)

            # set window size
            self.set_window_size(self.window_width, self.window_height)

            # set utf-8 code page
            if 'CODE_PAGE' in options and options['CODE_PAGE'] > 0:
                if ctypes.windll.kernel32.IsValidCodePage(ctypes.c_uint(options['CODE_PAGE'])):

                    ctypes.windll.kernel32.SetConsoleCP(ctypes.c_uint(options['CODE_PAGE']))
                    ctypes.windll.kernel32.SetConsoleOutputCP(ctypes.c_uint(options['CODE_PAGE']))

            # init shared memory
            self.init_shared_memory(mem_key)

            # init read buffers
            self.tc = ctypes.create_unicode_buffer(self.buffer_width)
            self.ac = ctypes.create_unicode_buffer(self.buffer_width)

            return True

        except:

            return False


    def init_shared_memory(self, mem_key):
        """ Create shared memory objects. """

        self.shm_input = ConqueSoleSharedMemory(CONQUE_SOLE_INPUT_SIZE, 'input', mem_key)
        self.shm_input.create('write')
        self.shm_input.clear()

        self.shm_output = ConqueSoleSharedMemory(self.buffer_height * self.buffer_width, 'output', mem_key, True)
        self.shm_output.create('write')
        self.shm_output.clear()

        if not self.fast_mode:
            buf_info = self.get_buffer_info()
            self.shm_attributes = ConqueSoleSharedMemory(self.buffer_height * self.buffer_width, 'attributes', mem_key, True, chr(buf_info.wAttributes), encoding='latin-1')
            self.shm_attributes.create('write')
            self.shm_attributes.clear()

        self.shm_stats = ConqueSoleSharedMemory(CONQUE_SOLE_STATS_SIZE, 'stats', mem_key, serialize=True)
        self.shm_stats.create('write')
        self.shm_stats.clear()

        self.shm_command = ConqueSoleSharedMemory(CONQUE_SOLE_COMMANDS_SIZE, 'command', mem_key, serialize=True)
        self.shm_command.create('write')
        self.shm_command.clear()

        self.shm_resize = ConqueSoleSharedMemory(CONQUE_SOLE_RESIZE_SIZE, 'resize', mem_key, serialize=True)
        self.shm_resize.create('write')
        self.shm_resize.clear()

        self.shm_rescroll = ConqueSoleSharedMemory(CONQUE_SOLE_RESCROLL_SIZE, 'rescroll', mem_key, serialize=True)
        self.shm_rescroll.create('write')
        self.shm_rescroll.clear()

        return True


    def check_commands(self):
        """ Check for and process commands from Vim. """

        cmd = self.shm_command.read()

        if cmd:

            # shut it all down
            if cmd['cmd'] == 'close':

                # clear command
                self.shm_command.clear()

                self.close()
                return

        cmd = self.shm_resize.read()

        if cmd:

            # clear command
            self.shm_resize.clear()

            # resize console
            if cmd['cmd'] == 'resize':



                # only change buffer width if it's larger
                if cmd['data']['width'] > self.buffer_width:
                    self.buffer_width = cmd['data']['width']

                # always change console width and height
                self.window_width = cmd['data']['width']
                self.window_height = cmd['data']['height']

                # reset the console
                buf_info = self.get_buffer_info()
                self.reset_console(buf_info, add_block=False)


    def read(self):
        """ Read from windows console and update shared memory blocks. """

        # no point really
        if self.screen_redraw_ct == 0 and not self.is_alive():
            stats = {'top_offset': 0, 'default_attribute': 0, 'cursor_x': 0, 'cursor_y': self.cursor_line, 'is_alive': 0}

            self.shm_stats.write(stats)
            return

        # check for commands
        self.check_commands()

        # get cursor position
        buf_info = self.get_buffer_info()
        curs_line = buf_info.dwCursorPosition.Y
        curs_col = buf_info.dwCursorPosition.X

        # set update range
        if curs_line != self.cursor_line or self.top != buf_info.srWindow.Top or self.screen_redraw_ct == CONQUE_SOLE_SCREEN_REDRAW:
            self.screen_redraw_ct = 0

            read_start = self.top
            read_end = max([buf_info.srWindow.Bottom + 1, curs_line + 1])
        else:

            read_start = curs_line
            read_end = curs_line + 1




        # vars used in for loop
        coord = COORD(0, 0)
        chars_read = ctypes.c_int(0)

        # read new data
        for i in range(read_start, read_end):

            coord.Y = i

            res = ctypes.windll.kernel32.ReadConsoleOutputCharacterW(self.stdout, ctypes.byref(self.tc), self.buffer_width, coord, ctypes.byref(chars_read))
            if not self.fast_mode:
                ctypes.windll.kernel32.ReadConsoleOutputAttribute(self.stdout, ctypes.byref(self.ac), self.buffer_width, coord, ctypes.byref(chars_read))

            t = self.tc.value
            if not self.fast_mode:
                a = self.ac.value

            # add data
            if i >= len(self.data):
                for j in range(len(self.data), i + 1):
                    self.data.append('')
                    if not self.fast_mode:
                        self.attributes.append('')

            self.data[i] = t
            if not self.fast_mode:
                self.attributes[i] = a




            #for i in range(0, len(t)):




        # write new output to shared memory
        try:
            if self.mem_redraw_ct == CONQUE_SOLE_MEM_REDRAW:
                self.mem_redraw_ct = 0

                for i in range(0, len(self.data)):
                    self.shm_output.write(text=self.data[i], start=self.buffer_width * i)
                    if not self.fast_mode:
                        self.shm_attributes.write(text=self.attributes[i], start=self.buffer_width * i)
            else:

                for i in range(read_start, read_end):
                    self.shm_output.write(text=self.data[i], start=self.buffer_width * i)
                    if not self.fast_mode:
                        self.shm_attributes.write(text=self.attributes[i], start=self.buffer_width * i)
                    #self.shm_output.write(text=''.join(self.data[read_start:read_end]), start=read_start * self.buffer_width)
                    #self.shm_attributes.write(text=''.join(self.attributes[read_start:read_end]), start=read_start * self.buffer_width)

            # write cursor position to shared memory
            stats = {'top_offset': buf_info.srWindow.Top, 'default_attribute': buf_info.wAttributes, 'cursor_x': curs_col, 'cursor_y': curs_line, 'is_alive': 1}
            self.shm_stats.write(stats)

            # adjust screen position
            self.top = buf_info.srWindow.Top
            self.cursor_line = curs_line

            # check for reset
            if curs_line > buf_info.dwSize.Y - 200:
                self.reset_console(buf_info)

        except:




            pass

        # increment redraw counters
        self.screen_redraw_ct += 1
        self.mem_redraw_ct += 1

        return None


    def reset_console(self, buf_info, add_block=True):
        """ Extend the height of the current console if the cursor postion gets within 200 lines of the current size. """

        # sometimes we just want to change the buffer width,
        # in which case no need to add another block
        if add_block:
            self.output_blocks += 1

        # close down old memory
        self.shm_output.close()
        self.shm_output = None

        if not self.fast_mode:
            self.shm_attributes.close()
            self.shm_attributes = None

        # new shared memory key
        mem_key = 'mk' + str(time.time())

        # reallocate memory
        self.shm_output = ConqueSoleSharedMemory(self.buffer_height * self.buffer_width * self.output_blocks, 'output', mem_key, True)
        self.shm_output.create('write')
        self.shm_output.clear()

        # backfill data
        if len(self.data[0]) < self.buffer_width:
            for i in range(0, len(self.data)):
                self.data[i] = self.data[i] + ' ' * (self.buffer_width - len(self.data[i]))
        self.shm_output.write(''.join(self.data))

        if not self.fast_mode:
            self.shm_attributes = ConqueSoleSharedMemory(self.buffer_height * self.buffer_width * self.output_blocks, 'attributes', mem_key, True, chr(buf_info.wAttributes), encoding='latin-1')
            self.shm_attributes.create('write')
            self.shm_attributes.clear()

        # backfill attributes
        if len(self.attributes[0]) < self.buffer_width:
            for i in range(0, len(self.attributes)):
                self.attributes[i] = self.attributes[i] + chr(buf_info.wAttributes) * (self.buffer_width - len(self.attributes[i]))
        if not self.fast_mode:
            self.shm_attributes.write(''.join(self.attributes))

        # notify wrapper of new output block
        self.shm_rescroll.write({'cmd': 'new_output', 'data': {'blocks': self.output_blocks, 'mem_key': mem_key}})

        # set buffer size
        size = COORD(X=self.buffer_width, Y=self.buffer_height * self.output_blocks)

        res = ctypes.windll.kernel32.SetConsoleScreenBufferSize(self.stdout, size)






        # prev set size call needs to process
        time.sleep(0.2)

        # set window size
        self.set_window_size(self.window_width, self.window_height)

        # init read buffers
        self.tc = ctypes.create_unicode_buffer(self.buffer_width)
        self.ac = ctypes.create_unicode_buffer(self.buffer_width)



    def write(self):
        """ Write text to console. 

        This function just parses out special sequences for special key events 
        and passes on the text to the plain or virtual key functions.

        """
        # get input from shared mem
        text = self.shm_input.read()

        # nothing to do here
        if text == u(''):
            return



        # clear input queue
        self.shm_input.clear()

        # split on VK codes
        chunks = CONQUE_WIN32_REGEX_VK.split(text)

        # if len() is one then no vks
        if len(chunks) == 1:
            self.write_plain(text)
            return



        # loop over chunks and delegate
        for t in chunks:

            if t == '':
                continue

            if CONQUE_WIN32_REGEX_VK.match(t):

                self.write_vk(t[2:-2])
            else:
                self.write_plain(t)


    def write_plain(self, text):
        """ Write simple text to subprocess. """

        li = INPUT_RECORD * len(text)
        list_input = li()

        for i in range(0, len(text)):

            # create keyboard input
            ke = KEY_EVENT_RECORD()
            ke.bKeyDown = ctypes.c_byte(1)
            ke.wRepeatCount = ctypes.c_short(1)

            cnum = ord(text[i])

            ke.wVirtualKeyCode = ctypes.windll.user32.VkKeyScanW(cnum)
            ke.wVirtualScanCode = ctypes.c_short(ctypes.windll.user32.MapVirtualKeyW(int(cnum), 0))

            if cnum > 31:
                ke.uChar.UnicodeChar = uchr(cnum)
            elif cnum == 3:
                ctypes.windll.kernel32.GenerateConsoleCtrlEvent(0, self.pid)
                ke.uChar.UnicodeChar = uchr(cnum)
                ke.wVirtualKeyCode = ctypes.windll.user32.VkKeyScanW(cnum + 96)
                ke.dwControlKeyState |= LEFT_CTRL_PRESSED
            else:
                ke.uChar.UnicodeChar = uchr(cnum)
                if cnum in CONQUE_WINDOWS_VK_INV:
                    ke.wVirtualKeyCode = cnum
                else:
                    ke.wVirtualKeyCode = ctypes.windll.user32.VkKeyScanW(cnum + 96)
                    ke.dwControlKeyState |= LEFT_CTRL_PRESSED




            kc = INPUT_RECORD(KEY_EVENT)
            kc.Event.KeyEvent = ke
            list_input[i] = kc



        # write input array
        events_written = ctypes.c_int()
        res = ctypes.windll.kernel32.WriteConsoleInputW(self.stdin, list_input, len(text), ctypes.byref(events_written))








    def write_vk(self, vk_code):
        """ Write special characters to console subprocess. """



        code = None
        ctrl_pressed = False

        # this could be made more generic when more attributes
        # other than ctrl_pressed are available
        vk_attributes = vk_code.split(';')

        for attr in vk_attributes:
            if attr == CONQUE_VK_ATTR_CTRL_PRESSED:
                ctrl_pressed = True
            else:
                code = attr

        li = INPUT_RECORD * 1

        # create keyboard input
        ke = KEY_EVENT_RECORD()
        ke.uChar.UnicodeChar = uchr(0)
        ke.wVirtualKeyCode = ctypes.c_short(int(code))
        ke.wVirtualScanCode = ctypes.c_short(ctypes.windll.user32.MapVirtualKeyW(int(code), 0))
        ke.bKeyDown = ctypes.c_byte(1)
        ke.wRepeatCount = ctypes.c_short(1)

        # set enhanced key mode for arrow keys
        if code in CONQUE_WINDOWS_VK_ENHANCED:

            ke.dwControlKeyState |= ENHANCED_KEY

        if ctrl_pressed:
            ke.dwControlKeyState |= LEFT_CTRL_PRESSED

        kc = INPUT_RECORD(KEY_EVENT)
        kc.Event.KeyEvent = ke
        list_input = li(kc)

        # write input array
        events_written = ctypes.c_int()
        res = ctypes.windll.kernel32.WriteConsoleInputW(self.stdin, list_input, 1, ctypes.byref(events_written))







    def close(self):
        """ Close all running subproccesses """

        # record status
        self.is_alive = False
        try:
            stats = {'top_offset': 0, 'default_attribute': 0, 'cursor_x': 0, 'cursor_y': self.cursor_line, 'is_alive': 0}
            self.shm_stats.write(stats)
        except:
            pass

        pid_list = (ctypes.c_int * 10)()
        num = ctypes.windll.kernel32.GetConsoleProcessList(pid_list, 10)



        current_pid = os.getpid()





        # kill subprocess pids
        for pid in pid_list[0:num]:
            if not pid:
                break

            # kill current pid last
            if pid == current_pid:
                continue
            try:
                self.close_pid(pid)
            except:

                pass

        # kill this process
        try:
            self.close_pid(current_pid)
        except:

            pass


    def close_pid(self, pid):
        """ Terminate a single process. """


        handle = ctypes.windll.kernel32.OpenProcess(PROCESS_TERMINATE, 0, pid)
        ctypes.windll.kernel32.TerminateProcess(handle, -1)
        ctypes.windll.kernel32.CloseHandle(handle)


    def is_alive(self):
        """ Check process health. """

        status = ctypes.windll.kernel32.WaitForSingleObject(self.handle, 1)

        if status == 0:

            self.is_alive = False

        return self.is_alive


    def get_screen_text(self):
        """ Return screen data as string. """

        return "\n".join(self.data)


    def set_window_size(self, width, height):
        """ Change Windows console size. """



        # get current window size object
        window_size = SMALL_RECT(0, 0, 0, 0)

        # buffer info has maximum window size data
        buf_info = self.get_buffer_info()


        # set top left corner
        window_size.Top = 0
        window_size.Left = 0

        # set bottom right corner
        if buf_info.dwMaximumWindowSize.X < width:

            window_size.Right = buf_info.dwMaximumWindowSize.X - 1
        else:
            window_size.Right = width - 1

        if buf_info.dwMaximumWindowSize.Y < height:

            window_size.Bottom = buf_info.dwMaximumWindowSize.Y - 1
        else:
            window_size.Bottom = height - 1



        # set the window size!
        res = ctypes.windll.kernel32.SetConsoleWindowInfo(self.stdout, ctypes.c_bool(True), ctypes.byref(window_size))






        # reread buffer info to get final console max lines
        buf_info = self.get_buffer_info()

        self.window_width = buf_info.srWindow.Right + 1
        self.window_height = buf_info.srWindow.Bottom + 1


    def get_buffer_info(self):
        """ Retrieve commonly-used buffer information. """

        buf_info = CONSOLE_SCREEN_BUFFER_INFO()
        ctypes.windll.kernel32.GetConsoleScreenBufferInfo(self.stdout, ctypes.byref(buf_info))

        return buf_info



autoload/conque_term/conque_sole_wrapper.py	[[[1
278
# FILE:     autoload/conque_term/conque_sole_wrapper.py 
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

""" 

ConqueSoleSubprocessWrapper

Subprocess wrapper to deal with Windows insanity. Launches console based python,
which in turn launches originally requested command. Communicates with cosole
python through shared memory objects.

"""

import ctypes
import time


class ConqueSoleWrapper():

    # unique key used for shared memory block names
    shm_key = ''

    # process info
    handle = None
    pid = None

    # queue input in this bucket
    bucket = None

    # console size
    lines = 24
    columns = 80

    # shared memory objects
    shm_input = None
    shm_output = None
    shm_attributes = None
    shm_stats = None
    shm_command = None
    shm_rescroll = None
    shm_resize = None

    # console python process
    proc = None


    def open(self, cmd, lines, columns, python_exe='python.exe', communicator_py='conque_sole_communicator.py', options={}):
        """ Launch python.exe subprocess which will in turn launch the user's program.

        Arguments:
        cmd -- The user's command to run. E.g. "Powershell.exe" or "C:\Python27\Scripts\ipython.bat"
        lines, columns -- The size of the console, also the size of the Vim buffer
        python.exe -- The path to the python executable, typically C:\PythonXX\python.exe
        communicator_py -- The path to the subprocess controller script in the user's vimfiles directory
        options -- optional configuration

        """
        self.lines = lines
        self.columns = columns
        self.bucket = u('')

        # create a shm key
        self.shm_key = 'mk' + str(time.time())

        # python command
        cmd_line = '%s "%s" %s %d %d %d %d %s' % (python_exe, communicator_py, self.shm_key, int(self.columns), int(self.lines), int(options['CODE_PAGE']), int(CONQUE_FAST_MODE), cmd)


        # console window attributes
        flags = NORMAL_PRIORITY_CLASS | DETACHED_PROCESS | CREATE_UNICODE_ENVIRONMENT
        si = STARTUPINFO()
        pi = PROCESS_INFORMATION()

        # start the stupid process already
        try:
            res = ctypes.windll.kernel32.CreateProcessW(None, u(cmd_line), None, None, 0, flags, None, u('.'), ctypes.byref(si), ctypes.byref(pi))
        except:

            raise

        # handle
        self.pid = pi.dwProcessId



        # init shared memory objects
        self.init_shared_memory(self.shm_key)


    def read(self, start_line, num_lines, timeout=0):
        """ Read a range of console lines from shared memory. 

        Returns a pair of lists containing the console text and console text attributes.

        """
        # emulate timeout by sleeping timeout time
        if timeout > 0:
            read_timeout = float(timeout) / 1000

            time.sleep(read_timeout)

        output = []
        attributes = []

        # get output
        for i in range(start_line, start_line + num_lines + 1):
            output.append(self.shm_output.read(self.columns, i * self.columns))
            if not CONQUE_FAST_MODE:
                attributes.append(self.shm_attributes.read(self.columns, i * self.columns))

        return (output, attributes)


    def get_stats(self):
        """ Return a dictionary with current console cursor and scrolling information. """

        try:
            rescroll = self.shm_rescroll.read()
            if rescroll != '' and rescroll != None:



                self.shm_rescroll.clear()

                # close down old memory
                self.shm_output.close()
                self.shm_output = None

                if not CONQUE_FAST_MODE:
                    self.shm_attributes.close()
                    self.shm_attributes = None

                # reallocate memory

                self.shm_output = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns * rescroll['data']['blocks'], 'output', rescroll['data']['mem_key'], True)
                self.shm_output.create('read')

                if not CONQUE_FAST_MODE:
                    self.shm_attributes = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns * rescroll['data']['blocks'], 'attributes', rescroll['data']['mem_key'], True, encoding='latin-1')
                    self.shm_attributes.create('read')

            stats_str = self.shm_stats.read()
            if stats_str != '':
                self.stats = stats_str
            else:
                return False
        except:

            return False

        return self.stats


    def is_alive(self):
        """ Get process status. """

        if not self.shm_stats:
            return True

        stats_str = self.shm_stats.read()
        if stats_str:
            return (stats_str['is_alive'])
        else:
            return True


    def write(self, text):
        """ Write input to shared memory. """

        self.bucket += text

        istr = self.shm_input.read()

        if istr == '':

            self.shm_input.write(self.bucket[:500])
            self.bucket = self.bucket[500:]


    def write_vk(self, vk_code):
        """ Write virtual key code to shared memory using proprietary escape sequences. """

        seq = u("\x1b[") + u(str(vk_code)) + u("VK")
        self.write(seq)


    def idle(self):
        """ Write idle command to shared memory block, so subprocess controller can hibernate. """


        self.shm_command.write({'cmd': 'idle', 'data': {}})


    def resume(self):
        """ Write resume command to shared memory block, so subprocess controller can wake up. """

        self.shm_command.write({'cmd': 'resume', 'data': {}})


    def close(self):
        """ Shut it all down. """

        self.shm_command.write({'cmd': 'close', 'data': {}})
        time.sleep(0.2)


    def window_resize(self, lines, columns):
        """ Resize console window. """

        self.lines = lines

        # we don't shrink buffer width
        if columns > self.columns:
            self.columns = columns

        self.shm_resize.write({'cmd': 'resize', 'data': {'width': columns, 'height': lines}})


    def init_shared_memory(self, mem_key):
        """ Create shared memory objects. """

        self.shm_input = ConqueSoleSharedMemory(CONQUE_SOLE_INPUT_SIZE, 'input', mem_key)
        self.shm_input.create('write')
        self.shm_input.clear()

        self.shm_output = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns, 'output', mem_key, True)
        self.shm_output.create('write')

        if not CONQUE_FAST_MODE:
            self.shm_attributes = ConqueSoleSharedMemory(CONQUE_SOLE_BUFFER_LENGTH * self.columns, 'attributes', mem_key, True, encoding='latin-1')
            self.shm_attributes.create('write')

        self.shm_stats = ConqueSoleSharedMemory(CONQUE_SOLE_STATS_SIZE, 'stats', mem_key, serialize=True)
        self.shm_stats.create('write')
        self.shm_stats.clear()

        self.shm_command = ConqueSoleSharedMemory(CONQUE_SOLE_COMMANDS_SIZE, 'command', mem_key, serialize=True)
        self.shm_command.create('write')
        self.shm_command.clear()

        self.shm_resize = ConqueSoleSharedMemory(CONQUE_SOLE_RESIZE_SIZE, 'resize', mem_key, serialize=True)
        self.shm_resize.create('write')
        self.shm_resize.clear()

        self.shm_rescroll = ConqueSoleSharedMemory(CONQUE_SOLE_RESCROLL_SIZE, 'rescroll', mem_key, serialize=True)
        self.shm_rescroll.create('write')
        self.shm_rescroll.clear()

        return True


# vim:foldmethod=marker
autoload/conque_term/conque_subprocess.py	[[[1
213
# FILE:     autoload/conque_term/conque_subprocess.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
ConqueSubprocess

Create and interact with a subprocess through a pty.

Usage:

    p = ConqueSubprocess()
    p.open('bash', {'TERM':'vt100'})
    output = p.read()
    p.write('cd ~/vim' + "\r")
    p.write('ls -lha' + "\r")
    output += p.read(timeout = 500)
    p.close()
"""

import os
import signal
import pty
import tty
import select
import fcntl
import termios
import struct
import shlex

class ConqueSubprocess:

    # process id
    pid = 0

    # stdout+stderr file descriptor
    fd = None


    def open(self, command, env={}):
        """ Create subprocess using forkpty() """

        # parse command
        command_arr = shlex.split(command)
        executable = command_arr[0]
        args = command_arr


        # try to fork a new pty
        try:
            self.pid, self.fd = pty.fork()

        except:

            return False

        # child proc, replace with command after altering terminal attributes
        if self.pid == 0:

            # Set signals to default values in child
            try:
                signal.signal(signal.SIGCHLD, signal.SIG_DFL)
            except:
               pass

            try:
                signal.signal(signal.SIGHUP, signal.SIG_DFL)
            except:
               pass

            # set requested environment variables
            for k in env.keys():
                os.environ[k] = env[k]

            # set tty attributes
            try:
                attrs = tty.tcgetattr(1)
                attrs[0] = attrs[0] ^ tty.IGNBRK
                attrs[0] = attrs[0] | tty.BRKINT | tty.IXANY | tty.IMAXBEL
                attrs[2] = attrs[2] | tty.HUPCL
                attrs[3] = attrs[3] | tty.ICANON | tty.ECHO | tty.ISIG | tty.ECHOKE
                attrs[6][tty.VMIN] = 1
                attrs[6][tty.VTIME] = 0
                tty.tcsetattr(1, tty.TCSANOW, attrs)
            except:

                pass

            # replace this process with the subprocess
            os.execvp(executable, args)

        # else master, do nothing
        else:
            pass


    def read(self, timeout=1):
        """ Read from subprocess and return new output """

        output = ''
        read_timeout = float(timeout) / 1000
        read_ct = 0

        try:
            # read from fd until no more output
            while 1:
                s_read, s_write, s_error = select.select([self.fd], [], [], read_timeout)

                lines = ''
                for s_fd in s_read:
                    try:
                        # increase read buffer so huge reads don't slow down
                        if read_ct < 10:
                            lines = os.read(self.fd, 32)
                        elif read_ct < 50:
                            lines = os.read(self.fd, 512)
                        else:
                            lines = os.read(self.fd, 2048)
                        read_ct += 1
                    except:
                        pass
                    output = output + lines.decode('utf-8')

                if lines == '' or read_ct > 100:
                    break
        except:

            pass

        return output


    def write(self, input):
        """ Write new input to subprocess """

        try:
            if CONQUE_PYTHON_VERSION == 2:
                os.write(self.fd, input.encode('utf-8', 'ignore'))
            else:
                os.write(self.fd, bytes(input, 'utf-8'))
        except:

            pass


    def signal(self, signum):
        """ signal process """

        try:
            os.kill(self.pid, signum)
        except:
            pass


    def close(self):
        """ close process with sigterm signal """

        self.signal(15)


    def is_alive(self):
        """ get process status """

        p_status = True
        try:
            if os.waitpid(self.pid, os.WNOHANG)[0]:
                p_status = False
        except:
            p_status = False

        return p_status


    def window_resize(self, lines, columns):
        """ update window size in kernel, then send SIGWINCH to fg process """

        try:
            fcntl.ioctl(self.fd, termios.TIOCSWINSZ, struct.pack("HHHH", lines, columns, 0, 0))
            os.kill(self.pid, signal.SIGWINCH)
        except:
            pass


    def getpid(self):
        return self.pid;


# vim:foldmethod=marker
autoload/conque_term/conque_win32_util.py	[[[1
448
# FILE:     autoload/conque_term/conque_win32_util.py
# AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
# WEBSITE:  http://conque.googlecode.com
# MODIFIED: 2011-09-12
# VERSION:  2.3, for Vim 7.0
# LICENSE:
# Conque - Vim terminal/console emulator
# Copyright (C) 2009-2011 Nico Raffo
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

""" Python constants and structures used for ctypes interaction. """

from ctypes import *

# Constants

# create process flag constants

CREATE_BREAKAWAY_FROM_JOB = 0x01000000
CREATE_DEFAULT_ERROR_MODE = 0x04000000
CREATE_NEW_CONSOLE = 0x00000010
CREATE_NEW_PROCESS_GROUP = 0x00000200
CREATE_NO_WINDOW = 0x08000000
CREATE_PROTECTED_PROCESS = 0x00040000
CREATE_PRESERVE_CODE_AUTHZ_LEVEL = 0x02000000
CREATE_SEPARATE_WOW_VDM = 0x00000800
CREATE_SHARED_WOW_VDM = 0x00001000
CREATE_SUSPENDED = 0x00000004
CREATE_UNICODE_ENVIRONMENT = 0x00000400


DETACHED_PROCESS = 0x00000008
EXTENDED_STARTUPINFO_PRESENT = 0x00080000
INHERIT_PARENT_AFFINITY = 0x00010000


# process priority constants 

ABOVE_NORMAL_PRIORITY_CLASS = 0x00008000
BELOW_NORMAL_PRIORITY_CLASS = 0x00004000
HIGH_PRIORITY_CLASS = 0x00000080
IDLE_PRIORITY_CLASS = 0x00000040
NORMAL_PRIORITY_CLASS = 0x00000020
REALTIME_PRIORITY_CLASS = 0x00000100


# startup info constants 

STARTF_FORCEONFEEDBACK = 0x00000040
STARTF_FORCEOFFFEEDBACK = 0x00000080
STARTF_PREVENTPINNING = 0x00002000
STARTF_RUNFULLSCREEN = 0x00000020
STARTF_TITLEISAPPID = 0x00001000
STARTF_TITLEISLINKNAME = 0x00000800
STARTF_USECOUNTCHARS = 0x00000008
STARTF_USEFILLATTRIBUTE = 0x00000010
STARTF_USEHOTKEY = 0x00000200
STARTF_USEPOSITION = 0x00000004
STARTF_USESHOWWINDOW = 0x00000001
STARTF_USESIZE = 0x00000002
STARTF_USESTDHANDLES = 0x00000100


# show window constants 

SW_FORCEMINIMIZE = 11
SW_HIDE = 0
SW_MAXIMIZE = 3
SW_MINIMIZE = 6
SW_RESTORE = 9
SW_SHOW = 5
SW_SHOWDEFAULT = 10
SW_SHOWMAXIMIZED = 3
SW_SHOWMINIMIZED = 2
SW_SHOWMINNOACTIVE = 7
SW_SHOWNA = 8
SW_SHOWNOACTIVATE = 4
SW_SHOWNORMAL = 1


# input event types 

FOCUS_EVENT = 0x0010
KEY_EVENT = 0x0001
MENU_EVENT = 0x0008
MOUSE_EVENT = 0x0002
WINDOW_BUFFER_SIZE_EVENT = 0x0004


# key event modifiers 

CAPSLOCK_ON = 0x0080
ENHANCED_KEY = 0x0100
LEFT_ALT_PRESSED = 0x0002
LEFT_CTRL_PRESSED = 0x0008
NUMLOCK_ON = 0x0020
RIGHT_ALT_PRESSED = 0x0001
RIGHT_CTRL_PRESSED = 0x0004
SCROLLLOCK_ON = 0x0040
SHIFT_PRESSED = 0x0010


# process access 

PROCESS_CREATE_PROCESS = 0x0080
PROCESS_CREATE_THREAD = 0x0002
PROCESS_DUP_HANDLE = 0x0040
PROCESS_QUERY_INFORMATION = 0x0400
PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
PROCESS_SET_INFORMATION = 0x0200
PROCESS_SET_QUOTA = 0x0100
PROCESS_SUSPEND_RESUME = 0x0800
PROCESS_TERMINATE = 0x0001
PROCESS_VM_OPERATION = 0x0008
PROCESS_VM_READ = 0x0010
PROCESS_VM_WRITE = 0x0020


# input / output handles 

STD_INPUT_HANDLE = c_ulong(-10)
STD_OUTPUT_HANDLE = c_ulong(-11)
STD_ERROR_HANDLE = c_ulong(-12)


CONQUE_WINDOWS_VK = {
    'VK_LBUTTON': 0x0001,
    'VK_RBUTTON': 0x0002,
    'VK_CANCEL': 0x0003,
    'VK_BACK': 0x0008,
    'VK_TAB': 0x0009,
    'VK_CLEAR': 0x000C,
    'VK_RETURN': 0x0D,
    'VK_SHIFT': 0x10,
    'VK_CONTROL': 0x11,
    'VK_MENU': 0x12,
    'VK_PAUSE': 0x0013,
    'VK_CAPITAL': 0x0014,
    'VK_ESCAPE': 0x001B,
    'VK_SPACE': 0x0020,
    'VK_PRIOR': 0x0021,
    'VK_NEXT': 0x0022,
    'VK_END': 0x0023,
    'VK_HOME': 0x0024,
    'VK_LEFT': 0x0025,
    'VK_UP': 0x0026,
    'VK_RIGHT': 0x0027,
    'VK_DOWN': 0x0028,
    'VK_SELECT': 0x0029,
    'VK_PRINT': 0x002A,
    'VK_EXECUTE': 0x002B,
    'VK_SNAPSHOT': 0x002C,
    'VK_INSERT': 0x002D,
    'VK_DELETE': 0x002E,
    'VK_HELP': 0x002F,
    'VK_0': 0x0030,
    'VK_1': 0x0031,
    'VK_2': 0x0032,
    'VK_3': 0x0033,
    'VK_4': 0x0034,
    'VK_5': 0x0035,
    'VK_6': 0x0036,
    'VK_7': 0x0037,
    'VK_8': 0x0038,
    'VK_9': 0x0039,
    'VK_A': 0x0041,
    'VK_B': 0x0042,
    'VK_C': 0x0043,
    'VK_D': 0x0044,
    'VK_E': 0x0045,
    'VK_F': 0x0046,
    'VK_G': 0x0047,
    'VK_H': 0x0048,
    'VK_I': 0x0049,
    'VK_J': 0x004A,
    'VK_K': 0x004B,
    'VK_L': 0x004C,
    'VK_M': 0x004D,
    'VK_N': 0x004E,
    'VK_O': 0x004F,
    'VK_P': 0x0050,
    'VK_Q': 0x0051,
    'VK_R': 0x0052,
    'VK_S': 0x0053,
    'VK_T': 0x0054,
    'VK_U': 0x0055,
    'VK_V': 0x0056,
    'VK_W': 0x0057,
    'VK_X': 0x0058,
    'VK_Y': 0x0059,
    'VK_Z': 0x005A,
    'VK_LWIN': 0x005B,
    'VK_RWIN': 0x005C,
    'VK_APPS': 0x005D,
    'VK_SLEEP': 0x005F,
    'VK_NUMPAD0': 0x0060,
    'VK_NUMPAD1': 0x0061,
    'VK_NUMPAD2': 0x0062,
    'VK_NUMPAD3': 0x0063,
    'VK_NUMPAD4': 0x0064,
    'VK_NUMPAD5': 0x0065,
    'VK_NUMPAD6': 0x0066,
    'VK_NUMPAD7': 0x0067,
    'VK_NUMPAD8': 0x0068,
    'VK_MULTIPLY': 0x006A,
    'VK_ADD': 0x006B,
    'VK_SEPARATOR': 0x006C,
    'VK_SUBTRACT': 0x006D,
    'VK_DECIMAL': 0x006E,
    'VK_DIVIDE': 0x006F,
    'VK_F1': 0x0070,
    'VK_F2': 0x0071,
    'VK_F3': 0x0072,
    'VK_F4': 0x0073,
    'VK_F5': 0x0074,
    'VK_F6': 0x0075,
    'VK_F7': 0x0076,
    'VK_F8': 0x0077,
    'VK_F9': 0x0078,
    'VK_F10': 0x0079,
    'VK_F11': 0x007A,
    'VK_F12': 0x007B,
    'VK_F13': 0x007C,
    'VK_F14': 0x007D,
    'VK_F15': 0x007E,
    'VK_F16': 0x007F,
    'VK_F17': 0x0080,
    'VK_F18': 0x0081,
    'VK_F19': 0x0082,
    'VK_F20': 0x0083,
    'VK_F21': 0x0084,
    'VK_F22': 0x0085,
    'VK_F23': 0x0086,
    'VK_F24': 0x0087,
    'VK_NUMLOCK': 0x0090,
    'VK_SCROLL': 0x0091,
    'VK_LSHIFT': 0x00A0,
    'VK_RSHIFT': 0x00A1,
    'VK_LCONTROL': 0x00A2,
    'VK_RCONTROL': 0x00A3,
    'VK_LMENU': 0x00A4,
    'VK_RMENU': 0x00A5
}

CONQUE_WINDOWS_VK_INV = dict([v, k] for k, v in CONQUE_WINDOWS_VK.items())

CONQUE_WINDOWS_VK_ENHANCED = {
    str(int(CONQUE_WINDOWS_VK['VK_UP'])): 1,
    str(int(CONQUE_WINDOWS_VK['VK_DOWN'])): 1,
    str(int(CONQUE_WINDOWS_VK['VK_LEFT'])): 1,
    str(int(CONQUE_WINDOWS_VK['VK_RIGHT'])): 1,
    str(int(CONQUE_WINDOWS_VK['VK_HOME'])): 1,
    str(int(CONQUE_WINDOWS_VK['VK_END'])): 1
}


# structures used for CreateProcess

# Odd types 

LPBYTE = POINTER(c_ubyte)
LPTSTR = POINTER(c_char)


class STARTUPINFO(Structure):
    _fields_ = [("cb",            c_ulong),
                ("lpReserved",    LPTSTR),
                ("lpDesktop",     LPTSTR),
                ("lpTitle",       LPTSTR),
                ("dwX",           c_ulong),
                ("dwY",           c_ulong),
                ("dwXSize",       c_ulong),
                ("dwYSize",       c_ulong),
                ("dwXCountChars", c_ulong),
                ("dwYCountChars", c_ulong),
                ("dwFillAttribute", c_ulong),
                ("dwFlags",       c_ulong),
                ("wShowWindow",   c_short),
                ("cbReserved2",   c_short),
                ("lpReserved2",   LPBYTE),
                ("hStdInput",     c_void_p),
                ("hStdOutput",    c_void_p),
                ("hStdError",     c_void_p),]

    def to_str(self):
        return ''


class PROCESS_INFORMATION(Structure):
    _fields_ = [("hProcess",    c_void_p),
                ("hThread",     c_void_p),
                ("dwProcessId", c_ulong),
                ("dwThreadId",  c_ulong),]

    def to_str(self):
        return ''


class MEMORY_BASIC_INFORMATION(Structure):
    _fields_ = [("BaseAddress",       c_void_p),
                ("AllocationBase",    c_void_p),
                ("AllocationProtect", c_ulong),
                ("RegionSize",        c_ulong),
                ("State",             c_ulong),
                ("Protect",           c_ulong),
                ("Type",              c_ulong),]

    def to_str(self):
        return ''


class SECURITY_ATTRIBUTES(Structure):
    _fields_ = [("Length", c_ulong),
                ("SecDescriptor", c_void_p),
                ("InheritHandle", c_bool)]

    def to_str(self):
        return ''


class COORD(Structure):
    _fields_ = [("X", c_short),
                ("Y", c_short)]

    def to_str(self):
        return ''


class SMALL_RECT(Structure):
    _fields_ = [("Left", c_short),
                ("Top", c_short),
                ("Right", c_short),
                ("Bottom", c_short)]

    def to_str(self):
        return ''


class CONSOLE_SCREEN_BUFFER_INFO(Structure):
    _fields_ = [("dwSize", COORD),
                ("dwCursorPosition", COORD),
                ("wAttributes", c_short),
                ("srWindow", SMALL_RECT),
                ("dwMaximumWindowSize", COORD)]

    def to_str(self):
        return ''


class CHAR_UNION(Union):
    _fields_ = [("UnicodeChar", c_wchar),
                ("AsciiChar", c_char)]

    def to_str(self):
        return ''


class CHAR_INFO(Structure):
    _fields_ = [("Char", CHAR_UNION),
                ("Attributes", c_short)]

    def to_str(self):
        return ''


class KEY_EVENT_RECORD(Structure):
    _fields_ = [("bKeyDown", c_byte),
                ("pad2", c_byte),
                ('pad1', c_short),
                ("wRepeatCount", c_short),
                ("wVirtualKeyCode", c_short),
                ("wVirtualScanCode", c_short),
                ("uChar", CHAR_UNION),
                ("dwControlKeyState", c_int)]

    def to_str(self):
        return ''


class MOUSE_EVENT_RECORD(Structure):
    _fields_ = [("dwMousePosition", COORD),
                ("dwButtonState", c_int),
                ("dwControlKeyState", c_int),
                ("dwEventFlags", c_int)]

    def to_str(self):
        return ''


class WINDOW_BUFFER_SIZE_RECORD(Structure):
    _fields_ = [("dwSize", COORD)]

    def to_str(self):
        return ''


class MENU_EVENT_RECORD(Structure):
    _fields_ = [("dwCommandId", c_uint)]

    def to_str(self):
        return ''


class FOCUS_EVENT_RECORD(Structure):
    _fields_ = [("bSetFocus", c_byte)]

    def to_str(self):
        return ''


class INPUT_UNION(Union):
    _fields_ = [("KeyEvent", KEY_EVENT_RECORD),
                ("MouseEvent", MOUSE_EVENT_RECORD),
                ("WindowBufferSizeEvent", WINDOW_BUFFER_SIZE_RECORD),
                ("MenuEvent", MENU_EVENT_RECORD),
                ("FocusEvent", FOCUS_EVENT_RECORD)]

    def to_str(self):
        return ''


class INPUT_RECORD(Structure):
    _fields_ = [("EventType", c_short),
                ("Event", INPUT_UNION)]

    def to_str(self):
        return ''


doc/conque_term.txt	[[[1
690
*conque_term.txt*   Vim version 7.3    Last change: 2013 April 18

The ConqueTerm plugin will turn a Vim buffer into a terminal emulator, allowing
you to run and interact with a shell or shell application inside the buffer.

This version of the Conque Term plugin ships with the Conque GDB plugin.
It is an improvement of Conque Term 2.3. It contains aditional options
and supports updating terminal buffers which are not in focus.

==============================================================================

Contents

 1. Installation                               |conque-setup|
    1.1 Requirements for Unix                  |conque-requirements|
    1.2 Requirements for Windows               |conque-windows|
    1.3 Installation                           |conque-installation|
 2. Usage                                      |conque-usage|
    2.1 General Usage                          |conque-gen-usage|
    2.2 Special keys                           |conque-special-keys|
        2.2.1 Send text to Conque              |conque-send|
        2.2.2 Toggle terminal input mode       |conque-input-mode|
        2.2.3 Sending the <Esc> key press      |conque-esc|
        2.2.4 Sending interrupt <C-c>          |conque-interrupt|
 3. Options                                    |conque-options|
    3.1 General                                |conque-general|
        3.1.1 Python version                   |ConqueTerm_PyVersion|
        3.1.2 Fast mode                        |ConqueTerm_FastMode|
        3.1.3 Color support                    |ConqueTerm_Color|
        3.1.4 Keep updating terminal buffer    |ConqueTerm_ReadUnfocused|
        3.1.5 Insert mode when entering buffer |ConqueTerm_InsertOnEnter|
        3.1.6 Close buffer when program exits  |ConqueTerm_CloseOnEnd|
        3.1.7 Hide start messages              |ConqueTerm_StartMessages|
        3.1.8 Regex for prompt highlighting    |ConqueTerm_PromptRegex|
        3.1.9 Syntax type                      |ConqueTerm_Syntax|
        3.1.10 The bell Vim message            |ConqueTerm_ShowBell|
        3.1.11 Unfocused update time           |ConqueTerm_UnfocusedUpdateTime|
        3.1.12 Focused update time             |ConqueTerm_FocusedUpdateTime|
        3.1.13 Pasting text                    |ConqueTermPaste|
    3.2 Keyboard                               |conque-keyboard|
        3.3.1 The <Esc> key                    |ConqueTerm_EscKey|
        3.3.2 The <C-c> mapping                |ConqueTerm_Interrupt|
        3.3.3 Toggle terminal input mode       |ConqueTerm_ToggleKey|
        3.3.4 Enable <C-w> in insert mode      |ConqueTerm_CWInsert|
        3.3.5 Execute current file in Conque   |ConqueTerm_ExecFileKey|
        3.3.6 Send file contents to Conque     |ConqueTerm_SendFileKey|
        3.3.7 Send selected text to Conque     |ConqueTerm_SendVisKey|
        3.3.8 Function Keys                    |ConqueTerm_SendFunctionKeys|
    3.3 Unix                                   |conque-config-unix|
        3.4.1 Choose your terminal type        |ConqueTerm_TERM|
    3.4 Windows                                |conque-config-windows|
        3.5.1 Python executable                |ConqueTerm_PyExe|
        3.5.2 Windows character code page      |ConqueTerm_CodePage|
        3.5.3 Terminal color method            |ConqueTerm_ColorMode|
 4. VimScript API                              |conque-api|
    4.1 conque_term#open()                     |conque-open|
    4.2 conque_term#subprocess()               |conque-subprocess|
    4.3 conque_term#get_instance()             |conque-get-instance|
    4.4 CONQUE_OBJECT.write()                  |conque-write|
    4.5 CONQUE_OBJECT.writeln()                |conque-writeln|
    4.6 CONQUE_OBJECT.read()                   |conque-read|
    4.7 CONQUE_OBJECT.set_callback()           |conque-set-callback|
    4.8 CONQUE_OBJECT.close()                  |conque-close|
    4.9 Registering functions                  |conque-events|
 5. Misc                                       |conque-misc|
    5.1 Known bugs                             |conque-bugs|
    5.2 Contribute                             |conque-contribute|
    5.3 Feedback                               |conque-feedback|

==============================================================================

1. Installation                                                 *conque-setup*

Conque is designed for both Unix and Windows operating systems, however the
requirements are slightly different. Please check section below corresponding
to your installed OS.

Please do also take a look at the Installation section in the Conque GDB
specific help file |conque_gdb.txt|.

1.1 Requirements for Unix                                *conque-requirements*

 * [G]Vim 7.0+ with +python
 * Python 2.3+
 * Unix-like OS: Linux, OS X, Solaris, Cygwin, etc

The most common stumbling block is getting a version of Vim which has the 
python interface enabled. Most all software package managers will have a copy
of Vim with Python support, so that is often the easiest way to get it. If 
you're compiling Vim from source, be sure to use the --enable-pythoninterp 
option, or --enable-python3interp for Python 3. On OS X the best option is 
MacVim, which installs with Python support by default.

1.2 Requirements for Windows                                  *conque-windows*

 * [G]Vim 7.3 with +python
 * Python 2.7
 * Modern Windows OS (XP or later)

Conque only officially supports the latest GVim 7.3 Windows installer 
available at www.vim.org. If you are currently using Vim 7.2 or earlier you
will need to upgrade to 7.3 for Windows support. The Windows installer already
has the +python interface built in.

The official 7.3 release of Vim for Windows only works with Python versions
2.7 and/or 3.1. You can download and install Python from their website 
http://www.python.org/download

If you are compiling Vim + Python from source on Windows, the requirements
become only Vim 7.3+ and Python 2.7+.

1.3 Installation                                         *conque-installation*

Download the latest vimball from http://www.vim.org

Open the .vmb file with Vim and run the following commands:
>
    :so %
    :q
<
That's it! The :ConqueTerm* commands will be available the next time you start
Vim. You can delete the .vmb file when you've verified Conque was successfully
installed.

==============================================================================

2. Usage                                                        *conque-usage*

For Conque GDB usage, take check the |conque_gdb.txt| help file.

2.1 General Usage                                           *conque-gen-usage*
                   *ConqueTerm* *ConqueTermSplit* *ConqueTermVSplit* *ConqueTermTab*

Type :ConqueTerm <command> to launch an application in the current window. Eg:
>
    :ConqueTerm bash
    :ConqueTerm mysql -h localhost -u joe_lunchbox Menu
    :ConqueTerm Powershell.exe
<
Use :ConqueTermSplit or :ConqueTermVSplit to open Conque in a new horizontal
or vertical buffer. Use :ConqueTermTab to open Conque in a new tab.

In insert mode you can interact with the shell as you would expect in a 
normal terminal. All key presses will be sent to the terminal, including 
control characters. See |conque-special-keys| for more information, 
particularly regarding the <Esc> and <C-c> mappings.

In normal mode you can use Vim commands to browse your terminal output and 
scroll back through the history. Most all Vim functionality will work, such
as searching, yanking or highlighting text.

2.2 Special keys                                         *conque-special-keys*

There are several keys which can be configured to have special behavior with
Conque.

2.2.1 Send text to Conque                                        *conque-send*

Conque gives you three different commands to send text from a different
buffer, probably a source code file, to the Conque terminal buffer. All three
are configurable to use your choice of key combinations.

To send a visually selected range of text to an existing terminal buffer,
press the <F9> key.

To send the entire contents of the file you are editing to an existing
terminal buffer, press the <F10> key.

Finally, to execute the current file in a new terminal buffer press the <F11>
key. This will split the screen with a new Conque buffer. The file you are
editing must be executable for this command to work.

See |conque-options| for information about configuring these commands.

2.2.2 Toggle terminal input mode                           *conque-input-mode*

If you want to use insert mode to edit the terminal screen, press <F8>. You
will now be able to edit the terminal output freely without your cursor
jumping the the active prompt line. This may be useful if you want to reformat
terminal output for readability. 

While the terminal is paused new output will not be displayed on the screen
until you press <F8> again to resume.

You can configure Conque to use a different key with the |ConqueTerm_ToggleKey| 
option.

2.2.3 Sending the <Esc> key press                                 *conque-esc*

By default if you press the <Esc> key in a Conque buffer you will leave insert
mode. But what if you want the <Esc> character to be sent to your terminal? 
There are two options. By default, pressing <Esc> twice will send one <Esc>
character to the terminal and you will remain in insert mode, while pressing 
it once will leave insert mode.

Alternatively you can use the |ConqueTerm_EscKey| option to choose a
different key for leaving insert mode. If a custom key is set, then all <Esc> 
key presses will be sent to the terminal.

2.2.4 Sending interrupt <C-c>                               *conque-interrupt*

By default Conque will to send the <C-c> key mapping to the terminal. If you
want to change this to something different you can use the option
|ConqueTerm_Interrupt|.

2.3 Registering functions                                    *conque-register*

Conque allows you to write your own VimScript functions which will be called
at certain events. See the API section |conque-events| for more.

==============================================================================

3. Options                                                    *conque-options*

You can set the following options in your .vimrc (default values shown).

Conque GDB also defines some options, take a look at the |conque_gdb.txt| help
file for documentation of these options.

3.1 General                                            *conque-config-general*

3.1.1 Python version                                    *ConqueTerm_PyVersion*

Conque will work with either Python 2.x or 3.x, assuming the interfaces have
been installed. By default it will try to use Python 2 first, then will try 
Python 3. If you want Conque to use Python 3, set this variable to 3. 

Note: even if you set this to 3, if you don't have the python3 interface
Conque will fall back to using Python 2.
>
    let g:ConqueTerm_PyVersion = 2
<
3.1.2 Fast Mode                                          *ConqueTerm_FastMode*

Disable features which could make Conque run slowly. This includes most
terminal colors and some unicode support. Set this to 1 to enable fast mode.
>
    let g:ConqueTerm_FastMode = 0
<
3.1.3 Color support                                         *ConqueTerm_Color*

Terminal colors have the potential to slow down terminal screen rendering,
depending on how many colors are used and how fast the computer is. This
option allows you to choose how much color support will be enabled.

If set to 0, terminal colors will be disabled. This will allow the terminal to
render most quickly. Syntax highlighting will still work. For example 
highlighting quoted strings or MySQL output.

If set to 1, terminal colors will be enabled, but only for the most recent 200
lines of terminal output. Older output will be periodically stripped of color
highlighting to keep the display responsive.

If set to 2, terminal colors will always be enabled. If your programs don't
use color output very frequently this is a good choice.

Note: Color support is automatically disabled in "fast mode".
>
    let g:ConqueTerm_Color = 1
<
3.1.4 Keep updating terminal buffer                 *ConqueTerm_ReadUnfocused*

If set to 1 then your Conque buffers will continue to update after you've
switched to another buffer.
>
    let g:ConqueTerm_ReadUnfocused = 0
<
3.1.5 Insert mode when entering buffer              *ConqueTerm_InsertOnEnter*

If set to 1 then you will automatically go into insert mode when you enter the
buffer. This diverges from normal Vim behavior. If 0 you will still be in
normal mode.
>
    let g:ConqueTerm_InsertOnEnter = 0
<
3.1.6 Close buffer when program exits                  *ConqueTerm_CloseOnEnd*

If you want your terminal buffer to be closed and permanently deleted when the 
program running inside of it exits, set this option to 1. Otherwise the buffer
will become a simple text buffer after the program exits, and you can edit the
program output in insert mode.
>
    let g:ConqueTerm_CloseOnEnd = 0
<
3.1.7 Show start messages                           *ConqueTerm_StartMessages*

Display warning messages when starting up ConqueTerm if your system is
configured incorrectly.
>
    let g:ConqueTerm_StartMessages = 1
<
3.1.8 Regex for highlighting your prompt              *ConqueTerm_PromptRegex*

Use this regular expression for sytax highlighting your terminal prompt. Your
terminal will generally run faster if you use Vim highlighting instead of 
terminal colors for your prompt. You can also use it to do more advanced
syntax highlighting for the prompt line.
>
    let g:ConqueTerm_PromptRegex = '^\w\+@[0-9A-Za-z_.-]\+:[0-9A-Za-z_./\~,:-]\+\$'
<
3.1.9 Choose Vim syntax type                               *ConqueTerm_Syntax*

Set the buffer syntax. The default has highlighting for MySQL,
but not much else.
>
    let g:ConqueTerm_Syntax = 'conque_term'
<
3.1.10 The bell Vim message                              *ConqueTerm_ShowBell*

You can choose whether you want Conque to echo the warning message 'BELL!'
whenever the bell character is written to a Conque terminal.
>
    let g:ConqueTerm_ShowBell = 0
<
3.1.11 Unfocused update time                  *ConqueTerm_UnfocusedUpdateTime*

Use this option to define how often in milliseconds you want Conque to
update your terminals when you are not in insert mode. The value 0 (zero) 
is special, use 0 if you want to keep you normal update time (|updatetime|)
when you are in normal mode.
>
        let g:ConqueTerm_UnfocusedUpdateTime = 500
>
3.1.12 Focused update time                      *ConqueTerm_FocusedUpdateTime*

Use this option to define how often in milliseconds you want Conque to
update the terminal in focus when you are in insert mode. The value 0 (zero)
is special and means that you want to keep your normal |updatetime| in insert
mode.
>
    let g:ConqueTerm_FocusedUpdateTime = 80
>
3.1.13 Pasting                                               *ConqueTermPaste*

Use the ConqueTermPaste command to paste the previously yanked text.

3.2 Keyboard                                          *conque-config-keyboard*

3.2.1 The <Esc> key                                        *ConqueTerm_EscKey*

If a custom key is set, then all <Esc> key presses will be sent to the 
terminal and you must use this custom key to leave insert mode. If left to the
default value of '<Esc>' then you must press it twice to send the escape
character to the terminal, while pressing it once will leave insert mode.

Note: You cannot use a key which is internally coded with the escape
character. This includes the <F-> keys and often the <A-> and <M-> keys.
Picking a control key, such as <C-k> will be your best bet.
>
    let g:ConqueTerm_EscKey = '<Esc>'
<
3.2.2 The <C-c> mapping                                 *ConqueTerm_Interrupt*

This key mapping defines how ConqueTerm will send interrupt to the terminal
in both normal and insert mode. By default this will be <C-c>. If you are
used to <C-c> for leaving insert mode you might want to change it.
>
    let g:ConqueTerm_Interrupt = '<C-c>'
<
3.2.3 Toggle terminal input mode                        *ConqueTerm_ToggleKey*

Press this key to pause terminal input and output display. You will then be
able to edit the terminal screen as if it were a normal text buffer. Press
this key again to resume terminal mode.
>
    let g:ConqueTerm_ToggleKey = '<F8>'
<
3.2.4 Enable <C-w> in insert mode                        *ConqueTerm_CWInsert*

If set to 1 then you can leave the Conque buffer using the <C-w> commands
while you're still in insert mode. If set to 0 then the <C-w> character will
be sent to the terminal. If both this option and ConqueTerm_InsertOnEnter are
set you can go in and out of the terminal buffer while never leaving insert
mode.
>
    let g:ConqueTerm_CWInsert = 0
<
3.2.5 Execute current file in Conque                  *ConqueTerm_ExecFileKey*

Press this key to execute the file you're currently editing in a Conque
buffer. Is equivelent to running the command :ConqueTermSplit YOUR_FILE. Your
file must be executable for this command to work correctly.
>
    let g:ConqueTerm_ExecFileKey = '<F11>'
<
3.2.6 Send file contents to Conque                    *ConqueTerm_SendFileKey*

Press this key to send your entire file contents to the most recently opened
Conque buffer as keyboard input.
>
    let g:ConqueTerm_SendFileKey = '<F10>'
<
3.2.7 Send selected text to Conque                     *ConqueTerm_SendVisKey*

Use this key to send the currently selected text to the most recently created
Conque buffer.
>
    let g:ConqueTerm_SendVisKey = '<F9>'
<
3.2.8 Function Keys                              *ConqueTerm_SendFunctionKeys*

By default, function keys (the F1-F12 row at the top of your keyboard) are not
passed to the terminal. Set this option to 1 to send these key events.

Note: Unless you configured |ConqueTerm_SendVisKey| and |ConqueTerm_ToggleKey|
to use different keys, <F8> and <F9> will not be sent to the terminal even if
you set this option to 1.
>
    let g:ConqueTerm_SendFunctionKeys = 0
<
3.3 Unix                                                  *conque-config-unix*

3.3.1 Choose your terminal type, Unix ONLY                   *ConqueTerm_TERM*

Use this option to tell Conque what type of terminal it should identify itself
as. Conque officially uses the more limited VT100 terminal type for
developement and testing, although it supports some more advanced features
such as colors and title strings.

You can change this setting to a more advanced type, namely 'xterm', but your
results may vary depending on which programs you're running.
>
    let g:ConqueTerm_TERM = 'vt100'
<
3.4 Windows                                            *conque-config-windows*

3.4.1 Python executable, Windows ONLY                       *ConqueTerm_PyExe*

The Windows version of Conque needs to know the path to the python.exe
executable for the version of Python Conque is using. If you installed Python
in the default location, or added the Python directory to your system path,
Conque should be able to find python.exe without you changing this variable.

For example, you might set this to 'C:\Program Files\Python27\python.exe'
>
    let g:ConqueTerm_PyExe = ''
<
3.4.2 Windows character code page                        *ConqueTerm_CodePage*

Set the "code page" Windows will use for your console. Leave this value set to
zero to use the environment code page.

Note: Displaying unicode characters on Conque for Windows needs work.
>
      let g:ConqueTerm_CodePage = 0
<
3.4.3 Terminal color method, Windows ONLY               *ConqueTerm_ColorMode*

Vim syntax highlighting by coordinate (e.g. the 3-7th characters on the 42nd
line) can be very slow. If you set this variable to 'conceal', you can use
the new conceal feature to render terminal colors. Requires Vim 7.3 and only 
works on the Windows version of Conque. This will make colors render faster, 
however it will also add hidden characters to the screen, which may be 
annoying if you're copying and pasting terminal output out of the Conque 
buffer. Set this to an empty string '' to disable concealed highlighting.
>
    let g:ConqueTerm_ColorMode = 'conceal'
<
==============================================================================

4. VimScript API                                                  *conque-api*

The Conque scripting API allows you to create and interact with Conque
terminals with the VimScript language.

4.1 conque_term#open({command}, [buf_opts], [remain])            *conque-open*

The open() function will create a new terminal buffer and start your command.

The {command} must be an executable, either an absolute path or relative to
your system path.

You can pass in a list of vim commands [buf_opts] which will be executed after
the new buffer is created but before the command is started. These are
typically commands to alter the size, position or configuration of the buffer
window.

Note: If you don't pass in a command such as 'split', the terminal will open
in the current buffer.

If you don't want the new terminal buffer to become the new active buffer, set
 [remain] to 1. Only works if you create a split screen using [options].

Returns a Conque terminal object.

Examples:
>
    let my_terminal = conque_term#open('/bin/bash')
    let my_terminal = conque_term#open('ipython', ['split', 'resize 20'], 1)
<
4.2 conque_term#subprocess({command}) (experimental)       *conque-subprocess*

Starts a new subprocess with your {command}, but no terminal buffer is ever
created. This may be useful if you need asynchronous interaction with a
subprocess, but want to handle the output on your own.

Returns a Conque terminal object.

Example:
>
    let my_subprocess = conque_term#subprocess('tail -f /var/log/foo.log')
<
4.3 conque_term#get_instance( [terminal_number] )        *conque-get-instance*

Use the get_instance() function to retrieve an existing terminal object. The
terminal could have been created either with the user command :ConqueTerm or
with an API call to conque_term#open() or subprocess().

Use the optional [terminal_number] to retrieve a specific terminal instance. 
Otherwise if the current buffer is a Conque terminal, it will be returned,
else the most recently created terminal. The terminal number is what you see 
at the end of a terminal buffer name, e.g. "bash - 2".

Returns a Conque terminal object.

Example:
>
    nnoremap <F4> :call conque_term#get_instance().writeln('clear')<CR>
<
4.4 CONQUE_OBJECT.write({text})                                 *conque-write*

Once you have a terminal object from open(), subprocess() or get_instance() 
you can send text input to it with the write() method.

No return value.

Examples:
>
    call my_terminal.write("whoami\n")
    call my_terminal.write("\<C-c>")
<
4.5 CONQUE_OBJECT.writeln({text})                             *conque-writeln*

The same as write() except adds a \n character to the end if your input.

Examples:
>
    call my_subprocess.writeln('make')
<
4.6 CONQUE_OBJECT.read( [timeout], [update_buffer] )             *conque-read*

Read new output from a Conque terminal subprocess. New output will be returned
as a string, and the terminal buffer will also be updated by default.

If you are reading immediately after calling the write() method, you may want
to wait [timeout] milliseconds for output to be ready.

If you want to prevent the output from being displayed in the terminal buffer,
set [update_buffer] to 0. This option has no effect if the terminal was 
created with the subprocess() function, since there never is a buffer to
update.

Returns output string.

Note: The terminal buffer will not automatically scroll down if the new output
extends beyond the bottom of the visible buffer. Vim doesn't allow "unfocused"
buffers to be scrolled at the current version, although hopefully this will 
change.

Examples:
>
    call my_terminal.writeln('whoami')
    let output = my_terminal.read(500)
    call my_terminal.writeln('ls -lha')
    let output = my_terminal.read(1000, 1)
<
4.7 CONQUE_OBJECT.set_callback( {funcname} )             *conque-set-callback*

Register a callback function for this subprocess instance. This function will
automatically be called whenever new output is available. Only practical with
subprocess() objects.

Conque checkes for new subprocess output once a second when Vim is idle. If
new output is found your function will be called.

Pass in the callback function name {funcname} as a string.

No return value.

Note: this method requires the g:ConqueTerm_ReadUnfocused option to be set.

Note: this method is experimental, results may vary.

Example:
>
    let sp = conque_term#subprocess('tail -f /home/joe/log/error_log')

    function! MyErrorAlert(output)
        echo a:output
    endfunction

    call sp.set_callback('MyErrorAlert')
<
4.8 CONQUE_OBJECT.close()                                       *conque-close*

Kill your terminal subprocess. Sends the ABORT signal. You probably want to
close your subprocess in a more graceful manner with the write() method, but 
this can be used when needed. Does not close the terminal buffer, if it
exists.

This method will be called on all existing Conque subprocesses when Vim exits.

Example:
>
    let term = conque_term#open('ping google.com', ['belowright split'])
    call term.read(5000)
    call term.close()
<
4.9 Registering functions                                      *conque-events*

Conque provides the option to register callback functions which will be
executed at several different events. The currently available events are:

  after_startup    After your application has loaded into the buffer.
  after_close      After your application has terminated, but not when the
                   application buffer gets unloaded.
  buffer_enter     When you switch to a Conque buffer.
  buffer_leave     When you leave a Conque buffer.

You may use the function conque_term#register_function(event, function_name) 
to add additional hooks at a particular event. The second argument should be
the name of a callback function which has one parameter, the current 
terminal object (see |conque-api| for more about terminal objects). 

For example:
>
  function MyConqueStartup(term)

      " set buffer syntax using the name of the program currently running
      let syntax_associations = { 'ipython': 'python', 'irb': 'ruby' }

      if has_key(syntax_associations, a:term.program_name)
          execute 'setlocal syntax=' . syntax_associations[a:term.program_name]
      else
          execute 'setlocal syntax=' . a:term.program_name
      endif

      " shrink window height to 10 rows
      resize 10

      " silly example of terminal api usage
      if a:term.program_name == 'bash'
          call a:term.writeln('svn up ~/projects/*')
      endif
      
  endfunction

  call conque_term#register_function('after_startup', 'MyConqueStartup')
<

==============================================================================

5. Misc                                                          *conque-misc*


5.1 Known bugs                                                   *conque-bugs*

The following are known limitations:

 - Font/color highlighting is imperfect and slow. If you don't care about
   color in your shell, set g:ConqueTerm_Color = 0 in your .vimrc
 - Conque only supports the extended ASCII character set for input, not utf-8.
 - VT100 escape sequence support is not complete.
 - Alt/Meta key support in Vim isn't great in general, and conque is no 
   exception. Pressing <Esc><Esc>x or <Esc><M-x> instead of <M-x> works in 
   most cases.

5.2 Contribute                                             *conque-contribute*

The two contributions most in need are improvements to Vim itself. I currently 
use hacks to capture key press input from the user, and to poll the terminal
for more output. The Vim todo.txt document lists proposed improvements to give 
users this behavior without hacks. Having a key press event should allow 
Conque to work with multi- byte input. If you are a Vim developer, please 
consider prioritizing these two items: 

 - todo.txt (Autocommands, line ~3137)
     8   Add an event like CursorHold that is triggered repeatedly, not just 
         once after typing something.


5.3 Feedback                                                 *conque-feedback*

Bugs, suggestions and patches are all welcome.

For more information visit http://conque.googlecode.com

Check out the latest from svn at http://conque.googlecode.com/svn/trunk/

vim:tw=78:ts=8:ft=help:norl:
doc/conque_gdb.txt	[[[1
366
*conque_gdb.txt*    Vim version 7.3   Last change: 2013 May 7

This help file explains the Conque GDB Vim plugin.

==============================================================================

Introduction

The Conque GDB plugin extends the Conque (Conque Term) plugin. Like Conque
Term, Conque GDB is a terminal emulator. The |ConqueGdb|, |ConqueGdbSplit|,
|ConqueGdbVsplit| and |ConqueGdbTab| commands will turn a Vim buffer into a
GDB command line interface (CLI).

When debugging a program with one of the |ConqueGdb|* commands, Conque GDB will
automatically open the appropriate source files when break points are hit,
and highlight the line where program execution has stopped. And if you install
Conque GDB on a Unix system with GDB 7.0+ compiled with python support, Conque
GDB will place signs on lines to mark where you have placed break points.

Conque GDB ships with a modified version of Conque Term 2.3. This new version
of Conque Term comes with new options and new features. Please see the
|conque_term.txt| help file for help regarding Conque Term. Most of the Conque
Term options also apply to Conque GDB, so even if you don't plan on using
Conque Term it's a good idea to take a look at the Conque Term options.
Especially regarding the |ConqueTerm_ReadUnfocused| option, which is now fully
functional.

==============================================================================

Contents

1. Installation                              |conque-gdb-setup|
   1.1 Requirements for Unix                 |conque-gdb-unix-requirements|
   1.2 Requirements for Windows              |conque-gdb-window-requirements|
   1.3 Vimball installation                  |conque-gdb-installation|
2. Usage                                     |conque-gdb-usage|
   2.1 Opening Conque GDB CLI                |conque-gdb-open|
   2.2 Delete unneeded buffers               |conque-gdb-delete-buffers|
   2.3 Send command to GDB                   |conque-gdb-command|
   2.4 Send command to GDB                   |conque-gdb-exe|
3. Options                                   |conque-gdb-options|
   3.1 GDB Source code split                 |conque-gdb-src-split|
   3.2 Path to GDB                           |conque-gdb-path|
   3.3 Disable GDB commands                  |conque-gdb-disable|
   3.4 Save command history                  |conque-gdb-save-history|
   3.5 Set Read Timeout For GDB Resposes     |conque-gdb-read-timeout|
   3.6 Keyboard Mappings                     |conque-gdb-mappings|
       3.6.1 Mappings leader                 |conque-gdb-leader|
       3.6.2 Run program mapping             |conque-gdb-run-mapping|
       3.6.3 Continue program mapping        |conque-gdb-continue-mapping|
       3.6.4 Next line mapping               |conque-gdb-next-mapping|
       3.6.5 Step line mapping               |conque-gdb-step-mapping|
       3.6.6 Print identifier under cursor   |conque-gdb-print-mapping|
       3.6.7 Toggle break point mapping      |conque-gdb-toggle-mapping|
       3.6.8 Set break point mapping         |conque-gdb-break-mapping|
       3.6.9 Delete break point mapping      |conque-gdb-delete-break-mapping|
       3.6.10 Finish mapping                 |conque-gdb-finish-mapping|
       3.6.11 Backtrace mapping              |conque-gdb-backtrace-mapping|
4. Custom key mappings                       |conque-gdb-custom-key-mappings|

==============================================================================

1. Installation                              *conque-gdb-setup*

Conque GDB works on both Unix and Windows. The requirements are slightly
different though. Note that Conque GDB supports some features on Unix which
are not supported on Windows.

1.1 Requirements for Unix                    *conque-gdb-unix-requirements*

 * [G]Vim 7.3+ with +python
 * Python 2.3+
 * Unix-like OS: Linux, OS X, Solaris, Cygwin, etc
 * GDB 7.0+ (see note below)

Note: Conque GDB actually works with older versions of GDB (GDB 6.3+).
However GDB 7.0+ is recommended since it is likely to support all the Conque
GDB features.

Even tough you have GDB 7.0+ installed on your system it is not 100% sure that
it will support all the Conque GDB features, namely the ability to place signs
on lines to mark where break points are currently placed. If you encounter
this problem with GDB 7.0+ installed on your system, then go ahead and build
GDB 7.0+ from source with python support by specifying the '--with-python'
configuration option.

1.2 Requirements for Windows                 *conque-gdb-windows-requirements*

 * [G]Vim 7.3 with +python
 * Python 2.7
 * Modern Windows OS (XP or later)
 * MinGW GDB 7.0+

See http://www.mingw.org/wiki/Getting_Started for an explanation on how to
install MinGW. If you don't install MinGW in the C:\MinGW directory and you
haven't specified a path to the path\to\MinGW\bin directory in your PATH
environment variable. Then you have to tell Conque GDB where MinGW GDB is
installed on your system. See the |ConqueGdb_GdbExe| option for an explanation
on how to do this.

1.3 Vimball Installation                     *conque-gdb-installation*

Download the latest conque_gdb.vmb vimball from http://www.vim.org.

Open conque_gdb.vmb with Vim and run the following commands:
>
    :so %
    :q
<
Next time you open Vim the |ConqueTerm|* and |ConqueGdb|* commands will be
available.

==============================================================================

2. Usage                                     *conque-gdb-usage*

This section describes the usage of Conque GDB. See the Conque Term specific
file |conque_term.txt|, for Conque Term usage.

2.1 Opening Conque GDB CLI                   *conque-gdb-open* 
                                             *ConqueGdb*    *ConqueGdbVSplit* 
                                             *ConqueGdbTab* *ConqueGdbSplit*

Type :ConqueGdb <gdb-arguments> to launch GDB in the current window. E.g.:
>
    :ConqueGdb
    :ConqueGdb program
    :ConqueGdb -d dir --args program [arguments] 
<
Use :ConqueGdbSplit or :ConqueGdbVSplit to open GDB in a new horizontal or
vertical buffer. When opening GDB with one of the split commands, it will
use the current window as its destination window for source files when
break points are hit. Use :ConqueGdbTab to open GDB in a new tab.

When issuing the :ConqueGdbTab or :ConqueGdb commands Conque GDB will open a
new split window for the source files. See |g:ConqueGdb_SrcSplit| to change how
Conque should split the GDB window.

2.2 Delete unneeded buffers                  *conque-gdb-delete-buffers*
                                             *ConqueGdbBDelete*

Once you have debugged a program with one of the |ConqueGdb|* commands, you
might experience that a lot of new source files have been opened in buffers.
If you want Conque to get rid of some of these buffers, you can use the
|ConqueGdbBDelete| command. This command deletes the buffers ConqueGdb opened
while you were debugging.

Note that only buffers opened by Conque GDB will be deleted, and if you have
modified a buffer opened by Conque GDB, this buffer will not be deleted either.
>
    :ConqueGdbBDelete
>
2.3 Send command to GDB                      *conque-gdb-command*
                                             *ConqueGdbCommand*

If you are currently outside the GDB CLI window and would like to send a
command to GDB use |ConqueGdbCommand| to send any command to GDB. E.g.
>
    :ConqueGdbCommand disable 1
>
This will only work properly if the |ConqueTerm_ReadUnfocused| option is
enabled. See the help file |conque_term.txt| for information.

2.4 Set path to GDB                          *conque-gdb-exe*
                                             *ConqueGdbExe*

If switch is needed between different GDB executables, for instance, during
cross-development, you can specify path to a GDB executable as follows:
>
    :ConqueGdbExe /path/to/gdb-cross
    :ConqueGdbExe
>
When zero arguments are given to the |ConqueGdbExe| command, Conque GDB will
use the default path to GDB, as specified by the |g:ConqueGdb_GdbExe| option
on startup. See |g:ConqueGdb_GdbExe|.
==============================================================================

3. Options                                   *conque-gdb-options*

This section describes the modifiable options Conque Gdb offers. Please take
a look at the |conque_term.txt| help file for Conque Term options. Most of
these options also apply to Conque Gdb.

3.1 GDB Source code split                    *conque-gdb-src-split*
                                             *g:ConqueGdb_SrcSplit*

When Conque GDB splits the GDB CLI window to open source files it will by
defaut split the window such that the source code will appear above the GDB
CLI window. You can change the value of |g:ConqueGdb_SrcSplit| to 'above',
'below', 'left' or 'right' if you want Conque GDB to split the GDB window
such that the source code will spilt above, below, left or right to the
GDB CLI window.
>
    let g:ConqueGdb_SrcSplit = 'above'
<
3.2 Path to GDB                              *conque-gdb-path*
                                             *g:ConqueGdb_GdbExe*

If the |ConqueGdb| commands can't find GDB in the system path, then you might
need to specify the path to the GDB executable manually. However on Windows
Conque will also look for GDB in C:\MinGW\bin. To define the path to the GDB
executable you can change the value of |g:ConqueGdb_GdbExe|. By default this
option is:
>
   let g:ConqueGdb_GdbExe = ''
<
Note that you have to restart Vim before changes to |g:ConqueGdb_GdbExe| are
recognized. If you would like to change path to the GDB executable at runtime,
use the |ConqueGdbExe| command.

3.3 Disable GDB commands                     *conque-gdb-disable*
                                             *g:ConqueGdb_Disable*

With this option you can disable the Conque GDB plugin. By default it is
enabled:
>
    let g:ConqueGdb_Disable = 0
<
3.4 Save command history                     *conque-gdb-save-history*
                                             *g:ConqueGdb_SaveHistory*

With this option you can tell whether Conque GDB should save history of
commands that are issued by keyboard mappings. By default the keyboard mapping
command history is not saved, which implies you will not see the commands
issued by keyboard mappings when pressing <Up> to view previous GDB commands
in the CLI window.
>
    let g:ConqueGdb_SaveHistory = 0

3.5 Set Read Timeout For GDB Resposes        *conque-gdb-read-timeout*
                                             *g:ConqueGdb_ReadTimeout*

This will allow you to set the timeout before Conque GDB tries to read output
from GDB. You may have to change the time depending on the amount of output
GDB makes and system performance. The default is 50 milliseconds.

    let g:ConqueGdb_ReadTimeout = 50


3.6 Keyboard Mappings                        *conque-gdb-mappings*

Conque GDB defines keyboard mappings to some of the most common gdb commands.
By default these Keyboard mappings use the |mapleader| (|<leader>|) as prefix.
However you can change this with the |g:ConqueGdb_Leader| option.

Note that you need to enable the |ConqueTerm_ReadUnfocused| option for the
keyboard mappings to work properly. See the help file |conque_term.txt|.

3.6.1 Mappings leader                        *conque-gdb-leader*
                                             *g:ConqueGdb_Leader*

This option specifies which keyboard key is used as prefix for the Conque GDB
keyboard mappings described below. By default it is:
>
    let g:ConqueGdb_Leader = '<Leader>'
>
Note that |<Leader>| is usually defined as \ (backslash). You don't have to
use the |g:ConqueGdb_Leader| when defining new keyboard mappings as described
below.

3.6.2 Run program mapping                    *conque-gdb-run-mapping*
                                             *g:ConqueGdb_Run*

This option defines the keyboard mapping used to issue the GDB command run
from any buffer. By default this is:
>
    let g:ConqueGdb_Run = g:ConqueGdb_Leader . 'r'
>
3.6.3 Continue program mapping               *conque-gdb-continue-mapping*
                                             *g:ConqueGdb_Continue*

This option defines the mapping used to issue the continue command. This
is by default:
>
    let g:ConqueGdb_Continue = g:ConqueGdb_Leader . 'c'
>
3.6.4 Next line mapping                      *conque-gdb-next-mapping*
                                             *g:ConqueGdb_Next*

Mapping to issue GDB command next. Default:
>
    let g:ConqueGdb_Next = g:ConqueGdb_Leader . 'n'
>
3.6.5 Step line mapping                      *conque-gdb-step-mapping*
                                             *g:ConqueGdb_Step*

Mapping to send the step command to GDB. Default:
>
    let g:ConqueGdb_Step = g:ConqueGdb_Leader . 's'
>
3.6.6 Print identifier under cursor          *conque-gdb-print-mapping*
                                             *g:ConqueGdb_Print*

This mapping is used to issue the print GDB command, to print value of the
identifier under the cursor. By default it is:
>
    let g:ConqueGdb_Print = g:ConqueGdb_Leader . 'p'
>
3.6.7 Toggle break point mapping             *conque-gdb-toggle-mapping*
                                             *g:ConqueGdb_ToggleBreak*

This is a special mapping used to toggle a break point on the current line.
I.e. if there is a break point on the current line already it will delete
the break point, otherwise it will create a new break point on the current
line.

This mapping is only supported on Unix having GDB 7.0+ with full python
support. See |conque-gdb-unix-requirements|. By default this mapping is:
>
    let g:ConqueGdb_ToggleBreak = g:ConqueGdb_Leader . 'b'
>
3.6.8 Set break point mapping                *conque-gdb-break-mapping*
                                             *g:ConqueGdb_SetBreak*

This mapping is specific to Conque GDB installations on Windows and Unix
systems where GDB does not have full python support. See |conque-gdb-setup|.

It will issue the GDB command break to place a break point on the current
line. By default this mapping is:
>
    let g:ConqueGdb_SetBreak = g:ConqueGdb_Leader . 'b'
>
3.6.9 Delete break point mapping             *conque-gdb-delete-break-mapping*
                                             *g:ConqueGdb_DeleteBreak*

This mapping is specific to Conque GDB installations on Windows and Unix
systems where GDB does not have full python support. See |conque-gdb-setup|.

It will issue the GDB command clear to delete the break point on the current
line. Default:
>
    let g:ConqueGdb_DeleteBreak = g:ConqueGdb_Leader . 'd'
>
3.6.10 Finish mapping                              *conque-gdb-finish-mapping*
                                                   *g:ConqueGdb_Finish*

Mapping to issue the finish command. Default:
>
    let g:ConqueGdb_Finish = g:ConqueGdb_Leader . 'f'
>
3.6.11 Backtrace mapping                        *conque-gdb-backtrace-mapping*
                                                *g:ConqueGdb_Backtrace*

Mapping to execute the backtrace command. By default it is:
>
    let g:ConqueGdb_Backtrace = g:ConqueGdb_Leader . 't'
>
4. Custom key mappings                        *conque-gdb-custom-key-mappings*

This section shows you how you can use |ConqueGdbCommand| to setup your
own customized Conque GDB key mappings.

You might want to be able answer GDB confirmations (say y or n) without
having to go to the Conque GDB window. You can use the |ConqueGdbCommand|
command to achieve this:
>
    nnoremap <silent> <Leader>Y :ConqueGdbCommand y<CR>
    nnoremap <silent> <Leader>N :ConqueGdbCommand n<CR>
>
With those 2 lines in your vimrc file you can type the leader key followed
by a capital Y to answer yes to GDB confirmations and leader followed by
capital N to answer no to GDB confirmations.

==============================================================================

vim:tw=78:ts=8:ft=help:norl:
plugin/conque_gdb.vim	[[[1
118

" Option to specify whether to enable ConqueGdb
if !exists('g:ConqueGdb_Disable')
    let g:ConqueGdb_Disable = 0
endif

if exists('g:plugin_conque_gdb_loaded') || g:ConqueGdb_Disable
    finish
endif
let g:plugin_conque_gdb_loaded = 1

" Options how to split GDB window when opening new source file
let g:conque_gdb_src_splits = {'below': 'belowright split', 'above': 'aboveleft split', 'right': 'belowright vsplit', 'left': 'leftabove vsplit'}

let g:conque_gdb_default_split = g:conque_gdb_src_splits['above']

if !exists('g:ConqueGdb_SrcSplit')
    let g:ConqueGdb_SrcSplit = 'above'
elseif !has_key(g:conque_gdb_src_splits, g:ConqueGdb_SrcSplit)
    let g:ConqueGdb_SrcSplit = 'above'
    echohl WarningMsg
    echomsg "ConqueGdb: Warning the g:ConqueGdb_SrcSplit option is invalid"
    echomsg "           valid options are: 'below', 'above', 'right' or 'left'"
    echomsg ""
    echohl None
endif

" Option to define path to gdb executable
if !exists('g:ConqueGdb_GdbExe')
    let g:ConqueGdb_GdbExe = ''
endif

" Option to choose leader key to execute gdb commands.
if !exists('g:ConqueGdb_Leader')
    let g:ConqueGdb_Leader = '<Leader>'
endif

" Load python scripts now
call conque_gdb#load_python()

" Keyboard mappings
if g:conque_gdb_gdb_py_support
    if !exists('g:ConqueGdb_ToggleBreak')
        let g:ConqueGdb_ToggleBreak = g:ConqueGdb_Leader . 'b'
    endif
else
    if !exists('g:ConqueGdb_SetBreak')
        let g:ConqueGdb_SetBreak = g:ConqueGdb_Leader . 'b'
    endif
    if !exists('g:ConqueGdb_DeleteBreak')
        let g:ConqueGdb_DeleteBreak = g:ConqueGdb_Leader . 'd'
    endif
endif
if !exists('g:ConqueGdb_Continue')
    let g:ConqueGdb_Continue = g:ConqueGdb_Leader . 'c'
endif
if !exists('g:ConqueGdb_Run')
    let g:ConqueGdb_Run = g:ConqueGdb_Leader . 'r'
endif
if !exists('g:ConqueGdb_Next')
    let g:ConqueGdb_Next = g:ConqueGdb_Leader . 'n'
endif
if !exists('g:ConqueGdb_Step')
    let g:ConqueGdb_Step = g:ConqueGdb_Leader . 's'
endif
if !exists('g:ConqueGdb_Print')
    let g:ConqueGdb_Print = g:ConqueGdb_Leader . 'p'
endif
if !exists('g:ConqueGdb_Finish')
    let g:ConqueGdb_Finish = g:ConqueGdb_Leader . 'f'
endif
if !exists('g:ConqueGdb_Backtrace')
    let g:ConqueGdb_Backtrace = g:ConqueGdb_Leader . 't'
endif
if !exists('g:ConqueGdb_ReadTimeout')
    let g:ConqueGdb_ReadTimeout = 50
endif
if !exists('g:ConqueGdb_SaveHistory')
    let g:ConqueGdb_SaveHistory = 0
endif

" Commands to open conque gdb
command! -nargs=* -complete=file ConqueGdb call conque_gdb#open(<q-args>, [
        \ get(g:conque_gdb_src_splits, g:ConqueGdb_SrcSplit, g:conque_gdb_default_split),
        \ 'buffer ' . bufnr("%"),
        \ 'wincmd w'])
command! -nargs=* -complete=file ConqueGdbSplit call conque_gdb#open(<q-args>, [
        \ 'rightbelow split'])
command! -nargs=* -complete=file ConqueGdbVSplit call conque_gdb#open(<q-args>, [
        \ 'rightbelow vsplit'])
command! -nargs=* -complete=file ConqueGdbTab call conque_gdb#open(<q-args>, [
        \ 'tabnew',
        \ get(g:conque_gdb_src_splits, g:ConqueGdb_SrcSplit, g:conque_gdb_default_split),
        \ 'buffer ' . bufnr("%"),
        \ 'wincmd w'])

" Command to change path to GDB executable at runtime
command! -nargs=? -complete=file ConqueGdbExe call conque_gdb#change_gdb_exe(<q-args>)

" Command to delete the buffers ConqueGdb has opened
command! -nargs=0 ConqueGdbBDelete call conque_gdb#delete_opened_buffers()

" Command to write a command to the gdb tertminal
command! -nargs=+ ConqueGdbCommand call conque_gdb#command(<q-args>)

if g:conque_gdb_gdb_py_support
    exe 'nnoremap <silent> ' . g:ConqueGdb_ToggleBreak . ' :call conque_gdb#toggle_breakpoint(expand("%:p"), line("."))<CR>'
else
    exe 'nnoremap <silent> ' . g:ConqueGdb_SetBreak . ' :call conque_gdb#command("break " . expand("%:p") . ":" . line("."))<CR>'
    exe 'nnoremap <silent> ' . g:ConqueGdb_DeleteBreak . ' :call conque_gdb#command("clear " . expand("%:p") . ":" . line("."))<CR>'
endif
exe 'nnoremap <silent> ' . g:ConqueGdb_Continue . ' :call conque_gdb#command("continue")<CR>'
exe 'nnoremap <silent> ' . g:ConqueGdb_Run . ' :call conque_gdb#command("run")<CR>'
exe 'nnoremap <silent> ' . g:ConqueGdb_Next . ' :call conque_gdb#command("next")<CR>'
exe 'nnoremap <silent> ' . g:ConqueGdb_Step . ' :call conque_gdb#command("step")<CR>'
exe 'nnoremap <silent> ' . g:ConqueGdb_Finish . ' :call conque_gdb#command("finish")<CR>'
exe 'nnoremap <silent> ' . g:ConqueGdb_Backtrace . ' :call conque_gdb#command("backtrace")<CR>'
exe 'nnoremap <silent> ' . g:ConqueGdb_Print . ' :call conque_gdb#print_word(expand("<cword>"))<CR>'
plugin/conque_term.vim	[[[1
241
" FILE:     plugin/conque/conque_term.vim {{{
" AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
" WEBSITE:  http://conque.googlecode.com
" MODIFIED: 2011-09-12
" VERSION:  2.3, for Vim 7.0
" LICENSE:
" Conque - Vim terminal/console emulator
" Copyright (C) 2009-2011 Nico Raffo 
"
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}

" See docs/conque.txt for help or type :help ConqueTerm

if exists('g:ConqueTerm_Loaded') || v:version < 700
    finish
endif

" **********************************************************************************************************
" **** DEFAULT CONFIGURATION *******************************************************************************
" **********************************************************************************************************

" DO NOT EDIT CONFIGURATION SETTINGS IN THIS FILE!
" Define these variables in your local .vimrc to over-ride the default values

" {{{

" Fast mode {{{
" Disables all features which could cause Conque to run slowly, including:
"   * Disables terminal colors
"   * Disables some multi-byte character handling
if !exists('g:ConqueTerm_FastMode')
    let g:ConqueTerm_FastMode = 0
endif " }}}

" automatically go into insert mode when entering buffer {{{
if !exists('g:ConqueTerm_InsertOnEnter')
    let g:ConqueTerm_InsertOnEnter = 0
endif " }}}

" Allow user to use <C-w> keys to switch window in insert mode. {{{
if !exists('g:ConqueTerm_CWInsert')
    let g:ConqueTerm_CWInsert = 0
endif " }}}

" Choose key mapping to leave insert mode {{{
" If you choose something other than '<Esc>', then <Esc> will be sent to terminal
" Using a different key will usually fix Alt/Meta key issues
if !exists('g:ConqueTerm_EscKey')
    let g:ConqueTerm_EscKey = '<Esc>'
endif " }}}

" Key mapping to send interrupt to terminal in insert and normal mode {{{
if !exists('g:ConqueTerm_Interrupt')
    let g:ConqueTerm_Interrupt = '<C-c>'
endif " }}}

" Use this key to execute the current file in a split window. {{{
" THIS IS A GLOBAL KEY MAPPING
if !exists('g:ConqueTerm_ExecFileKey')
    let g:ConqueTerm_ExecFileKey = '<F11>'
endif " }}}

" Use this key to send the current file contents to conque. {{{
" THIS IS A GLOBAL KEY MAPPING
if !exists('g:ConqueTerm_SendFileKey')
    let g:ConqueTerm_SendFileKey = '<F10>'
endif " }}}

" Use this key to send selected text to conque. {{{
" THIS IS A GLOBAL KEY MAPPING
if !exists('g:ConqueTerm_SendVisKey')
    let g:ConqueTerm_SendVisKey = '<F9>'
endif " }}}

" Use this key to toggle terminal key mappings. {{{
" Only mapped inside of Conque buffers.
if !exists('g:ConqueTerm_ToggleKey')
    let g:ConqueTerm_ToggleKey = '<F8>'
endif " }}}

" Enable color. {{{
" If your apps use a lot of color it will slow down the shell.
" 0 - no terminal colors. You still will see Vim syntax highlighting.
" 1 - limited terminal colors (recommended). Past terminal color history cleared regularly.
" 2 - all terminal colors. Terminal color history never cleared.
if !exists('g:ConqueTerm_Color')
    let g:ConqueTerm_Color = 1
endif " }}}

" Color mode. Windows ONLY {{{
" Set this variable to 'conceal' to use Vim's conceal mode for terminal colors.
" This makes colors render much faster, but has some odd baggage.
if !exists('g:ConqueTerm_ColorMode')
    let g:ConqueTerm_ColorMode = ''
endif " }}}

" TERM environment setting {{{
if !exists('g:ConqueTerm_TERM')
    let g:ConqueTerm_TERM =  'vt100'
endif " }}}

" Syntax for your buffer {{{
if !exists('g:ConqueTerm_Syntax')
    let g:ConqueTerm_Syntax = 'conque_term'
endif " }}}

" Keep on updating the shell window after you've switched to another buffer {{{
if !exists('g:ConqueTerm_ReadUnfocused')
    let g:ConqueTerm_ReadUnfocused = 0
endif " }}}

" Use this regular expression to highlight prompt {{{
if !exists('g:ConqueTerm_PromptRegex')
    let g:ConqueTerm_PromptRegex = '^\w\+@[0-9A-Za-z_.-]\+:[0-9A-Za-z_./\~,:-]\+\$'
endif " }}}

" Choose which Python version to attempt to load first {{{
" Valid values are 2, 3 or 0 (no preference)
if !exists('g:ConqueTerm_PyVersion')
    let g:ConqueTerm_PyVersion = 2
endif " }}}

" Path to python.exe. (Windows only) {{{
" By default, Conque will check C:\PythonNN\python.exe then will search system path
" If you have installed Python in an unusual location and it's not in your path, fill in the full path below
" E.g. 'C:\Program Files\Python\Python27\python.exe'
if !exists('g:ConqueTerm_PyExe')
    let g:ConqueTerm_PyExe = ''
endif " }}}

" Automatically close buffer when program exits {{{
if !exists('g:ConqueTerm_CloseOnEnd')
    let g:ConqueTerm_CloseOnEnd = 0
endif " }}}

" Send function key presses to terminal {{{
if !exists('g:ConqueTerm_SendFunctionKeys')
    let g:ConqueTerm_SendFunctionKeys = 0
endif " }}}

" Session support {{{
if !exists('g:ConqueTerm_SessionSupport')
    let g:ConqueTerm_SessionSupport = 0
endif " }}}

" hide Conque startup messages {{{
" messages should only appear the first 3 times you start Vim with a new version of Conque
" and include important Conque feature and option descriptions
" TODO - disabled and unused for now
if !exists('g:ConqueTerm_StartMessages')
    let g:ConqueTerm_StartMessages = 1
endif " }}}

" Windows character code page {{{
" Leave at 0 to use current environment code page.
" Use 65001 for utf-8, although many console apps do not support it.
if !exists('g:ConqueTerm_CodePage')
    let g:ConqueTerm_CodePage = 0
endif " }}}

" InsertCharPre support {{{
" Disable this feature by default, still in Beta
if !exists('g:ConqueTerm_InsertCharPre')
    let g:ConqueTerm_InsertCharPre = 0
endif " }}}

" Don't show 'BELL!' message by default {{{
if !exists('g:ConqueTerm_ShowBell')
    let g:ConqueTerm_ShowBell = 0
endif " }}}

" Option to change update time when conque term is not in focus {{{
" Zero means do not change the update time
if !exists('g:ConqueTerm_UnfocusedUpdateTime')
    let g:ConqueTerm_UnfocusedUpdateTime = 500
endif " }}}

" Option to change update time when conque term is in focus {{{
" Zero means do not change the update time
if !exists('g:ConqueTerm_FocusedUpdateTime')
    let g:ConqueTerm_FocusedUpdateTime = 80
endif " }}}

" }}}

" **********************************************************************************************************
" **** Startup *********************************************************************************************
" **********************************************************************************************************

" Startup {{{

let g:ConqueTerm_Loaded = 1
let g:ConqueTerm_Idx = 0
let g:ConqueTerm_Version = 230

command! -nargs=+ -complete=shellcmd ConqueTerm call conque_term#open(<q-args>)
command! -nargs=+ -complete=shellcmd ConqueTermSplit call conque_term#open(<q-args>, ['belowright split'])
command! -nargs=+ -complete=shellcmd ConqueTermVSplit call conque_term#open(<q-args>, ['belowright vsplit'])
command! -nargs=+ -complete=shellcmd ConqueTermTab call conque_term#open(<q-args>, ['tabnew'])

" }}}

" **********************************************************************************************************
" **** Global Mappings & Autocommands **********************************************************************
" **********************************************************************************************************

" Startup {{{

if exists('g:ConqueTerm_SessionSupport') && g:ConqueTerm_SessionSupport == 1
    autocmd SessionLoadPost * call conque_term#resume_session()
endif

if maparg(g:ConqueTerm_ExecFileKey, 'n') == ''
    exe 'nnoremap <silent> ' . g:ConqueTerm_ExecFileKey . ' :call conque_term#exec_file()<CR>'
endif

" }}}

" Command for pasting contents of previous register.
command! -nargs=0 ConqueTermPaste sil exe ':normal a' . @"

" vim:foldmethod=marker
syntax/conque_term.vim	[[[1
113
" FILE:     syntax/conque_term.vim {{{
" AUTHOR:   Nico Raffo <nicoraffo@gmail.com>
" WEBSITE:  http://conque.googlecode.com
" MODIFIED: 2011-09-12
" VERSION:  2.3, for Vim 7.0
" LICENSE:
" Conque - Vim terminal/console emulator
" Copyright (C) 2009-2011 Nico Raffo 
"
" MIT License
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}


" *******************************************************************************************************************
" MySQL *************************************************************************************************************
" *******************************************************************************************************************

" TODO Move these to syntax which is only executed for mysql
"syn match MySQLTableBodyG "^\s*\w\+:\(.\+\)\=$" contains=MySQLTableHeadG,MySQLNullG,MySQLBool,MySQLNumberG,MySQLStorageClass oneline skipwhite skipnl
"syn match MySQLTableHeadG "^\s*\w\+:" contains=MySQLTableColon skipwhite contained
"syn match MySQLTableColon ":" contained

syn match MySQLTableHead "^ *|.*| *$" nextgroup=MySQLTableDivide contains=MySQLTableBar oneline skipwhite skipnl
syn match MySQLTableBody "^ *|.*| *$" nextgroup=MySQLTableBody,MySQLTableEnd contains=MySQLTableBar,MySQLNull,MySQLBool,MySQLNumber,MySQLStorageClass oneline skipwhite skipnl
syn match MySQLTableEnd "^ *+[+=-]\++ *$" oneline 
syn match MySQLTableDivide "^ *+[+=-]\++ *$" nextgroup=MySQLTableBody oneline skipwhite skipnl
syn match MySQLTableStart "^ *+[+=-]\++ *$" nextgroup=MySQLTableHead oneline skipwhite skipnl
syn match MySQLNull " NULL " contained contains=MySQLTableBar
syn match MySQLStorageClass " PRI " contained
syn match MySQLStorageClass " MUL " contained
syn match MySQLStorageClass " UNI " contained
syn match MySQLStorageClass " CURRENT_TIMESTAMP " contained
syn match MySQLStorageClass " auto_increment " contained
syn match MySQLTableBar "|" contained
syn match MySQLNumber "|\?  *\d\+\(\.\d\+\)\?  *|" contained contains=MySQLTableBar
syn match MySQLQueryStat "^\d\+ rows\? in set.*" oneline
syn match MySQLPromptLine "^.\?mysql> .*$" contains=MySQLKeyword,MySQLPrompt,MySQLString oneline
syn match MySQLPromptLine "^    -> .*$" contains=MySQLKeyword,MySQLPrompt,MySQLString oneline
syn match MySQLPrompt "^.\?mysql>" contained oneline
syn match MySQLPrompt "^    ->" contained oneline
syn case ignore
syn keyword MySQLKeyword select count max sum avg date show table tables status like as from left right outer inner join contained 
syn keyword MySQLKeyword where group by having limit offset order desc asc show contained and interval is null on
syn case match
syn region MySQLString start=+'+ end=+'+ skip=+\\'+ contained oneline
syn region MySQLString start=+"+ end=+"+ skip=+\\"+ contained oneline
syn region MySQLString start=+`+ end=+`+ skip=+\\`+ contained oneline


hi def link MySQLPrompt Identifier
hi def link MySQLTableHead Title
hi def link MySQLTableBody Normal
hi def link MySQLBool Boolean
hi def link MySQLStorageClass StorageClass
hi def link MySQLNumber Number
hi def link MySQLKeyword Keyword
hi def link MySQLString String

" terms which have no reasonable default highlight group to link to
hi MySQLTableHead term=bold cterm=bold gui=bold
if &background == 'dark'
    hi MySQLTableEnd term=NONE cterm=NONE gui=NONE ctermfg=238 guifg=#444444
    hi MySQLTableDivide term=NONE cterm=NONE gui=NONE ctermfg=238 guifg=#444444
    hi MySQLTableStart term=NONE cterm=NONE gui=NONE ctermfg=238 guifg=#444444
    hi MySQLTableBar term=NONE cterm=NONE gui=NONE ctermfg=238 guifg=#444444
    hi MySQLNull term=NONE cterm=NONE gui=NONE ctermfg=238 guifg=#444444
    hi MySQLQueryStat term=NONE cterm=NONE gui=NONE ctermfg=238 guifg=#444444
elseif &background == 'light'
    hi MySQLTableEnd term=NONE cterm=NONE gui=NONE ctermfg=247 guifg=#9e9e9e
    hi MySQLTableDivide term=NONE cterm=NONE gui=NONE ctermfg=247 guifg=#9e9e9e
    hi MySQLTableStart term=NONE cterm=NONE gui=NONE ctermfg=247 guifg=#9e9e9e
    hi MySQLTableBar term=NONE cterm=NONE gui=NONE ctermfg=247 guifg=#9e9e9e
    hi MySQLNull term=NONE cterm=NONE gui=NONE ctermfg=247 guifg=#9e9e9e
    hi MySQLQueryStat term=NONE cterm=NONE gui=NONE ctermfg=247 guifg=#9e9e9e
endif


" *******************************************************************************************************************
" Bash **************************************************************************************************************
" *******************************************************************************************************************

" Typical Prompt
if g:ConqueTerm_PromptRegex != ''
    silent execute "syn match ConquePromptLine '" . g:ConqueTerm_PromptRegex . ".*$' contains=ConquePrompt,ConqueString oneline"
    silent execute "syn match ConquePrompt '" . g:ConqueTerm_PromptRegex . "' contained oneline"
    hi def link ConquePrompt Identifier
endif

" Strings
syn region ConqueString start=+'+ end=+'+ skip=+\\'+ contained oneline
syn region ConqueString start=+"+ end=+"+ skip=+\\"+ contained oneline
syn region ConqueString start=+`+ end=+`+ skip=+\\`+ contained oneline
hi def link ConqueString String

" vim: foldmethod=marker
