" Creation         : 2018-02-19
" Last modification: 2018-03-25


fun! vfinder#sources#directories#check()
    return v:true
endfun

fun! vfinder#sources#directories#get() abort
     return {
                \   'name'         : 'directories',
                \   'to_execute'   : function('s:directories_source'),
                \   'format_fun'   : function('s:directories_format'),
                \   'syntax_fun'   : function('s:directories_syntax_fun'),
                \   'maps'         : vfinder#sources#directories#maps(),
                \ }
endfun

fun! s:directories_source() abort
    let wd = getcwd() . '/'
    let dirs = glob(wd . '*/', 1, 1)
    let dirs += glob(wd . '.*/', 1, 1)[2:]
    return ['../'] + map(copy(dirs), 'fnamemodify(v:val, ":.")')
endfun

fun! s:directories_format(dirs) abort
    return map(copy(a:dirs), 'v:val !~# "/$" ? v:val . "/" : v:val')
endfun

fun! s:directories_syntax_fun() abort
    syntax match vfinderDirectoriesHidden =^\.\f\+$=
    syntax match vfinderDirectoriesGoback =\%2l\.\./=
    highlight! link vfinderDirectoriesHidden Comment
    highlight! link vfinderDirectoriesGoback CursorLineNr
endfun

fun! vfinder#sources#directories#maps() abort
    let keys = vfinder#maps#get('directories')
    let options = {
                \   'clear_prompt': 1,
                \   'function'    : 1,
                \   'quit'        : 0,
                \   'silent'      : 0
                \ }
    return {
                \   'i': {
                \       keys.i.goto  : {'action': function('s:goto'), 'options': options},
                \       keys.i.goback: {'action': function('s:goback'), 'options': options},
                \       keys.i.cd    : {'action': function('s:cd'), 'options': extend(copy(options), {'quit': 1, 'exec_in_vf': 1}, 'force')}
                \   },
                \   'n': {
                \       keys.n.goto  : {'action': function('s:goto'), 'options': options},
                \       keys.n.goback: {'action': function('s:goback'), 'options': options},
                \       keys.n.cd    : {'action': function('s:cd'), 'options': extend(copy(options), {'quit': 1, 'exec_in_vf': 1}, 'force')}
                \   }
                \ }
endfun

fun! s:goto(path) abort
    if a:path is# '../'
        call s:goback('../')
    else
        let goto = exists('b:vf.last_wd')
                    \ ? fnamemodify(b:vf.last_wd . a:path, ':p')
                    \ : a:path
        call s:set_path_to(goto)
    endif
endfun

fun! s:goback(path) abort
    let goto = exists('b:vf.last_wd') && b:vf.last_wd isnot# '/..'
                \ ? fnamemodify(b:vf.last_wd . '../', ':p')
                \ : b:vf.initial_wd . '../'
    call s:set_path_to(goto)
endfun

fun! s:set_path_to(dir) abort
    silent execute 'cd ' . a:dir
    call vfinder#prompt#i().render('')
    call vfinder#events#update_candidates_request()
    silent execute 'cd ' . b:vf.initial_wd
    let b:vf.last_wd = a:dir
endfun

fun! s:cd(path) abort
    let goto = exists('b:vf.last_wd')
                \ ? fnamemodify(b:vf.last_wd . a:path, ':p')
                \ : a:path
    silent execute 'cd ' . goto
endfun
