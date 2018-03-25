" Creation         : 2018-02-11
" Last modification: 2018-03-25


fun! vfinder#sources#command_history#check()
    return v:true
endfun

fun! vfinder#sources#command_history#get() abort
    return {
                \   'name'         : 'command_history',
                \   'to_execute'   : s:command_history_source(),
                \   'format_fun'   : function('s:command_history_format'),
                \   'candidate_fun': function('s:command_history_candidate_fun'),
                \   'maps'         : vfinder#sources#commands#maps()
                \ }
endfun

fun! s:command_history_source() abort
    let cmd_history = split(execute('history'), "\n")[1:]
    call remove(cmd_history, -1)
    return reverse(cmd_history)
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
