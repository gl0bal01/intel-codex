"""Syntax-check fenced code blocks in Markdown files.

bash/sh/shell blocks -> `bash -n`; python blocks -> compile(). Syntax only:
placeholders and undefined names are not resolved. Untagged fences are flagged
(the vault convention is language-tagged fences).

Usage: python3 -I tools/code_block_check.py FILE...
"""
import re
import subprocess
import sys

OPEN = re.compile(r"^(\s*)(`{3,}|~{3,})\s*([\w+-]*)")
SHELL = {"bash", "sh", "shell"}
bad = 0
for path in sys.argv[1:]:
    lines = open(path).read().splitlines()
    i = 0
    while i < len(lines):
        m = OPEN.match(lines[i])
        if not m:
            i += 1
            continue
        indent, tok, lang = m.groups()
        start = i + 1
        close = re.compile(rf"^\s*{re.escape(tok)}\s*$")
        i += 1
        body = []
        while i < len(lines) and not close.match(lines[i]):
            body.append(lines[i][len(indent):] if lines[i].startswith(indent) else lines[i])
            i += 1
        i += 1  # skip closing fence
        src = "\n".join(body) + "\n"
        where = f"{path}:{start}"
        if not lang:
            bad += 1
            print(f"{where}: untagged fence")
        elif lang in SHELL:
            r = subprocess.run(["bash", "-n"], input=src, text=True, capture_output=True)
            if r.returncode:
                bad += 1
                print(f"{where}: bash -n: {r.stderr.strip()}")
        elif lang == "python":
            try:
                compile(src, where, "exec")
            except SyntaxError as e:
                bad += 1
                print(f"{where}: python: {e.msg} (block line {e.lineno})")
print(f"{bad} issue(s)")
sys.exit(1 if bad else 0)
