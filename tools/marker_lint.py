"""Lint SOPs for [verify YYYY-MM-DD] marker placement and unclosed fences.

Flags: more than one marker on a line, a marker in front matter, on a heading,
in a table header row, or on a code line inside a fence. Inside a fence a marker may only sit in a
comment (#, //, ;, --); otherwise copy-pasting the command breaks it.

Usage: python3 -I tools/marker_lint.py FILE...
"""
import re
import sys

MARK = re.compile(r"\[verify \d{4}-\d{2}-\d{2}[^\]]*\]")
COMMENT = ("#", "//", ";", "--", "/*", "*", "<!--")
TABLE_RULE = re.compile(r"^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$")
bad = 0
for path in sys.argv[1:]:
    lines = open(path).read().splitlines()
    fm_end = lines.index("---", 1) if lines and lines[0] == "---" else -1
    fence = None
    fences = 0
    for n, line in enumerate(lines, 1):
        s = line.lstrip()
        m = re.match(r"(`{3,}|~{3,})", s)
        if m:
            fences += 1
            tok = m.group(1)[0] * 3
            fence = None if fence == tok else (fence or tok)
            continue
        issues = []
        if len(MARK.findall(line)) > 1:
            issues.append("multiple markers")
        if n <= fm_end + 1 and MARK.search(line):
            issues.append("marker in front matter")
        if fence is None and re.match(r"#{1,6} ", line) and MARK.search(line):
            issues.append("marker in heading")
        if fence is not None and MARK.search(line) and not s.startswith(COMMENT):
            issues.append("marker on a code line inside a fence")
        if fence is None and "|" in line and TABLE_RULE.match(line) and n >= 2 and MARK.search(lines[n - 2]):
            bad += 1
            print(f"{path}:{n - 1}: marker in table header row: {lines[n - 2][:100]}")
        for i in issues:
            bad += 1
            print(f"{path}:{n}: {i}: {line[:100]}")
    if fence:
        bad += 1
        print(f"{path}: unclosed {fence} fence at EOF ({fences} fence lines)")
print(f"{bad} issue(s)")
sys.exit(1 if bad else 0)
