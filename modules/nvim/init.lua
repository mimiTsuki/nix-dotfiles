vim.keymap.set("i", "jj", "<esc>", { noremap = true, silent = true })


vim.scriptencoding = "utf-8"
vim.wo.number = true
vim.g.mapleader = " "

local options = {
    encoding = "utf-8",
    fileencoding = "utf-8",
    mouse = "",
    title = true,
    backup = false,
    clipboard = "unnamedplus",
    cmdheight = 2,
    swapfile = false,
    number = true,
    relativenumber = true,
    autoindent = true,
    expandtab = true,
    tabstop = 2,
    shiftwidth = 2,
    writebackup = false,
    updatetime = 300,
    signcolumn = "yes",
    cursorline = true,
    list = true,
    listchars = { tab = "»·", nbsp = "·", space = "·" },
    termguicolors = true,
    winblend = 0,
    pumblend = 0,
    completeopt = {
        "fuzzy",
        "popup",
        "menuone",
        "noinsert",
      }
}

vim.opt.shortmess:append("c")
vim.opt.nrformats:append("")

for k, v in pairs(options) do
    vim.opt[k] = v
end

require("config.lazy")
require("config.lsp")

local function get_relative_path()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    local root = clients[1].config.root_dir
    local abs = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(abs, ':~:.'):gsub('^' .. vim.pesc(root) .. '/', '')
  end
  return vim.fn.expand('%:.')
end

vim.keymap.set("n", "<S-p>", function()
  local path = get_relative_path()
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "Copy relative path to clipboard" })

-- QuickScope
vim.cmd 'highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline'
vim.cmd 'highlight QuickScopeSecondary guifg=#5fffff gui=underline ctermfg=81 cterm=underline'
