" Creation         : 2018-02-04
" Last modification: 2018-02-05


fun! vfinder#source#get(name) abort
    let fun_name = 'vfinder#sources#' . a:name . '#get'
    " There is no good way to check if an autoloaded function exist before
    " executing it.
    let fun_result = execute('echo vfinder#sources#' . a:name . '#get()', 'silent!')
    if empty(fun_result)
        call vfinder#helpers#Throw('No function "' . fun_name . '" found')
    endif
    let options = call(fun_name, [])

    return {
                \   'name'   : a:name,
                \   'cmd'    : options.cmd . ' 2> /dev/null',
                \ }
endfun
