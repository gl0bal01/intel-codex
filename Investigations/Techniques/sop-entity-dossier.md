---
type: dossier
title: Entity Dossier Guide
description: "Build comprehensive subject profiles: identity verification, digital footprint mapping, relationship analysis & intelligence dossier templates for OSINT."
entity_type: person
name: Entity Name
aliases: []
primary_id:
country:
risk: medium
confidence: medium
tags:
  - dossier
  - entity
  - osint
created: 2025-10-05
updated: 2026-04-26
analyst:
case_id:
---

# Entity Dossier Template

> **Purpose:** Comprehensive entity profiling for OSINT investigations. This template provides a structured framework for documenting persons, organizations, digital assets, domains, or cryptocurrency wallets.

---

## 1. Entity Overview

### Basic Information

| Field | Value |
|-------|-------|
| **Full Name/Designation** | [Legal name, handle, or identifier] |
| **Entity Type** | Person / Organization / Domain / Wallet / Asset |
| **Primary Identifier** | [Email, phone, domain, address, wallet ID] |
| **Country/Region** | [Geographic location] |
| **Risk Level** | Low / Medium / High / Critical |
| **Confidence Level** | Low / Medium / High |
| **Status** | Active / Inactive / Suspended / Under Investigation |

### Aliases & Alternative Identifiers

```markdown
**Known Aliases:**
- Alias 1 (platform: Twitter, confirmed: 2024-05-10)
- Alias 2 (platform: Telegram, confirmed: 2024-06-15)
- Alias 3 (context: Dark web forum, confidence: medium)

**Usernames:**
- @username1 (Twitter, Instagram, GitHub)
- username2 (Reddit, Discord)
- handle_xyz (Telegram, Signal)

**Email Addresses:**
- primary@example.com (confirmed via WHOIS 2024-01-10)
- secondary@domain.com (found in data breach, confidence: high)
- alias@tempmail.com (possible burner, confidence: low)

**Phone Numbers:**
- +1-555-123-4567 (confirmed via Signal, 2024-03-15)
- +44-20-1234-5678 (linked via LinkedIn, confidence: medium)

**Cryptocurrency Wallets:**
- BTC: bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh
- ETH: 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
- Monero: 4AdUndXHHZ6cfufTMvppY6JwXNouMBzSkbLYfpAV5Usx...

**Domains Owned:**
- example.com (WHOIS: 2020-05-10, registrar: Namecheap)
- example.net (WHOIS: 2021-08-20, privacy protection enabled)
- suspicious-site.tk (Free TLD, created: 2024-09-01)
```

### Visual Identifiers

```markdown
**Profile Photos:**
- Photo 1: SHA256: a1b2c3d4e5f6... (source: Twitter, date: 2024-01-15)
  - PimEyes match: 85% confidence
  - Google Image Search: 3 matches (LinkedIn, Facebook, company website)
- Photo 2: SHA256: b2c3d4e5f6... (source: Instagram, date: 2024-06-20)
  - Location metadata: 51.5074° N, 0.1278° W (London, UK)
  - Reverse image search: No additional matches

**Identifying Markers:**
- Tattoo on left forearm (visible in Instagram post, 2024-07-10)
- Distinctive vehicle: Red Tesla Model 3, plate: ABC-1234 (seen in background, 2024-08-05)
```

---

## 2. Profile Summary

### Activity Overview

```markdown
**Primary Activities:**
- Cryptocurrency trading (confirmed via blockchain analysis)
- Software development (GitHub contributions, 200+ repos)
- Social media influencer (Twitter: 50k followers, engagement rate: 3.5%)

**Timeline Highlights:**

| Date | Event | Source | Significance |
|------|-------|--------|--------------|
| 2020-05-10 | Registered example.com | WHOIS | First known online presence |
| 2022-03-15 | First BTC transaction | Blockchain | Started crypto activity |
| 2023-07-20 | Appeared in data breach | HIBP | Email exposed in XYZ breach |
| 2024-01-10 | Twitter account suspended | Twitter | Violated ToS, appealed successfully |
| 2024-09-01 | Large crypto transfer | Blockchain | $500k BTC → unknown wallet |

**Behavioral Patterns:**
- Active hours: 09:00-17:00 UTC (consistent with GMT timezone)
- Posting frequency: 5-10 tweets/day, peaks on weekdays
- Language: English (primary), occasional Spanish
- Topics: Crypto, privacy tech, geopolitics
```

### Key Associates

