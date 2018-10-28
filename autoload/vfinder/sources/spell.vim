" Creation         : 2018-03-16
" Last modification: 2018-10-28


fun! vfinder#sources#spell#check()
    return v:true
endfun

fun! vfinder#sources#spell#get() abort
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

fun! s:spell_is_valid()
    if !&l:spell
        call vfinder#helpers#echo('`spell` option is not enabled', 'WarningMsg')
        return 0
    else
        return 1
    endif
endfun

fun! s:spell_source() abort
    " [' 1 "foo"',' 2 "fou"']
    return split(execute('normal! z='), "\n")[1:-2]
endfun

fun! s:spell_format(suggestions) abort
    let res = []
    for s in a:suggestions
        let i = matchstr(s, '^\s*\zs\d\+')
        let sug = matchstr(s, '"\zs.*\ze"')
        call add(res, printf('%-3s %s', i, sug))
    endfor
    return res
endfun

fun! s:spell_candidate_fun() abort
    return matchstr(getline('.'), '^\d\+\ze')
endfun

fun! vfinder#sources#spell#maps() abort
    let maps = {}
    let keys = vfinder#maps#get('spell')
    let maps.i = {keys.i.use: {'action': function('s:use_suggestion'), 'options': {'function': 1}}}
    let maps.n = {keys.n.use: {'action': function('s:use_suggestion'), 'options': {'function': 1}}}
    return maps
endfun

fun! s:use_suggestion(i) abort
    let pos = getpos('.')
    silent execute 'normal! ' . a:i . 'z='
    " Depending of the suggestion length, the position may not be accurate.
    call setpos('.', pos)
endfun
