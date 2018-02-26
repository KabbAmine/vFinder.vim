" Creation         : 2018-02-11
" Last modification: 2018-02-26


fun! vfinder#sources#outline#check()
    return v:true
endfun

fun! vfinder#sources#outline#get() abort
    let to_execute = s:outline_source()
    return {
                \   'name'                : 'outline',
                \   'is_valid'            : empty(to_execute) ? 0 : 1,
                \   'to_execute'          : to_execute,
                \   'format_fun'          : function('s:outline_format'),
                \   'candidate_fun'       : function('s:outline_candidate_fun'),
                \   'syntax_fun'          : function('s:outline_syntax_fun'),
                \   'maps'                : vfinder#sources#outline#maps()
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
    let cmd = ['ctags', '--sort=no', '-x']

    " Not valid if empty buffer
    if vfinder#helpers#empty_buffer()
        return ''
    endif
    let buffer = bufname('%')
    let modified = getbufvar(buffer, '&modified')
    let file = fnamemodify(buffer, ':p')
    if filereadable(file) && !modified
        let cmd += [file]
    else
        let ext = fnamemodify(buffer, ':e')
        let ft = getbufvar(buffer, '&filetype')
        " Not valid if not extension or filetype
        if empty(ext) && empty(ft)
            return ''
        endif
        let temp_file = tempname()
        if !empty(ext)
            let temp_file .= '.' . ext
        else
            let cmd += ['--language-force=' . ft]
        endif
        call writefile(getline(1, '$'), temp_file)
        let cmd += [temp_file]
    endif

    echomsg join(cmd)
    return join(cmd)
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
    return {
                \   'i': {'<CR>': {'action': '%s', 'options': {}}},
                \   'n': {'<CR>': {'action': '%s', 'options': {}}},
                \ }
endfun
