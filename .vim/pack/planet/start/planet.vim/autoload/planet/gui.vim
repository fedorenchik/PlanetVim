scriptversion 4

func! planet#gui#VimServerStart() abort
  if empty(v:servername) && exists('*remote_startserver')
    call remote_startserver('VIM')
    echo 'Started as ' .. v:servername
  else
    echo 'Already started as ' .. v:servername
  end
endfunc

func! planet#gui#MenuListVimServers() abort
  for vs_id in systemlist('vim --serverlist')
    exe 'an 850.200 🗄️&x.&Vim\ Servers.&' .. planet#menu#MenuifyName(vs_id) .. ' <Cmd>TODO<CR>'
  endfor
endfunc
