" Creation         : 2018-02-11
" Last modification: 2018-11-11


fun! vfinder#sources#tags#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#tags#get() abort " {{{1
    return {
                \   'name'         : 'tags',
                \   'to_execute'   : function('s:tags_source'),
                \   'format_fun'   : function('s:tags_format'),
                \   'candidate_fun': function('s:tags_candidate_fun'),
                \   'syntax_fun'   : function('s:tags_syntax_fun'),
                \   'maps'         : vfinder#sources#tags#maps(),
                \ }
endfun
" 1}}}

fun! s:tags_source() abort " {{{1
    " a simple hack to keep the previous echoed msg shown
    sleep 1m
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
    call s:execute_cmd_unfold_and_flash(cmd)
endfun
" 1}}}

fun! s:splitandgoto(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'split ' . file
    call s:execute_cmd_unfold_and_flash(cmd)
endfun
" 1}}}

fun! s:vsplitandgoto(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'vsplit ' . file
    call s:execute_cmd_unfold_and_flash(cmd)
endfun
" 1}}}

fun! s:tabandgoto(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'tabedit ' . file
    call s:execute_cmd_unfold_and_flash(cmd)
endfun
" 1}}}

fun! s:preview(tag) abort " {{{1
    let [file, cmd] = s:filename_and_cmd(a:tag)
    silent execute 'pedit ' . file
    silent wincmd P
    call s:execute_cmd_unfold_and_flash(cmd)
    silent wincmd p
    call s:autoclose_pwindow_autocmd()
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:filename_and_cmd(tag) abort " {{{1
    let tag_name = substitute(matchstr(a:tag, '^.*\ze\s\+:\h:.*'), '\s*$', '', 'g')
    let tag = taglist('\V' . tag_name)[0]
    return [tag.filename, tag.cmd]
endfun
" 1}}}

fun! s:execute_cmd_unfold_and_flash(cmd) abort " {{{1
    let [magic, &magic] = [&magic, 0]
    execute a:cmd
    let &magic = magic
    call vfinder#helpers#unfold_and_put_line('z')
    call vfinder#helpers#flash_line(winnr())
endfun
" 1}}}

fun! s:autoclose_pwindow_autocmd() abort "{{{1
    augroup VFAutoClosePWindow
        autocmd!
        autocmd BufDelete,BufWipeout <buffer> pclose!
                    \| augroup VFAutoClosePWindow
                    \|  autocmd!
                    \| augroup End
                    \| augroup! VFAutoClosePWindow
    augroup END
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
