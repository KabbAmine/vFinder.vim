" Creation         : 2018-11-15
" Last modification: 2018-11-30


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#grep#get(...) abort " {{{1
    call s:grep_define_maps()
    let query = exists('a:1') && !empty(a:1)
                \ ? a:1
                \ : s:get_query()
    return {
                \   'name'      : 'grep',
                \   'to_execute': s:grep_source(query),
                \   'syntax_fun': function('s:grep_syntax_fun', [query]),
                \   'maps'      : s:grep_maps(),
                \   'is_valid'  : !empty(query)
                \ }
endfun
" 1}}}

fun! s:grep_source(query) abort " {{{1
    return &grepprg . ' "' . a:query . '"'
endfun
" 1}}}

fun! s:grep_syntax_fun(query) abort " {{{1
    if a:query isnot# '""'
        let query = a:query =~# '\u'
                    \ ? '\C' . a:query
                    \ : '\c' . a:query
        let query = substitute(query, '"', '', 'g')
        execute 'syntax match vfinderGrepQuery =' . query . '='
    endif
    syntax match vfinderGrepInfos =^\S\+:=
    highlight! link vfinderGrepInfos vfinderIndex
    highlight! link vfinderGrepQuery Title
endfun
" 1}}}

fun! s:grep_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('grep')
    let maps.i = {
                \ keys.i.goto           : {'action': function('s:goto'), 'options': {'function': 1}},
                \ keys.i.split_and_goto : {'action': function('s:split_and_goto'), 'options': {'function': 1}},
                \ keys.i.vsplit_and_goto: {'action': function('s:vsplit_and_goto'), 'options': {'function': 1}},
                \ keys.i.tab_and_goto   : {'action': function('s:tab_and_goto'), 'options': {'function': 1}},
                \ keys.i.preview        : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    let maps.n = {
                \ keys.n.goto           : {'action': function('s:goto'), 'options': {'function': 1}},
                \ keys.n.split_and_goto : {'action': function('s:split_and_goto'), 'options': {'function': 1}},
                \ keys.n.vsplit_and_goto: {'action': function('s:vsplit_and_goto'), 'options': {'function': 1}},
                \ keys.n.tab_and_goto   : {'action': function('s:tab_and_goto'), 'options': {'function': 1}},
                \ keys.n.preview        : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:goto(line) abort " {{{1
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col)
endfun
" 1}}}

fun! s:split_and_goto(line) abort " {{{1
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col, 'sbuffer')
endfun
" 1}}}

fun! s:vsplit_and_goto(line) abort " {{{1
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col, 'vertical sbuffer')
endfun
" 1}}}

fun! s:tab_and_goto(line) abort " {{{1
    let initial_qflist = getqflist()
    let [buf_nr, line, col] = s:set_and_get_qf_values(a:line)
    call s:goto_buf(buf_nr, line, col, 'tabnew | buffer')
    call setqflist(initial_qflist)
endfun
" 1}}}

fun! s:preview(line) abort " {{{1
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

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:grep_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('grep', {
                \   'i': {
                \       'goto'           : '<CR>',
                \       'split_and_goto' : '<C-s>',
                \       'vsplit_and_goto': '<C-v>',
                \       'tab_and_goto'   : '<C-t>',
                \       'preview'        : '<C-o>',
                \   },
                \   'n': {
                \       'goto'           : '<CR>',
                \       'split_and_goto' : 's',
                \       'vsplit_and_goto': 'v',
                \       'tab_and_goto'   : 't',
                \       'preview'        : 'o',
                \   }
                \ })
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:get_query() abort " {{{1
    call inputsave()
    echohl vfinderPrompt
    let query = input('VFGrep> ')
    echohl None
    call inputrestore()
    return !empty(query)
                \ ? query
                \ : ''
endfun
" 1}}}

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


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
