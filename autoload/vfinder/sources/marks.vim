" Creation         : 2018-03-31
" Last modification: 2018-10-28


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
    " Go to the initial window to get its marks
    silent execute bufwinnr(b:vf.initial_bufnr) . 'wincmd w'
    let marks = split(execute('marks'), "\n")[1:]
    silent execute 'wincmd p'
    return map(marks, {i, v -> substitute(v, '^\s\+', '', '')})
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
                \ keys.i.delete  : {
                \       'action': function('s:delete_mark'),
                \       'options': {'function': 1, 'silent': 0, 'quit': 0, 'update': 1}
                \       }
                \ }
    let maps.n = {
                \ keys.n.goto  : {'action': 'normal! ''%', 'options': {}},
                \ keys.n.delete  : {
                \       'action': function('s:delete_mark'),
                \       'options': {'function': 1, 'silent': 0, 'quit': 0, 'update': 1}
                \       }
                \ }
    return maps
endfun

fun! s:delete_mark(m) abort
    " Only A-Z and 0-9
    if a:m !~ '^\(\u\|\d\)$'
        call vfinder#helpers#echo('Only marks in range A-Z or 0-9 can be deleted', 'Error', 1)
        return ''
    endif
    execute 'delmarks ' . a:m
endfun
