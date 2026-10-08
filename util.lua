-- Pure string helpers handed to every snippet's expand(words, util).
local M = {}

function M.words(input)
    local words = {}
    for word in input:gmatch("[^%s]+") do
        table.insert(words, word)
    end
    return words
end

-- join(words, sep, from, to): join words[from..to] (defaults: " ", 1, #words)
function M.join(words, sep, from, to)
    return table.concat(words, sep or " ", from or 1, to or #words)
end

function M.starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

function M.ends_with(str, suffix)
    return suffix == "" or str:sub(-#suffix) == suffix
end

-- strip_after("i=0", "=") -> "i"
function M.strip_after(str, char)
    local idx = str:find(char, 1, true)
    if idx == nil then
        return str
    end
    return str:sub(1, idx - 1)
end

function M.remove_special_chars(str)
    return (str:gsub("[^%w%s]+$", ""))
end

-- C/C++ ---------------------------------------------------------------------

M.CDataTypes = {
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
    ["$ull"] = "unsigned long long",
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

M.COperands = {
    ["=="] = "==",
    ["!="] = "!=",
    [">="] = ">=",
    [">"] = ">",
    ["<="] = "<=",
    ["<"] = "<",
    ["&&"] = "&&",
    ["||"] = "||",
    ["++"] = "++",
    ["--"] = "--",
    ["eq"] = "==",
    ["ne"] = "!=",
    ["gt"] = ">=",
    ["gr"] = ">",
    ["lt"] = "<=",
    ["ls"] = "<",
    ["and"] = "&&",
    ["or"] = "||",
    ["pp"] = "++",
    ["mm"] = "--",
}

-- Resolve a type token: "$i" -> "int", "%size_t" -> "size_t", anything else -> nil
function M.ctype(word)
    if word == nil then
        return nil
    end
    if M.CDataTypes[word] ~= nil then
        return M.CDataTypes[word]
    end
    if word:sub(1, 1) == "%" and #word > 1 then
        return word:sub(2)
    end
    return nil
end

-- Build "type name<sep>type name..." from words[start..]. A name without a
-- preceding type token gets default_type (or no type when default_type is nil).
function M.typed_list(words, start, sep, default_type)
    local out = {}
    local i = start or 1
    while i <= #words do
        local t = M.ctype(words[i])
        if t ~= nil then
            if words[i + 1] ~= nil then
                table.insert(out, t .. " " .. words[i + 1])
                i = i + 2
            else
                table.insert(out, t)
                i = i + 1
            end
        else
            table.insert(out, default_type and (default_type .. " " .. words[i]) or words[i])
            i = i + 1
        end
    end
    return table.concat(out, sep or ", ")
end

return M
