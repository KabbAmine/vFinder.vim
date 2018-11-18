" Creation         : 2018-02-04
" Last modification: 2018-11-18


fun! vfinder#sources#files#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#files#get(...) abort " {{{1
    call s:files_define_maps()
    return {
                \   'name'         : 'files',
                \   'to_execute'   : s:files_source(),
                \   'candidate_fun': function('vfinder#sources#files#candidate_fun'),
                \   'format_fun'   : function('s:files_format_fun'),
                \   'syntax_fun'   : function('s:files_syntax_fun'),
                \   'maps'         : vfinder#sources#files#maps()
                \ }
endfun
" 1}}}

fun! s:files_source() abort " {{{1
    return executable('rg')
                \ ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag')
                \ ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : s:in_git_project()
                \ ? 'git ls-files -co --exclude-standard'
                \ : 'find * -type f'
endfun
" 1}}}

fun! s:files_format_fun(files) abort " {{{1
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
" 1}}}

fun! s:files_syntax_fun() abort " {{{1
    syntax match vfinderAddedGitStatus =^\ +\ =
    syntax match vfinderModifiedGitStatus =^\ \~\ =
    syntax match vfinderRenamedGitStatus =^\ -\ =
    syntax match vfinderUntrackedGitStatus =^\ ?\ =
    highlight! link vfinderAddedGitStatus DiffAdded
    highlight! link vfinderModifiedGitStatus DiffChange
    highlight! link vfinderRenamedGitStatus DiffDelete
    highlight! link vfinderUntrackedGitStatus vfinderIndex
endfun
" 1}}}

fun! vfinder#sources#files#candidate_fun() abort " {{{1
    return escape(matchstr(getline('.'), '\f\+$'), '%#')
endfun
" 1}}}

fun! vfinder#sources#files#maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('files')
    let options = {'silent': 0}
    let maps.i = {
                \ keys.i.edit  : {'action': 'edit %s', 'options': options},
                \ keys.i.split : {'action': 'split %s', 'options': options},
                \ keys.i.vsplit: {'action': 'vertical split %s', 'options': options},
                \ keys.i.tab   : {'action': 'tabedit %s', 'options': options},
                \ keys.i.toggle_git_flags: {
                \       'action': function('s:toggle_git_flags'),
                \       'options': {'function': 1, 'flag': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       }
                \ }
    let maps.n = {
                \ keys.n.edit  : {'action': 'edit %s', 'options': options},
                \ keys.n.split : {'action': 'split %s', 'options': options},
                \ keys.n.vsplit: {'action': 'vertical split %s', 'options': options},
                \ keys.n.tab   : {'action': 'tabedit %s', 'options': options},
                \ keys.n.toggle_git_flags: {
                \       'action': function('s:toggle_git_flags'),
                \       'options': {'function': 1, 'flag': 1, 'update': 1, 'quit': 0, 'silent': 0}
                \       }
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:toggle_git_flags(file) abort " {{{1
    if !s:in_git_project()
        call vfinder#helpers#echo('not in a git project')
        return ''
    endif
    let b:vf.flags.git_flags = !b:vf.flags.git_flags
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            git related
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Git status symbols {{{1
let s:git_status_symbols = {
            \   'M': '~',
            \   'A': '+',
            \   'R': '-',
            \   'D': '-'
            \ }
" 1}}}

fun! s:in_git_project() abort " {{{1
    return executable('git') && isdirectory('./.git')
endfun
" 1}}}

fun! s:git_status_files() abort " {{{1
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
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:files_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('files', {
                \   'i': {
                \       'edit'             : '<CR>',
                \       'split'            : '<C-s>',
                \       'vsplit'           : '<C-v>',
                \       'tab'              : '<C-t>',
                \       'toggle_git_flags' : '<C-g>'
                \   },
                \   'n': {
                \       'edit'             : '<CR>',
                \       'split'            : 's',
                \       'vsplit'           : 'v',
                \       'tab'              : 't',
                \       'toggle_git_flags' : 'gi'
                \   }
                \ })
endfun
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
