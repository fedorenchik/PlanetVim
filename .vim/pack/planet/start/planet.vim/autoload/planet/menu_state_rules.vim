vim9script

# Read-only state descriptions. Do not execute a menu RHS to discover its state.
var cache: dict<any> = {}

def Rule(expr: string, kind: string = 'check'): dict<any>
  return {expr: expr, kind: kind}
enddef

def Option(name: string, test: string = '', kind: string = 'check'): dict<any>
  return Rule('exists(' .. string('+' .. name) .. ') ? (' .. (empty(test) ? '&' .. name : test) .. ') : -1', kind)
enddef

def Flag(name: string, value: string): dict<any>
  return Option(name, 'index(split(&' .. name .. ", ','), " .. string(value) .. ') >= 0')
enddef

const keys = {yoc: '&cursorline', yoh: '&hlsearch', yoi: '&ignorecase', yon: '&number',
  yor: '&relativenumber', you: '&cursorcolumn', yov: "&virtualedit ==# 'all'", yow: '&wrap',
  yox: '&cursorline && &cursorcolumn', yos: '&spell', zi: '&foldenable'}
const calls = {
  'planet#editing#AutoSaveToggle()': "get(g:, 'PV_autosave', 0)",
  'planet#tags#ToggleAutoPreview()': "get(g:, 'PV_tags_auto_preview', 0)",
  'planet#windowview#ToggleAutoSave()': "get(g:, 'PV_view_autosave', 0)",
  'planet#windowview#ToggleLocalOptions()': "index(split(&viewoptions, ','), 'localoptions') >= 0",
  'planet#appearance#Ligatures()': "exists('+guiligatures') ? !empty(&guiligatures) : -1",
  'planet#display#Padding()': "exists('+scrolloffpad') ? &scrolloffpad > 0 : -1",
  'planet#gui#Window(''fullscreen'')': "has('patch-9.2.0534') ? stridx(&guioptions, 's') >= 0 : -1",
}

# Most menu actions have no selectable state. Dispatch before applying the
# small catalog's argument patterns, instead of trying every pattern on every
# tool command during startup.
const readers = {
  'planet#preferences#Toggle': true,
  'planet#preferences#Flag': true,
  'planet#preferences#Set': true,
  'planet#menu#Style': true,
  'planet#planet#BasicToggle': true,
  'planet#planet#EditingToggle': true,
  'planet#planet#DevelopmentToggle': true,
  'planet#planet#ToolsToggle': true,
  'planet#planet#NavigationToggle': true,
  'planet#planet#SettingsToggle': true,
  'planet#planet#SetEasyMode': true,
  'planet#planet#SetStandardMode': true,
  'planet#planet#SetSuperChargedMode': true,
  'planet#planet#SetGuiDialogs': true,
  'planet#planet#SetTextDialogs': true,
  'planet#search#Case': true,
  'planet#diff#Whitespace': true,
  'planet#diff#Option': true,
  'planet#git#EnableAutoCommit': true,
  'planet#git#DisableAutoCommit': true,
  'planet#prose#Focus': true,
  'lsp#enable_diagnostics_for_buffer': true,
  'lsp#disable_diagnostics_for_buffer': true,
  'planet#completion#Engine': true,
  'planet#completion#Preset': true,
  'planet#appearance#Theme': true,
  'planet#lsp_display#Set': true,
  'planet#view#Panel': true,
  'planet#display#Popup': true,
  'planet#display#Status': true,
  'planet#fold#EnableAuto': true,
  'planet#fold#DisableAuto': true,
}

