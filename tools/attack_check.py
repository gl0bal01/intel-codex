"""Check every ATT&CK technique/tactic ID cited in the vault against the official STIX bundle.

Usage: python3 -I tools/attack_check.py <enterprise-attack.json> <vault-root>
Get the bundle: curl -sL -o enterprise-attack.json https://raw.githubusercontent.com/mitre-attack/attack-stix-data/master/enterprise-attack/enterprise-attack.json
"""
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

bundle, root = Path(sys.argv[1]), Path(sys.argv[2])
objs = json.loads(bundle.read_text())["objects"]


def ext_id(o):
    for r in o.get("external_references", []):
        if r.get("source_name") == "mitre-attack":
            return r.get("external_id")


by_stix, by_id = {}, {}
for o in objs:
    if o.get("type") in ("attack-pattern", "x-mitre-tactic"):
        eid = ext_id(o)
        if eid:
            by_stix[o["id"]] = eid
            # several objects can share an ID (revoked + live); keep the live one
            if eid not in by_id or not (o.get("revoked") or o.get("x_mitre_deprecated")):
                by_id[eid] = o
    if o.get("type") == "x-mitre-collection":
        print("ATT&CK bundle version:", o.get("x_mitre_version"), o.get("modified"))

revoked_by = {}
for o in objs:
    if o.get("type") == "relationship" and o.get("relationship_type") == "revoked-by":
        src, tgt = by_stix.get(o["source_ref"]), by_stix.get(o["target_ref"])
        if src and tgt:
            revoked_by[src] = tgt

tactic_names = {o["x_mitre_shortname"]: ext_id(o) + " " + o["name"]
                for o in objs if o.get("type") == "x-mitre-tactic" and not o.get("revoked")}

cites = defaultdict(set)
for f in list(root.glob("Investigations/**/*.md")) + list(root.glob("Security/**/*.md")) + list(root.glob("Cases/**/*.md")):
    for n, line in enumerate(f.read_text(errors="replace").splitlines(), 1):
        for m in re.finditer(r"\b(T[A]?\d{4}(?:\.\d{3})?)\b", line):
            cites[m.group(1)].add(f"{f.relative_to(root)}:{n}")

problems = 0
for eid in sorted(cites):
    o = by_id.get(eid)
    where = sorted(cites[eid])
    if o is None:
        status = "NOT IN ATT&CK"
    elif o.get("revoked"):
        status = f"REVOKED -> {revoked_by.get(eid, '?')} {by_id.get(revoked_by.get(eid, ''), {}).get('name', '')}"
    elif o.get("x_mitre_deprecated"):
        status = "DEPRECATED"
    else:
        continue
    problems += 1
    print(f"{eid}: {status}\n    " + "\n    ".join(where))

print(f"\n{len(cites)} distinct IDs cited; {problems} need attention")
print("Live tactics:", ", ".join(sorted(tactic_names.values())))
