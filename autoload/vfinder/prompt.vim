" Creation         : 2018-02-04
" Last modification: 2018-02-19


fun! vfinder#prompt#i() abort
    return {
                \   'query'            : '',
                \   'get_query'        : function('s:prompt_get_query'),
                \   'delete'           : function('s:prompt_delete'),
                \   'render'           : function('s:prompt_render'),
                \   'set'              : function('s:prompt_set'),
                \}
endfun

fun! s:prompt_render(...) dict
    if exists('a:1')
        let self.query = a:1
        call self.set()
    else
        call self.delete().get_query().set()
    endif
    return self
endfun

fun! s:prompt_get_query() dict
    let self.query = getline(1)[2:]
    return self
endfun

fun! s:prompt_delete() dict
    let self.query = ''
    return self
endfun

fun! s:prompt_set() dict
    call setline(1, '> ' . self.query)
    return self
endfun
