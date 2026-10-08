# snipr snippet format

Type words on a line, hit `<leader>h<key>`, and the line is replaced by the snippet.

Each file in `snips/` returns a table; register its filetypes in `snippers.lua`'s `registry`.

```lua
return {
    group = "c/cpp snips",              -- which-key name for <leader>h
    subgroups = { e = "elses" },        -- which-key names for <leader>h<prefix>
    snippets = {
        {
            key = "i",                  -- mapped to <leader>hi (buffer-local)
            desc = "if(words){}",
            min_words = 1,              -- optional: do nothing with fewer words
            expand = function(words, util)
                -- pure: no buffer access, no shared state. return nil to abort.
                return {
                    lines = { "if(" .. util.join(words) .. "){", "\t", "}" },
                    cursor = { 2, "eol" },  -- row within lines (1-based), col (0-based) or "eol"
                    mode = "i",             -- "i" enters insert, "n" stays in normal
                }
            end,
        },
    },
}
```

- The current line's indentation is applied to every output line.
- Each leading `\t` in an output line is one extra indent level (respects `expandtab`/`shiftwidth`).
- `util` (see `util.lua`): `words`, `join(words, sep, from, to)`, `starts_with`, `ends_with`,
  `strip_after`, `remove_special_chars`, and for C: `ctype`, `typed_list`, `CDataTypes`, `COperands`.
