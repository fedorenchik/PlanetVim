" Hints are presentation only; native mappings, flags and script context survive.
aunmenu *
silent! tlunmenu *
call planet#menu_help#Reset()
PlanetMenu an 10 Teaching.Undo u
PlanetMenu an 20 Teaching.Next<Tab><C-PgDown><Tab>gt gt
PlanetMenu an 30 Teaching.Minimize<Tab>:suspend<Tab><C-z> <C-z>
PlanetMenu an 40 Teaching.First\ Line gg
PlanetMenu an 50 Teaching.Text\ Object viw
PlanetMenu an 60 Teaching.Tab<Tab>g\<Tab\> g<Tab>
call assert_equal(":undo\tu", menu_info('Teaching.Undo').accel)
call assert_equal("<C-PgDown>\tgt", menu_info('Teaching.Next').accel)
call assert_equal(":suspend\t<C-z>", menu_info('Teaching.Minimize').accel)
call assert_equal('gg', menu_info('Teaching.First Line').accel)
call assert_equal('g<Tab>', menu_info('Teaching.Tab').accel)
call assert_match(':undo', execute('tmenu Teaching.Undo'))
call assert_match('" Move to the first line', execute('tmenu Teaching.First\ Line'))
call assert_match('" Select the word contents', execute('tmenu Teaching.Text\ Object'))

