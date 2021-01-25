" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowInit")
  finish
endif
let g:barowInit = 1

function! Bufname()
  let bufname = bufname("%")
  if bufname("%") == ""
    return ""
  endif
  return split(bufname, "/")[-1]
endfunction

function! ReadOnly()
  let filetype = getbufvar("%", "&filetype")
  if (&readonly || !&modifiable) && filetype !~? 'help\|man'
    return "ro"
  endif
  return ""
endfunction

function! BufChanged()
  let bufinfo = get(getbufinfo("%"), 0, { 'changed': 0 })
  if bufinfo.changed
    return "*"
  endif
  return ""
endfunction

function! Mode()
  let mode = mode()
  if mode =~? '^n'
    return " "
  elseif mode =~? '^i'
    return "i"
  elseif mode =~# '^R'
    return "r"
  elseif mode ==# 'v'
    return "v"
  elseif mode ==# 'V'
    return "l"
  elseif mode == ''
    return "b"
  elseif mode =~? '^c'
    return "c"
  elseif mode == 't'
    return "t"
  elseif mode == '!'
    return "!"
  elseif mode =~? '^r'
    return "p"
  elseif mode =~? '^s\|'
    return "s"
  endif
  return mode
endfunction

function! SetModeHi()
  let mode = Mode()
  if mode == "i"
    hi link BarowMod BarowInsert
  elseif mode == "r"
    hi link BarowMod BarowReplace
  elseif mode =~? 'v\|b\|l'
    hi link BarowMod BarowVisual
  elseif mode =~? 'c\|!'
    hi link BarowMod BarowCommand
  elseif mode == "t"
    hi link BarowMod BarowTerminal
  else
    hi link BarowMod BarowNormal
  endif
  return ""
endfunction

function! IsTabChanged(n)
  let buflist = tabpagebuflist(a:n)
  for i in buflist
    let bufinfo = get(getbufinfo(i), 0, { 'changed': 0 })
    if bufinfo.changed
      return 1
    endif
  endfor
  return 0
endfunction

function! TabLabel(n)
  let winnr = tabpagewinnr(a:n)
  let winid = win_getid(winnr, a:n)
  let bufname = bufname(winbufnr(winid))
  if empty(bufname)
    return a:n
  endif
  return split(bufname, "/")[-1]
endfunction

function! SetStatusLine()
  let modeFormat = " %{SetModeHi()}%#BarowMod#%1.1{Mode()}%*"
  let modeFormatInactive = "  "
  let spacer = "%="
  let lineInfo = "%4.9l:%-3.9c %3.3p%% "
  for n in range(1, winnr('$'))
    if n == winnr()
      let bufName = " %#BarowBufName#%2.50{Bufname()}%*"
      let ro = " %#BarowRO#%{ReadOnly()}%*"
      let bufChanged = " %#BarowChange#%1.1{BufChanged()}%*"
      call setwinvar(n, '&statusline', modeFormat.bufName.ro.bufChanged.spacer.lineInfo)
    else
      let bufName = " %#BarowBufNameNC#%2.50{Bufname()}%*"
      let ro = " %#BarowRONC#%{ReadOnly()}%*"
      let bufChanged = " %#BarowChangeNC#%1.1{BufChanged()}%*"
      call setwinvar(n, '&statusline', modeFormatInactive.bufName.ro.bufChanged.spacer.lineInfo)
    endif
  endfor
endfunction

function! SetTabLine()
  let s = ''
  for i in range(1, tabpagenr('$'))
    if i == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= ' %'.i.'T%1.20{TabLabel('.i.')}'
    if IsTabChanged(i)
      if i == tabpagenr()
        let s .= '%#BarowTChange#*'
      else
        let s .= '%#BarowTChangeNC#*'
      endif
    else
      let s.= ' '
    endif
    let s .= '%T'
  endfor
  let s .= '%#TabLineFill#'
  return s
endfunction

set tabline=%!SetTabLine()
augroup barow
  autocmd!
  autocmd VimEnter,BufEnter,BufDelete,WinEnter,TabEnter,TabLeave,TabNew,TabNewEntered,TabClosed,TermEnter,TermLeave * call SetStatusLine()
augroup END

function s:Hi(group, fg, ...)
  " arguments: group, fg, bg, style
  if a:0 >= 1
    let bg=a:1
  else
    let bg=s:p.null
  endif
  if a:0 >= 2 && strlen(a:2)
    let style=a:2
  else
    let style='NONE'
  endif
  let hiList = [
        \ 'hi', a:group,
        \ 'ctermfg=' . a:fg[1],
        \ 'guifg=' . a:fg[0],
        \ 'ctermbg=' . bg[1],
        \ 'guibg=' . bg[0],
        \ 'cterm=' . style,
        \ 'gui=' . style
        \ ]
  execute join(hiList)
endfunction

let s:p={
      \ 'null': ['NONE', 'NONE'],
      \ 'statusLine': ['#313335', 237],
      \ 'statusLineFg': ['#BBBBBB', 250],
      \ 'statusLineNC': ['#787878', 243],
      \ 'tabLineFg': ['#A9B7C6', 145],
      \ 'tabLineSel': ['#4E5254', 239],
      \ 'UIBlue': ['#3592C4', 67],
      \ 'UIGreen': ['#499C54', 71],
      \ 'UIRed': ['#C75450', 131],
      \ 'UIBrown': ['#93896C', 102]
      \ }
call s:Hi('StatusLine', s:p.statusLineFg, s:p.statusLine)
call s:Hi('StatusLineNC', s:p.statusLineNC, s:p.statusLine)
call s:Hi('TabLine', s:p.statusLineFg, s:p.statusLine)
call s:Hi('TabLineFill', s:p.statusLine, s:p.statusLine)
call s:Hi('TabLineSel', s:p.tabLineFg, s:p.tabLineSel)
call s:Hi('BarowBufName', s:p.statusLineFg, s:p.statusLine, 'italic')
call s:Hi('BarowBufNameNC', s:p.statusLineNC, s:p.statusLine, 'italic')
call s:Hi('BarowChange', s:p.UIBrown, s:p.statusLine)
call s:Hi('BarowChangeNC', s:p.statusLineNC, s:p.statusLine)
call s:Hi('BarowTChangeNC', s:p.UIBrown, s:p.statusLine)
call s:Hi('BarowTChange', s:p.UIBrown, s:p.tabLineSel)
call s:Hi('BarowRO', s:p.UIRed, s:p.statusLine, 'bold')
call s:Hi('BarowRONC', s:p.statusLineNC, s:p.statusLine, 'bold')
call s:Hi('BarowNormal', s:p.statusLineFg, s:p.statusLine, 'bold')
call s:Hi('BarowInsert', s:p.UIGreen, s:p.statusLine, 'bold')
call s:Hi('BarowReplace', s:p.UIRed, s:p.statusLine, 'bold')
call s:Hi('BarowVisual', s:p.UIBlue, s:p.statusLine, 'bold')
call s:Hi('BarowCommand', s:p.UIBrown, s:p.statusLine, 'bold')
call s:Hi('BarowTerminal', s:p.UIGreen, s:p.statusLine, 'bold')
hi link BarowMod BarowNormal

let &cpo = s:save_cpo
unlet s:save_cpo
