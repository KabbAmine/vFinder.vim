# sources

## default sources

- buffers
- colors
- command_history
- commands
- directories
- files
- mru
- oldfiles
- outline
- tags
- yank
- registers
- spell

# source options

```viml
name,
is_valid,
to_execute,
format_fun,
candidate_fun,
syntax_fun,
filter_name,
maps,
```

# maps

```viml
{
  i:{'keys': {'action': '%s', 'options': {<see below>}}},
  n:{'keys': {'action': '%s', 'options': {<see below>}}},
}
```

## maps options

```viml
quit,
silent,
update,
function,
echo,
clear_prompt,
```
