" Creation         : 2018-02-10
" Last modification: 2018-02-10


fun! vfinder#sources#buffers#check()
    return v:true
endfun

fun! vfinder#sources#buffers#get() abort
     return {
                \   'name'         : 'buffers',
                \   'to_execute'   : function('s:buffers_source'),
                \   'format_fun'   : function('s:buffers_format'),
                \   'candidate_fun': function('s:buffers_candidate_fun'),
                \   'maps'         : s:buffers_maps(),
                \ }
endfun

fun! s:buffers_source() abort
    let nrs = []
    for nr in filter(range(1, bufnr('$')), 'buflisted(v:val)')
        call add(nrs, nr)
    endfor
    return nrs
endfun

fun! s:buffers_format(nrs) abort
    let res = []
    for nr in a:nrs
        let name = empty(bufname(nr)) ? '[No Name]' : fnamemodify(bufname(nr), ':.')
        call add(res, printf("%-5d %s", nr, name))
    endfor
    return res
endfun

fun! s:buffers_candidate_fun() abort
    return matchstr(getline('.'), '^\d\+\s\+\zs.*')
endfun

fun! s:buffers_maps() abort
    let maps = vfinder#sources#files#maps()
    call extend(maps.i, {
                \ '<C-d>' : {
                \       'action': 'bwipeout! %s',
                \       'options': {'update': 1, 'quit': 0}},
                \ })
    call extend(maps.n, {
                \ 'dd' : {
                \       'action': 'bwipeout! %s',
                \       'options': {'update': 1, 'quit': 0}},
                \ })
    return maps
endfun
