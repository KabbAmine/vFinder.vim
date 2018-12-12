" Creation         : 2018-02-04
" Last modification: 2018-12-12


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
    highlight default link CursorLine vfinderPreviewCursorLine
    let s:flash_timer = timer_start(100, {t ->
                \    setwinvar(
                \       a:win_nr,
                \       '&cursorline',
                \       !getwinvar(a:win_nr, '&cursorline'))
                \ }, {'repeat': 4})
    " Stop the flashing when the line changes, set back the initial
    " cursorline's higroup and unlet all the s:vars.
    augroup VFPostFlashLine
        autocmd!
        autocmd CursorMoved,CursorMovedI <buffer>
                    \ if exists('s:initial_line') && line('.') isnot# s:initial_line
                    \|  call s:clean_flash_setup()
                    \| endif
        autocmd CursorHold,CursorHoldI <buffer> call s:clean_flash_setup()
    augroup END
    " Ensure to set back the cursor line initial higroup another
    " time with the timer
    call timer_start(600, {t -> s:clean_flash_setup()})
    " Then delete the augroup
    call timer_start(700, {t -> s:delete_flash_augroup()})
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

fun! vfinder#helpers#in_git_project() abort " {{{1
    return executable('git') && isdirectory('./.git')
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	misc
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#helpers#process_query(query) abort " {{{1
    let q = b:vf.flags.fuzzy
                \ ? substitute(a:query, ' ', '', 'g')
                \ : a:query
    let q_sep = b:vf.flags.fuzzy ? '\zs' : ' '
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

    silent execute 'normal! zv'
    if exists('a:1')
        silent execute 'normal! z' . a:1
    endif
endfun
" 1}}}

fun! vfinder#helpers#autoclose_pwindow_autocmd() abort " {{{1
    augroup VFAutoClosePWindow
        autocmd!
        " The augroup will be deleted when the buffer is
        " closed/deleted/wiped
        autocmd BufDelete,BufWipeout <buffer> unsilent echomsg 'wéé' | pclose!
    augroup END
endfun
" 1}}}

fun! vfinder#helpers#get_bufname(nr) abort " {{{1
    return empty(bufname(a:nr))
                \ ? '[No Name]'
                \ : fnamemodify(bufname(a:nr), ':~:.')
endfun
" 1}}}

fun! vfinder#helpers#open_and_close_empty_vf() abort " {{{1
    silent call vfinder#i({'name': '!', 'to_execute': [], 'maps': {
                \   'i': {'<CR>': {'action': '%s', 'options': {}} },
                \   'n': {'<CR>': {'action': '%s', 'options': {}} }
                \ }})
    silent execute bufnr('vf__!__') . 'bwipeout'
endfun
" 1}}}

fun! vfinder#helpers#throw(msg) abort " {{{1
    " For some reason, its impossible to throw msg which start with 'Vim'
    let e = a:msg =~# '^Vim' ? 'vim' . a:msg[3:] : a:msg
    throw e
endfun
" 1}}}

fun! vfinder#helpers#go_to_initial_col_i(col) abort " {{{1
    startinsert
    call cursor(line('.'), a:col + 1)
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
    unlet! s:initial_cursorline s:initial_cl_hi s:initial_line s:flash_timer
endfun
" 1}}}

fun! s:delete_flash_augroup() abort " {{{1
    augroup VFPostFlashLine | autocmd! | augroup END | augroup! VFPostFlashLine
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
