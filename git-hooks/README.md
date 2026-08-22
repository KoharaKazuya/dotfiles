# git-hooks

`core.hooksPath` 経由で全リポジトリに適用されるグローバルフック。

## 設計方針

過去にこのディレクトリは 10 個のチェックを抱えていたが、性質の異なる要求を
1 つの仕組みに載せていたため、片方の都合がもう片方を壊していた。
現在は「どこでも効かせたい安全網」だけをここに置き、残りは本来の層へ移した。

| 種別 | 置き場所 |
| --- | --- |
| git 拡張の配線 (git-lfs) | 各リポジトリ (`git lfs install`) |
| どこでも効かせたい安全網 | **ここ** |
| プロジェクト規約 (Conventional Commits) | CI |
| 作業リマインダ (TODO, npm install) | linter / エディタ / direnv |

## チェック一覧

| フック | チェック | 挙動 |
| --- | --- | --- |
| `pre-commit` | `unicode` | Trojan Source 対策。BLOCK でコミットを止める |
| `pre-commit` | `gitleaks` | 秘匿情報の検出。gitleaks がある場合のみ |
| `post-merge` | `unicode` | 取り込んだ差分の検査。事後なので警告のみ |

## Trojan Source 対策

Trojan Source (CVE-2021-42574 / CVE-2021-42694) の主たる経路は
「自分が書く」ことではなく「**他人のコードを取り込む・レビューする**」ことなので、
`pre-commit` だけでなく `post-merge` でも検査する。

検査は `bin/git-scan-unicode` が行う。コア Perl のみに依存し、
Node などの外部ランタイムを必要としない (フックから呼ぶため可用性が最優先)。

```sh
git scan-unicode --staged           # コミット前
git scan-unicode ORIG_HEAD..HEAD    # 取り込んだ差分
git scan-unicode main..feature      # レビュー時
```

`post-merge` は事後なので止められない。**強制力は CI に置いている**
(`.github/workflows/test.yml` の `trojan-source` ジョブ)。
ローカルフックは早期警告と位置づける。

多層防御として、以下の既存の仕組みも併用するとよい。

- rustc: `text_direction_codepoint_in_literal` / `_in_comment` (deny by default)
- GCC 12+: `-Wbidi-chars=`
- ESLint: `eslint-plugin-anti-trojan-source`
- VS Code: `editor.unicodeHighlight.*` (既定で有効)
- GitHub: 双方向テキストを含む差分に警告バナーを表示する

## チェックを無効化する

チェックごとに `GIT_HOOKS_IGNORE_<チェック名>` を定義する。

```sh
GIT_HOOKS_IGNORE_UNICODE=1 git commit ...
GIT_HOOKS_IGNORE_GITLEAKS=1 git commit ...
```

全部まとめて飛ばすなら `git commit --no-verify`。

## チェックを追加する

`<フック名>.d/` に `*.sh` を置く。`base.sh` がサブシェルで読み込む。
非ゼロで終了すればそのフックは失敗する。

マシン固有のチェックは `~/.config/git/hooks/<フック名>.d/*.sh` に置く
(このリポジトリには入らない)。

利用できる関数は `base.sh` を参照。`info` / `warn` / `error` /
`show_ignore_variable` / `changed_files_by_commit` / `changed_files_by_merge`。

## リポジトリ固有のフック

`core.hooksPath` を設定すると git は `.git/hooks` を完全に無視する。
その代替として、`base.sh` は同名のリポジトリ固有フックがあれば実行する。
ただし救済できるのはこのディレクトリに存在するフック名だけなので、
`post-rewrite` などをリポジトリ側が入れている場合は動かない。

## 制約

POSIX sh (dash) で動くこと。`/bin/sh` は Debian/Ubuntu では dash であり、
`builtin` や `local` のような bash/zsh 専用の構文は使えない。
かつてこの制約を破っていたために、git-lfs と git-secrets の
ラッパーが Debian 系で無言で no-op になっていた。

## テスト

```sh
sh git-hooks/test.sh
```

CI でも実行される。挙動を変えたらテストも更新すること。
