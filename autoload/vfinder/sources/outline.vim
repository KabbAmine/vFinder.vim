" Creation         : 2018-02-11
" Last modification: 2018-03-25


fun! vfinder#sources#outline#check()
    return v:true
endfun

fun! vfinder#sources#outline#get() abort
    return {
                \   'name'         : 'outline',
                \   'is_valid'     : s:outline_is_valid(),
                \   'to_execute'   : function('s:outline_source'),
                \   'format_fun'   : function('s:outline_format'),
                \   'candidate_fun': function('s:outline_candidate_fun'),
                \   'syntax_fun'   : function('s:outline_syntax_fun'),
                \   'filter_name'  : 'compact_match',
                \   'maps'         : vfinder#sources#outline#maps()
                \ }
endfun

fun! s:outline_is_valid() abort
    if !executable('ctags')
        call vfinder#helpers#echo('"ctags" was not found', 'Error', 1)
        return 0
    else
        return 1
    endif
endfun

fun! s:outline_source() abort
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

fun! s:outline_format(tags) abort
    let res = []
    for t in a:tags
        " An example of how the output is:
        " Font(s)          Heading_L3   25 .vim/README.md   ### Font(s)
        " Formatters & fixers Heading_L3   30 .vim/README.md   ### Formatters & fixers
        let till_line = matchstr(t, '.*\s\+\d\+\ze\s\+')
        let kind = matchstr(till_line, '\S\+\ze\s\+\d\+$')
        let name = substitute(matchstr(till_line, '^.*\ze\s\+\S\+\s\+\d\+$'), '\s*$', '', '')
        let line = matchstr(till_line, '\d\+$')
        let l = printf('%-50s %-10s %5d', name, '[' . kind . ']', line)
        call add(res, l)
    endfor
    return res
endfun

fun! s:outline_candidate_fun() abort
    return matchstr(getline('.'), '\d\+$')
endfun

fun! s:outline_syntax_fun() abort
    syntax match vfinderOutlineLinenr =\d\+$=
    syntax match vfinderOutlineKind =\s\+\[\S\+\]\s\+=
    highlight! link vfinderOutlineLinenr vfinderIndex
    highlight! link vfinderOutlineKind Identifier
endfun

fun! vfinder#sources#outline#maps() abort
    let keys = vfinder#maps#get('outline')
    return {
                \   'i': {
                \       keys.i.goto       : {'action': '%s', 'options': {}},
                \       keys.i.splitandgoto : {'action': 'split \| %s', 'options': {}},
                \       keys.i.vsplitandgoto: {'action': 'vertical split \| %s', 'options': {}}
                \   },
                \   'n': {
                \       keys.n.goto       : {'action': '%s', 'options': {}},
                \       keys.n.splitandgoto : {'action': 'split \| %s', 'options': {}},
                \       keys.n.vsplitandgoto: {'action': 'vertical split \| %s', 'options': {}}
                \   }
                \ }
endfun