" A short mapped shortcut wins over the command; retain up to two shortcuts.
nnoremap zx <Cmd>buffers<CR>
call planet#menu_help#Reset()
PlanetMenu an 70 Teaching.Buffers<Tab>:buffers <Cmd>buffers<CR>
PlanetMenu an 80 Teaching.Alternates<Tab>[*<Tab>[/<Tab>ignored [/
call assert_equal(":buffers\tzx", menu_info('Teaching.Buffers').accel)
call assert_equal("[*\t[/", menu_info('Teaching.Alternates').accel)

" Adding a tip must not execute any of its text, or change an action's escaping.
PlanetMenu nnoremenu <silent> 90 Teaching.Pipe\|Dots\.\ &&\ 汉字 <Cmd>let g:PV_menu_help_ran = 1<Bar>let g:PV_menu_help_more = 2<CR>
call assert_false(exists('g:PV_menu_help_ran'))
let s:path = 'Teaching.Pipe|Dots\. & 汉字'
let s:info = menu_info(s:path)
call assert_equal('<Cmd>let g:PV_menu_help_ran = 1|let g:PV_menu_help_more = 2<CR>', s:info.rhs)
call assert_true(s:info.silent)
call assert_true(s:info.noremenu)
call assert_match(':let g:PV_menu_help_ran = 1|let g:PV_menu_help_more = 2', execute('tmenu Teaching.Pipe\|Dots\.\ &&\ 汉字'))
emenu Teaching.Pipe\|Dots\.\ &&\ 汉字
call assert_equal(2, g:PV_menu_help_more)

function! s:Action() abort
  let g:PV_menu_help_local = 1
endfunction
PlanetMenu nnoremenu <script> 100 Teaching.Local <Cmd>call <SID>Action()<CR>
let s:info = menu_info('Teaching.Local')
call assert_true(s:info.script)
call assert_match(':call ' .. matchstr(s:info.rhs, '<SNR>\d\+_') .. 'Action()', execute('tmenu Teaching.Local'))
emenu Teaching.Local
call assert_equal(1, g:PV_menu_help_local)
unlet g:PV_menu_help_local
execute planet#menu_help#Entry('nnoremenu <script> 105 ', 'Teaching.CompiledLocal', '<Cmd>call <SID>Action()<CR>')
let s:info = menu_info('Teaching.CompiledLocal')
call assert_true(s:info.script)
call assert_match(':call ' .. matchstr(s:info.rhs, '<SNR>\d\+_') .. 'Action()', execute('tmenu Teaching.CompiledLocal'))
emenu Teaching.CompiledLocal
call assert_equal(1, g:PV_menu_help_local)

" Mode overrides retain their actions; the shared tip teaches the Normal action.
PlanetMenu an 110 Teaching.Modes <Cmd>echo 'normal'<CR>
PlanetMenu inoremenu 110 Teaching.Modes <Cmd>echo 'insert'<CR>
PlanetMenu vnoremenu 110 Teaching.Modes <Cmd>echo 'visual'<CR>
call assert_equal("<Cmd>echo 'insert'<CR>", menu_info('Teaching.Modes', 'i').rhs)
call assert_equal("<Cmd>echo 'visual'<CR>", menu_info('Teaching.Modes', 'x').rhs)
call assert_match(":echo 'normal'", execute('tmenu Teaching.Modes'))
PlanetMenu an 120 Teaching.Select\ Then\ Command V<Cmd>call planet#search#Sort('numeric')<CR>
call assert_match(":call planet#search#Sort('numeric')", execute('tmenu Teaching.Select\ Then\ Command'))

" Late plugin mappings refresh tips without recreating hidden/removed items.
PlanetMenu nmenu 130 Teaching.Late zP
nnoremap zP <Cmd>echo 'late plugin command'<CR>
an disable Teaching.Modes
anoremenu Teaching.Placeholder <Nop>
call planet#menu_help#RefreshTips()
call assert_match(":echo 'late plugin command'", execute('tmenu Teaching.Late'))
call assert_false(menu_info('Teaching.Modes').enabled)
aunmenu Teaching.Late
call planet#menu_help#RefreshTips()
call assert_equal({}, menu_info('Teaching.Late'))

" Two real shortcuts take precedence over a command in the middle column.
nnoremap zy <Cmd>buffers<CR>
call planet#menu_help#Reset()
PlanetMenu an 140 Teaching.TwoMaps <Cmd>buffers<CR>
call assert_match('^z[xy]\tz[xy]$', menu_info('Teaching.TwoMaps').accel)
call assert_notequal(split(menu_info('Teaching.TwoMaps').accel, "\t")[0], split(menu_info('Teaching.TwoMaps').accel, "\t")[1])
PlanetMenu nnoremenu 150 Teaching.EscapedPipe :let g:PV_menu_help_escaped = 1 \| let g:PV_menu_help_escaped_more = 2<CR>
call assert_false(exists('g:PV_menu_help_escaped_more'))
PlanetMenu nmenu 160 Teaching.Lowercase zL
nnoremap zL :<c-u>echo 'lowercase'<cr>
call planet#menu_help#RefreshTips()
call assert_match(":echo 'lowercase'", execute('tmenu Teaching.Lowercase'))

" Right-click menus use GVim's separate per-mode copies.
PlanetMenu nnoremenu PopUp.TestCopy <Cmd>echo 'normal'<CR>
PlanetMenu vnoremenu PopUp.TestCopy "+y
PlanetMenu cnoremenu PopUp.TestCopy <C-Y>
call assert_match(":echo 'normal'", execute('tmenu PopUpn.TestCopy'))
call assert_match('Copy the selected text', execute('tmenu PopUpv.TestCopy'))
call assert_match('Accept the selected command-line completion', execute('tmenu PopUpc.TestCopy'))

" Accelerator text is after the mnemonic portion: literal & must not double.
PlanetMenu an 170 Teaching.Repeat &
PlanetMenu an 180 Teaching.KeepFlags <Cmd>&&<CR>
call assert_equal(":&\t&", menu_info('Teaching.Repeat').accel)
call assert_equal(':&&', menu_info('Teaching.KeepFlags').accel)

" Tooltip mode is t; terminal mode is tl. Tips must never become actions.
PlanetMenu tlnoremenu 190 Teaching.Terminal <Cmd>echo 'terminal action'<CR>
tmenu Teaching.TipOnly :quit
let s:index = planet#action_index#Build('Teaching', 'Teaching', 'basic')
let s:undo = filter(copy(s:index), 'v:val.path ==# "Teaching.Undo"')[0]
call assert_false(has_key(s:undo.modes, 't'))
call assert_equal([], filter(copy(s:index), 'v:val.path ==# "Teaching.TipOnly"'))
let s:terminal = filter(copy(s:index), 'v:val.path ==# "Teaching.Terminal"')[0]
call assert_equal(['t'], keys(s:terminal.modes))
call assert_equal("<Cmd>echo 'terminal action'<CR>", s:terminal.modes.t.rhs)
PlanetMenu tlnoremenu PopUp.TerminalStop <C-W><C-C>
call assert_match('Force the job', menu_info('PopUptl.TerminalStop', 't').rhs)
