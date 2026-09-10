vim9script
export def TutorCommand(): any
  return [v:progpath, '-g', '-f', '-Nu', 'NONE', '-U', 'NONE', '-i', 'NONE', '-n', '-S', planet#paths#Root() .. '/.vim/pack/planet/start/planet.vim/bin/tutor.vim']
enddef

export def Tutor(): any
  return planet#term#RunGuiApp(planet#learn#TutorCommand())
enddef

export def Help(arg_topic: any = v:null): any
  var topic: any = arg_topic == null ? planet#prompt#Ask('Search Vim help: ', '', 'help') : arg_topic
  if topic == null || empty(topic)
    return 0
  endif
  execute 'help ' .. escape(topic, ' |')
  return 1
enddef

export def Vim9(): any
  tabnew
  setlocal buftype=nofile bufhidden=hide noswapfile filetype=vim
  setline(1, ['vim9script', '', '# Edit this scratch example, then choose Compile/Run Scratch Example.',
       'def Greet(name: string): string', '  return $"Hello, {name}!"', 'enddef', '', 'echo Greet("PlanetVim")'])
  b:PV_vim9_lesson = 1
  setlocal nomodified
  return 0
enddef

export def RunVim9(): any
  if !get(b:, 'PV_vim9_lesson', 0)
    echomsg 'PlanetVim: open the Vim9 scratch example first'
    return 0
  endif
  # The user explicitly runs the editable lesson; no automatic sourcing.
  source
  return 1
enddef

export def Menus(): any
  PlanetMenu an 990.12 ❔&?.Interactive\ Tutor\ (new\ GVim) <Cmd>call planet#learn#Tutor()<CR>
  PlanetMenu an 990.12 ❔&?.User\ Manual <Cmd>help usr_toc<CR>
  PlanetMenu an 990.12 ❔&?.Search\ Help <Cmd>call planet#learn#Help()<CR>
  PlanetMenu an 990.12 ❔&?.What's\ New\ in\ This\ Vim <Cmd>help news<CR>
  PlanetMenu an 990.12 ❔&?.PlanetVim\ Guide <Cmd>execute 'tab sview ' .. fnameescape(planet#paths#Root() .. '/docs/GUIDE.md')<CR>
  PlanetMenu an 990.13 ❔&?.Vim9.Learn\ Vim9\ Script <Cmd>help vim9<CR>
  PlanetMenu an 990.13 ❔&?.Vim9.Classes <Cmd>help vim9-class<CR>
  PlanetMenu an 990.13 ❔&?.Vim9.Open\ Scratch\ Example <Cmd>call planet#learn#Vim9()<CR>
  PlanetMenu an 990.13 ❔&?.Vim9.Compile/Run\ Scratch\ Example <Cmd>call planet#learn#RunVim9()<CR>
  return 0
enddef
