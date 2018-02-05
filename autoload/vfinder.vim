" Creation         : 2018-02-04
" Last modification: 2018-02-04


fun! vfinder#i(name) abort
    " if name is {} then its the options

    try
        let source = vfinder#source#get(a:name)

        let buffer = vfinder#buffer#i(source.name)
        call buffer.new()
        let b:vf = {}
        let b:vf.cmd = source.cmd
        " let b:vf.maps

        let prompt = vfinder#prompt#i()
        call prompt.render()

        call vfinder#helpers#Echo('Candidates gathering...', 'Function')
        let candidates = vfinder#candidates#i(b:vf.cmd)
        call candidates.get().populate()
        redraw!

        startinsert!
    catch /^\[vfinder\].*$/
        call vfinder#helpers#Echo(v:errmsg, 'Error')
    endtry
endfun
