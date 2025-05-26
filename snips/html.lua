local lines = 0
local empty = 0
local mode = "n"
local endofline = false
local reg = ""
local colpos = 0

local keys = {
    t = function(words, _)
        reg = "<" .. words[1] .. ">"
        if #words > 1 then
            reg = reg .. "\n"
            for i = 2, #words do
                reg = reg .. " " .. words[i]
            end
            lines = 3
            empty = 2
        else
            lines = 1
            empty = 1
        end
        reg = reg .. "</" .. words[1] .. ">"
    end,
    Ta = function(words, _)
        reg = "<" .. words[1] .. ' class="' .. words[2] .. '"' .. 'id="' .. words[3] .. '"' .. ">"
        if #words > 1 then
            reg = reg .. "\n"
            for i = 2, #words do
                reg = reg .. " " .. words[i]
            end
            lines = 3
            empty = 2
        else
            lines = 1
            empty = 1
        end
        reg = reg .. "</" .. words[1] .. ">"
    end,
    Tc = function(words, _)
        reg = "<" .. words[1] .. ' class="' .. words[2] .. '"' .. ">"
        if #words > 1 then
            reg = reg .. "\n"
            for i = 2, #words do
                reg = reg .. " " .. words[i]
            end
            lines = 3
            empty = 2
        else
            lines = 1
            empty = 1
        end
        reg = reg .. "</" .. words[1] .. ">"
    end,
    Ti = function(words, _)
        reg = "<" .. words[1] .. ' id="' .. words[2] .. '"' .. ">"
        if #words > 1 then
            reg = reg .. "\n"
            for i = 2, #words do
                reg = reg .. " " .. words[i]
            end
            lines = 3
            empty = 2
        else
            lines = 1
            empty = 1
        end
        reg = reg .. "</" .. words[1] .. ">"
    end,
    c = function(words, _)
        lines = 1
        empty = 1
    end,
    i = function(words, _)
        lines = 1
        empty = 1
    end,
    s = function(words, _)
        lines = 1
        empty = 1
    end,
}

local function SetFuncs(key, middleware)
    local indent = middleware.GetContentUnderCursor()
    local SeperateWords = middleware.SeperateWords
    --    vim.notify(key, vim.log.levels.INFO)
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

local function HtmlUpdateBuffers(middleware, wk)
    local ibinds = {}
    wk.add({
        { "<leader>h", group = "Html snips" },
        { "<leader>hT", group = "tag++" },
    })
    vim.keymap.set("n", "<leader>ht", function()
        SetFuncs("t", middleware)
    end, { desc = "<word1></word1>" })
    vim.keymap.set("n", "<leader>hTa", function()
        SetFuncs("Ta", middleware)
    end, { desc = '<word1 class="word2" id="word3"> words...</word1>' })
    vim.keymap.set("n", "<leader>hTc", function()
        SetFuncs("Tc", middleware)
    end, { desc = '<word1 class="word2"> words...</word1>' })
    vim.keymap.set("n", "<leader>hTi", function()
        SetFuncs("Ti", middleware)
    end, { desc = '<word1 id="word2"> words...</word1>' })
    vim.keymap.set("n", "<leader>hc", function()
        SetFuncs("c", middleware)
    end, { desc = '<tag class="word1"></tag>' })
    vim.keymap.set("n", "<leader>hi", function()
        SetFuncs("i", middleware)
    end, { desc = '<tag id="word1"></tag>' })
    vim.keymap.set("n", "<leader>hs", function()
        SetFuncs("s", middleware)
    end, { desc = '<tag word1="word2"></tag>' })
    ibinds = middleware.getObjKeyNames(keys)
    return { ft = "html", binds = ibinds }
end

return HtmlUpdateBuffers
