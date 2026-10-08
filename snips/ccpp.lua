-- Type tokens: $i -> int, $v -> void, %anything -> anything (see util.CDataTypes)

local function block(head, tail)
    return { lines = { head .. "{", "\t", tail or "}" }, cursor = { 2, "eol" }, mode = "i" }
end

-- "}else" style chaining: a leading "}" on the line is kept in front
local function take_brace(w)
    if w[1] ~= nil and w[1]:sub(1, 1) == "}" then
        w[1] = w[1]:sub(2)
        if w[1] == "" then
            table.remove(w, 1)
        end
        return "}"
    end
    return ""
end

return {
    group = "c/cpp snips",
    subgroups = { e = "elses", s = "switch", l = "loops" },
    snippets = {
        {
            key = "c",
            desc = "$dtype n words n...",
            min_words = 1,
            expand = function(w, u)
                local out = {}
                for i, word in ipairs(w) do
                    out[i] = u.ctype(word) or word
                end
                return { lines = { u.join(out) }, cursor = { 1, "eol" }, mode = "i" }
            end,
        },
        {
            key = "f",
            desc = "$dtype1 words2({$dtype words}..){}",
            expand = function(w, u)
                if #w == 0 then
                    return block("int function()")
                end
                local ret, name, start = "int", w[1], 2
                if u.ctype(w[1]) ~= nil then
                    ret, name, start = u.ctype(w[1]), w[2] or "function", 3
                end
                return block(ret .. " " .. name .. "(" .. u.typed_list(w, start, ", ", "int") .. ")")
            end,
        },
        {
            key = "i",
            desc = "if({words1 $comp words2} $||$&& ...){}",
            expand = function(w, u)
                return block("if(" .. u.join(w) .. ")")
            end,
        },
        {
            key = "ee",
            desc = "else{}",
            expand = function(w, _)
                return block(take_brace(w) .. "else")
            end,
        },
        {
            key = "ei",
            desc = "else if(words1){}",
            expand = function(w, u)
                local brace = take_brace(w)
                return block(brace .. "else if(" .. u.join(w) .. ")")
            end,
        },
        {
            key = "sh",
            desc = "switch(words1){ default: break;}",
            expand = function(w, _)
                return {
                    lines = { "switch(" .. (w[1] or "") .. "){", "\t", "default:", "\tbreak;", "}" },
                    cursor = { 2, "eol" },
                    mode = "i",
                }
            end,
        },
        {
            key = "sc",
            desc = "case words1: break;",
            min_words = 1,
            expand = function(w, _)
                local lines = {}
                for _, word in ipairs(w) do
                    vim.list_extend(lines, { "case " .. word .. ":", "\t", "\tbreak;" })
                end
                return { lines = lines, cursor = { 2, "eol" }, mode = "i" }
            end,
        },
        {
            key = "lf",
            desc = "for($dtype words1 ; $opperand words2 ; words1 $opperand){}",
            min_words = 3,
            expand = function(w, u)
                local t = u.CDataTypes[w[1]]
                if t == nil then
                    return nil
                end
                local var = u.strip_after(w[2], "=")
                local step = u.COperands[w[4]] or "++"
                return block("for (" .. t .. " " .. w[2] .. " ; " .. var .. w[3] .. " ; " .. var .. step .. " ) ")
            end,
        },
        {
            key = "r",
            desc = "return words n ... ;",
            expand = function(w, u)
                if w[1] == "return" then
                    table.remove(w, 1)
                end
                local line = #w > 0 and ("return " .. u.join(w)) or "return"
                if not u.ends_with(line, ";") then
                    line = line .. ";"
                end
                return { lines = { line }, cursor = { 1, "eol" }, mode = "i" }
            end,
        },
    },
}
