" Creation         : 2018-02-16
" Last modification: 2018-11-19


fun! vfinder#sources#mru#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#mru#get(...) abort " {{{1
    call s:mru_define_maps()
    return {
                \   'name'         : 'mru',
                \   'to_execute'   : function('s:mru_source'),
                \   'format_fun'   : function('s:mru_format'),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_filepath'),
                \   'maps'         : s:mru_maps()
                \ }
endfun
" 1}}}

fun! s:mru_source() abort " {{{1
    let files = vfinder#cache#get_and_set_elements('mru', 500)
    return filter(copy(files), {i, v ->
                \   filereadable(v)
                \   && vfinder#global#file_is_valid(v)
                \ })
endfun
" 1}}}

fun! s:mru_format(files) abort " {{{1
    return map(copy(a:files), 'fnamemodify(v:val, ":~")')
endfun
" 1}}}

fun! s:mru_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('mru')
    let actions = vfinder#actions#get('files')
    let maps.i = {
                \   keys.i.edit  : actions.edit,
                \   keys.i.split : actions.split,
                \   keys.i.vsplit: actions.vsplit,
                \   keys.i.tab   : actions.tab
                \ }
    let maps.n = {
                \   keys.n.edit  : actions.edit,
                \   keys.n.split : actions.split,
                \   keys.n.vsplit: actions.vsplit,
                \   keys.n.tab   : actions.tab
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:mru_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('mru', {
                \   'i': {
                \       'edit'             : '<CR>',
                \       'split'            : '<C-s>',
                \       'vsplit'           : '<C-v>',
                \       'tab'              : '<C-t>'
                \   },
                \   'n': {
                \       'edit'             : '<CR>',
                \       'split'            : 's',
                \       'vsplit'           : 'v',
                \       'tab'              : 't'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
