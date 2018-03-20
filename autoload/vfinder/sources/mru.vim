" Creation         : 2018-02-16
" Last modification: 2018-03-16


fun! vfinder#sources#mru#check()
    return v:true
endfun

fun! vfinder#sources#mru#get() abort
    return {
                \   'name'         : 'mru',
                \   'to_execute'   : function('s:mru_source'),
                \   'format_fun'   : function('s:mru_format'),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'maps'         : vfinder#sources#files#maps()
                \ }
endfun

fun! s:mru_source() abort
    let files = vfinder#cache#get_and_set_elements('mru', 100)
    return filter(copy(files), {i, v ->
                \   filereadable(v)
                \   && vfinder#sources#oldfiles#file_is_valid(v)
                \ })
endfun

fun! s:mru_format(files) abort
    return map(copy(a:files), 'fnamemodify(v:val, ":~")')
endfun
