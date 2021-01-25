" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowInit")
  finish
endif
let g:barowInit = 1

augroup barow
  autocmd!
  autocmd VimEnter,BufEnter,BufDelete,WinEnter,TabEnter,TabLeave,TabNew,TabNewEntered,TabClosed,TermEnter,TermLeave * call barow#update()
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
hi link BarowLPercent StatusLine
hi link BarowLPercentNC StatusLineNC
hi link BarowRowCol StatusLine
hi link BarowRowColNC StatusLineNC
call s:Hi('BarowNormal', s:p.statusLineFg, s:p.statusLine, 'bold')
call s:Hi('BarowInsert', s:p.UIGreen, s:p.statusLine, 'bold')
call s:Hi('BarowReplace', s:p.UIRed, s:p.statusLine, 'bold')
call s:Hi('BarowVisual', s:p.UIBlue, s:p.statusLine, 'bold')
call s:Hi('BarowCommand', s:p.UIBrown, s:p.statusLine, 'bold')
call s:Hi('BarowTerminal', s:p.UIGreen, s:p.statusLine, 'bold')
hi link BarowMode BarowNormal
hi link BarowModeNC StatusLineNC

let &cpo = s:save_cpo
unlet s:save_cpo
