" Creation         : 2018-02-04
" Last modification: 2018-02-11


fun! vfinder#sources#files#check()
    return v:true
endfun

fun! vfinder#sources#files#get() abort
    let is_valid = s:files_is_valid() ? 1 : 0
    redraw!
    return {
                \   'name'         : 'files',
                \   'to_execute'   : s:files_source(),
                \   'maps'         : vfinder#sources#files#maps(),
                \   'is_valid'     : is_valid,
                \ }
endfun

fun! s:files_is_valid()
    if getcwd() isnot# $HOME
        return 1
    else
        let old_vf_verbose_option = g:vfinder_verbose
        let g:vfinder_verbose = 1
        call vfinder#helpers#Echo('Gathering candidates from $HOME may freeze your editor', 'Question')
        let response = vfinder#helpers#input('Do you want to proceed? [y/N] ', 'Question')
        let g:vfinder_verbose = old_vf_verbose_option
        return response =~# 'y\|Y' ? 1 : 0
    endif
endfun

fun! s:files_source() abort
    return executable('rg') ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag') ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : 'find * -type f'
endfun

fun! vfinder#sources#files#maps() abort
    let maps = {}
    let maps.i = {
                \ '<CR>' : {'action': 'edit %s', 'options': {'quit': 1}},
                \ '<C-s>': {'action': 'split %s', 'options': {'quit': 1}},
                \ '<C-v>': {'action': 'vertical split %s', 'options': {'quit': 1}},
                \ '<C-t>': {'action': 'tabedit %s', 'options': {'quit': 1}}
                \ }
    let maps.n = {
                \ '<CR>': {'action': 'edit %s', 'options': {'quit': 1}},
                \ 's'    : {'action': 'split %s', 'options': {'quit': 1}},
                \ 'v'    : {'action': 'vertical split %s', 'options': {'quit': 1}},
                \ 't'    : {'action': 'tabedit %s', 'options': {'quit': 1}}
                \ }
    return maps
endfun