```markdown
**Known Associates:**

1. **John Doe (@johndoe)**
   - Relationship: Business partner
   - Evidence: Co-owns domain "partnership.com" (WHOIS)
   - Last interaction: 2024-09-15 (Twitter mention)
   - Risk level: Medium

2. **Jane Smith (@jsmith)**
   - Relationship: Frequent contact
   - Evidence: 50+ mutual Twitter interactions, Signal contact (leaked)
   - Last interaction: 2024-10-01
   - Risk level: Low

3. **Acme Corp**
   - Relationship: Former employer
   - Evidence: LinkedIn employment history (2018-2022)
   - Confirmation: Company website lists entity in team page (archived 2020)
   - Risk level: Low

**Social Graph Visualization:**
[Insert network diagram showing connections between entities]

```

---

## 3. Links & Pivots

### Shared Infrastructure

**WHOIS/DNS Pivots:**
```markdown
**Registrant Email Pivoting:**
- Email: admin@example.com found in WHOIS for:
  - example.com (registered 2020-05-10)
  - example.net (registered 2021-08-20)
  - suspicious-domain.xyz (registered 2024-09-01)

**Name Server Pivoting:**
- ns1.example.com used by:
  - example.com
  - partnerdomain.com (linked to John Doe)
  - client-site.org

**IP Address Pivoting:**
- 192.168.1.100 hosts:
  - example.com
  - example.net
  - malicious-site.tk (⚠️ flagged by VirusTotal)

**Commands Used:**
```bash
# WHOIS reverse lookup
whois -H example.com | grep "Registrant Email"

# DNS enumeration
dig example.com ANY
host -t NS example.com

# Reverse IP lookup
curl -s "https://api.hackertarget.com/reverseiplookup/?q=192.168.1.100"

# Certificate transparency search
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq -r '.[].name_value' | sort -u
```

### Tracking & Analytics Pivots

```markdown
**Google Analytics Pivoting:**
- UA-123456789-1 found on:
  - example.com
  - partnerdomain.com
  - affiliate-site.org

**Google AdSense Pivoting:**
- pub-9876543210123456 found on:
  - example.com
  - monetized-blog.net

**Favicon Hash Pivoting:**
- Favicon hash: -1234567890
- Shodan search: `http.favicon.hash:-1234567890`
- Results: 15 domains using identical favicon

**Commands Used:**
```bash
# Extract Google Analytics ID
curl -s https://example.com | grep -oP "UA-\d{4,10}-\d{1,4}"

# Extract AdSense ID
curl -s https://example.com | grep -oP "pub-\d{16}"

# Calculate favicon hash
curl -s https://example.com/favicon.ico | python3 -c 'import mmh3, sys; print(mmh3.hash(sys.stdin.buffer.read()))'

# Shodan search
shodan search "http.favicon.hash:-1234567890"
```

### Social Media Cross-Referencing

```markdown
**Platform Correlation:**

| Platform | Username | URL | Verified | Activity |
|----------|----------|-----|----------|----------|
| Twitter | @entity_name | https://twitter.com/entity_name | ✓ | Active (last post: 2024-10-05) |
| Instagram | entity.name | https://instagram.com/entity.name | ✓ | Active (last post: 2024-10-04) |
| LinkedIn | entity-name | https://linkedin.com/in/entity-name | ✓ | Active (updated: 2024-09-15) |
| GitHub | entityname | https://github.com/entityname | ✓ | Active (last commit: 2024-10-02) |
| Telegram | @entityname | t.me/entityname | ✗ | Active (online 2 hours ago) |
| Reddit | u/entityname | https://reddit.com/user/entityname | ✗ | Active (last comment: 2024-10-03) |

**Username Enumeration:**
```bash
# WhatsMyName (canonical username-enumeration ruleset; >600 sites)
# https://github.com/WebBreacher/WhatsMyName  (web UI: whatsmyname.app)
python3 web_accounts_list_checker.py -u entity_name

# Maigret (WhatsMyName fork + parsing of returned profiles)
# https://github.com/soxoj/maigret
maigret entity_name --html

# Sherlock (legacy but still maintained)
# https://github.com/sherlock-project/sherlock
sherlock entity_name

# Nuclei OSINT templates (template tag `osint` exists, but is not a username-enumeration
# replacement for the above — use for surface-level recon only) [verify 2026-04-26]
nuclei -t http/osint/ -var user=entity_name

