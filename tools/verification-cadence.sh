#!/usr/bin/env bash
# Single source of truth for how often a SOP's claims are re-checked.
#
# One `[verify YYYY-MM-DD]` marker is one claim checked against its primary
# source on that date. A SOP is as fresh as its oldest marker, so these numbers
# are always measured against that one.
#
# Sourced by tools/check-vault.sh, tools/build-vault-state.sh and
# tools/list-stale-sops.sh. Change the cadence here and nowhere else, or the
# published page and the linter start disagreeing about what "current" means.

# Re-check every year.
VERIFY_CADENCE_DAYS=365

# Flag a month before the cadence expires, so rotation can be scheduled rather
# than discovered after the fact.
VERIFY_WARN_DAYS=335
