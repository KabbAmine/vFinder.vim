" Creation         : 2018-02-11
" Last modification: 2018-03-16


fun! vfinder#sources#yank#check()
    return v:true
endfun

fun! vfinder#sources#yank#get() abort
    return {
                \   'name'         : 'yank',
                \   'to_execute'   : function('s:yank_source'),
                \   'format_fun'   : function('s:yank_format'),
                \   'candidate_fun': function('s:yank_candidate_fun'),
                \   'syntax_fun'   : function('s:yank_syntax_fun'),
                \   'maps'         : vfinder#sources#yank#maps()
                \ }
endfun

fun! s:yank_source() abort
    let yanked = vfinder#cache#get_and_set_elements('yank', 100)
    return yanked
endfun

fun! s:yank_format(yank_l) abort
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

fun! s:yank_candidate_fun() abort
    " the text is like: '100- Foo bar'
    return substitute(getline('.')[5:], '\\n', '\n', 'g')
endfun

fun! s:yank_syntax_fun() abort
    syntax match vfinderYankIndex =^\d\+\s*:\s\+=
    syntax match vfinderYankEndofline =\\n=
    highlight! link vfinderYankIndex vfinderIndex
    highlight! link vfinderYankEndofline vfinderYankIndex
endfun

fun! vfinder#sources#yank#maps() abort
    return {
                \   'i': {'<CR>': {'action': function('s:paste'), 'options': {'function': 1}}},
                \   'n': {'<CR>': {'action': function('s:paste'), 'options': {'function': 1}}},
                \ }
endfun

fun! s:paste(content) abort
    " a:content can be something like 'foo^@bar^@zee'

    let [line, col_p] = [line('.'), col('.')]
    let new_lines = split(getline('.')[: col_p - 1] . a:content . getline('.')[col_p :], "\n")
    let go_to_line = line + len(new_lines) - 1
    let go_to_col = col_p + len(split(a:content, "\n")[-1])
    silent execute 'keepjumps ' . line . 'delete_'
    call append(line - 1, new_lines)
    call cursor(go_to_line, go_to_col)
endfun
