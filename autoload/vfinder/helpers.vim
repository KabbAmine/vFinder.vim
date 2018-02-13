" Creation         : 2018-02-04
" Last modification: 2018-02-13


fun! vfinder#helpers#go_to_prompt()
    call cursor(1, 0)
    startinsert!
endfun

fun! vfinder#helpers#is_in_prompt()
    return line('.') is# 1 ? 1 : 0
endfun

fun! vfinder#helpers#process_query(query) abort
    return join(split(escape(a:query, '.|*')), '.*')
endfun

fun! vfinder#helpers#throw(msg) abort
    let v:errmsg = s:Msg(a:msg, 'error')
    throw v:errmsg
endfun

fun! vfinder#helpers#echo(msg, higroup, ...) abort
    if g:vfinder_verbose || exists('a:1') && a:1
        let msg = a:msg =~# '^\V[vfinder]' ? a:msg : s:Msg(a:msg)
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

fun! s:Msg(content, ...) abort
    let extra = exists('a:1') ? '[' . a:1 . '] ' : ''
    return '[vfinder] ' . extra . a:content
endfun
