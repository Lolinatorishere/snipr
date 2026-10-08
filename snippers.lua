-- Usage (init.lua):
--   require("custom.snipr.snippers")                 -- default keys
--   require("custom.snipr.snippers").setup({
--       keys = {                                     -- per snippet module
--           ccpp = { lf = "fl", r = "R" },           -- default key -> custom key
--       },
--   })
-- Keys are relative to <leader>h. Overrides that are unknown or conflict with
-- another snippet's key fall back to the default and raise a warning.
local engine = require("custom.snipr.engine")
local resolve = require("custom.snipr.keys").resolve

local M = {}

-- filetype -> module under custom.snipr.snips
local registry = {
    javascript = "javascript",
    javascriptreact = "javascript",
    typescript = "javascript",
    typescriptreact = "javascript",
    html = "html",
    c = "ccpp",
    cpp = "ccpp",
}

local config = { keys = {} }
local resolved = {} -- module name -> { [snippet.key] = key }, resolved once per setup

local function warn(lines)
    local ok, lazy = pcall(require, "lazy.core.util")
    if ok then
        lazy.warn(lines, { title = "snipr" })
    else
        vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "snipr" })
    end
end

local function module_keys(name, module)
    if resolved[name] == nil then
        local keys, warnings = resolve(module, config.keys[name])
        if #warnings > 0 then
            local lines = { "**" .. name .. "** key overrides:" }
            for _, w in ipairs(warnings) do
                table.insert(lines, "- " .. w)
            end
            warn(lines)
        end
        resolved[name] = keys
    end
    return resolved[name]
end

local function attach(buf, force)
    local name = registry[vim.bo[buf].filetype]
    local current = vim.b[buf].snipr_module
    if name == current and not force then
        return
    end
    if current ~= nil then
        engine.detach(buf)
    end
    if name ~= nil then
        local module = require("custom.snipr.snips." .. name)
        engine.attach(buf, module, module_keys(name, module))
    end
    vim.b[buf].snipr_module = name
end

local function attach_loaded(force)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            attach(buf, force)
        end
    end
end

function M.setup(opts)
    config = vim.tbl_deep_extend("force", { keys = {} }, opts or {})
    resolved = {}

    local known = {}
    for _, name in pairs(registry) do
        known[name] = true
    end
    local unknown = {}
    for name in pairs(config.keys) do
        if not known[name] then
            table.insert(unknown, "- `" .. name .. "`: no such snippet module, overrides ignored")
        end
    end
    if #unknown > 0 then
        table.sort(unknown)
        table.insert(unknown, 1, "**keys**:")
        warn(unknown)
    end

    attach_loaded(true)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("snipr", { clear = true }),
    callback = function(args)
        attach(args.buf)
    end,
})

-- buffers that were already open before this file was loaded
attach_loaded(false)

return M
