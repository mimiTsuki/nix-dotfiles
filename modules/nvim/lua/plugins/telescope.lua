return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require('telescope').setup({
            mappings = {
                n = {
                    ['<Esc>'] = require('telescope.actions').close,
                    ['<C-g>'] = require('telescope.actions').close
                },
                i = {
                    ['<C-g>'] = require('telescope.actions').close
                }
            },
            pickers = {
                find_files = {
                    theme = 'dropdown',
                    previewer = false
                },
                live_grep = {
                    theme = 'dropdown',
                    previewer = false
                }
            }
        })
        local builtin = require('telescope.builtin')
        vim.keymap.set("n", "<Leader>ff", builtin.find_files, {})
        vim.keymap.set("n", "<Leader>fg", builtin.live_grep, {})
        vim.keymap.set("n", '<Plug>(ff)r', '<Cmd>Telescope find_files<CR>')
        vim.keymap.set("n", '<Plug>(ff)s', '<Cmd>Telescope git_status<CR>')
        vim.keymap.set("n", '<Plug>(ff)b', '<Cmd>Telescope buffers<CR>')
        vim.keymap.set("n", '<Plug>(ff)f', '<Cmd>Telescope live_grep<CR>')
    end
}
