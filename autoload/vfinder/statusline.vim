" Creation         : 2018-02-09
" Last modification: 2018-02-09


fun! vfinder#statusline#get() abort
    let current = s:current_item()
    let count_filtered = s:count_filtered()

    let count_infos = current ? current . '/' : ''
    let count_infos .= count_filtered ? count_filtered : ''
    let count_infos = count_infos ? '(' . count_infos . ')' : ''

    return printf('%3s | VF[%s] %s[%s]',
                \   s:mode(),
                \   s:name(),
                \   count_infos,
                \   s:count_candidates(),
                \ )
endfun

fun! s:name() abort
    return bufname('%')
endfun

fun! s:mode() abort
    return toupper(mode())
endfun

fun! s:count_candidates() abort
    let count_candidates = len(b:vf.original_candidates)
    return count_candidates ? count_candidates : 0
endfun

fun! s:current_item() abort
    let current_item = line('.') - 1
    return current_item ? current_item : 0
endfun

fun! s:count_filtered() abort
    let query = getline(1)[2:]
    let count_candidates = line('$') - 1
    return count_candidates && !empty(query) ? count_candidates : 0
endfun
