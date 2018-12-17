" Creation         : 2018-02-28
" Last modification: 2018-11-09


fun! vfinder#match#i(name, candidates, query) abort " {{{1
    " Where name can be:
    " - default       : Use built-in filter function
    " - match_position: Sort by 1st index of matched string
    " - compact_match : Sort by 1st index and shorter matched string (it is
    "   slow when we have a lof of candidates)

    return call('s:filter_by_' . a:name, [a:candidates, a:query])
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            filter functions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:filter_by_default(candidates, query) abort " {{{1
    return a:query =~# '\u'
                \ ? filter(copy(a:candidates), {i, v -> v =~# a:query})
                \ : filter(copy(a:candidates), {i, v -> v =~? a:query})
endfun
" 1}}}

fun! s:filter_by_match_position(candidates, query) abort " {{{1
    let query = a:query =~# '\u' ? '\C' . a:query : '\c' . a:query
    let filtered = []
    for c in a:candidates
        let pos = match(c, query)
        if pos >=# 0
            call add(filtered, [pos, c])
        endif
    endfor
    let sorted = s:sort_list_by_nth_element(1, filtered)
    return s:get_list_of_last_values(sorted)
endfun
" 1}}}

fun! s:filter_by_compact_match(candidates, query) abort " {{{1
    let query = a:query =~# '\u' ? '\C' . a:query : '\c' . a:query
    let filtered = []
    for c in a:candidates
        let pos = match(c, query)
        let matched = matchstr(c, query)
        if pos >=# 0
            call add(filtered, [pos, strlen(matched), c])
        endif
    endfor
    let sorted = s:sort_list_by_nth_element(1, filtered)
    let sorted = s:sort_list_by_nth_element(2, copy(sorted))
    return s:get_list_of_last_values(sorted)
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:get_list_of_last_values(l) abort " {{{1
    " Return a list of the last values of a:l
    " e.g. [..., ..., ..., cand1], [..., ..., ..., cand2], ...
    "                        ^                       ^
    return map(copy(a:l), 'v:val[-1]')
endfun
" 1}}}

fun! s:sort_list_by_nth_element(n, l) " {{{1
    let f = 's:sort_list_by_' . a:n . '_value'
    let n = a:n - 1
    return sort(copy(a:l), f)
endfun
" 1}}}

fun! s:sort_list_by_1_value(a, b) abort " {{{1
    " e.g. [20, ...], [0, ...], ...
    "        ^         ^
    return s:numerical_sort(a:a[0], a:b[0])
endfun
" 1}}}

fun! s:sort_list_by_2_value(a, b) abort " {{{1
    " e.g. [..., 20, ...], [..., 10, ...], ...
    "             ^               ^
    return s:numerical_sort(a:a[1], a:b[1])
endfun
" 1}}}

fun! s:numerical_sort(a, b) abort " {{{1
    return a:a ==# a:b ? 0
                \ : a:a ># a:b ? 1
                \ : -1
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
