" Creation         : 2018-12-09
" Last modification: 2018-12-12


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#help#get(...) abort " {{{1
    call s:help_define_maps()
    return {
                \   'name'         : 'help',
                \   'to_execute'   : function('s:help_source'),
                \   'format_fun'   : function('s:help_format_fun'),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_first_non_whitespace'),
                \   'syntax_fun'   : function('s:help_syntax_fun'),
                \   'maps'         : s:help_maps()
                \ }
endfun
" 1}}}

fun! s:help_source() abort " {{{1
    " inspired from fzf-helptags
    let ht = []
    for f in uniq(sort(split(globpath(&runtimepath, 'doc/tags', 1), "\n")))
        let ht += readfile(f)
    endfor
    return ht
endfun
" 1}}}

fun! s:help_format_fun(ht) abort " {{{1
    let res = []
    for h in copy(a:ht)
        let splitted = split(h, '\t')
        call add(res, printf('%-50s %s', splitted[0], splitted[1]))
    endfor
    return res
endfun
" 1}}}

fun! s:help_syntax_fun() abort " {{{1
    syntax match vfinderHelpFilename =\%>1l\f\+$=
    highlight default link vfinderHelpFilename vfinderIndex
endfun
" 1}}}

fun! s:help_maps() abort " {{{1
    let maps = {}
    let keys = vfinder#maps#get('help')
    let actions = vfinder#actions#get('help')
    let maps.i = {
                \   keys.i.open: actions.open,
                \   keys.i.open_in_vsplit: actions.open_in_vsplit
                \ }
    let maps.n = {
                \   keys.i.open: actions.open,
                \   keys.i.open_in_vsplit: actions.open_in_vsplit
                \ }
    return maps
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:help_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('help', {
                \   'i': {
                \       'open'          : '<CR>',
                \       'open_in_vsplit': '<C-v>'
                \   },
                \   'n': {
                \       'open'          : '<CR>',
                \       'open_in_vsplit': 'v'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
