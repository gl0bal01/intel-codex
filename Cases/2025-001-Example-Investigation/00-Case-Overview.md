# Case 2025-001: Example OSINT Investigation

## Case Information

**Case Number:** 2025-001
**Case Name:** Example Social Media Fraud Investigation
**Status:** 🟢 Active (Example Case)
**Priority:** Medium
**Date Opened:** 2025-01-15
**Lead Investigator:** [Your Name]
**Classification:** EXAMPLE / TRAINING

---

## Executive Summary

This is a **dummy case** created for demonstration purposes. It shows how to structure and document an OSINT investigation using the SOPs in this vault.

**Scenario:** Investigation into a suspected social media impersonation and financial fraud scheme targeting cryptocurrency investors.

**Key Findings (Example):**
- Identified 3 fake social media accounts impersonating legitimate crypto influencer
- Located IP address range associated with threat actor (VPN service in Eastern Europe)
- Discovered pattern of phishing links leading to fake trading platform
- Estimated victim count: ~50-100 individuals
- Estimated financial loss: $75,000 - $150,000 USD

---

## Case Details

### Background

**Client/Requestor:** Example Crypto Exchange (fictional)
**Incident Type:** Impersonation, Phishing, Financial Fraud
**Target of Investigation:** @crypto_scammer_example (Twitter/X account)

**Initial Report:**
Multiple users reported receiving direct messages from what appeared to be a verified crypto influencer account (@RealCryptoGuru), asking them to invest in a "private presale" opportunity. The messages included links to a website that mimicked a legitimate cryptocurrency exchange.

### Scope

**In Scope:**
- Social media account analysis (Twitter/X, Telegram, Instagram)
- Domain/website investigation
- Financial transaction analysis (blockchain)
- Network infrastructure (IP addresses, hosting)
- Timeline reconstruction

**Out of Scope:**
- Direct communication with suspect (law enforcement only)
- Access to private messages without authorization
- Hacking or unauthorized access to accounts/systems

**Geographic Focus:** Global (online investigation)
**Time Period:** 2024-12-01 to 2025-01-15

---

## Subjects/Entities

### Primary Subject
[01-Subject-Profiles](01-Subject-Profiles.md)

**Handle:** @crypto_scammer_example
**Platform:** Twitter/X
**Display Name:** "Alex Morgan - Crypto Analyst"
**Profile Created:** 2024-11-28
**Followers:** 1,247 (as of 2025-01-10)
**Profile Picture:** Stolen from legitimate influencer @RealCryptoGuru

**Indicators:**
- Recently created account (red flag)
- Bio identical to legitimate account
- No verification badge (impersonating verified account)
- Suspicious engagement patterns (bought followers likely)

### Related Entities

**Associated Accounts:**
- Telegram: @crypto_alex_official (suspicious)
- Instagram: @crypto.alex.trades (suspended 2025-01-12)
- Website: crypto-presale-exclusive[.]com (taken down 2025-01-13)

**Infrastructure:**
- IP Address: 185.220.101.XXX (Tor exit node)
- Hosting: Namecheap (domain registrar)
- Email: alex.crypto.trades@protonmail.com (identified in WHOIS)

---

## Investigation Timeline

### 2024-11-28
- **Event:** Fake Twitter account created (@crypto_scammer_example)
- **Source:** Twitter API / manual verification
- **Evidence:** Screenshot saved in `03-Evidence/screenshots/account-creation.png`

### 2024-12-05
- **Event:** First phishing message sent to victim
- **Source:** Victim report to client
- **Evidence:** DM screenshot in `03-Evidence/victim-reports/victim-001.png`

### 2024-12-15
- **Event:** Phishing domain registered (crypto-presale-exclusive[.]com)
- **Source:** WHOIS lookup, crt.sh
- **Evidence:** `03-Evidence/domains/whois-crypto-presale.txt`

### 2025-01-08
- **Event:** Instagram account @crypto.alex.trades identified
- **Source:** Reverse image search of profile picture
- **Evidence:** `03-Evidence/social-media/instagram-profile.png`

### 2025-01-10
- **Event:** Investigation initiated by client
- **Source:** Internal case file
- **Evidence:** Case assignment email

### 2025-01-12
- **Event:** Instagram account suspended
- **Source:** Platform moderation (reported by victims)
- **Evidence:** Suspension notice screenshot

### 2025-01-13
- **Event:** Phishing domain taken down
- **Source:** Domain registrar abuse report
- **Evidence:** `03-Evidence/domains/takedown-confirmation.pdf`

