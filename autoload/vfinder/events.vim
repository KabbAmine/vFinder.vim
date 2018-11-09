" Creation         : 2018-02-04
" Last modification: 2018-02-26


fun! vfinder#events#char_inserted() abort " {{{1
    if !vfinder#helpers#is_in_prompt()
        call vfinder#helpers#go_to_prompt_and_startinsert()
    endif
endfun
" 1}}}

fun! vfinder#events#update_candidates_request() abort " {{{1
    let b:vf.update = 1
    call s:filter_and_update()
endfun
" 1}}}

fun! vfinder#events#query_modified() abort " {{{1
    " This event is called after a manual update, so we ensure to stop it if
    " its the case.
    let col = col('.')
    if exists('b:vf.update')
        unlet! b:vf.update
        return ''
    endif
    call s:filter_and_update()
    if col is# col('$')
        startinsert!
    else
        startinsert
        call cursor(1, col)
    endif
endfun
" 1}}}

fun! s:filter_and_update() abort " {{{1
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
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
