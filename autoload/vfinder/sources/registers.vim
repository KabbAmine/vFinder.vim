" Creation         : 2018-02-19
" Last modification: 2018-11-18


fun! vfinder#sources#registers#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#registers#get(...) abort " {{{1
    call s:registers_define_maps()
    return {
                \   'name'         : 'registers',
                \   'to_execute'   : function('s:registers_source'),
                \   'format_fun'   : function('s:registers_format'),
                \   'candidate_fun': function('s:registers_candidate_fun'),
                \   'syntax_fun'   : function('s:registers_syntax_fun'),
                \   'maps'         : s:registers_maps()
                \ }
endfun
" 1}}}

fun! s:registers_source() abort " {{{1
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
            call add(regs, reg . ' ' . content)
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
" 1}}}

fun! s:registers_format(regs) abort " {{{1
    return map(copy(a:regs), 'printf("%s: %s", v:val[0], v:val[2:])')
endfun
" 1}}}

fun! s:registers_candidate_fun() abort " {{{1
    return getline('.')[3:]
endfun
" 1}}}

fun! s:registers_syntax_fun() abort " {{{1
    syntax match vfinderRegistersName =^\S\+:\s\+=
    highlight! link vfinderRegistersName vfinderIndex
endfun
" 1}}}

fun! s:registers_maps() abort " {{{1
    let keys = vfinder#maps#get('registers')
    return {
                \   'i': {keys.i.paste: {
                \       'action': function('vfinder#sources#yank#paste'),
                \       'options': {'function': 1}
                \   }},
                \   'n': {keys.n.paste: {
                \       'action': function('vfinder#sources#yank#paste'),
                \       'options': {'function': 1}
                \   }}
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:registers_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('registers', {
                \ 'i': {'paste': '<CR>'},
                \ 'n': {'paste': '<CR>'}
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
