" Creation         : 2018-02-04
" Last modification: 2018-03-25
" Maintainer       : Kabbaj Amine <amine.kabb@gmail.com>
" License          : MIT


" Vim options {{{1
if exists('g:vfinder_loaded')
    finish
endif
let g:vfinder_loaded = 1

" To avoid conflict problems.
let s:saveCpoptions = &cpoptions
set cpoptions&vim
" 1}}}

" Global options {{{1
let g:vfinder_verbose = get(g:, 'vfinder_verbose', 1)	" TODO: default to 0
let g:vfinder_fuzzy = get(g:, 'vfinder_fuzzy', 0)
let g:vfinder_cache_path = get(g:, 'vfinder_cache_path', $HOME . '/.cache/vfinder')
let g:vfinder_yank_source_enabled = get(g:, 'vfinder_yank_source_enabled', 1)
let g:vfinder_mru_source_enabled = get(g:, 'vfinder_mru_source_enabled', 1)
let g:vfinder_maps = get(g:, 'vfinder_maps', {})
" 1}}}

" Mappings {{{1
call vfinder#maps#create('buffers', {
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
call vfinder#maps#create('colors', {
            \   'i': {
            \       'apply'  : '<CR>',
            \       'preview': '<C-o>'
            \   },
            \   'n': {
            \       'apply'  : '<CR>',
            \       'preview': 'o'
            \   }
            \ })
call vfinder#maps#create('commands', {
            \   'i': {
            \       'apply': '<CR>',
            \       'echo' : '<C-o>'
            \   },
            \   'n': {
            \       'apply': '<CR>',
            \       'echo' : 'o'
            \   }
            \ })
call vfinder#maps#create('directories', {
            \   'i': {
            \       'cd'    : '<CR>',
            \       'goto'  : '<C-s>',
            \       'goback': '<C-v>'
            \   },
            \   'n': {
            \       'cd'    : '<CR>',
            \       'goto'  : 's',
            \       'goback': 'v'
            \   }
            \ })
call vfinder#maps#create('files', {
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
call vfinder#maps#create('outline', {
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
call vfinder#maps#create('spell', {
            \ 'i': {'use': '<CR>'},
            \ 'n': {'use': '<CR>'}
            \ })
call vfinder#maps#create('tags', {
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
call vfinder#maps#create('yank', {
            \ 'i': {'paste': '<CR>'},
            \ 'n': {'paste': '<CR>'}
            \ })
" 1}}}

" Initialize caching {{{1
call vfinder#enable_autocmds_for_caching()
" 1}}}

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
