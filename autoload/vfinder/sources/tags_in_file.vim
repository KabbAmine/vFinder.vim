" Creation         : 2018-02-11
" Last modification: 2018-10-25


fun! vfinder#sources#tags_in_file#check()
    return v:true
endfun

fun! vfinder#sources#tags_in_file#get() abort
    return {
                \   'name'         : 'tags_in_file',
                \   'is_valid'     : s:tags_in_file_is_valid(),
                \   'to_execute'   : function('s:tags_in_file_source'),
                \   'format_fun'   : function('s:tags_in_file_format'),
                \   'candidate_fun': function('s:tags_in_file_candidate_fun'),
                \   'syntax_fun'   : function('s:tags_in_file_syntax_fun'),
                \   'filter_name'  : 'compact_match',
                \   'maps'         : vfinder#sources#tags_in_file#maps()
                \ }
endfun

fun! s:tags_in_file_is_valid() abort
    if !executable('ctags')
        call vfinder#helpers#echo('"ctags" was not found', 'Error', 1)
        return 0
    else
        return 1
    endif
endfun

fun! s:tags_in_file_source() abort
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

fun! s:tags_in_file_format(tags) abort
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

fun! s:tags_in_file_candidate_fun() abort
    return matchstr(getline('.'), '\d\+$')
endfun

fun! s:tags_in_file_syntax_fun() abort
    syntax match vfindertags_in_fileLinenr =\d\+$=
    syntax match vfindertags_in_fileKind =\s\+:\S\+:\s\+=
    highlight! link vfindertags_in_fileLinenr vfinderIndex
    highlight! link vfindertags_in_fileKind Identifier
endfun

fun! vfinder#sources#tags_in_file#maps() abort
    let keys = vfinder#maps#get('tags_in_file')
    return {
                \   'i': {
                \       keys.i.goto         : {'action': '%s', 'options': {}},
                \       keys.i.splitandgoto : {'action': 'split \| %s', 'options': {}},
                \       keys.i.vsplitandgoto: {'action': 'vertical split \| %s', 'options': {}}
                \   },
                \   'n': {
                \       keys.n.goto         : {'action': '%s', 'options': {}},
                \       keys.n.splitandgoto : {'action': 'split \| %s', 'options': {}},
                \       keys.n.vsplitandgoto: {'action': 'vertical split \| %s', 'options': {}}
                \   }
                \ }
endfun