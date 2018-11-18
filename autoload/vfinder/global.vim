" Creation         : 2018-11-19
" Last modification: 2018-11-19


fun! vfinder#global#candidate_fun_get_filepath() abort " {{{1
    return escape(matchstr(getline('.'), '\f\+$'), '%#')
endfun
" 1}}}

fun! vfinder#global#candidate_fun_get_index() abort " {{{1
    return matchstr(getline('.'), '^\d\+\ze')
endfun
" 1}}}

fun! vfinder#global#file_is_valid(f) abort " {{{1
    return a:f !~#  '/vim.*/doc/' ? 1 : 0
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