# Manual spot-check
# X (Twitter): https://x.com/entity_name
# Instagram: https://instagram.com/entity_name
# GitHub: https://github.com/entityname
```

**Bio/Description Correlation:**
- Twitter bio: "Crypto enthusiast | Privacy advocate | Coffee lover"
- Instagram bio: "☕ Crypto & Privacy | DM for collabs"
- LinkedIn bio: "Cryptocurrency consultant specializing in privacy tech"
- **Common themes:** Cryptocurrency, privacy, professional availability

### Sanctions, Beneficial-Ownership & Corporate Registries

Run every named entity (person, company, wallet, vessel) against the canonical lists below before finalizing risk rating. For deeper financial-crime methodology see [[sop-financial-aml-osint|Financial / AML OSINT]].

**Sanctions screening:**

| Source | URL | Notes |
|--------|-----|-------|
| OFAC SDN + Consolidated (US) | `sanctionssearch.ofac.treas.gov` | Authoritative US Treasury list; CSV/XML downloads at `home.treasury.gov/policy-issues/financial-sanctions/` |
| EU Consolidated Financial Sanctions | `data.europa.eu/en/datasets/consolidated-list-of-persons-groups-and-entities-subject-to-eu-financial-sanctions` | XML / CSV; mirrored by FSF |
| UK OFSI Consolidated List | `gov.uk/government/publications/financial-sanctions-consolidated-list-of-targets` | HM Treasury OFSI |
| UN Security Council Consolidated | `un.org/securitycouncil/sanctions/un-sc-consolidated-list` | UN-1267, UN-1718, etc. |
| OpenSanctions | `opensanctions.org` | Aggregated multi-jurisdiction sanctions + PEPs (FollowTheMoney schema) |
| AU DFAT / CA SEMA / CH SECO | per-government portals | Verify URL at use time `[verify 2026-04-26]` |

**Beneficial-ownership / corporate registries:**

| Source | URL | Notes |
|--------|-----|-------|
| OpenCorporates | `opencorporates.com` | Largest open-data corporate registry index |
| UK Companies House — People with Significant Control (PSC) | `find-and-update.company-information.service.gov.uk` | Public; ID-verification phase-in under ECCT Act 2023 `[verify 2026-04-26]` |
| US FinCEN Beneficial Ownership Information (BOI) | `fincen.gov/boi` | Scope materially narrowed by **Treasury's March 2025 interim final rule** to foreign reporting companies only — verify current state before relying on it `[verify 2026-04-26]` |
| EU UBO registers (5AMLD/6AMLD) | per-member-state portal | **CJEU C-37/20 + C-601/20 (Nov 2022)** invalidated unrestricted public access; most member states now require "legitimate interest" — document the access pathway used `[verify 2026-04-26]` |
| ICIJ OffshoreLeaks | `offshoreleaks.icij.org` | Panama / Paradise / Pandora / Pandora-2 / Cyprus / Bahamas leaks |
| OCCRP Aleph | `aleph.occrp.org` | Investigative document + leak corpus search |
| Sayari Graph / Moody's Orbis (BvD) / LSEG World-Check | commercial | Document use without endorsement |

**Threat-actor / cyber-TI dossier sources** (when entity is an adversary group):

| Source | URL | Notes |
|--------|-----|-------|
| MITRE ATT&CK Groups | `attack.mitre.org/groups/` | Curated TTP-attribution dossiers |
| MISP | `misp-project.org` | Threat-sharing platform; community feeds |
| OpenCTI (Filigran / ANSSI) | `opencti.io` | TI knowledge graph (STIX 2.1) |
| Mandiant Advantage / Recorded Future / CrowdStrike Falcon Intelligence | commercial | Document without endorsement |
| DFIR Report / Talos Intelligence (Cisco) / Unit 42 (Palo Alto) | OSS write-ups | Useful for incident-derived attribution |

> **Sanctions hits are not a verdict** — name collisions (esp. PEP-class lists) require corroborating identifiers (DOB, country of citizenship, primary identifier) before downgrading confidence to "match." Annotate every hit with the source list, list version/date, and confirming identifier(s).

---

## 4. Digital Footprint Analysis

### Data Breach Exposure

```markdown
**Confirmed Breaches (Have I Been Pwned):**
```bash
# Check email in breaches
curl -H "hibp-api-key: YOUR_API_KEY" \
  "https://haveibeenpwned.com/api/v3/breachedaccount/entity@example.com"

# Results:
# - Adobe (2013): Email, password hash
# - LinkedIn (2021): Email, phone, job title
# - Collection #1 (2019): Email, plaintext password
```

