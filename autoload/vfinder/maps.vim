" Creation         : 2018-03-25
" Last modification: 2018-03-25

fun! vfinder#maps#create(name, def_maps) abort
    let g:vfinder_maps[a:name] = get(g:vfinder_maps, a:name, {})
    let g:vfinder_maps[a:name].i = get(g:vfinder_maps[a:name], 'i', {})
    let g:vfinder_maps[a:name].i = extend(a:def_maps.i, g:vfinder_maps[a:name].i, 'force')
    let g:vfinder_maps[a:name].n = get(g:vfinder_maps[a:name], 'n', {})
    let g:vfinder_maps[a:name].n = extend(a:def_maps.n, g:vfinder_maps[a:name].n, 'force')
endfun

fun! vfinder#maps#get(name) abort
    return g:vfinder_maps[a:name]
endfun
