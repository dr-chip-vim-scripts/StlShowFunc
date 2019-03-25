" StlShowFunc_m.vim :	an ftplugin for matlab
" Author:	Charles E. Campbell
" Date:		Apr 03, 2010
" Version:  2d	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if exists("b:loaded_StlShowFunc")
 finish
endif
let b:loaded_StlShowFunc= "v2d"

" ---------------------------------------------------------------------
" StlShowFunc_matlab: show function name associated with the line under the cursor {{{1
"DechoTabOn
fun! StlShowFunc_matlab()
"  call Dfunc("StlShowFunc_matlab() line#".line(".")." mode=".mode())
  if mode() != 'n'
"   call Dret("StlShowFunc_matlab")
   return
  endif
  if !exists("b:showfunc_bgn")
   let b:showfunc_bgn= -2
   let b:showfunc_end= -2
  endif

  sil! keepj let bgnfuncline = search('^\s*function\>','Wbn')
  sil! keepj let endfuncline = search('^\s*\%(end\)\=function\>','Wn')
  if getline(".") =~ '^\s*function\>'
   let bgnfuncline= line(".")
   let endfuncline= bgnfuncline
  endif
  if getline(".") =~ '^\s*endfunction\>'
   let endfuncline= line(".")
  endif
"  call Decho("previous bgn,end[".b:showfunc_bgn.",".b:showfunc_end."]")
"  call Decho("current  bgn,end[".bgnfuncline.",".endfuncline."]")

  if bgnfuncline == b:showfunc_bgn && endfuncline == b:showfunc_end
   " looks like we're in the same region -- no change
"   call Dret("StlShowFunc_matlab : no change")
   return
  endif

  let            b:showfunc_bgn = bgnfuncline
  let            b:showfunc_end = endfuncline
  sil! keepj let endprvfuncline  = search('^\s*endfunction\>','Wbn')
"  call Decho("endprvfuncline=".endprvfuncline)

  if bgnfuncline < endprvfuncline || (endprvfuncline == 0 && bgnfuncline == 0)
   call ShowFunc#Set("")
  else
   " extract the function name from the bgnfuncline
   let funcline= getline(bgnfuncline)
   if funcline =~ '^\s*function\s\+\%(.\{-}=\s*\)\=\h\w*\s*('
    let funcname= substitute(funcline,'^\s*function\s\+\%(.\{-}=\s*\)\=\(\h\w*\)\s*(.*$','\1','')
"   call Decho("funcname<".funcname.">")
    call ShowFunc#Set(funcname."()")
   else
    call ShowFunc#Set("")
   endif
  endif

  " set the status line and return
"  call Dret("StlShowFunc_matlab")
endfun

" ---------------------------------------------------------------------
"  Plugin Enabling: {{{1
call ShowFunc#Setup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
