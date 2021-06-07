scriptversion 4

if ! exists('g:PV_run_configurations')
  let g:PV_run_configurations = ''
end

func! planet#run#InitRunConfigurations() abort
  if empty(g:PV_run_configurations)
    return
  end
  let l:conf_list = split(g:PV_run_configurations, ',')
  for run_conf in l:conf_list
    exe 'an 510.100 ▶️&r.' .. planet#menu#MenuifyName(run_conf) .. ' <Cmd>call planet#term#RunCmd("' .. run_conf .. '", v:false, v:false, v:false, "' .. g:PV_build_dir .. '")<CR>'
  endfor
endfunc

func! planet#run#AddConfig() abort
  let l:config_to_add = input('Please type binary with arguments (relative to build directory): ')
  if empty(l:config_to_add)
    return
  end
  let g:PV_run_configurations ..= ',' .. l:config_to_add
  exe 'an 510.100 ▶️&r.' .. planet#menu#MenuifyName(l:config_to_add) .. ' <Cmd>call planet#term#RunCmd("' .. l:config_to_add .. '", v:false, v:false, v:false, "' .. g:PV_build_dir .. '")<CR>'
endfunc

func! planet#run#EditConfig() abort
  let l:ret = inputdialog("Run configs: ", g:PV_run_configurations, 'CANCELLED')
  if l:ret == 'CANCELLED'
    return
  end
  let g:PV_run_configurations = l:ret
  call planet#run#UpdateRunMenu()
endfunc

func! planet#run#UpdateRunMenu() abort
  aunmenu ▶️&r
    an 510.10  ▶️&r.Run <Nop>
    an disable ▶️&r.Run
    call planet#run#InitRunConfigurations()
    an 510.500 ▶️&r.--1-- <Nop>
    an 510.500 ▶️&r.Add\ Run\ Configuration                 <Cmd>call planet#run#AddConfig()<CR>
    an 510.500 ▶️&r.Edit\ Run\ Configurations               <Cmd>call planet#run#EditConfig()<CR>
endfunc
