" Creation         : 2018-02-04
" Last modification: 2018-02-11
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

nnoremap <silent> ,,f :call vfinder#i('files')<CR>
nnoremap <silent> ,,b :call vfinder#i('buffers')<CR>
nnoremap <silent> ,,r :call vfinder#i('oldfiles')<CR>

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
