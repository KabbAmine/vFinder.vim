" Creation         : 2018-02-16
" Last modification: 2018-10-25


fun! vfinder#sources#mru#check()
    return v:true
endfun

fun! vfinder#sources#mru#get() abort
    return {
                \   'name'         : 'mru',
                \   'to_execute'   : function('s:mru_source'),
                \   'format_fun'   : function('s:mru_format'),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'maps'         : s:mru_maps()
                \ }
endfun

fun! s:mru_source() abort
    let files = vfinder#cache#get_and_set_elements('mru', 100)
    return filter(copy(files), {i, v ->
                \   filereadable(v)
                \   && vfinder#sources#oldfiles#file_is_valid(v)
                \ })
endfun

fun! s:mru_format(files) abort
    return map(copy(a:files), 'fnamemodify(v:val, ":~")')
endfun

fun! s:mru_maps() abort
    let maps = {}
    let keys = vfinder#maps#get('mru')
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
