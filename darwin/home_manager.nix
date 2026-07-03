{ username, herdr, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit username herdr; };
  home-manager.backupFileExtension = "bak";
  home-manager.users."${username}" = { imports = [ ../modules ./home ]; };
}
