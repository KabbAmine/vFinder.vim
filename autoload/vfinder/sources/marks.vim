" Creation         : 2018-03-31
" Last modification: 2018-03-31


fun! vfinder#sources#marks#check()
    return v:true
endfun

fun! vfinder#sources#marks#get() abort
    return {
                \   'name'         : 'marks',
                \   'to_execute'   : function('s:marks_source'),
                \   'candidate_fun': function('s:marks_candidate_fun'),
                \   'syntax_fun'   : function('s:marks_syntax_fun'),
                \   'maps'         : vfinder#sources#marks#maps(),
                \ }
endfun

fun! s:marks_source() abort
    let marks = split(execute('marks'), "\n")[1:]
    let marks = map(copy(marks), {i, v -> substitute(v, '^\s\+', '', '')})
    return marks
endfun

fun! s:marks_candidate_fun() abort
    return matchstr(getline('.'), '^\S\+')
endfun

fun! s:marks_syntax_fun() abort
    syntax match vfinderMarksLine =\%>1l^\S\+\s\+\d\+\s\+\d\+\s\+=
    highlight! link vfinderMarksLine vfinderIndex
endfun

fun! vfinder#sources#marks#maps() abort
    let maps = {}
    let keys = vfinder#maps#get('marks')
    let maps.i = {
                \ keys.i.goto  : {'action': 'normal! ''%s', 'options': {}},
                \ }
    let maps.n = {
                \ keys.n.goto  : {'action': 'normal! ''%', 'options': {}},
                \ }
    return maps
endfun
