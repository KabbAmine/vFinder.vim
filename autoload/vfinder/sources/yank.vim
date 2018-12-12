" Creation         : 2018-02-11
" Last modification: 2018-12-12


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#yank#get(...) abort " {{{1
    call s:yank_define_maps()
    return {
                \   'name'         : 'yank',
                \   'to_execute'   : function('s:yank_source'),
                \   'format_fun'   : function('s:yank_format'),
                \   'candidate_fun': function('s:yank_candidate_fun'),
                \   'syntax_fun'   : function('s:yank_syntax_fun'),
                \   'maps'         : s:yank_maps()
                \ }
endfun
" 1}}}

fun! s:yank_source() abort " {{{1
    let yanked = vfinder#cache#get_and_set_elements('yank', 500)
    return yanked
endfun
" 1}}}

fun! s:yank_format(yank_l) abort " {{{1
    let res = []
    for i in range(0, len(a:yank_l) - 1)
        call add(res, printf(
                    \   '%-3d: %s',
                    \   i + 1,
                    \   substitute(a:yank_l[i], '\n', '\\n', 'g')
                    \ ))
    endfor
    return res
endfun
" 1}}}

fun! s:yank_candidate_fun() abort " {{{1
    " the text is like: '100- Foo bar'
    return substitute(getline('.')[5:], '\\n', '\n', 'g')
endfun
" 1}}}

fun! s:yank_syntax_fun() abort " {{{1
    syntax match vfinderYankIndex =\%>1l^\d\+\s*:\s\+=
    syntax match vfinderYankEndofline =\%>1l\\n=
    highlight default link vfinderYankIndex vfinderIndex
    highlight default link vfinderYankEndofline vfinderYankIndex
endfun
" 1}}}

fun! s:yank_maps() abort " {{{1
    let keys = vfinder#maps#get('yank')
    let actions = vfinder#actions#get('yank')
    return {
                \   'i': {keys.i.paste: actions.paste},
                \   'n': {keys.n.paste: actions.paste}
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:yank_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('yank', {
                \ 'i': {'paste': '<CR>'},
                \ 'n': {'paste': '<CR>'}
                \ })
endfun
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
