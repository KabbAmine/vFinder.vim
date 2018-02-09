" Creation         : 2018-02-04
" Last modification: 2018-02-09


fun! vfinder#buffer#i(name) abort
    return {
                \   'name'           : a:name,
                \   'new'            : function('s:buffer_new'),
                \   'quit'           : function('s:buffer_quit'),
                \   'set_options'    : function('s:buffer_set_options'),
                \   'set_syntax'     : function('s:buffer_set_syntax'),
                \   'set_maps'       : function('s:buffer_set_maps'),
                \   'set_autocmds'   : function('s:buffer_set_autocmds'),
                \   'set_statusline' : function('s:buffer_set_statusline')
                \ }
endfun

fun! s:buffer_new() dict
    call self.quit()
    silent execute 'topleft split ' . self.name
    call self.set_syntax().set_options().set_maps().set_autocmds()
    call self.set_statusline()
    return self
endfun

fun! s:buffer_quit() dict
    call s:wipe_buffer(self.name)
    return self
endfun

fun! s:buffer_set_options() dict
    setlocal nonumber
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal modifiable
    setlocal cursorline
    setlocal nowrap
    return self
endfun

fun! s:buffer_set_syntax() dict
    syntax clear
    syntax case ignore
    syntax match vfinderPrompt =\%1l.*=
    highlight! link vfinderPrompt ModeMsg
    return self
endfun

fun! s:buffer_set_maps() dict
    inoremap <silent> <buffer> <C-n> <Esc>:call <SID>move_down_i()<CR>
    inoremap <silent> <buffer> <C-p> <Esc>:call <SID>move_up_i()<CR>
    inoremap <silent> <buffer> <Esc> <Esc>:call <SID>wipe_buffer()<CR>
    nnoremap <silent> <buffer> <Esc> :call <SID>wipe_buffer()<CR>
    nmap <silent> <buffer> q <Esc>
    nnoremap <silent> <buffer> i :call <SID>go_to_prompt()<CR>
    nnoremap <silent> <buffer> I :call <SID>go_to_prompt()<CR>
    nnoremap <silent> <buffer> a :call <SID>go_to_prompt()<CR>
    nnoremap <silent> <buffer> A :call <SID>go_to_prompt()<CR>
    nnoremap <silent> <buffer> o :call <SID>go_to_prompt()<CR>
    nnoremap <silent> <buffer> O :call <SID>go_to_prompt()<CR>
    nnoremap <silent> <buffer> R :call <SID>update_candidates_and_stay()<CR>
    inoremap <silent> <buffer> <C-r> <Esc>:call <SID>update_candidates()<CR>
    inoremap <silent> <buffer> <expr> <BS> <SID>backspace()
    inoremap <silent> <buffer> <expr> <C-w> <SID>control_w()
    inoremap <silent> <buffer> <expr> <C-u> <SID>control_u()
    return self
endfun

fun! s:buffer_set_autocmds() dict
    augroup VFinder
        autocmd!
        autocmd TextChangedI <buffer> :call vfinder#events#query_modified()
        autocmd InsertCharPre <buffer> :call vfinder#events#char_inserted()
    augroup END
endfun

fun! s:buffer_set_statusline() dict
    setlocal statusline=%{vfinder#statusline#get()}
endfun

fun! s:move_down_i() abort
    let current_line = line('.')
    let last_line = line('$')
    if current_line is# last_line
        call cursor(1, 0)
    else
        silent execute 'normal! j'
    endif
    call s:set_insertion_position()
endfun

fun! s:move_up_i() abort
    let current_line = line('.')
    if current_line is# 1
        call cursor(line('$'), 0)
    else
        silent execute 'normal! k'
    endif
    call s:set_insertion_position()
endfun

fun! s:set_insertion_position() abort
    if line('.') is# 1
        startinsert!
    else
        silent execute 'normal! ^'
        startinsert
    endif
endfun

fun! s:wipe_buffer(...) abort
    let buffer = exists('a:1') ? a:1 : bufname('%')
    if bufexists(buffer)
        silent execute 'bwipeout! ' . buffer
    endif
endfun

fun! s:go_to_prompt() abort
    call cursor(1, 0)
    startinsert!
endfun

fun! s:update_candidates_and_stay() abort
    let pos = getpos('.')
    call vfinder#events#update_candidates_request()
    call setpos('.', pos)
    stopinsert
endfun

fun! s:update_candidates() abort
    call vfinder#events#update_candidates_request()
    startinsert!
endfun

fun! s:backspace() abort
    return line('.') is# 1
                \ ? "\<BS>"
                \ : "\<C-o>1gg\<C-o>$\<BS>"
endfun

fun! s:control_w() abort
    return line('.') is# 1
                \ ? "\<C-w>"
                \ : "\<C-o>1gg\<C-o>$\<C-w>"
endfun

fun! s:control_u() abort
    return line('.') is# 1
                \ ? "\<C-u>"
                \ : "\<C-o>1gg\<C-o>$\<C-u>"
endfun
