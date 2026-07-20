{
  description = "Home Manager configuration of mimitsuki";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr.url = "github:ogulcancelik/herdr/v0.7.1";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      herdr,
      hunk,
      ...
    }:
    let
      sudoUser = builtins.getEnv "SUDO_USER";
      rawUsername = if sudoUser != "" then sudoUser else builtins.getEnv "LOGNAME";
      username = if rawUsername == "" then throw "環境変数 LOGNAME が設定されていません。" else rawUsername;
      makeDarwinSystem =
        { username, host }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit self;
            inherit username;
            inherit herdr;
            inherit hunk;
          };
          modules = [
            ./hosts/${host}
            home-manager.darwinModules.home-manager
          ];
        };
      makeHomeConfig =
        { username, system, host }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "zsh-abbr" ];
          };
          extraSpecialArgs = { inherit username herdr hunk; };
          modules = [ ./modules ./hosts/${host} ];
        };
    in
    {
      darwinConfigurations = {
        pr25 = makeDarwinSystem {
          username = username;
          host = "pr25";
        };
        ap25 = makeDarwinSystem {
          username = username;
          host = "ap25";
        };
      };
      homeConfigurations = {
        "wl25" = makeHomeConfig {
          username = username;
          system = "x86_64-linux";
          host = "wl25";
        };
      };
      modules = [ ./modules ];
    };

}
