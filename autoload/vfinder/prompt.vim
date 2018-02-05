" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#prompt#i() abort
    return {
                \   'query'            : '',
                \   'get_query'        : function('s:prompt_get_query'),
                \   'delete'           : function('s:prompt_delete'),
                \   'render'           : function('s:prompt_render'),
                \   'set'              : function('s:prompt_set'),
                \}
endfun

fun! s:prompt_get_query() dict
    let self.query = getline(1)[2:]
    return self
endfun

fun! s:prompt_delete() dict
    let self.query = ''
    call self.render()
    return self
endfun

fun! s:prompt_render() dict
    call self.get_query().set()
    return self
endfun

fun! s:prompt_set() dict
    call setline(1, '> ' . self.query)
    return self
endfun
