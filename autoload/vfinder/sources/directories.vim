" Creation         : 2018-02-19
" Last modification: 2018-12-12


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#directories#get(...) abort " {{{1
    call s:directories_define_maps()
    return {
                \   'name'         : 'directories',
                \   'to_execute'   : function('s:directories_source'),
                \   'format_fun'   : function('s:directories_format'),
                \   'syntax_fun'   : function('s:directories_syntax_fun'),
                \   'maps'         : s:directories_maps(),
                \ }
endfun
" 1}}}

fun! s:directories_source() abort " {{{1
    let b:vf.bopts.update_on_win_enter = 0
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
    syntax match vfinderDirectoriesHidden =\%>1l^\.\f\+$=
    syntax match vfinderDirectoriesGoback =\%2l\.\./=
    highlight default link vfinderDirectoriesHidden Comment
    highlight default link vfinderDirectoriesGoback CursorLineNr
endfun
" 1}}}

fun! s:directories_maps() abort " {{{1
    let keys = vfinder#maps#get('directories')
    " Here we need to get the candidates_update action key, but it may not be
    " declared at this time so we shamelessly use a not-so-good hack:
    " - We first get the glob_keys if the variable exists (we silent errors in
    " case it does not)
    " - We check that the var is correct and contains the 'candidates_update'
    " key, and:
    "    * if yes, we continue normally
    "    * otherwise we open and close an empty vfinder buffer to initiliaze
    " the global keys variable once, and resave it in glob_keys var.
    " Note that this workaround is temporary
    silent! let glob_keys = vfinder#maps#get('_')
    if !exists('glob_keys.i.candidates_update') || !exists('glob_keys.n.candidates_update')
        call vfinder#helpers#open_and_close_empty_vf()
        let glob_keys = vfinder#maps#get('_')
    endif
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
        call vfinder#helpers#echo(s:reduce_path(goto))
    endif
endfun
" 1}}}

fun! s:go_back(path) abort " {{{1
    let goto = exists('b:vf.last_wd') && b:vf.last_wd isnot# '/..'
                \ ? b:vf.last_wd . '../'
                \ : b:vf.ctx.wd . '../'
    call s:set_path_to(goto)
    call vfinder#helpers#echo(s:reduce_path(goto))
endfun
" 1}}}

fun! s:cd(path) abort " {{{1
    let goto = exists('b:vf.last_wd')
                \ ? fnamemodify(b:vf.last_wd . a:path, ':p')
                \ : a:path
    execute 'cd ' . goto
    call vfinder#helpers#echo('cd to ' . s:reduce_path(getcwd()))
endfun
" 1}}}

fun! s:reload_i(...) abort " {{{1
    call s:reload('i')
endfun
" 1}}}

fun! s:reload_n(...) abort " {{{1
    call s:reload('n')
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:set_path_to(dir) abort " {{{1
    let path = fnamemodify(a:dir, ':p')
    silent execute 'cd ' . path
    call vfinder#prompt#i().render('')
    silent call vfinder#events#update_candidates_request()
    silent execute 'cd ' . b:vf.ctx.wd
    let b:vf.last_wd = path
endfun
" 1}}}

fun! s:reload(mode) abort " {{{1
    if exists('b:vf.last_wd')
        call remove(b:vf, 'last_wd')
    endif
    call vfinder#events#update_candidates_request(a:mode)
    unsilent call vfinder#helpers#echo(s:reduce_path(getcwd()))
endfun
" 1}}}

fun! s:reduce_path(path) abort " {{{1
    return simplify(fnamemodify(a:path, ':~:.'))
endfun
" )}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:directories_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('directories', {
                \   'i': {
                \       'goto'  : '<CR>',
                \       'go_back': '<C-v>',
                \       'cd'    : '<C-s>'
                \   },
                \   'n': {
                \       'goto'  : '<CR>',
                \       'go_back': 'v',
                \       'cd'    : 's'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
