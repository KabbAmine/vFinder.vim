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
                \ }
endfun

fun! s:buffer_new() dict
    call self.quit()
    silent execute 'topleft split ' . self.name
    call self.set_syntax().set_options().set_maps().set_autocmds()
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
    return self
endfun

fun! s:buffer_set_autocmds() dict
    augroup VFinder
        autocmd!
        autocmd TextChangedI <buffer> :call vfinder#events#query_modified()
    augroup END
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
