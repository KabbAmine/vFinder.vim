" Creation         : 2018-02-19
" Last modification: 2018-02-19


fun! vfinder#sources#directories#check()
    return v:true
endfun

fun! vfinder#sources#directories#get() abort
     return {
                \   'name'         : 'directories',
                \   'to_execute'   : function('s:directories_source'),
                \   'format_fun'   : function('s:directories_format'),
                \   'candidate_fun': function('s:directories_candidate_fun'),
                \   'maps'         : vfinder#sources#directories#maps(),
                \ }
endfun

fun! s:directories_source() abort
    let dirs = glob('*/', 1, 1)
    let dirs += glob('.*/', 1, 1)[2:]
    return ['../'] + map(copy(dirs), 'fnamemodify(v:val, ":.")')
endfun

fun! s:directories_format(dirs) abort
    return map(copy(a:dirs), 'v:val !~# "/$" ? v:val . "/" : v:val')
endfun

fun! s:directories_candidate_fun() abort
    return fnamemodify(getline('.'), ':p')
endfun

fun! vfinder#sources#directories#maps() abort " {{{2
    let options = {
                \   'silent'      : 0,
                \   'update'      : 1,
                \   'quit'        : 0,
                \   'clear_prompt': 1
                \ }
    return {
                \   'i': {
                \       '<CR>' : {'action': 'cd %s', 'options': {'silent': 0}},
                \       '<C-o>': {'action': 'cd %s', 'options': options},
                \       '<C-e>': {'action': 'cd ..', 'options': options}
                \   },
                \   'n': {
                \       '<CR>': {'action': 'cd %s', 'options': options},
                \       'o'   : {'action': 'cd %s', 'options': {'silent': 0}},
                \       'e'   : {'action': 'cd ..', 'options': options},
                \   }
                \ }
endfun
