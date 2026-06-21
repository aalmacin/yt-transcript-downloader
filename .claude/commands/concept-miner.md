---
description: Mine a YouTube video into a corrected transcript, concept list, and study page under vids/<slug>/
argument-hint: <youtube-url>
---

Use the `concept-miner` skill to process this YouTube URL: $ARGUMENTS

Follow the skill's steps exactly: run `fetch.sh` to get `raw.txt`, then produce
`transcript.txt`, `concepts-mined.csv`, and `index.html` in the output directory.
