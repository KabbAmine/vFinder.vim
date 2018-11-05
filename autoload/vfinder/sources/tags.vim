" Creation         : 2018-02-11
" Last modification: 2018-11-05


fun! vfinder#sources#tags#check()
    return v:true
endfun

fun! vfinder#sources#tags#get() abort
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

fun! s:tags_is_valid() abort
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

fun! s:tags_source() abort
    return taglist('.*')
endfun

fun! s:tags_format(tags) abort
    return map(copy(a:tags), {
                \ i, v ->
                \       printf('%-50s %-10s %s',
                \           v.name,
                \           ':' . v.kind . ':',
                \           fnamemodify(v.filename, ':~:.')
                \ )})
endfun

fun! s:tags_candidate_fun() abort
    return getline('.')
endfun

fun! s:tags_syntax_fun() abort
    syntax match vfinderTagsFilename =\f\+$=
    syntax match vfinderTagsKind =\s\+:\S\+:\s\+=
    highlight! link vfinderTagsFilename vfinderIndex
    highlight! link vfinderTagsKind Identifier
endfun

fun! vfinder#sources#tags#maps() abort
    let maps = {}
    let keys = vfinder#maps#get('tags')
    let maps.i = {
                \ keys.i.goto         : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.i.splitandgoto : {'action': function('s:splitandgoto'), 'options': {'function': 1}},
                \ keys.i.vsplitandgoto: {'action': function('s:vsplitandgoto'), 'options': {'function': 1}},
                \ keys.i.preview      : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    let maps.n = {
                \ keys.n.goto         : {'action': function('s:gototag'), 'options': {'function': 1}},
                \ keys.n.splitandgoto : {'action': function('s:splitandgoto'), 'options': {'function': 1}},
                \ keys.n.vsplitandgoto: {'action': function('s:vsplitandgoto'), 'options': {'function': 1}},
                \ keys.n.preview      : {'action': function('s:preview'), 'options': {'function': 1, 'quit': 0}}
                \ }
    return maps
endfun

fun! s:gototag(tag) abort
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'edit ' . file
    silent execute cmd
endfun

fun! s:splitandgoto(tag) abort
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'split ' . file
    silent execute cmd
endfun

fun! s:vsplitandgoto(tag) abort
    let [file, cmd] = s:filename_and_cmd(a:tag)
    unsilent execute 'vsplit ' . file
    silent execute cmd
endfun

fun! s:preview(tag) abort
    let [file, cmd] = s:filename_and_cmd(a:tag)
    silent execute 'pedit ' . file
    silent wincmd P
    silent execute cmd
    silent wincmd p
endfun

fun! s:filename_and_cmd(tag) abort
    let tag_name = substitute(matchstr(a:tag, '^.*\ze\s\+:\h:.*'), '\s*$', '', 'g')
    let tag = taglist('\V' . tag_name)[0]
    return [tag.filename, escape(tag.cmd, '*~')]
endfun
