"""Check that in-file (#anchor) links resolve to a heading (GitHub/Obsidian slug rules).

Usage: python3 -I tools/anchor_check.py FILE...
"""
import re
import sys


def slug(heading):
    s = heading.strip().lower()
    s = re.sub(r"[^\w\- ]", "", s)
    return s.replace(" ", "-")


broken = 0
for path in sys.argv[1:]:
    text = open(path).read()
    # ignore headings inside fenced blocks
    body = re.sub(r"^(```|~~~).*?^\1", "", text, flags=re.M | re.S)
    heads = {slug(h) for h in re.findall(r"^#{1,6} (.+)$", body, re.M)}
    links = re.findall(r"\]\(#([^)]+)\)", text)
    bad = [link for link in links if link not in heads]
    broken += len(bad)
    print(f"{path.split('/')[-1]}: {len(links)} anchor links, broken: {bad or 'none'}")
sys.exit(1 if broken else 0)