def Detect(rhs: string): dict<any>
  if has_key(keys, rhs) | return Rule(keys[rhs]) | endif
  if rhs ==# 'zN' || rhs ==# 'zn' | return Rule(rhs ==# 'zN' ? '&foldenable' : '!&foldenable', 'radio') | endif
  var code = substitute(rhs, '^<Cmd>\|^:', '', '')
  code = substitute(code, '<CR>$', '', '')
  if stridx(code, 'call ') == 0
    var call = strpart(code, 5)
    if has_key(calls, call) | return Rule(calls[call]) | endif
    if !has_key(readers, strpart(call, 0, stridx(call, '('))) | return {} | endif
    var m = matchlist(call, "^planet#preferences#Toggle('\\(\\a\\+\\)'[,)]")
    if !empty(m) | return Option(m[1]) | endif
    m = matchlist(call, "^planet#preferences#Flag('\\(\\a\\+\\)', '\\([^']*\\)'[,)]")
    if !empty(m) | return Flag(m[1], m[2]) | endif
    m = matchlist(call, "^planet#preferences#Set('\\(\\a\\+\\)', \\('[^']*'\\|\\d\\+\\)[,)]")
    if !empty(m)
      var value = m[2]
      if exists('+' .. m[1]) && type(eval('&' .. m[1])) == v:t_bool
        value = value ==# '0' ? 'v:false' : 'v:true'
      endif
      return Option(m[1], '&' .. m[1] .. ' ==# ' .. value, 'radio')
    endif
    m = matchlist(call, "^planet#menu#Style('\\([^']*\\)')$")
    if !empty(m) | return Rule("get(g:, 'PV_menu_style', 'emoji') ==# " .. string(m[1]), 'radio') | endif
    m = matchlist(call, '^planet#planet#\(Basic\|Editing\|Development\|Tools\|Navigation\|Settings\)Toggle()$')
    if !empty(m)
      var group = get({Development: 'dev', Navigation: 'nav'}, m[1], tolower(m[1]))
      return Rule("get(g:, 'PV_menu_style', 'emoji') ==# 'descriptive' ? get(g:, 'PV_menu_group', 'basic') ==# " .. string(group)
        .. " : get(g:, 'PlanetVim_menus_" .. group .. "', 1)", 'group')
    endif
    m = matchlist(call, '^planet#planet#Set\(Easy\|Standard\|SuperCharged\)Mode()$')
    if !empty(m) | return Rule("get(g:, 'PV_mode', 's') ==# " .. string({Easy: 'e', Standard: 's', SuperCharged: 'p'}[m[1]]), 'radio') | endif
    if call ==# 'planet#planet#SetGuiDialogs()' || call ==# 'planet#planet#SetTextDialogs()'
      return Rule("stridx(&guioptions, 'c') " .. (call =~ 'Gui' ? '< 0' : '>= 0'), 'radio')
    endif
    m = matchlist(call, "^planet#search#Case('\\(sensitive\\|ignore\\|smart\\)')$")
    if !empty(m)
      return Rule(m[1] ==# 'sensitive' ? '!&ignorecase' : '&ignorecase && ' .. (m[1] ==# 'smart' ? '&smartcase' : '!&smartcase'), 'radio')
    endif
    m = matchlist(call, "^planet#diff#Whitespace('\\([^']*\\)')$")
    if !empty(m)
      return Rule(m[1] ==# 'exact' ? "&diffopt !~# '\\<iwhite\\%(all\\|eol\\)\\?\\>'"
        : 'index(split(&diffopt, ' .. string(',') .. '), ' .. string(m[1]) .. ') >= 0', 'radio')
    endif
    m = matchlist(call, "^planet#diff#Option('\\(algorithm\\|inline\\|linematch\\|anchor\\)', \\('[^']*'\\|v:null\\))$")
    if !empty(m)
      if m[2] ==# 'v:null'
        return Rule('&diffopt !~# ' .. string('\<' .. m[1] .. '\>'), 'radio')
      endif
      var value = strpart(m[2], 1, strlen(m[2]) - 2)
      var default = get({algorithm: 'myers', inline: 'simple'}, m[1], '')
      return Rule('matchstr(&diffopt, ' .. string('\<' .. m[1] .. ':\zs[^,]*') .. ') ==# ' .. string(value)
        .. (value ==# default ? ' || &diffopt !~# ' .. string('\<' .. m[1] .. ':') : ''), 'radio')
    endif
    if call ==# 'planet#git#EnableAutoCommit()' || call ==# 'planet#git#DisableAutoCommit()'
      return Rule((call =~ 'Disable' ? '!' : '') .. "exists('#AugPv_AutoCommit#BufWritePost')", 'radio')
    endif
    m = matchlist(call, '^planet#prose#Focus(\(v:true\|v:false\))$')
    if !empty(m) | return Rule((m[1] ==# 'v:false' ? '!' : '') .. 'planet#prose#FocusActive()', 'radio') | endif
    if call ==# 'lsp#enable_diagnostics_for_buffer()' || call ==# 'lsp#disable_diagnostics_for_buffer()'
      return Rule((call =~ '#disable' ? '!' : '') .. "get(b:, 'lsp_diagnostics_enabled', 1)", 'radio')
    endif
    m = matchlist(call, "^planet#completion#Engine('\\([^']*\\)')$")
    if !empty(m)
      var native = "(exists('+autocomplete') && &autocomplete)"
      var async = "(get(g:, 'asyncomplete_auto_popup', 1) && get(b:, 'asyncomplete_enable', 1))"
      return Rule(m[1] ==# 'native' ? native : m[1] ==# 'off' ? '!' .. native .. ' && !' .. async : '!' .. native .. ' && ' .. async, 'radio')
    endif
    m = matchlist(call, "^planet#completion#Preset('\\([^']*\\)')$")
    if !empty(m)
      return m[1] ==# 'standard' ? Rule("sort(split(&completeopt, ',')) ==# ['menuone', 'noinsert', 'noselect']", 'radio')
        : Flag('completeopt', m[1])
    endif
    m = matchlist(call, "^planet#appearance#Theme('\\([^']*\\)')$")
    if !empty(m)
      return Rule(m[1] ==# 'system' ? "stridx(&guioptions, 'd') < 0 && get(g:, 'PV_gui_theme', 'system') ==# 'system'"
        : '&background ==# ' .. string(m[1]) .. " && get(g:, 'PV_gui_theme', '') ==# " .. string(m[1]), 'radio')
    endif
    m = matchlist(call, "^planet#lsp_display#Set('\\([^']*\\)', \\([01]\\))$")
    if !empty(m)
      var setting = get({hints: 'PV_inlay_hints', inline: 'PV_inline_diagnostics', signs: 'lsp_diagnostics_signs_enabled', underlines: 'lsp_diagnostics_highlights_enabled'}, m[1], '')
      if !empty(setting)
        return Rule('(get(g:, ' .. string(setting) .. ', ' .. (m[1] ==# 'hints' || m[1] ==# 'inline' ? '0' : '1') .. ') ? 1 : 0) == ' .. m[2], 'radio')
      endif
    endif
    m = matchlist(call, "^planet#view#Panel('show', \\([02]\\))$")
    if !empty(m) | return Option('showtabpanel', '&showtabpanel == ' .. m[1], 'radio') | endif
    m = matchlist(call, "^planet#view#Panel('align', '\\(left\\|right\\)')$")
    if !empty(m) | return Option('tabpanelopt', "get(filter(split(&tabpanelopt, ','), (_, v) => v =~# '^align:'), 0, 'align:left') ==# " .. string('align:' .. m[1]), 'radio') | endif
    m = matchlist(call, "^planet#display#Popup('\\(border\\|opacity\\)', '\\([^']*\\)')$")
    if !empty(m)
      var fallback = m[1] ==# 'opacity' ? 'opacity:100' : 'border:'
      return Option('pumopt', "get(filter(split(&pumopt, ','), (_, v) => v =~# '^" .. m[1] .. ":'), 0, " .. string(fallback) .. ') ==# ' .. string(m[1] .. ':' .. m[2]), 'radio')
    endif
    m = matchlist(call, "^planet#display#Status('\\(multiline\\|clickable\\)')$")
    if !empty(m)
      var line = '%f %h%m%r%=%l:%c %P'
      return m[1] ==# 'multiline'
        ? Option('statuslineopt', "&statuslineopt ==# 'maxheight:2' && &statusline ==# " .. string(line .. '%@%y %{&fileencoding} %{&fileformat}'), 'radio')
        : Rule("has('statusline_click') ? &statusline ==# " .. string('%[planet#display#Click] Find Menu Action %[] ' .. line) .. ' : -1', 'radio')
    endif
    if call ==# 'planet#fold#EnableAuto()' || call ==# 'planet#fold#DisableAuto()'
      return Rule('&foldclose ==# ' .. string(call =~ 'Enable' ? 'all' : '') .. ' && &foldlevelstart == ' .. (call =~ 'Enable' ? 0 : 20), 'radio')
    endif
  endif
  if code ==# 'PlanetNativeTabs on' || code ==# 'PlanetNativeTabs off'
    return Rule((code =~ ' off$' ? '!' : '') .. "get(g:, 'PV_native_tabs_active', 0)", 'radio')
  endif
  if code ==# 'EditorConfigEnable' || code ==# 'EditorConfigDisable'
    return Rule((code =~ 'Disable' ? '!' : '') .. "exists('#editorconfig#BufReadPost')", 'radio')
  endif
  if code ==# 'let b:EditorConfig_disable=1'
    return Rule("get(b:, 'EditorConfig_disable', 0)")
  endif
  if code =~# '^syn\%(tax\)\? \%(on\|enable\)$'
    return Rule("exists('g:syntax_on') && !exists('g:syntax_manual')", 'radio')
  elseif code =~# '^syn\%(tax\)\? manual$'
    return Rule("exists('g:syntax_manual')", 'radio')
  elseif code =~# '^syn\%(tax\)\? off$'
    return Rule("!exists('g:syntax_on')", 'radio')
  elseif code =~# '^if exists("g:syntax_on") '
    return Rule("exists('g:syntax_on')")
  endif
  if code ==# 'VerbosityToggle' | return Rule('&verbose > 0') | endif
  if code =~# '^let &l:iminsert ='
    return Rule('&iminsert == 1')
  endif
  var colors = matchstr(code, '\<colorscheme \zs\w\+\ze$')
  if !empty(colors)
    var bg = matchstr(code, '\<bg=\zs\w\+')
    return Rule("get(g:, 'colors_name', '') ==# " .. string(colors) .. (empty(bg) ? '' : ' && &background ==# ' .. string(bg)), 'radio')
  endif
  # Literal :set toggles and presets only. Prompts, queries and arithmetic
  # changes (e.g. foldcolumn+=1) are actions, not selectable states.
  if code =~# '^set\%(local\|global\)\? '
    var clauses: list<string> = []
    var toggle = false
    for token in split(substitute(code, '^\S\+\s\+', '', ''))
      if token =~# '?$' | continue | endif
      var m = matchlist(token, '^\(\a\+\)=\([[:alnum:]_,]*\)$')
      if !empty(m)
        var literal = m[2] =~# '^\d\+$' ? m[2] : string(m[2])
        add(clauses, 'exists(' .. string('+' .. m[1]) .. ') && &' .. m[1] .. ' ==# ' .. literal)
        continue
      endif
      m = matchlist(token, '^\(\a\+\)\([!]\)\?$')
      if empty(m) | return {} | endif
      var name = m[1]
      var negative = name =~# '^no' && exists('+' .. strpart(name, 2))
      if negative | name = strpart(name, 2) | endif
      if !exists('+' .. name) | return {} | endif
      toggle = toggle || !empty(m[2])
      add(clauses, (negative ? '!' : '') .. '&' .. name)
    endfor
    if !empty(clauses) | return Rule(join(clauses, ' && '), toggle ? 'check' : 'radio') | endif
  endif
  return {}
enddef

export def For(rhs: string): dict<any>
  if !has_key(cache, rhs) | cache[rhs] = Detect(rhs) | endif
  return cache[rhs]
enddef
