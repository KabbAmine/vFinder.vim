" Creation         : 2018-02-12
" Last modification: 2018-02-15


" The cache is used only for the sources:
" * yank

fun! vfinder#cache#read(name) abort
    return readfile(vfinder#cache#get(a:name))
endfun

fun! vfinder#cache#exists(name) abort
    return filereadable(vfinder#cache#get() . '/' . a:name)
endfun

fun! vfinder#cache#write(name, content) abort
    let cache_file = vfinder#cache#get(a:name)
    call writefile(a:content, cache_file)
endfun

fun! vfinder#cache#clean(...) abort
    " Clean all cache files and temp cache variables if a:1 does not exit,
    " otherwise clean only a:1.

    if exists('a:1')
        let files = [vfinder#cache#get(a:1)]
        if exists('g:vf_cache.' . a:1)
            let g:vf_cache[a:1] = []
        endif
    else
        let files = glob(vfinder#cache#get() . '/*', '', 1)
        if exists('g:vf_cache')
            for k in keys(g:vf_cache)
                let k = []
            endfor
        endif
    endif
    for f in files
        call writefile([], f)
    endfor
endfun

fun! vfinder#cache#get(...) abort
    " Create, and return the cache dir if a:1 does not exist, otherwise create
    " and return the cache file a:1.
    let cache_dir = s:cache_create_dir()
    if exists('a:1')
        let cache_file = s:cache_create_file(a:1, cache_dir)
        return cache_file
    else
        return cache_dir
    endif
endfun

fun! s:cache_create_dir() abort
    let cache_dir = g:vfinder_cache_path
    if !isdirectory(cache_dir)
        call mkdir(cache_dir)
    endif
    return cache_dir
endfun

fun! s:cache_create_file(name, parent) abort
    let cache_file = a:parent . '/' . a:name
    if !filereadable(cache_file)
        call writefile([], cache_file)
    endif
    return cache_file
endfun