" Creation         : 2018-02-11
" Last modification: 2018-04-19


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
    let [names, res] = [[], []]
    for t in a:tags
        let name = t.name
        call add(names, name)
        let count_int = count(names, name)
        call add(res, printf('%-2s %-50s %s',
                    \   (count_int ># 1 ? string(count_int) : ''),
                    \   name,
                    \   fnamemodify(t.filename, ':~')
                    \ ))
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
                \ keys.i.goto         : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.i.splitandgoto : {'action': function('s:splitandgoto'), 'options': {'function': 1}},
                \ keys.i.vsplitandgoto: {'action': function('s:vsplitandgoto'), 'options': {'function': 1}},
                \ keys.i.preview      : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    let maps.n = {
                \ keys.n.goto         : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.n.splitandgoto : {'action': function('s:splitandgoto'), 'options': {'function': 1}},
                \ keys.n.vsplitandgoto: {'action': function('s:vsplitandgoto'), 'options': {'function': 1}},
                \ keys.n.preview      : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    return maps
endfun

fun! s:get_count_and_name(str) abort
    return [
                \   matchstr(a:str, '^\d\+'),
                \   matchstr(a:str, '^\d*\s\+\zs.*$')
                \ ]
endfun

fun! s:gototag(tag) abort
    let [c, name] = s:get_count_and_name(a:tag)
    silent execute c . 'tag ' . name
endfun

fun! s:splitandgoto(tag) abort
    let [c, name] = s:get_count_and_name(a:tag)
    silent execute c . 'stag ' . name
endfun

fun! s:vsplitandgoto(tag) abort
    let [c, name] = s:get_count_and_name(a:tag)
    silent execute 'vertical ' . c . 'stag ' . name
endfun

fun! s:preview(tag) abort
    let [c, name] = s:get_count_and_name(a:tag)
    silent execute c . 'ptag ' . name
endfun
