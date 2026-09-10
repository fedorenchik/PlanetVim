vim9script

# Metadata changes the displayed accelerator and native menu tip, never the
# mapping. Execute the returned definition in the caller's script context.
var registry: dict<any> = {}
var reverse_maps: dict<string> = {}
var alternate_maps: dict<string> = {}

def CanonicalKeys(value: string): string
  if stridx(value, '<') < 0
    return value
  endif
  return substitute(value, '<[^>]\+>', (m) => toupper(m[0]), 'g')
enddef

def ExCommand(rhs: string): string
  var start = stridx(rhs, '<Cmd>')
  # Most first-party entries are one literal <Cmd> action. Avoid repeated
  # regular-expression parsing for that common case; retain the general path
  # for chained commands, expression registers and special-key arguments.
  if start == 0 && strpart(rhs, strlen(rhs) - 4) ==# '<CR>' && count(rhs, '<') == 2
    return ':' .. trim(strpart(rhs, 5, strlen(rhs) - 9))
  endif
  var text = ''
  if rhs =~# '^q:i'
    return ':' .. trim(substitute(strpart(rhs, 3), '\c<C-X>.*$', '', ''))
  endif
  if start >= 0
    text = ':' .. strpart(rhs, start + 5)
  else
    text = substitute(rhs, '\c^\%(<C-C>\|<Esc>\|<C-\\><C-O>\|<C-O>\)\+', '', '')
    if text !~# '^:'
      return ''
    endif
    text = substitute(text, '\c^:<C-U>', ':', '')
  endif
  if stridx(text, '<Bar>') >= 0
    text = substitute(text, '<Bar>', '|', 'g')
  endif
  if stridx(text, '<CR><Cmd>') >= 0 || stridx(text, '<CR>:') >= 0
    text = substitute(text, '<CR>\%(<Cmd>\|:\)', ' | ', 'g')
  endif
  text = substitute(text, '\c<Space>', ' ', 'g')
  var finish = match(text, '\c<CR>\|<C-Z>')
  return trim(finish < 0 ? text : strpart(text, 0, finish))
enddef

