" StlShowFunc_pm.vim :	a ftplugin for Perl
" Author:	Charles E. Campbell
" Date:		Apr 03, 2010
" Version:  2e	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if exists("b:loaded_StlShowFunc")
 finish
endif
let b:loaded_StlShowFunc= "v2e"

" ---------------------------------------------------------------------
" StlShowFunc_perl: show function name associated with the line under the cursor {{{1
"DechoTabOn
fun! StlShowFunc_perl()
"  call Dfunc("StlShowFunc_perl() line#".line(".")." mode=".mode())
  if mode() != 'n'
"   call Dret("StlShowFunc_perl")
   return
  endif
  if !exists("b:showfunc_bgn")
   let b:showfunc_bgn= -2
   let b:showfunc_end= -2
  endif

  if getline(".") =~ '^\s*sub\s'
   let bgnfuncline= line(".")
   if bgnfuncline != 0 && getline(bgnfuncline) =~ '^\s*sub\s\+\h\w*\s*{}\s*$'
    let endfuncline= line(".")
   else
	sil! keepj let endfuncline = search('^\s*}\s*$','Wn')
   endif
  elseif getline(".") =~ '^\s*}\s*$'
   sil! keepj let bgnfuncline = search('^\s*sub\s\+\h\w*\s*[({]','Wbn')
   let            endfuncline = line(".")
  else
   sil! keepj let bgnfuncline = search('^\s*sub\s\+\h\w*\s*[({]','Wbn')
   sil! keepj let endfuncline = search('^\s*}\s*$','Wn')
   if bgnfuncline != 0 && getline(bgnfuncline) =~ '^\s*sub\s\+\h\w*\s*{}\s*$'
   	let endfuncline= bgnfuncline
   endif
  endif
"  call Decho("previous bgn,end[".b:showfunc_bgn.",".b:showfunc_end."]")
"  call Decho("current  bgn,end[".bgnfuncline.",".endfuncline."]")

  if bgnfuncline == b:showfunc_bgn && endfuncline == b:showfunc_end
   " looks like we're in the same region -- no change
"   call Dret("StlShowFunc_perl : no change")
   return
  endif

  let        b:showfunc_bgn = bgnfuncline
  let        b:showfunc_end = endfuncline
  sil! keepj let endprvfuncline = search('^}$','Wbn')
"  call Decho("endprvfuncline=".endprvfuncline)

  if bgnfuncline < endprvfuncline || (endprvfuncline == 0 && bgnfuncline == 0)
   call ShowFunc#Set("")
  else
   let funcline= getline(bgnfuncline)
   if funcline =~ '^\s*sub\s*\h\w*'
   	let funcname= substitute(funcline,'^\s*sub\s*\(\h\w*\).\{-}$','\1','')
"    call Decho("funcname<".funcname.">")
    call ShowFunc#Set(funcname."()")
   endif
  endif

  " set the status line and return
"  call Dret("StlShowFunc_perl")
endfun

" ---------------------------------------------------------------------
"  Enable FtPlugin: {{{1
call ShowFunc#Setup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
