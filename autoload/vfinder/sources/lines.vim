" Creation         : 2018-12-21
" Last modification: 2018-12-21


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#lines#get(...) abort " {{{1
    call s:lines_define_maps()
    return {
                \   'name'         : 'lines',
                \   'to_execute'   : function('s:lines_source'),
                \   'candidate_fun': function('vfinder#global#candidate_fun_get_index'),
                \   'format_fun'   : function('s:lines_format_fun'),
                \   'maps'         : s:lines_maps()
                \ }
endfun
" 1}}}

fun! s:lines_source() abort " {{{1
    return getbufline(b:vf.ctx.bufnr, 1, '$')
endfun
" 1}}}

fun! s:lines_format_fun(lines) abort " {{{1
    " Add line number & remove empty lines
    return filter(map(copy(a:lines), {
                \       i, v -> printf('%d %s', i + 1, v)
                \   }), {_, v -> v !~# '^\d\+ \s*$'})
endfun
" 1}}}

fun! s:lines_maps() abort " {{{1
    let keys = vfinder#maps#get('lines')
    return {
                \   'i': {
                \     keys.i.goto            : {'action': 'normal! %sggzv', 'options': {}},
                \     keys.i.split_and_goto  : {'action': 'split \| normal! %sggzv', 'options': {}},
                \     keys.i.vsplit_and_goto : {'action': 'vsplit \| normal! %sggzv', 'options': {}},
                \     keys.i.tab_and_goto    : {'action': 'tab split \| normal! %sggzv', 'options': {}},
                \   },
                \   'n': {
                \     keys.i.goto            : {'action': 'normal! %sggzv', 'options': {}},
                \     keys.i.split_and_goto  : {'action': 'split \| normal! %sggzv', 'options': {}},
                \     keys.i.vsplit_and_goto : {'action': 'vsplit \| normal! %sggzv', 'options': {}},
                \     keys.i.tab_and_goto    : {'action': 'tab split \| normal! %sggzv', 'options': {}},
                \   }
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:lines_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('lines', {
                \ 'i': {
                \   'goto'           : '<CR>',
                \   'split_and_goto' : '<C-s>',
                \   'vsplit_and_goto': '<C-v>',
                \   'tab_and_goto'   : '<C-t>'
                \ },
                \ 'n': {
                \   'goto'           : '<CR>',
                \   'split_and_goto' : '<C-s>',
                \   'vsplit_and_goto': '<C-v>',
                \   'tab_and_goto'   : 't'
                \ }})
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
