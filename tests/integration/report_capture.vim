if !has('gui_running') || !executable('ffmpeg') || !executable('ffprobe')
  throw 'Report capture integration requires a GUI display, ffmpeg and ffprobe'
endif
for s:id in ['screenshot', 'record-gif', 'record-screen']
  let s:extension = s:id ==# 'screenshot' ? 'png' : s:id ==# 'record-gif' ? 'gif' : 'mp4'
  let s:path = g:PV_test_dir .. '/report capture.' .. s:extension
  let s:buffer = planet#testtools#Run(s:id, {'cwd': g:PV_test_dir, 'output': s:path, 'duration': '1'})
  for s:attempt in range(1000)
    if get(planet#term#Result(s:buffer), 'status', '') !=# 'running' | break | endif
    sleep 10m
  endfor
  call assert_equal('success', get(planet#term#Result(s:buffer), 'status', ''), s:id)
  if get(planet#term#Result(s:buffer), 'status', '') !=# 'success'
    call job_stop(term_getjob(s:buffer))
    throw 'Capture failed: ' .. s:id .. ' ' .. string(getbufline(s:buffer, 1, '$'))
  endif
  call assert_true(getfsize(s:path) > 0, s:id .. ' did not produce a report artifact')
  let s:probe = system('ffprobe -v error -show_entries stream=codec_name,width,height -of json ' .. shellescape(s:path))
  call assert_equal(0, v:shell_error)
  let s:streams = json_decode(s:probe).streams
  call assert_true(s:streams[0].width > 0 && s:streams[0].height > 0)
  call assert_equal(s:id ==# 'screenshot' ? 'png' : s:id ==# 'record-gif' ? 'gif' : 'h264', s:streams[0].codec_name)
endfor
