#!/usr/bin/env python3
from pathlib import Path

HERE = Path(__file__).parent
SRC = HERE / "settings.local.json"
DST = HERE / "settings.json"
KEY = '"ssh_connections"'


def strip_block(text: str, key: str) -> str:
    """Remove `"<key>": [ ... ],` plus its leading indent and trailing newline."""
    if key not in text:
        return text

    start = text.index(key)
    j = text.index("[", start)

    # bracket-count to the matching ], skipping over string contents
    depth = 0
    while True:
        c = text[j]
        if c == '"':
            j += 1
            while text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            j += 1
            continue
        if c == "[":
            depth += 1
        elif c == "]":
            depth -= 1
            if depth == 0:
                j += 1
                break
        j += 1

    # eat trailing `,` + spaces + newline so the surrounding lines stay clean
    if j < len(text) and text[j] == ",":
        j += 1
    while j < len(text) and text[j] in " \t":
        j += 1
    if j < len(text) and text[j] == "\n":
        j += 1

    # rewind start over the leading indent of the line
    while start > 0 and text[start - 1] in " \t":
        start -= 1

    return text[:start] + text[j:]


def main() -> None:
    text = SRC.read_text()
    DST.write_text(strip_block(text, KEY))
    print(f"wrote {DST}")


if __name__ == "__main__":
    main()
