{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
  ];
  home.file = {
    ".config/gh/private_config.yml".source = ./private_config.yml;
  };
}
