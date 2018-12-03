" Creation         : 2018-02-10
" Last modification: 2018-12-03


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#buffers#get(...) abort " {{{1
    call s:buffers_define_maps()
    return {
                \   'name'         : 'buffers',
                \   'to_execute'   : function('s:buffers_source'),
                \   'format_fun'   : function('s:buffers_format'),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_index'),
                \   'syntax_fun'   : function('s:buffers_syntax_fun'),
                \   'maps'         : s:buffers_maps()
                \ }
endfun
" 1}}}

fun! s:buffers_source() abort " {{{1
    let list_all = get(b:vf.flags, 'list_all', 0)
    let all_bufs = range(1, bufnr('$'))
    let bufs = list_all
                \ ? filter(all_bufs, 'bufexists(v:val)')
                \ : filter(all_bufs, 'buflisted(v:val)')
    let nrs = []
    for nr in bufs
        if nr isnot# bufnr('%')
            call add(nrs, nr)
        endif
    endfor
    let b:vf.flags.list_all = list_all
    return nrs
endfun
" 1}}}

fun! s:buffers_format(nrs) abort " {{{1
    let res = []
    for nr in a:nrs
        let name = vfinder#helpers#get_bufname(nr)
        let was_modified = getbufvar(nr, '&modified', 0)
        call add(res, printf('%-4d %3s %-30s %s',
                    \   nr . '.',
                    \   was_modified ? '[+]' : '',
                    \   fnamemodify(name, ':t'),
                    \   fnamemodify(name, ':h') . '/'
                    \ )
                    \ )
    endfor
    return res
endfun
" 1}}}

fun! s:buffers_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('buffers')
    let actions = extend(vfinder#actions#get('buffers'), {
                \ 'toggle_all': {
                \   'action' : function('s:toggle_all'),
                \   'options': {'function': 1, 'flag': 1, 'update': 1, 'quit': 0}
                \ }})
    let maps.i = {
                \ keys.i.edit      : actions.edit,
                \ keys.i.split     : actions.split,
                \ keys.i.vsplit    : actions.vsplit,
                \ keys.i.tab       : actions.tab,
                \ keys.i.wipe      : actions.wipe,
                \ keys.i.toggle_all: actions.toggle_all
                \ }
    let maps.n = {
                \ keys.n.edit      : actions.edit,
                \ keys.n.split     : actions.split,
                \ keys.n.vsplit    : actions.vsplit,
                \ keys.n.tab       : actions.tab,
                \ keys.n.wipe      : actions.wipe,
                \ keys.n.toggle_all: actions.toggle_all
                \ }
    return maps
endfun
" 1}}}

fun! s:buffers_syntax_fun() abort " {{{1
    syntax match vfinderBuffersModified =\%>1l\[+\]=
    syntax match vfinderBuffersName =\%>1l\%>9c\zs.*\s\{2,\}=
    highlight! link vfinderBuffersName Statement
    highlight! link vfinderBuffersModified Identifier
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:toggle_all(buffer) abort " {{{1
    let b:vf.flags.list_all = !b:vf.flags.list_all
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:buffers_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('buffers', {
                \   'i': {
                \       'edit'      : '<CR>',
                \       'split'     : '<C-s>',
                \       'vsplit'    : '<C-v>',
                \       'tab'       : '<C-t>',
                \       'wipe'      : '<C-d>',
                \       'toggle_all': '<C-o>'
                \   },
                \   'n': {
                \       'edit'      : '<CR>',
                \       'split'     : 's',
                \       'vsplit'    : 'v',
                \       'tab'       : 't',
                \       'wipe'      : 'dd',
                \       'toggle_all': 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
