{ pkgs, username, ... }:
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
    tree
    tree-sitter
    watch
    wget
    yq-go
  ];
  home.sessionVariables = {
  };
  programs.home-manager.enable = true;
  imports = [
    ./claude
    ./gh
    ./git
    ./gitui
    ./mise
    ./nvim
    ./shell
    ./wezterm
  ];
}
