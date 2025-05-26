local function getObjKeyNames(tbl)
    local binds = {}
    for key, _ in pairs(tbl) do
        table.insert(binds, key)
    end
    return binds
end

local function unsetBinds(binds, wk)
    for i = 1, #binds do
        pcall(vim.keymap.del, "n", "<leader>h" .. binds[i])
    end
end

local function count_leading_spaces(str)
    local _, count = string.find(str, "^( *)")
    return count or 0
end

local function GetContentUnderCursor()
    local line_num = vim.api.nvim_win_get_cursor(0)[1]
    local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
    local indent = count_leading_spaces(line_content)
    vim.fn.setreg("+", line_content)
    return indent
end

local function SeperateWords(input)
    local words = {}
    for word in input:gmatch("[^%s]+") do
        table.insert(words, word)
    end
    return words
end

local function PrintToBuffer(row, col, cursor, print, mode, indent, lines)
    local indentstring = ""
    for i = 1, indent do
        indentstring = indentstring .. " "
    end
    for i = 1, #print do
        print[i] = indentstring .. print[i]
    end
    vim.api.nvim_buf_set_lines(0, row, row + 1, false, print)
    vim.api.nvim_win_set_cursor(0, { cursor.row, cursor.col })
    if mode == "i" then
        vim.api.nvim_feedkeys("a", "n", false)
    else
        vim.api.nvim_command("stopinsert")
    end
end

local function remove_special_chars(str)
    return (str:gsub("[^%w%s]+$", ""))
end

return {
    getObjKeyNames = getObjKeyNames,
    SeperateWords = SeperateWords,
    remove_special_chars = remove_special_chars,
    GetContentUnderCursor = GetContentUnderCursor,
    PrintToBuffer = PrintToBuffer,
    unsetBinds = unsetBinds,
}
