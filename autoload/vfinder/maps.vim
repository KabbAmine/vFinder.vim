" Creation         : 2018-03-25
" Last modification: 2018-03-26


fun! vfinder#maps#define() abort
    call s:define_gvar_maps('_', {
                \   'i': {
                \       'prompt_move_down'    : '<C-n>',
                \       'prompt_move_up'      : '<C-p>',
                \       'prompt_move_left'    : '<C-h>',
                \       'prompt_move_right'   : '<C-l>',
                \       'prompt_move_to_start': '<C-a>',
                \       'prompt_move_to_end'  : '<C-e>',
                \       'prompt_backspace'    : '<BS>',
                \       'prompt_delete'       : '<Del>',
                \       'prompt_delete_word'  : '<C-w>',
                \       'prompt_delete_line'  : '<C-u>',
                \       'window_quit'         : '<Esc>',
                \       'candidates_update'   : '<C-r>',
                \       'cache_clean'         : '<F5>'
                \   },
                \   'n': {
                \       'start_insert_mode_i': 'i',
                \       'start_insert_mode_I': 'I',
                \       'start_insert_mode_a': 'a',
                \       'start_insert_mode_A': 'A',
                \       'window_quit'        : '<Esc>',
                \       'candidates_update'  : 'R',
                \       'cache_clean'        : '<F5>'
                \
                \   }
                \ })
    call s:define_gvar_maps('buffers', {
                \   'i': {
                \       'edit'  : '<CR>',
                \       'split' : '<C-s>',
                \       'vsplit': '<C-v>',
                \       'tab'   : '<C-t>',
                \       'wipe'  : '<C-d>'
                \   },
                \   'n': {
                \       'edit'  : '<CR>',
                \       'split' : 's',
                \       'vsplit': 'v',
                \       'tab'   : 't',
                \       'wipe'  : 'dd'
                \   }
                \ })
    call s:define_gvar_maps('colors', {
                \   'i': {
                \       'apply'  : '<CR>',
                \       'preview': '<C-o>'
                \   },
                \   'n': {
                \       'apply'  : '<CR>',
                \       'preview': 'o'
                \   }
                \ })
    call s:define_gvar_maps('commands', {
                \   'i': {
                \       'apply': '<CR>',
                \       'echo' : '<C-o>'
                \   },
                \   'n': {
                \       'apply': '<CR>',
                \       'echo' : 'o'
                \   }
                \ })
    call s:define_gvar_maps('directories', {
                \   'i': {
                \       'goto'  : '<CR>',
                \       'goback': '<C-v>',
                \       'cd'    : '<C-s>'
                \   },
                \   'n': {
                \       'goto'  : '<CR>',
                \       'goback': 'v',
                \       'cd'    : 's'
                \   }
                \ })
    call s:define_gvar_maps('files', {
                \   'i': {
                \       'edit'  : '<CR>',
                \       'split' : '<C-s>',
                \       'vsplit': '<C-v>',
                \       'tab'   : '<C-t>'
                \   },
                \   'n': {
                \       'edit'  : '<CR>',
                \       'split' : 's',
                \       'vsplit': 'v',
                \       'tab'   : 't'
                \   }
                \ })
    call s:define_gvar_maps('outline', {
                \   'i': {
                \       'goto'         : '<CR>',
                \       'splitandgoto' : '<C-s>',
                \       'vsplitandgoto': '<C-v>'
                \   },
                \   'n': {
                \       'goto'         : '<CR>',
                \       'splitandgoto' : 's',
                \       'vsplitandgoto': 'v'
                \   }
                \ })
    call s:define_gvar_maps('spell', {
                \ 'i': {'use': '<CR>'},
                \ 'n': {'use': '<CR>'}
                \ })
    call s:define_gvar_maps('tags', {
                \   'i': {
                \       'goto'         : '<CR>',
                \       'splitandgoto' : '<C-s>',
                \       'vsplitandgoto': '<C-v>',
                \       'preview'      : '<C-o>'
                \   },
                \   'n': {
                \       'goto'         : '<CR>',
                \       'splitandgoto' : 's',
                \       'vsplitandgoto': 'v',
                \       'preview'      : 'o'
                \   }
                \ })
    call s:define_gvar_maps('yank', {
                \ 'i': {'paste': '<CR>'},
                \ 'n': {'paste': '<CR>'}
                \ })
endfun

fun! s:define_gvar_maps(name, def_maps) abort
    let g:vfinder_maps[a:name] = get(g:vfinder_maps, a:name, {})
    let g:vfinder_maps[a:name].i = get(g:vfinder_maps[a:name], 'i', {})
    let g:vfinder_maps[a:name].i = extend(copy(a:def_maps.i), g:vfinder_maps[a:name].i, 'force')
    let g:vfinder_maps[a:name].n = get(g:vfinder_maps[a:name], 'n', {})
    let g:vfinder_maps[a:name].n = extend(copy(a:def_maps.n), g:vfinder_maps[a:name].n, 'force')
endfun

fun! vfinder#maps#get(name) abort
    return g:vfinder_maps[a:name]
endfun
