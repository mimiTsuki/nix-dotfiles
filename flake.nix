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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      usernameFile = ./.username;
      rawUsername =
        if builtins.pathExists usernameFile then
          builtins.replaceStrings [ "\n" "\r" " " ] [ "" "" "" ] (builtins.readFile usernameFile)
        else
          throw ".username ファイルが見つかりません。.username.sample を参考に .username を作成してください。";
      username = if rawUsername == "" then throw ".username ファイルが空です。ユーザー名を記入してください。" else rawUsername;
      makeDarwinSystem =
        { username, host }:
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit self;
            inherit username;
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
          extraSpecialArgs = { inherit username; };
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
        "${username}" = makeHomeConfig {
          username = username;
          system = "x86_64-linux";
          host = "wsl";
        };
      };
      modules = [ ./modules ];
    };

}
