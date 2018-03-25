" Creation         : 2018-02-11
" Last modification: 2018-03-25


fun! vfinder#sources#tags#check()
    return v:true
endfun

fun! vfinder#sources#tags#get() abort
    let is_valid = s:tags_is_valid()
    redraw!
    return {
                \   'name'         : 'tags',
                \   'is_valid'     : is_valid,
                \   'to_execute'   : function('s:tags_source'),
                \   'format_fun'   : function('s:tags_format'),
                \   'candidate_fun': function('s:tags_candidate_fun'),
                \   'syntax_fun'   : function('s:tags_syntax_fun'),
                \   'maps'         : vfinder#sources#tags#maps(),
                \ }
endfun

fun! s:tags_is_valid() abort
    let tag_count = 0
    let wc = executable('wc') ? 1 : 0
    for tf in tagfiles()
        let tag_count += wc
                    \ ? matchstr(split(system('wc -l ' . tf), "\n")[0], '^\d\+')
                    \ : len(readfile(tf))
    endfor
    if tag_count <=# 70000
        return 1
    else
        let info = 'There are near ' . tag_count . ' tags, which may freeze your editor'
        let question = 'Do you want to proceed?'
        let response = vfinder#helpers#question(info, question)
        return response =~# 'y\|Y' ? 1 : 0
    endif
endfun

fun! s:tags_source() abort
    return taglist('.*')
endfun

fun! s:tags_format(tags) abort
    let res = []
    for t in a:tags
        let l = printf('%-50s %s', t.name, fnamemodify(t.filename, ':~'))
        call add(res, l)
    endfor
    return res
endfun

fun! s:tags_candidate_fun() abort
    return escape(matchstr(getline('.'), '^.*\ze\s\+\f\+'), '"')
endfun

fun! s:tags_syntax_fun() abort
    syntax match vfinderTagsFilename =\f\+$=
    highlight! link vfinderTagsFilename vfinderIndex
endfun

fun! vfinder#sources#tags#maps() abort
    let maps = {}
    let keys = vfinder#maps#get('tags')
    let maps.i = {
                \ keys.i.goto         : {'action': 'tag %s', 'options': {}},
                \ keys.i.splitandgoto : {'action': 'stag %s', 'options': {}},
                \ keys.i.vsplitandgoto: {'action': 'vertical stag %s', 'options': {}},
                \ keys.i.preview      : {'action': 'ptag %s', 'options': {'quit': 0}},
                \ }
    let maps.n = {
                \ keys.n.goto         : {'action': 'tag %s', 'options': {}},
                \ keys.n.splitandgoto : {'action': 'stag %s', 'options': {}},
                \ keys.n.vsplitandgoto: {'action': 'vertical stag %s', 'options': {}},
                \ keys.n.preview      : {'action': 'ptag %s', 'options': {'quit': 0}},
                \ }
    return maps
endfun
