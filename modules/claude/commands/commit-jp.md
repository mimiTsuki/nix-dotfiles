---
allowed-tools: Bash(git status:*), Bash(git commit:*)
description: Create a git commit with a one-liner Japanese message
---

## コンテキスト

- 現在のgitステータス: !`git status`
- 現在のgit差分（ステージ済み・未ステージ含む）: !`git diff HEAD`
- 現在のブランチ: !`git branch --show-current`
- 直近のコミット: !`git log --oneline -10`

## タスク

上記の変更内容に基づいて、コミットを1つ作成してください。

**コミットメッセージのルール（厳守）:**
- 1行のみ（本文・空行・箇条書き不可）
- 全て日本語で記述すること
- フォーマット: `<種別>: <変更内容の要約>`
  - 種別の例: `feat`, `fix`, `refactor`, `chore`, `docs`, `style`, `test`
- 簡潔にまとめること（合計72文字以内）

1回のレスポンスで複数のツールを呼び出すことができます。他のツールの使用や追加の操作は行わないでください。ツール呼び出し以外のテキストやメッセージは送信しないでください。
