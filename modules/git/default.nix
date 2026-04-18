{ pkgs, username, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      credential.helper = "!${pkgs.gh}/bin/gh auth git-credential";
    };
  };
  home.file = {
    ".gitconfig".text = builtins.replaceStrings [ "@username@" ] [ username ] (builtins.readFile ./.gitconfig);
    ".config/git/ignore".source = ./ignore;
  };
}
