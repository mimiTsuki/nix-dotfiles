{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mise
  ];
  home.file = {
    ".config/mise/config.toml".source = ./config.toml;
  };
}
