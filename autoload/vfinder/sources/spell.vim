" Creation         : 2018-03-16
" Last modification: 2018-12-22


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#spell#get(...) abort " {{{1
    redraw!
    let is_valid = s:spell_is_valid()
    let to_execute = is_valid
                \ ? s:spell_source()
                \ : []
    call s:spell_define_maps()
    return {
                \   'name'         : 'spell',
                \   'to_execute'   : to_execute,
                \   'format_fun'   : function('s:spell_format'),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_index'),
                \   'maps'         : s:spell_maps(),
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

fun! s:spell_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('spell')
    let options = {'function': 1}
    let maps.i = {keys.i.use: {'action': function('s:use_suggestion'), 'options': options}}
    let maps.n = {keys.n.use: {'action': function('s:use_suggestion'), 'options': options}}
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:use_suggestion(i) abort " {{{1
    try
        let pos = getpos('.')
        silent execute 'normal! ' . a:i . 'z='
        " Depending of the suggestion length, the position may not be accurate.
        call setpos('.', pos)
    catch
        unsilent call vfinder#helpers#throw(v:exception)
    endtry
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:spell_is_valid() " {{{1
    if !&l:spell
        unsilent call vfinder#helpers#echo('`spell` option is not enabled', 'WarningMsg', 'spell')
        return v:false
    else
        return v:true
    endif
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:spell_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('spell', {
                \ 'i': {'use': '<CR>'},
                \ 'n': {'use': '<CR>'}
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
