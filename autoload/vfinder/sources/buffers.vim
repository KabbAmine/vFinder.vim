" Creation         : 2018-02-10
" Last modification: 2018-11-12


fun! vfinder#sources#buffers#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#buffers#get() abort " {{{1
     return {
                \   'name'         : 'buffers',
                \   'to_execute'   : function('s:buffers_source'),
                \   'format_fun'   : function('s:buffers_format'),
                \   'candidate_fun': function('s:buffers_candidate_fun'),
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
        let name = empty(bufname(nr))
                    \ ? '[No Name]'
                    \ : fnamemodify(bufname(nr), ':.')
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

fun! s:buffers_candidate_fun() abort " {{{1
    return matchstr(getline('.'), '^\d\+\ze')
endfun
" 1}}}

fun! s:buffers_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('buffers')
    let options = {'silent': 0}
    let maps.i = {
                \ keys.i.edit        : {'action': 'buffer %s', 'options': options},
                \ keys.i.split       : {'action': 'sbuffer %s', 'options': options},
                \ keys.i.vsplit      : {'action': 'vertical sbuffer %s', 'options': options},
                \ keys.i.tab         : {'action': 'tabnew \| buffer %s', 'options': options},
                \ keys.i.wipe        : {
                \       'action': function('s:wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       },
                \ keys.i.toggle_all: {
                \       'action': function('s:toggle_all'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       },
                \ }
    let maps.n = {
                \ keys.n.edit        : {'action': 'buffer %s', 'options': options},
                \ keys.n.split       : {'action': 'sbuffer %s', 'options': options},
                \ keys.n.vsplit      : {'action': 'vertical sbuffer %s', 'options': options},
                \ keys.n.tab         : {'action': 'tabnew \| buffer %s', 'options': options},
                \ keys.n.wipe        : {
                \       'action': function('s:wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       },
                \ keys.n.toggle_all: {
                \       'action': function('s:toggle_all'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       },
                \ }
    return maps
endfun
" 1}}}

fun! s:buffers_syntax_fun() abort " {{{1
    syntax match vfinderBuffersModified =\[+\]=
    syntax match vfinderBuffersName =\%>9c\zs.*\s\{2,\}=
    highlight! link vfinderBuffersName Statement
    highlight! link vfinderBuffersModified Identifier
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:wipe(buffer) abort " {{{1
    let b = str2nr(a:buffer)
    if bufexists(b)
        unsilent execute b . 'bwipeout'
    endif
endfun
" 1}}}

fun! s:toggle_all(buffer) abort " {{{1
    let b:vf.flags.list_all = !b:vf.flags.list_all
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
