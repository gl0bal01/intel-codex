# Evidence Collection Log - Case 2025-001

**Case:** Example OSINT Investigation
**Lead Investigator:** [Your Name]
**Collection Period:** 2025-01-10 to 2025-01-15
**SOP Reference:** [sop-collection-log](../../Investigations/Techniques/sop-collection-log.md)

---

## Collection Summary

| Category              | Items  | Status           |
| --------------------- | ------ | ---------------- |
| Screenshots           | 23     | ✅ Complete       |
| WHOIS Records         | 4      | ✅ Complete       |
| Blockchain Data       | 8      | ✅ Complete       |
| Social Media Archives | 5      | ✅ Complete       |
| Victim Reports        | 15     | 🔄 Ongoing       |
| Network Logs          | 7      | ✅ Complete       |
| **TOTAL**             | **62** | **95% Complete** |

---

## Evidence Items

### E001: Twitter/X Profile - @crypto_scammer_example

**Collection Date:** 2025-01-10 14:23 UTC
**Collector:** [Your Name]
**Method:** Manual screenshot + archive.today

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E001-01 | Profile screenshot (full page) | PNG | a1b2c3d4e5f6... |
| E001-02 | Profile bio close-up | PNG | b2c3d4e5f6g7... |
| E001-03 | Follower list (page 1) | PNG | c3d4e5f6g7h8... |
| E001-04 | Following list (page 1) | PNG | d4e5f6g7h8i9... |
| E001-05 | Tweet timeline archive | HTML | e5f6g7h8i9j0... |
| E001-06 | Archive.today snapshot | URL | N/A |

**Files Location:** `03-Evidence/screenshots/twitter/`

**Archive URLs:**
- Archive.today: https://archive.ph/abc123 (example)
- Wayback Machine: https://web.archive.org/web/20250110/twitter.com/crypto_scammer_example

**Tool:**
```bash
# Screenshot command
firefox --screenshot profile-full.png https://twitter.com/crypto_scammer_example

# Archive command
curl -X POST https://archive.ph/submit/ -d "url=https://twitter.com/crypto_scammer_example"
```

**Notes:**
- Account still active as of collection time
- Captured before potential suspension
- Multiple archive services used for redundancy

---

### E002: WHOIS Records - Phishing Domain

**Collection Date:** 2025-01-10 15:47 UTC
**Collector:** [Your Name]
**Method:** WHOIS lookup + historical WHOIS

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E002-01 | Current WHOIS (crypto-presale-exclusive.com) | TXT | f6g7h8i9j0k1... |
| E002-02 | Historical WHOIS (Dec 15, 2024) | TXT | g7h8i9j0k1l2... |
| E002-03 | DNS records (A, MX, TXT) | JSON | h8i9j0k1l2m3... |
| E002-04 | SSL certificate details | PEM | i9j0k1l2m3n4... |

**Files Location:** `03-Evidence/domains/`

**Commands Used:**
```bash
# WHOIS lookup
whois crypto-presale-exclusive.com > whois-crypto-presale.txt

# DNS records
dig crypto-presale-exclusive.com ANY +noall +answer > dns-records.txt

# SSL certificate
echo | openssl s_client -connect crypto-presale-exclusive.com:443 2>/dev/null | openssl x509 -text > ssl-cert.txt

# Historical WHOIS
curl "https://whoishistory.whoisxmlapi.com/api/v1?apiKey=KEY&domainName=crypto-presale-exclusive.com" > whois-history.json
```

**Key Findings:**
- Registrant email: alex.crypto.trades@protonmail.com
- Privacy protection enabled (contact details hidden)
- Registered December 15, 2024 (3 weeks before investigation)
- Hosted on Cloudflare (origin IP hidden)

---

### E003: Victim Direct Messages

