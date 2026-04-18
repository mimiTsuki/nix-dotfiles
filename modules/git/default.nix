{ pkgs, username, ... }:
{
  programs.git = {
    enable = true;
  };
  home.file = {
    ".gitconfig".text = builtins.replaceStrings [ "@username@" ] [ username ] (builtins.readFile ./.gitconfig);
    ".config/git/ignore".source = ./ignore;
  };
}
