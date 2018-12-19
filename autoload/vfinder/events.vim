" Creation         : 2018-02-04
" Last modification: 2018-12-20


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	events
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#events#query_modified_with_delay() abort " {{{1
    " This event is fired the 1st time vfinder#i() is executed or after a
    " manual update, so we ensure to stop it if its the case
    if b:vf.bopts.manual_update
        let b:vf.bopts.manual_update = 0
        return
    endif
    call s:stop_filtering_timer_if_running()
    if vfinder#helpers#is_in_prompt()
        " If a delete map was used (<BS>, <Del>...) we get the delay related to
        " the number of the initial candidates (b:vf.candidates.initial),
        " otherwise we get the one related to the current candidates
        if b:vf.bopts.delete_map_used
            let b:vf.bopts.delete_map_used = 0
            let delay = s:get_timer_delay('initial')
        else
            let delay = s:get_timer_delay('current')
        endif
        let g:vf_filtering_timer = timer_start(delay, {
                    \   t -> call('vfinder#events#query_modified', [])
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
    " Be sure to delete the global timer variable if coming from a
    " #query_modified_with_delay()
    unlet! g:vf_filtering_timer
    let col = col('.')
    call s:filter_and_update()
    call s:start_insert_in_initial_pos(col)
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:filter_and_update() abort " {{{1
    let prompt = vfinder#prompt#i().render()
    let candidates = vfinder#candidates#i(b:vf.s)
    if !b:vf.bopts.manual_update
        let candidates.initial = b:vf.candidates.initial
    endif
    if !empty(prompt.query) || b:vf.bopts.manual_update
        call candidates.filter(prompt.query)
    endif
    call candidates.populate().highlight_matched()
    let b:vf.candidates.initial = candidates.initial
endfun
" 1}}}

fun! s:get_timer_delay(who) abort " {{{1
    " who: current|initial

    let ll = a:who is# 'current'
                \ ? line('$')
                \ : len(b:vf.candidates.initial)
    " More the candidates, bigger the delay
    return ll <# 10000
                \ ? 100
                \ : ll <# 20000
                \ ? 200
                \ : 300
endfun
" 1}}}

fun! s:stop_filtering_timer_if_running() abort " {{{1
    if exists('g:vf_filtering_timer') && timer_info(g:vf_filtering_timer) !=# []
        call timer_stop(g:vf_filtering_timer)
        unlet! g:vf_filtering_timer
    endif
endfun
" 1}}}

fun! s:start_insert_in_initial_pos(col) abort " {{{1
    if a:col is# col('$')
        startinsert!
    else
        startinsert
        call cursor(1, a:col)
    endif
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