**Collection Date:** 2025-01-11 09:15 UTC
**Collector:** [Your Name]
**Method:** Victim-provided screenshots (with consent)

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E003-01 | Victim 1 DM conversation (full) | PNG | j0k1l2m3n4o5... |
| E003-02 | Victim 2 DM conversation | PNG | k1l2m3n4o5p6... |
| E003-03 | Victim 3 DM conversation | PNG | l2m3n4o5p6q7... |
| E003-04 | Victim 4 DM conversation | PNG | m3n4o5p6q7r8... |
| E003-05 | Victim 5 DM conversation | PNG | n4o5p6q7r8s9... |
| ... | ... | ... | ... |
| E003-15 | Victim 15 DM conversation | PNG | x8y9z0a1b2c3... |

**Files Location:** `03-Evidence/victim-reports/`

**Collection Process:**
1. Victim contacted investigator via client referral
2. Consent form signed (allowing use of screenshots)
3. Victim provided unedited screenshots via encrypted email
4. Screenshots verified for authenticity (EXIF data, metadata)
5. Victim identity redacted in documentation (privacy protection)

**Common Message Pattern:**
```
"Hey [Name]! 👋 I noticed you follow @RealCryptoGuru.
We're running an exclusive presale for early supporters.
Only 10 spots left - ending tonight!

Check it out: crypto-presale-exclusive[.]com/vip

This is not financial advice, but this could be life-changing 🚀
Let me know if you have questions!"
```

**Notes:**
- All messages follow similar template
- Personalized with victim's name (scraped from profile)
- Urgency tactics consistent across all victims
- Link always directs to phishing domain

---

### E004: Blockchain Transaction Data

**Collection Date:** 2025-01-12 11:33 UTC
**Collector:** [Your Name]
**Method:** Etherscan API + manual verification

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E004-01 | Primary wallet transaction history | JSON | o5p6q7r8s9t0... |
| E004-02 | Transaction graph visualization | PNG | p6q7r8s9t0u1... |
| E004-03 | Victim 1 transaction (2.5 ETH) | JSON | q7r8s9t0u1v2... |
| E004-04 | Victim 2 transaction (1.8 ETH) | JSON | r8s9t0u1v2w3... |
| E004-05 | Mixer transaction (Tornado Cash) | JSON | s9t0u1v2w3x4... |
| E004-06 | Exchange deposit addresses | CSV | t0u1v2w3x4y5... |
| E004-07 | Wallet balance history | CSV | u1v2w3x4y5z6... |
| E004-08 | Smart contract interactions | JSON | v2w3x4y5z6a7... |

**Files Location:** `03-Evidence/blockchain/`

**Primary Wallet Analysis:**
```
Address: 0x1234abcd5678ef90abcd1234ef567890abcd1234
Network: Ethereum Mainnet
First Transaction: 2024-12-20 18:45:32 UTC
Last Transaction: 2025-01-10 03:21:17 UTC
Total Inbound: 87.3 ETH
Total Outbound: 87.3 ETH
Current Balance: 0 ETH
Transaction Count: 104
```

**Data Collection Commands:**
```bash
# Etherscan API (get transaction list)
curl "https://api.etherscan.io/api?module=account&action=txlist&address=0x1234abcd5678ef90abcd1234ef567890abcd1234&apikey=YOUR_API_KEY" > wallet-txlist.json

# Get token transfers
curl "https://api.etherscan.io/api?module=account&action=tokentx&address=0x1234abcd5678ef90abcd1234ef567890abcd1234&apikey=YOUR_API_KEY" > wallet-tokens.json

# Get internal transactions
curl "https://api.etherscan.io/api?module=account&action=txlistinternal&address=0x1234abcd5678ef90abcd1234ef567890abcd1234&apikey=YOUR_API_KEY" > wallet-internal.json
```

**Key Transactions:**
```
Tx Hash: 0xabc123def456... | From: Victim 1 | Amount: 2.5 ETH | Date: 2024-12-20
Tx Hash: 0xdef456ghi789... | From: Victim 2 | Amount: 1.8 ETH | Date: 2024-12-22
Tx Hash: 0xghi789jkl012... | To: Mixer    | Amount: 87.3 ETH | Date: 2024-12-29
```

