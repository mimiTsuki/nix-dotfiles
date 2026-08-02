{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.aeroSpace;

  # 静的設定は config.toml から読み込み、on-window-detected だけ動的に組み立てる
  # (このリポジトリで共有する設定と、ホスト固有のフロート対象アプリ・
  # workspace割り当てを合成するため)
  baseSettings = builtins.removeAttrs (builtins.fromTOML (builtins.readFile ./config.toml)) [
    "on-window-detected"
  ];

  floatingBundleIds = [
    "com.apple.finder"
  ]
  ++ cfg.extraFloatingBundleIds;

  floatingRules = map (bundleId: {
    "if".app-id = bundleId;
    run = "layout floating";
  }) floatingBundleIds;

  workspaceAssignmentRules = map (a: {
    "if".app-id = a.bundleId;
    run = "move-node-to-workspace ${a.workspace}";
  }) cfg.workspaceAssignments;
in
{
  options.aeroSpace.extraFloatingBundleIds = mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = ''
      フルスクリーンボタンを持つためAeroSpaceのダイアログ自動判定では
      フロートにならないが、フロート配置にしたいアプリのbundle ID一覧。
      全ホスト共通ではなく、特定のホストにしか入っていないアプリは
      hosts/<host>/home.nix 側でこのオプションに追加する。
    '';
  };

  options.aeroSpace.workspaceAssignments = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          bundleId = mkOption {
            type = types.str;
            description = "起動時に特定workspaceへ配置したいアプリのbundle ID";
          };
          workspace = mkOption {
            type = types.str;
            description = "配置先のworkspace名";
          };
        };
      }
    );
    default = [ ];
    description = ''
      AeroSpace起動時・新規ウィンドウ検出時に、特定のアプリを特定のworkspaceへ
      自動配置するルール一覧。全ホスト共通ではなく、ホスト固有の配置は
      hosts/<host>/home.nix 側でこのオプションに追加する。
    '';
  };

  config.programs.aerospace = {
    enable = true;
    # config.toml の start-at-login = true と対にするため、
    # 起動管理をHome Managerに任せる設定を有効化する
    launchd.enable = true;
    settings = baseSettings // {
      on-window-detected = floatingRules ++ workspaceAssignmentRules;
    };
  };
}
