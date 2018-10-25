" Creation         : 2018-02-11
" Last modification: 2018-10-25


fun! vfinder#sources#oldfiles#check()
    return v:true
endfun

fun! vfinder#sources#oldfiles#get() abort
    return {
                \   'name'         : 'oldfiles',
                \   'to_execute'   : s:oldfiles_source(),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'filter_name'  : 'match_position',
                \   'maps'         : s:oldfiles_maps(),
                \ }
endfun

fun! s:oldfiles_source() abort
    return filter(copy(v:oldfiles), {i, v ->
                \   filereadable(expand(v))
                \   && vfinder#sources#oldfiles#file_is_valid(v)
                \ })
endfun

fun! vfinder#sources#oldfiles#file_is_valid(f) abort
    return a:f !~#  '/vim.*/doc/' ? 1 : 0
endfun

fun! s:oldfiles_maps() abort
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
