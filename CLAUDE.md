# daily-max

Max/MSP daily patch log. GitHub Pages site at `index.html`.

## project structure

```
daily-max/
├── index.html          ← GitHub Pages サイト本体
├── patches/
│   ├── index.json      ← パッチ一覧（このファイルを編集する）
│   └── YYYY-MM-DD/
│       ├── patch.maxpat
│       └── screenshot.png
└── scripts/
    └── register.sh     ← 登録スクリプト
```

## inbox (ファイルの置き場所)

デフォルト: `~/Desktop/max-inbox/`
変更したい場合は環境変数で指定: `export DAILY_MAX_INBOX=~/path/to/folder`

毎日ここに `.maxpat` とスクショ（PNG or JPG）を置いておく。

## 毎日の登録方法

ユーザーが「今日のパッチを登録して」「今日のpatchを追加して」などと言ったら：

1. `scripts/register.sh` を実行する
2. スクリプトがタイトル・説明・タグを対話的に聞く
3. ファイルのコピー、index.json の更新、git commit & push を自動でやる

```bash
bash scripts/register.sh
```

## index.json の形式

```json
[
  {
    "date": "2026-05-19",
    "title": "random melody gen",
    "desc": "metro + random + makenoteでシンプルなメロディ生成",
    "tags": ["midi", "generative"],
    "file": "patch.maxpat",
    "screenshot": "screenshot.png"
  }
]
```

- `date`: YYYY-MM-DD（同じ日に再実行すると上書き）
- `screenshot`: 省略可（スクショなしでも登録できる）

## git / GitHub Pages

- `main` ブランチに push すれば GitHub Pages が自動でデプロイ
- GitHub Pages の設定: Settings → Pages → Source: main / (root)

## よくある操作

| やりたいこと | コマンド |
|---|---|
| 今日のパッチを登録 | `bash scripts/register.sh` |
| 過去のパッチを手動で編集 | `patches/index.json` を直接編集して `git push` |
| ローカルで確認 | `npx serve .` でlocalhost確認 |
