" Creation         : 2018-02-11
" Last modification: 2018-11-18


fun! vfinder#sources#oldfiles#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#oldfiles#get(...) abort " {{{1
    call s:oldfiles_define_maps()
    return {
                \   'name'         : 'oldfiles',
                \   'to_execute'   : s:oldfiles_source(),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'filter_name'  : 'match_position',
                \   'maps'         : s:oldfiles_maps(),
                \ }
endfun
" 1}}}

fun! s:oldfiles_source() abort " {{{1
    return filter(copy(v:oldfiles), {i, v ->
                \   filereadable(expand(v))
                \   && vfinder#sources#oldfiles#file_is_valid(v)
                \ })
endfun
" 1}}}

fun! vfinder#sources#oldfiles#file_is_valid(f) abort " {{{1
    return a:f !~#  '/vim.*/doc/' ? 1 : 0
endfun
" 1}}}

fun! s:oldfiles_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('oldfiles')
    let maps.i = {
                \ keys.i.edit  : {'action': 'edit %s', 'options': {}},
                \ keys.i.split : {'action': 'split %s', 'options': {}},
                \ keys.i.vsplit: {'action': 'vertical split %s', 'options': {}},
                \ keys.i.tab   : {'action': 'tabedit %s', 'options': {}}
                \ }
    let maps.n = {
                \ keys.n.edit  : {'action': 'edit %s', 'options': {}},
                \ keys.n.split : {'action': 'split %s', 'options': {}},
                \ keys.n.vsplit: {'action': 'vertical split %s', 'options': {}},
                \ keys.n.tab   : {'action': 'tabedit %s', 'options': {}}
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
                \       'tab'              : '<C-t>',
                \       'toggle_git_flags' : '<C-g>'
                \   },
                \   'n': {
                \       'edit'             : '<CR>',
                \       'split'            : 's',
                \       'vsplit'           : 'v',
                \       'tab'              : 't',
                \       'toggle_git_flags' : 'gi'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
