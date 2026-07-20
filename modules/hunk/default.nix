{ hunk, ... }:
{
  imports = [
    hunk.homeManagerModules.default
  ];

  programs.hunk = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      watch = true;
      line_number = true;
    };
  };
}
