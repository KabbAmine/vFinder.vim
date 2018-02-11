" Creation         : 2018-02-11
" Last modification: 2018-02-11


fun! vfinder#sources#commands#check()
    return v:true
endfun

fun! vfinder#sources#commands#get() abort
    return {
                \   'name'         : 'commands',
                \   'to_execute'   : s:commands_source(),
                \   'maps'         : vfinder#sources#commands#maps(),
                \ }
endfun

fun! s:commands_source() abort
    return getcompletion('', 'command')
endfun

fun! vfinder#sources#commands#maps() abort
    return {
                \   'i': {'<CR>' : {'action': '%s', 'options': {'quit': 1}}},
                \   'n': {'<CR>' : {'action': '%s', 'options': {'quit': 1}}},
                \ }
endfun
