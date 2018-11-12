" Creation         : 2018-03-25
" Last modification: 2018-11-12


fun! vfinder#maps#get(name) abort " {{{1
    return g:vfinder_maps[a:name]
endfun
" 1}}}

fun! vfinder#maps#define_gvar_maps(name, def_maps) abort " {{{1
    let g:vfinder_maps[a:name] = get(g:vfinder_maps, a:name, {})
    let g:vfinder_maps[a:name].i = get(g:vfinder_maps[a:name], 'i', {})
    let g:vfinder_maps[a:name].i = extend(copy(a:def_maps.i), g:vfinder_maps[a:name].i, 'force')
    let g:vfinder_maps[a:name].n = get(g:vfinder_maps[a:name], 'n', {})
    let g:vfinder_maps[a:name].n = extend(copy(a:def_maps.n), g:vfinder_maps[a:name].n, 'force')
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
