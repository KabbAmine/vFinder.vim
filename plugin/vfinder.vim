" Creation         : 2018-02-04
" Last modification: 2018-11-17
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
let g:vfinder_fuzzy = get(g:, 'vfinder_fuzzy', 0)
let g:vfinder_win_pos = get(g:, 'vfinder_win_pos', 'topleft')
let g:vfinder_flash = get(g:, 'vfinder_flash', 1)
let g:vfinder_cache_path = get(g:, 'vfinder_cache_path', $HOME . '/.cache/vfinder')
let g:vfinder_yank_source_enabled = get(g:, 'vfinder_yank_source_enabled', 1)
let g:vfinder_mru_source_enabled = get(g:, 'vfinder_mru_source_enabled', 1)
let g:vfinder_maps = get(g:, 'vfinder_maps', {})
" 1}}}

" Initialization {{{1
call vfinder#enable_autocmds_for_caching()
call vfinder#set_global_higroups()
" 1}}}

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
