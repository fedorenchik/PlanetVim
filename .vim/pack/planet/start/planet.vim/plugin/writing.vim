scriptversion 4

command! PlanetMarkdownPreview call planet#writing#MarkdownPreview()
command! PlanetLatexBuild call planet#writing#LatexBuild()
command! PlanetWritingOpen call planet#writing#OpenOutput()
command! PlanetWritingErrors call planet#writing#Errors()
command! PlanetGrammarCheck call planet#writing#GrammarCheck()

augroup PlanetVimWriting
  autocmd!
  autocmd FileType markdown,tex,plaintex,text call planet#writing#Setup()
augroup END
