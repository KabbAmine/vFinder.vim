" Creation         : 2018-02-04
" Last modification: 2018-02-10


fun! vfinder#source#i(source) abort
    " if a:source is a:
    "     - string: Its the name of a source/name.vim file
    "     - dictionnary: Its a custom source

    if type(a:source) is# v:t_string
        let fun_name_prefix = 'vfinder#sources#' . a:source
        " There is no good way to check if an autoloaded function exist before
        " executing it, at least AFAIK.
        let fun_result = execute('echo ' . fun_name_prefix . '#check()', 'silent!')
        if empty(fun_result)
            call vfinder#helpers#Throw('No function "' . fun_name_prefix . '" found')
            return ''
        endif
        let options = call(fun_name_prefix . '#get', [])
    elseif type(a:source) is# v:t_dict
        let options = a:source
    else
        call vfinder#helpers#Throw('The source ' . string(self.to_execute) . ' is not valid')
        return ''
    endif

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
    call self.execute().format().set_maps()
    return self
endfun

fun! s:source_execute() dict
    let candidates = []
    if type(self.to_execute) is# v:t_string && filereadable(self.to_execute)
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
        " candidate_fun being a funcref if defined, we must convert it to a
        " string before passing it to the execute command.
        let candidate_fun = string(self.candidate_fun)
        for i in range(0, len(maps_{mode}) - 1)
            let fun_args = printf('"%s", %s, "%s", %s',
                        \ values_{mode}[i].action,
                        \ candidate_fun,
                        \ mode,
                        \ values_{mode}[i].options)
             silent execute mode . 'noremap <silent> <buffer> ' .
                         \ keys_{mode}[i] . ' ' .
                         \ (mode is# 'i' ? '<Esc>' : '') .
                         \ ':call <SID>do(' . fun_args . ')<CR>'
        endfor
    endfor
    return self
endfun

fun! s:do(action, candidate_fun, mode, options)
    let in_prompt = vfinder#helpers#is_in_prompt()
    let line = line('.')
    let quit = vfinder#helpers#have(a:options, 'quit')
    let update = vfinder#helpers#have(a:options, 'update')
    let buffer = bufnr('%')
    let action = !empty(a:action) ? a:action : '%s'
    if in_prompt
        silent normal! j
        let target = !empty(a:candidate_fun) ? a:candidate_fun() : ''
        silent normal! k
    else
        let target = !empty(a:candidate_fun) ? a:candidate_fun() : ''
    endif
    let cmd = printf(action, target)
    if quit
        silent execute 'bwipeout ' . buffer
    endif
    silent execute cmd
    if !quit
        if update
            call vfinder#events#update_candidates_request()
        endif
        if a:mode is# 'i'
            call cursor(line, 0)
            silent execute line('.') is# 1 ? 'startinsert!' : 'startinsert'
        endif
    endif
endfun
