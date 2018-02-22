" Creation         : 2018-02-04
" Last modification: 2018-02-22


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"			Caching
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:cache(name) abort
    if exists('g:vf_cache') && has_key(g:vf_cache, a:name) && !empty(g:vf_cache[a:name])
        call vfinder#cache#write(a:name, g:vf_cache[a:name])
    endif
endfun

" yank
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:save_yanked(content) abort
    " a:content is a string and can contain multiple lines.

    let yanked = exists('g:vf_cache') && has_key(g:vf_cache, 'yank') && !empty(g:vf_cache.yank)
                \ ? g:vf_cache.yank : vfinder#cache#read('yank')
    if len(a:content) ># 1 || (len(a:content) is# 1 && len(a:content[0]) ># 1)
        let yanked = [join(a:content, "\n")] + yanked
    endif
    let g:vf_cache.yank = s:filter_yank(yanked)
endfun

fun! s:filter_yank(a_list) abort
    let res = []
    for item in a:a_list
        if index(res, item) is# -1
            call add(res, item)
        endif
    endfor
    return res
endfun

" mru
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:save_mru() abort
    let buffer = fnamemodify(bufname('%'), ':p')
    if !empty(buffer)
        let buffers = exists('g:vf_cache') && has_key(g:vf_cache, 'mru') && !empty(g:vf_cache.mru)
                    \ ? g:vf_cache.mru : vfinder#cache#read('mru')
        let buffers = [buffer] + buffers
        let g:vf_cache.mru = s:filter_mru(buffers)
    endif
endfun

fun! s:filter_mru(files) abort
    let res = []
    for f in a:files
        if index(res, f) is# -1 && filereadable(f) && vfinder#sources#oldfiles#file_is_valid(f)
            call add(res, f)
        endif
    endfor
    return res
endfun

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"			Main
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#enable_autocmds_for_caching() abort
    let g:vf_cache = {}
    augroup VFCaching
        autocmd!
        if g:vfinder_yank_source_enabled
            let g:vf_cache.yank = []
            autocmd TextYankPost * :call <SID>save_yanked(v:event.regcontents)
            autocmd VimLeave * :call <SID>cache('yank')
        endif
        if g:vfinder_mru_source_enabled
            let g:vf_cache.mru = []
            autocmd BufReadPost,BufWritePost * :call <SID>save_mru()
            autocmd VimLeave * :call <SID>cache('mru')
        endif
    augroup END
endfun

fun! vfinder#i(source) abort
    " if name is {} then its a custom source.

    try
        let source = vfinder#source#i(a:source)
        if !source.is_valid
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

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"			Filtering
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
