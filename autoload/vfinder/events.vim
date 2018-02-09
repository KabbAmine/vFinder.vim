" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#events#update_candidates_request() abort
    call s:filter_and_update(1)
endfun

fun! vfinder#events#query_modified() abort
    if line('.') isnot# 1
        return ''
    endif
    call s:filter_and_update(0)
    startinsert!
endfun

fun! s:filter_and_update(update) abort
    " Render prompt
    " Get candidates (reexecute cmd if update is 1)
    " Filter candidates depending of the query

    let prompt = vfinder#prompt#i()
    call prompt.render()

    let candidates = vfinder#candidates#i(b:vf.cmd)
    if exists('b:vf.original_candidates') && !a:update
        let candidates.original_list = b:vf.original_candidates
    endif

    if !empty(prompt.query)
        call candidates.filter(prompt.query).populate().highlight_matched()
        let s:was_filtered = 1
    elseif exists('s:was_filtered')
        call candidates.get().populate().highlight_matched()
        unlet! s:was_filtered
    endif
    let b:vf.original_candidates = candidates.original_list
endfun
