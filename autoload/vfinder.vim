" Creation         : 2018-02-04
" Last modification: 2018-02-15


fun! vfinder#enable_autocmds() abort
    let g:vf_cache = {}
    augroup VFCaching
        autocmd!
        if g:vfinder_yank_source_enabled
            let g:vf_cache.yank = []
            autocmd TextYankPost * :call <SID>save_yanked(v:event.regcontents)
            autocmd VimLeave * :call <SID>cache_yanked()
        endif
    augroup END
endfun

fun! s:save_yanked(content) abort
    " a:content is a string and can have multiple lines.

    let yanked = exists('g:vf_cache') && has_key(g:vf_cache, 'yank')
                \ ? g:vf_cache.yank : []
    if len(a:content) ># 1 || (len(a:content) is# 1 && len(a:content[0]) ># 1)
        let yanked = [join(a:content, "\n")] + yanked
    endif
    let g:vf_cache.yank = vfinder#helpers#uniq(yanked)
endfun

fun! s:cache_yanked() abort
    if exists('g:vf_cache') && has_key(g:vf_cache, 'yank') && !empty(g:vf_cache.yank)
        call vfinder#cache#write('yank', g:vf_cache.yank)
    endif
endfun

fun! vfinder#i(source) abort
    " if name is {} then its a custom source.

    try
        let source = vfinder#source#i(a:source)
        if !source.is_valid
            call vfinder#helpers#echo('The source is not valid', 'Error')
            return ''
        endif

        let buffer = vfinder#buffer#i(source.name)
        call buffer.new()
        let b:vf = source

        let prompt = vfinder#prompt#i()
        call prompt.render()

        call vfinder#helpers#echo('Candidates gathering...', 'Function')
        let candidates = vfinder#candidates#i(b:vf)
        call candidates.get().populate()
        let b:vf.original_candidates = candidates.original_list
        redraw!

        startinsert!
    catch /^\[vfinder\].*$/
        call vfinder#helpers#echo(v:errmsg, 'Error')
    endtry
endfun

" Filtering functions
" """"""""""""""""""""

if has('python3')

python3 << EOF
# TODO: No smartcase :/

from vim import eval
from re import search,IGNORECASE

def filter(query, candidates):
    suggestions = []
    pattern = r'' + query
    for candidate in candidates:
        s = search(pattern, candidate, IGNORECASE)
        if s:
            suggestions.append(s.string)
    return suggestions
EOF

endif
