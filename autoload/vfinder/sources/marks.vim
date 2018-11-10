" Creation         : 2018-03-31
" Last modification: 2018-11-10


fun! vfinder#sources#marks#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#marks#get() abort " {{{1
    return {
                \   'name'         : 'marks',
                \   'to_execute'   : function('s:marks_source'),
                \   'candidate_fun': function('s:marks_candidate_fun'),
                \   'syntax_fun'   : function('s:marks_syntax_fun'),
                \   'maps'         : vfinder#sources#marks#maps(),
                \ }
endfun
" 1}}}

fun! s:marks_source() abort " {{{1
    " Go to the initial window to get its marks
    silent execute bufwinnr(b:vf.initial_bufnr) . 'wincmd w'
    let marks = split(execute('marks'), "\n")[1:]
    silent execute 'wincmd p'
    return map(marks, {i, v -> substitute(v, '^\s\+', '', '')})
endfun
" 1}}}

fun! s:marks_candidate_fun() abort " {{{1
    return matchstr(getline('.'), '^\S\+')
endfun
" 1}}}

fun! s:marks_syntax_fun() abort " {{{1
    syntax match vfinderMarksLine =\%>1l^\S\+\s\+\d\+\s\+\d\+\s\+=
    highlight! link vfinderMarksLine vfinderIndex
endfun
" 1}}}

fun! vfinder#sources#marks#maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('marks')
    let maps.i = {
                \ keys.i.goto  : {
                \       'action': function('s:go_to_mark'),
                \       'options': {'function': 1}
                \       },
                \ keys.i.delete  : {
                \       'action': function('s:delete_mark'),
                \       'options': {'function': 1, 'silent': 0, 'quit': 0, 'update': 1}
                \       }
                \ }
    let maps.n = {
                \ keys.n.goto  : {
                \       'action': function('s:go_to_mark'),
                \       'options': {'function': 1}
                \       },
                \ keys.n.delete  : {
                \       'action': function('s:delete_mark'),
                \       'options': {'function': 1, 'silent': 0, 'quit': 0, 'update': 1}
                \       }
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:go_to_mark(m) abort " {{{1
    execute "normal! '" . a:m
    call vfinder#helpers#unfold_and_put_line()
    call vfinder#helpers#flash_line(winnr())
endfun
" 1}}}

fun! s:delete_mark(m) abort " {{{1
    " Only A-Z and 0-9
    if a:m !~ '^\(\u\|\d\)$'
        call vfinder#helpers#echo('Only marks in range A-Z or 0-9 can be deleted', 'Error')
        return ''
    endif
    execute 'delmarks ' . a:m
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
