" Creation         : 2018-02-04
" Last modification: 2018-11-17


" s:vars {{{1
let s:title = '[vfinder]'
let s:title_hi = 'vfinderPrompt'
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	prompt
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#helpers#go_to_prompt_and_startinsert() " {{{1
    call cursor(1, 0)
    startinsert!
endfun
" 1}}}

fun! vfinder#helpers#is_in_prompt() " {{{1
    return line('.') is# 1 ? 1 : 0
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	ui
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#helpers#echomsg(msg, ...) abort " {{{1
    let higroup = get(a:, 1, s:title_hi)
    silent execute 'echohl ' . higroup
    echomsg s:title . ' ' . a:msg
    echohl None
endfun
" 1}}}

fun! vfinder#helpers#echo(msg, ...) abort " {{{1
    " a:1: higroup
    " a:2: extra to title

    let higroup = empty(get(a:, 1, ''))
                \ ? s:title_hi
                \ : a:1
    let extra_title = get(a:, 2, '')
    let title = !empty(extra_title)
                \ ? s:title[:-2] . '-' . extra_title . ']'
                \ : s:title
    execute 'echohl ' . higroup
    echon title . ' '
    echohl None | echon a:msg
endfun
" 1}}}

fun! vfinder#helpers#question(msg, prompt) abort " {{{1
    echohl Question
    echon s:title . ' '
    echohl None
    echon a:msg
    let response = input(a:prompt)
    return response
endfun
" 1}}}

fun! vfinder#helpers#flash_line(win_nr) abort " {{{1
    " Flash the current line of a:win_nr by toggling the cursorline option a
    " few times.
    if !g:vfinder_flash
        return ''
    endif
    let s:initial_cl_hi = matchstr(
                \   split(execute('highlight cursorline'), "\n")[0],
                \   'xxx\s\+\zs.*'
                \ )
    let s:initial_cursorline = getwinvar(a:win_nr, '&cursorline')
    let s:buf_nr = bufnr('%')
    let s:initial_line = line('.')
    highlight! link CursorLine vfinderPreviewCursorLine
    let s:flash_timer = timer_start(100, {t ->
                \    setwinvar(
                \       a:win_nr,
                \       '&cursorline',
                \       !getwinvar(a:win_nr, '&cursorline'))
                \ }, {'repeat': 4})
    " Stop the flashing when the line changes, set back the initial
    " cursorline's higroup and unlet all the s:vars.
    " This augroup is executed once, then it deletes itself.
    augroup VFPostFlashLine
        autocmd!
        autocmd CursorMoved,CursorMovedI <buffer>
                    \ if exists('s:initial_line') && line('.') isnot# s:initial_line
                    \|  call s:clean_flash_setup()
                    \|  augroup VFPostFlashLine | autocmd! | augroup END
                    \|  augroup! VFPostFlashLine
                    \| endif
        autocmd CursorHold,CursorHoldI <buffer>
                    \| call s:clean_flash_setup()
                    \| augroup VFPostFlashLine | autocmd! | augroup END
                    \| augroup! VFPostFlashLine
    augroup END
    " Ensure to set back the cursor line initial higroup
    call timer_start(600, {t -> s:clean_flash_setup()})
endfun
" 1}}}

fun! vfinder#helpers#pedit_cmd(...) abort " {{{1
    let file = get(a:, 1, '')
    let win_nr = winnr()
    let [w, h] = [winwidth(win_nr), winheight(win_nr)]

    let pos = w / 2 ># h ? 'v' : 's'
    return pos is# 'v'
                \ ? 'vertical pedit +vertical\ resize\ ' . (w / 2) . ' ' . file
                \ : 'pedit +resize\ ' . (h / 2) . ' ' . file
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	system
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#helpers#black_hole() abort " {{{1
    return '2> /dev/null'
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	misc
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#helpers#process_query(query) abort " {{{1
    let q = b:vf.fuzzy
                \ ? substitute(a:query, ' ', '', 'g')
                \ : a:query
    let q_sep = b:vf.fuzzy ? '\zs' : ' '
    let join_pat = '.{-}'
    let to_escape = '@=?+&$.*~()|{}%[]'
    let final_regex = []
    for item in split(q, q_sep)
        call add(final_regex, escape(item, to_escape))
    endfor
    return '\v' . join(final_regex, join_pat)
endfun
" 1}}}

fun! vfinder#helpers#empty_buffer(...) abort " {{{1
    let buf_nr = exists('a:1') ? a:1 : bufnr('%')
    return join(getbufline(buf_nr, 1, '$')) =~# '^\s*$'
endfun
" 1}}}

fun! vfinder#helpers#get_maps_str_for(name) abort " {{{1
    if &filetype isnot# 'vfinder'
        return ''
    endif
    if !exists('g:vfinder_maps[a:name]')
        return ''
    endif
    let maps = vfinder#maps#get(a:name)
    let str = ' ' . (a:name is# '_' ? 'global' : a:name) . ': '
    for a in keys(maps.i)
        if a =~# '^\(prompt\|window\)'
            " Do not save the prompt-*/window-* mappings
            continue
        endif
        let str .= printf('%s(%s/%s) | ',
                    \   a,
                    \   get(maps.i, a, '-'),
                    \   get(maps.n, a, '-')
                    \ )
    endfor
    " Remove the last ' | '
    return str[:-4]
endfun
" 1}}}

fun! vfinder#helpers#unfold_and_put_line(...) abort " {{{1
    " a:1: (t)op, (b)ottom, (z)middle

    normal! zv
    if exists('a:1')
        execute 'normal! z' . a:1
    endif
endfun
" 1}}}

fun! vfinder#helpers#autoclose_pwindow_autocmd() abort " {{{1
    augroup VFAutoClosePWindow
        autocmd!
        autocmd BufDelete,BufWipeout <buffer> pclose!
                    \| augroup VFAutoClosePWindow
                    \|  autocmd!
                    \| augroup End
                    \| augroup! VFAutoClosePWindow
    augroup END
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:clean_flash_setup() abort " {{{1
    if !exists('s:flash_timer')
        return
    endif
    call timer_stop(s:flash_timer)
    call setbufvar(s:buf_nr, '&cursorline', s:initial_cursorline)
    execute 'highlight CursorLine ' . s:initial_cl_hi
    unlet! s:initial_cursorline s:initial_cl_hi s:win_nr s:initial_line s:flash_timer
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
