{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    docker-compose
    nkf
    podman
    postgresql
    sqlite
    temporal-cli
  ];
}
