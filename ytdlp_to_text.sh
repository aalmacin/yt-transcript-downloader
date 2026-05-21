#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <youtube-url>"
    exit 1
fi

URL="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

yt-dlp --write-auto-sub --sub-lang en --skip-download --convert-subs srt "$URL" -o "$SCRIPT_DIR/%(title)s [%(id)s].%(ext)s"

srt_file=$(ls -t "$SCRIPT_DIR"/*.srt 2>/dev/null | head -n1)
if [[ -z "$srt_file" ]]; then
    echo "Error: no SRT file found"
    exit 1
fi

python3 "$SCRIPT_DIR/srt_to_text.py" "$srt_file"
