" Creation         : 2018-02-09
" Last modification: 2018-03-27


fun! vfinder#statusline#get() abort
    return '%{vfinder#statusline#left()}%=%{vfinder#statusline#right()}'
endfun

fun! vfinder#statusline#left() abort
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

fun! vfinder#statusline#right() abort
    let fuzzy = b:vf.fuzzy ? '[fuzzy]': ''
    return printf('%3s ', fuzzy)
endfun

fun! s:name() abort
    return bufname('%')
endfun

fun! s:mode() abort
    return toupper(mode())
endfun

fun! s:count_candidates() abort
    let count_candidates = len(b:vf.original_candidates)
    return count_candidates ? count_candidates : '-'
endfun

fun! s:current_item() abort
    if line('$') is# 1
        return ''
    else
        let l = line('.')
        return l is# 1 ? 1 : l - 1
    endif
endfun

fun! s:count_filtered() abort
    let count_candidates = line('$') - 1
    return count_candidates ? count_candidates : 0
endfun
