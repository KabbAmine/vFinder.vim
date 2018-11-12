" Creation         : 2018-02-11
" Last modification: 2018-11-12


fun! vfinder#sources#commands#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#commands#get() abort " {{{1
    call s:command_define_maps()
    return {
                \   'name'         : 'commands',
                \   'to_execute'   : s:commands_source(),
                \   'maps'         : vfinder#sources#commands#maps(),
                \ }
endfun
" 1}}}

fun! s:commands_source() abort " {{{1
    return getcompletion('', 'command')
endfun
" 1}}}

fun! vfinder#sources#commands#maps() abort " {{{1
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
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:command_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('commands', {
                \   'i': {
                \       'apply': '<CR>',
                \       'echo' : '<C-o>'
                \   },
                \   'n': {
                \       'apply': '<CR>',
                \       'echo' : 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
