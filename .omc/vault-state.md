---
generated: 2026-04-27
generator: tools/build-vault-state.sh
---

# Vault State

> **Generated file. Do not edit directly.**
> - SOP inventory + counts: regenerated from the filesystem by `tools/build-vault-state.sh`.
> - Watchlist (rotation tiers): authored in `.omc/watchlist.md`.
> - Gaps (missing SOPs): authored in `.omc/gaps.md`.
> - Conventions, authoring rules, hard rules: `CLAUDE.md` (project root).
>
> Re-run `./tools/build-vault-state.sh` after adding, moving, or renaming any SOP.
> Run `./tools/check-vault.sh` to lint for drift / hygiene issues.

## SOP inventory

### Investigations/Platforms (8 SOPs)

- `sop-platform-bluesky` — Bluesky SOP (updated 2025-09-06)
- `sop-platform-discord` — Discord SOP (updated 2026-04-27)
- `sop-platform-instagram` — Instagram SOP (updated 2025-10-01)
- `sop-platform-linkedin` — LinkedIn SOP (updated 2025-10-06)
- `sop-platform-reddit` — Reddit SOP (updated 2025-10-02)
- `sop-platform-telegram` — Telegram SOP (updated 2026-04-27)
- `sop-platform-tiktok` — TikTok SOP (updated 2025-10-08)
- `sop-platform-twitter-x` — Twitter/X SOP (updated 2025-10-08)

### Investigations/Techniques (12 SOPs)

- `sop-blockchain-investigation` — Blockchain Investigation (updated 2026-04-26)
- `sop-collection-log` — OSINT Collection Log & Chain of Custody (updated 2026-04-26)
- `sop-darkweb-investigation` — Darkweb Investigation (updated 2026-04-26)
- `sop-entity-dossier` — Entity Dossier Guide (updated 2026-04-26)
- `sop-financial-aml-osint` — Financial Crime & AML OSINT (updated 2026-04-27)
- `sop-image-video-osint` — Image & Video OSINT (updated 2026-04-25)
- `sop-legal-ethics` — Legal, Ethics & Data Governance for OSINT (updated 2026-04-26)
- `sop-mixer-tracing` — Mixer & Privacy-Pool Tracing (updated 2026-04-26)
- `sop-opsec-plan` — OPSEC Planning for OSINT Investigations (updated 2026-04-26)
- `sop-reporting-packaging-disclosure` — Reporting, Packaging & Disclosure (updated 2026-04-27)
- `sop-sensitive-crime-intake-escalation` — Sensitive Crime Intake & Escalation (updated 2026-04-26)
- `sop-web-dns-whois-osint` — Web, DNS & WHOIS OSINT (updated 2026-04-25)

### Security/Analysis (10 SOPs)

- `sop-ai-vulnerability-evasion` — AI/ML Vulnerability & Evasion Testing SOP (updated 2026-04-26)
- `sop-cloud-forensics` — Cloud Forensics SOP (updated 2026-04-27)
- `sop-cryptography-analysis` — Cryptography Analysis SOP (updated 2026-04-25)
- `sop-email-bec-forensics` — Email & BEC Forensics SOP (updated 2026-04-27)
- `sop-forensics-investigation` — Digital Forensics Investigation SOP (updated 2026-04-25)
- `sop-hash-generation-methods` — Hash Generation Methods for Evidence Integrity (updated 2026-04-26)
- `sop-malware-analysis` — Malware Analysis SOP (updated 2026-04-27)
- `sop-reverse-engineering` — Reverse Engineering (updated 2026-04-25)
- `sop-saas-log-forensics` — SaaS Log Forensics SOP (updated 2026-04-27)
- `sop-smart-contract-audit` — Smart Contract Audit SOP (updated 2026-04-26)

### Security/Pentesting (11 SOPs)

- `sop-ad-pentest` — Active Directory Pentesting SOP (Authorized) (updated 2026-04-26)
- `sop-bug-bounty` — Bug Bounty Methodology SOP (updated 2026-04-25)
- `sop-cloud-pentest` — Cloud Pentesting SOP (Authorized) (updated 2026-04-27)
- `sop-container-k8s-pentest` — Container & Kubernetes Pentesting SOP (Authorized) (updated 2026-04-27)
- `sop-detection-evasion-testing` — Detection & Evasion Testing SOP (Purple Team) (updated 2026-04-25)
- `sop-firmware-reverse-engineering` — Firmware Reverse Engineering (updated 2026-04-26)
- `sop-linux-pentest` — Linux Pentesting SOP (Authorized) (updated 2026-04-25)
- `sop-mobile-security` — Mobile Security (iOS & Android) (updated 2026-04-26)
- `sop-vulnerability-research` — Vulnerability Research SOP (updated 2026-04-25)
- `sop-web-application-security` — Web Application Security Testing SOP (updated 2026-04-25)
- `sop-wireless-rf-pentest` — Wireless & RF Pentesting (Authorized) (updated 2026-04-26)

## Counts

