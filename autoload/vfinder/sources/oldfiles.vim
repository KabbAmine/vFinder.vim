" Creation         : 2018-02-11
" Last modification: 2018-02-28


fun! vfinder#sources#oldfiles#check()
    return v:true
endfun

fun! vfinder#sources#oldfiles#get() abort
    return {
                \   'name'         : 'oldfiles',
                \   'to_execute'   : s:oldfiles_source(),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'maps'         : vfinder#sources#files#maps(),
                \ }
endfun

fun! s:oldfiles_source() abort
    return filter(copy(v:oldfiles), {i, v ->
                \   filereadable(expand(v))
                \   && vfinder#sources#oldfiles#file_is_valid(v)
                \ })
endfun

fun! vfinder#sources#oldfiles#file_is_valid(f) abort
    return a:f !~#  '/vim.*/doc/' ? 1 : 0
endfun