**Analysis:**
- Funds received from 52 unique addresses (victims)
- All funds immediately forwarded to secondary wallet
- Secondary wallet sends to Tornado Cash mixer
- Post-mixer trail goes cold (privacy protocol works as intended)

---

### E005: Instagram Profile Archive

**Collection Date:** 2025-01-10 16:52 UTC (before suspension)
**Collector:** [Your Name]
**Method:** Manual archive + Instaloader tool

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E005-01 | Profile screenshot | PNG | w3x4y5z6a7b8... |
| E005-02 | All posts archive (23 images) | ZIP | x4y5z6a7b8c9... |
| E005-03 | Bio and link history | TXT | y5z6a7b8c9d0... |
| E005-04 | Follower/following list | JSON | z6a7b8c9d0e1... |
| E005-05 | Stories archive (7 items) | ZIP | a7b8c9d0e1f2... |

**Files Location:** `03-Evidence/social-media/instagram/`

**Collection Tool:**
```bash
# Instaloader (open-source Instagram scraper)
instaloader profile crypto.alex.trades --login YOUR_ACCOUNT --dirname-pattern=03-Evidence/social-media/instagram

# Download profile picture
instaloader --profile-pic-only crypto.alex.trades

# Download all posts
instaloader --no-videos --no-profile-pic crypto.alex.trades
```

**Account Status:**
- Collected: 2025-01-10 16:52 UTC
- Suspended: 2025-01-12 08:15 UTC (confirmed via platform notification)
- Reason: Terms of Service violation (suspected impersonation/fraud)

**Content Analysis:**
- 23 posts total (all stolen from other accounts)
- 7 stories showing fake "profit screenshots"
- Link in bio: crypto-presale-exclusive[.]com (phishing)
- Comments disabled on all posts (avoiding scrutiny)

---

### E006: Telegram Channel Archive

**Collection Date:** 2025-01-11 13:28 UTC
**Collector:** [Your Name]
**Method:** Telegram export + manual screenshots

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E006-01 | Channel profile screenshot | PNG | b8c9d0e1f2g3... |
| E006-02 | Full message history export | JSON | c9d0e1f2g3h4... |
| E006-03 | Member list (47 users) | JSON | d0e1f2g3h4i5... |
| E006-04 | Media files archive | ZIP | e1f2g3h4i5j6... |
| E006-05 | Pinned messages | PNG | f2g3h4i5j6k7... |

**Files Location:** `03-Evidence/social-media/telegram/`

**Channel Information:**
```
Username: @crypto_alex_official
Title: "VIP Crypto Presale - Alex Morgan"
Description: "Exclusive presale opportunities | Early access | VIP only 🚀"
Members: 47
Created: 2024-11-28 (same day as Twitter account)
```

**Export Command:**
```bash
# Telegram Desktop: Settings → Advanced → Export Chat History
# Format: JSON + media
# Time period: All time
```

**Message Patterns:**
- Daily posts about "limited presale opportunities"
- DMs sent to new members with phishing links
- Fake urgency ("last chance", "ending tonight")
- No actual crypto discussion (pure sales pitch)

---

### E007: Network/IP Intelligence

**Collection Date:** 2025-01-12 10:15 UTC
**Collector:** [Your Name]
**Method:** Passive DNS, Shodan, IP intelligence APIs

| Item ID | Description | Format | Hash (SHA-256) |
|---------|-------------|--------|----------------|
| E007-01 | Tor exit node logs (public) | JSON | g3h4i5j6k7l8... |
| E007-02 | Cloudflare CDN analysis | JSON | h4i5j6k7l8m9... |
| E007-03 | Passive DNS history | CSV | i5j6k7l8m9n0... |
| E007-04 | IP geolocation data | JSON | j6k7l8m9n0o1... |
| E007-05 | Server fingerprint (Shodan) | JSON | k7l8m9n0o1p2... |
| E007-06 | SSL/TLS certificate chain | PEM | l8m9n0o1p2q3... |
| E007-07 | HTTP headers analysis | TXT | m9n0o1p2q3r4... |