export def Begin()
  # Root menus will be rebuilt; keep independent context and window-bar tips.
  filter(registry, (_, item) => item.path =~# '^\%(PopUp\|WinBar\)\.')
  Reset()
enddef

export def Reset()
  reverse_maps = {}
  alternate_maps = {}
  for mapping in maplist()
    if get(mapping, 'expr', 0) || get(mapping, 'buffer', 0) || mapping.lhs =~? '<Plug>\|<SNR>' || mapping.mode !~# '[n ]'
      continue
    endif
    var command = ExCommand(mapping.rhs)
    if empty(command) || get(reverse_maps, command, '') ==# mapping.lhs
      continue
    endif
    if !has_key(reverse_maps, command) || strchars(mapping.lhs) < strchars(reverse_maps[command])
      if has_key(reverse_maps, command)
        alternate_maps[command] = reverse_maps[command]
      endif
      reverse_maps[command] = mapping.lhs
    elseif !has_key(alternate_maps, command) || strchars(mapping.lhs) < strchars(alternate_maps[command])
      alternate_maps[command] = mapping.lhs
    endif
  endfor
enddef

# Explicit native equivalents: no synthetic :normal wrappers for motions or
# operators, since those should teach the keys and their meaning instead.
const commands = {
  'u': ':undo', '<C-R>': ':redo', '<C-G>': ':file', 'ga': ':ascii', 'Q': ':ex', 'gQ': ':exim', '<C-W>n': ':new',
  '<C-W>s': ':split', '<C-W>v': ':vsplit', '<C-W>c': ':close',
  '<C-W>o': ':only', '<C-W>s<C-W>T': ':split | wincmd T', '<C-W>z': ':pclose', 'gt': ':tabnext', 'gT': ':tabprevious',
  'zo': ':foldopen', 'zO': ':foldopen!', 'zc': ':foldclose', 'zC': ':foldclose!',
  '<C-T>': ':pop', '<C-Z>': ':suspend', '<C-^>': ':buffer #',
  '&': ':&', 'do': ':diffget', 'dp': ':diffput', 'g-': ':earlier', 'g+': ':later',
  'zn': ':set nofoldenable', 'zN': ':set foldenable', 'zi': ':set foldenable!',
}

var native_shortcuts: dict<string> = {}
for [keys, command] in items(commands)
  native_shortcuts[command] = keys
endfor

def NativeCommand(rhs: string): string
  var keys = CanonicalKeys(substitute(rhs, '\\|', '|', 'g'))
  if has_key(commands, keys)
    return commands[keys]
  endif
  if keys =~# '^<C-W>g\?.$'
    return ':wincmd ' .. strpart(keys, 5)
  endif
  return ''
enddef

def Shortcut(command: string): string
  if has_key(reverse_maps, command)
    return reverse_maps[command]
  endif
  return get(native_shortcuts, command, '')
enddef

def ResolvedCommand(rhs: string, remap: bool, depth: number = 0): string
  var command = ExCommand(rhs)
  if !empty(command)
    return command
  endif
  if remap && depth < 8
    var lookup = substitute(rhs, '\c<Leader>', escape(get(g:, 'mapleader', '\'), '\\&'), 'g')
    var mapping = maparg(lookup, 'n', false, true)
    var suffix = ''
    if empty(mapping)
      # Prefix mappings (yo + c, m + 1) consume the remaining typed keys.
      for length in reverse(range(1, strchars(lookup) - 1))
        mapping = maparg(strcharpart(lookup, 0, length), 'n', false, true)
        if !empty(mapping)
          suffix = strcharpart(lookup, length)
          break
        endif
      endfor
    endif
    if !empty(mapping)
      var mapped = substitute(mapping.rhs, '\c<SID>', '<SNR>' .. mapping.sid .. '_', 'g')
      if get(mapping, 'expr', 0)
        # Describe the expression without evaluating it or triggering the action.
        if mapped =~# '^\%(<SNR>\d\+_\|[a-zA-Z_]\)[a-zA-Z0-9_#]*([^\r\n]*)$'
          return ':call ' .. mapped
        endif
      else
        var resolved = ResolvedCommand(mapped .. suffix, !mapping.noremap || mapped =~? '<Plug>', depth + 1)
        if !empty(resolved)
          return resolved
        endif
      endif
    endif
  endif
  return NativeCommand(rhs)
enddef

def EscapeLabel(text: string): string
  # Menu paths interpret only <Tab>; other angle-bracket keys stay literal.
  return substitute(escape(text, " .\\|\t"), '\c<Tab>', '\\<Tab>', 'g')
enddef

def PlainPath(path: string): string
  var plain = substitute(path, '\c<Tab>.*$', '', '')
  plain = substitute(plain, '\\\(.\)', '\1', 'g')
  return substitute(plain, '&&\|&', (m) => m[0] ==# '&&' ? '&' : '', 'g')
enddef

export def Describe(rhs: string, path: string): string
  return planet#menu_descriptions#Describe(rhs, PlainPath(path))
enddef

export def Explain(rhs: string, path: string, remap: bool = false): dict<string>
  var command = ResolvedCommand(rhs, remap)
  return {command: command, tip: empty(command) ? '" ' .. Describe(rhs, path) : command}
enddef

def Accelerator(rhs: string, annotations: list<string>, command: string): string
  var direct = rhs !~? '<Cmd>\|<Plug>\|<SNR>' && rhs !~# ':' && !empty(rhs)
  if !direct && empty(annotations) && stridx(command, ':call ') == 0 && !has_key(reverse_maps, command)
    return ''
  endif
  var keys: list<string> = []
  # Existing annotations also document mode-specific and pending-motion keys.
  for annotation in annotations
    var key = substitute(annotation, '\\\(.\)', '\1', 'g')
    if !empty(key) && key !~# '^:' && index(keys, key) < 0
      add(keys, key)
    endif
  endfor
  var primary = direct ? rhs : Shortcut(command)
  primary = substitute(primary, '\c<Leader>', escape(get(g:, 'mapleader', '\'), '\&'), 'g')
  if primary =~? '<CR>'
    primary = ''
  endif
  if !empty(primary)
    # Prefer the exact action's keys; expand old shorthand such as +c.
    var same = index(map(copy(keys), (_, v) => CanonicalKeys(v)), CanonicalKeys(primary))
    if same >= 0
      remove(keys, same)
    elseif !empty(keys) && (empty(command) || ResolvedCommand(keys[-1], true) !=# command)
      # Replace stale hints, but retain a verified alternative such as +c.
      remove(keys, -1)
    endif
  elseif !empty(keys)
    primary = remove(keys, -1)
  endif
  var secondary = empty(keys) ? '' : keys[0]
  if empty(secondary) && !empty(primary) && !empty(command)
    for mapped in [Shortcut(command), get(alternate_maps, command, ''), get(native_shortcuts, command, '')]
      if !empty(mapped) && CanonicalKeys(mapped) !=# CanonicalKeys(primary)
        secondary = mapped
        break
      endif
    endfor
  endif
  if empty(secondary)
    secondary = command
  endif
  if empty(primary)
    var existing = filter(copy(annotations), (_, v) => v =~# '^:')
    primary = empty(existing) ? command : substitute(existing[-1], '\\\(.\)', '\1', 'g')
    secondary = ''
  endif
  # Full function calls and lengthy command lines are always available in tips.
  if strdisplaywidth(primary) > 36 || primary =~? '^:\%(call\|cal\|execute\|exe\|if\|let\|for\|while\|try\)\>'
    return ''
  endif
  if !empty(secondary) && secondary !=# primary && strdisplaywidth(secondary .. '  ' .. primary) <= 36
    return EscapeLabel(secondary) .. '<Tab>' .. EscapeLabel(primary)
  endif
  return EscapeLabel(primary)
enddef

export def Definition(spec: string): string
  if strpart(spec, strlen(spec) - 5) ==? '<Nop>'
    return spec
  endif
  var sid = ''
  var head = matchstr(spec, '\%#=1^\s*\S\+\s\+\%(<[^>]\+>\s\+\)*\%(\d\+\%(\.\d\+\)*\s\+\)\?')
  if empty(head)
    return spec
  endif
  var tail = strpart(spec, strlen(head))
  if tail =~# '^\%(enable\|disable\)\s'
    return spec
  endif
  var path = matchstr(tail, '\%#=1^\%(\\.\|[^[:space:]]\)\+')
  var rhs = trim(strpart(tail, strlen(path)), ' ', 1)
  if empty(rhs) || rhs ==? '<Nop>' || path =~# '\.-[^.]*-$'
    return spec
  endif
  var name = split(head)[0]
  var remap = index(['am', 'amenu', 'menu', 'nmenu', 'vmenu', 'xmenu', 'smenu', 'omenu', 'imenu', 'cmenu', 'tlmenu'], name) >= 0
  var original = path
  var parts = stridx(path, '<Tab>') < 0 && stridx(path, "\t") < 0 ? [path] : split(path, '\\\@<!<Tab>\|\t', true)
  path = parts[0]
  var key = (stridx(path, 'WinBar.') == 0 ? win_getid() .. ':' : '') .. path
  # A native item has one accelerator and one tip shared by all editing modes.
  var preferred = name =~# '^\%(an\|am\|n\)'
  if !preferred && has_key(registry, key) && registry[key].normal
    return spec .. PopupRefresh(original)
  endif
  var info = Explain(rhs, path, remap)
  var accelerator = Accelerator(rhs, parts[1 :], info.command)
  if !empty(accelerator) && stridx(path, 'WinBar.') != 0
    path ..= '<Tab>' .. accelerator
  endif
  registry[key] = {path: original, rhs: rhs, remap: remap, sid: sid, normal: preferred}
  var tip = substitute(info.tip, '\c<SID>', sid, 'g')
  tip = TipText(tip)
  return head .. path .. ' ' .. rhs .. "\ntmenu " .. original .. ' ' .. tip
    .. (rhs =~? '\c<SID>' ? "\ncall planet#menu_help#ScriptTip(" .. string(key) .. ')' : '') .. PopupRefresh(original)
enddef

def TipText(tip: string): string
  # tmenu still parses Ex separators. Display a literal pipe, never execute it.
  return escape(tr(tip, "\r\n\t", '   '), '|')
enddef

export def ScriptTip(key: string)
  var item = registry[key]
  var actual = menu_info(LookupPath(item.path))
  if empty(actual)
    actual = menu_info(LookupPath(item.path), '!')
  endif
  item.sid = matchstr(get(actual, 'rhs', ''), '<SNR>\d\+_')
  execute 'tmenu ' .. item.path .. ' ' .. TipText(substitute(Explain(item.rhs, item.path, item.remap).tip, '\c<SID>', item.sid, 'g'))
enddef

def LookupPath(path: string): string
  var base = split(path, '\\\@<!<Tab>\|\t', true)[0]
  return substitute(base, '&&\|&', (m) => m[0] ==# '&&' ? '&' : '', 'g')
enddef

export def RefreshTips()
  Reset()
  for item in values(registry)
    if !item.remap || item.path =~# '^WinBar\.'
      continue
    endif
    # Paths are canonical and still resolve through menutrans. Do not recreate
    # a hidden group or a removed dynamic item just to add a tooltip.
    if empty(menu_info(LookupPath(item.path))) && empty(menu_info(LookupPath(item.path), '!'))
      continue
    endif
    var tip = Explain(item.rhs, item.path, item.remap).tip
    execute 'tmenu ' .. item.path .. ' ' .. TipText(substitute(tip, '\c<SID>', item.sid, 'g'))
  endfor
enddef


def PopupRefresh(path: string): string
  return stridx(path, 'PopUp.') == 0 ? "\ncall planet#menu_help#PopupTips(" .. string(path) .. ')' : ''
enddef

export def PopupTips(path: string)
  # GVim displays a separate native PopUp menu for each editing mode. tmenu on
  # PopUp alone does not propagate to those copies, unlike action definitions.
  for [suffix, mode] in [['n', 'n'], ['v', 'x'], ['s', 's'], ['o', 'o'], ['i', 'i'], ['c', 'c'], ['tl', 't']]
    var clone = 'PopUp' .. suffix .. strpart(path, 5)
    var actual = menu_info(LookupPath(clone), mode)
    if empty(actual) || empty(get(actual, 'rhs', ''))
      continue
    endif
    var command = mode ==# 'n' ? ResolvedCommand(actual.rhs, !actual.noremenu) : ExCommand(actual.rhs)
    var tip = empty(command) ? '" ' .. planet#menu_descriptions#Context(actual.rhs, PlainPath(clone), mode) : command
    execute 'tmenu ' .. clone .. ' ' .. TipText(tip)
  endfor
enddef
