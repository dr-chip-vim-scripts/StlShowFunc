" StlShowFunc_dbg.vim :	a ftplugin for DrChip's internal debugger files
" Author:	Charles E. Campbell
" Date:		Feb 04, 2016
" Version:  2h	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if exists("b:loaded_StlShowFunc")
 finish
endif
let b:loaded_StlShowFunc= "v2h"
"DechoRemOn

" ---------------------------------------------------------------------
" StlShowFunc_dbg: show function name associated with line under cursor {{{1
fun! StlShowFunc_dbg()
"  call Dfunc("StlShowFunc_dbg() mode=".mode())
  if mode() != 'n'
"   call Dret("StlShowFunc_dbg")
   return
  endif

  " initialization:
  if !exists("b:showfunc_funcline")
   let b:showfunc_funcline= -2
   let s:funcname            = ""
  endif

  " determine searchpairpos for {}
  let stopline= line(".") - 500
  if stopline <= 0 | let stopline= 1 | endif
  sil! keepj let [funcline,funccol] = searchpairpos('{$','','}\%(\~\d\+\)\=$','Wbn','',stopline)
"  call Decho("funcline=".funcline." funccol=".funccol." b:showfunc_funcline=".b:showfunc_funcline." stopline=".stopline." curline=".line("."))

  if funcline == 0 || funccol == 0
   " occurs when searchpairpos() fails
   let b:showfunc_funcline= -2
   call ShowFunc#Set("")
"   call Dret("StlShowFunc_dbg : b:showfunc_funcline=".b:showfunc_funcline)
   return
  endif

  if funcline != b:showfunc_funcline
   let b:showfunc_funcline= funcline
   let funcname              = substitute(getline(funcline),'^\d*|*\(\h\w*\)(.*$','\1','e')
"   call Decho("funcname<".funcname."> s:funcname<".s:funcname.">")
   if !exists("s:funcname") || funcname != s:funcname
	let s:funcname= funcname
	call ShowFunc#Set(funcname."()")
   endif
  else
   let s:funcname= ""
  endif
"  call Dret("StlShowFunc_dbg : b:showfunc_funcline=".b:showfunc_funcline)
endfun

" ---------------------------------------------------------------------
"  Enable FtPlugin: {{{1
call ShowFunc#Setup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