**Files Location:** `03-Evidence/network/`

**IP Address Analysis:**
```
Primary IP: 185.220.101.42
Type: Tor Exit Node
Location: Frankfurt, Germany (exit node, not true location)
ISP: Anonymous (Tor network)
First Observed: 2024-12-05
Last Observed: 2025-01-10
```

**Website Hosting:**
```
IP: 104.21.45.123 (Cloudflare CDN)
Origin Server: Unknown (protected by Cloudflare)
HTTP Server: nginx/1.21.6
SSL: Let's Encrypt (free certificate)
```

**Collection Commands:**
```bash
# Passive DNS lookup
curl "https://api.securitytrails.com/v1/domain/crypto-presale-exclusive.com/history/dns" \
  -H "APIKEY: YOUR_KEY" > passive-dns.json

# Shodan IP lookup
shodan host 104.21.45.123 > shodan-ip.json

# SSL certificate
echo | openssl s_client -connect crypto-presale-exclusive.com:443 -showcerts 2>/dev/null > ssl-chain.pem

# HTTP headers
curl -I https://crypto-presale-exclusive.com > http-headers.txt
```

---

### E008-E015: Victim Interview Statements

**Collection Dates:** 2025-01-11 to 2025-01-14
**Collector:** [Your Name]
**Method:** Structured interviews (consent obtained)

| Item ID | Victim | Loss Amount | Interview Date | Format | Hash |
|---------|--------|-------------|----------------|--------|------|
| E008 | V001 | 2.5 ETH | 2025-01-11 | PDF | n0o1p2q3r4s5... |
| E009 | V002 | 1.8 ETH | 2025-01-11 | PDF | o1p2q3r4s5t6... |
| E010 | V003 | 3.2 ETH | 2025-01-12 | PDF | p2q3r4s5t6u7... |
| E011 | V004 | 0.9 ETH | 2025-01-12 | PDF | q3r4s5t6u7v8... |
| E012 | V005 | 2.1 ETH | 2025-01-13 | PDF | r4s5t6u7v8w9... |
| E013 | V006 | 1.5 ETH | 2025-01-13 | PDF | s5t6u7v8w9x0... |
| E014 | V007 | 4.0 ETH | 2025-01-14 | PDF | t6u7v8w9x0y1... |
| E015 | V008 | 2.7 ETH | 2025-01-14 | PDF | u7v8w9x0y1z2... |

**Files Location:** `03-Evidence/victim-reports/interviews/`

**Interview Structure:**
1. Consent and privacy notice
2. Background (how they discovered account)
3. Communication timeline
4. Financial transaction details
5. Supporting evidence (screenshots, transaction hashes)
6. Impact statement

**Common Themes:**
- All victims found account via Twitter
- Most received unsolicited DM
- All trusted account due to stolen profile picture
- Urgency tactics influenced decision-making
- None verified account authenticity before sending funds

---

## Evidence Integrity

### Hash Verification

All evidence files have been hashed using SHA-256 for integrity verification:

```bash
# Generate hash manifest
find 03-Evidence/ -type f -exec sha256sum {} \; > evidence-hashes.txt

# Verify integrity (run periodically)
sha256sum -c evidence-hashes.txt
```

**Hash Manifest Location:** `05-Admin/evidence-hashes.txt`

---

### Chain of Custody

| Evidence ID | Collected By | Date/Time | Transferred To | Date/Time | Purpose |
|-------------|--------------|-----------|----------------|-----------|---------|
| E001-E007 | [Your Name] | 2025-01-10-12 | Encrypted storage | 2025-01-10 | Secure backup |
| E001 | [Your Name] | 2025-01-10 | Client (copy) | 2025-01-13 | Client review |
| ALL | [Your Name] | 2025-01-15 | Evidence package | 2025-01-15 | LEO referral prep |

