local JsSnips = require("custom.sniper.snipss.javascript")
local HtmlSnips = require("custom.sniper.snipss.html")
local Middleware = require("custom.middleware")
local wk = require("which-key")

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
    if Allowed_ft[ft] == true then
        if ft == "javascript" then
            JsSnips(Middleware, wk)
            return
        end
        if ft == "html" then
            HtmlSnips(Middleware, wk)
            return
        end
        wk.add({
            { "<leader>h", group = "snips", desc = "no snips available" },
        })
        vim.notify("no snips for filetype: " .. ft, vim.log.levels.INFO)
        return
    end
    wk.add({
        { "<leader>h", group = "snips", desc = "unsuported" },
    })
    pcall(vim.keymap.del, "n", "<leader>h")
end

return Snippers
