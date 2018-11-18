" Creation         : 2018-11-18
" Last modification: 2018-11-19


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	main
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#actions#get(name) abort " {{{1
    return s:{a:name}
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	buffers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:buffers_wipe(buffer) abort " {{{1
    let b = str2nr(a:buffer)
    if bufexists(b)
        unsilent execute b . 'bwipeout'
    endif
endfun
" 1}}}

" s:buffers {{{1
let s:buffers = {
                \ 'edit'  : {'action': 'buffer %s', 'options': {'silent': 0}},
                \ 'split' : {'action': 'sbuffer %s', 'options': {'silent': 0}},
                \ 'vsplit': {'action': 'vertical sbuffer %s', 'options': {'silent': 0}},
                \ 'tab'   : {'action': 'tabnew \| buffer %s', 'options': {'silent': 0}},
                \ 'wipe'  : {
                \       'action': function('s:buffers_wipe'),
                \       'options': {'function': 1, 'update': 1, 'quit': 0}
                \       }
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	colors
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:colors {{{1
let s:colors = {
                \ 'apply'  : {'action': 'colorscheme %s', 'options': {'silent': 0}},
                \ 'preview': {'action': 'colorscheme %s', 'options': {'silent': 0, 'quit': 0}}
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	commands
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:commands {{{1
let s:commands = {
                \   'apply': {'action': '%s', 'options': {'silent': 0}},
                \   'echo' : {'action': '%s', 'options': {'silent': 0, 'echo': 1}}
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	files
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

" s:files {{{1
let s:files = {
            \ 'edit'  : {'action': 'edit %s', 'options': {'silent': 0}},
            \ 'split' : {'action': 'split %s', 'options': {'silent': 0}},
            \ 'vsplit': {'action': 'vertical split %s', 'options': {'silent': 0}},
            \ 'tab'   : {'action': 'tabedit %s', 'options': {'silent': 0}}
            \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	marks
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:marks_go_to_mark(m) abort " {{{1
    execute "normal! '" . a:m
    call vfinder#helpers#unfold_and_put_line()
    call vfinder#helpers#flash_line(winnr())
endfun
" 1}}}

fun! s:marks_delete_mark(m) abort " {{{1
    " Only A-Z and 0-9
    if a:m !~ '^\(\u\|\d\)$'
        call vfinder#helpers#echo('only marks in range A-Z or 0-9 can be deleted', 'Error')
        return ''
    endif
    execute 'delmarks ' . a:m
endfun
" 1}}}

" s:marks {{{1
let s:marks = {
                \ 'goto': {
                \       'action': function('s:marks_go_to_mark'),
                \       'options': {'function': 1}
                \       },
                \ 'delete': {
                \       'action': function('s:marks_delete_mark'),
                \       'options': {'function': 1, 'silent': 0, 'quit': 0, 'update': 1}
                \       }
                \ }
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	yank
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:yank_paste(content) abort " {{{1
    " a:content can be something like 'foo^@bar^@zee'

    let [line, col_p] = [line('.'), col('.')]
    let new_lines = split(getline('.')[: col_p - 1] . a:content . getline('.')[col_p :], "\n")
    let go_to_line = line + len(new_lines) - 1
    let go_to_col = col_p + len(split(a:content, "\n")[-1])
    silent execute 'keepjumps ' . line . 'delete_'
    call append(line - 1, new_lines)
    call cursor(go_to_line, go_to_col)
endfun
" 1}}}

" s:yank {{{1
let s:yank = {
                \ 'paste': {
                \   'action': function('s:yank_paste'),
                \   'options': {'function': 1}
                \ }}
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
