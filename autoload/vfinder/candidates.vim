" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#candidates#i(cmd) abort
    return {
                \   'cmd'              : a:cmd,
                \   'query'            : '',
                \   'was_filtered'     : 0,
                \   'original_list'    : [],
                \   'filtered_list'    : [],
                \   'timer'            : {},
                \   'get'              : function('s:candidates_get'),
                \   'delete'           : function('s:candidates_delete'),
                \   'populate'         : function('s:candidates_populate'),
                \   'filter'           : function('s:candidates_filter'),
                \   'highlight_matched': function('s:candidates_highlight_matched'),
                \ }
endfun

fun! s:candidates_get() dict
    let self.original_list = systemlist(self.cmd)
    return self
endfun

fun! s:candidates_delete() dict
    if line('$') ># 1
        silent execute '2,$delete_'
    endif
    return self
endfun

fun! s:candidates_populate() dict
    call self.delete()
    if self.was_filtered
        let candidates = self.filtered_list
        let self.was_filtered = 0
    else
        let candidates = self.original_list
    endif
    call setline(2, candidates)
    return self
endfun

fun! s:candidates_filter(query) dict
    call self.get()
    let self.query = vfinder#helpers#process_query(a:query)
    let self.filtered_list = filter(copy(self.original_list), {i, v -> v =~? self.query})
    let self.was_filtered = 1
    return self
endfun

fun! s:candidates_highlight_matched() dict
    call clearmatches()
    if !empty(self.query)
        call matchadd('CursorLineNr', '\c' . self.query)
    endif
    return self
endfun
