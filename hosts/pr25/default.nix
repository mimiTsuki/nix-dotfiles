{ username, ... }:
{
  imports = [
    ../../darwin/base
    ../../darwin/home_manager.nix
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";
  nix.enable = false;
  security.pam.services.sudo_local.touchIdAuth = true;
  programs.zsh.enable = true;

  system.defaults = {
    NSGlobalDomain = {
      # マウス/トラックパッド
      "com.apple.swipescrolldirection" = true; # ナチュラルスクロールを有効化
      # キーボード
      NSAutomaticCapitalizationEnabled = false; # 文頭の自動大文字化を無効化
      NSAutomaticPeriodSubstitutionEnabled = false; # ピリオドの自動置換を無効化
      NSAutomaticSpellingCorrectionEnabled = false; # スペル自動修正を無効化
      NSAutomaticDashSubstitutionEnabled = false; # ダッシュの自動置換を無効化
      NSAutomaticQuoteSubstitutionEnabled = false; # クォートの自動置換を無効化
      # UI
      AppleInterfaceStyle = "Dark"; # ダークモードを有効化
      NSWindowResizeTime = 0.001; # ウィンドウのリサイズ速度を高速化
    };
    # Finder
    finder = {
      AppleShowAllExtensions = true; # ファイル拡張子を常に表示
      AppleShowAllFiles = true; # 隠しファイルを表示
      FXDefaultSearchScope = "SCcf"; # 検索範囲をカレントフォルダに設定
      ShowPathbar = true; # パスバーを表示
      FXEnableExtensionChangeWarning = false; # ファイル拡張子変更の警告を無効化
      FXPreferredViewStyle = "Nlsv"; # デフォルトの表示方法をリストビューに設定
    };
    # Dock
    dock = {
      show-process-indicators = true; # 起動中アプリをインジケーターに表示
      show-recents = false; # 最近使ったアプリを非表示
      launchanim = false; # アプリ起動時のアニメーションを無効化
      mineffect = "scale"; # ウィンドウを閉じるときのエフェクトをスケールに設定
    };
    # 画面キャプチャ
    screencapture = {
      target = "clipboard"; # スクリーンショットの保存先をクリップボードに設定
      disable-shadow = true; # スクリーンショットの影を無効化
    };
    # その他
    CustomUserPreferences = {
      NSGlobalDomain = {
        # キーボード
        WebAutomaticSpellingCorrectionEnabled = false; # スペル自動修正を無効化 (WebView)
        # Finder
        AppleMenuBarVisibleInFullscreen = true; # フルスクリーン時にメニューバーを表示
      };
    };
  };
  time.timeZone = "Asia/Tokyo";
}
