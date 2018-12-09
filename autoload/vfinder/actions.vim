" Creation         : 2018-11-18
" Last modification: 2018-12-09


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#actions#get(name) abort " {{{1
    return s:{a:name}
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	buffers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:buffers_wipe(buffer) abort " {{{1
    try
        unsilent execute str2nr(a:buffer) . 'bwipeout'
    catch
        call vfinder#helpers#throw(v:exception)
    endtry
endfun
" 1}}}

" s:buffers {{{1
let s:buffers = {
                \ 'edit'  : {'action': 'buffer %s', 'options': {'silent': 0}},
                \ 'split' : {'action': 'sbuffer %s', 'options': {'silent': 0}},
                \ 'vsplit': {'action': 'vertical sbuffer %s', 'options': {'silent': 0}},
                \ 'tab'   : {'action': 'tabnew \| buffer %s', 'options': {'silent': 0}},
                \ 'wipe'  : {
                \       'action': function('s:buffers_wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       }
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	colors
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:colors {{{1
let s:colors = {
                \ 'apply'  : {'action': 'colorscheme %s', 'options': {'silent': 0}},
                \ 'preview': {'action': 'colorscheme %s', 'options': {'silent': 0, 'quit': 0}}
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	commands
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:commands {{{1
let s:commands = {
                \   'execute': {'action': '%s', 'options': {'silent': 0}},
                \   'echo' : {'action': '%s', 'options': {'silent': 0, 'echo': 1}}
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	files
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:files {{{1
let s:files = {
            \ 'edit'  : {'action': 'edit %s', 'options': {'silent': 0}},
            \ 'split' : {'action': 'split %s', 'options': {'silent': 0}},
            \ 'vsplit': {'action': 'vertical split %s', 'options': {'silent': 0}},
            \ 'tab'   : {'action': 'tabedit %s', 'options': {'silent': 0}}
            \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	grep
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:set_and_get_qf_values(line) abort " {{{1
    let initial_qflist = getqflist()
    cgetexpr a:line
    let qf = getqflist()[0]
    call setqflist(initial_qflist)
    return [qf.bufnr, qf.lnum, qf.col]
endfun
" 1}}}

fun! s:goto_buf(buf_target, line, col, ...) abort " {{{1
    " if a:1 is pedit, then it gets the command from vfinder#helpers#pedit_cmd()

    let cmd = get(a:, 1, 'buffer')
    execute cmd . ' ' . a:buf_target
    call cursor(a:line, a:col)
    call vfinder#helpers#unfold_and_put_line('t')
endfun
" 1}}}

fun! s:grep_goto(line) abort " {{{1
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col)
endfun
" 1}}}

fun! s:grep_split_and_goto(line) abort " {{{1
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col, 'sbuffer')
endfun
" 1}}}

fun! s:grep_vsplit_and_goto(line) abort " {{{1
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col, 'vertical sbuffer')
endfun
" 1}}}

fun! s:grep_tab_and_goto(line) abort " {{{1
    let initial_qflist = getqflist()
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col, 'tabnew | buffer')
    call setqflist(initial_qflist)
endfun
" 1}}}

fun! s:grep_preview(line) abort " {{{1
    let [buf_nr, p_line, p_col] = s:set_and_get_qf_values(a:line)
    let [win_nr, line, col] = [winnr(), line('.'), col('.')]
    " Prevent future update on WinEnter
    let b:vf.bopts.update_on_win_enter = 0
    silent execute 'pclose'
    execute vfinder#helpers#pedit_cmd(bufname(buf_nr))
    silent execute 'wincmd P'
    call cursor(p_line, p_col)
    call vfinder#helpers#unfold_and_put_line('t')
    call vfinder#helpers#flash_line(winnr())
    silent execute win_nr . 'wincmd w'
    let b:vf.bopts.update_on_win_enter = 1
    call cursor(line, col)
    call vfinder#helpers#autoclose_pwindow_autocmd()
endfun
" 1}}}

" s:grep {{{1
let s:grep = {
                \ 'goto'           : {'action': function('s:grep_goto'), 'options': {'function': 1}},
                \ 'split_and_goto' : {'action': function('s:grep_split_and_goto'), 'options': {'function': 1}},
                \ 'vsplit_and_goto': {'action': function('s:grep_vsplit_and_goto'), 'options': {'function': 1}},
                \ 'tab_and_goto'   : {'action': function('s:grep_tab_and_goto'), 'options': {'function': 1}},
                \ 'preview'        : {'action': function('s:grep_preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	help
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:help {{{1
let s:help = {
                \ 'open'          : {'action': 'helpclose \| help %s', 'options': {}},
                \ 'open_in_vsplit': {'action': 'helpclose \| vertical help %s', 'options': {}},
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	marks
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:marks_go_to_mark(m) abort " {{{1
    try
        execute "normal! '" . a:m
        call vfinder#helpers#unfold_and_put_line()
        call vfinder#helpers#flash_line(winnr())
    catch
        unsilent call vfinder#helpers#echo(v:exception, 'Error')
    endtry
endfun
" 1}}}

fun! s:marks_delete_mark(m) abort " {{{1
    " Only A-Z and 0-9
    if a:m !~ '^\(\u\|\d\)$'
        call vfinder#helpers#throw('only marks in range A-Z or 0-9 can be deleted')
    endif
    execute 'delmarks ' . a:m
endfun
" 1}}}

" s:marks {{{1
let s:marks = {
                \ 'goto': {
                \       'action': function('s:marks_go_to_mark'),
                \       'options': {'function': 1}
                \       },
                \ 'delete': {
                \       'action': function('s:marks_delete_mark'),
                \       'options': {'function': 1, 'silent': 0, 'quit': 0, 'update': 1}
                \       }
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	yank
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:yank_paste(content) abort " {{{1
    " a:content can be something like 'foo^@bar^@zee'

    try
        let [line, col_p] = [line('.'), col('.')]
        let new_lines = split(getline('.')[: col_p - 1] . a:content . getline('.')[col_p :], "\n")
        let go_to_line = line + len(new_lines) - 1
        let go_to_col = col_p + len(split(a:content, "\n")[-1])
        silent execute 'keepjumps ' . line . 'delete_'
        call append(line - 1, new_lines)
        call cursor(go_to_line, go_to_col)
    catch
        unsilent call vfinder#helpers#throw(v:exception)
    endtry
endfun
" 1}}}

" s:yank {{{1
let s:yank = {
                \ 'paste': {
                \   'action': function('s:yank_paste'),
                \   'options': {'function': 1}
                \ }}
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
