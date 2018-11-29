" Creation         : 2018-02-04
" Last modification: 2018-11-29


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
"			main
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#i(source, ...) abort " {{{1
    " if name is {} then its a custom source.
    " a:1 is a {} which can contain vfinder options

    try
        let opts = get(a:, 1, {})

        let source = vfinder#source#i(a:source, get(opts, 'args', ''))
        if !source.is_valid
            return ''
        endif

        let [ctx, sopts, flags] = [
                    \  s:get_ctx(),
                    \  s:get_sopts(opts),
                    \  s:get_global_flags(opts)
                    \ ]

        call vfinder#buffer#i(source, sopts).goto()
        let b:vf = {
                    \   's'         : source,
                    \   'ctx'       : ctx,
                    \   'flags'     : flags,
                    \   'vopts'     : s:get_vopts(),
                    \   'bopts'     : s:get_bopts(),
                    \   'candidates': s:prepare_candidates_vars()
                    \ }

        call vfinder#prompt#i().render(sopts.query)
        call vfinder#helpers#echo('candidates gathering... (C-c to stop)', '', b:vf.s.name)
        let candidates = vfinder#candidates#i(b:vf.s)
        call candidates.get().populate()
        let b:vf.candidates.initial = candidates.initial

        redraw!
        call vfinder#helpers#go_to_prompt_and_startinsert()
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
        if index(res, f) is# -1 && filereadable(f) && vfinder#global#file_is_valid(f)
            call add(res, f)
        endif
    endfor
    return res
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:get_ctx() abort " {{{1
    " Some sources need an initial content to proceed (e.g tags_in_buffer) like
    " updating more than once, so we store some informations about the current
    " context
    " last_pos: [line, col]

    return {
                \   'bufnr'   : bufnr('%'),
                \   'wd'      : getcwd() . '/',
                \   'last_pos': []
                \ }
endfun
" 1}}}

fun! s:get_sopts(opts) abort " {{{1
    " Source extra options

    " Passed 'win_pos' have priority over the global g:vfinder_win_pos
    let win_pos = has_key(a:opts, 'win_pos')
                \ ? a:opts.win_pos
                \ : g:vfinder_win_pos
    return {
                \   'query'  : get(a:opts, 'query', ''),
                \   'win_pos': win_pos
                \ }
endfun
" 1}}}

fun! s:get_global_flags(opts) abort " {{{1
    " Toggleable elements

    return {
                \   'fuzzy': get(a:opts, 'fuzzy', g:vfinder_fuzzy)
                \ }
endfun
" 1}}}

fun! s:get_vopts() abort " {{{1
    " Vim options

    return {
                \   'statusline': &statusline
                \ }
endfun
" 1}}}

fun! s:prepare_candidates_vars() abort " {{{1
    return {
                \   'initial': [],
                \ }
endfun
" 1}}}

fun! s:get_bopts() abort " {{{1
    " Buf-local options

    return {
                \   'last_query'         : '',
                \   'first_execution'    : 1,
                \   'update_on_win_enter': 1,
                \ }
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
