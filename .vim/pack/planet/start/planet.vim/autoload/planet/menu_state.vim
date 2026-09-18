vim9script

# Translation aliases retain canonical :emenu paths while decorating labels.
# All state readers are supplied by the first-party catalog, never menu actions.
var entries: dict<any> = {}
var orders: dict<string> = {}
var heads: dict<any> = {}
var counters: dict<number> = {}
var aliases: dict<string> = {}
var errors: dict<string> = {}
var busy = false
var updates = 0
const translations = has('multi_lang')

export def Begin()
  entries = {}
  orders = {}
  counters = {}
  aliases = {}
  errors = {}
enddef

def Parts(path: string): list<string>
  if stridx(path, '\.') < 0 | return split(path, '\.', true) | endif
  return split(path, '\%(\\.\|[^.\\]\)\+\zs\.', true)
enddef

def Base(path: string): string
  if stridx(path, '<Tab>') < 0 && stridx(path, "\t") < 0 | return path | endif
  return split(path, '\\\@<!<Tab>\|\t', true)[0]
enddef

def Lookup(path: string): string
  return substitute(path, '&&\|&', (m) => m[0] ==# '&&' ? '&' : '', 'g')
enddef

def Managed(path: string): bool
  return translations && stridx(path, 'PopUp.') != 0 && stridx(path, 'WinBar.') != 0 && stridx(path, ']PVTab.') != 0
enddef

export def Order(head: string, path: string): string
  if !Managed(path) | return head | endif
  var keypath = Base(path)
  if !has_key(heads, head)
    var priority = matchstr(head, '\d\+\%(\.\d\+\)*\s*$')
    heads[head] = {prefix: empty(priority) ? head : strpart(head, 0, strlen(head) - strlen(priority)),
      numbers: empty(priority) ? [] : split(trim(priority), '\.')}
  endif
  var parsed = heads[head]
  if has_key(orders, keypath) | return parsed.prefix .. orders[keypath] .. ' ' | endif
  var parts = Parts(keypath)
  if len(parts) < 2 | return head | endif
  var order = get(parsed.numbers, 0, '500')
  var parent = parts[0]
  for depth in range(1, len(parts) - 1)
    var key = parent .. '.' .. parts[depth]
    if !has_key(orders, key)
      var value = get(parsed.numbers, depth, '500')
      var bucket = parent .. '\n' .. value
      counters[bucket] = get(counters, bucket, 0) + 1
      # Distinct priorities let a changed leaf keep its original sibling order.
      orders[key] = order .. '.' .. (str2nr(value) * 10000 + counters[bucket])
    endif
    order = orders[key]
    parent = key
  endfor
  return parsed.prefix .. order .. ' '
enddef

def Mark(rule: dict<any>): string
  try
    var value = eval(rule.expr)
    if type(value) == v:t_number && value < 0 | return '' | endif
    var radio = rule.kind ==# 'radio' || (rule.kind ==# 'group' && get(g:, 'PV_menu_style', 'emoji') ==# 'descriptive')
    return radio ? (value ? '●' : '○') : (value ? '☑' : '☐')
  catch
    # Unsupported options and unavailable plugin state have no false checkmark.
    errors[rule.expr] = v:exception
    return ''
  endtry
enddef

def Translate(path: string, mark: string): string
  var parts = Parts(path)
  var name = remove(parts, -1)
  var key = mark .. '\n' .. path
  if !has_key(aliases, key)
    var label = Base(name)
    var from = label .. '<Tab>PV-state-' .. (len(aliases) + 1)
    var to = empty(mark) ? name : mark .. '\ ' .. name
    execute 'menutrans ' .. from .. ' ' .. to
    aliases[key] = from
  endif
  return join(parts + [aliases[key]], '.')
enddef

export def Definition(head: string, path: string, rhs: string): string
  var key = Base(path)
  if !Managed(key) | return head .. path .. ' ' .. rhs | endif
  if !has_key(entries, key)
    var rule = planet#menu_state_rules#For(rhs)
    if empty(rule) | return head .. path .. ' ' .. rhs | endif
    entries[key] = {path: path, priority: trim(matchstr(head, '\d\+\%(\.\d\+\)*\s*$')), rule: rule, mark: Mark(rule)}
  endif
  return head .. Translate(entries[key].path, entries[key].mark) .. ' ' .. rhs
enddef

export def Refresh()
  if busy || empty(entries) | return | endif
  busy = true
  var previous_error = v:errmsg
  try
    for [key, item] in items(entries)
      var mark = Mark(item.rule)
      if mark ==# item.mark | continue | endif
      var path = Lookup(key)
      var modes: dict<any> = {}
      for m in ['n', 'x', 's', 'o', 'i', 'c', 'tl', 't']
        var info = menu_info(path, m)
        if has_key(info, 'rhs') | modes[m] = info | endif
      endfor
      if empty(modes) | continue | endif
      if len(filter(keys(modes), (_, m) => m !=# 'tl' && m !=# 't')) > 0
        execute 'aunmenu ' .. key
      endif
      if has_key(modes, 'tl') | execute 'tlunmenu ' .. key | endif
      var translated = Translate(item.path, mark)
      for [m, info] in items(modes)
        var command = m ==# 't' ? 'tmenu' : m .. (info.noremenu ? 'noremenu' : 'menu')
        var flags = m ==# 't' ? '' : (info.silent ? '<silent> ' : '') .. (info.script ? '<script> ' : '')
        execute command .. ' ' .. flags .. item.priority .. ' ' .. translated .. ' ' .. escape(info.rhs, '|')
        if m !=# 't' && !info.enabled | execute m .. 'menu disable ' .. key | endif
      endfor
      item.mark = mark
      updates += 1
    endfor
  finally
    v:errmsg = previous_error
    busy = false
  endtry
enddef

export def Stats(): dict<number>
  return {entries: len(entries), updates: updates, aliases: len(aliases), errors: len(errors)}
enddef

augroup PlanetMenuState
  autocmd!
  autocmd OptionSet * Refresh()
  autocmd WinEnter,BufEnter,TabEnter,ColorScheme,VimEnter,SafeState * Refresh()
augroup END
