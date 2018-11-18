" Creation         : 2018-02-11
" Last modification: 2018-11-19


fun! vfinder#sources#command_history#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#command_history#get(...) abort " {{{1
    call s:command_history_define_maps()
    return {
                \   'name'         : 'command_history',
                \   'to_execute'   : function('s:command_history_source'),
                \   'format_fun'   : function('s:command_history_format'),
                \   'candidate_fun': function('s:command_history_candidate_fun'),
                \   'maps'         : s:command_history_maps()
                \ }
endfun
" 1}}}

fun! s:command_history_source() abort " {{{1
    return reverse(split(execute('history'), "\n")[1:-2])
endfun
" 1}}}

fun! s:command_history_format(commands) abort " {{{1
    let res = []
    for c in a:commands
        let index = matchstr(c, '^\s\+>\?\zs\d\+\ze')
        let command = matchstr(c, '^\s\+>\?\d\+\s\+\zs.*')
        call add(res, printf('%-5s %s', index, command))
    endfor
    return res
endfun
" 1}}}

fun! s:command_history_candidate_fun() abort " {{{1
    return matchstr(getline('.'), '^\d\+\s\+\zs.*$')
endfun
" 1}}}

fun! s:command_history_maps() abort " {{{1
    let keys = vfinder#maps#get('command_history')
    let actions = vfinder#actions#get('commands')
    return {
                \   'i': {
                \       keys.i.apply: actions.apply,
                \       keys.i.echo : actions.echo
                \   },
                \   'n': {
                \       keys.n.apply: actions.apply,
                \       keys.n.echo : actions.echo
                \   }
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:command_history_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('command_history', {
                \   'i': {
                \       'apply': '<CR>',
                \       'echo' : '<C-o>'
                \   },
                \   'n': {
                \       'apply': '<CR>',
                \       'echo' : 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
