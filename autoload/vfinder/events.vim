" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#events#query_modified() abort
    if line('.') isnot# 1
        return ''
    endif

    let prompt = vfinder#prompt#i()
    call prompt.render()

    let candidates = vfinder#candidates#i(b:vf.cmd)

    " rg output is not in order and when we remove the query d'un seul coup,
    " the candidates are not updated
    if !empty(prompt.query)
        call candidates.filter(prompt.query).populate().highlight_matched()
        let s:was_filtered = 1
    elseif exists('s:was_filtered')
        call candidates.get().populate().highlight_matched()
        unlet! s:was_filtered
    endif

    startinsert!
endfun
