" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

if exists('g:barow_plugin')
  finish
endif
let g:barow_plugin = 1

let s:save_cpo = &cpo
set cpo&vim

let g:barowDefault = {
      \  'modes': {
      \    'normal': [' ', 'BarowNormal'],
      \    'insert': ['i', 'BarowInsert'],
      \    'replace': ['r', 'BarowReplace'],
      \    'visual': ['v', 'BarowVisual'],
      \    'v-line': ['l', 'BarowVisual'],
      \    'v-block': ['b', 'BarowVisual'],
      \    'select': ['s', 'BarowVisual'],
      \    'command': ['c', 'BarowCommand'],
      \    'shell-ex': ['!', 'BarowCommand'],
      \    'terminal': ['t', 'BarowTerminal'],
      \    'prompt': ['p', 'BarowNormal'],
      \    'inactive': [' ', 'BarowModeNC']
      \  },
      \  'statusline': ['Barow', 'BarowNC'],
      \  'tabline': ['BarowTab', 'BarowTabSel', 'BarowTabFill'],
      \  'buf_name': {
      \    'empty': '',
      \    'hi': ['BarowBufName', 'BarowBufNameNC']
      \  },
      \  'read_only': {
      \    'value': 'ro',
      \    'hi': ['BarowRO', 'BarowRONC']
      \  },
      \  'buf_changed': {
      \    'value': '*',
      \    'hi': ['BarowChange', 'BarowChangeNC']
      \  },
      \  'tab_changed': {
      \    'value': '*',
      \    'hi': ['BarowTChange', 'BarowTChangeNC']
      \  },
      \  'line_percent': {
      \    'hi': ['BarowLPercent', 'BarowLPercentNC']
      \  },
      \  'row_col': {
      \    'hi': ['BarowRowCol', 'BarowRowColNC']
      \  },
      \  'modules': []
      \}

function! s:normalize_config()
  if !exists('g:barow') || type(g:barow) != v:t_dict
    let g:barow = g:barowDefault
    return
  endif
	for key in keys(g:barowDefault)
	   if !has_key(g:barow, key) || type(g:barowDefault[key]) != type(g:barow[key])
       let g:barow[key] = g:barowDefault[key]
     endif
	endfor
endfunction

call s:normalize_config()

augroup barow
  autocmd!
  autocmd WinEnter,BufEnter,BufDelete,SessionLoadPost,FileChangedShellPost * call barow#update()
augroup END

let s:p={
      \ 'null': ['NONE', 'NONE'],
      \ 'statusLine': ['#313335', 236],
      \ 'statusLineFg': ['#BBBBBB', 250],
      \ 'statusLineNC': ['#787878', 243],
      \ 'tabLineFg': ['#A9B7C6', 145],
      \ 'tabLineSel': ['#4E5254', 239],
      \ 'UIBlue': ['#3592C4', 67],
      \ 'UIGreen': ['#499C54', 71],
      \ 'UIRed': ['#C75450', 131],
      \ 'UIBrown': ['#93896C', 102],
      \ 'UIOrange': ['#BE9117', 136]
      \ }
call barow#hi('Barow', s:p.statusLineFg, s:p.statusLine)
call barow#hi('BarowNC', s:p.statusLineNC, s:p.statusLine)
call barow#hi('BarowTab', s:p.statusLineFg, s:p.statusLine)
call barow#hi('BarowTabSel', s:p.tabLineFg, s:p.tabLineSel)
call barow#hi('BarowTabFill', s:p.statusLine, s:p.statusLine)
call barow#hi('BarowBufName', s:p.statusLineFg, s:p.statusLine, 'italic')
call barow#hi('BarowBufNameNC', s:p.statusLineNC, s:p.statusLine, 'italic')
call barow#hi('BarowChange', s:p.UIBrown, s:p.statusLine)
call barow#hi('BarowChangeNC', s:p.statusLineNC, s:p.statusLine)
call barow#hi('BarowTChangeNC', s:p.UIBrown, s:p.statusLine)
call barow#hi('BarowTChange', s:p.UIBrown, s:p.tabLineSel)
call barow#hi('BarowRO', s:p.UIRed, s:p.statusLine, 'bold')
call barow#hi('BarowRONC', s:p.statusLineNC, s:p.statusLine, 'bold')
hi! link BarowLPercent Barow
hi! link BarowLPercentNC BarowNC
hi! link BarowRowCol Barow
hi! link BarowRowColNC BarowNC
call barow#hi('BarowNormal', s:p.statusLineFg, s:p.statusLine, 'bold')
call barow#hi('BarowInsert', s:p.UIGreen, s:p.statusLine, 'bold')
call barow#hi('BarowReplace', s:p.UIRed, s:p.statusLine, 'bold')
call barow#hi('BarowVisual', s:p.UIBlue, s:p.statusLine, 'bold')
call barow#hi('BarowCommand', s:p.UIBrown, s:p.statusLine, 'bold')
call barow#hi('BarowTerminal', s:p.UIGreen, s:p.statusLine, 'bold')
hi! link BarowMode BarowNormal
hi! link BarowModeNC BarowNC
call barow#hi('BarowError', s:p.UIRed, s:p.statusLine, 'bold')
call barow#hi('BarowWarning', s:p.UIOrange, s:p.statusLine)
call barow#hi('BarowInfo', s:p.UIBrown, s:p.statusLine)
call barow#hi('BarowHint', s:p.statusLineNC, s:p.statusLine)

let &cpo = s:save_cpo
unlet s:save_cpo
