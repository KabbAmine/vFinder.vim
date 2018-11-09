" Creation         : 2018-03-25
" Last modification: 2018-11-10


fun! vfinder#maps#define() abort " {{{1
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
                \       'fuzzy_toggle'        : '<C-f>',
                \       'window_quit'         : '<Esc>',
                \       'candidates_update'   : '<C-r>',
                \       'cache_clean'         : '<F5>',
                \       'toggle_maps_in_sl'   : '<F1>'
                \   },
                \   'n': {
                \       'fuzzy_toggle'       : 'F',
                \       'start_insert_mode_i': 'i',
                \       'start_insert_mode_I': 'I',
                \       'start_insert_mode_a': 'a',
                \       'start_insert_mode_A': 'A',
                \       'window_quit'        : '<Esc>',
                \       'candidates_update'  : 'R',
                \       'cache_clean'        : '<F5>',
                \       'toggle_maps_in_sl'  : '<F1>'
                \   }
                \ })
    call s:define_gvar_maps('buffers', {
                \   'i': {
                \       'edit'          : '<CR>',
                \       'split'         : '<C-s>',
                \       'vsplit'        : '<C-v>',
                \       'tab'           : '<C-t>',
                \       'wipe'          : '<C-d>',
                \       'toggle_all': '<C-o>'
                \   },
                \   'n': {
                \       'edit'          : '<CR>',
                \       'split'         : 's',
                \       'vsplit'        : 'v',
                \       'tab'           : 't',
                \       'wipe'          : 'dd',
                \       'toggle_all': 'o'
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
                \       'edit'             : '<CR>',
                \       'split'            : '<C-s>',
                \       'vsplit'           : '<C-v>',
                \       'tab'              : '<C-t>',
                \       'toggle_git_flags' : '<C-g>'
                \   },
                \   'n': {
                \       'edit'             : '<CR>',
                \       'split'            : 's',
                \       'vsplit'           : 'v',
                \       'tab'              : 't',
                \       'toggle_git_flags' : 'gi'
                \   }
                \ })
    call s:define_gvar_maps('marks', {
                \ 'i': {
                \       'goto'  : '<CR>',
                \       'delete': '<C-d>'
                \   },
                \ 'n': {
                \       'goto'  : '<CR>',
                \       'delete': 'dd'
                \   }
                \ })
    call s:define_gvar_maps('tags_in_buffer', {
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
                \       'tabandgoto'   : '<C-t>',
                \       'preview'      : '<C-o>'
                \   },
                \   'n': {
                \       'goto'         : '<CR>',
                \       'splitandgoto' : 's',
                \       'vsplitandgoto': 'v',
                \       'tabandgoto'   : 't',
                \       'preview'      : 'o'
                \   }
                \ })
    call s:define_gvar_maps('yank', {
                \ 'i': {'paste': '<CR>'},
                \ 'n': {'paste': '<CR>'}
                \ })
    call s:define_gvar_maps('mru', vfinder#maps#get('files'))
    call s:define_gvar_maps('oldfiles', vfinder#maps#get('mru'))
    call s:define_gvar_maps('registers', vfinder#maps#get('yank'))
    call s:define_gvar_maps('command_history', vfinder#maps#get('commands'))
endfun
" 1}}}

fun! vfinder#maps#get(name) abort " {{{1
    return g:vfinder_maps[a:name]
endfun
" 1}}}

fun! s:define_gvar_maps(name, def_maps) abort " {{{1
    let g:vfinder_maps[a:name] = get(g:vfinder_maps, a:name, {})
    let g:vfinder_maps[a:name].i = get(g:vfinder_maps[a:name], 'i', {})
    let g:vfinder_maps[a:name].i = extend(copy(a:def_maps.i), g:vfinder_maps[a:name].i, 'force')
    let g:vfinder_maps[a:name].n = get(g:vfinder_maps[a:name], 'n', {})
    let g:vfinder_maps[a:name].n = extend(copy(a:def_maps.n), g:vfinder_maps[a:name].n, 'force')
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
