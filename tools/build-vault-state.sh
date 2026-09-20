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

# Keep the README badge line honest: rewrite the marked block in place so the
# published count can never drift from the filesystem. No markers, no rewrite.
README="README.md"
if [[ -f "$README" ]] && grep -q '<!-- vault-state:begin' "$README"; then
  COUNT_LINE="**$TOTAL SOPs** · $INVESTIGATIONS_COUNT investigation · $SECURITY_COUNT security"
  awk -v line="$COUNT_LINE" '
    /<!-- vault-state:begin/ { print; print line; skip = 1; next }
    /<!-- vault-state:end/   { skip = 0 }
    !skip                    { print }
  ' "$README" > "$README.tmp" && mv "$README.tmp" "$README"
  echo "Updated $README count block ($TOTAL SOPs)"
fi

# --- published verification status ------------------------------------------
# Every SOP carries inline `[verify YYYY-MM-DD]` markers: one claim checked
# against its primary source on that date. That record only ever existed inside
# the prose and in .omc/, neither of which reaches a reader. Publish it, so the
# age of a procedure is visible without having to trust the page.

STATUS="Verification-Status.md"
CURRENT_DAYS=90
OVERDUE_DAYS=180

n_current=0
n_due=0
n_overdue=0
n_none=0

status_rows() {
  local dir="$1"
  find "$dir" -maxdepth 1 -name 'sop-*.md' -type f -printf '%f\n' 2>/dev/null \
    | sort \
    | while read -r f; do
      local base="${f%.md}"
      local title updated count oldest age state
      title=$(awk '/^title:/{sub(/^title:[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}' "$dir/$f")
      updated=$(awk '/^updated:/{sub(/^updated:[[:space:]]*/,""); print; exit}' "$dir/$f")
      [[ -z "$updated" ]] && updated="—"
      [[ -z "$title" ]] && title="(no title)"
      # grep exits 1 on no match, which pipefail would turn into a script abort.
      count=$({ grep -oE '\[verify [0-9]{4}-[0-9]{2}-[0-9]{2}\]' "$dir/$f" || true; } | wc -l)
      oldest=$(grep -oE '\[verify [0-9]{4}-[0-9]{2}-[0-9]{2}\]' "$dir/$f" \
               | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | head -1 || true)
      if [[ -z "$oldest" ]]; then
        oldest="—"; age="—"; state="no source checks"
      else
        age=$(( ( $(date +%s) - $(date -d "$oldest" +%s) ) / 86400 ))
        if   (( age <= CURRENT_DAYS )); then state="current"
        elif (( age <= OVERDUE_DAYS )); then state="review due"
        else                                state="overdue"
        fi
      fi
      # Alias-free wikilink: an alias pipe would split the table cell, and the
      # Docusaurus sync de-links targets it excludes instead of emitting a 404.
      echo "| $title | [[$base]] | $updated | $count | $oldest | $age | $state |"
    done
}

# Counted in the parent shell: the pipeline above runs in a subshell.
for dir in "$PLATFORMS_DIR" "$TECHNIQUES_DIR" "$ANALYSIS_DIR" "$PENTEST_DIR"; do
  while IFS= read -r f; do
    oldest=$(grep -oE '\[verify [0-9]{4}-[0-9]{2}-[0-9]{2}\]' "$f" \
             | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | head -1 || true)
    if [[ -z "$oldest" ]]; then
      n_none=$((n_none + 1)); continue
    fi
    age=$(( ( $(date +%s) - $(date -d "$oldest" +%s) ) / 86400 ))
    if   (( age <= CURRENT_DAYS )); then n_current=$((n_current + 1))
    elif (( age <= OVERDUE_DAYS )); then n_due=$((n_due + 1))
    else                                n_overdue=$((n_overdue + 1))
    fi
  done < <(find "$dir" -maxdepth 1 -name 'sop-*.md' -type f)
done

cat > "$STATUS" <<EOF
---
type: index
title: Verification Status
description: "Per-SOP verification record for the Intel Codex vault: source-check counts, oldest check, and review age for all $TOTAL procedures."
generated: $today
generator: tools/build-vault-state.sh
tags:
  - index
  - verification
---

# Verification Status

> **Generated file. Do not edit directly.** Re-run \`./tools/build-vault-state.sh\`.

Every SOP in this vault carries inline \`[verify YYYY-MM-DD]\` markers. One marker
is one claim — a command flag, a statute reference, a vendor behaviour, a tool
default — checked against its primary source on that date.

This page publishes that record so the age of a procedure is visible without
having to take the page's word for it. Read it for what it is: **it reports when
claims were last checked against sources, not that a procedure was executed end
to end in a lab.** No SOP here is labelled field-tested, because none of them has
the evidence that label would require.

A SOP counts as \`current\` at $CURRENT_DAYS days or less, \`review due\` up to
$OVERDUE_DAYS, and \`overdue\` beyond that. Age is measured from the **oldest**
marker in the file, so a SOP is only as fresh as its stalest claim.

## Summary

| State | SOPs |
|-------|------|
| current (≤ $CURRENT_DAYS days) | $n_current |
| review due ($((CURRENT_DAYS + 1))–$OVERDUE_DAYS days) | $n_due |
| overdue (> $OVERDUE_DAYS days) | $n_overdue |
| no source checks recorded | $n_none |
| **Total** | **$TOTAL** |

## Investigations / Platforms

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
$(status_rows "$PLATFORMS_DIR")

## Investigations / Techniques

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
$(status_rows "$TECHNIQUES_DIR")

## Security / Analysis

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
$(status_rows "$ANALYSIS_DIR")

## Security / Pentesting

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
$(status_rows "$PENTEST_DIR")

---

**Generated:** $today
EOF

echo "Wrote $STATUS ($n_current current, $n_due due, $n_overdue overdue, $n_none unrecorded)"

echo "Wrote $OUT (Total: $TOTAL SOPs)"
