" Creation         : 2018-02-04
" Last modification: 2018-12-18


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	events
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#events#trigger_event_with_delay(name) abort " {{{1
    if exists('g:vf_filtering_timer') && timer_info(g:vf_filtering_timer) !=# []
        call timer_stop(g:vf_filtering_timer)
        unlet! g:vf_filtering_timer
    endif
    if vfinder#helpers#is_in_prompt()
        " If a delete map was used (<BS>, <Del>...) we get the delay related to
        " the initial candidates (b:vf.candidates.initial), otherwise we get
        " the one related to the current candidates
        if b:vf.bopts.delete_map_used
            let b:vf.bopts.delete_map_used = 0
            let delay = s:get_timer_delay('initial')
        else
            let delay = s:get_timer_delay('current')
        endif
        let f = 'vfinder#events#' . a:name
        let g:vf_filtering_timer = timer_start(delay, {
                    \   t -> call(f, [])
                    \ })
    endif
endfun
" 1}}}

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
        if b:vf.bopts.last_pos !=# []
            call cursor(b:vf.bopts.last_pos[0], b:vf.bopts.last_pos[1])
        endif
    endif
endfun
" 1}}}

fun! vfinder#events#win_leave() abort " {{{1
    let b:vf.bopts.last_pos = [line('.'), col('.')]
endfun
" 1}}}

fun! vfinder#events#update_candidates_request(...) abort " {{{1
    let b:vf.bopts.manual_update = 1
    let mode = get(a:, 1, 'i')
    let [line, col] = [line('.'), col('.')]
    call s:filter_and_update()
    silent execute line
    if mode is# 'i'
        if vfinder#helpers#is_in_prompt()
            call vfinder#helpers#go_to_initial_col_i(col)
        else
            call cursor(line, 0)
            startinsert
        endif
    else
        call cursor(line, col)
        stopinsert
    endif
    call vfinder#helpers#echo('list of candidates updated...')
endfun
" 1}}}

fun! vfinder#events#query_modified(...) abort " {{{1
    " If coming from a vfinder#events#query_modified_with_delay()
    if exists('g:vf_filtering_timer')
        unlet g:vf_filtering_timer
    endif
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

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

fun! s:get_timer_delay(who) abort " {{{1
    let ll = a:who is# 'current'
                \ ? line('$')
                \ : len(b:vf.candidates.initial)
    " More the candidates, bigger the delay
    return ll <# 5000
                \ ? 0
                \ : ll <# 15000
                \ ? 50
                \ : ll <# 30000
                \ ? 100
                \ : ll <# 50000
                \ ? 150
                \ : 250
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
