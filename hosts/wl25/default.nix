{ pkgs, username, ... }:
{
  home.homeDirectory = "/home/${username}";
  home.packages = with pkgs; [
    libgcc
  ];
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.libgcc}/lib";
  };
}
