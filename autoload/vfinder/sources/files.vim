" Creation         : 2018-02-04
" Last modification: 2018-11-03


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
                \   'format_fun'   : function('s:files_format_fun'),
                \   'syntax_fun'   : function('s:files_syntax_fun'),
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
                \ : s:in_git_project()
                \ ? 'git ls-files -co --exclude-standard'
                \ : 'find * -type f'
endfun

fun! s:files_format_fun(files) abort
    " Add git flags if the option is enabled
    let b:vf.flags.git_flags = get(b:vf.flags, 'git_flags', 0)
    if !s:in_git_project() || !b:vf.flags.git_flags
        return a:files
    endif
    let files = []
    let files_with_flags = s:git_status_files()
    for file in a:files
        let status = has_key(files_with_flags, file)
                    \ ? ' ' . files_with_flags[file] . ' '
                    \ : ''
        call add(files, printf('%-3s %s', status, file))
    endfor
    return files
endfun

fun! s:files_syntax_fun() abort
    syntax match vfinderAddedGitStatus =^\ +\ =
    syntax match vfinderModifiedGitStatus =^\ \~\ =
    syntax match vfinderRenamedGitStatus =^\ -\ =
    syntax match vfinderUntrackedGitStatus =^\ ?\ =
    highlight! link vfinderAddedGitStatus DiffAdded
    highlight! link vfinderModifiedGitStatus DiffChange
    highlight! link vfinderRenamedGitStatus DiffDelete
    highlight! link vfinderUntrackedGitStatus vfinderIndex
endfun

fun! vfinder#sources#files#candidate_fun() abort
    return escape(matchstr(getline('.'), '\f\+$'), '%#')
endfun

fun! vfinder#sources#files#maps() abort
    let maps = {}
    let keys = vfinder#maps#get('files')
    let maps.i = {
                \ keys.i.edit  : {'action': 'edit %s', 'options': {}},
                \ keys.i.split : {'action': 'split %s', 'options': {}},
                \ keys.i.vsplit: {'action': 'vertical split %s', 'options': {}},
                \ keys.i.tab   : {'action': 'tabedit %s', 'options': {}},
                \ keys.i.toggle_git_flags: {
                \       'action': function('s:toggle_git_flags'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       }
                \ }
    let maps.n = {
                \ keys.n.edit  : {'action': 'edit %s', 'options': {}},
                \ keys.n.split : {'action': 'split %s', 'options': {}},
                \ keys.n.vsplit: {'action': 'vertical split %s', 'options': {}},
                \ keys.n.tab   : {'action': 'tabedit %s', 'options': {}},
                \ keys.n.toggle_git_flags: {
                \       'action': function('s:toggle_git_flags'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       }
                \ }
    return maps
endfun

" Git related
" """""""""""

let s:git_status_symbols = {
            \   'M': '~',
            \   'A': '+',
            \   'R': '-',
            \   'D': '-'
            \ }

fun! s:in_git_project() abort
    return executable('git') && isdirectory('./.git')
endfun

fun! s:git_status_files() abort
    let res = {}
    for str in systemlist('git status --porcelain --untracked-files=all')
        " -> res[file] = status
        let [file, status] = [
                    \   matchstr(str, '\f\+$'),
                    \   matchstr(str, '\S')
                    \ ]
        " Get the appropriate symbol if it exists
        let status = get(s:git_status_symbols, status, status)
        let res[file] = status
    endfor
    return res
endfun

" Flags
"""""""""""

fun! s:toggle_git_flags(file) abort
    if !s:in_git_project()
        call vfinder#helpers#echo('not in a git project')
        return ''
    endif
    let b:vf.flags.git_flags = !b:vf.flags.git_flags
endfun
