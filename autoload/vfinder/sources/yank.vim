" Creation         : 2018-02-11
" Last modification: 2018-02-15


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
                \   'i': {'<CR>': {'action': function('s:paste_in_place'), 'options': {'quit': 1, 'function': 1}}},
                \   'n': {'<CR>': {'action': function('s:paste_in_place'), 'options': {'quit': 1, 'function': 1}}},
                \ }
endfun

fun! s:paste_in_place(content) abort
    " a:content can be something like 'foo^@bar^@zee'

    let col_p = col('.')
    let new_line = getline('.')[: col_p - 1] . a:content . getline('.')[col_p :]
    call setline(line('.'), split(new_line, "\n"))
    normal! l
endfun
