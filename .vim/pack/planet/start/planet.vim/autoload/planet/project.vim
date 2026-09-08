scriptversion 4

func! planet#project#CopyFile(file) abort
  return planet#generate#CopyFile(a:file)
endfunc

func! planet#project#CopyDir(dir) abort
  return planet#generate#CopyDir(a:dir)
endfunc
