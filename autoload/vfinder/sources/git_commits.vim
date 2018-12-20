" Creation         : 2018-12-10
" Last modification: 2018-12-20


" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	            main object
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! vfinder#sources#git_commits#get(...) abort " {{{1
    call s:git_commits_define_maps()
    return {
                \   'name'         : 'git_commits',
                \   'is_valid'     : s:git_commits_is_valid(),
                \   'to_execute'   : s:git_commits_source(),
                \   'candidate_fun': function('s:git_commits_candidate_fun'),
                \   'syntax_fun'   : function('s:git_commits_syntax_fun'),
                \   'maps'         : s:git_commits_maps()
                \ }
endfun
" 1}}}

fun! s:git_commits_source() abort " {{{1
    let format = '%h %cd %d %s'
    return printf('git log --decorate --color=never --pretty=format:"%s" --date=short --abbrev-commit',
                \       format
                \ )
endfun
" 1}}}

fun! s:git_commits_candidate_fun() abort " {{{1
    return vfinder#global#candidate_fun_get_first_non_whitespace()
endfun
" 1}}}

fun! s:git_commits_syntax_fun() abort " {{{1
    syntax match vfinderGitCommitsSha =\%>1l^\S\+=
    syntax match vfinderGitCommitsDate =\%>1l\s\+[0-9-]\{10}=
    syntax match vfinderGitCommitsRefs =\%>1l\s\{2}(.\{-})\s\+=
    highlight default link vfinderGitCommitsSha vfinderSymbols
    highlight default link vfinderGitCommitsDate vfinderIndex
    highlight default link vfinderGitCommitsRefs vfinderExtra
endfun
" 1}}}

fun! s:git_commits_maps() abort " {{{1
    let keys = vfinder#maps#get('git_commits')
    let use_sha_action = {
                \   'action': function('s:git_sha'),
                \   'options': {'function': 1}
                \   }
    let diff_action = {
                \   'action': function('s:diff'),
                \   'options': {'function': 1, 'quit': 0}
                \ }
    let diff_stat_action = {
                \   'action': function('s:diff_stat'),
                \   'options': {'function': 1, 'quit': 0}
                \ }
    return {
                \   'i': {
                \       keys.i.git_sha: use_sha_action,
                \       keys.i.diff: diff_action,
                \       keys.i.diff_stat: diff_stat_action
                \   },
                \   'n': {
                \       keys.n.git_sha: use_sha_action,
                \       keys.n.diff: diff_action,
                \       keys.n.diff_stat: diff_stat_action
                \   }
                \ }
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	actions
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:git_sha(sha) abort " {{{1
    call feedkeys(
                \   (s:fugitive_installed() ? ":Git" : ":!git") . "   "
                \   . a:sha
                \   . "\<C-left>\<left>\<left>"
                \ )
endfun
" 1}}}

fun! s:diff(hash) abort " {{{1
    call vfinder#helpers#autoclose_pwindow_autocmd()
    if s:fugitive_installed()
        let git_dir = FugitiveExtractGitDir(getcwd())
        if !empty(git_dir)
            silent execute 'pclose'
            execute vfinder#helpers#pedit_cmd(FugitiveFind(a:hash, git_dir))
        endif
    endif
endfun
" 1}}}

fun! s:diff_stat(hash) abort " {{{1
    call vfinder#helpers#autoclose_pwindow_autocmd()
    let win_nr = winnr()
    let b:vf.bopts.update_on_win_enter = 0
    let buf_name = 'vf__git_diff_stat__'
    silent execute 'pclose'
    execute vfinder#helpers#pedit_cmd(buf_name)
    silent execute 'wincmd P'
    call s:set_and_populate_diff_stat_prev_buf(a:hash)
    call s:set_syntax_diff_stat_prev_buf()
    call s:stop_insertmode_on_winenter_augroup()
    silent execute win_nr . 'wincmd w'
    let b:vf.bopts.update_on_win_enter = 1
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	helpers
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:git_commits_is_valid() abort " {{{1
    if !executable('git')
        unsilent call vfinder#helpers#echo('"git" was not found', 'Error')
        return v:false
    endif
    if !vfinder#helpers#in_git_project()
        unsilent call vfinder#helpers#echo('not a git project', 'Error')
        return v:false
    endif
    return v:true
endfun
" 1}}}

fun! s:fugitive_installed() abort " {{{1
    if !exists('*FugitiveExtractGitDir')
        unsilent call vfinder#helpers#echo('this action needs vim-fugitive plugin to proceed', 'Error')
        return v:false
    else
        return v:true
    endif
endfun
" 1}}}

fun! s:stop_insertmode_on_winenter_augroup() abort " {{{1
    augroup VFGitCommitsDiffStatStopInsert
        autocmd!
        autocmd InsertEnter <buffer> stopinsert
    augroup END
endfun
" 1}}}

fun! s:set_and_populate_diff_stat_prev_buf(hash) abort " {{{1
    let buf_nr = bufnr('%')
    setlocal bufhidden=wipe buftype=nofile noswapfile nowrap
    setlocal modifiable
    call deletebufline(buf_nr, 1, '$')
    call setbufline(buf_nr, 1, systemlist(printf(
                \   'git diff --stat %s^!', a:hash
                \ )))
    setlocal nomodifiable
endfun
" 1}}}

fun! s:set_syntax_diff_stat_prev_buf() abort " {{{1
    let ll = line('$')
    syntax clear
    " thanks to https://github.com/cohama/agit.vim for the patterns of +/-
    execute 'syntax match vfinderGitCommitsDiffStatLl =\%' . ll . 'l.*='
    execute 'syntax match vfinderGitCommitsDiffStatPlus =\%<' . ll . 'l\%(\d\+\ \)\zs+\+='
    execute 'syntax match vfinderGitCommitsDiffStatMinus =\%<' . ll . 'l-\+$='
    highlight default link vfinderGitCommitsDiffStatLl Identifier
    highlight default link vfinderGitCommitsDiffStatPlus DiffAdd
    highlight default link vfinderGitCommitsDiffStatMinus DiffDelete
endfun
" 1}}}

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 	        	maps
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:git_commits_define_maps() abort " {{{1
    call vfinder#maps#define_gvar_maps('git_commits', {
                \   'i': {
                \       'diff'     : '<CR>',
                \       'git_sha'  : '<C-s>',
                \       'diff_stat': '<C-o>'
                \   },
                \   'n': {
                \       'diff'     : '<CR>',
                \       'git_sha'  : 's',
                \       'diff_stat': 'o'
                \   }
                \ })
endfun
" 1}}}


" vim:ft=vim:fdm=marker:fmr={{{,}}}:
