" Creation         : 2018-02-04
" Last modification: 2018-11-29


fun! vfinder#events#char_inserted() abort " {{{1
    if !vfinder#helpers#is_in_prompt()
        call vfinder#helpers#go_to_prompt_and_startinsert()
    endif
endfun
" 1}}}

fun! vfinder#events#win_enter() abort " {{{1
    if b:vf.bopts.update_on_win_enter
        let b:vf.bopts.manual_update = 1
        call s:filter_and_update()
        if b:vf.ctx.last_pos !=# []
            call cursor(b:vf.ctx.last_pos[0], b:vf.ctx.last_pos[1])
        endif
    endif
endfun
" 1}}}

fun! vfinder#events#win_leave() abort " {{{1
    let b:vf.ctx.last_pos = [line('.'), col('.')]
endfun
" 1}}}

fun! vfinder#events#update_candidates_request() abort " {{{1
    let b:vf.bopts.manual_update = 1
    call s:filter_and_update()
endfun
" 1}}}

fun! vfinder#events#query_modified() abort " {{{1
    " When triggered with startinsert the 1st time
    if exists('b:vf.bopts.first_execution')
        unlet! b:vf.bopts.first_execution
        return
    endif
    " This event is called after a manual update, so we ensure to
    " stop it if its the case.
    let col = col('.')
    if exists('b:vf.bopts.manual_update')
        unlet! b:vf.bopts.manual_update
        return
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
    let manual_update = exists('b:vf.bopts.manual_update') && b:vf.bopts.manual_update
    let prompt = vfinder#prompt#i()
    call prompt.render()
    let candidates = vfinder#candidates#i(b:vf.s)
    " If no manual update
    if !manual_update
        let candidates.initial = b:vf.candidates.initial
    endif
    " No need to filter if no query
    if !empty(prompt.query) || manual_update
        call candidates.filter(prompt.query)
    endif
    call candidates.populate().highlight_matched()
    let b:vf.candidates.initial = candidates.initial
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
