#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <youtube-url>" >&2
    exit 1
fi

URL="$1"
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"

title="$(yt-dlp --print "%(title)s" --skip-download "$URL")"
if [[ -z "$title" ]]; then
    echo "Error: could not resolve video title" >&2
    exit 1
fi

slug="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
if [[ -z "$slug" ]]; then
    echo "Error: could not build slug from title: $title" >&2
    exit 1
fi

dir="$REPO_ROOT/vids/$slug"
mkdir -p "$dir"

yt-dlp --write-auto-sub --sub-lang en --skip-download --convert-subs srt "$URL" -o "$dir/subs.%(ext)s"

srt_file="$(ls -t "$dir"/*.srt 2>/dev/null | head -n1)"
if [[ -z "$srt_file" ]]; then
    echo "Error: no SRT produced (subtitles may be disabled for this video)" >&2
    exit 1
fi

python3 "$REPO_ROOT/srt_to_text.py" "$srt_file" "$dir/raw.txt"
rm -f "$dir"/*.srt

echo "$dir"
