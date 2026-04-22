return {
    "neovim/nvim-lspconfig",
    dependencies = {
        'saghen/blink.cmp',
    },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        { "<C-space>", "<cmd>lua vim.lsp.completion.get()  <CR>", mode = "i" },
        { "gh",        "<cmd>lua vim.lsp.buf.hover()       <CR>" },
        { "gd",        "<cmd>lua vim.lsp.buf.definition()  <CR>" },
        { "gD",        "<cmd>lua vim.lsp.buf.declaration() <CR>" },
        { "gq",        "<cmd>lua vim.lsp.buf.format()      <CR>" },
        --[
        -- Note: default mapping is as follows:
        --   * grn   => vim.lsp.buf.rename()
        --   * grr   => vim.lsp.buf.references()
        --   * gra   => vim.lsp.buf.code_action()
        --   * gri   => vim.lsp.buf.implementation()
        --   * gO    => vim.lsp.buf.document_symbol()
        --   * <C-s> => vim.lsp.buf.signature_help()
        --]
    },
}
