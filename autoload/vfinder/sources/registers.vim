" Creation         : 2018-02-19
" Last modification: 2018-02-23


fun! vfinder#sources#registers#check()
    return v:true
endfun

fun! vfinder#sources#registers#get() abort
    return {
                \   'name'         : 'registers',
                \   'to_execute'   : function('s:registers_source'),
                \   'format_fun'   : function('s:registers_format'),
                \   'candidate_fun': function('s:registers_candidate_fun'),
                \   'syntax_fun'   : function('s:registers_syntax_fun'),
                \   'maps'         : vfinder#sources#yank#maps()
                \ }
endfun

fun! s:registers_source() abort
    " registers: +, *, ", 0-9, a-z, -, ., %, /

    let regs = []
    for r in ['+', '*', '"']
        let content = getreg(r)
        if !empty(content)
            call add(regs, r . ' ' . content)
        endif
    endfor
    for i in range(0, 9)
        let content = getreg(i)
        if !empty(content)
            call add(regs, i . ' ' . content)
        endif
    endfor
    " From a to z
    for a in range(97, 122)
        let reg = nr2char(a)
        let content = getreg(reg)
        if !empty(content)
            call add(regs, regs[reg] . ' ' . content)
        endif
    endfor
    for r in ['-', '.', '%', '/']
        let content = getreg(r)
        if !empty(content)
            call add(regs, r . ' ' . content)
        endif
    endfor
    return regs
endfun

fun! s:registers_format(regs) abort
    return map(copy(a:regs), 'printf("%s: %s", v:val[0], v:val[2:])')
endfun

fun! s:registers_candidate_fun() abort
    return getline('.')[3:]
endfun

fun! s:registers_syntax_fun() abort
    syntax match vfinderRegistersName =^\S\+:\s\+=
    highlight! link vfinderRegistersName vfinderIndex
endfun
