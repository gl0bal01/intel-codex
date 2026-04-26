# CLAUDE.md — Intel Codex

Snapshot for Claude Code sessions working in this repo. Refreshed every ~6 months. Last refresh: 2026-04-25.

---

## 1. Vault identity

- Operational manual for digital investigators, security analysts, OSINT practitioners, and CTF players. Author: gl0bal01. License: MIT.
- Audience: investigators, threat analysts, pentesters, bug-bounty hunters, forensics examiners, students working through guided exercises, and contributors who run Claude Code locally.
- It is **not** a tool, not a course, not a CVE database, not a tool-install guide, not a malware sample repository. SOPs reference tools but do not bundle them.
- Dual-format: **Obsidian vault is the source of truth.** A second face is published via a bespoke Docusaurus "vault-sync" plugin (the Docusaurus site lives outside this repo — no `docusaurus.config*`, `package.json`, or `sidebars.js` in this tree).
- `index.md` is the Docusaurus-facing landing page (front matter + `:::info` admonitions). `README.md` is the Obsidian/GitHub-facing landing page (same scope, plain Markdown, GitHub badges). Keep both in sync when adding content.
- `.github/workflows/mirror.yml` mirrors `main` to Codeberg on push and weekly cron. No CI tests, no linting — authoring is the only workflow.

---

## 2. Top-level structure

- `Investigations/` — OSINT methodology. Two subfolders: `Platforms/` (per-network playbooks) and `Techniques/` (cross-cutting methods: legal/ethics, OPSEC, evidence, dossiers, geolocation, infrastructure, financial, escalation, reporting). Hub: `Investigations/Investigations-Index.md`.
- `Security/` — Offensive and defensive security. Two subfolders: `Analysis/` (malware, RE, forensics, crypto, hashing, AI/ML red-team) and `Pentesting/` (Linux, AD, web, mobile, firmware, vuln research, bug bounty, detection evasion). Hub: `Security/Security-Index.md`. Sub-hubs: `Security/Analysis/Analysis-Index.md`, `Security/Pentesting/Pentesting-Index.md`.
- `Cases/` — Investigation case management. Contains `README.md` (student-safety preface), `Investigation-Workflow.md` (visual lifecycle), `Glossary.md` (~100 terms), `Case-Template/` (skeleton with `Case-Completion-Checklist.md`), `2025-001-Example-Investigation/` (full crypto-scam reference case with dummy data), and `Student-Exercises/` (three guided exercises: username, domain, social-media-timeline).
- `CTF/` — Capture-the-Flag resources (out of scope for the SOP inventory below; see hub `CTF/CTF-Index.md`).

### Obsidian conventions actually used

- `[[file-name|Display]]` wikilinks dominate inside `Investigations/` and `Security/`. Obsidian resolves by basename, so most cross-folder links omit the path (e.g., `[[sop-forensics-investigation|Forensics]]` in `Security/Pentesting/Pentesting-Index.md` resolves to `Security/Analysis/sop-forensics-investigation.md` after the recent `Moved Forensics to Analysis folder` commit).
- `*-Index.md` hub files exist at every navigable level. Each ends with a `**Navigation:**` line of wikilinks.
- YAML front matter on every SOP (see §4).
- Only one file currently uses Obsidian Dataview blocks: `Investigations/Investigations-Index.md` (two `dataview` fences for Active Cases / High-Risk Entities / Pending Review). These render only inside Obsidian — they are no-ops on GitHub and Docusaurus.

### Docusaurus exceptions (only where they exist on disk)

- `index.md` uses Docusaurus front matter (`title`, `sidebar_label`, `sidebar_position`, `description`) and `:::info ... :::` admonitions, neither of which appear in any other file.
- `index.md` wikilinks use the long Docusaurus form `[[intel-codex/Investigations/Techniques/sop-legal-ethics|Legal & Ethics]]` rather than the short basename form. Some links in `index.md` are plain GitHub URLs (`https://github.com/gl0bal01/intel-codex/blob/main/Cases/...`) because the case folders sit outside the Docusaurus sync scope. [inferred]
- No other Docusaurus-specific files exist in the repo.

---

## 3. SOP inventory

30 SOPs total across the four in-scope domains. `README.md` and `index.md` were both reconciled to "30+" during the 2026-04-25 refresh (see §10). One-line purpose pulled from each file's front matter `description` or first paragraph.

### Platform SOPs — `Investigations/Platforms/`

- `Investigations/Platforms/sop-platform-bluesky.md` — Decentralized profile investigation, AT Protocol / DID resolution, federation tracking.
- `Investigations/Platforms/sop-platform-instagram.md` — Photo, story, location, and hashtag tracking; influencer network mapping.
- `Investigations/Platforms/sop-platform-linkedin.md` — Profile investigation, employment-history tracking, connection mapping, corporate intel.
- `Investigations/Platforms/sop-platform-reddit.md` — User history, subreddit investigation, comment tracking, archived/deleted content.
- `Investigations/Platforms/sop-platform-telegram.md` — Channel monitoring, group analysis, bot tracking, encrypted-messaging patterns.
- `Investigations/Platforms/sop-platform-tiktok.md` — Video analysis, user profiling, hashtag and sound investigation, viral content tracing.
- `Investigations/Platforms/sop-platform-twitter-x.md` — Profile/tweet collection, advanced search operators, X API v2, follower investigation.

### Investigation Techniques — `Investigations/Techniques/`

- `Investigations/Techniques/sop-collection-log.md` — Evidence logging, SHA-256 chain of custody, multi-format capture for legal admissibility.
- `Investigations/Techniques/sop-entity-dossier.md` — Person/org/asset profiling template; identity, footprint, link analysis, confidence/risk scoring.
- `Investigations/Techniques/sop-financial-aml-osint.md` — Cryptocurrency tracing, sanctions/PEP screening, AML investigation, blockchain analysis.
- `Investigations/Techniques/sop-image-video-osint.md` — EXIF, reverse image search, geolocation, sun/shadow, video verification, deepfake detection.
- `Investigations/Techniques/sop-legal-ethics.md` — Authorization, GDPR/CCPA/CFAA, prohibited actions, retention, evidentiary integrity, escalation.
- `Investigations/Techniques/sop-opsec-plan.md` — 5-level threat model, VM/Whonix/Tails/Exegol/Kasm isolation, VPN/Tor, persona warming, browser hardening.
- `Investigations/Techniques/sop-reporting-packaging-disclosure.md` — Report structure, redaction, metadata scrubbing, encrypted disclosure, version control.
- `Investigations/Techniques/sop-sensitive-crime-intake-escalation.md` — CSAM/terrorism/trafficking handoff (NCMEC, FBI, CEOP, IWF, Pharos, NCA, etc.), investigator-trauma protocol.
- `Investigations/Techniques/sop-web-dns-whois-osint.md` — Domain attribution, DNS, WHOIS, certificate transparency, subdomain discovery, infrastructure pivoting.

