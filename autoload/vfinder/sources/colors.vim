" Creation         : 2018-02-19
" Last modification: 2018-11-30


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#colors#get(...) abort " {{{1
    call s:colors_define_maps()
    return {
                \   'name'         : 'colors',
                \   'to_execute'   : function('s:colors_source'),
                \   'maps'         : s:colors_maps()
                \ }
endfun
" 1}}}

fun! s:colors_source() abort " {{{1
    return getcompletion('', 'color')
endfun
" 1}}}

fun! s:colors_maps() abort " {{{1
    let keys = vfinder#maps#get('colors')
    let actions = vfinder#actions#get('colors')
    return {
                \   'i': {
                \       keys.i.apply  : actions.apply,
                \       keys.i.preview: actions.preview
                \   },
                \   'n': {
                \       keys.n.apply  : actions.apply,
                \       keys.n.preview: actions.preview
                \   }
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:colors_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('colors', {
                \   'i': {
                \       'apply'  : '<CR>',
                \       'preview': '<C-o>'
                \   },
                \   'n': {
                \       'apply'  : '<CR>',
                \       'preview': 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
