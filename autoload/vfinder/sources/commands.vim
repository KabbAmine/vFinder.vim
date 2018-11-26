" Creation         : 2018-02-11
" Last modification: 2018-11-27


fun! vfinder#sources#commands#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#commands#get(...) abort " {{{1
    call s:command_define_maps()
    return {
                \   'name'         : 'commands',
                \   'to_execute'   : s:commands_source(),
                \   'maps'         : s:commands_maps(),
                \ }
endfun
" 1}}}

fun! s:commands_source() abort " {{{1
    return getcompletion('', 'command')
endfun
" 1}}}

fun! s:commands_maps() abort " {{{1
    let keys = vfinder#maps#get('commands')
    let actions = vfinder#actions#get('commands')
    return {
                \   'i': {
                \       keys.i.execute: actions.execute,
                \       keys.i.echo : actions.echo
                \   },
                \   'n': {
                \       keys.n.execute: actions.execute,
                \       keys.n.echo : actions.echo
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
                \       'execute': '<CR>',
                \       'echo'   : '<C-o>'
                \   },
                \   'n': {
                \       'execute': '<CR>',
                \       'echo'   : 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
