{ ... }:
{
  programs.git = {
    enable = true;
  };
  home.file = {
    ".gitconfig".source = ./.gitconfig;
    ".config/git/ignore".source = ./ignore;
  };
}
