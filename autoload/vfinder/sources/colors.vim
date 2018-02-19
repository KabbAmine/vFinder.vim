" Creation         : 2018-02-19
" Last modification: 2018-02-19


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
    return {
                \   'i': {
                \       '<CR>' : {'action': 'colorscheme %s', 'options': {'silent': 0}},
                \       '<C-o>': {'action': 'colorscheme %s', 'options': {'silent': 0, 'quit': 0}}
                \   },
                \   'n': {
                \       '<CR>' : {'action': 'colorscheme %s', 'options': {'silent': 0}},
                \       'o'    : {'action': 'colorscheme %s', 'options': {'silent': 0, 'quit': 0}}
                \   }
                \ }
endfun
