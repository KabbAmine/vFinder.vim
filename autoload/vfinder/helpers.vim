" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#helpers#process_query(query) abort
    return join(split(escape(a:query, '.|*')), '.*')
endfun

fun! vfinder#helpers#Throw(msg) abort
    let v:errmsg = s:Msg(a:msg, 'error')
    throw v:errmsg
endfun

fun! vfinder#helpers#Echo(msg, higroup) abort
    let msg = a:msg =~# '^\V[vfinder]' ? a:msg : s:Msg(a:msg)
    silent execute 'echohl ' . a:higroup
    echomsg msg
    echohl None
endfun

fun! s:Msg(content, ...) abort
    let extra = exists('a:1') ? '[' . a:1 . '] ' : ''
    return '[vfinder] ' . extra . a:content
endfun
