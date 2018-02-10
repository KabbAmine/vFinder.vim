" Creation         : 2018-02-11
" Last modification: 2018-02-11


fun! vfinder#sources#tags#check()
    return v:true
endfun

fun! vfinder#sources#tags#get() abort
    return {
                \   'name'         : 'tags',
                \   'to_execute'   : function('s:tags_source'),
                \   'format_fun'   : function('s:tags_format'),
                \   'candidate_fun': function('s:tags_candidate_fun'),
                \   'maps'         : s:tags_maps(),
                \ }
endfun

fun! s:tags_source() abort
    return taglist('.*')
endfun

fun! s:tags_format(tags) abort
    let res = []
    for t in a:tags
        let l = printf('%-25s %s', t.name, fnamemodify(t.filename, ':~'))
        call add(res, l)
    endfor
    return res
endfun

fun! s:tags_candidate_fun() abort
    return matchstr(getline('.'), '^.*\ze\s\+\f\+')
endfun

fun! s:tags_maps() abort
    let maps = {}
    let maps.i = {
                \ '<CR>' : {'action': 'tag %s', 'options': {'quit': 1}},
                \ '<C-s>': {'action': 'split \| tag %s', 'options': {'quit': 1}},
                \ '<C-v>': {'action': 'vertical split \| tag %s', 'options': {'quit': 1}},
                \ '<C-o>': {'action': 'ptag %s', 'options': {'quit': 1}},
                \ }
    let maps.n = {
                \ '<CR>': {'action': 'tag %s', 'options': {'quit': 1}},
                \ 's'   : {'action': 'split \| tag %s', 'options': {'quit': 1}},
                \ 'v'   : {'action': 'vertical split \| tag %s', 'options': {'quit': 1}},
                \ 'o'   : {'action': 'ptag %s', 'options': {'quit': 1}},
                \ }
    return maps
endfun
