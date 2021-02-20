source common.vim

silent edit test-listings.tex

if empty($INMAKE) | finish | endif

call vimtex#test#assert(vimtex#syntax#in('texFileArg', 7, 28))
call vimtex#test#assert(vimtex#syntax#in('texLstZoneInline', 9, 14))

call vimtex#test#assert(vimtex#syntax#in('texLstZone', 15, 1))
call vimtex#test#assert(vimtex#syntax#in('texLstZoneC', 23, 1))
call vimtex#test#assert(vimtex#syntax#in('texLstZonePython', 30, 1))
call vimtex#test#assert(vimtex#syntax#in('texLstZoneRust', 36, 1))

call vimtex#test#assert(vimtex#syntax#in('texLstsetGroup', 42, 10))

quit!
