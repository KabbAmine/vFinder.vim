" Creation         : 2018-02-04
" Last modification: 2018-12-17


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        main candidates object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#candidates#i(source) abort " {{{1
    return {
                \   'source'           : a:source,
                \   'buf_nr'           : bufnr('%'),
                \   'query'            : '',
                \   'was_filtered'     : 0,
                \   'initial'          : [],
                \   'filtered_list'    : [],
                \   'current'          : [],
                \   'get'              : function('s:candidates_get'),
                \   'delete'           : function('s:candidates_delete'),
                \   'populate'         : function('s:candidates_populate'),
                \   'filter'           : function('s:candidates_filter'),
                \   'highlight_matched': function('s:candidates_highlight_matched'),
                \ }
endfun
" 1}}}

fun! s:candidates_get() dict abort " {{{1
    if self.initial ==# []
        let self.initial = self.source.prepare().candidates
    endif
    let self.current = getbufline(self.buf_nr, 2, '$')
    return self
endfun
" 1}}}

fun! s:candidates_delete() dict abort " {{{1
    silent call deletebufline(self.buf_nr, 2, '$')
    return self
endfun
" 1}}}

fun! s:candidates_populate() dict abort " {{{1
    call self.delete()
    if self.was_filtered
        let candidates = self.filtered_list
        let self.was_filtered = 0
    else
        let candidates = self.initial
    endif
    call setbufline(self.buf_nr, 2, candidates)
    return self
endfun
" 1}}}

fun! s:candidates_filter(query) dict abort " {{{1
    call self.get()
    let self.query = vfinder#helpers#process_query(a:query)
    " There is no need to filter all the original candidates if we added
    " characters to our previous query.
    " Note that the following is not appliable if we have a manual update.
    let candidates = !exists('b:vf.bopts.manual_update')
                \ && self.query[2:] =~# '^\v' . b:vf.bopts.last_query[2:]
                \   ? self.current
                \   : self.initial
    let b:vf.bopts.last_query = self.query
    let self.filtered_list = s:filter(self.query, candidates)
    let self.was_filtered = 1
    return self
endfun
" 1}}}

fun! s:candidates_highlight_matched() dict abort " {{{1
    call clearmatches()
    if !empty(self.query) && self.query isnot# '\v'
        let case = self.query =~# '\u' ? '\C' : '\c'
        call matchadd('vfinderMatched', case . self.query)
    endif
    return self
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:filter(query, candidates) abort " {{{1
    return vfinder#match#i(b:vf.s.match_mode, a:candidates, a:query)
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
