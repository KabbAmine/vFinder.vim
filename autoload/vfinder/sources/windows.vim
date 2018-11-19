" Creation         : 2018-11-19
" Last modification: 2018-11-19


fun! vfinder#sources#windows#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#windows#get(...) abort " {{{1
    call s:windows_define_maps()
    return {
                \   'name'         : 'windows',
                \   'to_execute'   : function('s:windows_source'),
                \   'format_fun'   : function('s:windows_format'),
                \   'candidate_fun': function('s:windows_candidate_fun'),
                \   'syntax_fun'   : function('s:windows_syntax_fun'),
                \   'maps'         : s:windows_maps()
                \ }
endfun
" 1}}}

fun! s:windows_source() abort " {{{1
    return map(copy(getwininfo()), {i, v -> v.winid})
endfun
" 1}}}

fun! s:windows_format(ids) abort " {{{1
    let res = []
    for id in copy(a:ids)
        let w_infos = getwininfo(id)[0]
        let [t_nr, b_nr] = [w_infos.tabnr, w_infos.bufnr]
        " do not add vfinder windows
        if b_nr is# bufnr('%')
            continue
        endif
        let b_name = vfinder#helpers#get_bufname(b_nr)
        let [path, name] = [
                    \   fnamemodify(b_name, ':h') . '/',
                    \   fnamemodify(b_name, ':t'),
                    \ ]
        call add(res, printf('%-15s %-25s %s',
                    \   't' . t_nr  . ':' . id,
                    \   name,
                    \   path
                    \ ))
    endfor
    return res
endfun
" 1}}}

fun! s:windows_candidate_fun() abort " {{{1
    return matchstr(getline('.'), '^t\d\+:\zs\d\+')
endfun
" 1}}}

fun! s:windows_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('windows')
    let action_goto = {
                \ 'action': 'call win_gotoid(%s)',
                \ 'options': {}
                \ }
    return {
                \   'i': {keys.i.goto: action_goto},
                \   'n': {keys.n.goto: action_goto}
                \ }
endfun
" 1}}}

fun! s:windows_syntax_fun() abort " {{{1
    syntax match vfinderWindowsTabnrAndId =^\S\+=
    syntax match vfinderWindowsName = \{2\}.*\ze \{2,\}\f\+$=
    highlight! link vfinderWindowsTabnrAndId vfinderIndex
    highlight! link vfinderWindowsName Statement
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:windows_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('windows', {
                \ 'i': {'goto': '<CR>'},
                \ 'n': {'goto': '<CR>'}
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
