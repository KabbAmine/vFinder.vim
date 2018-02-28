" Creation         : 2018-02-04
" Last modification: 2018-02-28


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
            call vfinder#helpers#throw('No source "' . a:source . '" found')
            return ''
        endif
        let options = call(fun_name_prefix . '#get', [])
    elseif type(a:source) is# v:t_dict
        let options = a:source
    else
        call vfinder#helpers#throw('The source ' . string(a:source) . ' is not valid')
        return ''
    endif

    return {
                \   'name'          : options.name,
                \   'is_valid'      : get(options, 'is_valid', 1),
                \   'to_execute'    : options.to_execute,
                \   'format_fun'    : get(options, 'format_fun', ''),
                \   'candidate_fun' : get(options, 'candidate_fun', function('getline', ['.'])),
                \   'syntax_fun'    : get(options, 'syntax_fun', ''),
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
        " We delay the file reading a little to be sure that the writing
        " process is done.
        sleep 150m
        let candidates = readfile(self.to_execute)
    elseif type(self.to_execute) is# v:t_func
        let candidates = call(self.to_execute, [])
    elseif type(self.to_execute) is# v:t_list
        let candidates = self.to_execute
    elseif type(self.to_execute) is# v:t_string
        let candidates = systemlist(self.to_execute . ' ' . vfinder#helpers#black_hole())
    endif
    if candidates is# []
        call vfinder#helpers#throw('The source ' . string(self.to_execute) . ' is not valid')
        return ''
    endif
    let self.candidates = candidates
    return self
endfun

fun! s:source_format() dict
    if !empty(self.format_fun) && !empty(self.candidates)
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
            let options = s:set_all_options(values_{mode}[i].options)
            let fun_args = printf('"%s", %s, "%s", %s',
                        \ values_{mode}[i].action,
                        \ candidate_fun,
                        \ mode,
                        \ options)
             silent execute mode . 'noremap <silent> <buffer> ' .
                         \ keys_{mode}[i] . ' ' .
                         \ (mode is# 'i' ? '<Esc>' : '') .
                         \ ':call <SID>do(' . fun_args . ')<CR>'
        endfor
    endfor
    return self
endfun

fun! s:do(action, candidate_fun, mode, options)
    let line = line('.')
    let buffer = bufnr('%')
    let in_prompt = vfinder#helpers#is_in_prompt()
    let no_candidates = line('$') is# 1
    let action = !empty(a:action) ? a:action : '%s'

    if in_prompt
        if no_candidates
            call s:set_mode(line, a:mode)
            return ''
        endif
        silent normal! j
        let target = a:candidate_fun()
        silent normal! k
    else
        let target = a:candidate_fun()
    endif

    if a:options.quit
        silent execute 'wincmd p'
        silent execute 'bwipeout ' . buffer
    endif

    " A capital C in case we have a funcref
    if a:options.function
        let Cmd = function(action, [target])
    else
        let Cmd = action =~ '%s' ? printf(action, target) : action
    endif

    let silent = a:options.silent ? 'silent' : ''
    if a:options.function
        execute silent . ' call Cmd()'
    elseif a:options.echo
        execute silent . ' call feedkeys(":" . Cmd)'
    else
        execute silent ' execute Cmd'
    endif

    if !a:options.silent && !a:options.echo
        let to_add = a:options.function ? string(Cmd) : Cmd
        call histadd('cmd', to_add)
    endif

    if !a:options.quit
        if a:options.clear_prompt
            let prompt = vfinder#prompt#i()
            call prompt.render('')
            call clearmatches()
        endif
        if a:options.update
            call vfinder#events#update_candidates_request()
        endif
        call s:set_mode(line, a:mode)
    endif
endfun

fun! s:set_all_options(options) abort
    let opts = copy(a:options)
    let opts.quit = get(opts, 'quit', 1)
    let opts.update = get(opts, 'update', 0)
    let opts.silent = get(opts, 'silent', 1)
    let opts.function = get(opts, 'function', '')
    let opts.echo = get(opts, 'echo', 0)
    let opts.clear_prompt = get(opts, 'clear_prompt', 0)
    return opts
endfun

fun! s:set_mode(line, mode) abort
    if a:mode is# 'i'
        call cursor(a:line, 0)
        silent execute line('.') is# 1 ? 'startinsert!' : 'startinsert'
    endif
endfun
