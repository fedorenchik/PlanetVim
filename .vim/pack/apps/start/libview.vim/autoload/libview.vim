" libview.vim
"   Author: Charles E. Campbell
"   Date:   Jul 08, 2015 - Feb 18, 2016
"   Version: 1l	ASTRO-ONLY
"redraw!|call inputsave()|call input("Press <cr> to continue")|call inputrestore()
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_libview")
 finish
endif
let g:loaded_libview = "v1l"
if v:version < 702
 echohl WarningMsg
 echo "***warning*** this version of libview needs vim 7.2"
 echohl Normal
 finish
endif
let s:keepcpo        = &cpo
set cpo&vim
"DechoTabOn

" =====================================================================
"  Variables: {{{1
if !exists("g:libview_colsize")
 let g:libview_colsize= 25
endif
if !exists("g:libview_cmd")
 let g:libview_cmd= "nm -a --demangle --no-sort --extern-only -l"
endif
let s:lv_colfmt1= '%'.g:libview_colsize.'s'
let s:lv_colfmt2= '%'.(g:libview_colsize-1).'s'

" =====================================================================
" Functions: {{{1

" ---------------------------------------------------------------------
" libview#ABrowse: allows viewing of archives {{{2
fun! libview#ABrowse(libfile)
"  call Dfunc("libview#ABrowse(libfile<".a:libfile.">)")
  
  "  initialization
  let repkeep= &report
  set report=10
  if &ma != 1
   set ma
  endif
  let b:libfile= a:libfile
  let fenkeep  = &fen
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal nowrap
  setlocal nofen
  set ft=libview

  " give header
  let lastline= line("$")
  call setline(lastline+1,'" libview.vim version '.g:loaded_libview)
  call setline(lastline+2,'" Browsing '.((a:libfile =~ '\.a')? "archive" : "???").a:libfile)
  keepj 0d
  $

  " get contents of archive file
"  call Decho("exe silent r! ".g:libview_cmd." -- ".shellescape(b:libfile,1))
  exe "silent r! ".g:libview_cmd." -- ".shellescape(b:libfile,1)
  if v:shell_error != 0
   silent %d _
   redraw!
   echohl WarningMsg | echo "***warning*** (libview#ABrowse) ".b:libfile." is not supported by libview (ie. *.o, *.a, *.so)" | echohl None
"   call Dret("libview#SOBrowse")
   return
  endif

  " modify nm listing
  let title = substitute(a:libfile,'^.*/','','').":"
  let flist = [ substitute(title,'\.o:','.c','') ]
"  call Decho("title<".title.">")
"  call Decho("flist<".string(flist).">")
  3
  while search('^\a','cW')
   let beg   = line(".")
   let end   = search('^[ 0-9]*$','cWn') - 1
   if end <= 0
    let end= line("$")
   endif
   let title = getline(".")
"   call Decho("line(.)=".line(".")." title<".title."> beg#".beg." end#".end)
   let flist= []
   exe "silent ".beg.",".end."g/^[ 0-9]*a\\s/call add(flist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
   let glist= []
   exe "silent ".beg.",".end."g/^[ 0-9]*T\\s/call add(glist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
   let llist= []
   exe "silent ".beg.",".end."g/^[ 0-9]*t\\s/call add(llist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
   " cleanup
   let dottxt= index(llist,'.text')
   if dottxt >= 0
	call remove(llist,dottxt)
   endif
   let vlist= []
   exe "silent ".beg.",".end."g/\\sB\\s/call add(vlist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
"   call Decho("title<".title.">")
"   call Decho("flist ".string(flist))
"   call Decho("glist ".string(glist))
"   call Decho("llist ".string(llist))
"   call Decho("vlist ".string(vlist))

   " determine imax (max length of lists)
   let imax= len(flist)
   if len(glist) > imax | let imax= len(glist) | endif
   if len(llist) > imax | let imax= len(llist) | endif
   if len(vlist) > imax | let imax= len(vlist) | endif
