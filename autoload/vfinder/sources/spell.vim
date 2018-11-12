" Creation         : 2018-03-16
" Last modification: 2018-11-09


fun! vfinder#sources#spell#check() " {{{1
    return v:true
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#spell#get() abort " {{{1
    redraw!
    let is_valid = s:spell_is_valid()
    let to_execute = is_valid
                \ ? s:spell_source()
                \ : []
    return {
                \   'name'         : 'spell',
                \   'to_execute'   : to_execute,
                \   'format_fun'   : function('s:spell_format'),
                \   'candidate_fun': function('s:spell_candidate_fun'),
                \   'maps'         : vfinder#sources#spell#maps(),
                \   'is_valid'     : is_valid,
                \ }
endfun
" 1}}}

fun! s:spell_source() abort " {{{1
    " [' 1 "foo"',' 2 "fou"']
    return split(execute('normal! z='), "\n")[1:-2]
endfun
" 1}}}

fun! s:spell_format(suggestions) abort " {{{1
    let res = []
    for s in a:suggestions
        let i = matchstr(s, '^\s*\zs\d\+')
        let sug = matchstr(s, '"\zs.*\ze"')
        call add(res, printf('%-3s %s', i, sug))
    endfor
    return res
endfun
" 1}}}

fun! s:spell_candidate_fun() abort " {{{1
    return matchstr(getline('.'), '^\d\+\ze')
endfun
" 1}}}

fun! vfinder#sources#spell#maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('spell')
    let options = {'function': 1, 'silent': 0}
    let maps.i = {keys.i.use: {'action': function('s:use_suggestion'), 'options': options}}
    let maps.n = {keys.n.use: {'action': function('s:use_suggestion'), 'options': options}}
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:use_suggestion(i) abort " {{{1
    let pos = getpos('.')
    silent execute 'normal! ' . a:i . 'z='
    " Depending of the suggestion length, the position may not be accurate.
    call setpos('.', pos)
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:spell_is_valid() " {{{1
    if !&l:spell
        call vfinder#helpers#echo('`spell` option is not enabled', 'WarningMsg')
        return 0
    else
        return 1
    endif
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
