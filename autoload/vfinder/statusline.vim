" Creation         : 2018-02-09
" Last modification: 2018-11-27


fun! vfinder#statusline#get() abort " {{{1
    return '%{vfinder#statusline#head()}%=%{vfinder#statusline#flags()}'
endfun
" 1}}}

fun! vfinder#statusline#head() abort " {{{1
    let current = s:current_item()
    let count_filtered = s:count_filtered()

    let count_infos = current ? current . '/' : ''
    let count_infos .= count_filtered ? count_filtered : ''
    let count_infos = count_infos ? '[' . count_infos . ']' : ''

    return printf('%3s | %s(%s) %s',
                \   s:mode(),
                \   s:name(),
                \   s:count_candidates(),
                \   count_infos
                \ )
endfun
" 1}}}

fun! vfinder#statusline#flags() abort " {{{1
    let str = ''
    for [name, value] in items(b:vf.flags)
        if value
            let str .= '[' . tolower(name) . ']'
        endif
    endfor
    return str
endfun
" 1}}}


fun! s:name() abort " {{{1
    return bufname('%')
endfun
" 1}}}

fun! s:mode() abort " {{{1
    return toupper(mode())
endfun
" 1}}}

fun! s:count_candidates() abort " {{{1
    " The check is here to avoid errors popping when the candidates gathering
    " process is interrupted
    let count_candidates = exists('b:vf.candidates.initial')
                \ ? len(b:vf.candidates.initial)
                \ : 0
    return count_candidates ? count_candidates : '-'
endfun
" 1}}}

fun! s:current_item() abort " {{{1
    if line('$') is# 1
        return ''
    else
        let l = line('.')
        return l is# 1 ? 1 : l - 1
    endif
endfun
" 1}}}

fun! s:count_filtered() abort " {{{1
    let count_candidates = line('$') - 1
    return count_candidates ? count_candidates : 0
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
