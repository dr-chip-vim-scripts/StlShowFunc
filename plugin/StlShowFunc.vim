" StlShowFunc.vim : status line show-function script
"   Author: Charles E. Campbell
"   Date:   Sep 24, 2012 - Nov 14, 2018
"   Version: 2t	ASTRO-ONLY
"   Copyright: Charles E. Campbell (09/24/12) (see StlShowFunc.txt for license)
" =====================================================================
" Load Once: {{{1
if &cp || exists("g:loaded_StlShowFunc")
 finish
endif
let s:keepcpo= &cpo
set cpo&vim
let g:loaded_StlShowFunc= "v2t"

" =====================================================================
" Commands: {{{1
com! -bang -nargs=* StlShowFunc	call s:ShowFuncSetup(<bang>1,<f-args>)

" =====================================================================
" Settings:
if !exists("b:stlshowfunc_keep")
 let b:stlshowfunc_keep= &l:stl
endif
if !exists("g:stlshowfunc_stlnofunc")
 let s:stlshowfunc_stlnofunc= '%1*%f%2*  %{&kmp }%h%m%r%0*%=%-14.(%l,%c%V%)%< %P Win#%{winnr()} %{winwidth(0)}x%{winheight(0)} byte#%o %<%{strftime("%a %b %d, %Y, %I:%M:%S %p")}'
else
 let s:stlshowfunc_stlnofunc= g:stlshowfunc_stlnofunc
endif
if !exists("g:stlshowfunc_stlfunc")
 let s:stlshowfunc_stlfunc = '%1*%f %3*%{StlShowFunc()}%2* %{&diff? "DIFF" : ""} %h%m%r%0* %= %-14.(%l,%c%V%)%< %P Win#%{winnr()} %{winwidth(0)}x%{winheight(0)} %<%{strftime("%a %b %d, %Y, %I:%M:%S %p")}'
else
 let s:stlshowfunc_stlfunc = g:stlshowfunc_stlfunc
endif
let &l:stl=s:stlshowfunc_stlnofunc

"  Set up User[1234] highlighting only if they're not already defined. {{{2
hi def User1 ctermfg=white ctermbg=blue guifg=white guibg=blue
hi def User2 ctermfg=cyan  ctermbg=blue guifg=cyan  guibg=blue
hi def User3 ctermfg=green ctermbg=blue guifg=green guibg=blue
hi def User4 ctermfg=red   ctermbg=blue guifg=red   guibg=blue

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" ShowFuncSetup: toggle the display of containing function in the status line {{{2
"    StlShowFunc  [lang] - turn showfunc on
"    StlShowFunc!        - turn showfunc off
"
" TODO: separate Setup() function used by ftplugins and StlShowFunc command
fun! s:ShowFuncSetup(mode,...)
" call Dfunc( "ShowFuncSetup(mode=" . a:mode . ") a:0=" . a:0 )

  let stlhandler = a:0 ? a:1 : &ft
" call Decho( "stlhandler<" . stlhandler . ">" )

  if a:mode
    " turning StlShowFunc mode on

    " add buffer-local autocmd only once
"   call Decho( "StlShowFunc_" . stlhandler . "() " . (exists( "*StlShowFunc_" . stlhandler )? "exists" : "doesn't exist") )
    if empty(getbufvar('', 'autocommands_loaded')) && exists("*StlShowFunc_" . stlhandler)

      " enable StlShowFunc for stlhandler language
"     call Decho( "enabling StlShowFunc_" . stlhandler )
"     call Decho( "exe au CursorMoved " . expand( "%" ) . " call StlShowFunc_" . stlhandler . "()" )
      augroup STLSHOWFUNC
        exe "au CursorMoved <buffer> call StlShowFunc_" . stlhandler . "()"

        " NOTE: sometimes WinEnter executes twice (:bwipeout :next)
        au WinEnter <buffer>
          \ if !exists('w:stlshowfunc') |
          \   let w:stlshowfunc = b:stlshowfunc |
          \   let w:bgn_range = b:bgn_range |
          \   let w:end_range = b:end_range |
          \
          \   unlet b:stlshowfunc b:bgn_range b:end_range |
          \ endif

        " NOTE: sometimes BufWinEnter executes twice
        au BufWinEnter <buffer>
          \ if exists('b:stlshowfunc') |
          \   let w:stlshowfunc = b:stlshowfunc |
          \   let w:bgn_range = b:bgn_range |
          \   let w:end_range = b:end_range |
          \
          \   unlet b:stlshowfunc b:bgn_range b:end_range |
          \ endif

        au WinLeave,BufWinLeave <buffer>
          \ let b:stlshowfunc = w:stlshowfunc |
          \ let b:bgn_range = w:bgn_range |
          \ let b:end_range = w:end_range

        " needed if StlShowFunc was turned off in new buffer
        au BufWinLeave <buffer>
          \ let w:stlshowfunc = ''

        au BufDelete <buffer>
          \ au! STLSHOWFUNC * <buffer=abuf>
          "\ au! STLSHOWFUNC * <buffer>
      augroup END

      let b:autocommands_loaded = 1

      for win_id in win_findbuf(bufnr(''))
        let [tabnr, winnr] = win_id2tabwin(win_id)

        " reset the function
        call settabwinvar(tabnr, winnr, 'stlshowfunc', '')
        call settabwinvar(tabnr, winnr, 'bgn_range', 0)
        call settabwinvar(tabnr, winnr, 'end_range', 0)

        " set up the status line option to show the function
        call settabwinvar(tabnr, winnr, '&stl', s:stlshowfunc_stlfunc)
      endfor

      " recalculate the function for current window
      exe 'call StlShowFunc_' . stlhandler . '()'
    endif

  elseif exists('#STLSHOWFUNC')
   " turning StlShowFunc mode off
   " remove *all* StlShowFunc handlers
"	call Decho("disabling all StlShowFunc_*")
	let &l:stl=b:stlshowfunc_keep
    augroup STLSHOWFUNC
    	au!
    augroup END
    augroup! STLSHOWFUNC
   unlet b:autocommands_loaded
  endif

" call Dret( "ShowFuncSetup" )
endfun

" ---------------------------------------------------------------------
" StlShowFunc: {{{2
fun! StlShowFunc()
  return w:stlshowfunc
endfun

" ---------------------------------------------------------------------
" StlSetFunc: assigns a funcname to a window {{{2
fun! StlSetFunc(funcname)
"  call Dfunc("StlSetFunc(funcname<".a:funcname.">)")
  " set up the window to function name association
  let w:stlshowfunc = a:funcname
"  call Dret("StlSetFunc")
endfun

" =====================================================================
" Modelines: {{{1
" vim: fdm=marker
let &cpo= s:keepcpo
unlet s:keepcpo
