" Creation         : 2018-02-11
" Last modification: 2018-02-11


fun! vfinder#sources#outline#check()
    return v:true
endfun

fun! vfinder#sources#outline#get() abort
    return {
                \   'name'         : 'outline',
                \   'is_valid'     : s:outline_is_valid(),
                \   'to_execute'   : s:outline_source(),
                \   'format_fun'   : function('s:outline_format'),
                \   'candidate_fun': function('s:outline_candidate_fun'),
                \   'maps'         : vfinder#sources#outline#maps()
                \ }
endfun

fun! s:outline_is_valid() abort
    if !executable('ctags')
        call vfinder#helpers#echo('"ctags" was not found', 'Error', 1)
        return 0
    else
        return 1
    endif
endfun

fun! s:outline_source() abort
    return 'ctags -x ' . expand('%') . ' --sort=no'
endfun

fun! s:outline_format(tags) abort
    let res = []
    for t in a:tags
        " An example of how the output is:
        " Font(s)          Heading_L3   25 .vim/README.md   ### Font(s)
        " Formatters & fixers Heading_L3   30 .vim/README.md   ### Formatters & fixers
        let name_and_kind = split(matchstr(t, '.*\ze\s\+\d\+\s\+\f\+'))
        let line = matchstr(t, '\s\+\zs\d\+\ze\s\+\f\+')
        let l = printf('%-25s %-10s %d', join(name_and_kind[:-2]), name_and_kind[-1][:9], line)
        call add(res, l)
    endfor
    return res
endfun

fun! s:outline_candidate_fun() abort
    return matchstr(getline('.'), '\d\+$')
endfun

fun! vfinder#sources#outline#maps() abort
    return {
                \   'i': {'<CR>': {'action': '%s', 'options': {'quit': 1}}},
                \   'n': {'<CR>': {'action': '%s', 'options': {'quit': 1}}},
                \ }
endfun