### 2025-01-15
- **Event:** Case opened for formal investigation
- **Source:** This case file
- **Evidence:** N/A

---

## Collection Log

Detailed collection activities are tracked in: [[02-Collection-Log]]

**Summary Statistics:**
- Total items collected: 47
- Screenshots: 23
- WHOIS records: 4
- Blockchain transactions: 8
- Social media archives: 5
- Network logs: 7

**Key Evidence Items:**
- E001: Fake Twitter profile screenshots (10 images)
- E002: WHOIS records for phishing domain
- E003: Victim direct message screenshots (15 images)
- E004: Blockchain transaction hashes (8 transactions)
- E005: IP address logs from phishing site

---

## Analysis & Findings

### Social Media Analysis

**Twitter/X Account (@crypto_scammer_example):**
- **Account Age:** 48 days (suspiciously recent)
- **Follower Analysis:**
  - 1,247 followers
  - 73% appear to be bot accounts (based on profile analysis)
  - Purchased followers likely from SMM panel
- **Tweet Patterns:**
  - Retweets legitimate crypto news (appears normal)
  - DMs sent to followers of @RealCryptoGuru (targeted approach)
  - No original content (all stolen from legitimate account)

**Cross-Platform Presence:**
- Telegram account created same day as Twitter (coordinated)
- Instagram account used same stolen profile picture
- Consistent handle pattern: "crypto_alex" / "alex.crypto"

### Domain/Infrastructure Analysis

**Primary Phishing Domain:**
```
Domain: crypto-presale-exclusive[.]com
Registered: 2024-12-15
Registrar: Namecheap
Registrant Email: alex.crypto.trades@protonmail.com
IP Address: 185.220.101.42 (Hosting: Cloudflare)
SSL Certificate: Let's Encrypt (free)
```

**Website Analysis:**
- Near-perfect clone of legitimate exchange
- Fake "KYC verification" form (data harvesting)
- Fake crypto wallet addresses for deposits
- No actual trading functionality (pure scam)

**Network Infrastructure:**
- Used Cloudflare CDN to hide origin server
- Email communications through ProtonMail (anonymous)
- Payment address changes per victim (laundering technique)

### Financial Analysis

**Blockchain Investigation (Ethereum):**

**Primary Wallet:** 0x1234...abcd (example address)
- **Inbound Transactions:** 52 deposits
- **Total Received:** ~87.3 ETH (~$150,000 USD at time)
- **Outbound Transactions:** Funds moved through mixer (Tornado Cash)

**Victim Deposits (Examples):**
```
Tx Hash: 0xabc123... | Amount: 2.5 ETH | Date: 2024-12-20
Tx Hash: 0xdef456... | Amount: 1.8 ETH | Date: 2024-12-22
Tx Hash: 0x789ghi... | Amount: 3.2 ETH | Date: 2024-12-28
```

**Money Laundering Pattern:**
1. Victim deposits to wallet A
2. Funds immediately forwarded to wallet B
3. Wallet B sends to Tornado Cash (mixer)
4. Funds emerge from mixer to exchanges (cashout)

### Attribution Indicators

**Language Analysis:**
- Profile bio contains British English spelling ("analyse", "favour")
- DM messages show inconsistent grammar (likely non-native speaker)
- Timezone analysis: Most active 14:00-22:00 UTC+3 (Eastern Europe likely)

**Technical Indicators:**
- Domain registered with privacy protection
- Uses VPN/Tor for anonymity
- ProtonMail for email (privacy-focused)
- Cryptocurrency payments only (no traceable fiat)

**Behavioral Patterns:**
- Targets specific demographic (crypto investors, age 25-45)
- Uses urgency tactics ("limited spots", "closing soon")
- Builds trust through fake verification badges
- Mimics legitimate influencer's communication style

---

## Risk Assessment

**Threat Level:** 🟡 Medium

**Ongoing Risks:**
- Additional accounts may exist (suspect likely operating multiple personas)
- Victims continue to discover fraud (complaints increasing)
- Funds likely unrecoverable (laundered through mixers)
- Suspect may rebrand and continue operations

**Victim Impact:**
- 50-100+ estimated victims
- $75,000-$150,000 USD estimated losses
- Reputational damage to legitimate influencer being impersonated

---

## Recommendations

### Immediate Actions
1. ✅ **Report to Platforms** (Completed 2025-01-12)
   - Twitter: Account reported and under review
   - Instagram: Account suspended
   - Telegram: Report filed

2. ✅ **Domain Takedown** (Completed 2025-01-13)
   - Abuse report filed with Namecheap
   - Domain disabled

