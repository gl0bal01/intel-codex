#!/usr/bin/env bash
# tools/list-stale-sops.sh
# Lists the SOPs whose source checks need attention, as Markdown.
#
# Three buckets, all measured from a SOP's OLDEST [verify YYYY-MM-DD] marker:
#   overdue      — past the review cadence
#   due soon     — inside the last month before it expires
#   unverified   — carries no marker at all, so nothing has ever been checked
#
# Prints nothing when every SOP is current, so a caller can treat empty output
# as "no rotation needed". Always exits 0; an empty list is not an error.
#
# Run from repo root: ./tools/list-stale-sops.sh

set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tools/verification-cadence.sh
source tools/verification-cadence.sh

now=$(date +%s)

overdue=""
due_soon=""
unverified=""

for dir in Investigations/Platforms Investigations/Techniques Security/Analysis Security/Pentesting; do
  while IFS= read -r f; do
    base=$(basename "$f" .md)
    title=$(awk '/^title:/{sub(/^title:[[:space:]]*/,""); gsub(/^"|"$/,""); print; exit}' "$f")
    [[ -z "$title" ]] && title="$base"

    oldest=$({ grep -oE '\[verify [0-9]{4}-[0-9]{2}-[0-9]{2}\]' "$f" || true; } \
             | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort | head -1 || true)

    if [[ -z "$oldest" ]]; then
      unverified+="- \`$base\` — $title (no source check has ever been recorded)"$'\n'
      continue
    fi

    age=$(( (now - $(date -d "$oldest" +%s)) / 86400 ))
    if   (( age > VERIFY_CADENCE_DAYS )); then
      overdue+="- \`$base\` — $title (oldest check $oldest, $age days)"$'\n'
    elif (( age > VERIFY_WARN_DAYS )); then
      due_soon+="- \`$base\` — $title (oldest check $oldest, $age days)"$'\n'
    fi
  done < <(find "$dir" -maxdepth 1 -name 'sop-*.md' -type f | sort)
done

[[ -z "$overdue$due_soon$unverified" ]] && exit 0

if [[ -n "$overdue" ]]; then
  printf '## Overdue (past %s days)\n\n%s\n' "$VERIFY_CADENCE_DAYS" "$overdue"
fi
if [[ -n "$due_soon" ]]; then
  printf '## Due soon (within a month of the cadence)\n\n%s\n' "$due_soon"
fi
if [[ -n "$unverified" ]]; then
  printf '## Never verified\n\n%s\n' "$unverified"
fi

printf 'Full record: [Verification-Status.md](Verification-Status.md). Re-run `./tools/build-vault-state.sh` after adding markers.\n'
