local JsSnips = require("custom.snipr.snips.javascript")
local HtmlSnips = require("custom.snipr.snips.html")
local Middleware = require("custom.snipr.middleware")
local wk = require("which-key")
local binds = { ft = "", binds = {} }

local Allowed_ft = {
    javascript = true,
    javascriptreact = true,
    typescript = true,
    typescriptreact = true,
    html = true,
    css = true,
    scss = true,
    less = true,
    vue = true,
    c = true,
    cpp = true,
    cs = true,
    lua = true,
}

function Snippers(ft)
    if ft == nil then
        pcall(vim.keymap.del, "n", "<leader>h")
        return
    end
    if Allowed_ft[ft] then
        if #binds.binds > 0 and ft ~= binds.ft then
            Middleware.unsetBinds(binds.binds, wk)
        end
        if ft == "javascript" then
            binds = JsSnips(Middleware, wk)
            return
        end
        if ft == "html" then
            Middleware.unsetBinds(binds)
            binds = HtmlSnips(Middleware, wk)
            return
        end
        vim.notify("no snips for filetype: " .. ft, vim.log.levels.INFO)
        return
    end
    wk.add({
        { "<leader>h", group = "snips", desc = "unsuported" },
    })
    pcall(vim.keymap.del, "n", "<leader>h")
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    callback = function()
        Snippers(vim.bo.filetype)
    end,
})
