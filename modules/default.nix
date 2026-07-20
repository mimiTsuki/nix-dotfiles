{ pkgs, username, herdr, ... }:
{
  home.username = username;
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    git
    nixfmt
    nil
    bat
    eza
    fd
    ffmpeg
    ghq
    git-filter-repo
    git-secrets
    gnupg
    gnused
    jq
    k9s
    libavif
    libwebp
    luajit
    mkcert
    ripgrep
    sqruff
    tree
    tree-sitter
    watch
    wget
    yq-go
  ] ++ [
    herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  home.sessionVariables = {
  };
  programs.home-manager.enable = true;
  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    settings = {
      mgr = {
        show_hidden = true;
      };
    };
  };
  imports = [
    ./claude
    ./gh
    ./git
    ./gitui
    ./hunk
    ./mise
    ./nvim
    ./shell
    ./wezterm
  ];
}