### Analysis SOPs — `Security/Analysis/`

- `Security/Analysis/sop-ai-vulnerability-evasion.md` — Red/blue team AI security: prompt injection, MITRE ATLAS mapping, OWASP LLM Top-10, jailbreak suites, governance.
- `Security/Analysis/sop-cryptography-analysis.md` — Cipher analysis, RSA attacks (RsaCtfTool patterns), password cracking, SSL/TLS testing, CTF crypto.
- `Security/Analysis/sop-forensics-investigation.md` — Disk imaging, memory acquisition (LiME/AVML/FTK), Volatility, registry, timeline (Plaso), browser/email artifacts.
- `Security/Analysis/sop-hash-generation-methods.md` — SHA-256/MD5 tooling on Windows / Linux / macOS, chain-of-custody hashing, NSRL, malware dedup.
- `Security/Analysis/sop-malware-analysis.md` — Static + dynamic analysis, sandbox setup (REMnux/FlareVM/INetSim), IOC extraction, YARA/Sigma.
- `Security/Analysis/sop-reverse-engineering.md` — Disassembly, decompilation (Ghidra/IDA/r2), debugging, anti-RE, exploit dev.

### Pentesting SOPs — `Security/Pentesting/`

- `Security/Pentesting/sop-ad-pentest.md` — Read-only AD enumeration, BloodHound, Kerberoasting, AS-REP roasting, ACL/DCSync abuse, GPO review, LAPS.
- `Security/Pentesting/sop-bug-bounty.md` — Program selection, recon, OWASP-driven testing, severity scoring, report writing, responsible disclosure.
- `Security/Pentesting/sop-detection-evasion-testing.md` — Purple-team validation; Caldera, Atomic Red Team, AMSI/EDR/SIEM bypass, gap-driven improvement.
- `Security/Pentesting/sop-firmware-reverse-engineering.md` — Firmware acquisition (download, intercept, SPI/CH341A, UART, JTAG), unpacking with Binwalk, QEMU emulation, Firmadyne.
- `Security/Pentesting/sop-linux-pentest.md` — Read-only enumeration, SUID/capabilities, sudo abuse, kernel-CVE checks, LinPEAS/LSE.
- `Security/Pentesting/sop-mobile-security.md` — APK/IPA reversing (JADX, Apktool, class-dump, frida-ios-dump), Frida/Objection runtime hooking, SSL-pinning bypass.
- `Security/Pentesting/sop-vulnerability-research.md` — Methodology, fuzzing (AFL++/LibFuzzer/Honggfuzz), memory-corruption classes, ROP, mitigation bypass, CVE process.
- `Security/Pentesting/sop-web-application-security.md` — OWASP Top-10 walkthrough, auth/session, injection, XSS/CSRF, API and business-logic testing.

---

## 4. Document conventions

Derived from front matter and structure of files actually read.

### Front matter

- Universal SOP fields (most SOPs): `type: sop`, `title`, `description`, `tags: [...]`. Many also include `created`, `updated`, and/or `template_version`.
- The recent (2025) SOPs use a YAML *list* form for `tags:` (one per line). Older ones use the inline form `tags: [sop, ...]`. Both are valid Obsidian YAML — keep whichever style the file already uses.
- `Investigations/Techniques/sop-entity-dossier.md` uses `type: dossier` (not `sop`) and adds entity-specific fields (`entity_type`, `name`, `aliases`, `primary_id`, `country`, `risk`, `confidence`, `analyst`, `case_id`). It is both an SOP *and* a fillable template.
- Index files use `type: index` plus `title`, `description`, `tags`.
- Only `index.md` uses Docusaurus fields (`sidebar_label`, `sidebar_position`).

### Tag taxonomy (confirmed by grep across all files)

Group by theme — use existing tags rather than inventing new ones:

- **Document type:** `sop`, `index`, `dossier`
- **OSINT domain:** `osint`, `investigation`, `investigations`, `intelligence`, `navigation`
- **Platforms:** `platform`, `social-media`, `messaging`, `video`, `decentralized`, `professional`, `twitter`, `x`, `instagram`, `telegram`, `linkedin`, `reddit`, `tiktok`, `bluesky`
- **Investigation technique:** `legal`, `ethics`, `compliance`, `gdpr`, `privacy`, `data-governance`, `opsec`, `operational-security`, `log`, `chain-of-custody`, `evidence`, `documentation`, `entity`, `media`, `exif`, `reverse`, `geolocation`, `verification`, `webint`, `whois`, `dns`, `finance`, `aml`, `sanctions`, `reporting`, `disclosure`, `safety`, `escalation`, `safeguarding`, `child-protection`, `terrorism`, `trafficking`
- **Security domain:** `security`, `cybersecurity`, `pentest`, `pentesting`, `analysis`, `dfir`, `forensics`, `incident-response`
- **Security topic:** `malware`, `reverse`, `reverse-engineering`, `binary-analysis`, `exploit-dev`, `assembly`, `disassembly`, `vulnerability-research`, `exploitation`, `fuzzing`, `web-security`, `web-apps`, `owasp`, `bugbounty`, `mobile`, `ios`, `android`, `app-security`, `firmware`, `iot`, `embedded`, `hardware`, `router`, `active-directory`, `internal`, `linux`, `purple-team`, `red-team`, `blue-team`, `detection`, `evasion`, `ai`, `ml`, `adversarial`, `template`

### Heading hierarchy

- One `# H1` matching the front-matter `title`. Optional blockquote warning on the next line (`> **Authorized environments only.**`, `> **Purpose:**`, `> [!warning] ...`).
- A `## Table of Contents` very early (most SOPs).
- Numbered top-level sections (`## 1. ...`, `## 2. ...`) for procedural SOPs (platforms, pentesting, malware, hashing, AD, Linux). Named sections (no numbers) for narrative SOPs (legal-ethics, opsec-plan, reporting). Both styles are accepted — match the file you're editing.
- Standard tail sections (in this order, in most SOPs): `Tools Reference`, `Common Pitfalls` *or* `Risks & Limitations`, `Real-World Scenarios` (platforms only), `Emergency Procedures` (platforms + escalation), `Related SOPs`, `External Resources` / `Reference Resources`. Trailing footer with `Version`, `Last Updated`, `Review Frequency`.

