" Creation         : 2018-02-11
" Last modification: 2018-11-10


fun! vfinder#sources#tags#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#tags#get() abort " {{{1
    let is_valid = s:tags_is_valid()
    redraw!
    return {
                \   'name'         : 'tags',
                \   'is_valid'     : is_valid,
                \   'to_execute'   : function('s:tags_source'),
                \   'format_fun'   : function('s:tags_format'),
                \   'candidate_fun': function('s:tags_candidate_fun'),
                \   'syntax_fun'   : function('s:tags_syntax_fun'),
                \   'maps'         : vfinder#sources#tags#maps(),
                \ }
endfun
" 1}}}

fun! s:tags_source() abort " {{{1
    return taglist('.*')
endfun
" 1}}}

fun! s:tags_format(tags) abort " {{{1
    return map(copy(a:tags), {
                \ i, v ->
                \       printf('%-50s %-10s %s',
                \           v.name,
                \           ':' . v.kind . ':',
                \           fnamemodify(v.filename, ':~:.')
                \ )})
endfun
" 1}}}

fun! s:tags_candidate_fun() abort " {{{1
    return getline('.')
endfun
" 1}}}

fun! s:tags_syntax_fun() abort " {{{1
    syntax match vfinderTagsFilename =\f\+$=
    syntax match vfinderTagsKind =\s\+:\S\+:\s\+=
    highlight! link vfinderTagsFilename vfinderIndex
    highlight! link vfinderTagsKind Identifier
endfun
" 1}}}

fun! vfinder#sources#tags#maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('tags')
    let maps.i = {
                \ keys.i.goto         : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.i.splitandgoto : {'action': function('s:splitandgoto'), 'options': {'function': 1}},
                \ keys.i.vsplitandgoto: {'action': function('s:vsplitandgoto'), 'options': {'function': 1}},
                \ keys.i.tabandgoto   : {'action': function('s:tabandgoto'), 'options': {'function': 1}},
                \ keys.i.preview      : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    let maps.n = {
                \ keys.n.goto         : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.n.splitandgoto : {'action': function('s:splitandgoto'), 'options': {'function': 1}},
                \ keys.n.vsplitandgoto: {'action': function('s:vsplitandgoto'), 'options': {'function': 1}},
                \ keys.n.tabandgoto   : {'action': function('s:tabandgoto'), 'options': {'function': 1}},
                \ keys.n.preview      : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:gototag(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'edit ' . file
    call s:execute_cmd_and_unfold(cmd)
endfun
" 1}}}

fun! s:splitandgoto(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'split ' . file
    call s:execute_cmd_and_unfold(cmd)
endfun
" 1}}}

fun! s:vsplitandgoto(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'vsplit ' . file
    call s:execute_cmd_and_unfold(cmd)
endfun
" 1}}}

fun! s:tabandgoto(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'tabedit ' . file
    call s:execute_cmd_and_unfold(cmd)
endfun
" 1}}}

fun! s:preview(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    silent execute 'pedit ' . file
    silent wincmd P
    call s:execute_cmd_and_unfold(cmd)
    silent wincmd p
    call s:autoclose_pwindow_autocmd()
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:tags_is_valid() abort " {{{1
    let tag_count = 0
    let wc = executable('wc') ? 1 : 0
    for tf in tagfiles()
        let tag_count += wc
                    \ ? matchstr(split(system('wc -l ' . tf), "\n")[0], '^\d\+')
                    \ : len(readfile(tf))
    endfor
    if tag_count <=# 70000
        return 1
    else
        let info = 'There are near ' . tag_count . ' tags, which may freeze your editor'
        let question = 'Do you want to proceed?'
        let response = vfinder#helpers#question(info, question)
        return response =~# 'y\|Y' ? 1 : 0
    endif
endfun
" 1}}}

fun! s:filename_and_cmd(tag) abort " {{{1
    let tag_name = substitute(matchstr(a:tag, '^.*\ze\s\+:\h:.*'), '\s*$', '', 'g')
    let tag = taglist('\V' . tag_name)[0]
    return [tag.filename, tag.cmd]
endfun
" 1}}}

fun! s:execute_cmd_and_unfold(cmd) abort " {{{1
    let [magic, &magic] = [&magic, 0]
    execute a:cmd
    let &magic = magic
    normal! zv
endfun
" 1}}}

fun! s:autoclose_pwindow_autocmd() abort
    augroup VFAutoClosePWindow
        autocmd!
        autocmd BufDelete,BufWipeout <buffer> pclose!
                    \| augroup VFAutoClosePWindow
                    \|  autocmd!
                    \| augroup End
                    \| augroup! VFAutoClosePWindow
    augroup END
endfun


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