"   call Decho("imax=".imax)

   " generate report
   let i= 0
   let L= beg+1
   call setline(beg,printf(s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.' {'.'{{1',title,"Global Func","Internal Func","Global Var"))
   while i < imax
	call setline(L,printf(s:lv_colfmt2.'  '.s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.'',((i < len(flist))? flist[i] : " "),((i < len(glist))? glist[i] : " "),((i < len(llist))? llist[i] : " "),((i < len(vlist))? vlist[i] : " ")))
	let i= i + 1
	let L= L + 1
   endwhile
   if L <= end
"	call Decho("end-of-block cleanup: exe silent ".L.",".end."d")
	exe "silent ".L.",".end."d"
   endif
  endwhile

  " prepare to return: setting preparation and restoration
  2
  setlocal noma nomod ro fdm=marker
  let &report= repkeep
  let &fen   = fenkeep

"  call Dret("libview#ABrowse")
endfun

" ---------------------------------------------------------------------
" libview#OBrowse: allows browsing of object files {{{2
fun! libview#OBrowse(libfile)
"  call Dfunc("libview#OBrowse(libfile<".a:libfile.">)")
  
  "  initialization
  let repkeep= &report
  set report=10
  if &ma != 1
   set ma
  endif
  let b:libfile= a:libfile
  let fenkeep  = &fen
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal nowrap
  setlocal nofen
  set ft=libview

  " give header
  let lastline= line("$")
  call setline(lastline+1,'" libview.vim version '.g:loaded_libview)
  call setline(lastline+1,'" Browsing '.((a:libfile =~ '\.o')? "object" : "???").": ".a:libfile)
  $put =''
  keepj 0d
  $

  " get contents of object file
"  call Decho("exe silent r! ".g:libview_cmd." -- ".shellescape(b:libfile,1))
  exe "silent r! ".g:libview_cmd." -- ".shellescape(b:libfile,1)
  if v:shell_error != 0
   silent %d _
   redraw!
   echohl WarningMsg | echo "***warning*** (libview#ABrowse) ".b:libfile." is not a libview-supported file" | echohl None
"   call Dret("libview#SOBrowse")
   return
  endif

  " modify nm listing
  let title = substitute(a:libfile,'^.*/','','').":"
  let flist = [ substitute(title,'\.o:','.c','') ]
  3
  let beg = 3
  let end = line("$")

  let flist= []
  exe "silent ".beg.",".end."g/\\sa\\s/call add(flist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
  let glist= []
  exe "silent ".beg.",".end."g/\\sT\\s/call add(glist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
  let llist= []
  exe "silent ".beg.",".end."g/\\st\\s/call add(llist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
  let dottxt= index(llist,'.text')
  if dottxt >= 0
   call remove(llist,dottxt)
  endif
  let vlist= []
  exe "silent ".beg.",".end."g/\\sB\\s/call add(vlist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"

"  call Decho("title<".title.">")
"  call Decho("flist ".string(flist))
"  call Decho("glist ".string(glist))
"  call Decho("llist ".string(llist))
"  call Decho("vlist ".string(vlist))

  " determine imax (max length of lists)
  let imax= len(flist)
  if len(glist) > imax | let imax= len(glist) | endif
  if len(llist) > imax | let imax= len(llist) | endif
  if len(vlist) > imax | let imax= len(vlist) | endif
"  call Decho("imax=".imax)

  " generate report
  silent 3,$d
  let i = 0
  let L= beg + 1
  call setline(beg,printf(s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.' {'.'{{1',title,"Global Func","Internal Func","Global Var"))
  while i < imax
   call setline(L,printf(s:lv_colfmt2.'  '.s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.'',((i < len(flist))? flist[i] : " "),((i < len(glist))? glist[i] : " "),((i < len(llist))? llist[i] : " "),((i < len(vlist))? vlist[i] : " ")))
   let i= i + 1
   let L= L + 1
  endwhile

  " prepare to return: setting preparation and restoration
  2
  setlocal noma nomod ro fdm=marker
  let &report= repkeep
  let &fen   = fenkeep

