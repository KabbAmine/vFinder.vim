" Creation         : 2018-02-04
" Last modification: 2018-12-17


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"		    main buffer object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#buffer#i(source, sopts) abort " {{{1
    call s:buffer_define_maps()
    return {
                \   'source'        : a:source,
                \   'name'          : 'vf__' . a:source.name . '__',
                \   'win_pos'       : a:sopts.win_pos,
                \   'goto'          : function('s:buffer_goto'),
                \   'new'           : function('s:buffer_new'),
                \   'quit'          : function('s:buffer_quit'),
                \   'set_options'   : function('s:buffer_set_options'),
                \   'set_syntax'    : function('s:buffer_set_syntax'),
                \   'set_maps'      : function('s:buffer_set_maps'),
                \   'set_autocmds'  : function('s:buffer_set_autocmds'),
                \   'set_statusline': function('s:buffer_set_statusline')
                \ }
endfun
" 1}}}

fun! s:buffer_goto() dict abort " {{{1
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
" 1}}}

fun! s:buffer_new() dict abort " {{{1
    silent execute self.win_pos . ' split ' . self.name
    call self.set_options().set_syntax().set_maps().set_autocmds()
    call self.set_statusline()
    return self
endfun
" 1}}}

fun! s:buffer_quit() dict abort " {{{1
    call s:wipe_buffer(self.name)
    return self
endfun
" 1}}}

fun! s:buffer_set_options() dict abort " {{{1
    setfiletype vfinder
    setlocal nonumber
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal modifiable
    setlocal cursorline
    setlocal nowrap
    setlocal foldcolumn=0
    setlocal textwidth=0
    setlocal omnifunc=
    setlocal complete=
    return self
endfun
" 1}}}

fun! s:buffer_set_syntax() dict abort " {{{1
    syntax clear
    syntax case ignore
    syntax match vfinderPrompt =\%1l.*=
    syntax match vfinderIndex =\%>1l^\d\+\s\+=
    if !empty(self.source.syntax_fun)
        call call(self.source.syntax_fun, [])
    endif
    return self
endfun
" 1}}}

fun! s:buffer_set_maps() dict abort " {{{1
    " Disable some default vim keys
    for k in ['<CR>', 'x', 'c', 'd', 'o', 'O', 'p', 'P', 'u', 'U', '<C-r>']
        silent execute 'nnoremap <silent> <buffer> ' . k . ' <Nop>'
    endfor
    let keys = vfinder#maps#get('_')
    let [i, n] = [keys.i, keys.n]
    " Prompt & movement
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_move_down . ' <Esc>:call <SID>move_down_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_move_up . ' <Esc>:call <SID>move_up_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_move_left . ' <Esc>:call <SID>move_left_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_move_right . ' <Esc>:call <SID>move_right_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_move_to_start . ' <Esc>:call <SID>move_to_edge_i(-1)<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_move_to_end . ' <Esc>:call <SID>move_to_edge_i(1)<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_backspace . ' <Esc>:call <SID>backspace_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_delete . ' <Esc>:call <SID>delete_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_delete_word . ' <Esc>:call <SID>control_w_i()<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.prompt_delete_line . ' <Esc>:call <SID>control_u_i()<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.new_query . ' <Esc>:call <SID>new_query()<CR>'
    " Modes
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.fuzzy_toggle . ' <Esc>:call <SID>toggle_fuzzy("i")<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.fuzzy_toggle . ' :call <SID>toggle_fuzzy("n")<CR>'
    " Insert mode
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.start_insert_mode_i . ' :call <SID>start_ins_mode_with_key("i")<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.start_insert_mode_a . ' :call <SID>start_ins_mode_with_key("a")<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.start_insert_mode_I . ' :call <SID>start_ins_mode_with_key("I")<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.start_insert_mode_A . ' :call <SID>start_ins_mode_with_key("A")<CR>'
    " Buffer
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.window_quit . ' :call <SID>wipe_buffer()<CR>'
    " Candidates & cache
    silent execute 'inoremap <nowait> <buffer> ' . i.candidates_update . ' <Esc>:call vfinder#events#update_candidates_request("i")<CR>'
    silent execute 'nnoremap <nowait> <buffer> ' . n.candidates_update . ' :call vfinder#events#update_candidates_request("n")<CR>'
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.cache_clean . ' <Esc>:call <SID>clean_cache_if_it_exists("i")<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.cache_clean . ' :call <SID>clean_cache_if_it_exists("n")<CR>'
    " Toggle source mappings in the statusline
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.toggle_maps_in_sl . ' <Esc>:call <SID>toggle_maps_in_sl(1)<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.toggle_maps_in_sl . ' :call <SID>toggle_maps_in_sl()<CR>'
    " Misc
    silent execute 'inoremap <silent> <nowait> <buffer> ' . i.send_to_qf . ' <Esc>:call <SID>send_to_quickfix(1)<CR>'
    silent execute 'nnoremap <silent> <nowait> <buffer> ' . n.send_to_qf . ' :call <SID>send_to_quickfix()<CR>'
    return self
endfun
" 1}}}

fun! s:buffer_set_autocmds() dict abort " {{{1
    augroup VFinder
        autocmd!
        autocmd TextChangedI <buffer> call vfinder#events#trigger_event_with_delay('query_modified')
        autocmd InsertCharPre <buffer> call vfinder#events#char_inserted()
        autocmd WinEnter <buffer> call vfinder#events#win_enter()
        autocmd WinLeave <buffer> call vfinder#events#win_leave()
    augroup END
endfun
" 1}}}

fun! s:buffer_set_statusline() dict abort " {{{1
    let &l:statusline = vfinder#statusline#get()
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"		    actions for maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:move_down_i() abort " {{{1
    let last_line = line('$')
    if line('.') is# last_line
        call cursor(1, 0)
    else
        silent execute 'normal! j'
    endif
    call s:set_cursor_position_i()
endfun
" 1}}}

fun! s:move_up_i() abort " {{{1
    if line('.') is# 1
        call cursor(line('$'), 0)
    else
        silent execute 'normal! k'
    endif
    call s:set_cursor_position_i()
endfun
" 1}}}

fun! s:move_left_i() abort " {{{1
    startinsert
    if s:already_near_the_prompt_char()
        return ''
    endif
endfun
" 1}}}

fun! s:move_right_i() abort " {{{1
    startinsert
    call cursor(1, col('.') + 2)
endfun
" 1}}}

fun! s:move_to_edge_i(direction) abort " {{{1
    if !vfinder#helpers#is_in_prompt()
        call cursor(1, 0)
    endif
    if a:direction ># 0
        startinsert!
    else
        startinsert
        call s:go_to_start_of_prompt()
    endif
endfun
" 1}}}

fun! s:backspace_i() abort " {{{1
    let b:vf.bopts.delete_map_used = 1
    if !vfinder#helpers#is_in_prompt()
        call s:move_to_edge_i(1)
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
" 1}}}

fun! s:delete_i() abort " {{{1
    let b:vf.bopts.delete_map_used = 1
    if !vfinder#helpers#is_in_prompt()
        call s:move_to_edge_i(1)
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
" 1}}}

fun! s:control_w_i() abort " {{{1
    let b:vf.bopts.delete_map_used = 1
    if !vfinder#helpers#is_in_prompt()
        call s:move_to_edge_i(1)
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
" 1}}}

fun! s:control_u_i() abort " {{{1
    let b:vf.bopts.delete_map_used = 1
    if !vfinder#helpers#is_in_prompt()
        call s:move_to_edge_i(1)
    endif
    let origin_col = col('.')
    if s:already_near_the_prompt_char()
        return ''
    endif
    let post_inp = s:get_pre_post_of_query(origin_col)[1]
    let prompt = vfinder#prompt#i()
    call prompt.render(post_inp)
    startinsert
    call s:go_to_start_of_prompt()
endfun
" 1}}}

fun! s:new_query() abort " {{{1
    " like the behavior of cc in normal mode
    let b:vf.bopts.delete_map_used = 1
    call s:move_to_edge_i(1)
    call s:control_u_i()
endfun
" 1}}}

fun! s:set_cursor_position_i() abort " {{{1
    if vfinder#helpers#is_in_prompt()
        startinsert!
    else
        silent execute 'normal! ^'
        startinsert
    endif
endfun
" 1}}}

fun! s:toggle_fuzzy(mode) abort " {{{1
    let b:vf.flags.fuzzy = !b:vf.flags.fuzzy
    silent call vfinder#events#update_candidates_request(a:mode)
endfun
" 1}}}

fun! s:start_ins_mode_with_key(key) abort " {{{1
    if a:key is# 'I'
        call s:go_to_start_of_prompt()
        startinsert
    elseif a:key is# 'A'
        call s:move_to_edge_i(1)
        startinsert!
    else
        if !vfinder#helpers#is_in_prompt()
            call vfinder#helpers#go_to_prompt_and_startinsert()
        else
            startinsert
            let new_col = a:key is# 'a'
                        \ ? col('.') + 1
                        \ : col('.')
            call cursor(1, new_col)
            call s:already_near_the_prompt_char()
        endif
    endif
endfun
" 1}}}

fun! s:wipe_buffer(...) abort " {{{1
    let buffer = exists('a:1') ? a:1 : bufname('%')
    if bufexists(buffer)
        " Be sure to go back to the initial window
        silent execute 'wincmd p'
        silent execute 'bwipeout! ' . buffer
    endif
endfun
" 1}}}

fun! s:clean_cache_if_it_exists(mode) abort " {{{1
    " The bufname is vf__foo_bar__
    let name = bufname('%')[4:-3]
    if vfinder#cache#exists(name)
        call vfinder#cache#clean(name)
        silent call vfinder#events#update_candidates_request(a:mode)
        silent execute a:mode is# 'i' ? 'startinsert!' : 'normal! 1gg$'
        call vfinder#helpers#echo('cache for "' . name . '" deleted')
    else
        call vfinder#helpers#echo('no cache for the source "' . name . '"', 'WarningMsg')
        if a:mode is# 'i'
            call s:set_cursor_position_i()
        endif
    endif
endfun
" 1}}}

fun! s:toggle_maps_in_sl(...) abort " {{{1
    let in_ins_mode = get(a:, 1, 0)
    let col = col('.')
    let [def_sl, global_maps_sl, source_maps_sl] = [
                \   b:vf.vopts.statusline,
                \   vfinder#helpers#get_maps_str_for('_'),
                \   vfinder#helpers#get_maps_str_for(b:vf.s.name)
                \ ]
    if &l:statusline is# def_sl
        let &l:statusline = source_maps_sl
    elseif &l:statusline is# source_maps_sl
        let &l:statusline = global_maps_sl
    else
        let &l:statusline = def_sl
    endif

    if in_ins_mode
        call vfinder#helpers#go_to_initial_col_i(col)
    endif
endfun
" 1}}}

fun! s:send_to_quickfix(...) abort " {{{1
    let in_ins_mode = get(a:, 1, 0)
    let [win_nr, col] = [winnr(), col('.')]
    let lines = getline(2, '$')
    if lines !=# []
        cgetexpr lines
        if getqflist() !=# []
            copen
            silent execute win_nr . 'wincmd w'
        endif
    endif
    if in_ins_mode
        call vfinder#helpers#go_to_initial_col_i(col)
    endif
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"		    	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:already_near_the_prompt_char() abort " {{{1
    if col('.') <# 3
        startinsert
        call s:go_to_start_of_prompt()
        return v:true
    else
        return v:false
    endif
endfun
" 1}}}

fun! s:get_pre_post_of_query(col) abort " {{{1
    " From a:col split query in pre & post part and return them.
    let query = getline('.')[2:]
    let pre_inp = query[: a:col - 3]
    let post_inp = strcharpart(query, len(pre_inp))
    return [pre_inp, post_inp]
endfun
" 1}}}

fun! s:go_to_start_of_prompt() abort " {{{1
    call cursor(1, 3)
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            global maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:buffer_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('_', {
                \   'i': {
                \       'cache_clean'         : '<F5>',
                \       'candidates_update'   : '<C-r>',
                \       'fuzzy_toggle'        : '<C-f>',
                \       'prompt_backspace'    : '<BS>',
                \       'prompt_delete'       : '<Del>',
                \       'prompt_delete_line'  : '<C-u>',
                \       'prompt_delete_word'  : '<C-w>',
                \       'prompt_move_down'    : '<C-n>',
                \       'prompt_move_left'    : '<C-h>',
                \       'prompt_move_right'   : '<C-l>',
                \       'prompt_move_to_end'  : '<C-e>',
                \       'prompt_move_to_start': '<C-a>',
                \       'prompt_move_up'      : '<C-p>',
                \       'send_to_qf'          : '<C-q>',
                \       'toggle_maps_in_sl'   : '<F1>',
                \   },
                \   'n': {
                \       'cache_clean'        : '<F5>',
                \       'candidates_update'  : 'R',
                \       'fuzzy_toggle'       : 'F',
                \       'new_query': 'cc',
                \       'send_to_qf'         : 'Q',
                \       'start_insert_mode_a': 'a',
                \       'start_insert_mode_A': 'A',
                \       'start_insert_mode_i': 'i',
                \       'start_insert_mode_I': 'I',
                \       'toggle_maps_in_sl'  : '<F1>',
                \       'window_quit'        : '<Esc>'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
