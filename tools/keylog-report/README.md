# keylog-report

NeoVimのキー入力ログ(`~/.local/state/nvim/keylog/keylog-YYYY-MM-DD.jsonl`)をダイジェスト化するRust製CLI。

## セットアップ(mise)

このディレクトリの `mise.toml` でRustバージョンがピン留めされているので、`tools/keylog-report` 配下では自動でそのバージョンが使われる。

```sh
cd tools/keylog-report
mise trust   # 初回のみ
mise install
```

## ビルド・実行

```sh
cargo build --release
./target/release/keylog-report ~/.local/state/nvim/keylog/keylog-YYYY-MM-DD.jsonl
```
