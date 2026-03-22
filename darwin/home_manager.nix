{ username, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit username; };
  home-manager.users."${username}" = { imports = [ ../modules ./home ]; };
}
