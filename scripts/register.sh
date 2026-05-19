#!/usr/bin/env bash
# daily-max patch registration script
# called by Claude Code via CLAUDE.md instructions

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INBOX_DIR="${DAILY_MAX_INBOX:-/c/Users/takan/Dropbox/00_artWorks/80_maxMSP/01_daily-max}"
TODAY=$(date +%Y-%m-%d)
DEST="$REPO_DIR/patches/$TODAY"
INDEX="$REPO_DIR/patches/index.json"

echo ""
echo "daily max — patch registration"
echo "───────────────────────────────"
echo ""

# ── 1. find files in inbox ──────────────────────────────────────────
if [ ! -d "$INBOX_DIR" ]; then
  echo "inbox not found: $INBOX_DIR"
  echo "set DAILY_MAX_INBOX or put files in ~/Desktop/max-inbox/"
  exit 1
fi

MAXPAT=$(find "$INBOX_DIR" -maxdepth 1 -name "*.maxpat" | head -1)
SCREENSHOT=$(find "$INBOX_DIR" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | head -1)

if [ -z "$MAXPAT" ]; then
  echo "no .maxpat file found in $INBOX_DIR"
  exit 1
fi

echo "found:"
echo "  patch:      $(basename "$MAXPAT")"
if [ -n "$SCREENSHOT" ]; then
  echo "  screenshot: $(basename "$SCREENSHOT")"
else
  echo "  screenshot: (none)"
fi
echo ""

# ── 2. ask for metadata ─────────────────────────────────────────────
read -p "title: " TITLE
if [ -z "$TITLE" ]; then
  echo "title is required"
  exit 1
fi

read -p "description (1 line): " DESC
read -p "tags (comma-separated, e.g. midi,generative): " TAGS_RAW

# ── 3. copy files ───────────────────────────────────────────────────
mkdir -p "$DEST"

PATCH_FILENAME=$(basename "$MAXPAT")
cp "$MAXPAT" "$DEST/$PATCH_FILENAME"

SCREENSHOT_FILENAME=""
if [ -n "$SCREENSHOT" ]; then
  SCREENSHOT_FILENAME=$(basename "$SCREENSHOT")
  cp "$SCREENSHOT" "$DEST/$SCREENSHOT_FILENAME"
fi

echo ""
echo "copied to patches/$TODAY/"

# ── 4. update index.json ────────────────────────────────────────────
# parse tags into JSON array
TAGS_JSON=$(echo "$TAGS_RAW" | python3 -c "
import sys, json
raw = sys.stdin.read().strip()
tags = [t.strip() for t in raw.split(',') if t.strip()] if raw else []
print(json.dumps(tags))
")

NEW_ENTRY=$(python3 -c "
import json
entry = {
  'date': '$TODAY',
  'title': $(python3 -c "import json,sys; print(json.dumps('$TITLE'))"),
  'desc':  $(python3 -c "import json,sys; print(json.dumps('$DESC'))"),
  'tags':  $TAGS_JSON,
  'file':  $(python3 -c "import json; print(json.dumps('$PATCH_FILENAME'))"),
  'screenshot': $(python3 -c "import json; print(json.dumps('$SCREENSHOT_FILENAME'))")
}
print(json.dumps(entry, ensure_ascii=False))
")

python3 -c "
import json
with open('$INDEX') as f:
    data = json.load(f)
new_entry = $NEW_ENTRY
# remove existing entry for today if re-running
data = [e for e in data if e.get('date') != '$TODAY']
data.append(new_entry)
with open('$INDEX', 'w') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
print('index.json updated ($TODAY added, total:', len(data), 'patches)')
"

# ── 5. git commit & push ─────────────────────────────────────────────
cd "$REPO_DIR"
git add patches/
git commit -m "day $(git rev-list --count HEAD patches/ 2>/dev/null || echo '?'): $TITLE ($TODAY)"
git push

echo ""
echo "✓ done! published: $TITLE"
echo ""

# ── 6. optionally clear inbox ────────────────────────────────────────
read -p "clear inbox? (y/N): " CLEAR
if [[ "$CLEAR" =~ ^[Yy]$ ]]; then
  [ -n "$MAXPAT" ]      && rm "$MAXPAT"
  [ -n "$SCREENSHOT" ]  && rm "$SCREENSHOT"
  echo "inbox cleared"
fi
