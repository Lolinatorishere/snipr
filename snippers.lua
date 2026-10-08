local engine = require("custom.snipr.engine")

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

local function attach(buf)
    local name = registry[vim.bo[buf].filetype]
    local current = vim.b[buf].snipr_module
    if name == current then
        return
    end
    if current ~= nil then
        engine.detach(buf, require("custom.snipr.snips." .. current))
    end
    if name ~= nil then
        engine.attach(buf, require("custom.snipr.snips." .. name))
    end
    vim.b[buf].snipr_module = name
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("snipr", { clear = true }),
    callback = function(args)
        attach(args.buf)
    end,
})

-- buffers that were already open before this file was loaded
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
        attach(buf)
    end
end
