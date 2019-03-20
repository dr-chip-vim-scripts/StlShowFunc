" StlShowFunc_cpp.vim :	a ftplugin for C++
" Author:	Charles E. Campbell, Jr.
" Date:		Sep 09, 2010
" Version:  2k	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Don't load if main StlShowFunc isn't available: {{{1
if exists("b:loaded_StlShowFunc") || !exists("g:loaded_StlShowFunc")
 finish
endif
let b:loaded_StlShowFunc= "v2k"

" ---------------------------------------------------------------------
" StlShowFunc_cpp: show function name associated with the line under the cursor {{{1
"DechoTabOn
fun! StlShowFunc_cpp()
"  call Dfunc("StlShowFunc_cpp() line#".line(".")." mode=".mode())
  if mode() != 'n'
"   call Dret("StlShowFunc_cpp")
   return
  endif
  if !exists("b:showfunc_bgn")
   let b:showfunc_bgn= -2
   let b:showfunc_end= -2
  endif
"  call Decho("b:showfunc_bgn=".b:showfunc_bgn." b:showfunc_end=".b:showfunc_end)

  keepj let swp= SaveWinPosn(0)
  while 1
   keepj let spline= searchpair(')\_s*\%(const\_s*\|volatile\_s*\|/\*.*\*/\_s*\|//.*\_s*\)\{,2}{','','}','bW')
"   call Decho("spline=".spline)
   if spline <= 0
	call StlSetFunc("")
   	break
   endif
   if synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") == "Comment"
	if line(".") == 1
"	 call Decho("case comment in line#1:")
     call StlSetFunc("")
   	 break
	endif
	keepj norm! 0k
	continue
   endif
"   call Decho("after searchpair: line#".line(".").".".col(".")." spline=".spline)
   silent! keepj norm! %b
"   call Decho("after %b        : line#".line(".").".".col(".")." potential-funcname<".expand("<cword>").">")
   if expand("<cword>") !~ '\<\%(if\|for\|try\|catch\|while\|switch\|else\|do\)\>'
	let funcname= expand("<cword>")
"	call Decho("funcname<".funcname.">")
	call StlSetFunc(funcname."()")
	break
   endif
  endwhile
"  call Decho("swp<".swp.">")
  keepjumps call RestoreWinPosn(swp)

  " set the status line and return
"  call Dret("StlShowFunc_cpp : line#".line(".")." col#".col('.'))
endfun

" ---------------------------------------------------------------------
"  Enable FtPlugin: {{{1
call ShowFuncSetup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
