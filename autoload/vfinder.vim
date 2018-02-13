" Creation         : 2018-02-04
" Last modification: 2018-02-13

" TODO:
" sources: mru,...
" replace a vf window if it already exist (or maybe not?)
" do not open tags when no tagfiles
" capitals is some functions
" multiple selections
" delay filtering when we have a lot of candidates and typing fast.
" improve the python3 function
" escape special characters in the query (may be different for python)
" user options:
"	* files find command
"	* ctags executable & options depending of options
"	* empty candidates

fun! vfinder#cache_yanked(content) abort
    " a:content is a string and can have multiple lines.
    if len(a:content) ># 1 || (len(a:content) is# 1 && len(a:content[0]) ># 1)
        call vfinder#cache#write('yank', [join(a:content, "\n")])
    endif
endfun

fun! vfinder#i(source) abort
    " if name is {} then its a custom source.

    try
        let source = vfinder#source#i(a:source)
        if !source.is_valid
            call vfinder#helpers#echo('The source is not valid', 'Error')
            return ''
        endif

        let buffer = vfinder#buffer#i(source.name)
        call buffer.new()
        let b:vf = source

        let prompt = vfinder#prompt#i()
        call prompt.render()

        call vfinder#helpers#echo('Candidates gathering...', 'Function')
        let candidates = vfinder#candidates#i(b:vf)
        call candidates.get().populate()
        let b:vf.original_candidates = candidates.original_list
        redraw!

        startinsert!
    catch /^\[vfinder\].*$/
        call vfinder#helpers#echo(v:errmsg, 'Error')
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
