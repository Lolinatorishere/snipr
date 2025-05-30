local lines = 0
local empty = 0
local mode = "n"
local endofline = false
local reg = ""
local colpos = 0

--local elif = {
--    ["$e"] = { "else(", true },
--    ["$ei"] = { "else if(", true },
--    ["$r"] = { "return ", true },
--}
--
--local switch = {
--    ["$c"] = { "case ", true },
--    ["$b"] = { "break;", true },
--    ["$r"] = { "return ", true },
--}

local CDataTypes = {
    ["$v"] = "void",
    ["$c"] = "char",
    ["$s"] = "short",
    ["$i"] = "int",
    ["$l"] = "long",
    ["$f"] = "float",
    ["$d"] = "double",
    ["$ll"] = "long long",
    ["$ld"] = "long double",
    ["$uc"] = "unsigned char",
    ["$us"] = "unsigned short",
    ["$ui"] = "unsigned int",
    ["$ul"] = "unsigned long",
    ["$uf"] = "unsinged float",
    ["$ud"] = "unsinged double",
    ["$ull"] = "unsigned long long",
    ["$uld"] = "unsigned long double",
    ["$u8"] = "uint8_t",
    ["$8"] = "int8_t",
    ["$u16"] = "uint16_t",
    ["$16"] = "int16_t",
    ["$u32"] = "uint32_t",
    ["$32"] = "int32_t",
    ["$u64"] = "uint64_t",
    ["$64"] = "int64_t",
    ["$%hd"] = "short",
    ["$%hu"] = "unsigned short",
    ["$%u"] = "unsigned int",
    ["$%d"] = "int",
    ["$%ld"] = "long",
    ["$%lu"] = "unsigned long",
    ["$%lld"] = "long long",
    ["$%llu"] = "unsigned long long",
    ["$%c"] = "char",
    ["$%f"] = "float",
    ["$%lf"] = "double",
    ["$%Lf"] = "long double",
}

--xshort int %hd
--xunsigned short int %hu
--xunsigned int %u
--xint %d
--xlong int %ld
--xunsigned long int %lu
--xlong long int %lld
--xunsigned long long int %llu
--xsigned char %c
--xunsigned char %c
--float %f
--double %lf
--long double %Lf

local function StartsWithBrace(input)
    return input:sub(1, 1) == "}"
end

local keys = {

    f = function(words, _)
        local start = 0
        if #words > 1 then
            local dtype = false
            if CDataTypes[words[1]] ~= nil then
                reg = CDataTypes[words[1]] .. " "
                reg = reg .. words[2] .. "("
                start = 3
            else
                reg = "int " .. words[1] .. "("
                start = 2
            end
            for i = start, #words do
                if CDataTypes[words[i]] ~= nil and dtype == false then
                    reg = reg .. CDataTypes[words[i]] .. " "
                    dtype = true
                else
                    if dtype == true then
                        reg = reg .. words[i]
                    else
                        reg = reg .. "int " .. words[i]
                    end
                    dtype = false
                end
                if i ~= #words and dtype == false then
                    reg = reg .. ","
                end
            end
            reg = reg .. "){\n\n}"
            lines = 3
            empty = 3
            mode = "i"
            endofline = true
        else
            reg = "int function(){\n\n}"
            lines = 3
            empty = 2
            mode = "i"
            endofline = true
        end
    end,

    i = function(words, _)
        reg = "if( "
        if #words > 1 then
            reg = reg .. words[1]
            for i = 2, #words do
                reg = reg .. words[i]
            end
        elseif #words == 1 then
            reg = reg .. words[1]
        end
        reg = reg .. "){\n\n}"
        lines = 3
        empty = 2
        mode = "i"
        endofline = true
    end,

    ee = function(words, _)
        if words[1] == "}" then
            reg = "}"
        end
        reg = reg .. "else{\n\n}"
        lines = 3
        empty = 2
        mode = "i"
        endofline = true
    end,

    ei = function(words, _)
        if #words ~= 0 then
            if StartsWithBrace then
                reg = "}"
                words[1] = words[1]:sub(2)
            end
            reg = reg .. "else if("
            if #words > 1 then
                for i = 1, #words do
                    reg = reg .. words[i]
                end
            else
                reg = reg .. words[1]
            end
        else
            reg = reg .. "else if("
        end
        reg = reg .. "){\n\n}"
        lines = 3
        empty = 2
        lines = 3
        empty = 2
        mode = "i"
        endofline = true
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

local function CcppUpdateBuffers(middleware, wk)
    local ibinds = {}
    wk.add({
        { "<leader>h", group = "c/cpp snips" },
        { "<leader>he", group = "elses" },
    })
    vim.keymap.set("n", "<leader>hf", function()
        SetFuncs("f", middleware)
    end, { desc = "$dtype1 words2({$dtype words}..){}" })
    vim.keymap.set("n", "<leader>hi", function()
        SetFuncs("i", middleware)
    end, { desc = "if({words1 $comp words2} $||$&& ...){}" })
    vim.keymap.set("n", "<leader>hI", function()
        SetFuncs("I", middleware)
    end, { desc = "elseif({words1 $comp words2} $||$&& ...){}" })
    vim.keymap.set("n", "<leader>hee", function()
        SetFuncs("ee", middleware)
    end, { desc = "else{}" })
    vim.keymap.set("n", "<leader>hei", function()
        SetFuncs("ei", middleware)
    end, { desc = "else if(words1){}" })
    vim.keymap.set("n", "<leader>hei", function()
        SetFuncs("ei", middleware)
    end, { desc = "switch(words1){case words2: break... default: return 0;}" })
    ibinds = middleware.getObjKeyNames(keys)
    return { ft = "html", binds = ibinds }
end

return CcppUpdateBuffers
