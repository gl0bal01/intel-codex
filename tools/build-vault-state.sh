#!/usr/bin/env bash
# tools/build-vault-state.sh
# Regenerates .omc/vault-state.md from current vault state.
# Composes: filesystem-walked SOP inventory + counts + manual watchlist + manual gaps.
# Run from repo root: ./tools/build-vault-state.sh
#
# Sources of truth:
#   - SOP inventory + counts: filesystem (this script regenerates)
#   - Watchlist tiers + rationale: .omc/watchlist.md (manual)
#   - Capability gaps: .omc/gaps.md (manual)
#   - Conventions, authoring rules, hard rules: CLAUDE.md (project root)
#
# Re-run after adding, moving, or renaming any SOP.

set -euo pipefail
cd "$(dirname "$0")/.."

OUT=".omc/vault-state.md"
WATCHLIST=".omc/watchlist.md"
GAPS=".omc/gaps.md"

count_dir() {
  find "$1" -maxdepth 1 -name 'sop-*.md' -type f 2>/dev/null | wc -l
}

list_dir() {
  local dir="$1"
  find "$dir" -maxdepth 1 -name 'sop-*.md' -type f -printf '%f\n' 2>/dev/null \
    | sort \
    | while read -r f; do
      local base="${f%.md}"
      local title updated
      title=$(awk '/^title:/{sub(/^title:[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}' "$dir/$f")
      updated=$(awk '/^updated:/{sub(/^updated:[[:space:]]*/,""); print; exit}' "$dir/$f")
      [[ -z "$updated" ]] && updated="?"
      [[ -z "$title" ]] && title="(no title)"
      echo "- \`$base\` — $title (updated $updated)"
    done
}

PLATFORMS_DIR="Investigations/Platforms"
TECHNIQUES_DIR="Investigations/Techniques"
ANALYSIS_DIR="Security/Analysis"
PENTEST_DIR="Security/Pentesting"

PLATFORMS_COUNT=$(count_dir "$PLATFORMS_DIR")
TECHNIQUES_COUNT=$(count_dir "$TECHNIQUES_DIR")
ANALYSIS_COUNT=$(count_dir "$ANALYSIS_DIR")
PENTEST_COUNT=$(count_dir "$PENTEST_DIR")

INVESTIGATIONS_COUNT=$((PLATFORMS_COUNT + TECHNIQUES_COUNT))
SECURITY_COUNT=$((ANALYSIS_COUNT + PENTEST_COUNT))
TOTAL=$((INVESTIGATIONS_COUNT + SECURITY_COUNT))

today=$(date +%Y-%m-%d)

cat > "$OUT" <<EOF
---
generated: $today
generator: tools/build-vault-state.sh
---

# Vault State

> **Generated file. Do not edit directly.**
> - SOP inventory + counts: regenerated from the filesystem by \`tools/build-vault-state.sh\`.
> - Watchlist (rotation tiers): authored in \`.omc/watchlist.md\`.
> - Gaps (missing SOPs): authored in \`.omc/gaps.md\`.
> - Conventions, authoring rules, hard rules: \`CLAUDE.md\` (project root).
>
> Re-run \`./tools/build-vault-state.sh\` after adding, moving, or renaming any SOP.
> Run \`./tools/check-vault.sh\` to lint for drift / hygiene issues.

## SOP inventory

### Investigations/Platforms ($PLATFORMS_COUNT SOPs)

$(list_dir "$PLATFORMS_DIR")

### Investigations/Techniques ($TECHNIQUES_COUNT SOPs)

$(list_dir "$TECHNIQUES_DIR")

### Security/Analysis ($ANALYSIS_COUNT SOPs)

$(list_dir "$ANALYSIS_DIR")

### Security/Pentesting ($PENTEST_COUNT SOPs)

$(list_dir "$PENTEST_DIR")

## Counts

| Folder | SOPs |
|--------|------|
| Investigations/Platforms | $PLATFORMS_COUNT |
| Investigations/Techniques | $TECHNIQUES_COUNT |
| Security/Analysis | $ANALYSIS_COUNT |
| Security/Pentesting | $PENTEST_COUNT |
| **Investigations total** | **$INVESTIGATIONS_COUNT** |
| **Security total** | **$SECURITY_COUNT** |
| **Vault total** | **$TOTAL** |

These counts are the source of truth. \`README.md\`, \`index.md\`, and per-folder \`*-Index.md\` files should match.

EOF

if [[ -f "$WATCHLIST" ]]; then
  echo "" >> "$OUT"
  cat "$WATCHLIST" >> "$OUT"
fi

if [[ -f "$GAPS" ]]; then
  echo "" >> "$OUT"
  cat "$GAPS" >> "$OUT"
fi

echo "Wrote $OUT (Total: $TOTAL SOPs)"
