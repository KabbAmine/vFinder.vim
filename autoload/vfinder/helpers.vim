" Creation         : 2018-02-04
" Last modification: 2018-10-29


let s:title = '[vfinder]'
let s:title_hi = 'vfinderPrompt'

fun! vfinder#helpers#go_to_prompt_and_startinsert()
    call cursor(1, 0)
    startinsert!
endfun

fun! vfinder#helpers#is_in_prompt()
    return line('.') is# 1 ? 1 : 0
endfun

fun! vfinder#helpers#process_query(query) abort
    let q = b:vf.fuzzy
                \ ? substitute(a:query, ' ', '', 'g')
                \ : a:query
    let q_sep = b:vf.fuzzy ? '\zs' : ' '
    let join_pat = '.{-}'
    let to_escape = '@=?+&$.*~()|{}%[]'
    let final_regex = []
    for item in split(q, q_sep)
        call add(final_regex, escape(item, to_escape))
    endfor
    return '\v' . join(final_regex, join_pat)
endfun

fun! vfinder#helpers#throw(msg, ...) abort
    let in_messages = get(a:, 1, 0)
    try
        throw '--vf-- ' . a:msg
    catch =\V--vf--=
        " Remove the --vf--
        let err_msg = v:exception[7:]
        if in_messages
            call vfinder#helpers#echomsg(err_msg, 'Error')
        else
            call vfinder#helpers#echo(err_msg, 'Error')
        endif
    endtry
endfun

fun! vfinder#helpers#echomsg(msg, ...) abort
    let higroup = get(a:, 1, s:title_hi)
    silent execute 'echohl ' . higroup
    echomsg s:title . ' ' . a:msg
    echohl None
endfun

fun! vfinder#helpers#echo(msg, ...) abort
    " a:1: higroup
    " a:2: optional msg, respect or not g:vfinder_verbose

    let higroup = empty(get(a:, 1, ''))
                \ ? s:title_hi
                \ : a:1
    let optional = get(a:, 2, 0)

    if optional && !g:vfinder_verbose
        return ''
    endif
    execute 'echohl ' . higroup
    echon s:title . ' '
    echohl None | echon a:msg
endfun

fun! vfinder#helpers#question(msg, prompt) abort
    echohl Question
    echon s:title . ' '
    echohl None
    echon a:msg
    let response = input(a:prompt)
    return response
endfun

fun! vfinder#helpers#empty_buffer(...) abort
    let buf_nr = exists('a:1') ? a:1 : bufnr('%')
    return join(getbufline(buf_nr, 1, '$')) =~# '^\s*$'
endfun

fun! vfinder#helpers#black_hole() abort
    return '2> /dev/null'
endfun

fun! vfinder#helpers#get_maps_str_for(name) abort
    if &filetype isnot# 'vfinder'
        return ''
    endif
    if !exists('g:vfinder_maps[a:name]')
        return ''
    endif
    let maps = vfinder#maps#get(a:name)
    let str = ' ' . (a:name is# '_' ? 'global' : a:name) . ': '
    for a in keys(maps.i)
        if a =~# '^\(prompt\|window\)'
            " Do not save the prompt-*/window-* mappings
            continue
        endif
        let str .= printf('%s(%s/%s) | ',
                    \   a,
                    \   get(maps.i, a, '-'),
                    \   get(maps.n, a, '-')
                    \ )
    endfor
    " Remove the last ' | '
    return str[:-4]
endfun
