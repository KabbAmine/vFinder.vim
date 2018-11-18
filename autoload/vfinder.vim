" Creation         : 2018-02-04
" Last modification: 2018-11-18


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"			main
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#i(source, ...) abort " {{{1
    " if name is {} then its a custom source.
    " a:1 is a {} which can contain vfinder options

    try
        let ctx = s:get_ctx_opts_from(get(a:, 1, {}))

        let source = vfinder#source#i(a:source, ctx.args)
        if !source.is_valid
            return ''
        endif

        " Some sources need an initial content to process (e.g tags_in_buffer
        " source) to be updated more than once, so we store the current
        " buffer number (same goes for the working directory).
        let [initial_bufnr, initial_wd] = [bufnr('%'), getcwd() . '/']

        let buffer = vfinder#buffer#i(source, ctx)
        call buffer.goto()
        let b:vf = extend(source, {
                    \   'initial_bufnr': initial_bufnr,
                    \   'initial_wd'   : initial_wd,
                    \   'fuzzy'        : ctx.fuzzy,
                    \   'flags'        : {},
                    \   'statusline'   : &l:statusline,
                    \   'last_pos'     : [],
                    \   'do_not_update': 0
                    \ })

        let prompt = vfinder#prompt#i()
        call prompt.render(ctx.query)

        call vfinder#helpers#echo('candidates gathering... (C-c to stop)', '', b:vf.name)
        let candidates = vfinder#candidates#i(b:vf)
        call candidates.get().populate()
        let b:vf.original_candidates = candidates.original_list

        redraw!
        startinsert!
    catch
        call vfinder#helpers#echomsg(v:exception, 'Error')
    endtry
endfun
" 1}}}

fun! vfinder#set_global_higroups() abort " {{{1
    highlight! link vfinderPrompt ModeMsg
    highlight! link vfinderIndex Comment
    highlight! link vfinderPreviewCursorLine IncSearch
    highlight! link vfinderMatched CursorLineNr
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"			caching
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#enable_autocmds_for_caching() abort " {{{1
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
" 1}}}

fun! s:cache(name) abort " {{{1
    if exists('g:vf_cache') && has_key(g:vf_cache, a:name) && !empty(g:vf_cache[a:name])
        call vfinder#cache#write(a:name, g:vf_cache[a:name])
    endif
endfun
" 1}}}

" yank
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:save_yanked(content) abort " {{{1
    " a:content is a string and can contain multiple lines.

    let yanked = exists('g:vf_cache') && has_key(g:vf_cache, 'yank') && !empty(g:vf_cache.yank)
                \ ? g:vf_cache.yank : vfinder#cache#read('yank')
    if len(a:content) ># 1 || (len(a:content) is# 1 && len(a:content[0]) ># 1)
        let yanked = [join(a:content, "\n")] + yanked
    endif
    let g:vf_cache.yank = s:filter_yank(yanked)
endfun
" 1}}}

fun! s:filter_yank(a_list) abort " {{{1
    let res = []
    for item in a:a_list
        if index(res, item) is# -1
            call add(res, item)
        endif
    endfor
    return res
endfun
" 1}}}

" mru
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:save_mru() abort " {{{1
    let buffer = fnamemodify(bufname('%'), ':p')
    if !empty(buffer)
        let buffers = exists('g:vf_cache') && has_key(g:vf_cache, 'mru') && !empty(g:vf_cache.mru)
                    \ ? g:vf_cache.mru : vfinder#cache#read('mru')
        let buffers = [buffer] + buffers
        let g:vf_cache.mru = s:filter_mru(buffers)
    endif
endfun
" 1}}}

fun! s:filter_mru(files) abort " {{{1
    let res = []
    for f in a:files
        if index(res, f) is# -1 && filereadable(f) && vfinder#sources#oldfiles#file_is_valid(f)
            call add(res, f)
        endif
    endfor
    return res
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:get_ctx_opts_from(opts) abort " {{{1
    " a:opts can have the following keys:
    " - fuzzy
    " - win_pos
    " - query
    " - args

    " Passed 'win_pos' have priority over the global g:vfinder_win_pos
    let win_pos = has_key(a:opts, 'win_pos')
                \ ? a:opts.win_pos
                \ : g:vfinder_win_pos
    return {
                \   'fuzzy'  : get(a:opts, 'fuzzy', g:vfinder_fuzzy),
                \   'query'  : get(a:opts, 'query', ''),
                \   'args'   : get(a:opts, 'args', ''),
                \   'win_pos': win_pos
                \ }
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
