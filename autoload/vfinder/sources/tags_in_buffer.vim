" Creation         : 2018-02-11
" Last modification: 2018-11-18


fun! vfinder#sources#tags_in_buffer#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#tags_in_buffer#get(...) abort " {{{1
    call s:tags_in_buffer_define_maps()
    return {
                \   'name'         : 'tags_in_buffer',
                \   'is_valid'     : s:tags_in_buffer_is_valid(),
                \   'to_execute'   : function('s:tags_in_buffer_source'),
                \   'format_fun'   : function('s:tags_in_buffer_format'),
                \   'candidate_fun': function('s:tags_in_buffer_candidate_fun'),
                \   'syntax_fun'   : function('s:tags_in_buffer_syntax_fun'),
                \   'filter_name'  : 'compact_match',
                \   'maps'         : vfinder#sources#tags_in_buffer#maps()
                \ }
endfun
" 1}}}

fun! s:tags_in_buffer_source() abort " {{{1
    " Set the approriate ctags command string (+ flags + filename) and execute
    " it then return the result.
    " The filename can be the current one if it is a file and was not modified,
    " otherwise save and use a temporary file with the current content.
    " P.S:
    "	- The function uses b:vf.intitial_bufnr as initial buffer number.
    "	- When using a temp file, we use the same extension as the
    "	current buffer, or we pass the current filetype to ctags command. If no
    "	extension and no filetype, we simply return an empty list.
    " e.g. with all the possible cases for ctags command string:
    "	ctags --sort=no foo.bar 2> /dev/null
    "	ctags --sort=no -x /tmp/foo.bar 2> /dev/null
    "	ctags --sort=no --language-force=vim -x /tmp/foo 2> /dev/null

    let cmd = ['ctags', '--sort=no']
    let bufnr = b:vf.initial_bufnr
    let buffer = bufname(bufnr)
    if vfinder#helpers#empty_buffer(bufnr)
        return []
    endif
    let modified = getbufvar(bufnr, '&modified')
    let file = fnamemodify(buffer, ':p')
    let ft = getbufvar(bufnr, '&filetype')
    if filereadable(file) && !modified
        if !empty(ft)
            let cmd += ['--language-force=' . ft]
        endif
        let cmd += ['-x'] + [file]
    else
        let ext = fnamemodify(buffer, ':e')
        if empty(ext) && empty(ft)
            return []
        endif
        let temp_file = tempname()
        if !empty(ext)
            let temp_file .= '.' . ext
        else
            let cmd += ['--language-force=' . ft]
        endif
        call writefile(getbufline(bufnr, 1, '$'), temp_file)
        let cmd += ['-x'] + [temp_file]
    endif
    return systemlist(join(cmd) . ' ' . vfinder#helpers#black_hole())
endfun
" 1}}}

fun! s:tags_in_buffer_format(tags) abort " {{{1
    let res = []
    for t in a:tags
        " An example of how the output is:
        " Font(s)          Heading_L3   25 .vim/README.md   ### Font(s)
        " Formatters & fixers Heading_L3   30 .vim/README.md   ### Formatters & fixers
        let full_line = matchstr(t, '^.*\s\+\d\+\ze\s\+\f\+\s\+')
        let line = matchstr(full_line, '\d\+$')
        let kind = matchstr(full_line, '\s\+\zs\S\+\ze\s\+\d\+$')
        let name = matchstr(full_line, '^.*\ze\s\+' . kind . '\s\+' . line . '$')
        let l = printf('%-50s %-10s %5s', name, ':' . kind . ':', line)
        call add(res, l)
    endfor
    return res
endfun
" 1}}}

fun! s:tags_in_buffer_candidate_fun() abort " {{{1
    return matchstr(getline('.'), '\d\+$')
endfun
" 1}}}

fun! s:tags_in_buffer_syntax_fun() abort " {{{1
    syntax match vfindertags_in_bufferLinenr =\d\+$=
    syntax match vfindertags_in_bufferKind =\s\+:\S\+:\s\+=
    highlight! link vfindertags_in_bufferLinenr vfinderIndex
    highlight! link vfindertags_in_bufferKind Identifier
endfun
" 1}}}

fun! vfinder#sources#tags_in_buffer#maps() abort " {{{1
    let keys = vfinder#maps#get('tags_in_buffer')
    let options = {'function': 1}
    return {
                \   'i': {
                \       keys.i.goto           : {'action': function('s:goto_tag'), 'options': options},
                \       keys.i.split_and_goto : {'action': function('s:split_and_goto_tag'), 'options': options},
                \       keys.i.vsplit_and_goto: {'action': function('s:vsplit_and_goto_tag'), 'options': options}
                \   },
                \   'n': {
                \       keys.n.goto           : {'action': function('s:goto_tag'), 'options': options},
                \       keys.n.split_and_goto : {'action': function('s:split_and_goto_tag'), 'options': options},
                \       keys.n.vsplit_and_goto: {'action': function('s:vsplit_and_goto_tag'), 'options': options}
                \   }
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:goto_tag(tag_line) abort " {{{1
    execute a:tag_line
    call vfinder#helpers#unfold_and_put_line('t')
    call vfinder#helpers#flash_line(winnr())
endfun
" 1}}}

fun! s:split_and_goto_tag(tag_line) abort " {{{1
    execute 'split +' . a:tag_line
    call vfinder#helpers#unfold_and_put_line('z')
    call vfinder#helpers#flash_line(winnr())
endfun
" 1}}}

fun! s:vsplit_and_goto_tag(tag_line) abort " {{{1
    execute 'vsplit +' . a:tag_line
    call vfinder#helpers#unfold_and_put_line('z')
    call vfinder#helpers#flash_line(winnr())
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:tags_in_buffer_is_valid() abort " {{{1
    if !executable('ctags')
        call vfinder#helpers#echo('"ctags" was not found', 'Error')
        return 0
    else
        return 1
    endif
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:tags_in_buffer_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('tags_in_buffer', {
                \   'i': {
                \       'goto'           : '<CR>',
                \       'split_and_goto' : '<C-s>',
                \       'vsplit_and_goto': '<C-v>'
                \   },
                \   'n': {
                \       'goto'           : '<CR>',
                \       'split_and_goto' : 's',
                \       'vsplit_and_goto': 'v'
                \   }
                \ })
endfun
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
