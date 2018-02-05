" Creation         : 2018-02-04
" Last modification: 2018-02-04

fun! vfinder#sources#files#get() abort
    return {
                \   'cmd'   : 'rg --files --hidden --glob "!.git/"',
                \ }
endfun
