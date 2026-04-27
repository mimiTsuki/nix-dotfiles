return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').install({
      'go', 'gomod', 'gosum',
      'lua',
      'rust',
      'typescript', 'javascript', 'tsx',
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'go', 'gomod', 'gosum', 'lua', 'rust', 'typescript', 'javascript', 'typescriptreact' },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