**Custody Log Location:** `05-Admin/chain-of-custody.pdf`

---

### Storage & Backup

**Primary Storage:**
- Location: Encrypted external SSD (AES-256)
- Access: Password-protected, 2FA enabled
- Backup Schedule: Daily incremental, weekly full

**Secondary Backup:**
- Location: Encrypted cloud storage (client-provided)
- Provider: Client's secure infrastructure
- Encryption: End-to-end encrypted before upload

**Retention Policy:**
- Active case: Indefinite retention
- Post-case: Retain per client agreement (typically 7 years)
- Destruction: Secure deletion per NIST SP 800-88

---

## Collection Tools Used

| Tool | Version | Purpose | License |
|------|---------|---------|---------|
| Firefox | 121.0 | Screenshot capture | Open Source |
| Archive.today | N/A | Web page archiving | Free Service |
| WHOIS | CLI | Domain registration lookup | Open Source |
| Etherscan API | v1 | Blockchain data collection | Free/Commercial |
| Instaloader | 4.10 | Instagram archiving | Open Source |
| Telegram Desktop | 4.15 | Telegram export | Open Source |
| OpenSSL | 3.0.2 | SSL certificate analysis | Open Source |
| curl | 8.5.0 | HTTP requests/downloads | Open Source |
| Shodan API | N/A | Network intelligence | Commercial |

---

## Collection Methodology Compliance

**SOPs Followed:**
- ✅ [[Investigations/Techniques/sop-collection-log|Collection Logging SOP]]
- ✅ [[Investigations/Techniques/sop-legal-ethics|Legal & Ethics SOP]]
- ✅ [[Investigations/Techniques/sop-opsec-plan|OPSEC Planning SOP]]

**Legal Compliance:**
- ✅ All data collected from publicly accessible sources
- ✅ No unauthorized access to accounts or systems
- ✅ Victim consent obtained for private communications
- ✅ Data handling compliant with GDPR/CCPA

**Quality Control:**
- ✅ All evidence timestamped and geotagged (when applicable)
- ✅ Multiple archive methods used (redundancy)
- ✅ Hashing performed for integrity verification
- ✅ Chain of custody documented

---

## Pending Collections

### Outstanding Items

| Item | Description | Status | Expected Date |
|------|-------------|--------|---------------|
| P001 | Victim 9-15 interviews | 🔄 Scheduled | 2025-01-16 |
| P002 | Additional blockchain wallet analysis | 🔄 In progress | 2025-01-17 |
| P003 | Historical domain registration data | 🔄 Awaiting API access | 2025-01-18 |
| P004 | Cross-reference with similar scams | 🔄 Research phase | 2025-01-20 |

---

## Collection Notes

### Challenges Encountered

**Technical:**
- Instagram suspended mid-collection (resolved: used cached data)
- Cloudflare hiding origin server IP (limitation: cannot determine true host)
- Tornado Cash mixer preventing transaction tracing (limitation: accepted)

**Legal/Ethical:**
- Victim privacy concerns (resolved: anonymization and consent forms)
- Cross-border jurisdiction questions (resolved: legal counsel consulted)

**Operational:**
- Subject using Tor (limitation: cannot trace real IP)
- ProtonMail refusing disclosure (expected: privacy-focused service)

### Lessons Learned

1. **Archive early and often:** Instagram suspension highlighted importance of immediate archiving
2. **Multiple sources:** Redundant collection methods prevented data loss
3. **Victim engagement:** Personal interviews provided valuable context beyond digital evidence
4. **Documentation:** Detailed logging essential for legal proceedings

---

**Collection Log Maintained By:** [Your Name]
**Last Updated:** 2025-01-15 18:45 UTC
**Next Review:** 2025-01-16 09:00 UTC
**Status:** 🟢 Active Collection
