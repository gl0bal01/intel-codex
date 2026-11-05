"""Check [[file#anchor]] wikilinks resolve to a heading in the target file.

Usage: python3 -I tools/wikianchor_check.py ROOT
"""
import os
import re
import sys

root = sys.argv[1]


def slug(h):
    s = re.sub(r"[^\w\- ]", "", h.strip().lower())
    return s.replace(" ", "-")


files = {}
for d, dirs, fs in os.walk(root):
    dirs[:] = [x for x in dirs if not x.startswith(".")]
    for f in fs:
        if f.endswith(".md"):
            files.setdefault(f[:-3], os.path.join(d, f))

heads = {}
def headings(path):
    if path not in heads:
        body = re.sub(r"^(```|~~~).*?^\1", "", open(path).read(), flags=re.M | re.S)
        hs = re.findall(r"^#{1,6} (.+)$", body, re.M)
        heads[path] = {slug(h) for h in hs} | {h.strip().lower() for h in hs}
    return heads[path]

bad = 0
for base, path in sorted(files.items()):
    for n, line in enumerate(open(path), 1):
        for target, anchor in re.findall(r"\[\[([^\]|#]+)#([^\]|]+)", line):
            tbase = os.path.basename(target.strip())
            if tbase not in files:
                continue  # check-vault covers missing files
            if anchor.strip().lower() not in headings(files[tbase]) and slug(anchor) not in headings(files[tbase]):
                bad += 1
                print(f"{os.path.relpath(path, root)}:{n}: [[{target}#{anchor}]]")
print(f"{bad} broken anchor link(s)")
sys.exit(1 if bad else 0)