**Exposed Data:**
- Email: entity@example.com
- Password: Summer2023! (plaintext in Collection #1)
- Phone: +1-555-123-4567 (LinkedIn breach)
- Date of birth: 1985-05-15 (estimated from LinkedIn education dates)

### Cryptocurrency Activity

```markdown
**Bitcoin Analysis:**
```bash
# Balance + tx history — blockchain.info endpoints still respond but are legacy;
# prefer mempool.space or Blockstream Esplora for modern, rate-limit-friendly access.
# (blockchain.com rebrand kept the blockchain.info JSON paths live — [verify 2026-04-26])
curl -s "https://blockchain.info/balance?active=bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
curl -s "https://blockchain.info/rawaddr/bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh" | jq '.txs'

# Modern equivalents (prefer for new dossiers):
curl -s "https://mempool.space/api/address/bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"
curl -s "https://blockstream.info/api/address/bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh/txs"

# Cluster analysis — note: walletexplorer.com (Sam Rushing / formerly btc.com) is the
# legacy free clusterer; verify currency before citing in evidence. Modern alternatives:
#   - mempool.space (open, on-chain only, no clustering)
#   - oxt.me (closed/limited post-Samourai enforcement [verify 2026-04-26])
#   - Chainalysis Reactor / TRM Labs / Elliptic / Crystal / GraphSense (commercial / OSS)
# Linked wallets: 5 addresses in same cluster
# Total balance across cluster: 15.3 BTC (illustrative — convert at audit time, not template time)
```

**Key Transactions:**
- 2024-09-01: 10 BTC sent to 1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa (Satoshi's wallet? likely error)
- 2024-08-15: Received 5 BTC from Binance hot wallet
- 2024-07-20: 2 BTC sent to unknown wallet (possible OTC trade)

**Ethereum Analysis:**
```bash
# Etherscan API
curl "https://api.etherscan.io/api?module=account&action=balance&address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb&tag=latest&apikey=YourApiKeyToken"

# Token holdings
curl "https://api.etherscan.io/api?module=account&action=tokentx&address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb&apikey=YourApiKeyToken"
```

**Holdings:**
- ETH: 50.5 ETH (~$100,000 USD)
- USDT: 25,000 USDT
- USDC: 10,000 USDC
- Other: 5 different ERC-20 tokens

### Geolocation Intelligence

```markdown
**Location Indicators:**

**IP Address History:**
- 192.168.1.100 → London, UK (ISP: BT Group, 2024-01-01 to 2024-06-15)
- 10.0.0.50 → Berlin, Germany (ISP: Deutsche Telekom, 2024-06-16 to present)

**Photo Metadata:**
```bash
# Extract EXIF data
exiftool image.jpg | grep -E "(GPS|Date|Camera)"

# Results:
# GPS Position: 51.5074° N, 0.1278° W (London, UK)
# Date Taken: 2024:07:15 14:30:22
# Camera: iPhone 13 Pro
```

**Social Media Geotagging:**
- Instagram check-ins: London (15 posts), Berlin (8 posts), Dubai (3 posts)
- Twitter location: "London, UK" (profile), frequent tweets geotagged "Berlin"

**Timezone Analysis:**
- Posting times suggest GMT/CET timezone (09:00-17:00 UTC)
- Consistent with London/Berlin location claims

---

## 5. Evidence & Exhibits

### Artifact Repository

```markdown
**File Evidence:**

| Filename | Hash (SHA256) | Source | Date | Description |
|----------|---------------|--------|------|-------------|
| profile_photo.jpg | a1b2c3d4e5f6... | Twitter | 2024-01-15 | Profile photo with EXIF data |
| screenshot_telegram.png | b2c3d4e5f6... | Telegram | 2024-09-10 | Conversation excerpt |
| website_archive.html | c3d4e5f6... | Archive.org | 2024-08-01 | Archived website snapshot |
| email_evidence.eml | d4e5f6... | Subpoena | 2024-10-01 | Email thread with associate |

**Evidence Storage:**
- Path: `/evidence/CASE-2025-1005/entity_name/`
- Backup: `/backup/CASE-2025-1005/entity_name/`
- Access: Restricted (analyst only)

**Hash Verification:**
```bash
# Verify evidence integrity
cd /evidence/CASE-2025-1005/entity_name/
sha256sum -c SHA256SUMS
# All files: OK
```

### Screenshot Evidence

```markdown
**Social Media Screenshots:**
1. Twitter post (2024-09-15)
   - Content: "Just moved to Berlin! Loving the crypto scene here 🚀"
   - Engagement: 150 likes, 30 retweets
   - Hash: e5f6g7h8...

2. Instagram story (2024-10-01)
   - Content: Photo at Berlin conference
   - Visible: Conference badge with name visible
   - Hash: f6g7h8i9...

3. LinkedIn update (2024-09-15)
   - Content: Job title changed to "Crypto Consultant"
   - Hash: g7h8i9j0...
```

### OSINT Tool Outputs

```markdown
**Tool Execution Records:**
```bash
# Nuclei output
nuclei -tags osint -var user=entity_name > evidence/nuclei_output.txt
# Found: 12 platforms

# theHarvester output
theHarvester -d example.com -b all > evidence/theharvester_output.txt
# Found: 15 emails, 10 hosts, 5 IPs

# Maltego transform results
# [Export Maltego graph as evidence/maltego_graph.mtgx]
# Entities found: 50+ linked nodes
```

---

## 6. Assessment & Analysis

### Confidence Rating

> **Anchor frameworks:** rate every claim against (a) the **Berkeley Protocol on Digital Open Source Investigations §V — Information Verification** (corroboration, source assessment, three-source rule) and (b) the **NATO Admiralty Code (STANAG 2511 / AJP-2)** 6×6 source-credibility × information-credibility matrix (A–F × 1–6). Use the [[sop-collection-log|Collection Log]] for evidentiary traceability and the **Cone of Plausibility** to bound analytic uncertainty on forward-looking claims.

```markdown
**Overall Confidence: MEDIUM-HIGH**

| Information Type | Confidence | Justification |
|------------------|------------|---------------|
| Identity (name) | High | Multiple corroborating sources (LinkedIn, WHOIS, social media) |
| Location (current) | Medium | IP geolocation + social media posts, but VPN usage possible |
| Email addresses | High | Confirmed via WHOIS, data breaches, social media |
| Cryptocurrency wallets | High | Blockchain transactions verified, linked to known entities |
| Associates | Medium | Social media interactions observed, business relationships inferred |
| Intentions | Low | Speculative, requires further investigation |

**Confidence Modifiers:**
- ✅ Multiple independent sources confirm identity
- ✅ Blockchain evidence is immutable and verifiable
- ⚠️ Some aliases unconfirmed (only one sighting)
- ⚠️ VPN/proxy usage detected (IP reliability reduced)
- ❌ No official government records obtained
```

### Risk Assessment

```markdown
**Risk Level: MEDIUM**

**Risk Factors:**
- Cryptocurrency activity involving large sums ($500k+ movements)
- Association with entities on sanctions lists (TBD - requires verification)
- Past ToS violations on social media platforms
- Data breach exposure with plaintext passwords

**Mitigating Factors:**
- No criminal record found (public records search)
- Legitimate business presence (registered company, public profiles)
- Responsive to legal requests (per social media platform data)

**Threat Indicators:**
- None currently identified
- Monitor for: darknet presence, sanctioned entity contact, illegal fundraising

**Recommendation:**
- Continue monitoring cryptocurrency transactions
- Flag any contact with high-risk entities
- Escalate if transaction volume exceeds $1M in 30-day period
```

### Intelligence Gaps

```markdown
**Known Unknowns:**
- [ ] Government-issued ID verification (no passport/driver's license obtained)
- [ ] Physical address (residence unknown, only IP geolocation available)
- [ ] Employment status (LinkedIn shows "self-employed" but no verification)
- [ ] Source of funds for cryptocurrency investments
- [ ] Full list of cryptocurrency wallets (only 3 confirmed, likely more)
- [ ] Associates in jurisdiction X (geographic gap in intelligence)

**Collection Priorities:**
1. **High:** Obtain physical address via commercial data brokers
2. **High:** Map complete cryptocurrency wallet cluster
3. **Medium:** Verify employment claims via business registry
4. **Low:** Historical social media activity (pre-2020)
```

---

## 7. Operational Notes

### OPSEC Considerations

> Canonical guidance lives in [[sop-opsec-plan|OPSEC Plan]] — the example block below records the dossier-specific **execution log**, not the policy. Do not re-derive sock-puppet provisioning, network egress, or device-hardening doctrine here.

```markdown
**Investigator OPSEC (per-dossier execution log):**
- ✅ All queries performed via VPN (exit node: Switzerland)
- ✅ Burner email used for service registrations (e.g. ProtonMail / SimpleLogin alias — pick per [[sop-opsec-plan|OPSEC]] §Identities)
- ✅ Browser fingerprinting protection enabled (Mullvad Browser, or Tor Browser for higher-risk pivots)
- ⚠️ Avoid direct contact with entity's social media (may alert target — LinkedIn especially: anonymous viewing requires Premium and is not perfectly opaque [verify 2026-04-26])
- ⚠️ Use passive OSINT only; no active probing of infrastructure

**Sensitive Actions Log:**
| Date | Action | Tool/Method | Alert Risk | Mitigation |
|------|--------|-------------|------------|------------|
| 2024-10-01 | LinkedIn profile view | Manual | Low | Used anonymous account |
| 2024-10-02 | WHOIS lookup | whois command | None | Passive query |
| 2024-10-03 | Shodan search | Shodan API | None | Passive database query |
```

### Next Steps

```markdown
**Immediate Actions:**
- [ ] Submit cryptocurrency wallets to blockchain analytics platform (Chainalysis)
- [ ] Cross-reference email addresses with additional breach databases
- [ ] Request historical WHOIS data via DomainTools
- [ ] Monitor social media accounts for new posts

**Follow-Up Tasks (7-day timeline):**
- [ ] Re-check data breach databases for new exposures
- [ ] Verify employment claims via LinkedIn Sales Navigator
- [ ] Attempt to identify additional cryptocurrency wallets via clustering
- [ ] Review archived website snapshots for historical data (Wayback Machine)

**Long-Term Monitoring:**
- [ ] Set up Google Alerts for entity name + aliases
- [ ] Configure social media monitoring (Hootsuite, X Pro [formerly TweetDeck — renamed Aug 2023, gated behind X Premium], Bluesky deck.blue, Mastodon Elk/Phanpy)
- [ ] Subscribe to blockchain transaction alerts (Whale Alert)
- [ ] Periodic review every 30 days
```

### Legal & Compliance

> Jurisdictional framing (CFAA, CMA, EU Cybercrime Directive 2013/40/EU, GDPR Art. 6/9, DPA 2018, BIPA/CUBI, etc.) is canonical in [[sop-legal-ethics|Legal & Ethics]] — **do not re-derive here**. Capture only the per-dossier authorization record below; flag minor-related, exploitation, or trafficking content per [[sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake]] *immediately* and stop collection until escalation completes.

```markdown
**Per-dossier authorization record:**
- Case ID: CASE-2025-1005-001
- Authorized by: [Legal Team / Supervisor Name]
- Authorization date: 2025-10-01
- Scope: Open-source intelligence only (no hacking, no illegal access)
- Expiration: 2025-12-31 (renewable)
- Lawful basis (GDPR Art. 6 / Art. 9 if special-category data): [select + cite]

**Data handling (align with [[sop-collection-log|Collection Log]] retention schedule):**
- Classification: CONFIDENTIAL
- Storage: Encrypted vault (AES-256-GCM or stronger; document KMS / passphrase custody)
- Access: Analyst + supervisor only (RBAC enforced)
- Retention: 7 years per policy (verify against jurisdictional limit)
- Disposal: Secure deletion after retention period (NIST SP 800-88 Rev. 1 sanitization)

**Operational boundaries (canonical list in [[sop-legal-ethics|Legal & Ethics]]):**
- ✅ Public records search (WHOIS / RDAP, social media, blockchain, court PACER, etc.)
- ✅ Data breach database queries (HIBP, Dehashed, IntelX — per licensing + jurisdiction)
- ✅ Commercial data brokers (within licensing terms; document the dataset version)
- ❌ Unauthorized access to private accounts
- ❌ Social engineering or pretexting
- ❌ Exploitation of vulnerabilities
- ❌ Scraping in violation of CFAA / CMA / GDPR Art. 6 lawful-basis tests (see [[sop-legal-ethics|Legal & Ethics]] §Scraping)
```

---

## 8. Appendix

### Tools Used

Replace fictional version pins with `--version` invocations at audit time. Versions below are illustrative anchors `[verify 2026-04-26]`.

| Tool              | Type    | Purpose                                | Command / Link                                                                 |
| ----------------- | ------- | -------------------------------------- | ------------------------------------------------------------------------------ |
| WhatsMyName       | CLI/Web | Username enumeration (canonical)       | [whatsmyname.app](https://whatsmyname.app) / [WebBreacher/WhatsMyName](https://github.com/WebBreacher/WhatsMyName) |
| Maigret           | CLI     | Username enumeration + profile parse   | [soxoj/maigret](https://github.com/soxoj/maigret)                              |
| Sherlock          | CLI     | Username enumeration (legacy, active)  | [sherlock-project/sherlock](https://github.com/sherlock-project/sherlock)      |
| Nuclei (v3.x)     | CLI     | Surface-level OSINT templates          | `nuclei -t http/osint/`                                                        |
| theHarvester      | CLI     | Email/domain OSINT                     | `theHarvester -d domain.com -b all` (current 4.x)                              |
| WHOIS / RDAP      | CLI     | Domain registration lookup             | `whois domain.com` / `openrdap` / `rdap.org`                                   |
| Shodan / Censys / FOFA / ZoomEye | Web/CLI | Internet-wide attribution         | `shodan search ...` (verify tier + active credits)                             |
| Have I Been Pwned | API     | Data breach check (v3 API key required) | [haveibeenpwned.com](https://haveibeenpwned.com)                               |
| Dehashed / IntelX | Web/API | Breach + leak corpus search            | per licensing                                                                  |
| mempool.space / Blockstream Esplora | API | Bitcoin chain analysis (open)     | `https://mempool.space/api/...`                                                |
| Etherscan         | API     | Ethereum chain analysis                | [etherscan.io](https://etherscan.io)                                           |
| Chainalysis Reactor / TRM Labs / Elliptic / Crystal / GraphSense | Commercial / OSS | Wallet clustering & risk scoring | per licensing                          |
| OpenSanctions     | Web/API | Sanctions + PEP aggregation            | [opensanctions.org](https://www.opensanctions.org)                             |
| OpenCorporates    | Web/API | Corporate registry index               | [opencorporates.com](https://opencorporates.com)                               |
| ICIJ OffshoreLeaks / OCCRP Aleph | Web | Investigative leak corpus            | [offshoreleaks.icij.org](https://offshoreleaks.icij.org) / [aleph.occrp.org](https://aleph.occrp.org) |
| ExifTool          | CLI     | Metadata extraction                    | `exiftool image.jpg`                                                           |
| Maltego CE        | GUI     | Link analysis                          | [maltego.com](https://www.maltego.com) (Maltego Technology GmbH)               |
| i2 Analyst's Notebook | GUI | Link analysis (commercial)             | N. Harris Computer Corp acquired from IBM 2022 `[verify 2026-04-26]`           |
| Neo4j Bloom / Linkurious / Gephi | GUI/OSS | Graph relationship viz             | per vendor                                                                     |
| Spiderfoot / Recon-ng | CLI | Automated OSINT enumeration            | [spiderfoot.net](https://www.spiderfoot.net) / [lanmaster53/recon-ng](https://github.com/lanmaster53/recon-ng) |

### Common Pitfalls

- **Name-collision sanctions hits** — common names produce false positives on PEP / SDN lists; require ≥1 corroborating identifier (DOB, country, primary identifier) before "match."
- **Stale alias confidence** — "confirmed via Twitter 2024-05-10" doesn't survive a platform sale or account migration; re-verify before publishing.
- **Cluster claims without provenance** — wallet-clustering output (Chainalysis, TRM, OXT) is an opinion of the analytics provider, not a chain-of-custody fact. Cite the provider + dataset version + run date.
- **Geolocation overconfidence** — IP geo-lookups, EXIF, and check-ins are independently weak; Berkeley Protocol §V three-source rule applies.
- **VPN / Tor false negatives** — counter-intel use of residential proxies and CGNAT collapses simple geo signals; flag rather than discard a contradicting datum.
- **Schema drift** — if you rename a front-matter field (`primary_id`, `risk`, `confidence`), every downstream Case dossier inherits the break. Add new fields rather than rename.
- **C2PA / Content Credentials absence ≠ authenticity** — see [[sop-image-video-osint|Image / Video OSINT]] §6 for synthetic-media verification limits before crediting profile photos.
- **LinkedIn anonymous-view leak** — Premium "anonymous viewer" still surfaces region/industry on the target's "Who's Viewed Your Profile" panel `[verify 2026-04-26]`. Use a clean sock-puppet account per [[sop-opsec-plan|OPSEC]].

### Related SOPs

**Methodology & authorization:**
- [[sop-legal-ethics|Legal & Ethics]] — jurisdictional framing (canonical)
- [[sop-opsec-plan|OPSEC Plan]] — investigator OPSEC, sock-puppet provisioning (canonical)
- [[sop-collection-log|Collection Log]] — chain-of-custody, evidence hashing, retention (canonical)
- [[sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — escalation triggers if dossier touches CSAM, trafficking, or imminent-harm content
- [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — final-report packaging, defang conventions

**OSINT collection feeders:**
- [[sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] — infrastructure pivots feeding §3
- [[sop-image-video-osint|Image / Video OSINT]] — visual identifiers, reverse search, C2PA
- [[sop-financial-aml-osint|Financial / AML OSINT]] — sanctions, beneficial ownership, mixers, Travel Rule
- [[sop-platform-twitter-x|X (Twitter)]] · [[sop-platform-linkedin|LinkedIn]] · [[sop-platform-instagram|Instagram]] · [[sop-platform-telegram|Telegram]] · [[sop-platform-reddit|Reddit]] · [[sop-platform-tiktok|TikTok]] · [[sop-platform-bluesky|Bluesky]] — per-platform handle/profile collection

**Evidence-side handoffs:**
- [[sop-hash-generation-methods|Hash Generation Methods]] — SHA-256 / BLAKE3 hashing of evidence artefacts
- [[sop-forensics-investigation|Forensics Investigation]] — when an OSINT dossier escalates to live-system acquisition

### External / Reference Resources

**Methodology:**
- **Berkeley Protocol on Digital Open Source Investigations** (UN OHCHR + UC Berkeley HRC, 2022) — canonical methodology, esp. §V Information Verification.
- **NATO STANAG 2511 / AJP-2 — Admiralty Code** — A–F source-credibility × 1–6 information-credibility matrix.
- **Cone of Plausibility** (Charles W. Taylor / UK MoD) — bounding analytic uncertainty on forward-looking claims.
- **NIST SP 800-88 Rev. 1** — media sanitization (used at retention-period disposal).
- **SWGDE / SWGIT Best Practices** — digital-evidence forensic baseline.

**Sanctions & beneficial ownership:**
- OFAC SDN / Consolidated — `sanctionssearch.ofac.treas.gov`
- EU Consolidated Financial Sanctions — `data.europa.eu` (search "consolidated list ... financial sanctions")
- UK OFSI Consolidated List — `gov.uk/government/publications/financial-sanctions-consolidated-list-of-targets`
- UN Security Council Consolidated — `un.org/securitycouncil/sanctions/un-sc-consolidated-list`
- OpenSanctions — `opensanctions.org`
- OpenCorporates — `opencorporates.com`
- ICIJ OffshoreLeaks — `offshoreleaks.icij.org`
- OCCRP Aleph — `aleph.occrp.org`
- UK PSC (Companies House) — `find-and-update.company-information.service.gov.uk`
- US FinCEN BOI — `fincen.gov/boi` (scope narrowed by 2025 Treasury interim final rule `[verify 2026-04-26]`)

**Threat-actor / cyber-TI:**
- MITRE ATT&CK Groups — `attack.mitre.org/groups/`
- MISP — `misp-project.org`
- OpenCTI — `opencti.io`

**Identity verification (jurisdictional, with consent):**
- eIDAS (EU), GOV.UK One Login (UK), India Aadhaar (jurisdictional), US REAL ID (full enforcement May 7 2025 `[verify 2026-04-26]`)
- KYC vendors: Onfido, Jumio, Trulioo, Persona (document without endorsement)

### Case References

- Case file: `Cases/<YYYY-NNN-Brief-Description>/` (per CLAUDE.md naming)
- Evidence repository: `Cases/<YYYY-NNN-Brief-Description>/Evidence/<entity_name>/`
- Worked example: [Example Investigation](../../Cases/2025-001-Example-Investigation/README.md)
- Template: [Case Template](../../Cases/Case-Template/README.md)

## Legal & Ethical Considerations

Canonical text lives in [[sop-legal-ethics|Legal & Ethics]]. Dossier-specific reminders:

- **Lawful basis required.** GDPR Art. 6 (and Art. 9 for special-category data: biometric/health/political/religion/sexuality/criminal-conviction). Document the basis on the dossier front matter or in §7 authorization record.
- **Profiling restrictions.** GDPR Art. 22 limits decisions made solely on automated profiling — flag if downstream consumers will use the dossier in automated decisioning.
- **Cross-border transfer.** If the dossier subject is in the EU/EEA/UK and the receiving analyst is not, document the transfer mechanism (SCCs, adequacy decision, derogation).
- **Sensitive-crime triggers.** If collection surfaces CSAM, trafficking, imminent-harm threats, or terrorism content, **stop and escalate per [[sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake]]**. Do not download, hash, or screenshot until escalation completes.
- **Defamation surface.** Risk-rating language ("Critical", "High") is adversarial-context-only; avoid it in client-facing summaries unless evidence supports the claim under the relevant jurisdiction's defamation standard.
- **Subject-access / GDPR Art. 15.** Investigated subjects can request their data; prepare for SAR handling in the retention plan.

---

**Analyst:** gl0bal01
**Date Created:** 2025-10-05
**Last Updated:** 2026-04-26
**Review Cycle:** Yearly (slow-rot anchor SOP per CLAUDE.md watchlist)