### Legal / ethics placement

- The canonical legal frame is `Investigations/Techniques/sop-legal-ethics.md`. Every other SOP **cross-references it** rather than re-deriving it.
- Most SOPs open with a one-line top-of-page warning blockquote (`> **Authorized environments only.**`, `> **Authorized investigations only.**`, `> **Ethical bug hunting only.**`). The AI/ML SOP uses an Obsidian `> [!warning]` callout instead.
- A `## Legal & Ethical Considerations` (or `## Safety & Legal`) section appears near the **bottom** of each technical SOP. Pre-engagement legal checklists appear near the **top** for pentesting SOPs. Both placements coexist in the same file.

### OPSEC placement

- Authoritative source: `Investigations/Techniques/sop-opsec-plan.md`.
- Each platform SOP contains a "Risks & Limitations" section that addresses platform-specific attribution/detection. Each pentesting SOP contains a "Pre-Engagement" section that bundles authorization, OPSEC, and rollback. There is no dedicated `## OPSEC` section template — the topic is integrated where it applies.

### Command-block formatting

- Fenced code blocks tagged with the language: ```bash`, ```powershell`, ```python`, ```c`, ```javascript`, ```sql`, ```http`, ```yaml`, ```nasm`, ```cypher`, ```smali`, ```objective-c`.
- The README claims "All commands provided for Windows/Linux/macOS." Grep across the vault shows Windows command syntax (PowerShell, certutil, Get-FileHash, fciv, HashMyFiles) in 11 SOPs: `sop-collection-log.md`, `sop-image-video-osint.md`, `sop-opsec-plan.md`, `sop-reporting-packaging-disclosure.md`, `sop-forensics-investigation.md`, `sop-hash-generation-methods.md`, `sop-malware-analysis.md`, `sop-ad-pentest.md`, `sop-detection-evasion-testing.md`, `sop-vulnerability-research.md`, `sop-web-application-security.md`. True Win/Linux/macOS *triples* (the same task spelled three ways) are most consistent in `sop-hash-generation-methods.md`, `sop-forensics-investigation.md`, and `sop-collection-log.md`; elsewhere Windows commands appear in single-OS context (e.g., `sop-ad-pentest.md` is Windows-domain by nature). [inferred for triple-vs-single distribution] Platform SOPs and most pentesting SOPs default to Linux/bash. Treat the README claim as aspirational — match the surrounding SOP rather than introducing triples uniformly.

### Cross-reference style

- Inside the vault, **wikilinks are the default** and use either basename (`[[sop-opsec-plan|OPSEC]]`) or relative path (`[[../Techniques/sop-collection-log|Collection Log]]`). Both forms appear; basename form is more common for in-folder references, relative form for cross-folder.
- `index.md` is the only file that uses the long Docusaurus-friendly form `[[intel-codex/path/to/file|Display]]`.
- For files that are not part of the Docusaurus sync (cases, case templates, exercises), `index.md` uses GitHub URLs. Inside Obsidian-only files, `Cases/...` is referenced via plain Markdown relative paths (`[Glossary](Glossary.md)`) or short wikilinks.
- Never write a wikilink to a file that does not exist on disk — Obsidian renders broken links silently and Docusaurus build will fail.

---

## 5. Cross-cutting principles

Distilled from `README.md` and `CONTRIBUTING.md`. These apply to every new SOP and every edit:

- **Legal & ethical first.** Every SOP that touches investigations, OSINT, or adversary tactics needs a Legal & Ethics block and a cross-reference to `sop-legal-ethics.md`.
- **OPSEC by default.** Operational security is integrated, not optional. Reference `sop-opsec-plan.md`.
- **Practical over theoretical.** Each SOP is grounded in real operations and scenarios.
- **Copy-paste ready commands.** Code blocks should run as written. Use absolute paths, env vars for secrets, and explicit tool names.
- **Template-driven.** Reuse existing templates (entity-dossier front matter, case-template skeleton, collection-log table) instead of inventing new shapes.

---

## 6. Learning paths

The README defines six 6-week tracks. Each maps to specific SOPs already in the vault:

- **Path 1 — Investigations Specialist.** `sop-legal-ethics`, `sop-opsec-plan`, platform SOPs, `sop-image-video-osint`, `sop-financial-aml-osint`, `sop-reporting-packaging-disclosure`.
- **Path 2 — Security Analyst.** `sop-malware-analysis`, `sop-reverse-engineering`, IOC generation (covered inside malware analysis).
- **Path 3 — Penetration Tester.** `sop-web-application-security`, `sop-linux-pentest`, `sop-ad-pentest`, `sop-mobile-security`, `sop-firmware-reverse-engineering`.
- **Path 4 — Bug Bounty Hunter.** `sop-web-application-security`, `sop-bug-bounty`, `sop-vulnerability-research`.
- **Path 5 — CTF Competitor.** `sop-reverse-engineering`, `sop-cryptography-analysis`, plus `CTF/CTF_Challenge_Methodology.md` and `CTF/CTF_Tools.md` (out of inventory scope but referenced for completeness).
- **Path 6 — Digital Forensics Investigator.** `sop-forensics-investigation`, `sop-hash-generation-methods`, `sop-malware-analysis`.

---

## 7. Field-evolution watchlist

Opinionated, file-named, based on full reads. All 30 SOPs are now in the watchlist as of the 2026-04-25 watchlist-completion pass.

### Rots fastest (platform APIs, attacker TTPs)

