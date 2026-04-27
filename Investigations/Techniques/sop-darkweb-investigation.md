---
type: sop
title: Darkweb Investigation
description: "Darkweb OSINT methodology: Tor and I2P navigation, hidden-service discovery, marketplace observation, vendor PGP pivots, and ransomware leak-site tracking — open-source observation only."
tags:
  - sop
  - darkweb
  - tor
  - i2p
  - onion
  - marketplace
  - ransomware
  - pgp
  - osint
  - investigation
created: 2026-04-26
updated: 2026-04-26
template_version: 2026-04-26
---

# Darkweb Investigation

> **Authorized environments only.** This SOP covers open-source observation of publicly reachable hidden services for lawful investigative, journalistic, threat-intelligence, or research purposes. It is **not** a buyer's guide, a vendor manual, or a deanonymization playbook. Several jurisdictions (UK Computer Misuse Act 1990, US 18 U.S.C. §1030, EU NIS2 / Directive 2013/40, AU Criminal Code Part 10.7, CA s.342.1) criminalize unauthorized access — operating an "investigation" account without written authorization, paying for goods, or registering on closed forums to gather intelligence can each cross the line from observation into participation. Read [[sop-legal-ethics|Legal & Ethics]] before every engagement and [[sop-opsec-plan|OPSEC Plan]] before configuring the environment. CSAM and trafficking findings are escalated immediately per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] — not preserved locally, not analyzed in-line, not cross-referenced.

---

## Table of Contents

