" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#buffer#i(name) abort
    return {
                \   'name'           : a:name,
                \   'new'            : function('s:buffer_new'),
                \   'set_options'    : function('s:buffer_set_options'),
                \   'set_syntax'     : function('s:buffer_set_syntax'),
                \   'set_autocmds'   : function('s:buffer_set_autocmds'),
                \ }
endfun

fun! s:buffer_new() dict
    if bufexists(self.name)
        silent execute 'bwipeout! ' . self.name
    endif
    silent execute 'topleft split ' . self.name
    call self.set_syntax().set_options().set_autocmds()
    return self
endfun

fun! s:buffer_set_options() dict
    setlocal nonumber
    setlocal nobuflisted
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal modifiable
    setlocal cursorline
    setlocal nowrap
    return self
endfun

fun! s:buffer_set_syntax() dict
    syntax clear
    syntax case ignore
    syntax match vfinderPrompt =\%1l.*=
    highlight! link vfinderPrompt ModeMsg
    return self
endfun

fun! s:buffer_set_autocmds() dict
    augroup VFinder
        autocmd!
        autocmd TextChangedI <buffer> :call vfinder#events#query_modified()
    augroup END
endfun
