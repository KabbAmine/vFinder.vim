" Creation         : 2018-02-04
" Last modification: 2018-02-05


fun! vfinder#source#i(name) abort
    let fun_name_prefix = 'vfinder#sources#' . a:name
    " There is no good way to check if an autoloaded function exist before
    " executing it.
    let fun_result = execute('echo ' . fun_name_prefix . '#check()', 'silent!')
    if empty(fun_result)
        call vfinder#helpers#Throw('No function "' . fun_name . '" found')
    endif
    let options = call(fun_name_prefix . '#get', [])

    return {
                \   'name'          : options.name,
                \   'to_execute'    : options.to_execute,
                \   'format_fun'    : get(options, 'format_fun', ''),
                \   'candidate_fun' : get(options, 'candidate_fun', 'getline(".")'),
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
    call self.execute().format()
    " TODO:
    call self.set_maps()
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
    return self
endfun
