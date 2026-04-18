# Dotfiles

## 導入

### Nix のインストール

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install
```

### リポジトリのクローン

nix shell を利用してリポジトリをクローンします。

```sh
nix shell nixpkgs#git
git clone https://github.com/mimiTsuki/nix-dotfiles {リポジトリを配置したいパス}
exit
```

以降の手順はカレントディレクトリ = リポジトリルートの前提で説明します。

## ビルド・インストール

### macOS

```sh
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#{プロファイル} --impure
```

プロファイル一覧:

| プロファイル | 説明 |
| ------------ | ---- |
| `ap25`       |      |
| `pr25`       |      |

#### Homebrewのインストール

Homebrew公式の手順に従ってインストールする。

https://brew.sh/ja/

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Brewfileからのインストール

nix-darwin の適用後、`~/Brewfile` が生成されるので、以下のコマンドでインストールする。

```sh
brew bundle
```

### WSL2

```sh
nix run home-manager/master -- switch --flake .#wl25 --impure
```

> [!NOTE]
> `hosts/wsl/default.nix` の `system` は `x86_64-linux` で固定されています。ARM環境の場合は `aarch64-linux` に変更してください。

### zsh

`~/zsh/local.zsh` を作成することで、ホストマシン固有の設定を適用できます。
秘匿性の高い内容や、Nix 管理外のアプリケーション向けの設定などはこのファイルに記載してください。

#### WSL2 でのログインシェル変更

Home Manager はログインシェルの変更を行わないため、WSL2 では手動で設定する必要があります。

```sh
# /etc/shells に Nix の zsh を追加
echo $(which zsh) | sudo tee -a /etc/shells

# ログインシェルを zsh に変更
chsh -s $(which zsh)
```

変更はターミナルを再起動すると反映されます。

## 備考

未使用パッケージをディスクから削除するには:

```sh
nix store gc
```
