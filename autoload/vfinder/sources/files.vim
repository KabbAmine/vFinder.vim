" Creation         : 2018-02-04
" Last modification: 2018-02-10


fun! vfinder#sources#files#check()
    return v:true
endfun

fun! vfinder#sources#files#get() abort
    return {
                \   'name'      : 'files',
                \   'to_execute': s:files_source(),
                \   'format_fun': function('s:files_format'),
                \   'maps'      : s:files_maps(),
                \ }
endfun

fun! s:files_source() abort
    return executable('rg') ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag') ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : 'find * -type f'
endfun

" Just an example
fun! s:files_format(candidates) abort
    return a:candidates
endfun

fun! s:files_maps() abort
    let insert_maps = {
                \ "\<CR>": {
                \	'action': 'edit %s',
                \	'mode': 'insert',
                \       'options': {'quit': 1},
                \       },
                \ "\<C-s>": {
                \	'action': 'split %s',
                \	'mode': 'insert',
                \       'options': {'quit': 1},
                \       },
                \ "\<C-v>": {
                \	'action': 'vertical split %s',
                \	'mode': 'insert',
                \       'options': {'quit': 1},
                \       },
                \ "\<C-t>": {
                \	'action': 'tabedit %s',
                \	'mode': 'insert',
                \       'options': {'quit': 1},
                \       }
                \ }
    let normal_maps = {
                \ "\<CR>": {
                \	'action': 'edit %s',
                \	'mode': 'normal',
                \       'options': {'quit': 1},
                \       },
                \ 's': {
                \	'action': 'split %s',
                \	'mode': 'normal',
                \       'options': {'quit': 1},
                \       },
                \ 'v': {
                \	'action': 'vertical split %s',
                \	'mode': 'normal',
                \       'options': {'quit': 1},
                \       },
                \ 't': {
                \	'action': 'tabedit %s',
                \	'mode': 'normal',
                \       'options': {'quit': 1},
                \       }
                \ }
    return extend(insert_maps, normal_maps)
endfun
