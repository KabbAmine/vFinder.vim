" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#go_to_prompt() abort
    call cursor(1, 0)
    startinsert!
endfun

fun! vfinder#update_candidates_i() abort
    call vfinder#events#update_candidates_request()
    startinsert!
endfun

fun! vfinder#update_candidates_and_stay() abort
    let pos = getpos('.')
    call vfinder#events#update_candidates_request()
    call setpos('.', pos)
    stopinsert
endfun

fun! vfinder#i(name) abort
    " if name is {} then its the options

    try
        let source = vfinder#source#get(a:name)

        let buffer = vfinder#buffer#i(source.name)
        call buffer.new()
        let b:vf = {}
        let b:vf.cmd = source.cmd

        let prompt = vfinder#prompt#i()
        call prompt.render()

        call vfinder#helpers#Echo('Candidates gathering...', 'Function')
        let candidates = vfinder#candidates#i(b:vf.cmd)
        call candidates.get().populate()
        let b:vf.original_candidates = candidates.original_list
        redraw!

        startinsert!
    catch /^\[vfinder\].*$/
        call vfinder#helpers#Echo(v:errmsg, 'Error')
    endtry
endfun
