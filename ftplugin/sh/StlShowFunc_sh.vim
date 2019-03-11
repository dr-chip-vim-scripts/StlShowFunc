" StlShowFunc_sh.vim :	a ftplugin for Borne shell, Korn/Posix shell, and Bash
" Author:	Charles E. Campbell
" Date:		Apr 03, 2010
" Version:  2f	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Enable Plugin For All Sh FileTypes: {{{1
if &diff
 finish
endif
" ---------------------------------------------------------------------
"  Load Once: {{{1
if exists("b:loaded_StlShowFunc_sh") || !exists("g:loaded_StlShowFunc")
 finish
endif
let b:loaded_StlShowFunc_sh= "v2f"

" ---------------------------------------------------------------------
" StlShowFunc_sh: show function name associated with the line under the cursor {{{1
"DechoTabOn
fun! StlShowFunc_sh()
"  call Dfunc("StlShowFunc_sh() line#" . line(".") . " mode=" . mode())
  let curlinenum = line(".")

  if   mode() != 'n'
  \ || w:bgn_range <= curlinenum && curlinenum <= w:end_range
   " looks like we're in the same region -- no change
"   call Dret("StlShowFunc_sh : no change")
   return
  endif

  let swp = SaveWinPosn(0)
  let bgnfuncline = search('^\s*\h\w*\s*()[[:blank:]\n]*{','bWc')
  let w:bgn_range = bgnfuncline
"  call Decho("preliminary bgnfuncline=" . bgnfuncline)
  if bgnfuncline
   call search('{','W')
   let endfuncline = searchpair('{','','}',"Wn")
   if endfuncline < curlinenum
    let bgnfuncline = 0
    if endfuncline
     let w:bgn_range = endfuncline + 1
    endif
    let endfuncline = search('^\s*\h\w*\s*()[[:blank:]\n]*{','Wn')
    let w:end_range = endfuncline ? endfuncline - 1 : line('$')
   else
    let w:end_range = endfuncline
   endif
  else
   let endfuncline = search('^\s*\h\w*\s*()[[:blank:]\n]*{','Wn')
   let w:end_range = endfuncline ? endfuncline - 1 : line('$')
  endif
  call RestoreWinPosn(swp)
"  call Decho("current  bgn,end[" . w:bgn_range . "," . w:end_range . "]")

  call StlSetFunc( bgnfuncline ? substitute(getline(bgnfuncline), '^\s*\(\h\w*\).*$', '\1', '') : '' )

  " set the status line and return
"  call Dret("StlShowFunc_sh")
endfun

" ---------------------------------------------------------------------
"  Enable FtPlugin: {{{1
call ShowFuncSetup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
