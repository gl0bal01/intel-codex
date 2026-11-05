#!/usr/bin/env bash
# tools/ci-local.sh
# Runs .github/workflows/vault-check.yml locally, step for step, against HEAD
# plus the working-tree files you name, in a throwaway git worktree. Keep it in
# step with the workflow: a new CI step gets added here in the same commit.
#
# Usage: ./tools/ci-local.sh [--head | FILE...]
#   FILE...   overlay exactly these working-tree files (what you are about to stage)
#   --head    test HEAD as committed, no overlay (pre-push hook)
#   nothing   overlay every modified or untracked file except index.md
# Exit: 0 = both steps pass, 1 = at least one failed (all steps always run).

set -uo pipefail
cd "$(dirname "$0")/.."
repo=$PWD
export TZ=UTC   # GitHub runners run in UTC

if [[ "${1:-}" == "--head" ]]; then
  files=()
elif (($#)); then
  files=("$@")
else
  mapfile -t files < <({ git diff --name-only HEAD; git ls-files --others --exclude-standard; } | grep -vx 'index.md' | sort -u)
fi

wt=$(mktemp -d "${TMPDIR:-/tmp}/vault-ci.XXXXXX")
cleanup() { git -C "$repo" worktree remove --force "$wt" >/dev/null 2>&1; rm -rf "$wt"; }
trap cleanup EXIT
git worktree add -q --detach "$wt" HEAD || exit 1

for f in "${files[@]}"; do
  if [[ -e "$f" ]]; then
    mkdir -p "$wt/$(dirname "$f")"
    command cp -f -- "$f" "$wt/$f" || exit 1
  else
    rm -f -- "$wt/$f"   # deleted in the working tree
  fi
done
echo "Overlay on $(git rev-parse --short HEAD): ${#files[@]} file(s)"

cd "$wt" || exit 1
[[ "$(git rev-parse --show-toplevel)" == "$wt" ]] || { echo "worktree guard failed"; exit 1; }
git add -A   # the overlay stands in for the commit being tested

fail=0
echo "== [1/2] Lint the vault"
if ./tools/check-vault.sh >check.log 2>&1; then echo "PASS"; else tail -20 check.log; echo "FAIL"; fail=1; fi

echo "== [2/2] Generated counts are up to date"
VAULT_STATE_AS_OF=$(awk '/^generated:/{print $2; exit}' Verification-Status.md) \
  ./tools/build-vault-state.sh >/dev/null
if git diff --quiet; then
  echo "PASS"
else
  git --no-pager diff --stat
  echo "FAIL: run ./tools/build-vault-state.sh and include the result"
  fail=1
fi

echo; ((fail)) && echo "ci-local: FAILED" || echo "ci-local: all steps passed"
exit $fail