"  call Dret("libview#OBrowse")
endfun

" ---------------------------------------------------------------------
" libview#SOBrowse: {{{2
fun! libview#SOBrowse(libfile)
"  call Dfunc("libview#SOBrowse(libfile<".a:libfile.">)")

  "  initialization
  let repkeep= &report
  set report=10
  if &ma != 1
   set ma
  endif
  let b:libfile= a:libfile
  let fenkeep  = &fen
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal nowrap
  setlocal nofen
  set ft=libview

  " give header
  let lastline= line("$")
  call setline(lastline+1,'" libview.vim version '.g:loaded_libview)
  call setline(lastline+2,'" Browsing '.((a:libfile =~ '\.so')? "shared lib" : "???").": ".a:libfile)
  $put =''
  keepj 0d
  $

  " get contents of shared library file
"  call Decho("exe silent r! ".g:libview_cmd." -- ".shellescape(b:libfile,1))
  exe "silent r! ".g:libview_cmd." -- ".shellescape(b:libfile,1)
"  call Decho("v:shell_error=".v:shell_error)
  if v:shell_error != 0
   silent %d _
   redraw!
   echohl WarningMsg | echo "***warning*** (libview#ABrowse) ".b:libfile." is not supported by libview (ie. not *.o, *.a, *.so)" | echohl None
"   call Dret("libview#SOBrowse")
   return
  endif

  " modify nm listing
  silent 3,$s/^\x\+\s*//e
  silent 3,$s/^\s\+//e
  silent 3,$g/^\a\s\./d
  silent 3,$g/^\a\s__/d
  silent 3,$g/@@/d
  silent 3,$g/\<call_gmon_start\>/d
  silent 3,$g/\<frame_dummy\>/d
  silent 3,$g/^d\s\+p\.\d\+\>/d
  3
  let begrange= search('^a\>','cW') 
  if begrange > 3
   exe "3,".(begrange-1)."d"
  endif
  3
  let endrange= search('^a\s.*\.','cW') 
  if endrange > 3
   let endrange= endrange - 1
   exe "3,".endrange."d"
   3
  endif
  while search('^a\s.*\.','cW') 
   let begrange = line(".")
"   call Decho("top-of-while: begrange#".begrange."<".getline(begrange)."> endrange#".endrange)
   while begrange <= endrange && getline(begrange) == getline(begrange+1)
    d
   endwhile
   let endrange = search('^a\>','W') - 1
   if endrange <= 0
    let endrange= line("$")
   endif

   " DEBUG
"   call Decho("------  ------  ------ PRELIMINARY begrange=".begrange." endrange=".endrange." line($)=".line("$"))
"   let L= begrange          " Decho
"   while L <= endrange      " Decho
"	call Decho(L.": ".getline(L))
"	let L= L + 1            " Decho
"   endwhile                 " Decho
"   call Decho(L.": ".getline(L)." (starts next block)")
"   call Decho("------  ------  ------ ")

   let title = substitute(getline(begrange),'^\a\s\+','','').":"
"   call Decho("title<".title."> beg#".begrange." end#".endrange." line($)=".line("$"))
   if getline(begrange) !~ '\.'
"	call Decho("skip block<".getline(begrange).">")
	exe endrange
	continue
   endif
"   call Decho("line range: begrange=".begrange."<".getline(begrange)."> endrange=".endrange."<".getline(endrange)."> line($)=".line("$"))
   exe begrange
"   call Decho("begrange#".begrange." line(.)=".line(".")." line($)=".line("$")." line<".getline(begrange).">")
   silent d
"   call Decho("begrange#".begrange." line(.)=".line(".")." line($)=".line("$")." line<".getline(begrange).">")
   let endrange= endrange - 1

   " DEBUG
"   call Decho("------  ------  ------ begrange=".begrange." endrange=".endrange." line($)=".line("$"))
"   let L= begrange          " Decho
"   while L <= endrange      " Decho
"	call Decho(L.": ".getline(L))
"	let L= L + 1            " Decho
"   endwhile                 " Decho
"   call Decho("------  ------  ------ ")

   let flist= []
   let glist= []
   let llist= []
   let vlist= []

   if begrange <= endrange
