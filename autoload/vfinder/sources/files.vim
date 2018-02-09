" Creation         : 2018-02-04
" Last modification: 2018-02-04

fun! vfinder#sources#files#get() abort
    let cmd = executable('rg') ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag') ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : 'find * -type f'
    return {
                \   'cmd': cmd,
                \ }
endfun
