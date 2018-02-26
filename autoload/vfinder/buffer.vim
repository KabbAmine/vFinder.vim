" Creation         : 2018-02-04
" Last modification: 2018-02-26


fun! vfinder#buffer#i(source) abort
    return {
                \   'source'         : a:source,
                \   'name'           : 'vf__' . a:source.name . '__',
                \   'goto'           : function('s:buffer_goto'),
                \   'new'            : function('s:buffer_new'),
                \   'quit'           : function('s:buffer_quit'),
                \   'set_options'    : function('s:buffer_set_options'),
                \   'set_syntax'     : function('s:buffer_set_syntax'),
                \   'set_maps'       : function('s:buffer_set_maps'),
                \   'set_autocmds'   : function('s:buffer_set_autocmds'),
                \   'set_statusline' : function('s:buffer_set_statusline')
                \ }
endfun

fun! s:buffer_goto() dict
    " If the vf buffer already exists we:
    "    - move to it if its window is in the current tab.
    "    - wipe it and create a new on in the current tab.
    " Otherwise we create a new one.

    if bufexists(self.name)
        let win_nr = bufwinnr(bufname(self.name))
        if win_nr ># 0
            silent execute win_nr . 'wincmd w'
        else
            silent execute 'bwipeout ' . self.name
            call self.new()
        endif
    else
        call self.new()
    endif
    return self
endfun

fun! s:buffer_new() dict
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
    syntax match vfinderIndex =^\d\+\s*=
    highlight! link vfinderPrompt ModeMsg
    highlight! link vfinderIndex Comment
    if !empty(self.source.syntax_fun)
        call call(self.source.syntax_fun, [])
    endif
    return self
endfun

fun! s:buffer_set_maps() dict
    " Prompt & movement
    inoremap <silent> <buffer> <C-n> <Esc>:call <SID>move_down()<CR>
    inoremap <silent> <buffer> <C-p> <Esc>:call <SID>move_up()<CR>
    inoremap <silent> <buffer> <C-h> <Esc>:call <SID>move_left()<CR>
    inoremap <silent> <buffer> <C-l> <Esc>:call <SID>move_right()<CR>
    inoremap <silent> <buffer> <C-a> <Esc>:call <SID>move_to_edge(-1)<CR>
    inoremap <silent> <buffer> <C-e> <Esc>:call <SID>move_to_edge(1)<CR>
    inoremap <silent> <buffer> <BS> <Esc>:call <SID>backspace()<CR>
    inoremap <silent> <buffer> <Del> <Esc>:call <SID>delete()<CR>
    inoremap <silent> <buffer> <C-w> <Esc>:call <SID>control_w()<CR>
    inoremap <silent> <buffer> <C-u> <Esc>:call <SID>control_u()<CR>
    " Insert mode
    nnoremap <silent> <buffer> i :call <SID>start_insert_mode(-1)<CR>
    nnoremap <silent> <buffer> I :call <SID>start_insert_mode(-1)<CR>
    nnoremap <silent> <buffer> a :call <SID>start_insert_mode(1)<CR>
    nnoremap <silent> <buffer> A :call <SID>start_insert_mode(1)<CR>
    " Buffer
    inoremap <silent> <buffer> <Esc> <Esc>:call <SID>wipe_buffer()<CR>
    nnoremap <silent> <buffer> <Esc> :call <SID>wipe_buffer()<CR>
    nnoremap <silent> <buffer> q :call <SID>wipe_buffer()<CR>
    " Candidates & cache
    nnoremap <silent> <buffer> R :call <SID>update_candidates_n()<CR>
    inoremap <silent> <buffer> <C-r> <Esc>:call <SID>update_candidates_i()<CR>
    inoremap <silent> <buffer> <F5> <Esc>:call <SID>clean_cache_if_it_exists(1)<CR>
    nnoremap <silent> <buffer> <F5> :call <SID>clean_cache_if_it_exists()<CR>
    " Disable some default vim keys
    for k in ['<CR>', 'x', 'c', 'd', 'o', 'O']
        silent execute 'nnoremap <silent> <buffer> ' . k . ' <Nop>'
    endfor
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

