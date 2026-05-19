# daily max

Max/MSP patches, one per day.

## setup

```bash
git clone https://github.com/YOUR_USERNAME/daily-max
cd daily-max
```

GitHub Pages: Settings → Pages → Source: `main` / `(root)`

## daily workflow

1. Make a patch in Max/MSP
2. Take a screenshot
3. Drop both files into `~/Desktop/max-inbox/`
4. Run: `bash scripts/register.sh`

Or with Claude Code:
```bash
claude "今日のパッチを登録して"
```

## inbox location

Default: `~/Desktop/max-inbox/`

To change:
```bash
export DAILY_MAX_INBOX=~/your/folder
```
