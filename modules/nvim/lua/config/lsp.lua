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

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        -- 補完を有効化
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end


        -- 保存時にフォーマットを行う
        if not client:supports_method("textDocument/willSaveWaitUntil")
            and client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 3000 })
                end,
            })
        end
    end,
})
