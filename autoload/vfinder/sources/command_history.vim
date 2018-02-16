" Creation         : 2018-02-11
" Last modification: 2018-02-15


fun! vfinder#sources#command_history#check()
    return v:true
endfun

fun! vfinder#sources#command_history#get() abort
    return {
                \   'name'         : 'command_history',
                \   'to_execute'   : s:command_history_source(),
                \   'format_fun'   : function('s:command_history_format'),
                \   'candidate_fun': function('s:command_history_candidate_fun'),
                \   'maps'         : vfinder#sources#command_history#maps()
                \ }
endfun

fun! s:command_history_source() abort
    return split(execute('history'), "\n")[1:]
endfun

fun! s:command_history_format(commands) abort
    let res = []
    for c in a:commands
        let index = matchstr(c, '^\s\+\zs\d\+\ze')
        let command = matchstr(c, '^\s\+\d\+\s\+\zs.*')
        call add(res, printf('%-5s %s', index, command))
    endfor
    return res
endfun

fun! s:command_history_candidate_fun() abort
    return matchstr(getline('.'), '^\d\+\s\+\zs.*$')
endfun

fun! vfinder#sources#command_history#maps() abort
    return {
                \   'i': {'<CR>' : {
                \       'action': '%s',
                \       'options': {'quit': 1, 'silent': 0, 'echo': 1}}},
                \   'n': {'<CR>' : {
                \       'action': '%s',
                \       'options': {'quit': 1, 'silent': 0, 'echo': 1}}},
                \ }
endfun