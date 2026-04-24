{ ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    initLua = builtins.readFile ./init.lua;
  };

  home.file = {
    ".config/nvim/after/lsp/lua_ls.lua".source = ./after/lsp/lua_ls.lua;
    ".config/nvim/lua/config/lazy.lua".source = ./lua/config/lazy.lua;
    ".config/nvim/lua/config/lsp.lua".source = ./lua/config/lsp.lua;
    ".config/nvim/lua/plugins/blink.lua".source = ./lua/plugins/blink.lua;
    ".config/nvim/lua/plugins/bufferline.lua".source = ./lua/plugins/bufferline.lua;
    ".config/nvim/lua/plugins/diffview.lua".source = ./lua/plugins/diffview.lua;
    ".config/nvim/lua/plugins/fyler.lua".source = ./lua/plugins/fyler.lua;
    ".config/nvim/lua/plugins/general.lua".source = ./lua/plugins/general.lua;
    ".config/nvim/lua/plugins/gitui.lua".source = ./lua/plugins/gitui.lua;
    ".config/nvim/lua/plugins/hop.lua".source = ./lua/plugins/hop.lua;
    ".config/nvim/lua/plugins/lualine.lua".source = ./lua/plugins/lualine.lua;
    ".config/nvim/lua/plugins/nord.lua".source = ./lua/plugins/nord.lua;
    ".config/nvim/lua/plugins/nvim-lspconfig.lua".source = ./lua/plugins/nvim-lspconfig.lua;
    ".config/nvim/lua/plugins/telescope.lua".source = ./lua/plugins/telescope.lua;
    ".config/nvim/lua/plugins/which-key.lua".source = ./lua/plugins/which-key.lua;
  };
}