- `Investigations/Platforms/sop-platform-twitter-x.md` — Pricing tiers (`Free Tier: 1,500 tweets/month`, `Basic Tier $100/mo`) and endpoint paths under `api.x.com` change unilaterally. Twint already noted as discontinued.
- `Investigations/Platforms/sop-platform-reddit.md` — Heavy reliance on Pushshift API for deleted-content recovery; public Pushshift access has been restricted to mod-only since the 2023 API blackout. Re-validate every recipe involving `api.pushshift.io`. [inferred]
- `Investigations/Platforms/sop-platform-tiktok.md` — TikTok Research API (academic-only) is a moving target; geographic availability shifts with regulatory action; `yt-dlp --no-watermark` flag behavior depends on platform-side changes.
- `Investigations/Platforms/sop-platform-telegram.md` — MTProto client behavior, directory sites (`combot.org`, `tgstat.com`, `lyzem.com`) self-flagged as "use with caution — data quality varies"; `telegram-cli` annotated `(odd)` in tools list — both early staleness signals.
- `Investigations/Platforms/sop-platform-instagram.md` — Aggressive anti-scraping; InstaLoader and Toutatis frequently break with platform updates; story view-tracking remains the OPSEC trap.
- `Investigations/Platforms/sop-platform-linkedin.md` — Sales Navigator pricing ($99/mo) and connection limits change; "LinkedIn data to Excel" Chrome extension is one platform update from breaking.
- `Investigations/Platforms/sop-platform-bluesky.md` — Self-flagged ("Rapid development — Features changing frequently"); AT Protocol surface area still mutating; PDS hosting model evolving.
- `Security/Pentesting/sop-ad-pentest.md` — Kerberos relay and ACL-abuse TTPs evolve constantly (RemotePotato/Coerce variants); BloodHound CE replaced legacy in 2023; Microsoft is shipping new defaults that change attacker workflow; LAPS → Windows LAPS migration in progress.
- `Security/Pentesting/sop-detection-evasion-testing.md` — AMSI/ETW bypass primitives are patched and rediscovered constantly; EDR vendor coverage matrices age in weeks; MITRE ATT&CK technique IDs are reissued each version.
- `Security/Pentesting/sop-mobile-security.md` — Jailbreak tooling (checkra1n, unc0ver, Taurine, Odyssey) is pinned to specific iOS versions and ages out as iOS releases. The version-by-version tool table will be the first thing to break.
- `Security/Pentesting/sop-firmware-reverse-engineering.md` — Vendor encryption schemes shift; Firmadyne / FAT emulation harnesses lag new architectures; CH341A / flashrom chip support evolves.
- `Security/Analysis/sop-ai-vulnerability-evasion.md` — Quarterly review schedule is correctly set; OWASP LLM Top 10 will iterate; jailbreak suites and provider-side mitigations move weekly. Document the `Last Updated` carefully on each pass.

### Rots medium (tooling, methodology)

- `Security/Pentesting/sop-vulnerability-research.md` — AFL++/LibFuzzer/Honggfuzz APIs and mitigation-bypass landscape (CFI, IBT) keep moving; CVE process and PSIRT contacts shift.
- `Security/Pentesting/sop-bug-bounty.md` — Platform pricing, severity rubrics, and safe-harbor language change per program; the platform table needs an annual sweep.
- `Security/Pentesting/sop-linux-pentest.md` — Cited kernel CVEs (PwnKit `CVE-2021-4034`, DirtyPipe `CVE-2022-0847`) are getting old as headline examples; LinPEAS/LSE versions move fast.
- `Investigations/Techniques/sop-financial-aml-osint.md` — Sanctions data is the most volatile content (OFAC SDN updates daily); the *recipes* are stable, but the *example wallets/addresses* and mixer landscape (Tornado Cash sanctions, Wasabi, ChipMixer status) drift.
- `Investigations/Techniques/sop-web-dns-whois-osint.md` — WHOIS data continues to be redacted under GDPR; SecurityTrails / DomainTools tier limits keep changing.
- `Investigations/Techniques/sop-image-video-osint.md` — Reverse-image and face-search providers (PimEyes, Search4Faces) policy-change frequently; deepfake detection lags actual generation capability.
- `Security/Analysis/sop-forensics-investigation.md` — Volatility 2 → 3 migration ongoing; mobile acquisition (Cellebrite/Magnet AXIOM) version-locked to iOS/Android; cloud artifact coverage is thin and will need expansion.
- `Security/Analysis/sop-cryptography-analysis.md` — RsaCtfTool attack inventory grows; Hashcat hash-mode numbers stable but example hashes age; testssl.sh CVE coverage updates.
- `Security/Analysis/sop-malware-analysis.md` — Tool versions pinned in §9.1 (FLOSS 2.3, CAPA 7.0, PE-bear 0.6, Procmon 3.95, Wireshark 4.0); cloud-sandbox tier offerings (ANY.RUN, Tria.ge, Hybrid Analysis, Joe Sandbox) and abuse.ch service endpoints (MalwareBazaar, ThreatFox, URLhaus) shift; Mandiant FlareVM install URL is an external dependency; dnSpy → dnSpyEx fork acknowledged in §12 and Volatility 2 → 3 migration referenced in §10.1 still in progress. Methodology (static/dynamic analysis, IOC defanging, MITRE mapping, YARA/Sigma/Suricata authoring) is stable.
- `Security/Pentesting/sop-web-application-security.md` — OWASP Top 10 ranking pinned to the **2021** release in the Quick Reference table and will reset on the next iteration; Nuclei template ecosystem and the broader tool matrix (Burp Suite, OWASP ZAP, sqlmap, dalfox, ffuf, jwt_tool, dirsearch, arjun) churn at moderate pace; cited CVE / platform-version examples (`CVE-2014-0160` Heartbleed, `CVE-2014-3566` POODLE, `CVE-2011-3389` BEAST, `CVE-2012-4929` CRIME, `CVE-2015-9251` jQuery 1.8.2; PHP 7.4.3, Apache 2.4.29) read more dated each year but remain valid teaching cases. Cloud-metadata SSRF endpoints (AWS `169.254.169.254`, GCP `metadata.google.internal`, Azure metadata) and SQLi/XSS/CSRF/IDOR/SSRF/XXE/SSTI fundamentals do not move.

### Rots slowly (legal frameworks, fundamentals)

