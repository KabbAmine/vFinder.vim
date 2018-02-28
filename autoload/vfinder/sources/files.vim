" Creation         : 2018-02-04
" Last modification: 2018-02-28


fun! vfinder#sources#files#check()
    return v:true
endfun

fun! vfinder#sources#files#get() abort
    let is_valid = s:files_is_valid() ? 1 : 0
    redraw!
    return {
                \   'name'         : 'files',
                \   'to_execute'   : s:files_source(),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'maps'         : vfinder#sources#files#maps(),
                \   'filter_name'  : 'match_position',
                \   'is_valid'     : is_valid,
                \ }
endfun

fun! s:files_is_valid()
    if getcwd() isnot# $HOME
        return 1
    else
        let old_vf_verbose_option = g:vfinder_verbose
        let g:vfinder_verbose = 1
        call vfinder#helpers#echo('Gathering candidates from $HOME may freeze your editor', 'Question')
        let response = vfinder#helpers#input('Do you want to proceed? [y/N] ', 'Question')
        let g:vfinder_verbose = old_vf_verbose_option
        return response =~# 'y\|Y' ? 1 : 0
    endif
endfun

fun! s:files_source() abort
    return executable('git') && isdirectory('./.git')
                \ ? 'git ls-files -co -X ./.gitignore'
                \ : executable('rg')
                \ ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag')
                \ ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : 'find * -type f'
endfun

fun! vfinder#sources#files#candidate_fun() abort
    return escape(getline('.'), '%#')
endfun

fun! vfinder#sources#files#maps() abort
    let maps = {}
    let maps.i = {
                \ '<CR>' : {'action': 'edit %s', 'options': {}},
                \ '<C-s>': {'action': 'split %s', 'options': {}},
                \ '<C-v>': {'action': 'vertical split %s', 'options': {}},
                \ '<C-t>': {'action': 'tabedit %s', 'options': {}}
                \ }
    let maps.n = {
                \ '<CR>': {'action': 'edit %s', 'options': {}},
                \ 's'   : {'action': 'split %s', 'options': {}},
                \ 'v'   : {'action': 'vertical split %s', 'options': {}},
                \ 't'   : {'action': 'tabedit %s', 'options': {}}
                \ }
    return maps
endfun
