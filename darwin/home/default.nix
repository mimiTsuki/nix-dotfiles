{ pkgs, ... }:
{
  imports = [ ./hammerspoon ./homebrew ./karabiner ./shell.nix ];
  home.packages = with pkgs; [
    pinentry_mac
  ];
}
