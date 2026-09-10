vim9script
export def CopyFile(file: any): any
  return planet#generate#CopyFile(file)
enddef

export def CopyDir(dir: any): any
  return planet#generate#CopyDir(dir)
enddef