- `Investigations/Techniques/sop-legal-ethics.md` — GDPR/CCPA/CFAA cores stable; case law (`Van Buren v. United States` 2021, `hiQ Labs v. LinkedIn` 2022) cited remains live; refresh annually.
- `Investigations/Techniques/sop-opsec-plan.md` — Threat-modeling fundamentals stable; named tools (Mullvad, ProtonVPN, Tor, Whonix, Tails, Exegol, Kasm) age slowly.
- `Investigations/Techniques/sop-sensitive-crime-intake-escalation.md` — Hotlines (NCMEC `1-800-843-5678`, FBI tips, NCA, Pharos `internet-signalement.gouv.fr`) and statutes (18 U.S.C. § 2258A, Modern Slavery Act 2015) are stable; verify per refresh.
- `Investigations/Techniques/sop-collection-log.md` — Chain-of-custody methodology is stable; only the tool versions and example commands need light touch-ups.
- `Investigations/Techniques/sop-entity-dossier.md` — Template structure is stable; named third-party tools (Maltego, OpenCorporates, OpenSanctions, ICIJ Offshore Leaks) are stable.
- `Security/Analysis/sop-hash-generation-methods.md` — SHA-2 family standards (FIPS 180-4) stable; only NSRL/MalwareBazaar URL hygiene needs periodic checks.
- `Security/Analysis/sop-reverse-engineering.md` — Dominated by stable fundamentals: x86/x64 register sets and instructions, Windows/Linux calling conventions (stdcall, cdecl, fastcall, MS x64, SysV AMD64), stack-frame layout, PE/ELF/GOT/PLT, anti-debug primitives (IsDebuggerPresent, PEB BeingDebugged, RDTSC), and exploitation mitigations (DEP/NX, ASLR, stack canaries, PIE) — all decades-stable. Mature tooling (IDA Pro, Ghidra, Binary Ninja, Radare2, x64dbg, GDB with PEDA/GEF/pwndbg, pwntools, ROPgadget, ropper, one_gadget) ages slowly; the Android sub-section (JADX, Apktool, dex2jar) and Frida hooking examples are the parts most likely to drift with platform updates [inferred]. dnSpy → dnSpyEx fork shift already acknowledged in `sop-malware-analysis.md`.

---

## 8. Gaps and opportunities

Adjacent topics not currently covered by any dedicated SOP. Each verified by grep before being listed.

- **Cloud forensics** — AWS / GCP / Azure incident response: CloudTrail / GuardDuty / Activity Log evidence acquisition, IAM compromise patterns, snapshot/EBS imaging. `sop-forensics-investigation.md` is endpoint-only.
- **Cloud / SaaS pentesting** — IAM enumeration, S3/blob misconfig, metadata-service SSRF, OAuth abuse, container-runtime escapes. Only fragments inside `sop-bug-bounty.md` and `sop-web-application-security.md`.
- **Container / Kubernetes pentesting** — Pod escapes, RBAC abuse, kube-apiserver attack surface, etcd exposure, runtime detection. `sop-linux-pentest.md` mentions `docker` group only.
- **SaaS log forensics (M365 / Google Workspace)** — Unified Audit Log, Defender for 365, Workspace audit log, BEC/AiTM investigation. Not present.
- **Mobile device forensics (separate from pentesting)** — Cellebrite/AXIOM/Oxygen workflows, app data parsing, iOS backup encryption, Android FBE. Currently only a few paragraphs inside `sop-forensics-investigation.md`.
- **Encrypted-messenger forensics** — Signal, Session, Matrix, WhatsApp. Vault has a Telegram SOP only.
- **Discord OSINT** — Servers, bots, webhooks, voice metadata, Discord-id pivots. Referenced incidentally; no dedicated SOP.
- **YouTube / Mastodon / Facebook OSINT** — Three of the largest platforms with no dedicated SOP. Mastodon/Fediverse is the natural complement to the existing Bluesky SOP.
- **LLM-assisted OSINT** — Prompt-driven pivoting, hallucination QA, source-grounding. Distinct from `sop-ai-vulnerability-evasion.md` (which is about *testing* AI systems, not *using* them for investigations).
- **Synthetic media / deepfake detection** — `sop-image-video-osint.md` lists deepfake indicators but no detection workflow (FakeCatcher, PRNU, frequency analysis, Microsoft Video Authenticator successor).
- **Smart-contract auditing** — Solidity/EVM analysis, Slither/Echidna/Foundry workflow. Mentioned in one line under crypto-analysis tools.
- **Cryptocurrency mixer tracing in depth** — Tornado Cash, CoinJoin, Wasabi, JoinMarket de-anonymization techniques. `sop-financial-aml-osint.md` flags mixers as red flags but does not cover tracing methodology.
- **Email forensics & BEC** — Header analysis, DMARC/DKIM forensic interpretation, MX-pivot investigation. Currently a half-dozen lines inside `sop-collection-log.md`.
- **Phishing-kit analysis** — Kit acquisition, deobfuscation, attribution, telemetry exfil endpoints. Not present.
- **ICS/OT investigation** — SCADA, PLC/HMI, Modbus/DNP3, ICS-specific incident response. Not present.
- **Supply-chain compromise investigation** — Dependency-confusion, malicious npm/PyPI, signed-build tampering, SolarWinds-class persistence. Not present.
- **Wi-Fi / wireless** — 802.11 capture, WPA3 weaknesses, BLE/Zigbee, rogue AP detection. Adjacent to firmware RE; absent.
- **BGP / routing investigation** — Route hijack detection, RPKI, AS-graph pivoting. Adjacent to web-DNS-WHOIS; absent.
- **Threat-actor / TTP tracking workflow** — How to maintain a TIP (MISP, OpenCTI), pivot from TTP to actor, manage YARA/Sigma corpora over time.

---

## 9. Contributor / authoring rules

Distilled from `CONTRIBUTING.md` and observed practice:

- **File naming.** New SOPs use `sop-<topic>.md`; new platform SOPs use `sop-platform-<name>.md`. Examples already on disk: `sop-platform-twitter-x.md`, `sop-reverse-engineering.md`. Use kebab-case, lowercase.
- **Folder placement.** OSINT methodology → `Investigations/Techniques/`. Per-network playbooks → `Investigations/Platforms/`. Defensive analysis (malware, RE, forensics, crypto, hashing, AI red-team) → `Security/Analysis/`. Offensive testing → `Security/Pentesting/`.
- **PR-ready SOP.** Front-matter (`type`, `title`, `description`, `tags`, dates), `# H1` matching title, top-of-page authority/scope blockquote, Table of Contents for multi-section docs, copy-paste-ready commands, Legal & Ethics block (cross-link `sop-legal-ethics.md`) where relevant, OPSEC consideration where relevant, "Related SOPs" tail block, working external links.
- **Navigation update obligation.** When adding or moving an SOP, update **all three** of: the matching `*-Index.md`, the corresponding domain index (`Investigations-Index.md`, `Analysis-Index.md`, `Pentesting-Index.md`, `Security-Index.md`), `README.md`, and `index.md`. The README + index pair is what makes the file appear in both Obsidian and Docusaurus.
- **Working links.** Wikilinks must resolve to real files. Use `Grep`/`Glob` to verify path and casing before committing — Obsidian fails silently, Docusaurus build does not.
- **Front matter on edits.** When meaningfully revising a file, bump `updated:` (or `template_version:`) in the YAML and the trailing `**Last Updated:**` line.
- **No CI.** There are no tests, no link-checker, no spellcheck. Manual diligence is the gate.