fun! s:move_down() abort
    let last_line = line('$')
    if line('.') is# last_line
        call cursor(1, 0)
    else
        silent execute 'normal! j'
    endif
    call s:set_insertion_position()
endfun

fun! s:move_up() abort
    if line('.') is# 1
        call cursor(line('$'), 0)
    else
        silent execute 'normal! k'
    endif
    call s:set_insertion_position()
endfun

fun! s:move_left() abort
    startinsert
    if s:already_near_the_prompt_char()
        return ''
    endif
endfun

fun! s:move_right() abort
    startinsert
    call cursor(1, col('.') + 2)
endfun

fun! s:move_to_edge(direction) abort
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, 0)
    endif
    if a:direction ># 0
        startinsert!
    else
        startinsert
        call cursor(1, 3)
    endif
endfun

fun! s:start_insert_mode(...) abort
    if !vfinder#helpers#is_in_prompt()
        call vfinder#helpers#go_to_prompt()
    else
        startinsert
        if !exists('a:1')
            let new_col = col('$')
        elseif a:1 is# 1
            let new_col = col('.') + 1
        elseif a:1 is# -1
            let new_col = col('.')
        endif
        call cursor(1, new_col)
        call s:already_near_the_prompt_char()
    endif
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
        " Be sure to go back to initial window
        silent execute 'wincmd p'
        silent execute 'bwipeout! ' . buffer
    endif
endfun

fun! s:backspace() abort
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, col('$'))
        startinsert!
    endif
    let origin_col = col('.')
    if s:already_near_the_prompt_char()
        return ''
    endif
    let [pre_inp, post_inp] = s:get_pre_post_of_query(origin_col)
    let prompt = vfinder#prompt#i()
    call prompt.render(pre_inp[:-2] . post_inp)
    startinsert
    call cursor(1, origin_col)
endfun

fun! s:delete() abort
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, col('$'))
        startinsert!
    endif
    let origin_col = col('.')
    if origin_col is# col('$')
        return ''
    endif
    let [pre_inp, post_inp] = s:get_pre_post_of_query(origin_col)
    let prompt = vfinder#prompt#i()
    " When we have: _foo, foo is the pre_inp and there is no post_inp, so:
    let query = origin_col is# 2 && empty(post_inp)
                \ ? pre_inp[1:]
                \ : pre_inp . post_inp[1:]
    call prompt.render(query)
    startinsert
    call cursor(1, origin_col + 1)
endfun

fun! s:control_w() abort
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, col('$'))
        startinsert!
    endif
    let origin_col = col('.')
    if s:already_near_the_prompt_char()
        return ''
    endif
    let [pre_inp, post_inp] = s:get_pre_post_of_query(origin_col)
    let prompt = vfinder#prompt#i()
    " We use here \S instead of \w to allow special characters
    let query = prompt.get_query().query
    let pre_inp = substitute(pre_inp, '\S\+\s*$', '', '')
    let new_query = pre_inp . post_inp
    call prompt.render(new_query)
    startinsert
    let len_deleted = len(query) - len(new_query)
    let new_col = origin_col - len_deleted
    call cursor(1, new_col + 1)
endfun

fun! s:control_u() abort
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, col('$'))
        startinsert!
    endif
    let origin_col = col('.')
    if s:already_near_the_prompt_char()
        return ''
    endif
    let post_inp = s:get_pre_post_of_query(origin_col)[1]
    let prompt = vfinder#prompt#i()
    call prompt.render(post_inp)
    startinsert
    call cursor(1, 3)
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
    " The bufname is vf__foo_bar__
    let name = bufname('%')[4:-3]
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

fun! s:already_near_the_prompt_char() abort
    if col('.') <# 3
        startinsert
        call cursor(1, 3)
        return 1
    else
        return 0
    endif
endfun

fun! s:get_pre_post_of_query(col) abort
    " From a:col split query in pre & post part and return them.
    let query = getline('.')[2:]
    let pre_inp = query[: a:col - 3]
    let post_inp = strcharpart(query, len(pre_inp))
    return [pre_inp, post_inp]
endfun
