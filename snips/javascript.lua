local lines = 0
local empty = 0
local mode = "n"
local endofline = false
local reg = ""
local colpos = 0

local keys = {
    q = function(words, _)
        reg = "if (" .. words[1]
        if #words > 1 then
            for i = 2, #words do
                reg = reg .. words[i]
            end
        end
        reg = reg .. ") {\n\n}"
        lines = 3
        empty = 2
        mode = "i"
        endofline = true
    end,
    s = function(words, _)
        reg = "function " .. words[1] .. "("
        if #words > 1 then
            for i = 2, #words do
                if i == #words then
                    reg = reg .. words[i]
                else
                    reg = reg .. words[i] .. ", "
                end
            end
        end
        reg = reg .. ") {\n\n}"
        lines = 3
        empty = 2
        mode = "i"
        endofline = true
    end,
    a = function(words, m)
        reg = "async function " .. m.remove_special_chars(words[1]) .. "("
        if #words > 1 then
            for i = 2, #words do
                if i == #words then
                    reg = reg .. words[i]
                else
                    reg = reg .. words[i] .. ", "
                end
            end
        end
        reg = reg .. ") {\n\n}"
        lines = 3
        empty = 2
        mode = "i"
        endofline = true
    end,
    A = function(words, m)
        reg = "async " .. m.remove_special_chars(words[1]) .. "("
        if #words > 1 then
            for i = 2, #words do
                if i == #words then
                    reg = reg .. words[i]
                else
                    reg = reg .. words[i] .. ", "
                end
            end
        end
        reg = reg .. ");"
        lines = 1
        empty = 1
        endofline = true
    end,
    S = function(words, m)
        reg = m.remove_special_chars(words[1]) .. "("
        if #words > 1 then
            for i = 2, #words do
                if i == #words then
                    reg = reg .. words[i]
                else
                    reg = reg .. words[i] .. ", "
                end
            end
        end
        reg = reg .. ");"
        lines = 1
        empty = 1
        endofline = true
    end,
    d = function(words, _)
        if #words > 1 then
            reg = "let " .. words[1] .. " = document.getElementById('" .. words[2]
        else
            reg = "document.getElementById("
            reg = reg .. '"' .. words[1]
        end
        reg = reg .. '")'
        lines = 1
        empty = 1
        mode = "i"
        endofline = true
    end,
    f = function(words, _)
        reg = ".addEventListener(" .. words[1] .. ", () => {\n\n});"
        lines = 3
        empty = 1
        mode = "i"
        endofline = true
    end,
    F = function(words, _)
        reg = ".addEventListener(" .. words[1] .. ", async() => {\n\n});"
        lines = 3
        empty = 1
        mode = "i"
        endofline = true
    end,
    k = function(words, _)
        reg = "console.error(" .. words[1]
        if #words > 1 then
            for i = 2, #words do
                if i ~= #words then
                    reg = reg .. " + "
                end
                reg = reg .. words[i]
            end
        end
        reg = reg .. ");"
        lines = 1
        empty = 1
        endofline = true
    end,
    l = function(words, _)
        reg = "console.log(" .. words[1]
        if #words > 1 then
            for i = 2, #words do
                if i ~= #words then
                    reg = reg .. " + "
                end
                reg = reg .. words[i]
            end
        end
        reg = reg .. ");"
        lines = 1
        empty = 1
        endofline = true
    end,
}

local function SetFuncs(key, middleware)
    local indent = middleware.GetContentUnderCursor()
    local SeperateWords = middleware.SeperateWords
    if key == nil then
        return
    end
    if vim.fn.getreg("+") == nil then
        return
    end
    local words = SeperateWords(vim.fn.getreg("+"))
    if #words == 0 then
        return
    end
    keys[key](words, middleware)
    local print = vim.split(reg, "\n")
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if endofline == true then
        col = #vim.api.nvim_get_current_line()
    else
        col = colpos
    end
    local cursor = { row = row + empty, col = col }
    middleware.PrintToBuffer(row, col, cursor, print, mode, indent, lines)
end

local function JsUpdateBuffers(middleware, wk)
    local ibinds = {}
    wk.add({
        { "<leader>h", group = "Js snips" },
    })
    vim.keymap.set("n", "<leader>hq", function()
        SetFuncs("q", middleware)
    end, { desc = "if(words..){}" })
    vim.keymap.set("n", "<leader>ha", function()
        SetFuncs("a", middleware)
    end, { desc = "async function(words..){ }" })
    vim.keymap.set("n", "<leader>hs", function()
        SetFuncs("s", middleware)
    end, { desc = "function(words..){ }" })
    vim.keymap.set("n", "<leader>hd", function()
        SetFuncs("d", middleware)
    end, { desc = "document.getElementById('word')" })
    vim.keymap.set("n", "<leader>hf", function()
        SetFuncs("f", middleware)
    end, { desc = ".addEventListener('word', () => {})" })
    vim.keymap.set("n", "<leader>hF", function()
        SetFuncs("F", middleware)
    end, { desc = "addEventListener('word', async () => {})" })
    vim.keymap.set("n", "<leader>hA", function()
        SetFuncs("A", middleware)
    end, { desc = "words (words..)" })
    vim.keymap.set("n", "<leader>hS", function()
        SetFuncs("S", middleware)
    end, { desc = "words (words..)" })
    vim.keymap.set("n", "<leader>hk", function()
        SetFuncs("k", middleware)
    end, { desc = "console.error(words..)" })
    vim.keymap.set("n", "<leader>hl", function()
        SetFuncs("l", middleware)
    end, { desc = "console.log(words..)" })
    ibinds = middleware.getObjKeyNames(keys)
    return { ft = "javascript", binds = ibinds }
end

return JsUpdateBuffers
