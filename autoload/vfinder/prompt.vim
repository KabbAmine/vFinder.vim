" Creation         : 2018-02-04
" Last modification: 2018-11-07


fun! vfinder#prompt#i() abort " {{{1
    return {
                \   'query'    : '',
                \   'get_query': function('s:prompt_get_query'),
                \   'delete'   : function('s:prompt_delete'),
                \   'render'   : function('s:prompt_render'),
                \   'set'      : function('s:prompt_set'),
                \}
endfun
" 1}}}

fun! s:prompt_render(...) dict " {{{1
    if exists('a:1')
        let self.query = a:1
        call self.set()
    else
        call self.delete().get_query().set()
    endif
    return self
endfun
" 1}}}

fun! s:prompt_get_query() dict " {{{1
    let self.query = getline(1)[2:]
    return self
endfun
" 1}}}

fun! s:prompt_delete() dict " {{{1
    let self.query = ''
    return self
endfun
" 1}}}

fun! s:prompt_set() dict " {{{1
    call setline(1, '> ' . self.query)
    return self
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
