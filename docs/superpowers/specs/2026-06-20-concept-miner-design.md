# Concept-Miner — Design

## Purpose

Extend the existing YouTube subtitle→text pipeline into a study tool. Given a
YouTube URL, download the transcript, correct it, mine the key concepts, and
produce a self-contained study page — all stored under `vids/<slug>/`.

Invoked as a Claude Code slash command: `/concept-miner <youtube-url>`.

## Components

### 1. `.claude/skills/concept-miner/fetch.sh`

Mechanical fetch (no LLM work). Responsibilities:

1. Validate a single URL argument (`set -euo pipefail`).
2. Resolve repo root (the script lives at `.claude/skills/concept-miner/`).
3. `yt-dlp --print "%(title)s" --skip-download "$URL"` to get the title.
4. Build a lowercase kebab-case slug from the title.
5. `mkdir -p vids/<slug>/`.
6. `yt-dlp --write-auto-sub --sub-lang en --skip-download --convert-subs srt`
   downloading into `vids/<slug>/`.
7. Run `srt_to_text.py <srt> vids/<slug>/raw.txt` (dedup + strip timestamps).
8. Remove the temporary `.srt`.
9. Print the absolute path of `vids/<slug>/` to stdout (so Claude knows where
   to work).

Errors clearly if no SRT is produced (e.g. subtitles disabled on the video).

### 2. `.claude/skills/concept-miner/SKILL.md`

Instructs Claude on the LLM steps that run after `fetch.sh`:

- Run `fetch.sh` with the URL, capture the output directory.
- Read `raw.txt`.
- Write `transcript.txt`, `concepts-mined.csv`, `index.html` into that directory.

Includes the exact rules for each output (below).

### 3. `.claude/commands/concept-miner.md`

Slash command `/concept-miner <youtube-url>` that invokes the concept-miner
skill, passing the URL through.

## Data Flow

```
URL → fetch.sh → vids/<slug>/raw.txt → (Claude reads) → transcript.txt
                                                       → concepts-mined.csv
                                                       → index.html
```

## Output Files (in `vids/<slug>/`)

### raw.txt
Verbatim cleaned subtitle text produced by `srt_to_text.py`: consecutive
duplicates removed, timestamps stripped, joined into one block. No LLM edits.

### transcript.txt
The same spoken words in the same order as `raw.txt`, corrected:

- Fix mis-transcribed terms (e.g. `PostgreQL` → `PostgreSQL`).
- Add proper punctuation and capitalization.
- Break the wall of text into natural paragraphs for readability.
- **No** section headings, **no** summarizing, **no** rewriting into an article.
  It must remain a faithful transcript.

### concepts-mined.csv
- Header row: `concept,definition`
- One row per concept/term worth researching individually.
- Sorted by importance to the video's topic — most important first.
- Definitions are concise, written from Claude's knowledge.
- Proper CSV quoting (quote fields containing commas/quotes; escape `"` as `""`).

### index.html
Self-contained, styled (inline CSS) study page containing:

- Video title (`<h1>`)
- "Watch on YouTube" link
- Overview — short prose summary of what the video covers
- Key takeaways — bulleted list
- Key Concepts — table rendered from the mined concepts (concept + definition)
- Links to `raw.txt`, `transcript.txt`, `concepts-mined.csv`

## Git Tracking

`.gitignore` currently ignores `*.txt` and `*.srt`, which would make
`vids/*/raw.txt` and `transcript.txt` untrackable. Add a `!vids/` exception (and
the directory itself) so mined output can be committed. Claude does not commit
anything automatically (per project convention).

## Error Handling

- `fetch.sh`: `set -euo pipefail`, validates the URL argument, and exits with a
  clear message if no SRT is produced.
- The skill checks that `raw.txt` exists and is non-empty before the LLM steps.

## Out of Scope (YAGNI)

- Non-English subtitles / language selection.
- Manual-subtitle vs auto-subtitle preference handling.
- Batch processing of multiple URLs.
- Re-running / updating an already-mined video (just overwrite).
