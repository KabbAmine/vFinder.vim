" Creation         : 2018-02-04
" Last modification: 2018-02-22


fun! vfinder#buffer#i(name) abort
    return {
                \   'name'           : 'vf__' . a:name . '__',
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
    call self.set_options().set_syntax().set_maps().set_autocmds()
    call self.set_statusline()
    return self
endfun

fun! s:buffer_quit() dict
    call s:wipe_buffer(self.name)
    return self
endfun

fun! s:buffer_set_options() dict
    setfiletype vfinder
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
    nnoremap <silent> <buffer> q :call <SID>wipe_buffer()<CR>
    inoremap <silent> <buffer> <BS> <Esc>:call <SID>backspace()<CR>
    inoremap <silent> <buffer> <C-w> <Esc>:call <SID>control_w()<CR>
    inoremap <silent> <buffer> <C-u> <Esc>:call <SID>control_u()<CR>
    nnoremap <silent> <buffer> i :call vfinder#helpers#go_to_prompt()<CR>
    nnoremap <silent> <buffer> I :call vfinder#helpers#go_to_prompt()<CR>
    nnoremap <silent> <buffer> a :call vfinder#helpers#go_to_prompt()<CR>
    nnoremap <silent> <buffer> A :call vfinder#helpers#go_to_prompt()<CR>
    nnoremap <silent> <buffer> o :call vfinder#helpers#go_to_prompt()<CR>
    nnoremap <silent> <buffer> O :call vfinder#helpers#go_to_prompt()<CR>
    nnoremap <silent> <buffer> R :call <SID>update_candidates_n()<CR>
    inoremap <silent> <buffer> <C-r> <Esc>:call <SID>update_candidates_i()<CR>
    nnoremap <silent> <buffer> x <Nop>
    nnoremap <silent> <buffer> c <Nop>
    nnoremap <silent> <buffer> d <Nop>
    nnoremap <silent> <buffer> <CR> <Nop>
    inoremap <silent> <buffer> <F5> <Esc>:call <SID>clean_cache_if_it_exists(1)<CR>
    nnoremap <silent> <buffer> <F5> :call <SID>clean_cache_if_it_exists()<CR>
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
    if vfinder#helpers#is_in_prompt()
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

fun! s:backspace() abort
    let prompt = vfinder#prompt#i()
    let new_query = prompt.get_query().query[:-2]
    call prompt.render(new_query)
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, 0)
    endif
    startinsert!
endfun

fun! s:control_w() abort
    let prompt = vfinder#prompt#i()
    " We use here \S instead of \w to allow special characters
    let query = substitute(prompt.get_query().query, '\s*\S*$', '', '')
    call prompt.render(query)
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, 0)
    endif
    startinsert!
endfun

fun! s:control_u() abort
    let prompt = vfinder#prompt#i()
    call prompt.render('')
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, 0)
    endif
    startinsert!
endfun

fun! s:update_candidates_i() abort
    call vfinder#events#update_candidates_request()
    startinsert!
endfun

fun! s:update_candidates_n() abort
    let pos = getpos('.')
    call vfinder#events#update_candidates_request()
    call setpos('.', pos)
    stopinsert
endfun

fun! s:clean_cache_if_it_exists(...) abort
    " a:1 is when we came from insert mode
    let name = bufname('%')
    if vfinder#cache#exists(name)
        call vfinder#cache#clean(name)
        call vfinder#events#update_candidates_request()
        silent execute exists('a:1') ? 'startinsert!' : 'normal! 1gg$'
    else
        call vfinder#helpers#echo('No cache for the source "' . name . '"', 'Function')
        if exists('a:1')
            call s:set_insertion_position()
        endif
    endif
endfun
