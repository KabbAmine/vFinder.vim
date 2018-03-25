" Creation         : 2018-02-11
" Last modification: 2018-03-25


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
    let keys = vfinder#maps#get('commands')
    return {
                \   'i': {
                \       keys.i.apply: {'action': '%s', 'options': {'silent': 0}},
                \       keys.i.echo : {'action': '%s', 'options': {'silent': 0, 'echo': 1}}
                \   },
                \   'n': {
                \       keys.n.apply: {'action': '%s', 'options': {'silent': 0}},
                \       keys.n.echo : {'action': '%s', 'options': {'silent': 0, 'echo': 1}}
                \   }
                \ }
endfun
