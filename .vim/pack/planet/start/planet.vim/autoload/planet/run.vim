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
