" Creation         : 2018-02-04
" Last modification: 2018-02-10


fun! vfinder#source#i(name) abort
    let fun_name_prefix = 'vfinder#sources#' . a:name
    " There is no good way to check if an autoloaded function exist before
    " executing it.
    let fun_result = execute('echo ' . fun_name_prefix . '#check()', 'silent!')
    if empty(fun_result)
        call vfinder#helpers#Throw('No function "' . fun_name_prefix . '" found')
    endif
    let options = call(fun_name_prefix . '#get', [])

    return {
                \   'name'          : options.name,
                \   'to_execute'    : options.to_execute,
                \   'format_fun'    : get(options, 'format_fun', ''),
                \   'candidate_fun' : get(options, 'candidate_fun', function('getline', ['.'])),
                \   'maps'          : options.maps,
                \   'prepare'       : function('<SID>source_prepare'),
                \   'execute'       : function('<SID>source_execute'),
                \   'format'        : function('<SID>source_format'),
                \   'set_maps'      : function('<SID>source_set_maps'),
                \   'candidates'    : [],
                \ }
endfun

fun! s:source_prepare() dict
    " Execute the source, format & set the mappings
    call self.execute().format().set_maps()
    return self
endfun

fun! s:source_execute() dict
    let candidates = []
    if filereadable(self.to_execute)
        let candidates = readfile(self.to_execute)
    elseif type(self.to_execute) is# v:t_func
        let candidates = call(self.to_execute, [])
    elseif type(self.to_execute) is# v:t_list
        let candidates = self.to_execute
    elseif type(self.to_execute) is# v:t_string
        " TODO: add windows black hole in the helpers
        let candidates = systemlist(self.to_execute . ' 2> /dev/null',)
    endif
    if candidates is# []
        call vfinder#helpers#Throw('The source ' . string(self.to_execute) . ' is not valid')
        return ''
    endif
    let self.candidates = candidates
    return self
endfun

fun! s:source_format() dict
    if !empty(self.format_fun)
        let self.candidates = call(self.format_fun, [self.candidates])
    endif
    return self
endfun

fun! s:source_set_maps() dict
    for mode in ['i', 'n']
        let maps_{mode} = self.maps[mode]
        let keys_{mode} = keys(maps_{mode})
        let values_{mode} = values(maps_{mode})
        for i in range(0, len(maps_{mode}) - 1)
            let keys = keys_{mode}[i]
            let action = values_{mode}[i].action
            let options = values_{mode}[i].options
            let fun_args = printf('"%s", %s, "%s", %d',
                        \ action,
                        \ self.candidate_fun,
                        \ mode,
                        \ options.quit)
             silent execute mode . 'noremap <silent> <buffer> ' . keys . ' ' .
                         \ (mode is# 'i' ? '<Esc>' : '') .
                         \ ':call <SID>action(' . fun_args . ')<CR>'
        endfor
    endfor
    return self
endfun

fun! s:action(what, candidate_fun, mode, quit)
    let in_prompt = line('.') is# 1
    let buffer = bufnr('%')
    let what = !empty(a:what) ? a:what : '%s'
    if in_prompt
        silent normal! j
        let target = !empty(a:candidate_fun)
                    \ ? a:candidate_fun()
                    \ : ''
        silent normal! k
    else
        let target = !empty(a:candidate_fun)
                    \ ? a:candidate_fun()
                    \ : ''
    endif
    let cmd = printf(what, target)
    if a:quit
        silent execute 'bwipeout ' . buffer
    endif
    silent execute cmd
    if a:mode is# 'insert' && !a:quit
        startinsert
    endif
endfun

