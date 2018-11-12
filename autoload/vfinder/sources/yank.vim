" Creation         : 2018-02-11
" Last modification: 2018-11-12


fun! vfinder#sources#yank#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#yank#get() abort " {{{1
    call s:yank_define_maps()
    return {
                \   'name'         : 'yank',
                \   'to_execute'   : function('s:yank_source'),
                \   'format_fun'   : function('s:yank_format'),
                \   'candidate_fun': function('s:yank_candidate_fun'),
                \   'syntax_fun'   : function('s:yank_syntax_fun'),
                \   'maps'         : vfinder#sources#yank#maps()
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
    syntax match vfinderYankIndex =^\d\+\s*:\s\+=
    syntax match vfinderYankEndofline =\\n=
    highlight! link vfinderYankIndex vfinderIndex
    highlight! link vfinderYankEndofline vfinderYankIndex
endfun
" 1}}}

fun! vfinder#sources#yank#maps() abort " {{{1
    let keys = vfinder#maps#get('yank')
    return {
                \   'i': {keys.i.paste: {
                \       'action': function('vfinder#sources#yank#paste'),
                \       'options': {'function': 1}
                \   }},
                \   'n': {keys.n.paste: {
                \       'action': function('vfinder#sources#yank#paste'),
                \       'options': {'function': 1}
                \   }}
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#yank#paste(content) abort " {{{1
    " a:content can be something like 'foo^@bar^@zee'

    let [line, col_p] = [line('.'), col('.')]
    let new_lines = split(getline('.')[: col_p - 1] . a:content . getline('.')[col_p :], "\n")
    let go_to_line = line + len(new_lines) - 1
    let go_to_col = col_p + len(split(a:content, "\n")[-1])
    silent execute 'keepjumps ' . line . 'delete_'
    call append(line - 1, new_lines)
    call cursor(go_to_line, go_to_col)
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
