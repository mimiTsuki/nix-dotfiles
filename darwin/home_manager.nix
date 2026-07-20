{ username, herdr, hunk, ... }:
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit username herdr hunk; };
  home-manager.backupFileExtension = "bak";
  home-manager.users."${username}" = { imports = [ ../modules ./home ]; };
}
