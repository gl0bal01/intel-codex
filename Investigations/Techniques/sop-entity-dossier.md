---
type: dossier
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
updated: 2025-10-05
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
# Nuclei - find usernames across platforms
nuclei -tags osint -var user=entity_name

# WhatsMyName
python3 whatsmyname.py -u entity_name

# Manual check
# Twitter: https://twitter.com/entity_name
# Instagram: https://instagram.com/entity_name
# GitHub: https://github.com/entityname
```

**Bio/Description Correlation:**
- Twitter bio: "Crypto enthusiast | Privacy advocate | Coffee lover"
- Instagram bio: "☕ Crypto & Privacy | DM for collabs"
- LinkedIn bio: "Cryptocurrency consultant specializing in privacy tech"
- **Common themes:** Cryptocurrency, privacy, professional availability

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
# Check wallet balance and transactions
curl -s "https://blockchain.info/balance?active=bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"

# Transaction history
curl -s "https://blockchain.info/rawaddr/bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh" | jq '.txs'

# Cluster analysis (wallet.explorer.btc.com)
# Linked wallets: 5 addresses in same cluster
# Total balance across cluster: 15.3 BTC (~$450,000 USD at 2024 rates)
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

```markdown
**Investigator OPSEC:**
- ✅ All queries performed via VPN (exit node: Switzerland)
- ✅ Burner email used for service registrations (tempmail@proton.me)
- ✅ Browser fingerprinting protection enabled (Mullvad Browser)
- ⚠️ Avoid direct contact with entity's social media (may alert target)
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
- [ ] Configure social media monitoring (Hootsuite, TweetDeck)
- [ ] Subscribe to blockchain transaction alerts (Whale Alert)
- [ ] Periodic review every 30 days
```

### Legal & Compliance

```markdown
**Authorization:**
- Case ID: CASE-2025-1005-001
- Authorized by: [Legal Team / Supervisor Name]
- Authorization date: 2025-10-01
- Scope: Open-source intelligence only (no hacking, no illegal access)
- Expiration: 2025-12-31 (renewable)

**Data Handling:**
- Classification: CONFIDENTIAL
- Storage: Encrypted vault (AES-256)
- Access: Analyst + supervisor only
- Retention: 7 years per policy
- Disposal: Secure deletion after retention period

**Legal Boundaries:**
- ✅ Public records search (WHOIS, social media, blockchain)
- ✅ Data breach database queries (HIBP, Dehashed)
- ✅ Commercial data brokers (within licensing terms)
- ❌ Unauthorized access to private accounts
- ❌ Social engineering or pretexting
- ❌ Exploitation of vulnerabilities
```

---

## 8. Appendix

### Tools Used

| Tool              | Version | Purpose                      | Command/Link                                     |
| ----------------- | ------- | ---------------------------- | ------------------------------------------------ |
| Nuclei            | 9.15    | Username enumeration         | `nuclei -tags osint -var user=username`          |
| theHarvester      | 4.5.0   | Email/domain OSINT           | `theHarvester -d domain.com -b all`              |
| WHOIS             | CLI     | Domain registration lookup   | `whois domain.com`                               |
| Shodan            | Web/CLI | Internet-wide device search  | `shodan search query`                            |
| Have I Been Pwned | API     | Data breach check            | [haveibeenpwned.com](https://haveibeenpwned.com) |
| Blockchain.info   | API     | Bitcoin blockchain analysis  | [blockchain.info](https://blockchain.info)       |
| Etherscan         | API     | Ethereum blockchain analysis | [etherscan.io](https://etherscan.io)             |
| ExifTool          | CLI     | Metadata extraction          | `exiftool image.jpg`                             |
| Maltego           | CE      | Link analysis                | [maltego.com](https://www.maltego.com)           |

### References

- Case file: `/cases/CASE-2025-1005-001/`
- Evidence repository: `/evidence/CASE-2025-1005-001/entity_name/`
- Related entities:
  - [Example Investigation](../../Cases/2025-001-Example-Investigation/README.md)
  - [entity-example-person](../Entity-Dossiers/entity-example-person.md)
  - [entity-example-organization](../Entity-Dossiers/entity-example-organization.md)


---

**Analyst:** gl0bal01
**Date Created:** 2025-10-10
**Last Updated:** 2025-10-10
**Review Cycle:** Yearly
