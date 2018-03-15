" Creation         : 2018-02-10
" Last modification: 2018-03-15


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
    let nrs = []
    for nr in filter(range(1, bufnr('$')), 'buflisted(v:val)')
        call add(nrs, nr)
    endfor
    return nrs
endfun

fun! s:buffers_format(nrs) abort
    let res = []
    for nr in a:nrs
        let name = empty(bufname(nr)) ? '[No Name]' : fnamemodify(bufname(nr), ':.')
        let was_modified = getbufvar(nr, '&modified', 0)
        call add(res, printf('%-4d %3s %s',
                    \   nr,
                    \   was_modified ? '[+]' : '',
                    \   name)
                    \ )
    endfor
    return res
endfun

fun! s:buffers_candidate_fun() abort
    return matchstr(getline('.'), '^\d\+\ze')
endfun

fun! s:buffers_maps() abort
    let maps = {}
    let maps.i = {
                \ '<CR>' : {'action': 'buffer %s', 'options': {}},
                \ '<C-s>': {'action': 'sbuffer %s', 'options': {}},
                \ '<C-v>': {'action': 'vertical sbuffer %s', 'options': {}},
                \ '<C-t>': {'action': 'tabnew \| buffer %s', 'options': {}},
                \ '<C-d>': {
                \       'action': function('s:wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       },
                \ }
    let maps.n = {
                \ '<CR>' : {'action': 'buffer %s', 'options': {}},
                \ 's'    : {'action': 'sbuffer %s', 'options': {}},
                \ 'v'    : {'action': 'vertical sbuffer %s', 'options': {}},
                \ 't'    : {'action': 'tabnew \| buffer %s', 'options': {}},
                \ 'dd'   : {
                \       'action': function('s:wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       },
                \ }
    return maps
endfun

fun! s:buffers_syntax_fun() abort
    syntax match vfinderBuffersModified =\[+\]=
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