| Folder | SOPs |
|--------|------|
| Investigations/Platforms | 8 |
| Investigations/Techniques | 12 |
| Security/Analysis | 10 |
| Security/Pentesting | 11 |
| **Investigations total** | **20** |
| **Security total** | **21** |
| **Vault total** | **41** |

These counts are the source of truth. `README.md`, `index.md`, and per-folder `*-Index.md` files should match.


## Watchlist (field-evolution rot speed)

Recommended review cadence per tier. SOPs in **Fast** rotate fastest (platform APIs, attacker TTPs, enforcement landscape); **Slow** are fundamentals (legal, OPSEC, evidence discipline) that change on the order of years.

### Fast — quarterly review

- All `Investigations/Platforms/*` (8 SOPs: bluesky, discord, instagram, linkedin, reddit, telegram, tiktok, twitter-x) — platform APIs, scraping surfaces, ToS, and attacker TTPs rotate frequently
- `sop-ad-pentest`
- `sop-cloud-pentest`
- `sop-container-k8s-pentest` — k8s minor-version cycle, admission-controller projects (Gatekeeper / Kyverno / kubewarden), runtime CVEs (runc / containerd / CRI-O), Pod Security Standards drift, and managed-k8s feature drift across EKS / AKS / GKE rotate quarterly; cluster-RBAC and IAM-bridge fundamentals are slower
- `sop-darkweb-investigation` — marketplace / leak-site / forum landscape rotates monthly (quarterly review); Tor / I2P / PGP fundamentals are slower
- `sop-detection-evasion-testing`
- `sop-mixer-tracing` — mixer enforcement timeline, prosecution outcomes (Pertsev appeal, Storm trial, Samourai prosecution) and vendor heuristic implementations rotate quarterly; CoinJoin / Tornado heuristic methodology is slower
- `sop-mobile-security`
- `sop-firmware-reverse-engineering`
- `sop-wireless-rf-pentest` — Wi-Fi / Bluetooth / Matter portions rotate quarterly; SDR / NFC fundamentals are slower
- `sop-ai-vulnerability-evasion` — quarterly review

### Medium — semi-annual review

- `sop-vulnerability-research`
- `sop-bug-bounty`
- `sop-linux-pentest`
- `sop-financial-aml-osint`
- `sop-web-dns-whois-osint`
- `sop-image-video-osint`
- `sop-forensics-investigation`
- `sop-cryptography-analysis`
- `sop-malware-analysis`
- `sop-web-application-security`
- `sop-blockchain-investigation` — vendor product lineup, sanctions trajectory, bridge-protocol churn rotate quarterly; clustering-heuristic methodology and Daubert posture are slower
- `sop-smart-contract-audit` — audit tooling (Slither / Aderyn / Wake / Echidna / Halmos), EIP / opcode / L2 support drift on a quarterly cadence; vulnerability-class fundamentals are slower
- `sop-cloud-forensics` — CSP control-plane API field renames, retention defaults, managed-Kubernetes audit-log structure, cloud-native threat-detection product feature drift on a quarterly cadence; classical DFIR fundamentals and evidence-discipline are slower
- `sop-saas-log-forensics` — M365 / Workspace / Okta / Slack / Salesforce / GitHub API field renames, retention defaults, license-tier feature drift, OAuth-consent abuse TTPs evolve on a quarterly cadence; classical eDiscovery / chain-of-custody fundamentals are slower
- `sop-email-bec-forensics` — BEC TTPs, AiTM kit landscape, lookalike-domain registrar patterns, M365 / Workspace / SEG message-trace API field renames, IC3 / FFKC threshold guidance evolve on a quarterly cadence; RFC-level SPF / DKIM / DMARC / ARC fundamentals and chain-of-custody discipline are slower

### Slow — annual review

- `sop-legal-ethics`
- `sop-opsec-plan`
- `sop-sensitive-crime-intake-escalation`
- `sop-collection-log`
- `sop-entity-dossier`
- `sop-hash-generation-methods`
- `sop-reverse-engineering`

## Gaps (no dedicated SOP yet)

Capabilities not covered by a dedicated SOP. Add a new SOP only on explicit user decision (no auto-promotion).

- **SaaS pentesting** — M365 / Workspace as a SaaS attack surface (offensive). Defensive side covered by `sop-saas-log-forensics`.
- **Mobile device forensics** — standalone (acquisition, decoding, app-data carving, trust-store analysis). Currently subsumed under `sop-forensics-investigation`.
- **Encrypted-messenger forensics** — Signal / Session / Matrix / WhatsApp.
- **YouTube, Mastodon, Facebook OSINT** — no platform SOPs yet (Discord landed 2026-04-27).
- **LLM-assisted OSINT** — methodology + verification + bias-control.
- **Deepfake detection workflow** — image / video / audio synthetic-media verification.
- **Phishing-kit analysis** — kit-decomposition methodology covered defensively in `sop-email-bec-forensics` §12; deeper standalone SOP remains a gap.
- **ICS / OT** — industrial control / operational technology security.
- **Supply-chain compromise** — software supply-chain attack reconstruction.
- **BGP routing** — BGP hijacking / RPKI / route-leak investigation.
- **Threat-actor / TTP tracking** — MISP / OpenCTI workflows.
