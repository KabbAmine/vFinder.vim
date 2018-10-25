" Creation         : 2018-02-10
" Last modification: 2018-10-25


fun! vfinder#sources#buffers#check()
    return v:true
endfun

fun! vfinder#sources#buffers#get() abort
     return {
                \   'name'         : 'buffers',
                \   'to_execute'   : function('s:buffers_source'),
                \   'format_fun'   : function('s:buffers_format'),
                \   'candidate_fun': function('s:buffers_candidate_fun'),
                \   'syntax_fun'   : function('s:buffers_syntax_fun'),
                \   'maps'         : s:buffers_maps()
                \ }
endfun

fun! s:buffers_source() abort
    let list_hiddens = get(b:vf.flags, 'list_hiddens', 0)
    let all_bufs = range(1, bufnr('$'))
    let bufs = list_hiddens
                \ ? filter(all_bufs, 'bufexists(v:val)')
                \ : filter(all_bufs, 'buflisted(v:val)')
    let nrs = []
    for nr in bufs
        if nr isnot# bufnr('%')
            call add(nrs, nr)
        endif
    endfor
    let b:vf.flags.list_hiddens = list_hiddens
    return nrs
endfun

fun! s:buffers_format(nrs) abort
    let res = []
    for nr in a:nrs
        let name = empty(bufname(nr)) ? '[No Name]' : fnamemodify(bufname(nr), ':.')
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

fun! s:buffers_candidate_fun() abort
    return matchstr(getline('.'), '^\d\+\ze')
endfun

fun! s:buffers_maps() abort
    let maps = {}
    let keys = vfinder#maps#get('buffers')
    let maps.i = {
                \ keys.i.edit        : {'action': 'buffer %s', 'options': {}},
                \ keys.i.split       : {'action': 'sbuffer %s', 'options': {}},
                \ keys.i.vsplit      : {'action': 'vertical sbuffer %s', 'options': {}},
                \ keys.i.tab         : {'action': 'tabnew \| buffer %s', 'options': {}},
                \ keys.i.wipe        : {
                \       'action': function('s:wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       },
                \ keys.i.toggle_hiddens: {
                \       'action': function('s:toggle_hiddens'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       },
                \ }
    let maps.n = {
                \ keys.n.edit        : {'action': 'buffer %s', 'options': {}},
                \ keys.n.split       : {'action': 'sbuffer %s', 'options': {}},
                \ keys.n.vsplit      : {'action': 'vertical sbuffer %s', 'options': {}},
                \ keys.n.tab         : {'action': 'tabnew \| buffer %s', 'options': {}},
                \ keys.n.wipe        : {
                \       'action': function('s:wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       },
                \ keys.n.toggle_hiddens: {
                \       'action': function('s:toggle_hiddens'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       },
                \ }
    return maps
endfun

fun! s:buffers_syntax_fun() abort
    syntax match vfinderBuffersModified =\[+\]=
    syntax match vfinderBuffersName =\%>1l\v(\f+|\[No\ Name\])\ze\s+\f+$=
    highlight! link vfinderBuffersName Statement
    highlight! link vfinderBuffersModified Identifier
endfun

fun! s:wipe(buffer) abort
    let b = str2nr(a:buffer)
    if bufexists(b)
        try
            execute b . 'bwipeout'
        catch
        endtry
    endif
endfun

fun! s:toggle_hiddens(buffer) abort
    let b:vf.flags.list_hiddens = b:vf.flags.list_hiddens
                \ ? 0
                \ : 1
endfun
