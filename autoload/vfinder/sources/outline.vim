" Creation         : 2018-02-11
" Last modification: 2018-02-23


fun! vfinder#sources#outline#check()
    return v:true
endfun

fun! vfinder#sources#outline#get() abort
    return {
                \   'name'         : 'outline',
                \   'is_valid'     : s:outline_is_valid(),
                \   'to_execute'   : s:outline_source(),
                \   'format_fun'   : function('s:outline_format'),
                \   'candidate_fun': function('s:outline_candidate_fun'),
                \   'syntax_fun'   : function('s:outline_syntax_fun'),
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
    " Return the approriate ctags command string.
    " current_file.py    -> return 'ctags --sort=no current_file.py'
    " current_file.py[+] -> save the content to a temp file 'xxx.py' and return
    " 			    'ctags --sort=no xxx.py'
    " current_file[+]    -> save the content to a temp file 'xxx' and return
    " 			    'ctags --sort=no --language-force=&l:ft xxx'

    let cmd = ['ctags', '--sort=no']
    if !&l:modified
        let cmd += ['-x', expand('%:p')]
    else
        let ext = fnamemodify(bufname('%'), ':e')
        let ft = &l:filetype
        let temp_file = tempname()
        if empty(ext)
            let cmd += ['--language-force=' . ft]
        else
            let temp_file .= '.' . ext
        endif
        call writefile(getline(1, '$'), temp_file)
        let cmd += ['-x', temp_file]
    endif
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
