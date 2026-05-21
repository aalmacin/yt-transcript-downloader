# ytdlp-to-text

Downloads auto-generated subtitles from a YouTube video and converts them to a clean plain-text transcript. Output files are named in kebab-case.

## Requirements

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — `brew install yt-dlp`
- Python 3

## Usage

```bash
./ytdlp_to_text.sh <youtube-url>
```

**Example:**

```bash
./ytdlp_to_text.sh https://www.youtube.com/watch?v=O1cRJWYF-g4
```

This produces two files in the script's directory:

- `video-title-id.srt` — the raw subtitle file
- `video-title-id.txt` — the cleaned transcript

## Alias setup (zsh)

Add an alias so you can run `yt2txt` from anywhere.

1. Open `~/.zshrc` in your editor.
2. Add this line, replacing the path with the actual location of the script:

```zsh
alias yt2txt="/path/to/ytdlp_to_text.sh"
```

**Example:**

```zsh
alias yt2txt="$HOME/Projects/ytdlp/ytdlp_to_text.sh"
```

3. Reload your shell:

```bash
source ~/.zshrc
```

4. Now you can run it from any directory:

```bash
yt2txt https://www.youtube.com/watch?v=O1cRJWYF-g4
```
