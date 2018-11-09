" Creation         : 2018-02-19
" Last modification: 2018-03-25


fun! vfinder#sources#colors#check() " {{{1
    return v:true
endfun
" 1}}}

fun! vfinder#sources#colors#get() abort " {{{1
    return {
                \   'name'         : 'colors',
                \   'to_execute'   : function('s:colors_source'),
                \   'maps'         : vfinder#sources#colors#maps()
                \ }
endfun
" 1}}}

fun! s:colors_source() abort " {{{1
    return getcompletion('', 'color')
endfun
" 1}}}

fun! vfinder#sources#colors#maps() abort " {{{1
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
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
