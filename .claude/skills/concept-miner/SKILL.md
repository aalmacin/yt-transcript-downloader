---
name: concept-miner
description: Use when given a YouTube URL to mine for study. Downloads the transcript, corrects it, extracts key concepts, and builds a study page under vids/<slug>/.
---

# Concept Miner

Turn a YouTube video into study material: a corrected transcript, a ranked list
of mined concepts, and a self-contained study page.

## Steps

### 1. Fetch the raw transcript

Run the fetch script with the URL. It downloads English auto-subs, cleans them
(dedup + timestamps stripped), and writes `raw.txt`. It prints the output
directory — capture it.

```bash
.claude/skills/concept-miner/fetch.sh "<youtube-url>"
```

Let `DIR` be the printed path (e.g. `vids/<slug>`). Confirm `DIR/raw.txt` exists
and is non-empty before continuing.

### 2. Write `DIR/transcript.txt`

A faithful, corrected transcript — same spoken words in the same order as
`raw.txt`, with:

- Mis-transcribed terms fixed (e.g. `PostgreQL` → `PostgreSQL`, `node js` →
  `Node.js`).
- Proper punctuation and capitalization.
- Natural paragraph breaks for readability.

Do **not** add section headings, do **not** summarize, do **not** rewrite into
an article. It must stay a transcript.

### 3. Write `DIR/concepts-mined.csv`

CSV of terms and concepts from the video worth researching individually.

- First line is exactly: `concept,definition`
- One row per concept; definition is concise, from your own knowledge.
- Sort by importance to the video's topic — most important first.
- Quote any field containing a comma, quote, or newline; escape `"` as `""`.

### 4. Write `DIR/index.html`

A self-contained study page (inline CSS, no external assets) containing:

- The video title as `<h1>`.
- A "Watch on YouTube" link to the original URL.
- **Overview** — a short prose summary of what the video covers.
- **Key takeaways** — a bulleted list.
- **Key Concepts** — a table built from `concepts-mined.csv` (concept,
  definition).
- Links to `raw.txt`, `transcript.txt`, and `concepts-mined.csv` (relative).

### 5. Report

Tell the user the slug and list the four files created under `DIR/`.
