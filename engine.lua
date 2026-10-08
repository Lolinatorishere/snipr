-- Turns a snippet's pure result into buffer edits and binds snippet modules
-- to buffers.
--
-- A snippet is { key, desc, min_words?, expand = function(words, util) }.
-- expand returns nil to abort, or:
--   {
--     lines  = { ... } | "multi\nline string",  -- leading tabs = one indent level each
--     cursor = { row, col | "eol" },              -- row is 1-based within lines, col 0-based
--     mode   = "i" | "n",
--   }
local util = require("custom.snipr.util")

local M = {}

local function indent_unit()
    if vim.bo.expandtab then
        return string.rep(" ", vim.fn.shiftwidth())
    end
    return "\t"
end

function M.apply(result, row, base_indent)
    local lines = result.lines
    if type(lines) == "string" then
        lines = vim.split(lines, "\n", { plain = true })
    end
    local unit = indent_unit()
    local out = {}
    for i, line in ipairs(lines) do
        local tabs, rest = line:match("^(\t*)(.*)$")
        out[i] = base_indent .. string.rep(unit, #tabs) .. rest
    end
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, out)

    local cursor = result.cursor or { 1, "eol" }
    local crow = row + math.min(math.max(cursor[1], 1), #out) - 1
    local line = out[crow - row + 1]
    local eol = cursor[2] == "eol"
    local ccol = eol and #line or (#base_indent + cursor[2])
    vim.api.nvim_win_set_cursor(0, { crow, ccol })

    if result.mode == "i" then
        vim.cmd(eol and "startinsert!" or "startinsert")
    end
end

function M.expand(snippet)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_get_current_line()
    local base_indent = line:match("^%s*")
    local words = util.words(line)
    if #words < (snippet.min_words or 0) then
        return
    end
    local ok, result = pcall(snippet.expand, words, util)
    if not ok then
        vim.notify("snipr [" .. snippet.key .. "]: " .. tostring(result), vim.log.levels.ERROR)
        return
    end
    if result == nil then
        return
    end
    M.apply(result, row, base_indent)
end

-- keys: { [snippet.key] = key to bind } (see keys.lua); defaults to snippet.key
function M.attach(buf, module, keys)
    keys = keys or {}
    local has_wk, wk = pcall(require, "which-key")
    if has_wk then
        local spec = { { "<leader>h", group = module.group, buffer = buf } }
        for key, name in pairs(module.subgroups or {}) do
            table.insert(spec, { "<leader>h" .. key, group = name, buffer = buf })
        end
        wk.add(spec)
    end
    local bound = {}
    for _, snippet in ipairs(module.snippets) do
        local lhs = "<leader>h" .. (keys[snippet.key] or snippet.key)
        vim.keymap.set("n", lhs, function()
            M.expand(snippet)
        end, { buffer = buf, desc = snippet.desc })
        table.insert(bound, lhs)
    end
    vim.b[buf].snipr_lhs = bound
end

function M.detach(buf)
    for _, lhs in ipairs(vim.b[buf].snipr_lhs or {}) do
        pcall(vim.keymap.del, "n", lhs, { buffer = buf })
    end
    vim.b[buf].snipr_lhs = nil
end

return M
