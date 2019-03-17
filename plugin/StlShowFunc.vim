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

" ---------------------------------------------------------------------
" StlShowFunc: toggle the display of containing function in the status line {{{2
"
com StlShowFunc	call s:command()

" =====================================================================
" Settings:
let s:stlshowfunc_stlfunc = exists("g:stlshowfunc_stlfunc") ?
  \ g:stlshowfunc_stlfunc :
  \ '%f %([%{StlShowFunc()}] %)%h%m%r%=%-14.(%l,%c%V%) %P'

"  Set up User[1234] highlighting only if they're not already defined. {{{2
hi def User1 ctermfg=white ctermbg=blue guifg=white guibg=blue
hi def User2 ctermfg=cyan  ctermbg=blue guifg=cyan  guibg=blue
hi def User3 ctermfg=green ctermbg=blue guifg=green guibg=blue
hi def User4 ctermfg=red   ctermbg=blue guifg=red   guibg=blue

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" ShowFuncSetup: setup buffer for the function calculation {{{2
"
fun ShowFuncSetup(...)
  if !a:0
    " first run by ftplugin, needs init
    let w:stlshowfunc = ''
    let w:bgn_range = 0
    let w:end_range = 0

    " set up the status line option to show the function
    let &l:stl = s:stlshowfunc_stlfunc
  endif

  let bufnr = a:0 ? a:1 : bufnr('')

  " enable StlShowFunc for &filetype language
" call Decho( "enabling StlShowFunc_" . getbufvar(bufnr, '&ft') )
" call Decho( "exe au CursorMoved " . expand( "%" ) . " call StlShowFunc_" . getbufvar(bufnr, '&ft') . "()" )
  augroup STLSHOWFUNC
    exe 'au CursorMoved <buffer=' . bufnr . '> call StlShowFunc_' . getbufvar(bufnr, '&ft') . '()'

    " NOTE: sometimes WinEnter executes twice (:bwipeout :next)
    exe 'au WinEnter <buffer=' . bufnr . '>
      \ if !exists("w:stlshowfunc") |
      \   let w:stlshowfunc = b:stlshowfunc |
      \   let w:bgn_range = b:bgn_range |
      \   let w:end_range = b:end_range |
      \
      \   unlet b:stlshowfunc b:bgn_range b:end_range |
      \ endif'

    " NOTE: sometimes BufWinEnter executes twice
    exe 'au BufWinEnter <buffer=' . bufnr . '>
      \ if exists("b:stlshowfunc") |
      \   let w:stlshowfunc = b:stlshowfunc |
      \   let w:bgn_range = b:bgn_range |
      \   let w:end_range = b:end_range |
      \
      \   unlet b:stlshowfunc b:bgn_range b:end_range |
      \ endif'

    exe 'au WinLeave,BufWinLeave <buffer=' . bufnr . '>
      \ let b:stlshowfunc = w:stlshowfunc |
      \ let b:bgn_range = w:bgn_range |
      \ let b:end_range = w:end_range'

    " needed if StlShowFunc was turned off in new buffer
    "au BufWinLeave <buffer>
    "  \ let w:stlshowfunc = ''

    exe 'au BufDelete <buffer=' . bufnr . '>
      \ au! STLSHOWFUNC * <buffer=abuf>'
  augroup END

  call setbufvar(bufnr, 'autocommands_loaded', 1)

" call Dret( "ShowFuncSetup" )
endfun

" ---------------------------------------------------------------------
" command: toggle StlShowFunc mode for all handled buffers {{{2
"
fun s:command()
  if exists('#STLSHOWFUNC')
    " turning StlShowFunc mode off

    " remove StlShowFunc handlers
"   call Decho( "disabling all StlShowFunc_*" )
    au! STLSHOWFUNC
    augroup! STLSHOWFUNC

    " reset buffers-local 'autocommands_loaded' flag and status lines of theirs windows (if any)
    for bufnr in filter( range(1, bufnr('$')), '!empty(getbufvar(v:val, "autocommands_loaded"))' )
      for win_id in win_findbuf(bufnr)
        let [tabnr, winnr] = win_id2tabwin(win_id)
        call settabwinvar(tabnr, winnr, '&stl', '')
      endfor
    endfor

  else
    " turning StlShowFunc mode on

    let win_saved = win_getid()

    " add buffer-local autocmd only once
    for bufnr in filter( range(1, bufnr('$')), '!empty(getbufvar(v:val, "autocommands_loaded"))' )
      call ShowFuncSetup(bufnr)

      for win_id in win_findbuf(bufnr)
        call win_gotoid(win_id)

        " reset the function
        let w:stlshowfunc = ''
        let w:bgn_range = 0
        let w:end_range = 0

        " set up the status line option to show the function
        let &l:stl = s:stlshowfunc_stlfunc

        " recalculate the function for processed window
"       call Decho( "call StlShowFunc_" . &ft . "()" )
        exe 'call StlShowFunc_' . &ft . '()'
      endfor
    endfor

    win_gotoid(win_saved)

  endif
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
