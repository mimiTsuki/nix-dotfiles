{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  xdg.configFile."hunk/config.toml".source = tomlFormat.generate "hunk-config.toml" {
    theme = "catppuccin-mocha";
    watch = true;
    line_number = true;
  };
}
