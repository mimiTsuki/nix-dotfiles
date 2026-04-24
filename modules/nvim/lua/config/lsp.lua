vim.lsp.enable({
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
    "lua_ls",
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/rust_analyzer.lua
    "rust_analyzer",
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/vtsls.lua
    "vtsls",
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/tailwindcss.lua
    "tailwindcss",
    -- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/gopls.lua
    "gopls"
})

vim.diagnostic.config({
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "",
        },
    },
    underline = true,
    update_in_insert = false,
    float = {
        border = "rounded",
        source = true,
    },
})

vim.api.nvim_create_autocmd("CursorHold", {
    group = vim.api.nvim_create_augroup("my.diagnostic", {}),
    callback = function()
        vim.diagnostic.open_float(nil, { focus = false })
    end,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        -- 補完を有効化
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})
