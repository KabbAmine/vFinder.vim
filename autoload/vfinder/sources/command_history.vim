" Creation         : 2018-02-11
" Last modification: 2018-10-26


fun! vfinder#sources#command_history#check() " {{{1
    return v:true
endfun
" 1}}}

fun! vfinder#sources#command_history#get() abort " {{{1
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
    return {
                \   'i': {
                \       keys.i.apply: {'action': '%s', 'options': {'silent': 0}},
                \       keys.i.echo : {'action': '%s', 'options': {'silent': 0, 'echo': 1}}
                \   },
                \   'n': {
                \       keys.n.apply: {'action': '%s', 'options': {'silent': 0}},
                \       keys.n.echo : {'action': '%s', 'options': {'silent': 0, 'echo': 1}}
                \   }
                \ }
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
