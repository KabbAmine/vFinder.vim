" Creation         : 2018-02-11
" Last modification: 2018-12-12


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#tags#get(...) abort " {{{1
    call s:tags_define_maps()
    return {
                \   'name'         : 'tags',
                \   'to_execute'   : function('s:tags_source'),
                \   'format_fun'   : function('s:tags_format'),
                \   'syntax_fun'   : function('s:tags_syntax_fun'),
                \   'maps'         : s:tags_maps(),
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

fun! s:tags_syntax_fun() abort " {{{1
    syntax match vfinderTagsFilename =\%>1l\f\+$=
    syntax match vfinderTagsKind =\%>1l\s\+:\S\+:\s\+=
    highlight default link vfinderTagsFilename vfinderIndex
    highlight default link vfinderTagsKind Identifier
endfun
" 1}}}

fun! s:tags_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('tags')
    let maps.i = {
                \ keys.i.goto           : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.i.split_and_goto : {'action': function('s:split_and_goto'), 'options': {'function': 1}},
                \ keys.i.vsplit_and_goto: {'action': function('s:vsplit_and_goto'), 'options': {'function': 1}},
                \ keys.i.tab_and_goto   : {'action': function('s:tab_and_goto'), 'options': {'function': 1}},
                \ keys.i.preview        : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    let maps.n = {
                \ keys.n.goto           : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.n.split_and_goto : {'action': function('s:split_and_goto'), 'options': {'function': 1}},
                \ keys.n.vsplit_and_goto: {'action': function('s:vsplit_and_goto'), 'options': {'function': 1}},
                \ keys.n.tab_and_goto   : {'action': function('s:tab_and_goto'), 'options': {'function': 1}},
                \ keys.n.preview        : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:gototag(line) abort " {{{1
    let [name, file, cmd] = s:filename_and_cmd(a:line)
    execute 'edit ' . file
    call s:execute_cmd_unfold_and_flash(name, cmd)
endfun
" 1}}}

fun! s:split_and_goto(line) abort " {{{1
    let [name, file, cmd] = s:filename_and_cmd(a:line)
    unsilent execute 'split ' . file
    call s:execute_cmd_unfold_and_flash(name, cmd)
endfun
" 1}}}

fun! s:vsplit_and_goto(line) abort " {{{1
    let [name, file, cmd] = s:filename_and_cmd(a:line)
    unsilent execute 'vsplit ' . file
    call s:execute_cmd_unfold_and_flash(name, cmd)
endfun
" 1}}}

fun! s:tab_and_goto(line) abort " {{{1
    let [name, file, cmd] = s:filename_and_cmd(a:line)
    unsilent execute 'tabedit ' . file
    call s:execute_cmd_unfold_and_flash(name, cmd)
endfun
" 1}}}

fun! s:preview(line) abort " {{{1
    let win_nr = winnr()
    let [name, file, cmd] = s:filename_and_cmd(a:line)
    let b:vf.bopts.update_on_win_enter = 0
    " Always close the pwindow before to get width/height as expected
    silent execute 'pclose'
    execute vfinder#helpers#pedit_cmd(file)
    silent execute 'wincmd P'
    call s:execute_cmd_unfold_and_flash(name, cmd)
    silent execute win_nr . 'wincmd w'
    let b:vf.bopts.update_on_win_enter = 1
    call vfinder#helpers#autoclose_pwindow_autocmd()
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:filename_and_cmd(line) abort " {{{1
    let tag_name = substitute(matchstr(a:line, '^.*\ze\s\+:\h:.*'), '\s*$', '', 'g')
    let [filename, tag_cmd] = [matchstr(a:line, '\f\+$'), '']
    for t in taglist('\V' . tag_name)
        if t.filename is# fnamemodify(filename, ':p')
            let tag_cmd = t.cmd
            break
        endif
    endfor
    return [tag_name, filename, tag_cmd]
endfun
" 1}}}

fun! s:execute_cmd_unfold_and_flash(name, cmd) abort " {{{1
    if empty(a:cmd)
        call vfinder#helpers#throw('tag "' . a:name . '" not found')
    else
        let [magic, &magic] = [&magic, 0]
        execute a:cmd
        let &magic = magic
        call vfinder#helpers#unfold_and_put_line('t')
        call vfinder#helpers#flash_line(winnr())
    endif
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:tags_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('tags', {
                \   'i': {
                \       'goto'           : '<CR>',
                \       'split_and_goto' : '<C-s>',
                \       'vsplit_and_goto': '<C-v>',
                \       'tab_and_goto'   : '<C-t>',
                \       'preview'        : '<C-o>'
                \   },
                \   'n': {
                \       'goto'           : '<CR>',
                \       'split_and_goto' : 's',
                \       'vsplit_and_goto': 'v',
                \       'tab_and_goto'   : 't',
                \       'preview'        : 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
