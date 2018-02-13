" Creation         : 2018-02-04
" Last modification: 2018-02-13
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

" Options {{{1
let g:vfinder_verbose = get(g:, 'vfinder_verbose', 1)	" TODO: default to 0
let g:vfinder_cache_path = get(g:, 'vfinder_cache_path', $HOME . '/.cache/vfinder')
let g:vfinder_yank_source_enabled = get(g:, 'g:vfinder_yank_source_enabled', 1)
" 1}}}

if g:vfinder_yank_source_enabled
    augroup VFCaching
        autocmd!
        autocmd TextYankPost * :call vfinder#cache_yanked(v:event.regcontents)
    augroup END
endif

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
