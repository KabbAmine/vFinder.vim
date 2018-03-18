" Creation         : 2018-02-04
" Last modification: 2018-03-18


fun! vfinder#helpers#go_to_prompt_and_startinsert()
    call cursor(1, 0)
    startinsert!
endfun

fun! vfinder#helpers#is_in_prompt()
    return line('.') is# 1 ? 1 : 0
endfun

fun! vfinder#helpers#process_query(query) abort
    let q = g:vfinder_fuzzy
                \ ? substitute(a:query, ' ', '', 'g')
                \ : a:query
    let q_sep = g:vfinder_fuzzy ? '\zs' : ' '
    let join_pat = '.{-}'
    let to_escape = '@=?+&$.*~()|{}%[]'
    let final_regex = []
    for item in split(q, q_sep)
        call add(final_regex, escape(item, to_escape))
    endfor
    return '\v' . join(final_regex, join_pat)
endfun

fun! vfinder#helpers#throw(msg) abort
    let v:errmsg = s:msg(a:msg, 'error')
    throw v:errmsg
endfun

fun! vfinder#helpers#echo(msg, higroup, ...) abort
    if g:vfinder_verbose || exists('a:1') && a:1
        let msg = a:msg =~# '^\V[vfinder]' ? a:msg : s:msg(a:msg)
        silent execute 'echohl ' . a:higroup
        echomsg msg
        echohl None
    endif
endfun

fun! vfinder#helpers#input(msg, higroup) abort
    silent execute 'echohl ' . a:higroup
    let response = input(a:msg)
    echohl None
    return response
endfun

fun! vfinder#helpers#question(infos, question) abort
    let old_vf_verbose_option = g:vfinder_verbose
    let g:vfinder_verbose = 1
    call vfinder#helpers#echo(a:infos, 'Question')
    let response = vfinder#helpers#input(a:question . ' [y/N] ', 'Question')
    let g:vfinder_verbose = old_vf_verbose_option
    return response
endfun

fun! s:msg(content, ...) abort
    let extra = exists('a:1') ? '[' . a:1 . '] ' : ''
    return '[vfinder] ' . extra . a:content
endfun

fun! vfinder#helpers#empty_buffer(...) abort
    let buf_nr = exists('a:1') ? a:1 : bufnr('%')
    return join(getbufline(buf_nr, 1, '$')) =~# '^\s*$'
endfun

fun! vfinder#helpers#black_hole() abort
    return '2> /dev/null'
endfun
