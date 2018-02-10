" Creation         : 2018-02-04
" Last modification: 2018-02-09


fun! vfinder#events#char_inserted() abort
    if line('.') isnot# 1
        silent execute 'normal! 1gg'
        startinsert!
    endif
endfun

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

    if exists('b:vf.manually_updated')
        " This function is called twice after a manual update (due to textchangedI
        " event) so we ensure to stop it here if needed.
        unlet! b:vf.manually_updated
        return ''
    endif

    let prompt = vfinder#prompt#i()
    call prompt.render()

    let candidates = vfinder#candidates#i(b:vf)
    if a:update
        call candidates.update()
        let b:vf.manually_updated = 1
    else
        let candidates.original_list = b:vf.original_candidates
    endif

    if !empty(prompt.query)
        call candidates.filter(prompt.query).populate().highlight_matched()
        let b:vf.was_filtered = 1
    elseif exists('b:vf.was_filtered')
        call candidates.populate().highlight_matched()
        unlet! b:vf.was_filtered
    endif
    let b:vf.original_candidates = candidates.original_list
endfun