"    call Decho("exe silent ".begrange.",".endrange."g/^a\\s/call add(flist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))")
    try
     exe "silent ".begrange.",".endrange."g/^a\\s/call add(flist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
    catch /^Vim\%((\a\+)\)\=:E16/
"     call Dret("libview#SOBrowse")
 	return
    endtry
"    call Decho("exe silent ".begrange.",".endrange."g/^T\\s/call add(glist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))")
    exe "silent ".begrange.",".endrange."g/^T\\s/call add(glist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
"    call Decho("exe silent ".begrange.",".endrange."g/^t\\s/call add(llist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))")
    exe "silent ".begrange.",".endrange."g/^t\\s/call add(llist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
  
    " cleanup
    let deltxtlist=[".text","_DYNAMIC","_GLOBAL_OFFSET_TABLE_","_fini","_init"]
    let listlist=["flist","glist","llist"]
    for xlist in listlist
     for deltxt in deltxtlist
      let ideltxt= index({xlist},deltxt)
      if ideltxt >= 0
"      call Decho("1: removing <".deltxt."> from ".xlist." ideltxt=".ideltxt)
       call remove({xlist},ideltxt)
      endif
     endfor
     for deltxt in {xlist}
      if deltxt =~ '\.' || deltxt =~ '^__'
       let ideltxt= index(llist,deltxt)
       if ideltxt >= 0
"       call Decho("2: removing <".deltxt."> from ".xlist." ideltxt=".ideltxt)
        call remove(llist,ideltxt)
       endif
      endif
     endfor
    endfor
  
    exe "silent ".begrange.",".endrange."g/[BCDG]\\s/call add(vlist,substitute(getline('.'),'^.\\{-}\\(\\S\\+\\)$','\\1',''))"
   endif
 
"   call Decho("title<".title.">")
"   call Decho("flist ".string(flist))
"   call Decho("glist ".string(glist))
"   call Decho("llist ".string(llist))
"   call Decho("vlist ".string(vlist))
 
   " determine imax (max length of lists)
   let imax= len(flist)
   if len(glist) > imax | let imax= len(glist) | endif
   if len(llist) > imax | let imax= len(llist) | endif
   if len(vlist) > imax | let imax= len(vlist) | endif
"   call Decho("imax=".imax)
 
   " generate report
   let i = 0
   let L = begrange + 1
   call setline(begrange,printf(s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.' '.s:lv_colfmt1.' {'.'{{1',title,"Global Func","Internal Func","Global Var"))
   while i < imax
    call setline(L,printf("%24S  ".s:lv_colfmt1." ".s:lv_colfmt1." ".s:lv_colfmt1."",((i < len(flist))? flist[i] : " "),((i < len(glist))? glist[i] : " "),((i < len(llist))? llist[i] : " "),((i < len(vlist))? vlist[i] : " ")))
    let i= i + 1
    let L= L + 1
   endwhile
   if L <= endrange
"	call Decho("end-of-block cleanup: exe ".L.",".endrange."d")
	exe "silent ".L.",".endrange."d"
	let begrange= L
   else
    let begrange= endrange + 1
"	call Decho("end-of-block cleanup: simply set begrange= [endrange=".endrange."]+1=".begrange."<".getline(begrange).">  (L=".L.")")
   endif
"   call Decho("begrange=".begrange)

   " DEBUG
"   call Decho("------  ------  ------ SNAPSHOT  1,endrange=".endrange." line($)=".line("$"))
"   let L= 1                 " Decho
"   while L <= endrange      " Decho
"	call Decho(L.": ".getline(L))
"	let L= L + 1            " Decho
"   endwhile                 " Decho
"   call Decho("------  ------  ------ ")
  endwhile

  " prepare to return: setting preparation and restoration
  2
  setlocal noma nomod ro fdm=marker
  let &report= repkeep
  let &fen   = fenkeep
"  call Dret("libview#SOBrowse")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