3. 🔄 **Victim Notification** (In Progress)
   - Client notifying known victims
   - Warning posted on legitimate @RealCryptoGuru account

### Law Enforcement Escalation

**Recommendation:** Refer to law enforcement for criminal investigation

**Relevant Agencies:**
- **FBI IC3** (Internet Crime Complaint Center): https://www.ic3.gov/
- **FTC** (Federal Trade Commission)
- **Local Law Enforcement** (based on victim locations)

**Evidence Package:**
- Prepared evidence archive: `04-Reports/evidence-package.zip`
- Chain of custody documentation: `04-Reports/chain-of-custody.pdf`
- Executive summary for LEO: `04-Reports/leo-summary.pdf`

### Long-Term Mitigation
- Implement social media monitoring for impersonation attempts
- Educate community about verification indicators
- Develop victim support resources
- Consider civil litigation (if suspect identified)

---

## Legal & Ethics Compliance

**Authorization:** ✅ Confirmed
- Engagement letter signed by client: `05-Admin/engagement-letter.pdf`
- Scope approved by legal counsel

**Data Protection:** ✅ Compliant
- All victim PII handled per GDPR/CCPA requirements
- Data stored encrypted at rest
- Access limited to authorized investigators

**Prohibited Actions:** ❌ None Performed
- No unauthorized access to accounts
- No social engineering of subjects
- No DoS or hacking attempts

**References:**
- [sop-legal-ethics](../../Investigations/Techniques/sop-legal-ethics.md)
- [sop-opsec-plan](../../Investigations/Techniques/sop-opsec-plan.md)

---

## Case Files

### Directory Structure
```
2025-001-Example-Investigation/
├── 00-Case-Overview.md (this file)
├── 01-Subject-Profiles.md
├── 02-Collection-Log.md
├── 03-Evidence/
│   ├── screenshots/
│   ├── domains/
│   ├── social-media/
│   ├── blockchain/
│   └── victim-reports/
├── 04-Reports/
│   ├── final-report.md
│   ├── evidence-package.zip
│   └── chain-of-custody.pdf
├── 05-Admin/
│   ├── engagement-letter.pdf
│   └── case-notes.md
└── README.md
```

### Related Documents
- [[01-Subject-Profiles|Subject Profiles & Dossiers]]
- [[02-Collection-Log|Evidence Collection Log]]

---

## SOPs Referenced

**Primary SOPs Used:**
- [sop-legal-ethics](../../Investigations/Techniques/sop-legal-ethics.md)
- [sop-opsec-plan](../../Investigations/Techniques/sop-opsec-plan.md)
- [sop-platform-twitter-x](../../Investigations/Platforms/sop-platform-twitter-x.md)
- [sop-platform-telegram](../../Investigations/Platforms/sop-platform-telegram.md)
- [sop-web-dns-whois-osint](../../Investigations/Techniques/sop-web-dns-whois-osint.md)
- [sop-financial-aml-osint](../../Investigations/Techniques/sop-financial-aml-osint.md)]
- [sop-collection-log](../../Investigations/Techniques/sop-collection-log.md)
- [sop-reporting-packaging-disclosure](../../Investigations/Techniques/sop-reporting-packaging-disclosure.md)

---

## Next Steps

### Pending Actions
- [ ] Complete victim interview process (5 pending)
- [ ] Finalize evidence package for law enforcement
- [ ] Coordinate with @RealCryptoGuru for public awareness campaign
- [ ] Monitor for new accounts using similar patterns
- [ ] File IC3 complaint on behalf of victims

### Follow-Up Investigation
- [ ] Search for additional phishing domains (similar registration patterns)
- [ ] Investigate cryptocurrency mixer transactions (if possible)
- [ ] Cross-reference with other reported scams (pattern matching)

### Case Closure Criteria
- Law enforcement referral complete
- All victims notified
- Evidence preserved and archived
- Final report delivered to client
- Post-case debrief conducted

---

**Case Status:** 🟢 Active (Example for demonstration)
**Last Updated:** 2025-01-15
**Next Review:** 2025-01-22

---

## Notes

> **⚠️ IMPORTANT:** This is a DUMMY CASE for demonstration and training purposes only. All names, addresses, account handles, transactions, and other details are entirely fictional and do not represent real individuals or events.

> This case file demonstrates proper OSINT investigation documentation structure. Use this as a template for real cases, ensuring all sensitive information is properly protected and handled according to legal and ethical guidelines.

---

**Case File Created By:** [Your Name]
**Template Version:** 1.0
**Based on SOPs:** Intel Codex Vault 2025-10-10
