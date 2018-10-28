" Creation         : 2018-02-04
" Last modification: 2018-10-28


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
                \   'is_valid'     : is_valid
                \ }
endfun

fun! s:files_is_valid()
    if getcwd() isnot# $HOME
        return 1
    else
        let response = vfinder#helpers#question(
                    \   'Gathering candidates from $HOME may freeze your editor,',
                    \   'do you want to proceed? [y/N] '
                    \ )
        return response =~# 'y\|Y' ? 1 : 0
    endif
endfun

fun! s:files_source() abort
    return executable('rg')
                \ ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag')
                \ ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : executable('git') && isdirectory('./.git')
                \ ? 'git ls-files -co --exclude-standard'
                \ : 'find * -type f'
endfun

fun! vfinder#sources#files#candidate_fun() abort
    return escape(getline('.'), '%#')
endfun

fun! vfinder#sources#files#maps() abort
    let maps = {}
    let keys = vfinder#maps#get('files')
    let maps.i = {
                \ keys.i.edit  : {'action': 'edit %s', 'options': {}},
                \ keys.i.split : {'action': 'split %s', 'options': {}},
                \ keys.i.vsplit: {'action': 'vertical split %s', 'options': {}},
                \ keys.i.tab   : {'action': 'tabedit %s', 'options': {}}
                \ }
    let maps.n = {
                \ keys.n.edit  : {'action': 'edit %s', 'options': {}},
                \ keys.n.split : {'action': 'split %s', 'options': {}},
                \ keys.n.vsplit: {'action': 'vertical split %s', 'options': {}},
                \ keys.n.tab   : {'action': 'tabedit %s', 'options': {}}
                \ }
    return maps
endfun
