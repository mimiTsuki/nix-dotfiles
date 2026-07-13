---
allowed-tools: Bash, Read, Glob
description: NeoVimのキー入力ログをRust製の集計ツールでダイジェスト化し、操作習慣の改善点をレビューする
---

## コンテキスト

- キーロガー本体: `modules/nvim/lua/config/keylog.lua`（ログは `~/.local/state/nvim/keylog/keylog-YYYY-MM-DD.jsonl` に日次で出力される）
- 集計ツール: `tools/keylog-report`（Rust製 CLI。Rustバージョンはこのディレクトリの `mise.toml` でピン留めされている）
- 既存のキーマップ・プラグイン設定: `modules/nvim/init.lua`, `modules/nvim/lua/plugins/*.lua`（`jj`→`<Esc>`、hop `<leader>s`、quick-scope、telescope `<Leader>ff`/`<Leader>fg` など）

引数: $ARGUMENTS （ログファイルのパスが渡されればそれを使う。空なら `~/.local/state/nvim/keylog/` 配下の最新ファイルを使う）

## タスク

1. 対象ログファイルを決定する。`$ARGUMENTS` が空でなければそれをパスとして使い、空なら `~/.local/state/nvim/keylog/keylog-*.jsonl` の中で最終更新日時が最新のものを選ぶ。
2. `tools/keylog-report/target/release/keylog-report <file>` を実行してダイジェストを取得する。バイナリが存在しなければ先に `cd tools/keylog-report && cargo build --release` でビルドしてから実行する(mise がこのディレクトリの Rust バージョンを自動解決する)。
3. **生の JSONL ログファイルを `cat`/`Read` 等で直接開かない。** ダイジェスト出力だけを分析の根拠にすること。ダイジェストに含まれていない観点を確認したくなった場合は、生ログを読むのではなく `tools/keylog-report/src/main.rs` に集計・検出ロジックを追加することを提案する(その場で実装してよい)。
4. ダイジェストを踏まえて、具体的な改善提案を **優先度順** にまとめる。各提案は「現状の癖 → 推奨操作 → 理由」の形式で書く。既存のキーマップ・プラグイン(上記コンテキスト参照)で解決できるものは、新しい設定を提案するより先にそれを活かす形にする。
5. 提案は日本語で、簡潔に。良い癖(既に効率的に使えている操作)があれば軽く触れてもよいが、メインは改善点。
