-- Resolves the key each snippet is bound to (relative to the <leader>h prefix).
--
-- Defaults come from snippet.key. User overrides map a snippet's default key
-- to a custom one: { lf = "fl" }. An override is dropped (snippet falls back
-- to its default) and a warning is produced when it is unknown, invalid, or
-- clashes with another snippet's key. Two keys clash when they are equal or
-- one is a prefix of the other (vim would have to wait on the shorter one).
local M = {}

local function clash(a, b)
    return a:sub(1, #b) == b or b:sub(1, #a) == a
end

-- returns { [default_key] = effective_key }, { warning, ... }
function M.resolve(module, overrides)
    overrides = overrides or {}
    local warnings = {}
    local order = {}
    local keys = {}
    local custom = {}

    for _, snippet in ipairs(module.snippets) do
        table.insert(order, snippet.key)
        keys[snippet.key] = snippet.key
    end
    table.sort(order)

    local unknown = {}
    for from, to in pairs(overrides) do
        if keys[from] == nil then
            table.insert(unknown, from)
        elseif type(to) ~= "string" or to == "" or to:find("%s") then
            table.insert(warnings, ("`%s`: invalid key `%s`, using default"):format(from, vim.inspect(to)))
        elseif to ~= from then
            keys[from] = to
            custom[from] = true
        end
    end
    table.sort(unknown)
    for _, from in ipairs(unknown) do
        table.insert(warnings, ("`%s`: no such snippet, override ignored"):format(from))
    end

    -- Reverting one override can create a new clash with another override, so
    -- repeat until stable. Each pass reverts at least one override or stops.
    local reported = {}
    local changed = true
    while changed do
        changed = false
        for i = 1, #order do
            for j = i + 1, #order do
                local a, b = order[i], order[j]
                local ka, kb = keys[a], keys[b]
                if clash(ka, kb) then
                    if custom[a] or custom[b] then
                        for _, pair in ipairs({ { a, ka, b, kb }, { b, kb, a, ka } }) do
                            local s, ks, other, ko = pair[1], pair[2], pair[3], pair[4]
                            if custom[s] then
                                table.insert(
                                    warnings,
                                    ("`%s` → `%s` conflicts with snippet `%s` (bound to `%s`), using default `%s`"):format(
                                        s,
                                        ks,
                                        other,
                                        ko,
                                        s
                                    )
                                )
                                keys[s] = s
                                custom[s] = nil
                            end
                        end
                        changed = true
                    elseif not reported[a .. "\0" .. b] then
                        -- two defaults clash: a bug in the snippet module itself
                        reported[a .. "\0" .. b] = true
                        table.insert(warnings, ("default keys `%s` and `%s` conflict"):format(a, b))
                    end
                end
            end
        end
    end

    return keys, warnings
end

return M
