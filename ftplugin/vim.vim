" StlShowFunc_vim.vim :	a ftplugin for  vim
" Author:	Charles E. Campbell
" Date:		Apr 03, 2010
" Version:  2e	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
"  don't process command-line window
if exists("b:loaded_StlShowFunc") || !exists("g:loaded_StlShowFunc") || !empty( getcmdwintype() )
 finish
endif
let b:loaded_StlShowFunc= "v2e"

" ---------------------------------------------------------------------
" StlShowFunc_vim: show function name associated with the line under the cursor {{{1
"DechoTabOn
fun! StlShowFunc_vim()
"  call Dfunc("StlShowFunc_vim() line#".line(".")." mode=".mode())
  if mode() != 'n'
"   call Dret("StlShowFunc_vim")
   return
  endif
  if !exists("b:showfunc_bgn")
   let b:showfunc_bgn= -2
   let b:showfunc_end= -2
"   call Decho("init b:showfunc_bgn and b:showfunc_end")
  endif

  sil! keepj let bgnfuncline = search('^\s*fu\%[nction]\>','Wbn')
  sil! keepj let endfuncline = search('^\s*endf\%[unction]\>','Wn')
  if getline(".") =~ '^\s*fu\%[nction]\>'
   let bgnfuncline= line(".")
  endif
  if getline(".") =~ '^\s*endf\%[unction]\>'
   let endfuncline= line(".")
  endif
"  call Decho("previous bgn,end[".b:showfunc_bgn.",".b:showfunc_end."]")
"  call Decho("current  bgn,end[".bgnfuncline.",".endfuncline."]")
"  call Decho((bgnfuncline == b:showfunc_bgn)? "[bgnfuncline".bgnfuncline."] == [b:showfunc_bgn=".b:showfunc_bgn."]" : "[bgnfuncline=".bgnfuncline."] != [b:showfunc_bgn=".b:showfunc_bgn."]")
"  call Decho((endfuncline == b:showfunc_end)? "[endfuncline".endfuncline."] == [b:showfunc_end=".b:showfunc_end."]" : "[endfuncline=".endfuncline."] != [b:showfunc_end=".b:showfunc_end."]")

  if bgnfuncline == b:showfunc_bgn && endfuncline == b:showfunc_end
   " looks like we're in the same region -- no change
"   call Dret("StlShowFunc_vim : no change")
   return
  endif

  let            b:showfunc_bgn= bgnfuncline
  let            b:showfunc_end= endfuncline
  sil! keepj let endprvfuncline   = search('^\s*endf\%[unction]\>','Wbn')
"  call Decho("[bgnfuncline=".bgnfuncline."]".((bgnfuncline < endprvfuncline)? "<" : "≮")."[endprvfuncline=".endprvfuncline."]")

  if bgnfuncline < endprvfuncline || (endprvfuncline == 0 && bgnfuncline == 0)
"   call Decho('calling StlSetFunc("") (case 1)')
   call StlSetFunc("")
  else
   " extract the function name from the bgnfuncline
   let funcline= getline(bgnfuncline)
"   call Decho("extract function name from bgnfuncline#".bgnfuncline."<".funcline.">")
   if funcline =~ '^\s*fu\%[nction]!\=\s\+\(\%([sS]:\|<[sS][iI][dD]>\)\=\h[a-zA-Z0-9_#]*\).\{-}$'
    let funcname= substitute(funcline,'^\s*fu\%[nction]!\=\s\+\(\%([sS]:\|<[sS][iI][dD]>\)\=\h[a-zA-Z0-9_#]*\).\{-}$','\1','')
"	call Decho('calling StlSetFunc('.funcname.'()')
    call StlSetFunc(funcname."()")
   else
"    call Decho('calling StlSetFunc("") (case 2)')
    call StlSetFunc("")
   endif
  endif

  " set the status line and return
"  call Dret("StlShowFunc_vim")
endfun

" ---------------------------------------------------------------------
"  Plugin Enabling: {{{1
call ShowFuncSetup()

" ---------------------------------------------------------------------
"  Modelines: {{{1
" vim: fdm=marker
