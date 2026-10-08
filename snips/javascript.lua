local function block(head, tail)
    return { lines = { head .. "{", "\t", tail or "}" }, cursor = { 2, "eol" }, mode = "i" }
end

local function line(text, mode)
    return { lines = { text }, cursor = { 1, "eol" }, mode = mode }
end

return {
    group = "Js snips",
    snippets = {
        {
            key = "q",
            desc = "if(words..){}",
            min_words = 1,
            expand = function(w, u)
                return block("if (" .. u.join(w) .. ") ")
            end,
        },
        {
            key = "s",
            desc = "function(words..){ }",
            min_words = 1,
            expand = function(w, u)
                return block("function " .. w[1] .. "(" .. u.join(w, ", ", 2) .. ") ")
            end,
        },
        {
            key = "a",
            desc = "async function(words..){ }",
            min_words = 1,
            expand = function(w, u)
                return block("async function " .. u.remove_special_chars(w[1]) .. "(" .. u.join(w, ", ", 2) .. ") ")
            end,
        },
        {
            key = "A",
            desc = "async words(words..);",
            min_words = 1,
            expand = function(w, u)
                return line("async " .. u.remove_special_chars(w[1]) .. "(" .. u.join(w, ", ", 2) .. ");", "n")
            end,
        },
        {
            key = "S",
            desc = "words(words..);",
            min_words = 1,
            expand = function(w, u)
                return line(u.remove_special_chars(w[1]) .. "(" .. u.join(w, ", ", 2) .. ");", "n")
            end,
        },
        {
            key = "d",
            desc = "document.getElementById('word')",
            min_words = 1,
            expand = function(w, _)
                if #w > 1 then
                    return line("let " .. w[1] .. " = document.getElementById('" .. w[2] .. "')", "i")
                end
                return line('document.getElementById("' .. w[1] .. '")', "i")
            end,
        },
        {
            key = "f",
            desc = ".addEventListener('word', () => {})",
            min_words = 1,
            expand = function(w, _)
                return block(".addEventListener(" .. w[1] .. ", () => ", "});")
            end,
        },
        {
            key = "F",
            desc = ".addEventListener('word', async () => {})",
            min_words = 1,
            expand = function(w, _)
                return block(".addEventListener(" .. w[1] .. ", async () => ", "});")
            end,
        },
        {
            key = "k",
            desc = "console.error(words..)",
            min_words = 1,
            expand = function(w, u)
                return line("console.error(" .. u.join(w, " + ") .. ");", "n")
            end,
        },
        {
            key = "l",
            desc = "console.log(words..)",
            min_words = 1,
            expand = function(w, u)
                return line("console.log(" .. u.join(w, " + ") .. ");", "n")
            end,
        },
    },
}
