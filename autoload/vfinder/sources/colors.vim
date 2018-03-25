" Creation         : 2018-02-19
" Last modification: 2018-03-25


fun! vfinder#sources#colors#check()
    return v:true
endfun

fun! vfinder#sources#colors#get() abort
    return {
                \   'name'         : 'colors',
                \   'to_execute'   : function('s:colors_source'),
                \   'maps'         : vfinder#sources#colors#maps()
                \ }
endfun

fun! s:colors_source() abort
    return getcompletion('', 'color')
endfun

fun! vfinder#sources#colors#maps() abort
    let keys = vfinder#maps#get('colors')
    return {
                \   'i': {
                \       keys.i.apply  : {'action': 'colorscheme %s', 'options': {'silent': 0}},
                \       keys.i.preview: {'action': 'colorscheme %s', 'options': {'silent': 0, 'quit': 0}}
                \   },
                \   'n': {
                \       keys.n.apply: {'action': 'colorscheme %s', 'options': {'silent': 0}},
                \       keys.n.preview: {'action': 'colorscheme %s', 'options': {'silent': 0, 'quit': 0}}
                \   }
                \ }
endfun
