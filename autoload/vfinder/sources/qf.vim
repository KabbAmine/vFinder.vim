" Creation         : 2018-12-02
" Last modification: 2019-01-17


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#qf#get(...) abort " {{{1
    call s:qf_define_maps()
    let qf_t = get(a:, 1, 'q')
    return {
                \   'name'      : 'qf',
                \   'to_execute': function('s:qf_source', [qf_t]),
                \   'format_fun': function('s:qf_format'),
                \   'syntax_fun': function('s:qf_syntax_fun'),
                \   'maps'      : s:qf_maps(),
                \ }
endfun
" 1}}}

fun! s:qf_source(t) abort " {{{1
    return a:t is# 'q'
                \ ? getqflist()
                \ : getloclist(b:vf.ctx.winnr)
endfun
" 1}}}

fun! s:qf_format(items) abort " {{{1
    let res = []
    for i in a:items
        if !i.valid
            continue
        endif
        let [line, col] = [get(i, 'lnum', ''), get(i, 'col', '')]
        let buf_nr = get(i, 'bufnr', -1)
        let buf_name = buf_nr ># 0
                    \ ? fnamemodify(bufname(buf_nr), ':~:.')
                    \ : ''
        call add(res, printf('%s %s',
                    \   join([buf_name, line, col], ':'),
                    \   trim(i.text)
                    \ ))
    endfor
    return res
endfun
" 1}}}

fun! s:qf_syntax_fun() abort " {{{1
    syntax match vfinderQfblc =\%>1l^\S\+=
    highlight default link vfinderQfblc vfinderIndex
endfun
" 1}}}

fun! s:qf_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('qf')
    let actions = vfinder#actions#get('grep')
    let maps.i = {
                \ keys.i.goto           : actions.goto,
                \ keys.i.split_and_goto : actions.split_and_goto,
                \ keys.i.vsplit_and_goto: actions.vsplit_and_goto,
                \ keys.i.tab_and_goto   : actions.tab_and_goto,
                \ keys.i.preview        : actions.preview
                \ }
    let maps.n = {
                \ keys.n.goto           : actions.goto,
                \ keys.n.split_and_goto : actions.split_and_goto,
                \ keys.n.vsplit_and_goto: actions.vsplit_and_goto,
                \ keys.n.tab_and_goto   : actions.tab_and_goto,
                \ keys.n.preview        : actions.preview
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:qf_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('qf', {
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


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
