" Creation         : 2018-02-04
" Last modification: 2018-12-20


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#files#get(...) abort " {{{1
    call s:files_define_maps()
    return {
                \   'name'         : 'files',
                \   'to_execute'   : s:files_source(),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_filepath'),
                \   'format_fun'   : function('s:files_format_fun'),
                \   'syntax_fun'   : function('s:files_syntax_fun'),
                \   'maps'         : s:files_maps()
                \ }
endfun
" 1}}}

fun! s:files_source() abort " {{{1
    return executable('rg')
                \ ? 'rg --files --hidden --glob "!.git/"'
                \ : executable('ag')
                \ ? 'ag --nocolor --nogroup --hidden -g ""'
                \ : vfinder#helpers#in_git_project()
                \ ? 'git ls-files -co --exclude-standard'
                \ : 'find * -type f'
endfun
" 1}}}

fun! s:files_format_fun(files) abort " {{{1
    " Add git flags if the option is enabled
    let b:vf.flags.git_flags = get(b:vf.flags, 'git_flags', 0)
    if !b:vf.flags.git_flags
        return a:files
    endif
    let files = []
    let files_with_flags = s:get_git_status_files_with_flags()
    for file in a:files
        let status = get(files_with_flags, file, '')
        let status = !empty(status) ? '[' . status . ']' : status
        call add(files, printf('%-4s %s', status, file))
    endfor
    return files
endfun
" 1}}}

fun! s:files_syntax_fun() abort " {{{1
    syntax match vfinderFilesGitStatusSymbols =\%>1l^\[.*] =
    highlight default link vfinderFilesGitStatusSymbols Identifier
endfun
" 1}}}

fun! s:files_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('files')
    let actions = extend(vfinder#actions#get('files'), {
                \ 'toggle_git_flags': {
                \   'action' : function('s:toggle_git_flags'),
                \   'options': {'function': 1, 'flag': 1, 'update': 1, 'quit': 0}
                \ }})
    let maps.i = {
                \   keys.i.edit            : actions.edit,
                \   keys.i.split           : actions.split,
                \   keys.i.vsplit          : actions.vsplit,
                \   keys.i.tab             : actions.tab,
                \   keys.i.toggle_git_flags: actions.toggle_git_flags
                \ }
    let maps.n = {
                \   keys.n.edit            : actions.edit,
                \   keys.n.split           : actions.split,
                \   keys.n.vsplit          : actions.vsplit,
                \   keys.n.tab             : actions.tab,
                \   keys.n.toggle_git_flags: actions.toggle_git_flags
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:toggle_git_flags(file) abort " {{{1
    if !vfinder#helpers#in_git_project()
        unsilent call vfinder#helpers#echo('not in a git project')
        return ''
    endif
    let b:vf.flags.git_flags = !b:vf.flags.git_flags
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            git related
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:get_git_status_files_with_flags() abort " {{{1
    let res = {}
    for str in systemlist('git status --porcelain --untracked-files=all')
        let [file, status] = [matchstr(str, '\f\+$'), str[:1]]
        " 'X ' -> X+ (in index)
        " ' Y' -> X
        " 'XY' -> XY
        let res[file] = substitute(status, '\s$', '+', '')
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
