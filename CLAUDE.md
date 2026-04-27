# CLAUDE.md — Intel Codex

Session brief. Last refresh: 2026-04-27. Refresh history: `.omc/refresh-log.md`.

> **Before authoring or editing any SOP, read `.omc/vault-state.md`.** SOP inventory, per-folder counts, watchlist tiers (rotation cadence), and capability gaps live there. Regenerate with `./tools/build-vault-state.sh`. Lint the vault for drift with `./tools/check-vault.sh`.

## Identity

Operational manual for digital investigators, security analysts, OSINT practitioners, CTF players. Author: gl0bal01. MIT.

**Not** a tool, course, CVE database, install guide, or malware repo. SOPs reference tools, don't bundle them. Defensive/educational scope.

**Dual-format:** Obsidian vault is source of truth. Mirrored to a Docusaurus site via an out-of-tree `vault-sync` plugin. `index.md` = Docusaurus landing page; `README.md` = Obsidian/GitHub landing page — keep both in sync. `.github/workflows/mirror.yml` mirrors `main` to Codeberg. No CI; vault hygiene is checked by `tools/check-vault.sh`.

## Layout

- `Investigations/Platforms/` — per-network playbooks
- `Investigations/Techniques/` — cross-cutting OSINT methods
- `Security/Analysis/` — defensive analysis (forensics, malware, RE, crypto, hashing, AI red-team, smart-contract audit)
- `Security/Pentesting/` — offensive testing (Linux, AD, cloud, web, mobile, firmware, vuln research, bug bounty, detection evasion, wireless/RF)
- `Cases/` — `Case-Template/`, `2025-001-Example-Investigation/`, `Student-Exercises/`, `Glossary.md`, `Investigation-Workflow.md`
- `CTF/` — out of SOP scope; hub at `CTF/CTF-Index.md`
- `*-Index.md` hub at every navigable level, ending in a `**Navigation:**` wikilink line
- `.omc/vault-state.md` — generated SOP inventory + counts + watchlist + gaps (**read this first**)
- `.omc/watchlist.md`, `.omc/gaps.md` — manual sources composed into `vault-state.md`
- `tools/build-vault-state.sh`, `tools/check-vault.sh` — regenerate state; lint vault drift

SOP counts and inventory are derived from the filesystem — see `.omc/vault-state.md`. `README.md` and `index.md` should match the vault total; `tools/check-vault.sh` verifies.

## Conventions

- **Front matter:** `type: sop|index|dossier`, `title`, `description`, `tags`. Often `created`, `updated`, `template_version`. Newer SOPs use list-form `tags:`; older use inline. Match the file. Only `index.md` uses Docusaurus fields (`sidebar_label`, `sidebar_position`).
- **Headings:** `# H1` matches title. Optional top blockquote (`> **Authorized environments only.**`). `## Table of Contents` early. Numbered sections for procedural SOPs, named sections for narrative ones — match the file. Tail order: Tools Reference, Common Pitfalls / Risks & Limitations, Real-World Scenarios (platforms), Emergency Procedures (platforms + escalation), Related SOPs, External/Reference Resources, footer with Version/Last Updated/Review Frequency.
- **Legal & ethics:** canonical source `sop-legal-ethics.md`. Every other SOP cross-references it; never re-derives. Top-of-page warning blockquote + bottom `## Legal & Ethical Considerations` block. Pentesting SOPs add a top Pre-Engagement legal checklist.
- **OPSEC:** canonical source `sop-opsec-plan.md`. Integrated where relevant (platform "Risks & Limitations", pentest "Pre-Engagement"); no dedicated `## OPSEC` template.
- **Code blocks:** language-tagged fences. Linux/bash is the default. Win/Linux/macOS triples are consistent only in `sop-hash-generation-methods.md`, `sop-forensics-investigation.md`, `sop-collection-log.md`. Don't introduce triples uniformly — match surrounding SOP.
- **Cross-links:** wikilinks. Basename form (`[[sop-opsec-plan|OPSEC]]`) inside the vault — Obsidian resolves by basename. Relative form for cross-folder where useful. Only `index.md` uses Docusaurus long form `[[intel-codex/path/to/file|Display]]` and GitHub URLs for `Cases/` (outside sync scope). **Never write a wikilink to a file that doesn't exist** — Obsidian fails silently, Docusaurus build doesn't. `tools/check-vault.sh` flags broken targets.
- **Dataview:** only `Investigations/Investigations-Index.md` uses it (Obsidian-only; no-op on GitHub/Docusaurus). Pipe-escape `\|` inside dataview tables is intentional.

## Tag taxonomy

Use existing tags. Themes: doc type (`sop`, `index`, `dossier`), OSINT domain, platforms, technique, security domain, security topic. Full list via `git log` for prior CLAUDE.md or `grep` across files.

## Authoring rules

- **Naming:** kebab-case lowercase. `sop-<topic>.md`, `sop-platform-<name>.md`.
- **Folder placement:** OSINT methodology → `Investigations/Techniques/`. Platform playbooks → `Investigations/Platforms/`. Defensive analysis → `Security/Analysis/`. Offensive testing → `Security/Pentesting/`.
- **PR-ready SOP:** front matter (incl. `updated:`), `# H1`, top blockquote, TOC for multi-section, copy-paste-ready commands (absolute paths, env vars for secrets), Legal & Ethics block + cross-link, OPSEC where relevant, Related SOPs tail, working external links.
- **Navigation update obligation:** when adding/moving an SOP, update the matching `*-Index.md`, the domain index, `README.md`, and `index.md`, then re-run `./tools/build-vault-state.sh`. README+index pair is what publishes to both Obsidian and Docusaurus.
- **Verify links:** run `./tools/check-vault.sh` before committing; or `Glob`/`Grep` per-link.
- **Edits bump dates:** `updated:` (or `template_version:`) in YAML and trailing `**Last Updated:**` line.
- **Forensics location note:** `sop-forensics-investigation.md` lives in `Security/Analysis/` (post-move). Old `Security/Pentesting/` relative-path links are broken; basename links resolve.

## How Claude should help

- **New SOPs:** copy the closest existing SOP's structure. Match front-matter style, heading style, tail blocks. Cross-link `sop-legal-ethics.md` + `sop-opsec-plan.md` as appropriate.
- **Audits:** read `.omc/vault-state.md` for the watchlist; pick from the appropriate tier. Read the target file in full before proposing changes. Prefer a diff over a rewrite unless asked.
- **Cross-links:** verify with `./tools/check-vault.sh` or `Glob`/`Grep`. Basename for in-folder, relative for cross-folder, Docusaurus long form only in `index.md`, Markdown relative for `Cases/`.
- **Cases:** start from `Cases/Case-Template/`. Naming: `YYYY-NNN-Brief-Description`. Subject data fictional unless authorized. Reference `Cases/2025-001-Example-Investigation/`.
- **Refusals:** never invent commands, flags, CVE numbers, statute numbers, citations, vendor pricing. Never draft adversary content (working malware, weaponized exploits). If unsure about scope, ask first.
- **Commits:** never commit or `git push` without explicit user approval. The user runs commits.