1. [Objectives & Scope](#1-objectives--scope)
2. [Pre-Engagement & Authorization](#2-pre-engagement--authorization)
3. [Network Infrastructure & Access](#3-network-infrastructure--access)
4. [Hidden-Service Discovery](#4-hidden-service-discovery)
5. [Marketplace OSINT (Observation-Only)](#5-marketplace-osint-observation-only)
6. [Vendor PGP Key Pivots](#6-vendor-pgp-key-pivots)
7. [Forum & Community Investigation](#7-forum--community-investigation)
8. [Ransomware Leak-Site Tracking](#8-ransomware-leak-site-tracking)
9. [State-Actor & Sanctions-Evasion Indicators](#9-state-actor--sanctions-evasion-indicators)
10. [Analyst Hygiene & Session Discipline](#10-analyst-hygiene--session-discipline)
11. [Evidence Collection](#11-evidence-collection)
12. [Pivots & Cross-Platform Correlation](#12-pivots--cross-platform-correlation)
13. [Hand-off Boundaries (Scope Contract)](#13-hand-off-boundaries-scope-contract)
14. [Tools Reference](#14-tools-reference)
15. [Risks & Limitations](#15-risks--limitations)
16. [Common Pitfalls](#16-common-pitfalls)
17. [Real-World Scenarios](#17-real-world-scenarios)
18. [Emergency Procedures](#18-emergency-procedures)
19. [Related SOPs](#19-related-sops)
20. [External / Reference Resources](#20-external--reference-resources)

---

## 1. Objectives & Scope

### What this SOP covers

- Reaching publicly indexed hidden services on Tor and (briefly) I2P
- Discovering, observing, and preserving evidence from marketplaces, forums, and ransomware leak sites
- Building vendor / actor fingerprints from PGP keys, handles, and post-style markers
- Establishing the investigator-side hygiene that prevents cross-investigation linkability
- Capturing onion-side artifacts in a court-defensible manner (hash, WARC, screenshot, timestamp)

### What this SOP **does not** cover

- **Offensive deanonymization** (operating exit relays, exploiting Tor Browser, traffic-correlation against named targets, Tor-network attacks). Out of scope and out of authorization for OSINT-tier work.
- **Buying, registering, escrowing, depositing, or transacting** on any market. Open-source observation only.
- **CSAM platforms.** This SOP gives **no** instructions for accessing them. CSAM findings (incidental, including a search hit, an aggregator listing, or an indexer category) are routed immediately per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]. Do not "verify," do not screenshot the content, do not preserve the bytes — preserve only the URL and the timestamp, then escalate.
- **Blockchain tracing.** When a wallet address is observed in a listing, dump room, or escrow pointer, this SOP **stops at the observation**. Tracing is the job of [[sop-blockchain-investigation|Blockchain Investigation]]. AML-analyst quick-reference for crypto context lives in [[sop-financial-aml-osint|Financial & AML OSINT]] §5.
- **Mixer / privacy-pool / cross-chain-bridge tracing.** Routed to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. See [[sop-financial-aml-osint|Financial & AML OSINT]] for AML-analyst quick-reference on the mixer landscape.
- **Ransomware payload analysis.** Binaries collected from leak-site dumps go to [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]].
- **Validating leaked credentials, card data, or PII samples.** Even a "test login" is unauthorized access in most jurisdictions; route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] if the data is current and the population is identifiable.

### Threat-model framing

The darkweb-OSINT analyst sits in the same threat-model class as the targets they observe — sites are run by criminal operators, hostile services, and (frequently) by law enforcement honeypots. Three failure modes drive this SOP:

1. **Self-deanonymization** — investigator account leaks identity into the target environment (cross-context login, persona reuse, unique fingerprint).
2. **Cross-investigation linkability** — a single Tor session is reused across two unrelated investigations and traffic-pattern correlation links them.
3. **Evidentiary contamination** — investigator engages with a vendor, registers an account, or "tests" a payment, undermining admissibility and crossing into participation.

Stage A–E discipline: assume every action is logged by a hostile counterparty.

---

## 2. Pre-Engagement & Authorization

Before any onion fetch, complete the canonical pre-engagement triad:

### 2.1 Authorization checklist

- [ ] **Written authorization** from the engagement owner (employer, client, editor, supervising counsel) naming darkweb collection as in-scope. Verbal is insufficient.
- [ ] **Jurisdiction review:** does any statute in the analyst's jurisdiction or the target's jurisdiction criminalize the planned access? Mere viewing of a hidden service is not universally lawful — see [[sop-legal-ethics|Legal & Ethics]] §"Jurisdictional Frameworks" for the canonical rules.
- [ ] **Scope document:** explicit list of target onion addresses or target categories, time window, and stop conditions (e.g., "stop on CSAM, stop on active threat-to-life, stop on credential validation").
- [ ] **Reporting destination identified up-front** — MLRO, in-house counsel, FIU, NCMEC CyberTipline, NCA / FBI / Europol / national CERT. Routing is decided **before** observation, not after.
- [ ] **Wellness plan** for analysts who will be exposed to graphic content (rotation, two-person rule, time-limited sessions). See [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] §"Researcher-Wellness References."

### 2.2 Environment prerequisites

- Investigation host is **isolated** from the analyst's clearnet identity. Tails (live USB) or Whonix (Workstation VM behind Whonix-Gateway) are the two canonical environments — see [[sop-opsec-plan|OPSEC Plan]] §3 (Investigation environment isolation) and §6 (Browser hardening).
- **Never** run Tor Browser on the same host that holds personal mail, social-media sessions, or password managers tied to the analyst's identity.
- VPN-before-Tor (VPN→Tor) versus Tor-alone: see [[sop-opsec-plan|OPSEC Plan]]. The default for OSINT-tier work is **Tor alone, on Tails**, unless a specific threat model requires the additional hop.
- Time source synchronized (NTP via chrony or equivalent) — evidence timestamps are court-relevant.
- Disk encryption enforced on the host that stores collected evidence.

### 2.3 Disclosure-ready posture

- Every session is logged in real time per [[sop-collection-log|Collection Log]] (URL queried, timestamp UTC, action, hash of saved artifact).
- Capture artifacts are stored under `/Evidence/{case_id}/Darkweb/YYYYMMDD-HHMM/` (file structure in §11).
- The case file is encrypted at rest (LUKS, VeraCrypt, FileVault, BitLocker) and the key is held separately from the data.

---

## 3. Network Infrastructure & Access

### 3.1 Tor

- **What it is:** the dominant anonymity overlay; the only one with broad criminal-marketplace, leak-site, and forum coverage. Source-of-truth: [Tor Project](https://www.torproject.org/) [verify 2026-04-26].
- **Address format:** v3 onion services use 56-character base32 addresses ending in `.onion` (e.g. `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.onion`). **v2 onions (16-char) were deprecated 2021-07-15 and disabled in Tor 0.4.6+ on 2021-10-15** [verify 2026-04-26]; any v2 reference in 2026 is dead infrastructure. If a v2 address is the only artifact, it survives only as a historical fingerprint.
- **Tor Browser:** default access tool. Patched Firefox ESR fork. Three security levels (Standard / Safer / Safest) — Safer disables JavaScript on non-HTTPS sites; Safest disables it everywhere. Default to **Safer or Safest** for darkweb work; the marginal site that requires JavaScript is rarely worth the deanonymization risk.
- **Mullvad Browser:** Tor Project + Mullvad joint project (April 2023) — Tor Browser hardening **without** the Tor network, intended for use over a trusted VPN. Not a darkweb-access tool; useful for clearnet pivots from the same hardened-browser fingerprint.

### 3.2 Operating environments

| Environment       | Pattern                                          | Strength                                                                    | Trade-off                                                            |
| ----------------- | ------------------------------------------------ | --------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **Tails**         | Live USB, amnesic, all traffic via Tor           | No persistence ⇒ no host artifacts; widely audited                          | Persistence requires explicit volume; not suited for long campaigns  |
| **Whonix**        | Two-VM split (Gateway + Workstation), Tor-forced | Strong network isolation; Workstation cannot leak its IP even if root-owned | Heavier; requires VirtualBox / KVM / Qubes host                      |
| **Qubes + Whonix**| Qubes OS template-based AppVMs                   | Best-in-class compartmentalization (per-investigation `whonix-ws` AppVM)    | Steep learning curve; recommended for sustained darkweb workload     |
| **Tor Browser on host OS** | TBB on macOS / Linux / Windows          | Quick start                                                                 | Host artifacts persist; cross-context linkability risk; **not recommended** for sensitive work |

Cross-link: [[sop-opsec-plan|OPSEC Plan]] §3 for the canonical environment build, including Whonix Gateway pinning and Tails persistent-volume hygiene.

### 3.3 Other anonymity networks

- **I2P** (Invisible Internet Project) — `.i2p` eepsites; smaller user base; some marketplace and forum traffic migrated post-Hydra (2022). Access via `i2pd` (C++) or `i2p` (Java) router. Not interchangeable with Tor — separate browser profile.
- **Lokinet** — Oxen-network onion routing; small user base, niche marketplace presence [verify 2026-04-26].
- **Freenet / Hyphanet** — file-sharing-oriented; Hyphanet is the 2023 rebrand of Freenet [verify 2026-04-26]. Limited current investigative relevance outside specific forum migrations.
- **ZeroNet** — peer-to-peer site network using Bitcoin keys; effectively dormant after 2021 [verify 2026-04-26]; historical artifacts only.
- **Yggdrasil** / cjdns — mesh networks, not anonymity tools; not in scope.

Default network is Tor unless the target is known I2P-only.

---

## 4. Hidden-Service Discovery

### 4.1 Indexes and aggregators (clearnet-reachable)

These sites publish curated `.onion` lists. Treat each as a starting point for **discovery only** — accuracy varies, listings include scams and impersonators, and several have been seized and re-stood-up by unknown operators.

| Resource                      | Purpose                                            | URL pattern                            | Notes                                                       |
| ----------------------------- | -------------------------------------------------- | -------------------------------------- | ----------------------------------------------------------- |
| **Ahmia**                     | Search engine for indexed Tor hidden services      | `https://ahmia.fi`                     | Legitimate, hosted by Juha Nurmi; filters CSAM by policy [verify 2026-04-26] |
| **Tor.taxi**                  | Curated list of currently-online onions            | `https://tor.taxi`                     | Active aggregator; phishing-aware; status varies [verify 2026-04-26] |
| **dark.fail**                 | Marketplace status / canonical-mirror tracker      | `https://dark.fail`                    | Tracks marketplace uptime + signed mirror fingerprints [verify 2026-04-26] |
| **Daunt**                     | Curated index                                      | clearnet + onion                       | Volatile; verify on session [verify 2026-04-26]              |
| **Onion.live / OnionLive**    | Onion uptime monitor                                | clearnet                               | Multiple impersonators; verify [verify 2026-04-26]            |
| **Hidden Wiki (canonical)**   | Historical wiki-style index                         | many forks / impersonators              | Most public Hidden Wiki copies are scam-laden; treat as adversarial source |

**Rules of thumb:**

- Cross-check at least two indexes before treating an onion as canonical.
- Mirror-list signing (PGP-signed canonical-URL list, e.g. dark.fail's signed `pgp.txt`) is the strongest defense against phishing-mirror traps.
- Several indexes themselves have v2/v3 history; an index's own onion address has a canonical version maintained by its operator — pin it once and verify the PGP-signed canonical list at every refresh.

### 4.2 Discovery from clearnet pivots

Most darkweb investigations start clearnet-side, not from an index:

- **Telegram channels** — marketplaces and ransomware groups frequently advertise canonical onion mirrors via Telegram. Pivot via [[../Platforms/sop-platform-telegram|Telegram SOP]].
- **X / Twitter** — leak announcements, vendor handles, ransomware-group shaming posts. Pivot via [[../Platforms/sop-platform-twitter-x|Twitter/X SOP]].
- **Reddit** — subreddits historically cataloged darkweb resources; many were banned 2018–2022 but archived posts remain. Pivot via [[../Platforms/sop-platform-reddit|Reddit SOP]].
- **GitHub / Gitea / Codeberg** — leak repositories, ransomware tooling, indexer source code. Don't fork or clone in an attribution-tied account.
- **Paste sites** (pastebin, justpaste.it, dpaste, ghostbin) — credential dumps, leak announcements, ransom notes. Use [[sop-collection-log|Collection Log]] for capture.
- **Clearnet news + Bellingcat / OCCRP / DFRLab** — investigative journalism frequently surfaces canonical onion addresses with editorial vetting.
- **Threat-intel feeds** — MITRE ATT&CK Groups, MISP, OpenCTI, vendor blogs (Mandiant, Recorded Future, Group-IB, Trend Micro, Talos, Unit 42, DFIR Report). See [[sop-entity-dossier|Entity Dossier]] §"Sanctions, Beneficial-Ownership & Corporate Registries" for the threat-actor TI inventory.
- **Court filings** — DOJ press releases, Europol IOCTA, indictments often quote onion addresses verbatim.

### 4.3 Verification before access

For each candidate onion:

1. Capture the full address verbatim with timestamp and source (which clearnet pivot or which index).
2. If the operator publishes a PGP-signed canonical-URL list, verify the signature against the operator's known fingerprint **before** visiting.
3. Note the discovery context — a marketplace mirror found on dark.fail with a signed canonical entry is high-confidence; the same string copied from a Hidden Wiki fork is low-confidence.
4. Log the candidate per [[sop-collection-log|Collection Log]] before clicking — discovery-only, no fetch yet.

---

## 5. Marketplace OSINT (Observation-Only)

### 5.1 What you collect (and what you do not)

**Collect (publicly visible, no account required):**

- Marketplace name, canonical onion address, and current PGP-signed mirror list
- Operator handles, support contact (where published), forum cross-references
- Listing IDs visible in the public index (do **not** create an account to see "logged-in only" listings)
- Vendor handles, vendor PGP keys, vendor join date, vendor rating-count if publicly displayed
- Product category taxonomy (drugs, fraud, data, hacking, services — note any **prohibited categories the market itself lists**, which is itself OSINT)
- Listed currencies (BTC / XMR / ETH / LTC / USDT) and escrow type (multisig / centralized / FE — finalize-early)
- Dispute-resolution policy excerpts (often published)
- Marketplace TOS / rules pages (frequently informative about LE-evasion posture)

**Do not collect / do not do:**

- ❌ Register an account, even with a "burner" identity — most jurisdictions and most engagement scopes treat marketplace registration as participation, not observation.
- ❌ Deposit funds, even small "test" amounts.
- ❌ Initiate a chat with a vendor "to verify."
- ❌ Open executable downloads or sample files in any environment that is not airgapped and disposable. Many "sample" archives are credential-stealers or RATs.
- ❌ Submit feedback, vote on disputes, or react to listings.
- ❌ Solicit specific listings ("can you ship to X").
- ❌ Use a keyword search that itself crosses a legal line (e.g. searching CSAM categories — even the search query is logged by the operator and may be subpoenaed).

### 5.2 Marketplace lifecycle (historical reference)

Marketplaces fail in three patterns. Knowing the lifecycle helps interpret current snapshots:

- **Law-enforcement takedown.** Silk Road (FBI 2013), Silk Road 2 (2014), AlphaBay + Hansa (Operation Bayonet, July 2017), Wall Street (2019), DarkMarket (2021), Hydra (German BKA + DOJ, 2022-04-05) [verify 2026-04-26], Genesis Market (Operation Cookie Monster, April 2023) [verify 2026-04-26].
- **Exit scam** (operators disappear with escrow). Evolution (2015), Empire Market (August 2020) [verify 2026-04-26], Dark0de Reborn (2022) [verify 2026-04-26], several smaller markets per quarter.
- **Voluntary closure.** Dream Market (2019), occasional principled shutdowns; rare relative to the first two patterns.

A current marketplace observation is always relative to this lifecycle. If a market was seized last week and the same name is still listed on an aggregator, that listing is either (a) a phishing mirror, (b) an LE-controlled honeypot continuation, or (c) an unrelated namesquatter. Document accordingly.

### 5.3 Marketplace categories (defensive scope only)

The category taxonomy itself is investigative signal:

| Category                          | Investigative relevance                                                            | Hand-off                                                |
| --------------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------- |
| Narcotics                         | LE & journalist scope; vendor PGP pivots, pricing trends, regional clustering      | LE referral via [[sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] |
| Fraud / carding (BidenCash, lineage of Joker's Stash, Brian's Club) | Identity-theft and BIN-attack defense; victim notification                  | FIU / FBI IC3 / national equivalent                     |
| Stolen credentials / combo lists  | Account-takeover defense; victim-population scoping                                 | DPO / breach-notification authority                     |
| Hacking tools / 0-days / RaaS     | Threat-intel; capability assessment                                                  | [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] for any sample |
| Counterfeit documents             | Identity-fraud defense; geographic clustering                                        | LE referral                                              |
| Data brokers (PII / KYC bypass)    | Privacy-violation evidence; victim identification                                    | DPO + LE                                                 |
| Weapons                           | Rare on darkweb (most listings are scams); LE-priority when authentic               | LE referral immediate                                    |
| Trafficking / forced services     | **Immediate escalation** — do not "verify"                                          | [[sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] |
| CSAM categories                   | **Hard-stop. Preserve URL + timestamp only. Do not browse. Escalate.**             | [[sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] (NCMEC / Project Arachnid / national CSE unit) |

### 5.4 Per-listing capture pattern

For each in-scope listing observed:

1. Single-File capture or Tor-Browser screenshot of the public listing page (no account login).
2. Note: listing ID, vendor handle, vendor PGP fingerprint (if shown), price, currency, claimed origin/destination, claimed quantity, escrow type.
3. Hash the captured artifact (SHA-256) immediately; log hash + URL + timestamp UTC per [[sop-collection-log|Collection Log]].
4. Pivot only on **non-content** fingerprints: PGP key (§6), wallet address (hand-off — §13), image reverse-search of listing photo (where the photo itself is not contraband), language / timezone heuristics.
5. Mark the listing record with marketplace lifecycle status (active / seized / exit-scammed) at observation time.

---

## 6. Vendor PGP Key Pivots

PGP keys are the most durable vendor fingerprint on the darkweb. Vendors frequently rotate handles, change marketplaces, and reuse keys; the fingerprint is the canonical link.

### 6.1 What to extract

For every published vendor PGP block:

- **40-character SHA-1 fingerprint** (e.g. `1234 5678 90AB CDEF 1234 5678 90AB CDEF 1234 5678`). Treat as the primary key.
- **Long key ID** (last 16 hex chars of the fingerprint). Short 8-char IDs are collision-vulnerable (the [Evil 32](https://evil32.com) demonstration generated colliding short IDs for the entire Web of Trust strong set in 2014); never pivot on short IDs alone.
- **Algorithm and key size** (RSA-2048 / RSA-4096 / ed25519 / ecdsa).
- **Creation date** (UID self-signature timestamp).
- **UID strings** — name, email, comment fields. Frequently contain handle, marketplace, or operational hints.
- **Subkeys** — separate signing / encryption subkeys, each with their own creation and expiry timestamps.

Tools: GnuPG (`gpg --import`, `gpg --list-packets`, `gpg --fingerprint`), Sequoia PGP (`sq inspect`), kbpgp, pgpdump.

### 6.2 Pivot surfaces

| Surface                                        | What it tells you                                                                | Notes                                                                                |
| ---------------------------------------------- | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| **keys.openpgp.org**                           | Verified-email keyserver (Hagrid). Returns only keys whose owners verified the UID email | Limited returns for darkweb actors; valuable when present                            |
| **keyserver.ubuntu.com / pgp.mit.edu**         | Legacy SKS-protocol keyservers                                                    | SKS keyserver pool effectively shut down in 2019; remaining servers run Hockeypuck. Many 2010s vendor keys live here [verify 2026-04-26] |
| **keybase.io**                                  | Identity-bound keys (now Zoom-owned, dev paused circa 2022) [verify 2026-04-26] | Useful for clearnet identity → key cross-reference                                   |
| **WKD (Web Key Directory)**                    | Domain-bound keys served via `.well-known/openpgpkey/`                            | Less common in darkweb context but worth checking for clearnet pivots                |
| **Marketplace "vendor profile" pages**         | Multiple keys per vendor across marketplaces                                       | Capture each, hash each, track creation-date cluster                                 |
| **Forum signature lines and welcome posts**    | Key advertised at account creation                                                 | Often the highest-confidence "this account belongs to that key" link                  |
| **PGP-signed canonical-URL lists** (dark.fail) | Operator's own fingerprint                                                         | Strong attribution signal for marketplace operators                                   |

### 6.3 Vendor-pivoting workflow

1. **Collect** all PGP blocks for the target handle (across marketplaces, forums, mirrors).
2. **Compare fingerprints** — same fingerprint across markets is strong evidence of the same operator. Different fingerprints with overlapping UID metadata is weaker but still useful.
3. **Search public keyservers** for the fingerprint to find clearnet UIDs (real-name leaks via early Web-of-Trust cross-signatures, common). The 2018 academic paper "[The Russian Twin: A Social-Engineering Attack on the Web of Trust](https://example.invalid)" type of analysis is overkill for OSINT — fingerprint match plus UID is usually enough [verify 2026-04-26].
4. **Check key creation dates** — vendors who use a "fresh" key created the day before first listing are signalling either (a) operational discipline or (b) fronting for a takedown-survivor. Compare against the vendor's claimed join date.
5. **Subkey rotation** — vendors who rotated encryption subkeys after a known LE event are likely aware of the takedown; correlate subkey creation timestamps against public LE-event timeline.
6. **Cross-link** the vendor PGP record into the entity dossier — see [[sop-entity-dossier|Entity Dossier]] for the schema.

### 6.4 Preservation

- Save the full ASCII-armored block as a `.asc` file under `/Evidence/{case_id}/Darkweb/pgp/`.
- Run `gpg --import --import-options show-only` to verify parseability without polluting the local keyring (or use a disposable keyring with `--keyring`).
- Hash the `.asc` (SHA-256) and log with the source URL, capture timestamp, and observed UID.
- Never sign or encrypt with the captured key — generates evidentiary noise and may signal observation to the operator.

---

## 7. Forum & Community Investigation

### 7.1 Forum types

- **Marketplace forums** — vendor-customer disputes, market-status discussion (e.g. "is XMarket exit-scamming?"). Often readable without an account.
- **Hacking forums** — Exploit, XSS, RAMP, BreachForums lineage. BreachForums history: **founder Conor Brian Fitzpatrick ("pompompurin") arrested 2023-03-15** [verify 2026-04-26]; site re-launched under new admin lineage (Baphomet, then ShinyHunters / Anastasia clusters); FBI seized successor instances multiple times through 2024–2025. Each re-launch is its own investigation — capture canonical URL state at observation, do not assume continuity.
- **State-actor recruitment / disinformation forums** — RaidForums lineage, language-specific forums (Russian, Chinese, Persian, Arabic). Often invitation-only; treat invitation as an authorization escalation.
- **Whistleblower drops** — SecureDrop instances (newsroom-operated, lawful) are not in the same risk class as illicit forums. Collect canonical SecureDrop list at [securedrop.org/directory](https://securedrop.org/directory/) [verify 2026-04-26].
- **CSAM-adjacent forums** — **hard-stop.** No instructions; immediate escalation via [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]].

### 7.2 Pseudonym fingerprinting

For each tracked pseudonym:

- Username, including punctuation / capitalization variants
- Avatar (reverse-image search via [[sop-image-video-osint|Image & Video OSINT]])
- Signature line (PGP fingerprint, contact methods, ideological markers)
- Post-style markers — language, timezone of activity, idioms, typographical habits, code-switching patterns
- Cross-forum reuse — search same handle on Exploit / XSS / RAMP / Dread / Telegram / clearnet (Reddit, GitHub, X)
- Account creation date relative to known LE events (suspicious if "fresh" account immediately starts high-volume vending)

**Limits.** Stylometry / linguistic-fingerprinting is unreliable below ~1,000 words of writing per author and even then is contested in court; treat it as a soft pivot, not a primary attribution.

### 7.3 Engagement boundary

- **Read public posts only.** Most marketplace forums and Dread/Endchan-style boards have public-readable threads.
- **Do not register an account** unless the engagement scope explicitly permits it and counsel has reviewed.
- **Do not ask questions, post, react, or upvote.** Even a "lurker" account with a single post is a participation event.
- **Capture before content disappears.** Forums delete aggressively; archive at first observation.

---

## 8. Ransomware Leak-Site Tracking

### 8.1 Defensive purpose

Ransomware leak-site monitoring serves **defensive** ends: victim early-warning (notify victim before public-shaming countdown expires), IOC extraction (binaries linked from leak posts), TTP attribution (MITRE ATT&CK mapping), and ransom-payment-pattern analysis. The work is open-source observation of public extortion infrastructure.

### 8.2 Active groups (fast-rot — verify at every refresh)

The leak-site landscape rotates on a months-to-quarters cadence. Treat any list as a snapshot. As of 2026-04-26 [verify 2026-04-26]:

- **LockBit** — Operation Cronos disruption 2024-02-19 (NCA / FBI / Europol; takedown of infrastructure, recovery of decryptors); residual operations and re-launched leak sites surfaced through 2024–2025. Canonical group cluster but materially weaker post-Cronos.
- **BlackCat / ALPHV** — FBI takedown 2023-12-19 (decryption tool released); apparent operator exit-scam against affiliates in March 2024 (Change Healthcare ransom retained, affiliates unpaid). Effectively defunct as an operating brand by mid-2024.
- **Cl0p (Clop)** — recurrent zero-day-exploitation pattern (MOVEit 2023, GoAnywhere 2023, Cleo 2024). Long-running, infrastructure-resilient.
- **Black Basta** — active through 2024–2025; internal "BlackBastaLeaks" chat-log dump February 2025 surfaced operational detail.
- **Akira** — active; cross-platform (Windows + Linux/ESXi).
- **RansomHub** — emerged early 2024 as a major BlackCat-affiliate destination.
- **Play, Hunters International, Medusa, Qilin, 8Base, Cactus, INC Ransom** — active leak-site operators across 2024–2025.

This list is illustrative, not authoritative. Verify against the aggregators below at every session start.

### 8.3 Aggregators and feeds

| Resource                   | Maintainer                                  | URL                                | Notes                                                       |
| -------------------------- | ------------------------------------------- | ---------------------------------- | ----------------------------------------------------------- |
| **ransomwatch**            | Joshua Penny et al. (open source)            | `https://ransomwatch.telemetry.ltd` | Auto-collected; commit history is itself an IOC source [verify 2026-04-26] |
| **ransomware.live**        | Julien Mousqueton                            | `https://www.ransomware.live`        | Active dashboard + JSON API [verify 2026-04-26]              |
| **ransomlook.io**          | RansomLook project                           | `https://www.ransomlook.io`          | Group catalog + post archive [verify 2026-04-26]             |
| **ecrime.ch**              | eCrime.ch                                    | `https://ecrime.ch`                  | Eastern-Europe-aware analyst feed [verify 2026-04-26]        |
| **DarkFeed (commercial)**  | DarkFeed                                     | `https://darkfeed.io`                | Commercial threat-intel; cross-refs leak posts to known groups [verify 2026-04-26] |
| **Recorded Future / Mandiant / CrowdStrike / Group-IB** | Vendor reports               | subscription                        | Per-quarter retrospectives; canonical group lineage          |
| **MITRE ATT&CK Groups**    | MITRE                                        | `https://attack.mitre.org/groups/`   | Group → TTP mapping                                          |
| **MISP / OpenCTI feeds**   | self-hosted                                   | local                                | For organizations that ingest IOCs operationally             |
| **CISA #StopRansomware**   | CISA                                          | `https://www.cisa.gov/stopransomware` | Authoritative US advisory series with IOCs and mitigations [verify 2026-04-26] |

### 8.4 Capture procedure

For each leak post observed:

1. **Capture the post page** — Single-File HTML + screenshot. Preserve the victim claim, the listed sample-data filenames, the countdown timer if present, and any ransom-amount indicator.
2. **Do not download leaked data**. Many leak sites publish PII, PHI, or PCI data of identifiable victims. Possession is a separate legal question; route via counsel and victim-notification channels. If sample preservation is necessary for IOC extraction, scope it explicitly with counsel before fetching.
3. **Hash the captured page** (SHA-256) and log with timestamp UTC and onion source.
4. **Extract IOCs:** any mentioned RaaS-affiliate handle, contact email, Telegram channel, payment wallet, mirror onion. Wallet addresses **stop here** — hand off to [[sop-blockchain-investigation|Blockchain Investigation]] per §13. Contact handles pivot via [[../Platforms/sop-platform-telegram|Telegram SOP]].
5. **Cross-reference** the victim claim against public victim disclosure: SEC 8-K filings (US, materiality threshold), state breach-notification portals (NY DFS, CA AG, MA AGO), EU Article 33 GDPR notifications, victim's own status page or press release. Many groups post claims days-to-weeks before public disclosure; the lead time is the defensive value.
6. **Notify the victim** (if engagement scope permits) before the countdown expires. Routing typically goes through the victim's own security contact, an ISAC, a national CERT, or a recognized sector-specific feed (FS-ISAC, H-ISAC, MS-ISAC).
7. **Hand off any binary samples** to [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] for static/dynamic analysis. Never execute leak-site downloads on the analyst host or any non-isolated VM.

### 8.5 Operational hygiene specific to leak-site work

- Leak-site landing pages have historically hosted browser-exploit JavaScript. **Run with Tor Browser at "Safer" or "Safest"** (JavaScript disabled).
- Several leak sites fingerprint visitors and rate-limit aggressively; use fresh circuits and back off on 429s.
- Multi-tab leak-site browsing in a single Tor Browser instance can cross-correlate sites — one tab per session is the discipline for sensitive observations.

---

## 9. State-Actor & Sanctions-Evasion Indicators

### 9.1 Indicators

State-actor and sanctions-evasion overlap is a known darkweb-side pattern:

- **OFAC SDN crypto entries** that resolve to darkweb-advertised wallet addresses. The OFAC SDN list includes Digital Currency Address (DCA) entries by chain (XBT, ETH, USDT, XMR); a DCA hit in a marketplace listing or leak-site dump is a high-priority sanctions-evasion pivot. See [[sop-financial-aml-osint|Financial & AML OSINT]] §3 for the canonical sanctions catalog.
- **DPRK-cluster activity** — Lazarus Group, APT38 — historically tied to Sinbad.io (seized 2023-11-29) and predecessor Blender.io (2022). Mixer use observed downstream of a verified DPRK-cluster wallet is a strong sanctions-evasion signal; routed to [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]].
- **GRU / IRGC / MSS** indicators — disinformation-forum recruitment, leaked-data resale, ransomware-group affiliation. Open-source attribution is contested; defer to vendor and government attribution rather than in-line analyst conclusions.
- **Ransomware groups under sanctions** — Treasury OFAC has designated specific ransomware groups (Evil Corp 2019; varied since). Paying a sanctioned group is a US sanctions violation; capture observation may inform victim-side legal posture.

### 9.2 Defensive scope

- Cross-link sanctions hits to [[sop-financial-aml-osint|Financial & AML OSINT]] for the canonical sanctions framework and time-stamping discipline (sanctions status changes; record both activity timestamp and sanctions-list state at that time).
- Do not engage. State-actor-affiliated infrastructure and forums are out of scope for OSINT-tier observation beyond URL-level capture; engagement requires explicit national-CERT or LE coordination.

---

## 10. Analyst Hygiene & Session Discipline

### 10.1 Cross-context separation (the central rule)

**Never authenticate to a clearnet identity from a Tor Browser session.** This is the single most-violated darkweb-OSINT rule and the source of most analyst-side deanonymizations.

- No personal Gmail / Outlook / iCloud login.
- No personal social-media login.
- No password-manager unlock that holds clearnet credentials.
- No "I'll just check my work mail real quick."
- No clearnet site in the same Tor Browser instance that holds a darkweb tab.

If a clearnet pivot is required mid-investigation (e.g. cross-reference a leak post against a clearnet news article), use a **separate browser** on a separate VM or a separate Tails session — see [[sop-opsec-plan|OPSEC Plan]] §3.

### 10.2 Per-investigation circuit and identity

- One investigation per Tor Browser session (or per Whonix Workstation snapshot).
- Use **New Identity** (Ctrl+Shift+U in Tor Browser) between unrelated investigations.
- Use **New Tor Circuit for this Site** when a target rate-limits or fingerprints.
- Restart Tails between sustained campaigns; for Whonix, restore from clean snapshot.

### 10.3 Browser security level

- **Safer or Safest** is the default for darkweb work. JavaScript is the leading client-side exploit vector and is rarely worth the deanonymization risk on hostile sites.
- **Standard** is acceptable only on clearnet pivots from a Mullvad-Browser session, never on a marketplace or leak-site.
- Never install Tor Browser extensions beyond the bundled NoScript / HTTPS-Everywhere — extensions are fingerprintable.

### 10.4 Download discipline

- Treat every download as malicious until proven otherwise.
- Tails: do not open downloaded files in the Tails session — quarantine to airgap or to a Whonix Workstation snapshot dedicated to triage.
- Whonix: open downloads only in a disposable VM dedicated to that single artifact. Hash on quarantine, then route to [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]].
- Do not open Office documents, PDFs, or archives from leak sites without explicit malware-analysis routing.

### 10.5 Session log

Per [[sop-collection-log|Collection Log]] format, record per session:

- Session start timestamp (UTC)
- Environment (Tails build / Whonix snapshot ID)
- Tor Browser version
- Investigation case ID
- Target onion(s) accessed, with timestamps per fetch
- Artifacts saved (path + SHA-256)
- Session end timestamp (UTC)
- Anomalies (browser crashes, exit-node failures, sites unexpectedly down, suspected fingerprinting)

### 10.6 Captcha and challenge handling

Many marketplaces use captcha to deter scraping. Captchas are not in themselves OPSEC concerns, but:

- Some "captchas" are JavaScript-fingerprinting traps; if a captcha requires JavaScript and Tor-Browser-Safer fails, **do not** drop to Standard to bypass it — back out and reconsider the target.
- Repeated failures fingerprint the analyst across circuits if shared cookie state leaks; use New Identity between attempts.

### 10.7 Wellness

Sustained darkweb observation exposes analysts to graphic content, threats, and emotionally-corrosive material. Apply the same wellness floor as [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] §"Researcher-Wellness References":

- Two-person rule on any session that may contain CSAM, trafficking, or extreme violence.
- Mandatory rotation off sustained leak-site duty (weeks-not-quarters scale).
- No after-hours review of sensitive-content cases.
- Access to clinical support (employer EAP, sector-specific programs — Tech Coalition, Headington Institute, Dart Center, UK NCA wellbeing).

---

## 11. Evidence Collection

### 11.1 Capture toolchain

| Tool                       | Use                                                       | Notes                                                        |
| -------------------------- | --------------------------------------------------------- | ------------------------------------------------------------ |
| **SingleFile** (extension) | Full-DOM HTML snapshot                                    | Works in Tor Browser; preserves CSS / JS-rendered content    |
| **Tor Browser screenshot** | Visual artifact                                           | Built-in screenshot tool; captures viewport + full-page      |
| **wget + torsocks**        | WARC-format archival of a single page or recursive crawl  | `torsocks wget --warc-file=out --recursive --level=1 <url>` |
| **ArchiveBox**             | Heavy-duty archive (HTML + WARC + screenshot + media)     | Routes through Tor with `CHROME_USER_AGENT` and SOCKS proxy  |
| **GnuPG**                  | PGP-key parse / fingerprint                               | `gpg --import --import-options show-only`                    |
| **ExifTool**               | Strip / inspect listing-photo metadata                    | After download to airgap                                     |
| **sha256sum / shasum -a 256** | Hash artifacts immediately on capture                  | Per [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]] |
| **gpg --detach-sign / OpenTimestamps** | Timestamp manifests                            | Court-relevant; see [[sop-collection-log|Collection Log]] §"Qualified Timestamping" |

### 11.2 Tor-side WARC capture

```bash
# Whonix Workstation or Tails, with Tor running
torsocks wget \
  --warc-file=darkweb_capture_$(date -u +%Y%m%dT%H%M%SZ) \
  --warc-cdx \
  --no-warc-compression \
  --page-requisites \
  --convert-links \
  --tries=2 \
  --timeout=30 \
  "http://<onion>/<path>"
```

Notes:

- `--no-warc-compression` keeps the WARC inspectable without decompression — easier evidentiary review at the cost of size.
- `--tries=2 --timeout=30` is conservative; aggressive retries fingerprint on rate-limited targets.
- Do **not** recurse beyond `--level=1` on hostile sites; you will hit traps.

### 11.3 Hashing and timestamping

```bash
# After capture
sha256sum darkweb_capture_*.warc darkweb_capture_*.png darkweb_capture_*.html \
  > MANIFEST_$(date -u +%Y%m%dT%H%M%SZ).sha256

# Optional GPG-detach-sign the manifest with the analyst's investigation key
gpg --detach-sign --armor MANIFEST_*.sha256

# Optional OpenTimestamps (free, RFC 3161-compatible third-party anchor)
ots stamp MANIFEST_*.sha256
```

Per [[sop-collection-log|Collection Log]] §"Algorithm-selection," SHA-256 is the baseline; pair with SHA3-256 or BLAKE2 / BLAKE3 for defense-in-depth.

### 11.4 File structure

```
/Evidence/{case_id}/Darkweb/
├── YYYYMMDD-HHMM/
│   ├── session.log                          # session metadata (env, TB version, circuit notes)
│   ├── onion-targets.csv                    # URLs visited, timestamps, status
│   ├── pages/
│   │   ├── <onion-host>_<path>_<ts>.html    # SingleFile / wget output
│   │   ├── <onion-host>_<path>_<ts>.warc    # WARC archive
│   │   └── <onion-host>_<path>_<ts>.png     # screenshot
│   ├── pgp/
│   │   ├── <vendor>_<fpr>_<ts>.asc          # ASCII-armored block
│   │   └── <vendor>_<fpr>_<ts>.txt          # gpg --list-packets parsed output
│   ├── leak-sites/
│   │   └── <group>/<post-id>_<ts>.{html,warc,png}
│   ├── listings/
│   │   └── <market>/<listing-id>_<ts>.{html,warc,png}
│   ├── MANIFEST_<ts>.sha256
│   ├── MANIFEST_<ts>.sha256.asc             # analyst signature
│   └── MANIFEST_<ts>.sha256.ots             # OpenTimestamps anchor
```

Cross-link to [[sop-collection-log|Collection Log]] §"Self-Authenticating Electronic Records (FRE 902(13) and 902(14))" for US-court admissibility framing.

### 11.5 What you do **not** collect

- ❌ The data referenced by a leak-site post (the actual leaked PII / PHI / PCI / credentials / source code), unless a counsel-reviewed scope explicitly permits sample preservation for IOC extraction.
- ❌ Full marketplace scrapes — most engagement scopes do not authorize bulk-scraping a hostile site, and the operational footprint risks deanonymizing the analyst.
- ❌ Any binary, executable, or Office document downloaded from a marketplace listing or forum post, except via the malware-analysis routing in §10.4.
- ❌ Any image marked or contextually identifiable as CSAM. **Hard-stop.** Preserve URL + timestamp only.

---

## 12. Pivots & Cross-Platform Correlation

### 12.1 Onion → clearnet

- **Mirror sites** — many marketplaces, leak sites, and forums publish clearnet mirrors (often Cloudflare-fronted). The clearnet mirror is the easiest pivot to hosting / WHOIS / certificate fingerprints. Pivot via [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]].
- **Operator OPSEC failures** — leaked admin emails (registration data, SSL certificate Common Name, exposed git config), reused server fingerprints (SSH host key, HTTP server banner). Document as historical record even if patched.
- **Vanity onion vs random onion** — vanity onion addresses (where the operator brute-forced a recognizable prefix) require high CPU; the brute-force pattern itself is a low-resolution fingerprint.

### 12.2 Onion → blockchain

- BTC / ETH / XMR / USDT addresses observed in listings, ransom notes, escrow pointers, donation pages.
- **This SOP stops at the address.** Hand off to [[sop-blockchain-investigation|Blockchain Investigation]]. AML-analyst context (sanctions framework, Travel Rule, exchange typology) is in [[sop-financial-aml-osint|Financial & AML OSINT]] §5.
- **OFAC SDN check is in scope here** — a quick SDN search on observed addresses is part of the observation, not the trace. SDN match elevates priority and routing per §9.

### 12.3 Onion → other platforms

- **Telegram** — channels and bots are the dominant out-of-band advertisement layer for marketplaces and ransomware groups. Pivot via [[../Platforms/sop-platform-telegram|Telegram SOP]].
- **Forums (clearnet)** — Reddit, X / Twitter, Discord, Mastodon. Pivot via the matching platform SOP.
- **Breach databases** — IntelX, HaveIBeenPwned, DeHashed, Snusbase. Cross-reference operator email / handle / username against breach corpora. Treat breach data as a research input, not as a publication source.

### 12.4 Onion → onion

- **Mirror clusters** — same operator, multiple onions for redundancy. PGP-signed canonical-URL list is the gold standard; absent that, fingerprint via shared HTML peculiarities, identical 404 page, common SSH banner on a published TCP service.
- **Cross-marketplace vendor reuse** — same vendor handle + same PGP fingerprint = high-confidence link.

### 12.5 Pivot-chain hygiene

- Document every pivot step — onion → clearnet → blockchain → off-ramp — with timestamps and capture hashes. Admissibility requires an unbroken chain.
- Avoid "pivoting through analytics services that resell queries" — pasting an onion or wallet into a free analytics service can leak the investigation. Prefer self-hosted tools (e.g. local mempool.space, local etherscan-equivalent, GraphSense-on-prem) for high-stakes work; see [[sop-financial-aml-osint|Financial & AML OSINT]] §"Common Pitfalls."

---

## 13. Hand-off Boundaries (Scope Contract)

This SOP **stops** at the following boundaries. Each hand-off targets the canonical owner SOP.

| Observation                                                         | Stops here. Routes to:                                                                                  |
| ------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Wallet address (BTC / ETH / XMR / etc.) observed on listing or post | [[sop-blockchain-investigation|Blockchain Investigation]]                                                                                                       |
| Mixer / privacy-pool / cross-chain-bridge usage observed            | [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] (depends on [[sop-blockchain-investigation|Blockchain Investigation]] for upstream transparent tracing). |
| Ransomware payload / sample binary collected                        | [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]]                                       |
| Leaked credentials, card data, or PII samples                       | **Do not validate**. Route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] for victim notification; do not "test login." |
| CSAM observation (any)                                              | **Hard-stop.** URL + timestamp only. Immediate route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] (NCMEC CyberTipline / Project Arachnid / national CSE unit). |
| Trafficking listing / forced-services indicator                      | Immediate route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]         |
| Active extortion / wire transfer in progress                        | Immediate route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]         |
| Imminent threat-to-life (specific target / time / weapon)            | Immediate route to [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] + local emergency service |
| Sanctions evasion (DCA hit, designated-group infrastructure)         | [[sop-financial-aml-osint|Financial & AML OSINT]] §3; FIU per regulated-entity routing                  |
| Vendor PGP key matches a known clearnet identity                    | [[sop-entity-dossier|Entity Dossier]] for structured profiling                                          |
| Marketplace operator OPSEC failure (clearnet mirror, leaked email)   | [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] for infrastructure pivot                                |
| Pseudonym reuse on social platform                                  | Matching platform SOP under `Investigations/Platforms/`                                                  |
| Final report                                                         | [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]]                                |

The contract is bidirectional: when those owner SOPs reach a darkweb-side observation, they route **back here**.

---

## 14. Tools Reference

### 14.1 Network access

| Tool                     | Purpose                                  | Source                                           |
| ------------------------ | ---------------------------------------- | ------------------------------------------------ |
| **Tor Browser**          | Patched Firefox ESR for Tor              | [torproject.org](https://www.torproject.org/) [verify 2026-04-26] |
| **Mullvad Browser**      | Tor-Browser hardening over VPN           | [mullvad.net/browser](https://mullvad.net/en/browser) [verify 2026-04-26] |
| **Tails**                | Amnesic live OS, all-Tor                 | [tails.net](https://tails.net) [verify 2026-04-26] |
| **Whonix**               | Two-VM Tor-forced workstation            | [whonix.org](https://www.whonix.org) [verify 2026-04-26] |
| **Qubes OS**             | Compartmentalized OS (host for Whonix templates) | [qubes-os.org](https://www.qubes-os.org) [verify 2026-04-26] |
| **i2pd / i2p**           | I2P router (C++ / Java)                  | [i2pd.website](https://i2pd.website) / [geti2p.net](https://geti2p.net) [verify 2026-04-26] |
| **Lokinet**              | Oxen onion routing                       | [lokinet.org](https://lokinet.org) [verify 2026-04-26] |

### 14.2 Discovery and aggregation

| Tool                      | Purpose                                   | URL                                                |
| ------------------------- | ----------------------------------------- | -------------------------------------------------- |
| **Ahmia**                 | Indexed Tor search                         | `https://ahmia.fi` [verify 2026-04-26]              |
| **dark.fail**             | Marketplace canonical-URL tracker          | `https://dark.fail` [verify 2026-04-26]             |
| **Tor.taxi**              | Curated onion list                         | `https://tor.taxi` [verify 2026-04-26]              |
| **OnionSearch**           | Open-source CLI meta-search (megadose)    | [github.com/megadose/OnionSearch](https://github.com/megadose/OnionSearch) [verify 2026-04-26] |
| **OnionScan**             | Onion-service auditing tool               | [github.com/s-rah/onionscan](https://github.com/s-rah/onionscan) [verify 2026-04-26]; long-unmaintained — historical reference |
| **Onioff / OnionLink**    | Onion link checkers                        | various — verify per session                        |

### 14.3 Capture and archival

| Tool             | Purpose                                  | Notes                                            |
| ---------------- | ---------------------------------------- | ------------------------------------------------ |
| **SingleFile**   | Full-DOM HTML snapshot extension         | Browser extension; works in Tor Browser          |
| **wget + torsocks** | WARC archival via SOCKS                | `torsocks wget --warc-file=...`                   |
| **ArchiveBox**   | Bulk archival with Tor routing            | Self-hosted; supports WARC + screenshot          |
| **warcio / pywb**| WARC inspection and replay              | [github.com/webrecorder](https://github.com/webrecorder) |
| **ExifTool**     | Metadata extraction from images / docs    | After airgap quarantine                          |

### 14.4 PGP and identity

| Tool             | Purpose                                  | Notes                                            |
| ---------------- | ---------------------------------------- | ------------------------------------------------ |
| **GnuPG**        | PGP parsing, fingerprint, verification    | `gpg --import-options show-only`                  |
| **Sequoia PGP** | Modern Rust PGP implementation            | `sq inspect`                                      |
| **pgpdump**      | Packet-level PGP inspection               | `pgpdump file.asc`                                |
| **Keybase**      | Identity-bound key directory              | Acquired by Zoom 2020; development paused circa 2022 [verify 2026-04-26] |

### 14.5 Threat-intel and monitoring

| Tool                  | Purpose                                | URL                                                      |
| --------------------- | -------------------------------------- | -------------------------------------------------------- |
| **ransomwatch**       | Open-source leak-site aggregator        | `https://ransomwatch.telemetry.ltd` [verify 2026-04-26]  |
| **ransomware.live**   | Leak-site dashboard + JSON API          | `https://www.ransomware.live` [verify 2026-04-26]        |
| **ransomlook.io**     | Group catalog + post archive             | `https://www.ransomlook.io` [verify 2026-04-26]          |
| **MITRE ATT&CK Groups** | Group → TTP mapping                   | `https://attack.mitre.org/groups/`                       |
| **MISP**              | Open threat-intel sharing platform      | [misp-project.org](https://www.misp-project.org)         |
| **OpenCTI**           | Threat-intel platform (Filigran)         | [filigran.io](https://www.filigran.io) [verify 2026-04-26] |
| **CISA #StopRansomware** | US government advisory series        | `https://www.cisa.gov/stopransomware` [verify 2026-04-26] |

### 14.6 Forensics support

- See [[sop-collection-log|Collection Log]] §"Tools Reference" for the canonical capture / hash / timestamp toolset.
- See [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]] for algorithm-selection guidance.
- See [[sop-image-video-osint|Image & Video OSINT]] for marketplace-banner reverse-search and listing-photo geolocation.

---

## 15. Risks & Limitations

### 15.1 Operational risks

- **Browser exploits.** Tor Browser inherits Firefox-ESR vulnerabilities; historical Tor-Browser-targeted exploits (2013 FBI NIT against Freedom Hosting, 2016 NIT against Playpen, 2020s commercial exploits) are public record. Run with JavaScript disabled and patch promptly. See [[sop-opsec-plan|OPSEC Plan]] §6.
- **Fingerprinting.** Even with Tor Browser, screen size, font availability, language preference, and time-zone leak fingerprint signal. Tails default and Whonix-Workstation default minimize this; do not customize.
- **Honeypots.** Several major marketplace and forum takedowns (Hansa 2017, AlphaBay 2017, Genesis 2023) included LE-controlled continuations during which observation was monitored. Assume any sustained engagement is logged.
- **Active-content traps.** Leak sites have hosted browser-exploit JavaScript and fake-captcha SOCKS-leakers; cf. §10.3.

### 15.2 Legal risks

- **Mere viewing of a hidden service** is not universally lawful in every jurisdiction. The canonical legal framework — including unauthorized-access statutes (UK CMA, US 18 U.S.C. §1030, EU Directive 2013/40, AU Criminal Code Part 10.7), CSAM possession statutes (18 U.S.C. §2252, UK Protection of Children Act 1978, EU Directive 2011/93), sanctions (OFAC, EU TFR, UK OFSI), and cross-border data transfer regimes — is in [[sop-legal-ethics|Legal & Ethics]]. Review before the engagement begins.
- **CSAM-adjacent observation** is one of the highest-risk categories in OSINT. Even momentary inadvertent download can be a strict-liability offense. The discipline in this SOP (URL + timestamp only, immediate escalation) exists to avoid that exposure.
- **Stolen-credential validation** is unauthorized access — a "test login" is a CFAA / CMA offense.
- **Crypto-asset payment** to designated groups is a sanctions violation regardless of investigative intent.

### 15.3 Counter-OSINT risks

- Marketplace and forum operators monitor for LE / journalist analyst patterns. Sudden traffic from Tor-exit-correlated patterns, repeated captcha failures, and atypical session shapes can flag an investigator account.
- Counter-surveillance includes operator-side "canary" listings (listings that exist only to identify scrapers).
- Several historical takedowns relied on operator OPSEC failures — assume the inverse risk applies to investigators.

### 15.4 Volatility

- Sites disappear without warning. Capture immediately; do not "come back later for a screenshot."
- Marketplace lifecycle (§5.2) means any current observation is provisional. Re-verify status against `dark.fail` and aggregators before reporting.
- Onion addresses themselves change — operators rotate when burned. Pin the canonical PGP-signed URL list and refresh per session.

### 15.5 Attribution limits

- **Tor does not protect against global passive adversaries** — traffic-correlation attacks are theoretically and practically demonstrated (academic literature: Murdoch & Danezis 2005; Johnson et al. 2013; multiple post-2015 papers). Investigators should not rely on Tor for protection against nation-state-tier adversaries.
- **OPSEC failures attribute, not the network.** Most public deanonymizations (Silk Road's Ulbricht, Hutchins, Yastremskiy, Reality Winner, several BreachForums admins) trace to operator-side OPSEC mistakes, not Tor breaks. The same applies inversely to investigators — see [[sop-opsec-plan|OPSEC Plan]] §"Operator OPSEC failure case studies."

### 15.6 Researcher wellness

- Graphic content, victim distress, threat content, and ideologically-corrosive material accumulate. Apply the wellness floor in §10.7. Wellness is an operational requirement, not a soft-skills aside.

---

## 16. Common Pitfalls

- ❌ **Logging in to a clearnet identity from Tor Browser.** Single biggest analyst-side deanonymizer. Apply §10.1 every session.
- ❌ **Engaging with vendors or forums.** Even a single post is participation. Reading is observation; replying is not.
- ❌ **"Test deposits" or "small purchases" to verify a vendor.** Crosses into commission of a predicate offense and taints downstream blockchain analysis.
- ❌ **Downloading marketplace samples without isolation.** Many "samples" are credential-stealers, RATs, or contraband-bait files. Quarantine then route to malware-analysis.
- ❌ **Failing to capture immediately.** Sites disappear; "I'll come back tomorrow" is a discovery loss.
- ❌ **Pasting an onion URL into a clearnet analytics service.** Logs at exit; some services share queries with third parties; investigation leak.
- ❌ **Using Tor on a host that holds the analyst's clearnet identity.** Use Tails or Whonix on a clean host; not a habit-stack-on-top-of-personal-laptop.
- ❌ **Treating darkweb-listed prices, quantities, or claims as ground truth.** Most listings are fraudulent; many are LE-controlled.
- ❌ **Failing to time-stamp sanctions / takedown / lifecycle state at observation.** Tornado Cash designation status changed three times 2022–2025; Hydra status is "seized 2022-04-05"; LockBit is "Operation Cronos 2024-02-19, partial reconstitution after." Record what was true when.
- ❌ **Self-validating credentials, card BINs, or PII samples.** Unauthorized access. Do not.
- ❌ **Investigating CSAM platforms.** Hard-stop. URL + timestamp + escalation per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]. Do not "verify."
- ❌ **Failing to document the .onion → clearnet pivot chain.** Admissibility requires an unbroken evidentiary chain.
- ❌ **Cross-mixing investigations in one Tor session.** Cross-investigation linkability via shared cookies / HTTP-cache / browser-history side channels.
- ❌ **Trusting any single index.** Hidden Wiki forks, scrap-aggregator clones, and mirror impersonators dominate the discovery layer; cross-check.
- ❌ **Re-using a "burner" persona across investigations.** A persona is single-investigation-scoped; reusing one creates a linkage-by-tradecraft fingerprint.
- ❌ **Treating Tor as protection against a global passive adversary.** It is not; see §14.5.

---

## 17. Real-World Scenarios

### Scenario 1: Ransomware leak-site monitoring for victim early-warning

**Situation:** A ransomware group lists an apparent victim (a regional hospital network) on its leak site with a 7-day countdown.

**Approach:**

1. From a clean Whonix Workstation snapshot, navigate to the leak post via the canonical onion (verified against `dark.fail` PGP-signed list).
2. Capture the post (SingleFile + screenshot + WARC); hash the artifacts; log timestamp UTC.
3. Extract: claimed-victim name, listed sample-data filenames, countdown timer, ransom amount if visible, payment-wallet hint, contact channel.
4. Cross-reference the victim claim against the victim's public status page, SEC 8-K filings (if applicable), and state breach-notification portals. Lead time exists when claim precedes disclosure.
5. **Notify** through the victim's incident-response chain or a sector-specific feed (H-ISAC for healthcare); do **not** cold-email the victim with leaked data.
6. Hand off any binary IOCs to [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]]; payment-wallet to [[sop-blockchain-investigation|Blockchain Investigation]].
7. Continue monitoring through the countdown; capture any new posts and any "data dumped" event without downloading the dump.

**Outcome:** Defensive — victim notified before public-shaming-countdown expiry; incident-response timeline compressed; IOCs distributed via ISAC; sanctions screen on payment wallet flags potential designated-group involvement.

### Scenario 2: Vendor PGP pivot across marketplace migrations

**Situation:** A drug vendor on a now-seized market is suspected to have re-emerged on two successor markets under different handles.

**Approach:**

1. On the seized-market mirror or archived snapshot (do not rely on operator continuity), capture the vendor's last-known PGP block.
2. Extract the 40-char fingerprint and note the key creation date.
3. On each candidate successor market, capture vendor-profile pages for handles within the same product category and approximate price-tier; capture each PGP block.
4. Compare fingerprints — fingerprint match is high-confidence operator-continuity evidence. Different fingerprint with overlapping UID metadata (same comment string, same email-domain pattern) is medium-confidence.
5. Search public keyservers (`keys.openpgp.org`, `keyserver.ubuntu.com`) for the canonical fingerprint — older keys frequently have legacy clearnet UIDs.
6. Cross-link operator handle and clearnet-UID candidate into [[sop-entity-dossier|Entity Dossier]] with confidence levels per [[sop-entity-dossier|Entity Dossier]] §"Confidence Rating."
7. Do **not** message the vendor to "verify" — observation only.

**Outcome:** Operator-continuity evidence with court-defensible fingerprint chain; no investigator engagement; clearnet pivot lead generated for further OSINT (handle reuse on social media, breach-data correlation).

### Scenario 3: Forum monitoring of stolen-data resale

**Situation:** A breach-forum post advertises resale of a 2025 corporate breach dataset that the affected company has not yet publicly disclosed.

**Approach:**

1. Without registering an account (most BreachForums-lineage sites have public-readable threads via guest view or canonical mirrors), capture the post page.
2. Extract: poster handle, post timestamp, claimed dataset description, sample-file hashes if listed, asking price, currency, contact method.
3. **Do not download the sample.** Capture the post metadata only.
4. Cross-reference the poster handle against historical forum archives (RaidForums lineage if applicable), Telegram, and Tor-side aggregators.
5. Check observed wallet (if any) against OFAC SDN and `chainabuse.com` — hand off blockchain trace to [[sop-blockchain-investigation|Blockchain Investigation]].
6. Notify the affected company via its responsible-disclosure channel, CERT, or sector ISAC. The notification is the defensive value; the investigation does not scrape the corpus.
7. Document the routing: who was notified, when, with what artifacts.

**Outcome:** Defensive notification ahead of public dump; victim populations identified for breach-notification compliance; threat-actor handle mapped across forums for ongoing tracking; no investigator-side participation, no data possession.

---

## 18. Emergency Procedures

### 18.1 Escalation triggers (immediate)

- **Imminent threat to life** — specific target, weapon, time, location.
- **CSAM observation** of any kind, including thumbnails or category listings.
- **Active extortion or wire transfer in progress** with identifiable victim and short window.
- **Trafficking** indicator (recruitment language, transport details, victim-handling instructions).
- **Specific terror plot** with operational detail.
- **Active sanctions-evasion transfer** observed in real time.

### 18.2 Immediate actions

1. **Stop browsing.** Do not "follow the lead" deeper; further observation can become evidentiary contamination or investigator exposure.
2. **Preserve session evidence** — current capture, session log, hash manifest. Sign and timestamp the manifest.
3. **Do not download** illicit content. URL + timestamp + minimal context only.
4. **Escalate** per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] for the canonical reporting routes (NCMEC CyberTipline, Project Arachnid, NCA / FBI / Europol / national CERT, regulated-entity MLRO + FIU SAR).
5. **Document the routing** — who, when, what artifacts, response received.
6. **Wellness check** — analyst rotation, two-person debrief, time off the queue.

### 18.3 Specific pathway examples

- **CSAM:** US — NCMEC CyberTipline (`report.cybertip.org`); CA — Cybertip.ca; Canada/global — Project Arachnid; EU — INHOPE network member hotline; UK — IWF + NCA CEOP. Do not preserve content locally; preserve URL + timestamp only.
- **Terrorism:** UK — Anti-Terrorist Hotline 0800 789 321 + `gov.uk/ACT`; US — FBI tips.fbi.gov + 1-800-CALL-FBI; AU — National Security Hotline 1800 123 400.
- **Trafficking:** US — NHTRC 1-888-373-7888; UK — Modern Slavery NRM (First Responder duty) per Modern Slavery Act 2015 §52; INTERPOL trafficking unit via local LE.
- **Sanctions evasion (US):** OFAC Reporting at `sanctions_actions@ofac.treas.gov`; FinCEN SAR via regulated-entity routing.
- **Emergency (any):** local emergency number first if life is at imminent risk.

Cross-link [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] for the full canonical routing matrix; this section is a pointer, not the source of truth.

---

## 19. Related SOPs

- [[sop-legal-ethics|Legal & Ethics]] — canonical legal framework; review before every engagement
- [[sop-opsec-plan|OPSEC Plan]] — investigator OPSEC, environment build (Tails / Whonix / Qubes), browser hardening
- [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]] — escalation routes for CSAM, trafficking, terrorism, threats-to-life
- [[sop-collection-log|Collection Log]] — chain-of-custody, hashing, timestamping, FRE 902(13)/(14) framing
- [[sop-entity-dossier|Entity Dossier]] — structured profiling for operator / vendor / actor records
- [[sop-blockchain-investigation|Blockchain Investigation]] — multi-chain wallet tracing target for §13 hand-offs (wallet observation → trace)
- [[sop-financial-aml-osint|Financial & AML OSINT]] — fiat-side AML, corporate UBO, sanctions / SDN / DCA framework, AML-analyst quick-reference for crypto context
- [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT]] — clearnet-mirror / hosting / certificate pivots from operator OPSEC failures
- [[sop-image-video-osint|Image & Video OSINT]] — listing-photo / banner reverse-search and metadata analysis
- [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — final reporting, disclosure routes
- [[../Platforms/sop-platform-telegram|Telegram SOP]] — out-of-band advertisement layer for marketplaces and ransomware groups
- [[../Platforms/sop-platform-twitter-x|Twitter/X SOP]] — leak-announcement / vendor-handle pivots
- [[../Platforms/sop-platform-reddit|Reddit SOP]] — historical darkweb-resource cataloging (archived posts)
- [[../../Security/Analysis/sop-malware-analysis|Malware Analysis]] — for ransomware and dropped binaries
- [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]] — algorithm selection for evidence integrity
- [[../../Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]] — PGP / OpenPGP / cipher-primitive analysis when needed
- [[sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] — mixer / privacy-pool / cross-chain-bridge obfuscation tracing

## Legal & Ethical Considerations

Canonical legal framework: [[sop-legal-ethics|Legal & Ethics]]. Do not re-derive jurisdiction, statute, or authorization rules in this SOP — read them from the canonical source.

Darkweb-investigation-specific guardrails:

- **Authorization in writing**, naming darkweb collection as in-scope, before any onion fetch. Verbal authorization is insufficient given the unauthorized-access exposure.
- **Observation-only.** No registration, no transactions, no engagement, no "verification" of vendors / listings / credentials / data samples. The line between observation and participation is the legal line.
- **CSAM hard-stop.** Any CSAM observation — including aggregator categories, search-engine hits, or marketplace category labels — triggers immediate escalation per [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]. URL + timestamp only; no content preservation; no in-line analysis. Strict-liability statutes in most jurisdictions make even momentary inadvertent download a serious offense.
- **Sanctions discipline.** Crypto-asset payment to a designated group is a sanctions violation regardless of intent. Time-stamp sanctions / takedown / designation status at observation; report what was true when.
- **PII minimization.** Apply the same data-minimization discipline as any OSINT engagement (GDPR Art. 6/9, UK DPA, CCPA / CPRA). Document lawful basis per query; collect only what is necessary for the analytical purpose.
- **Mandatory reporting.** Operating inside a regulated entity, route findings via MLRO / DPO. Outside a regulated entity, route serious findings (sanctions evasion, terrorist financing, trafficking, child exploitation) via the appropriate FIU / national authority — see [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]].
- **Researcher wellness.** Two-person rule on sensitive-content sessions; mandatory rotation; clinical support access. Wellness is operational, not optional — see §10.7.
- **Log every query.** URL, timestamp UTC, action, hash of saved artifact — per [[sop-collection-log|Collection Log]] format. Admissibility depends on the chain.

OPSEC for the investigator (cross-context separation, environment isolation, browser hardening, persona discipline): [[sop-opsec-plan|OPSEC Plan]] is the canonical source. Darkweb work does not relax any OPSEC rule; it tightens several (§10).

---

## 20. External / Reference Resources

### Tor and anonymity-network documentation

- Tor Project — [torproject.org](https://www.torproject.org/) [verify 2026-04-26]
- Tor Browser Manual — [tb-manual.torproject.org](https://tb-manual.torproject.org) [verify 2026-04-26]
- Tor Specifications — [spec.torproject.org](https://spec.torproject.org) [verify 2026-04-26]
- Tails — [tails.net](https://tails.net) [verify 2026-04-26]
- Whonix — [whonix.org](https://www.whonix.org) [verify 2026-04-26]
- Qubes OS — [qubes-os.org](https://www.qubes-os.org) [verify 2026-04-26]
- I2P — [geti2p.net](https://geti2p.net) [verify 2026-04-26]
- I2Pd — [i2pd.website](https://i2pd.website) [verify 2026-04-26]

### Discovery indexes (fast-rot — verify per session)

- Ahmia — `https://ahmia.fi` [verify 2026-04-26]
- dark.fail — `https://dark.fail` [verify 2026-04-26]
- Tor.taxi — `https://tor.taxi` [verify 2026-04-26]

### Ransomware-tracking resources

- ransomwatch — `https://ransomwatch.telemetry.ltd` [verify 2026-04-26]
- ransomware.live — `https://www.ransomware.live` [verify 2026-04-26]
- ransomlook.io — `https://www.ransomlook.io` [verify 2026-04-26]
- CISA #StopRansomware — `https://www.cisa.gov/stopransomware` [verify 2026-04-26]
- Europol IOCTA — `https://www.europol.europa.eu/cms/sites/default/files/documents/IOCTA` (annual report) [verify 2026-04-26]

### Investigative journalism and research

- Bellingcat — [bellingcat.com](https://www.bellingcat.com)
- OCCRP — [occrp.org](https://www.occrp.org); Aleph (document graph) [aleph.occrp.org](https://aleph.occrp.org)
- DFRLab (Atlantic Council) — [dfrlab.org](https://dfrlab.org) [verify 2026-04-26]
- Krebs on Security — [krebsonsecurity.com](https://krebsonsecurity.com)
- The DFIR Report — [thedfirreport.com](https://thedfirreport.com) [verify 2026-04-26]

### Vendor / commercial threat-intel (subscription)

- Mandiant Advantage — Google Cloud
- Recorded Future
- CrowdStrike Falcon Intelligence
- Group-IB Threat Intelligence
- Trend Micro Research / Talos / Unit 42 (vendor-funded research; useful when paywalled-equivalent open-source alternatives unavailable)

### Standards and frameworks

- MITRE ATT&CK — `https://attack.mitre.org`
- MITRE D3FEND — `https://d3fend.mitre.org`
- NIST SP 800-86 (Integrating Forensic Techniques) — see [[sop-collection-log|Collection Log]] §"Standards & Frameworks"
- Berkeley Protocol on Digital Open Source Investigations (UN OHCHR 2022) — see [[sop-legal-ethics|Legal & Ethics]] §"International framework"

### Academic anonymity / Tor research

- Murdoch & Danezis 2005 — *Low-cost Traffic Analysis of Tor*
- Johnson et al. 2013 — *Users Get Routed: Traffic Correlation on Tor by Realistic Adversaries*
- The Free Haven anonymity bibliography — [freehaven.net/anonbib/](https://www.freehaven.net/anonbib/) [verify 2026-04-26]

### Operator OPSEC failure case studies (public record)

See [[sop-opsec-plan|OPSEC Plan]] §"Operator OPSEC failure case studies" for the canonical list (Hutchins, Ulbricht, Yastremskiy, Reality Winner, multiple BreachForums admins). These are pedagogical; the inverse failure modes apply to investigators.

---

**Version:** 1.0 (Initial)
**Last Updated:** 2026-04-26
**Review Frequency:** Quarterly (fast-rot — leak-site landscape, marketplace lifecycle, takedown timeline)
