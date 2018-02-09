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

" Filtering functions
" """"""""""""""""""""

if has('python3')

python3 << EOF
# TODO: No smartcase :/

from vim import eval
from re import search,IGNORECASE

def filter(query, candidates):
    suggestions = []
    pattern = r'' + query
    for candidate in candidates:
        s = search(pattern, candidate, IGNORECASE)
        if s:
            suggestions.append(s.string)
    return suggestions
EOF

endif
