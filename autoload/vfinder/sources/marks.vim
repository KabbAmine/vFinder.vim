" Creation         : 2018-03-31
" Last modification: 2018-11-27


fun! vfinder#sources#marks#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#marks#get(...) abort " {{{1
    call s:marks_define_maps()
    return {
                \   'name'         : 'marks',
                \   'to_execute'   : function('s:marks_source'),
                \   'candidate_fun': function('s:marks_candidate_fun'),
                \   'syntax_fun'   : function('s:marks_syntax_fun'),
                \   'maps'         : s:marks_maps(),
                \ }
endfun
" 1}}}

fun! s:marks_source() abort " {{{1
    " Go to the initial window to get its marks
    silent execute bufwinnr(b:vf.ctx.bufnr) . 'wincmd w'
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

fun! s:marks_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('marks')
    let actions = vfinder#actions#get('marks')
    let maps.i = {
                \   keys.i.goto  : actions.goto,
                \   keys.i.delete: actions.delete,
                \ }
    let maps.n = {
                \   keys.n.goto  : actions.goto,
                \   keys.n.delete: actions.delete,
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:marks_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('marks', {
                \ 'i': {
                \       'goto'  : '<CR>',
                \       'delete': '<C-d>'
                \   },
                \ 'n': {
                \       'goto'  : '<CR>',
                \       'delete': 'dd'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
