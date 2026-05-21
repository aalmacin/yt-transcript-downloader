import re
import sys
from pathlib import Path


def srt_to_text(input_path: str) -> str:
    with open(input_path, "r", encoding="utf-8") as f:
        content = f.read()

    blocks = re.split(r"\n\n+", content.strip())

    all_lines = []
    for block in blocks:
        lines = block.strip().split("\n")
        if len(lines) < 2:
            continue
        for line in lines[2:]:
            stripped = line.strip()
            if stripped:
                all_lines.append(stripped)

    # Remove consecutive duplicates from rolling 2-line subtitle format
    deduped = []
    prev = None
    for line in all_lines:
        if line != prev:
            deduped.append(line)
            prev = line

    return " ".join(deduped)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python srt_to_text.py <input.srt> [output.txt]")
        sys.exit(1)

    input_path = sys.argv[1]
    if len(sys.argv) > 2:
        output_path = sys.argv[2]
    else:
        stem = Path(input_path).stem
        stem = re.sub(r"[^\w\s-]", "", stem)
        stem = re.sub(r"\s+", "-", stem).strip("-")
        stem = re.sub(r"-+", "-", stem)

        kebab_srt = Path(input_path).with_name(stem + ".srt")
        if Path(input_path) != kebab_srt:
            Path(input_path).rename(kebab_srt)
            input_path = str(kebab_srt)

        output_path = Path(input_path).with_name(stem + ".txt")

    text = srt_to_text(input_path)

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(text)
        f.write("\n")

    print(f"Written to {output_path}")
