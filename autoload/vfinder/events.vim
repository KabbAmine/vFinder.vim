" Creation         : 2018-02-04
" Last modification: 2018-02-12


fun! vfinder#events#char_inserted() abort
    if !vfinder#helpers#is_in_prompt()
        call vfinder#helpers#go_to_prompt()
    endif
endfun

fun! vfinder#events#update_candidates_request() abort
    let b:vf.update = 1
    call s:filter_and_update()
endfun

fun! vfinder#events#query_modified() abort
    " This event is called after a manual update, so we ensure to stop it if
    " its the case.
    if exists('b:vf.update')
        unlet! b:vf.update
        return ''
    endif
    call s:filter_and_update()
    startinsert!
endfun

fun! s:filter_and_update() abort
    let update = exists('b:vf.update')
    let prompt = vfinder#prompt#i()
    call prompt.render()
    let candidates = vfinder#candidates#i(b:vf)
    " If no manual update
    if !update
        let candidates.original_list = b:vf.original_candidates
    endif
    " No need to filter if no query
    if !empty(prompt.query) || update
        call candidates.filter(prompt.query)
    endif
    call candidates.populate().highlight_matched()
    let b:vf.original_candidates = candidates.original_list
endfun
