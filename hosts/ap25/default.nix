{ username, ... }:
{
  imports = [
    ../../darwin/base
    ../../darwin/home_manager.nix
  ];
  home-manager.users.${username}.imports = [ ./home.nix ];
}
