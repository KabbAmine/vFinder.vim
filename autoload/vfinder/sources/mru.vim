" Creation         : 2018-02-16
" Last modification: 2018-02-23


fun! vfinder#sources#mru#check()
    return v:true
endfun

fun! vfinder#sources#mru#get() abort
    return {
                \   'name'         : 'mru',
                \   'to_execute'   : function('s:mru_source'),
                \   'format_fun'   : function('s:mru_format'),
                \   'maps'         : vfinder#sources#files#maps()
                \ }
endfun

fun! s:mru_source() abort
    let files = g:vf_cache.mru
    if empty(files)
        let files = vfinder#cache#read('mru')
        let g:vf_cache.mru = files
    elseif len(files) ># 100
        let files = g:vf_cache.files[:99]
        let g:vf_cache.files = files
    endif
    return filter(copy(files), {i, v ->
                \   filereadable(v)
                \   && vfinder#sources#oldfiles#file_is_valid(v)
                \ })
endfun

fun! s:mru_format(files) abort
    return map(copy(a:files), 'fnamemodify(v:val, ":~")')
endfun
