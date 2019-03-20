" StlShowFunc_c.vim :	a ftplugin for C
" Author:	Charles E. Campbell
" Date:		Apr 13, 2016
" Version:  2g	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Don't load if main StlShowFunc isn't available: {{{1
if exists("b:loaded_StlShowFunc") || !exists("g:loaded_StlShowFunc")
 finish
endif
let b:loaded_StlShowFunc= "v2g"

" ---------------------------------------------------------------------
" StlShowFunc_c: show function name associated with the line under the cursor {{{1
"DechoTabOn
fun! StlShowFunc_c()
"  call Dfunc("StlShowFunc_c() line#".line(".")." mode=".mode())
  if mode() != 'n'
"   call Dret("StlShowFunc_c")
   return
  endif
  if !exists("b:showfunc_bgn")
   let b:showfunc_bgn= -2
   let b:showfunc_end= -2
  endif

  keepjumps let bgnfuncline = search('^{\s*\(//.*$\|\/\*.*$\)\=','Wbn')
  keepjumps let endfuncline = search('^}\s*$','Wn')
  if getline(".") =~ '^{$'
   let bgnfuncline= line(".")
  endif
  if getline(".") =~ '^}$'
   let endfuncline= line(".")
  endif
"  call Decho("previous bgn,end[".b:showfunc_bgn.",".b:showfunc_end."]")
"  call Decho("current  bgn,end[".bgnfuncline.",".endfuncline."]")

  if bgnfuncline == b:showfunc_bgn && endfuncline == b:showfunc_end
   " looks like we're in the same region -- no change
"   call Dret("StlShowFunc_c : no change")
   return
  endif

  let b:showfunc_bgn= bgnfuncline
  let b:showfunc_end= endfuncline
  keepjumps let endprvfuncline = search('^}$','Wbn')
"  call Decho("endprvfuncline=".endprvfuncline)

  if bgnfuncline < endprvfuncline || (endprvfuncline == 0 && bgnfuncline == 0)
   call StlSetFunc("")
  else
   keepjumps let swp= SaveWinPosn(0)
   exe "keepjumps ".bgnfuncline
   while 1
   	keepjumps let argend = search(')','Wb')
	if synIDattr(synID(line("."),col("."),1),"name") != 'cComment'
	 break
	endif
	if argend == 0
	 break
	endif
   endwhile
   if argend > 0 && argend > endprvfuncline
   	keepjumps norm! %
	keepjumps let hw= search('\<\h\w*','Wb')
	if hw > 0
	 let funcname= expand("<cword>")
"	 call Decho("funcname<".funcname.">")
	 call StlSetFunc(funcname."()")
	endif
   endif
   call RestoreWinPosn(swp)
  endif

  " set the status line and return
"  call Dret("StlShowFunc_c")
endfun

" ---------------------------------------------------------------------
"  Enable FtPlugin: {{{1
call ShowFuncSetup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
