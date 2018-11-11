" Creation         : 2018-02-19
" Last modification: 2018-11-11


fun! vfinder#sources#directories#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#directories#get() abort " {{{1
     return {
                \   'name'         : 'directories',
                \   'to_execute'   : function('s:directories_source'),
                \   'format_fun'   : function('s:directories_format'),
                \   'syntax_fun'   : function('s:directories_syntax_fun'),
                \   'maps'         : vfinder#sources#directories#maps(),
                \ }
endfun
" 1}}}

fun! s:directories_source() abort " {{{1
    let wd = getcwd() . '/'
    let dirs = glob(wd . '*/', 1, 1)
    let dirs += glob(wd . '.*/', 1, 1)[2:]
    return ['../'] + map(copy(dirs), 'fnamemodify(v:val, ":.")')
endfun
" 1}}}

fun! s:directories_format(dirs) abort " {{{1
    return map(copy(a:dirs), 'v:val !~# "/$" ? v:val . "/" : v:val')
endfun
" 1}}}

fun! s:directories_syntax_fun() abort " {{{1
    syntax match vfinderDirectoriesHidden =^\.\f\+$=
    syntax match vfinderDirectoriesGoback =\%2l\.\./=
    highlight! link vfinderDirectoriesHidden Comment
    highlight! link vfinderDirectoriesGoback CursorLineNr
endfun
" 1}}}

fun! vfinder#sources#directories#maps() abort " {{{1
    let keys = vfinder#maps#get('directories')
    let glob_keys = vfinder#maps#get('_')
    let keys_reload_i = glob_keys.i.candidates_update
    let keys_reload_n = glob_keys.n.candidates_update
    let options = {
                \   'clear_prompt': 1,
                \   'function'    : 1,
                \   'quit'        : 0,
                \   'silent'      : 0
                \ }
    return {
                \   'i': {
                \       keys.i.goto  : {'action': function('s:goto'), 'options': options},
                \       keys.i.go_back: {'action': function('s:go_back'), 'options': options},
                \       keys.i.cd    : {'action': function('s:cd'), 'options': extend(copy(options), {'quit': 1, 'execute_in_place': 1}, 'force')},
                \       keys_reload_i: {'action': function('s:reload_i'), 'options': {'function': 1, 'quit': 0}}
                \   },
                \   'n': {
                \       keys.n.goto  : {'action': function('s:goto'), 'options': options},
                \       keys.n.go_back: {'action': function('s:go_back'), 'options': options},
                \       keys.n.cd    : {'action': function('s:cd'), 'options': extend(copy(options), {'quit': 1, 'execute_in_place': 1}, 'force')},
                \       keys_reload_n: {'action': function('s:reload_n'), 'options': {'function': 1, 'quit': 0}}
                \   }
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:goto(path) abort " {{{1
    if a:path is# '../'
        call s:go_back('../')
    else
        let goto = exists('b:vf.last_wd')
                    \ ? b:vf.last_wd . a:path
                    \ : a:path
        call s:set_path_to(goto)
    endif
endfun
" 1}}}

fun! s:go_back(path) abort " {{{1
    let goto = exists('b:vf.last_wd') && b:vf.last_wd isnot# '/..'
                \ ? b:vf.last_wd . '../'
                \ : b:vf.initial_wd . '../'
    call s:set_path_to(goto)
endfun
" 1}}}

fun! s:cd(path) abort " {{{1
    let goto = exists('b:vf.last_wd')
                \ ? fnamemodify(b:vf.last_wd . a:path, ':p')
                \ : a:path
    execute 'cd ' . goto
    pwd
endfun
" 1}}}

fun! s:reload_i(...) abort " {{{1
    call s:reload()
    startinsert!
endfun
" 1}}}

fun! s:reload_n(...) abort " {{{1
    call s:reload()
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:set_path_to(dir) abort " {{{1
    let path = fnamemodify(a:dir, ':p')
    silent execute 'cd ' . path
    call vfinder#prompt#i().render('')
    call vfinder#events#update_candidates_request()
    silent execute 'cd ' . b:vf.initial_wd
    let b:vf.last_wd = path
endfun
" 1}}}

fun! s:reload() abort " {{{1
    if exists('b:vf.last_wd')
        call remove(b:vf, 'last_wd')
    endif
    call vfinder#events#update_candidates_request()
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
