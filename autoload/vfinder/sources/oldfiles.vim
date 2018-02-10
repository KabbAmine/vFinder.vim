" Creation         : 2018-02-11
" Last modification: 2018-02-11


fun! vfinder#sources#oldfiles#check()
    return v:true
endfun

fun! vfinder#sources#oldfiles#get() abort
    return {
                \   'name'         : 'oldfiles',
                \   'to_execute'   : s:oldfiles_source(),
                \   'maps'         : s:oldfiles_maps(),
                \ }
endfun

fun! s:oldfiles_source() abort
    return filter(copy(v:oldfiles), 'filereadable(expand(v:val)) && v:val !~# "/vim.*/doc/"')
endfun

fun! s:oldfiles_maps() abort
    return vfinder#source#i('files').maps
endfun