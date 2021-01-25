" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at https://mozilla.org/MPL/2.0/.

let s:save_cpo = &cpo
set cpo&vim

if exists("g:barowAutoload")
  finish
endif
let g:barowAutoload = 1

let s:barowDefault = {
      \'modes': {
      \  'normal': [ ' ', 'BarowNormal' ],
      \  'insert': [ 'i', 'BarowInsert' ],
      \  'replace': [ 'r', 'BarowReplace' ],
      \  'visual': [ 'v', 'BarowVisual' ],
      \  'v-line': [ 'l', 'BarowVisual' ],
      \  'v-block': [ 'b', 'BarowVisual' ],
      \  'select': [ 's', 'BarowVisual' ],
      \  'command': [ 'c', 'BarowCommand' ],
      \  'shell-ex': [ '!', 'BarowCommand' ],
      \  'terminal': [ 't', 'BarowTerminal' ],
      \  'prompt': [ 'p', 'BarowNormal' ],
      \  'inactive': [ ' ', 'BarowModeNC' ]
      \},
      \'buf_name': {
      \  'empty': '',
      \  'highlight': [ 'BarowBufName', 'BarowBufNameNC' ]
      \},
      \'read_only': {
      \  'value': 'ro',
      \  'highlight': [ 'BarowRO', 'BarowRONC' ]
      \},
      \'buf_changed': {
      \  'value': '*',
      \  'highlight': [ 'BarowChange', 'BarowChangeNC' ]
      \},
      \'tab_changed': {
      \  'value': '*',
      \  'highlight': [ 'BarowTChange', 'BarowTChangeNC' ]
      \},
      \'line_percent': {
      \  'highlight': [ 'BarowLPercent', 'BarowLPercentNC' ]
      \},
      \'row_col': {
      \  'highlight': [ 'BarowRowCol', 'BarowRowColNC' ]
      \},
      \'modules': []
      \}

function! Bufname()
  let bufname = bufname("%")
  if bufname("%") == ""
    return get(g:barow, "buf_name.empty", s:barowDefault.buf_name.empty)
  endif
  return split(bufname, "/")[-1]
endfunction

function! ReadOnly()
  let filetype = getbufvar("%", "&filetype")
  if (&readonly || !&modifiable) && filetype !~? 'help\|man'
    return get(g:barow, "read_only.value", s:barowDefault.read_only.value)
  endif
  return ""
endfunction

function! BufChanged()
  let bufinfo = get(getbufinfo("%"), 0, { 'changed': 0 })
  if bufinfo.changed
    return get(g:barow, "buf_changed.value", s:barowDefault.buf_changed.value)
  endif
  return ""
endfunction

function! Mode()
  let mode = mode()
  let modeMap = get(g:barow, "modes", "s:barowDefault.modes")
  if mode =~? '^n'
    return get(modeMap, "normal", s:barowDefault.modes.normal)
  elseif mode =~? '^i'
    return get(modeMap, "insert", s:barowDefault.modes.insert)
  elseif mode =~# '^R'
    return get(modeMap, "replace", s:barowDefault.modes.replace)
  elseif mode ==# 'v'
    return get(modeMap, "visual", s:barowDefault.modes.visual)
  elseif mode ==# 'V'
    return get(modeMap, "v-line", s:barowDefault.modes["v-line"])
  elseif mode == ''
    return get(modeMap, "v-block", s:barowDefault.modes["v-block"])
  elseif mode =~? '^c'
    return get(modeMap, "command", s:barowDefault.modes.command)
  elseif mode == 't'
    return get(modeMap, "terminal", s:barowDefault.modes.terminal)
  elseif mode == '!'
    return get(modeMap, "shell-ex", s:barowDefault.modes["shell-ex"])
  elseif mode =~? '^r'
    return get(modeMap, "prompt", s:barowDefault.modes.prompt)
  elseif mode =~? '^s\|'
    return get(modeMap, "select", s:barowDefault.modes.select)
  endif
  return mode
endfunction

function! SetModeHi()
  let [mode, higroup] = Mode()
  execute("hi link BarowMod ".higroup)
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
      let symbol = get(g:barow, "tab_changed.value", s:barowDefault.tab_changed.value)
      if i == tabpagenr()
        let s .= '%#BarowTChange#'.symbol
      else
        let s .= '%#BarowTChangeNC#'.symbol
      endif
    else
      let s.= ' '
    endif
    let s .= '%T'
  endfor
  let s .= '%#TabLineFill#'
  return s
endfunction

function! barow#update()
  if !exists("g:barow")
    let g:barow = s:barowDefault
  endif
  let mode = "%{SetModeHi()}%#BarowMod#%1.1{Mode()[0]}%*"
  let modeInactive = "%#BarowModeNC#".get(g:barow, "modes.inactive[0]", s:barowDefault.modes.inactive[0])."%*"
  let spacer = "%="
  for n in range(1, winnr('$'))
    if n == winnr()
      let bufName = "%#BarowBufName#%2.50{Bufname()}%*"
      let ro = "%#BarowRO#%{ReadOnly()}%*"
      let bufChanged = "%#BarowChange#%1.1{BufChanged()}%*"
      let rowCol = "%#BarowRowCol#%4.9l:%-3.9c%*"
      let linePercent = "%#BarowLPercent#%3.3p%%%*"
      call setwinvar(n, '&statusline', " ".mode." ".bufName." ".ro." ".bufChanged.spacer.rowCol." ".linePercent." ")
    else
      let bufName = "%#BarowBufNameNC#%2.50{Bufname()}%*"
      let ro = "%#BarowRONC#%{ReadOnly()}%*"
      let bufChanged = "%#BarowChangeNC#%1.1{BufChanged()}%*"
      let rowCol = "%#BarowRowColNC#%4.9l:%-3.9c%*"
      let linePercent = "%#BarowLPercentNC#%3.3p%%%*"
      call setwinvar(n, '&statusline', " ".modeInactive." ".bufName." ".ro." ".bufChanged.spacer.rowCol." ".linePercent." ")
    endif
    call setwinvar(n, "&tabline", "%!SetTabLine()")
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
