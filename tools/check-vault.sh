#!/usr/bin/env bash
# tools/check-vault.sh
# Lints the vault for common drift / hygiene issues.
# Run from repo root: ./tools/check-vault.sh
# Exit code: 0 = clean, 1 = warnings found.
#
# Checks:
#   1. Every sop-*.md has 'updated:' in YAML front matter
#   2. Every sop-*.md cross-references Legal & Ethics
#   3. [verify YYYY-MM-DD] markers older than 180 days
#   4. Wikilink targets resolve to real basenames in the vault
#   5. .omc/vault-state.md total count matches the filesystem

set -uo pipefail
cd "$(dirname "$0")/.."

WARN=0
warn() { echo "WARN: $*"; WARN=1; }

# Build basename hash for wikilink check
declare -A KNOWN
while IFS= read -r b; do
  KNOWN[$b]=1
done < <(find Investigations Security Cases CTF -name '*.md' -type f -printf '%f\n' 2>/dev/null | sed 's/\.md$//')

# 1. updated: in front matter
echo "[1/5] Checking front-matter 'updated:' ..."
while IFS= read -r f; do
  if ! grep -q "^updated:" "$f"; then
    warn "$f missing 'updated:' YAML field"
  fi
done < <(find Investigations Security -name 'sop-*.md' -type f)

# 2. Legal & Ethics cross-reference
echo "[2/5] Checking Legal & Ethics cross-reference ..."
while IFS= read -r f; do
  if ! grep -qE "sop-legal-ethics|Legal & Ethic" "$f"; then
    warn "$f missing Legal & Ethics cross-reference"
  fi
done < <(find Investigations Security -name 'sop-*.md' -type f)

# 3. [verify YYYY-MM-DD] older than 180 days
echo "[3/5] Checking [verify] marker freshness ..."
cutoff=$(date -d "180 days ago" +%Y%m%d 2>/dev/null || gdate -d "180 days ago" +%Y%m%d 2>/dev/null || echo "")
if [[ -z "$cutoff" ]]; then
  echo "  (skipped: no GNU date available for 180-day arithmetic)"
else
  while IFS= read -r line; do
    file="${line%%:*}"
    date_str=$(echo "$line" | grep -oE '\[verify [0-9]{4}-[0-9]{2}-[0-9]{2}\]' | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    if [[ -n "$date_str" ]]; then
      date_compact="${date_str//-/}"
      if [[ "$date_compact" -lt "$cutoff" ]]; then
        warn "$file has stale [verify $date_str] (>180 days old)"
      fi
    fi
  done < <(grep -rn "\[verify [0-9]" Investigations Security 2>/dev/null || true)
fi

# 4. Wikilink targets exist
echo "[4/5] Checking wikilink targets ..."
while IFS= read -r f; do
  while read -r target; do
    [[ -z "$target" ]] && continue
    # Strip trailing backslash (Obsidian dataview pipe-escape: [[Foo\|Bar]])
    target="${target%\\}"
    # Strip trailing .md extension (Markdown-style wikilink: [[../CTF/CTF-Index.md]])
    target="${target%.md}"
    case "$target" in
      http*)
        warn "$f: malformed wikilink starting with URL: [[$target...]]"
        ;;
      intel-codex/*)
        # Docusaurus long form — strip prefix and check basename
        base=$(basename "$target")
        if [[ -z "${KNOWN[$base]:-}" ]]; then
          warn "$f: broken docusaurus wikilink basename: [[$target]] -> $base"
        fi
        ;;
      *)
        base=$(basename "$target")
        if [[ -z "${KNOWN[$base]:-}" ]]; then
          warn "$f: broken wikilink: [[$target]] (basename '$base' not found in vault)"
        fi
        ;;
    esac
  done < <(awk 'BEGIN{in_fence=0} /^```/{in_fence=!in_fence; next} !in_fence' "$f" 2>/dev/null | grep -oE '\[\[[^]|#]+' | sed 's/^\[\[//')
done < <(find Investigations Security -name '*.md' -type f)

# 5. vault-state.md count matches filesystem
echo "[5/5] Checking vault-state.md count parity ..."
if [[ -f .omc/vault-state.md ]]; then
  fs_total=$(find Investigations Security -name 'sop-*.md' -type f | wc -l)
  vs_total=$(grep -E '\*\*Vault total\*\* \| \*\*[0-9]+\*\*' .omc/vault-state.md 2>/dev/null | grep -oE '[0-9]+' | tail -1)
  if [[ -n "$vs_total" ]] && [[ "$fs_total" -ne "$vs_total" ]]; then
    warn ".omc/vault-state.md total ($vs_total) != filesystem total ($fs_total). Run ./tools/build-vault-state.sh"
  fi
else
  warn ".omc/vault-state.md not found. Run ./tools/build-vault-state.sh"
fi

if [[ "$WARN" -eq 0 ]]; then
  echo ""
  echo "OK: vault clean."
else
  echo ""
  echo "DONE: warnings above. Review, fix, or accept."
fi
exit $WARN
