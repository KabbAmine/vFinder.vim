" Creation         : 2018-02-04
" Last modification: 2018-02-09


fun! vfinder#candidates#i(cmd) abort
    return {
                \   'cmd'              : a:cmd,
                \   'query'            : '',
                \   'was_filtered'     : 0,
                \   'original_list'    : [],
                \   'filtered_list'    : [],
                \   'current'          : [],
                \   'timer'            : {},
                \   'get'              : function('s:candidates_get'),
                \   'delete'           : function('s:candidates_delete'),
                \   'populate'         : function('s:candidates_populate'),
                \   'filter'           : function('s:candidates_filter'),
                \   'highlight_matched': function('s:candidates_highlight_matched'),
                \ }
endfun

fun! s:candidates_get() dict
    if empty(self.original_list)
        let self.original_list = systemlist(self.cmd)
    endif
    let self.current = getline(2, '$')
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
    " If we append chars to our query, there is no need to filter all the
    " original candidates.
    let candidates = exists('b:vf.last_query') && self.query =~# '^' . b:vf.last_query
                \ ? self.current
                \ : self.original_list
    let b:vf.last_query = self.query
    let self.filtered_list = s:filter(self.query, candidates)
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

fun! s:filter(query, candidates) abort
    return has('python3')
                \ ? py3eval('filter("' . a:query . '", ' . string(a:candidates) . ')')
                \ : filter(copy(a:candidates), {i, v -> v =~? a:query})
endfun
