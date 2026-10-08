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

## Custom keys

Every snippet uses its default `key` unless you override it in `init.lua`:

```lua
require("custom.snipr.snippers").setup({
    keys = {
        ccpp = { lf = "L", r = "R" },   -- module name -> { default key = custom key }
        javascript = { l = "c" },
    },
})
```

Keys are relative to `<leader>h`. An override falls back to the snippet's
default key, and a warning is shown through lazy.nvim's notify, when:

- it names a snippet or module that doesn't exist, or the key isn't a non-empty string;
- it clashes with another snippet's key in the same module. Keys clash when
  they are equal, or when one is a prefix of the other (`e` vs `ee`), since
  vim would otherwise wait on the shorter key.

A custom key can take a default key that another override frees up
(`{ i = "Q", lf = "i" }`). Reverting one override can make another one clash;
that one reverts too.

## Snippet behaviour

- The current line's indentation is applied to every output line.
- Each leading `\t` in an output line is one extra indent level (respects `expandtab`/`shiftwidth`).
- `util` (see `util.lua`): `words`, `join(words, sep, from, to)`, `starts_with`, `ends_with`,
  `strip_after`, `remove_special_chars`, and for C: `ctype`, `typed_list`, `CDataTypes`, `COperands`.
