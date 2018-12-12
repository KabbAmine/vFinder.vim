" Creation         : 2018-11-15
" Last modification: 2018-12-12


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
    if !empty(a:query)
        call histadd('@', a:query)
    endif
    return &grepprg . ' "' . escape(a:query, '"') . '"'
endfun
" 1}}}

fun! s:grep_syntax_fun(query) abort " {{{1
    if a:query isnot# '""'
        let query = a:query =~# '\u'
                    \ ? '\C' . a:query
                    \ : '\c' . a:query
        execute 'syntax match vfinderGrepQuery =\%>1l\V' . query . '='
    endif
    syntax match vfinderGrepInfos =\%>1l^\S\+:=
    highlight default link vfinderGrepInfos vfinderIndex
    highlight default link vfinderGrepQuery Title
endfun
" 1}}}

fun! s:grep_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('grep')
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
    let query = input('VFGrep> ', '', 'customlist,vfinder#sources#grep#compl')
    echohl None
    call inputrestore()
    return !empty(query)
                \ ? query
                \ : ''
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	completion
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#grep#compl(arg, cmd, curpos) abort " {{{1
    let hl = []
    for h in ['/', '@']
        let hl += map(split(execute('history ' . h), "\n"), {
                    \   _, v -> matchstr(v, '^>\?\s*\d\+\s\+\zs\S.*$')
                    \ })
    endfor
    return filter(copy(reverse(uniq(hl))), {_, v -> v =~ '^' . a:arg})
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
