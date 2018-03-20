# vFinder [EXPERIMENTAL]

![Badge version](https://img.shields.io/badge/version-0.0.1-blue.svg?style=flat-square "Badge for version")
![License version](https://img.shields.io/badge/license-mit-blue.svg?style=flat-square "Badge for license")

A Unite-like non async finder for vim.

![Demo of vFinder](.img/vfinder_demo.gif "Demo of vFinder")

**N.B:** The plugin is very experimental and may change a lot.

# Usage

```viml
" Simply execute a default source
call vfinder#i('files')

" Or use a custom one
call vfinder#i({
    \   'name'      : 'my_bookmarks',
    \   'to_execute': ['~/.foo', '~/lab/bar'],
    \   'maps'      : vfinder#sources#directories#maps()
})
```

The candidates are gathered form the key `to_execute` which can be:

- A filename     : `path/to/foo`
- A funcref      : `function('s:foo')`
- A list         : `['foo', 'bar']`
- A shell command: `foo -f --flag2`

# Global options

| options                         | default value               | description                                 |
| --------------                  | --------------              | --------------                              |
| `g:vfinder_verbose`             | `1`                         | Enable/Disable showing echoed messages      |
| `g:vfinder_fuzzy`               | `0`                         | Enable/Disable fuzzy matching (May be slow) |            
| `g:vfinder_cache_path`          | `$HOME . '/.cache/vfinder'` | Directory where to store cache files        |
| `g:vfinder_yank_source_enabled` | `1`                         | Enable/Disable yank source which use caching|
| `g:vfinder_mru_source_enabled`  | `1`                         | Enable/Disable mru source which use caching |

# Sources

## Default sources

The plugin provides the following sources:

- `buffers`
- `colors`
- `command_history`
- `commands`
- `directories`
- `files` (Need `rg`, `ag`, `git ls-files` or `find`) (Do not work on windows yet)
- `mru`
- `oldfiles`
- `outline` (Need `ctags-exuberant`)
- `registers`
- `spell`
- `tags` (Need `ctags-exuberant`)
- `yank`

# Source options

*(The following will be documented soon)*

- `name`
- `is_valid`
- `to_execute`
- `format_fun`
- `candidate_fun`
- `syntax_fun`
- `filter_name`
- `maps`

# Maps

There are no mappings provided by the plugin, please define your owns (See the example of configuration below).

Note that the default sources have their own mappings (Not customizable for the moment).

- `buffers`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Edit 'buffer'
    + `<C-s> / s`  : Edit 'buffer' in a split
    + `<C-v> / v`  : Edit 'buffer' in a vertical split
    + `<C-t> / t`  : Edit 'buffer' in a tab
    + `<C-d> / dd` : Wipeout 'buffer'
- `colors`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Apply the 'colorscheme'
    + `<C-o> / o`  : Apply the 'colorscheme' and stay
- `command_history`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Echo 'command' in the command line
- `commands`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Execute 'command'
- `directories`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Cd to 'dir'
    + `<C-s> / s`  : Cd to 'dir' and stay
    + `<C-v> / v`  : Cd to ../'dir' and stay
- `files`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Edit 'file'
    + `<C-s> / s`  : Edit 'file' in a split
    + `<C-v> / v`  : Edit 'file' in a vertical split
    + `<C-t> / t`  : Edit 'file' in a tab
- `mru`, `oldfiles`:
  * *Same as `files`*
- `outline`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Go to 'tag' line
    + `<C-s> / s`  : Split the current window and go to 'tag' line
    + `<C-v> / v`  : Split vertically the current window and go to 'tag' line
- `registers`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Paste in place the 'selection'
- `spell`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Replace the current word by the 'suggestion'
- `tags`:
  * insert mode/normal mode:
    + `<CR> / <CR>`: Go to 'tag' line
    + `<C-s> / s`  : Open 'tag' in a split
    + `<C-v> / v`  : Open 'tag' in a vertical split
    + `<C-o> / o`  : Preview 'tag' in the preview window
- `yank`:
  * *Same as `registers`*

# Actions

*(The following will be documented soon)*

```viml
{
  i:{'keys': {'action': '%s', 'options': {<see below>}}},
  n:{'keys': {'action': '%s', 'options': {<see below>}}},
}

" options
{
clear_prompt: 0,
echo        : 0,
function    : 0,
quit        : 1,
silent      : 1,
update      : 0
}
```

# Example of configuration

```viml
let g:vfinder_fuzzy = 0
nnoremap <silent> ,f :call vfinder#i('files')<CR>
nnoremap <silent> ,b :call vfinder#i('buffers')<CR>
nnoremap <silent> ,d :call vfinder#i('directories')<CR>
nnoremap <silent> ,r :call vfinder#i('mru')<CR>
nnoremap <silent> ,c :call vfinder#i('commands')<CR>
nnoremap <silent> ,,c :call vfinder#i('command_history')<CR>
nnoremap <silent> ,t :call vfinder#i('tags')<CR>
nnoremap <silent> ,,f :call vfinder#i('outline')<CR>
nnoremap <silent> z= :call vfinder#i('spell')<CR>
inoremap <silent> <A-z> <Esc>:call vfinder#i('spell')<CR>
nnoremap <silent> ,y :call vfinder#i('yank')<CR>
inoremap <silent> <A-y> <Esc>:call vfinder#i('yank')<CR>
" nnoremap <silent> ,C :call vfinder#i('colors')<CR>
" nnoremap <silent> ,,r :call vfinder#i('oldfiles')<CR>
" nnoremap <silent> ,Y :call vfinder#i('registers')<CR>
nnoremap <silent> ,B :call vfinder#i({
            \   'name'      : 'bookmarks',
            \   'to_execute': ['~/.vim', '~/Temp/lab'],
            \   'maps'      : vfinder#sources#directories#maps()
            \ })<CR>

```

# Note

There are a lot of things planned for the plugin, but as a side project, I implement what I need when I have time.
