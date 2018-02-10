" Creation         : 2018-02-04
" Last modification: 2018-02-11


fun! vfinder#sources#files#check()
    return v:true
endfun

fun! vfinder#sources#files#get() abort
    return {
                \   'name'         : 'files',
                \   'to_execute'   : s:files_source(),
                \   'maps'         : s:files_maps(),
                \ }
endfun

fun! s:files_source() abort
    return executable('rg') ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag') ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : 'find * -type f'
endfun

fun! s:files_maps() abort
    let maps = {}
    let maps.i = {
                \ '<CR>' : {'action': 'edit %s', 'options': {'quit': 1}},
                \ '<C-s>': {'action': 'split %s', 'options': {'quit': 1}},
                \ '<C-v>': {'action': 'vertical split %s', 'options': {'quit': 1}},
                \ '<C-t>': {'action': 'tabedit %s', 'options': {'quit': 1}}
                \ }
    let maps.n = {
                \ '<CR>': {'action': 'edit %s', 'options': {'quit': 1}},
                \ 's'    : {'action': 'split %s', 'options': {'quit': 1}},
                \ 'v'    : {'action': 'vertical split %s', 'options': {'quit': 1}},
                \ 't'    : {'action': 'tabedit %s', 'options': {'quit': 1}}
                \ }
    return maps
endfun