---

## 10. Refresh log

### 2026-04-25 (initial CLAUDE.md)

Snapshot at refresh time. SOP count by domain (counted from disk, not from README): Platforms 7, Techniques 9, Analysis 6, Pentesting 8 → 30 total. README still claims "28+ SOPs" — minor lag, not worth a separate edit unless touching the README anyway.

Most recent ten commits at this refresh: `Add GitHub Actions workflow to mirror to Codeberg`, `Update links to cases and resources in index.md`, `.`, `Updated index for bespoke docusaurus vault-sync plugin`, `Merged main indexes to README.md to make it work for Obsidian/Github and moved START.md to index.md to make it work for docusaurus website`, `Obisidan Links to Markdown for -> Docusaurus main index`, `Clean up introduction in index.md`, `Add CTF/Student folders and bespoke index for Intel Codex Docusaurus website`, `Moved Forensics to Analysis folder`, `Updated references to START instead of 00_START to make it work with bespoke docusaurus obisidan vault sync plugin`. Author attention has been concentrated on the dual-format publication pipeline (Obsidian vault ↔ Docusaurus site) rather than SOP content. The Forensics → Analysis move is recent; basename wikilinks resolve correctly but any relative-path link to the old `Security/Pentesting/sop-forensics-investigation.md` location would now be broken.

Watchlist state: platform SOPs and AD-pentest SOP are the strongest staleness candidates (X API pricing, Pushshift access changes, Kerberos TTP churn). AI/ML evasion SOP is on a quarterly review cadence and is currently the youngest (`Last Updated: 2025-10-17`). Legal/ethics, OPSEC, sensitive-crime, hashing, and entity-dossier are stable.

### 2026-04-25 (watchlist completion)

Closed the §7 gap by reading the three previously-skipped SOPs in full and assigning rot buckets:

- `Security/Analysis/sop-malware-analysis.md` → **medium** (tool versions pinned in §9.1; sandbox-tier offerings shift; abuse.ch service endpoints; dnSpy → dnSpyEx fork; Volatility 2 → 3 migration ongoing).
- `Security/Analysis/sop-reverse-engineering.md` → **slowly** (dominated by stable fundamentals — assembly, calling conventions, PE/ELF format, anti-debug primitives, exploitation mitigations; only the Android sub-section and Frida tooling drift) [inferred].
- `Security/Pentesting/sop-web-application-security.md` → **medium** (OWASP Top 10 pinned to 2021 release, Nuclei template ecosystem and tool matrix churn, cited CVE / platform-version examples age each year; SQLi/XSS/CSRF/IDOR/SSRF/XXE/SSTI fundamentals stable).

§7 preamble updated to remove the "intentionally absent" carve-out; the watchlist now covers all 30 SOPs on disk.

### 2026-04-25 (inferred-marker verification)

Verified the four `[inferred]` markers from the initial pass against actual repo state:

- §2 Dataview claim — was "A few index files." Grep confirms exactly **one** file (`Investigations/Investigations-Index.md`, two `dataview` fences). Tightened the bullet and dropped `[inferred]`.
- §4 Win/Linux/macOS triple coverage — original list (4 SOPs) was wrong-narrow. Grep for Windows command syntax (`powershell`, `certutil`, `Get-FileHash`, `fciv`, `HashMyFiles`) returns **11 SOPs**. Bullet rewritten with the actual file list; the triple-vs-single distribution is still `[inferred]` because verifying which 11 are true triples requires per-file inspection.
- §2 Docusaurus long-form rationale (`index.md` only) — `[inferred]` retained: only `index.md` uses the `intel-codex/` prefix (confirmed by grep), but the *reason* (Docusaurus sync scope) cannot be confirmed without the plugin config, which lives outside this repo.
- §7 Pushshift mod-only-since-2023 claim — `[inferred]` retained: `api.pushshift.io` references confirmed in `sop-platform-reddit.md` (6 hits across §3.2 / §6.1 / §10.2 [inferred section numbers]), but the access-policy fact requires external verification.

§7 also gained one new `[inferred]` marker on the `sop-reverse-engineering.md` rot-bucket call (judgment, not fact).

### 2026-04-25 (count reconciliation + Student-Exercises link fix)

