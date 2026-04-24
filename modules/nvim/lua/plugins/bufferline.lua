return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup{}

    local map = function(key, cmd)
      vim.keymap.set("n", key, cmd, { noremap = true, silent = true })
    end

    map("<S-h>", "<cmd>BufferLineCyclePrev<CR>")
    map("<S-l>", "<cmd>BufferLineCycleNext<CR>")

    for i = 1, 9 do
      map("<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>")
    end
  end
}
