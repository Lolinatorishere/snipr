--local keys = {
--    "q", -- if(){}
--    "a", -- async function{}
--    "s", -- function{}
--    "d", -- document.getElementById
--    "f", -- addEventListener
--    "z", -- call async function()
--    "x", -- call async arrow function ()
--    "k", -- console.error
--    "l", -- console.log
--}

local function SetJsFuncs(key, middleware)
    local indent = middleware.GetContentUnderCursor()
    local SeperateWords = middleware.SeperateWords
    local remove_special_chars = middleware.remove_special_chars
    --    vim.notify(key, vim.log.levels.INFO)
    local reg = ""
    local lines = 0
    local empty = 0
    local mode = "n"
    local endofline = false
    local colpos = 0
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
    if key == "q" then
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
    end
    if key == "s" then
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
    end
    if key == "a" then
        reg = "async function " .. remove_special_chars(words[1]) .. "("
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
    end
    if key == "A" then
        reg = "async " .. remove_special_chars(words[1]) .. "("
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
    end
    if key == "S" then
        reg = remove_special_chars(words[1]) .. "("
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
    end
    if key == "d" then
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
    end
    if key == "f" then
        reg = ".addEventListener(" .. words[1] .. ", () => {\n\n});"
        lines = 3
        empty = 1
        mode = "i"
        endofline = true
    end
    if key == "F" then
        reg = ".addEventListener(" .. words[1] .. ", async() => {\n\n});"
        lines = 3
        empty = 1
        mode = "i"
        endofline = true
    end
    if key == "k" then
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
    end
    if key == "l" then
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
    end
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
    wk.add({
        { "<leader>h", group = "Js snips" },
        {
            "<leader>hq",
            function()
                SetJsFuncs("q", middleware)
            end,
            desc = "if(words..){}",
        },
        {
            "<leader>ha",
            function()
                SetJsFuncs("a", middleware)
            end,
            desc = "async function(words..){ }",
        },
        {
            "<leader>hs",
            function()
                SetJsFuncs("s", middleware)
            end,
            desc = "function(words..){ }",
        },
        {
            "<leader>hd",
            function()
                SetJsFuncs("d", middleware)
            end,
            desc = "document.getElementById('word')",
        },
        {
            "<leader>hf",
            function()
                SetJsFuncs("f", middleware)
            end,
            desc = ".addEventListener('word', () => {})",
        },
        {
            "<leader>hF",
            function()
                SetJsFuncs("F", middleware)
            end,
            desc = "addEventListener('word', async () => {})",
        },
        {
            "<leader>hA",
            function()
                SetJsFuncs("A", middleware)
            end,
            desc = "words (words..)",
        },
        {
            "<leader>hS",
            function()
                SetJsFuncs("S", middleware)
            end,
            desc = "words (words..)",
        },
        {
            "<leader>hk",
            function()
                SetJsFuncs("k", middleware)
            end,
            desc = "console.error(words..)",
        },
        {
            "<leader>hl",
            function()
                SetJsFuncs("l", middleware)
            end,
            desc = "console.log(words..)",
        },
    })
end

return JsUpdateBuffers