- `README.md:21` — "**28+ SOPs**" → "**30+ SOPs**"; "**13 Security Procedures**" → "**14 Security Procedures**" (Pentesting 8 + Analysis 6 = 14, not 13). Investigations sub-count "16" was already correct (Platforms 7 + Techniques 9). CTF "9" left as claimed (out of in-scope SOP count).
- `index.md:24-25` — "**Total SOPs:** 20+" → "**Total SOPs:** 30+"; "Security (13)" → "Security (14)".
- `README.md:129` — broken link `Cases/Student-Exercises.md` (file doesn't exist) → `Cases/Student-Exercises/` (directory). No hub README exists in `Cases/Student-Exercises/`; consider creating one if the dual-format publication needs a navigable target.

### 2026-04-25 (sop-malware-analysis production-readiness pass)

Modeled on the `09f91e4` commit in the sibling `gl0bal01/malware-analysis-claude-skills` repo (Apr 12 2026, "Production-readiness pass: fix inaccuracies, add missing content, trim README"). A previous cosmetic version-bump pass (16+/12−) was applied and reverted before this one — see git reflog if archaeology is ever needed. **Pass stat:** 364+/27− across one file, file grew 2020 → 2357 lines.

**Front matter:** `template_version: 2025-09-18` → `2026-04-25`, `updated: 2026-04-25` added.

**Inaccuracies fixed:**
- Persistence (§4.2): clarified that there is no Win32 `CreateScheduledTask` function — the COM API is `ITaskService` → `ITaskFolder::RegisterTaskDefinition`. Added UNC-path watch.
- Suricata (§8): mixed legacy modifier syntax → modern sticky-buffer style (`http.method;` then `content:"POST";`). Site-local SID range guidance (1000000–1999999); placeholder SID `1234567` → `1000001`.
- IOC table: placeholder UUID `12345678-1234-1234-1234-123456789abc` → real UUID4 example with regen instruction.
- Empty `## ` heading restored to `## 9. Reporting & Documentation`.

**Tool renames (deprecated → current):**
- `Process Hacker` → `System Informer` (six call sites + appendix), with link to `github.com/winsiderss/systeminformer` and rename-context note.
- `peepdf` → `peepdf-3` (Python 3 fork; original is Python 2 / unmaintained).
- `sigmac` → `sigma-cli` (PyPI package), with explicit deprecation note for `sigmac`.
- `dnSpy` → `dnSpyEx` (already addressed in earlier reverted pass — re-applied here).

**New subsections added** (matching SOP's existing numbered-procedural style; all subsection numbers fit the existing TOC):
- **§3.5 Packed Sample Handling** (~70 lines) — entropy/import/section signals, packer table (UPX, ASPack, MPRESS, Themida, VMProtect, Enigma, custom), workflow with hash-recording for both packed/unpacked, `pe-sieve` / `hollows_hunter` dump techniques, sophistication signal mapping.
- **§4.3 Modern covert C2 channels** (~10 lines) — DoH tunneling, named-pipe C2, domain fronting, certificate-pinning failure mode.
- **§6.3 Modern PDF CVEs** (~7 lines) — CVE-2023-21608, CVE-2023-26369, CVE-2024-4367, CVE-2023-36664.
- **§6.4 Expanded VBScript deobfuscation** (~50 lines) — `Chr()` resolver, `StrReverse`, `Replace()` chains, `Execute`/`ExecuteGlobal`→`WScript.Echo` swap idiom, `GetObject` CLSID enumeration, variable-substitution tracing.
- **§6.7 HTA (HTML Application) Analysis** (~70 lines) — T1218.005 framing, MOTW context, COM enumeration, decode pipeline, canonical XMLHTTP+ADODB.Stream cradle, PowerShell cradle, inline `mshta` URL pattern, dynamic confirmation via Procmon.
- **§6.8 Disk Image Analysis (ISO/IMG/VHD/VHDX)** (~85 lines) — T1553.005 MOTW-bypass framing; 7-Zip extract / Linux loop-mount / Windows `Mount-DiskImage` / `qemu-img` conversion paths; LNK+hidden DLL canonical pattern; RTLO + double-extension checks; routing table to other §6 subsections.
- **§10.4 Modern EDR/AV Evasion Techniques** (~50 lines) — ETW patching (T1562.006), AMSI bypass (T1562.001) with correct `AMSI_RESULT_CLEAN=0` / `E_INVALIDARG=0x80070057` values, direct syscalls / Hell's-Gate / Halo's-Gate / Tartarus-Gate (T1106), PPID spoofing (T1134.004) via `UpdateProcThreadAttribute`, module stomping / DLL hollowing (T1055.013), callback-based shellcode execution; al-khaser/pafish/pe-sieve/hollows_hunter/ScyllaHide/TitanHide tool table.
- **§10.5 Common Pitfalls & Best Practices** — renumbered from §10.4.

**Markers:** zero `[verify YYYY-MM-DD]`, zero `[inferred]`. Every claim grounded in the sibling repo's already-validated content, Microsoft Learn-documented APIs (AMSI, ITaskService/ITaskFolder, UpdateProcThreadAttribute), MITRE ATT&CK technique pages, or Suricata 5+ documentation patterns.

**Bloat trim:** none made. Review found no clear bloat; the verbose §9.1 report template is intentional analyst-fill content.

**Known limitation:** §9.1 report template has nested code-fence ambiguity (outer ```markdown wraps inner ```yara / ```yaml without clean closes before next heading). Renders correctly in Obsidian and on GitHub but is fragile. Follow-up could flatten the template to a quoted block or split it into `Cases/Case-Template/04-Reports/` (matching the sibling repo's `assets/report_template.md` pattern).

### 2026-04-25 (Group A production-readiness passes — detection-evasion, reverse-engineering, forensics)

Three further passes on the same model as the malware-analysis pass. Sibling-repo cross-reference where applicable (`anti_analysis_bypass.md`, `detection-engineer/SKILL.md`, `malware-triage/`, `malware-report-writer/`). Aggregate stat: 1265+/240− across three files. All four Group A SOPs now refreshed.

**`Security/Pentesting/sop-detection-evasion-testing.md`** — 228+/49− (704 → 834 lines)
- Front matter + `**Last Updated:**`. ATT&CK pinned to v18.1.
- Caldera install fixed (v5.3.0 path: `--recursive`, `--insecure --build`, default-creds note, CVE-2025-27364 caveat).
- Atomic Red Team install fixed (`powershell-yaml` dep, `-Scope CurrentUser`, `-getAtomics`, GUID-based execution note).
- Infection Monkey URL fixed (Guardicore → Akamai); `[verify 2026-04-25]` retained on release-activity status.
- AMSI/ETW section: correct `AMSI_RESULT_CLEAN=0` / `E_INVALIDARG=0x80070057`, ETW patching `0xC3` ret primitive, T1562.001 + T1562.006.
- Process Injection expanded with T1055.001/.012/.013/.004, module stomping (noted as contested mapping), direct syscalls / Hell's-Gate / Halo's-Gate / Tartarus-Gate (T1106).
- New §4.2 #6 **PPID Spoofing** (T1134.004, ~25 lines); new §4.2 #7 **Callback-based Shellcode** (T1055, ~25 lines).
- Tools Reference: 8 new rows (al-khaser, pafish, pe-sieve, hollows_hunter, ScyllaHide, TitanHide, sysmon-modular, sigma-cli). Cobalt Strike → Fortra. Sysmon URL → learn.microsoft.com. EID 25/26 version notes.
- Markers: 1 `[verify 2026-04-25]` (Infection Monkey release status), 0 `[inferred]`. Bloat trim: none.

**`Security/Analysis/sop-reverse-engineering.md`** — 411+/45− (2276 → 2642 lines)
- Front matter (`template_version: 2026-04-25`, `updated: 2026-04-25`).
- dnSpy → dnSpyEx (5 sites + fork-context note). Process Hacker → System Informer.
- Anti-debug section expanded ~85 → ~155 lines: CheckRemoteDebuggerPresent, NtGlobalFlag (PEB+0x68 32-bit / PEB+0xBC 64-bit, value 0x70), Heap.Flags / Heap.ForceFlags, NtQueryInformationProcess (ProcessDebugPort=0x07, ProcessDebugObjectHandle=0x1E, ProcessDebugFlags=0x1F), DR0–DR3 hardware-breakpoint detection. T1622 mapped. ScyllaHide bypass references throughout.
- New §4 **Anti-VM / Sandbox Detection** (~80 lines): CPUID hypervisor bit + vendor-string table, registry artifacts, MAC OUI table, hardware heuristics, pafish / al-khaser / VBoxHardenedLoader. T1497.
- New §5 **ARM64 / Apple Silicon (Mach-O)** (~95 lines): file/otool/lipo triage, Mach-O segment model, code-signing / SIP / hardened-runtime, AArch64 + AAPCS64, iOS arm64 vs arm64e + PAC, FairPlay, dyld shared cache, lldb + Frida workflow with re-signing requirement.
- Packing rewritten (~50 → ~90 lines): packer-signature table (UPX, ASPack, PECompact, MPRESS, Themida/WinLicense, VMProtect, Enigma, custom) + entropy thresholds + pe-sieve / hollows_hunter memory-dump path.
- Markers: 1 `[verify 2026-04-25]` (PEB offsets beyond core fields), 1 `[inferred]` (CR4.TSD hypervisor mitigation effect). Bloat trim: none — stable fundamentals untouched per watchlist guidance.

**`Security/Analysis/sop-forensics-investigation.md`** — 526+/146− (1006 → 1385 lines, biggest pass — gaps were genuine)
- Front matter + Version 2.0 / Quarterly footer.
- Hash recommendation order: SHA-256 primary; MD5 / SHA-1 marked broken (Wang 2004 / SHAttered 2017).
- Volatility 2 → 3 migration completed: §4 Memory Analysis fully rewritten, V3 plugins (`hollowprocesses`, `linux.bash`, `yarascan`); V2 marked unmaintained since 2020.
- macOS RAM: Rekall / OSXPmem flagged EOL; Volexity Surge Collect Pro added (Apple Silicon).
- LiME / AVML modernized (TCP-streaming pattern, `--compress`, `CONFIG_STRICT_DEVMEM` note).
- MFT analysis: Sleuth Kit `icat 0` extraction step added; MFTECmd promoted as primary parser.
- `adb backup` flagged deprecated (Android 13+, OEM-disabled earlier); iOS AFU/BFU state distinction added.
- Cuckoo → CAPEv2; FTK Imager URL `accessdata.com` → `exterro.com`; Process Hacker → System Informer.
- New §3 **Cloud Evidence Acquisition**: AWS (CloudTrail/GuardDuty/VPC Flow), Azure/M365 (Activity Log/Entra ID/UAL with retention table), GCP/Workspace (Audit Logs/Reports API/Vault), SaaS (Okta/Slack/GitHub/Salesforce). Closes the inline gap; standalone `sop-cloud-forensics.md` still listed in §8 gaps.
- New §3 **Mobile Device Acquisition** rewritten: AFU/BFU, vendor matrix, libimobiledevice, iLEAPP/ALEAPP/MVT/APOLLO open-source parsers.
- New §4 **Modern Windows execution & activity artifacts** table: BAM/DAM, PCA, AmCache, ShimCache, SRUM, JumpLists, LNK, Recycle Bin, USN, $LogFile, Sysmon, EvtxECmd.
- New §4 **macOS Artifacts** subsection: APFS snapshots, FSEvents, KnowledgeC, Biome, Unified Logs (`tracev3`), BTM, TCC, mac_apt / APOLLO / UnifiedLogReader.
- New §4 **Linux Artifacts** subsection: systemd-journald, auditd, machine-id, persistence (cron/init/profile/LD_PRELOAD), btrfs/zfs/LVM snapshots.
- §4 **Email Analysis** rewrite: pffexport, header bottom-to-top read, SPF/DKIM/DMARC/ARC forensic interpretation, BEC pivots (UAL inbox rules, Recoverable Items), dnstwist for look-alikes.
- New §4 **Anti-Forensic Awareness** subsection (cross-ref to malware-analysis §10.4): evasion-technique × artifact-impact table.
- §5 **IOC defanging** convention added (hxxp / [.] / [@]).
- §4 Malware Triage compressed (~25 lines) with scope-guard blockquote and hand-off cross-reference to sop-malware-analysis.
- Markers: 15 `[verify 2026-04-25]` (mobile vendor matrices, M365 retention, Plaso / Vol3 versions, PCA parser docs), 0 `[inferred]`. Bloat trim: −25 lines on §4 Malware Triage.

**Section-§8 follow-on**: this Group A pass closes inline forensics-cloud coverage but does NOT close the standalone `sop-cloud-forensics.md` gap. Keep that gap listed in §8.

---

## 11. How Claude should help in this repo

- **Writing new SOPs.** Copy the structure of the closest existing SOP in the same folder. Match its front-matter style (inline vs. list `tags:`), heading style (numbered vs. named), and tail blocks (Tools Reference / Common Pitfalls / Related SOPs). Cross-link `sop-legal-ethics.md` and `sop-opsec-plan.md` as appropriate. Never invent commands, tool flags, CVE numbers, or citations — if a flag isn't in the official docs, leave it out and note the gap.
- **Auditing existing SOPs.** Use the watchlist (§7) as the entry point. Read the candidate file in full before proposing changes. For a refresh pass, prefer a diff (front-matter `updated:` bump, tool/version changes, link rot, replaced URLs) over a rewrite unless the user explicitly asks for one.
- **Generating cross-links.** Verify every wikilink target with `Glob` or `Grep` before committing. Use basename form for in-folder links and relative form for cross-folder unless the file is `index.md` (Docusaurus long form). When linking to `Cases/`, prefer Markdown relative links — case folders may be outside the Docusaurus sync.
- **Drafting case studies.** Start from `Cases/Case-Template/`. Use the `YYYY-NNN-Brief-Description` naming convention. Keep all subject data fictional unless real authorization exists. Reference `Cases/2025-001-Example-Investigation/` as the structural reference.
- **Refusals.** Decline to invent techniques, citations, CVE numbers, vendor pricing, statute numbers, or tool flags. Decline to draft adversary content (working malware, weaponized exploits, real CSAM-handling shortcuts) — this vault is defensive/educational. If unsure about scope or authority, ask before writing.
- **Commit policy (whole project).** Never commit without explicit user approval. Never `git push` without explicit user approval. The user runs commits themselves.
