" Creation         : 2018-02-11
" Last modification: 2018-11-19


fun! vfinder#sources#oldfiles#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#oldfiles#get(...) abort " {{{1
    call s:oldfiles_define_maps()
    " TODO: filter_name
    return {
                \   'name'         : 'oldfiles',
                \   'to_execute'   : s:oldfiles_source(),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_filepath'),
                \   'filter_name'  : 'match_position',
                \   'maps'         : s:oldfiles_maps(),
                \ }
endfun
" 1}}}

fun! s:oldfiles_source() abort " {{{1
    return filter(copy(v:oldfiles), {i, v ->
                \   filereadable(expand(v))
                \   && vfinder#global#file_is_valid(v)
                \ })
endfun
" 1}}}

fun! s:oldfiles_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('oldfiles')
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

fun! s:oldfiles_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('oldfiles', {
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
