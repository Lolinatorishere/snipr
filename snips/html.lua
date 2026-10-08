-- <open></close> on one line with the cursor on the closing tag, or a
-- three-line block when there is inner text.
local function element(tag, attrs, w, u, from)
    local open = "<" .. tag .. attrs .. ">"
    local close = "</" .. tag .. ">"
    if #w >= from then
        return { lines = { open, "\t" .. u.join(w, " ", from), close }, cursor = { 2, "eol" }, mode = "n" }
    end
    return { lines = { open .. close }, cursor = { 1, #open }, mode = "n" }
end

return {
    group = "Html snips",
    subgroups = { T = "tag++" },
    snippets = {
        {
            key = "t",
            desc = "<word1> words...</word1>",
            min_words = 1,
            expand = function(w, u)
                return element(w[1], "", w, u, 2)
            end,
        },
        {
            key = "Ta",
            desc = '<word1 class="word2" id="word3"> words...</word1>',
            min_words = 3,
            expand = function(w, u)
                return element(w[1], ' class="' .. w[2] .. '" id="' .. w[3] .. '"', w, u, 4)
            end,
        },
        {
            key = "Tc",
            desc = '<word1 class="word2"> words...</word1>',
            min_words = 2,
            expand = function(w, u)
                return element(w[1], ' class="' .. w[2] .. '"', w, u, 3)
            end,
        },
        {
            key = "Ti",
            desc = '<word1 id="word2"> words...</word1>',
            min_words = 2,
            expand = function(w, u)
                return element(w[1], ' id="' .. w[2] .. '"', w, u, 3)
            end,
        },
        {
            key = "c",
            desc = '<div class="word1"></div>',
            min_words = 1,
            expand = function(w, u)
                return element("div", ' class="' .. w[1] .. '"', w, u, 2)
            end,
        },
        {
            key = "i",
            desc = '<div id="word1"></div>',
            min_words = 1,
            expand = function(w, u)
                return element("div", ' id="' .. w[1] .. '"', w, u, 2)
            end,
        },
        {
            key = "s",
            desc = '<div word1="word2"></div>',
            min_words = 2,
            expand = function(w, u)
                return element("div", " " .. w[1] .. '="' .. w[2] .. '"', w, u, 3)
            end,
        },
    },
}
