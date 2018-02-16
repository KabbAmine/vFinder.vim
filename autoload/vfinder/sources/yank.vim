" Creation         : 2018-02-11
" Last modification: 2018-02-16


fun! vfinder#sources#yank#check()
    return v:true
endfun

fun! vfinder#sources#yank#get() abort
    return {
                \   'name'         : 'yank',
                \   'to_execute'   : function('s:yank_source'),
                \   'maps'         : vfinder#sources#yank#maps()
                \ }
endfun

fun! s:yank_source() abort
    let yanked = g:vf_cache.yank
    if empty(yanked)
        let yanked = vfinder#cache#read('yank')
        let g:vf_cache.yank = yanked
    endif
    return yanked
endfun

fun! vfinder#sources#yank#maps() abort
    return {
                \   'i': {'<CR>': {'action': function('s:paste'), 'options': {'quit': 1, 'function': 1}}},
                \   'n': {'<CR>': {'action': function('s:paste'), 'options': {'quit': 1, 'function': 1}}},
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
