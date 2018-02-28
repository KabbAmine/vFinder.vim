" Creation         : 2018-02-04
" Last modification: 2018-02-28


fun! vfinder#candidates#i(source) abort
    return {
                \   'source'           : a:source,
                \   'query'            : '',
                \   'was_filtered'     : 0,
                \   'original_list'    : [],
                \   'filtered_list'    : [],
                \   'current'          : [],
                \   'get'              : function('s:candidates_get'),
                \   'delete'           : function('s:candidates_delete'),
                \   'populate'         : function('s:candidates_populate'),
                \   'filter'           : function('s:candidates_filter'),
                \   'highlight_matched': function('s:candidates_highlight_matched'),
                \ }
endfun

fun! s:candidates_get() dict
    if self.original_list ==# []
        let self.original_list = self.source.prepare().candidates
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
    " There is no need to filter all the original candidates if we added
    " characters to our previous query.
    " Note that the following is not appliable if we have a manual update.
    let candidates = !exists('b:vf.update') && exists('b:vf.last_query')
                \ && self.query[2:] =~# '^\v' . b:vf.last_query[2:]
                \   ? self.current
                \   : self.original_list
    let b:vf.last_query = self.query
    let self.filtered_list = s:filter(self.query, candidates)
    let self.was_filtered = 1
    return self
endfun

fun! s:candidates_highlight_matched() dict
    call clearmatches()
    if !empty(self.query) && self.query isnot# '\v'
        let case = self.query =~# '\u' ? '\C' : '\c'
        call matchadd('CursorLineNr', case . self.query)
    endif
    return self
endfun

fun! s:filter(query, candidates) abort
    return vfinder#filter#i(b:vf.filter_name, a:candidates, a:query)
endfun
