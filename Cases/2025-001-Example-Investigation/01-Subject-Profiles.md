# Subject Profiles - Case 2025-001

**Case:** Example OSINT Investigation
**Date:** 2025-01-15
**Investigator:** [Your Name]

---

## Primary Subject: "Alex Morgan"

### Identity Overview

**Known Aliases:**
- Alex Morgan (primary persona)
- @crypto_scammer_example (Twitter/X)
- @crypto_alex_official (Telegram)
- @crypto.alex.trades (Instagram - suspended)

**Suspected Real Identity:** UNKNOWN
**Nationality:** Unknown (suspected Eastern Europe based on timezone/language patterns)
**Age:** Unknown (profile claims "28", likely false)
**Gender:** Unknown (using male persona)

---

### Digital Footprint

#### Twitter/X: @crypto_scammer_example

**Profile Information:**
```
Handle: @crypto_scammer_example
Display Name: Alex Morgan - Crypto Analyst
Bio: "Crypto analyst & investor | Helping you navigate Web3 | DM for exclusive opportunities 🚀 | Not financial advice"
Location: "London, UK" (likely false)
Website: crypto-presale-exclusive[.]com (taken down)
Joined: November 28, 2024
```

**Profile Picture:**
- Stolen from @RealCryptoGuru (legitimate influencer)
- Reverse image search confirms theft
- File: `../03-Evidence/screenshots/stolen-profile-pic.png`

**Banner Image:**
- Generic crypto/blockchain graphics
- Downloaded from free stock photo site (Unsplash)

**Activity Patterns:**
```
Peak Activity Times:
- 14:00-16:00 UTC (likely working hours)
- 19:00-22:00 UTC (evening engagement)
- Timezone: UTC+3 suspected (Eastern Europe/Middle East)

Posting Frequency:
- 3-5 retweets per day
- No original tweets
- All content copied from @RealCryptoGuru

Engagement:
- 1,247 followers (73% suspected bots)
- Following: 2,891 accounts
- Average likes: 5-10 per tweet (low engagement rate)
```

**Communication Style:**
- British English spelling in bio ("analyse", "optimise")
- DMs show grammatical errors (non-native speaker)
- Uses crypto jargon ("WAGMI", "DYOR", "to the moon")
- Urgency tactics ("limited spots", "ending soon")

**Network Analysis:**
```
Follows legitimate crypto accounts to appear credible:
- @VitalikButerin
- @CZ_Binance
- @coinbase
- Other high-profile crypto personalities

Followed by:
- Suspected bot accounts (942)
- Real users (305) - likely targeted victims
```

---

#### Telegram: @crypto_alex_official

**Profile Information:**
```
Username: @crypto_alex_official
Display Name: Alex Morgan | Crypto Analyst
Bio: "Official Telegram | Exclusive presale opportunities | VIP group"
Profile Picture: Same stolen image as Twitter
Created: November 28, 2024 (same day as Twitter)
```

**Channel/Group Activity:**
- Created private group "VIP Crypto Presale" (47 members)
- Posts match Twitter activity (cross-posting)
- Sends DMs to new members with phishing links

**Message Examples:**
```
[2024-12-20 15:34 UTC]
"Hey! Thanks for joining 👋 We have an exclusive presale ending tonight.
Only 10 spots left. Check it out: crypto-presale-exclusive[.]com/vip"

[2024-12-28 19:12 UTC]
"This is your last chance! Presale closes in 3 hours.
Don't miss 100x gains 🚀 Link: crypto-presale-exclusive[.]com/vip"
```

---

#### Instagram: @crypto.alex.trades (SUSPENDED)

**Profile Information (Before Suspension):**
```
Handle: @crypto.alex.trades
Display Name: Alex Morgan
Bio: "Crypto trader 📈 | Making life-changing gains | Link in bio"
Posts: 23 (all stolen content)
Followers: 892
Following: 1,456
Account Created: December 3, 2024
Suspended: January 12, 2025
```

**Content Analysis:**
- All posts stolen from other crypto influencers
- Stories featured fake "profit screenshots"
- Link in bio directed to phishing domain
- Comments disabled (avoiding scrutiny)

**Evidence:**
- Archived profile: `../03-Evidence/social-media/instagram-archive.html`
- Screenshots: `../03-Evidence/social-media/instagram-*.png`

---

### Infrastructure

#### Email Addresses

**Primary Email:**
```
Email: alex.crypto.trades@protonmail.com
Found in: Domain WHOIS records
Provider: ProtonMail (privacy-focused)
Created: Unknown (ProtonMail doesn't disclose)
```

**Analysis:**
- ProtonMail chosen for anonymity (encrypted, no IP logging)
- No breach data found in haveibeenpwned.com
- Email not found in public data leaks

---

#### Domain Ownership

**crypto-presale-exclusive[.]com**

```
Domain: crypto-presale-exclusive.com
Registered: December 15, 2024
Registrar: Namecheap
Registrant: REDACTED (privacy protection)
Registrant Email: alex.crypto.trades@protonmail.com
Name Servers: NS1.CLOUDFLARE.COM, NS2.CLOUDFLARE.COM
Status: SUSPENDED (as of January 13, 2025)
```

**WHOIS Record:**
```
Domain Name: CRYPTO-PRESALE-EXCLUSIVE.COM
Registry Domain ID: 2876543210_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.namecheap.com
Registrar URL: http://www.namecheap.com
Updated Date: 2024-12-15T10:23:45Z
Creation Date: 2024-12-15T10:23:45Z
Registry Expiry Date: 2025-12-15T10:23:45Z
Registrar: NameCheap, Inc.
Registrar IANA ID: 1068
```

**Historical DNS:**
```
Date Range: 2024-12-15 to 2025-01-13
A Record: 104.21.45.123 (Cloudflare proxy)
Origin IP: Unknown (hidden by Cloudflare)
```

**Evidence Files:**
- `../03-Evidence/domains/whois-crypto-presale.txt`
- `../03-Evidence/domains/dns-history.json`

---

#### Network Infrastructure

**IP Addresses Associated:**

**Primary (via Tor):**
```
IP: 185.220.101.42
Type: Tor exit node
Location: Germany (exit node, not actual location)
ISP: Anonymous
First Seen: December 5, 2024
Last Seen: January 10, 2025
```

**Website Hosting:**
```
IP: 104.21.45.123 (Cloudflare CDN)
Origin Server: Hidden
SSL Certificate: Let's Encrypt (free, automated)
```

**Analysis:**
- Subject uses Tor for anonymity when managing accounts
- Cloudflare CDN hides actual server location
- Free SSL certificate (low investment, likely burner domain)

---

### Financial Footprint

#### Cryptocurrency Wallets

**Primary Ethereum Wallet:**
```
Address: 0x1234abcd5678ef90abcd1234ef567890abcd1234 (example)
Blockchain: Ethereum (ERC-20)
First Activity: December 20, 2024
Total Received: 87.3 ETH (~$150,000 USD)
Total Sent: 87.3 ETH (moved to mixer)
Current Balance: 0 ETH
```

**Transaction Pattern:**
```
Inbound: Victim deposits (52 transactions)
  ↓
Immediate Forward: To intermediate wallet
  ↓
Mixer: Tornado Cash (privacy protocol)
  ↓
Exchange Deposits: Multiple exchanges (cashout)
```

**Notable Transactions:**
```
Tx 1: 2.5 ETH from 0xabc...123 (Victim 1) - Dec 20, 2024
Tx 2: 1.8 ETH from 0xdef...456 (Victim 2) - Dec 22, 2024
Tx 3: 3.2 ETH from 0x789...ghi (Victim 3) - Dec 28, 2024
[... 49 more transactions]
```

**Laundering Wallets (Downstream):**
```
Wallet B: 0x5678...9012 (intermediate)
Wallet C: 0x9abc...def0 (mixer interface)
Wallet D-Z: Unknown (post-mixer dispersion)
```

**Evidence:**
- Blockchain explorer screenshots: `../03-Evidence/blockchain/`
- Transaction graph: `../03-Evidence/blockchain/tx-graph.png`

---

### Behavioral Analysis

#### Modus Operandi

**Impersonation Strategy:**
1. Create accounts mimicking verified influencer
2. Steal profile picture and bio
3. Purchase bot followers to appear legitimate
4. Target followers of real influencer

**Victim Targeting:**
1. Identify users engaging with crypto content
2. Send personalized DM claiming "exclusive opportunity"
3. Create urgency ("limited spots", "ending soon")
4. Direct to phishing website

**Phishing Website Tactics:**
1. Clone legitimate exchange interface
2. Request "KYC verification" (data harvesting)
3. Display fake wallet address for deposits
4. No actual trading functionality
5. Funds immediately forwarded to launder

**Money Laundering:**
1. Receive victim deposits to Wallet A
2. Forward to Wallet B within minutes
3. Send through Tornado Cash mixer
4. Withdraw to exchanges (likely for cashout)

---

#### Victimology

**Target Demographics:**
- Age: 25-45 years old
- Interest: Cryptocurrency investment
- Experience Level: Novice to intermediate
- Geographic: Global (English-speaking)

**Victim Profile:**
- Follows legitimate crypto influencers
- Active on crypto Twitter/Telegram
- Looking for investment opportunities
- Trusts verified/popular accounts

**Exploitation Method:**
- Social engineering (impersonation)
- Authority bias (mimicking influencer)
- Scarcity tactics (limited spots)
- FOMO (fear of missing out)

---

### Attribution Assessment

**Confidence Level:** Low-Medium

**Indicators:**

**Geographic:**
- Timezone: UTC+3 (Eastern Europe likely)
- Language: Non-native English speaker
- VPN/Tor usage suggests operational security awareness

**Technical Sophistication:**
- Medium skill level
- Uses privacy tools (ProtonMail, Tor, Cloudflare)
- Understands cryptocurrency mixers
- Website cloning capability

**Potential Locations:**
- 🇷🇺 Russia (timezone match, crypto fraud prevalence)
- 🇺🇦 Ukraine (timezone match, tech skills)
- 🇷🇴 Romania (timezone match, cybercrime hub)
- 🇧🇬 Bulgaria (timezone match)

**Assessment:**
Cannot definitively attribute to specific individual or location without:
- Law enforcement access to ProtonMail records
- Tor network analysis (requires ISP/Tor cooperation)
- Exchange KYC data (requires subpoena)
- Mistake by subject (operational security slip)

---

### Threat Assessment

**Recidivism Risk:** 🔴 High

**Likelihood of Continued Activity:**
- Subject likely operates multiple personas simultaneously
- Low investment per scam (easy to rebrand)
- Successful monetization (~$150K in ~1 month)
- No apparent law enforcement action yet

**Indicators Subject Will Continue:**
- Professional-level operation (not opportunistic)
- Invested in infrastructure (domains, accounts)
- Successful track record (high victim conversion)
- Low detection risk (using anonymity tools)

---

### Investigation Gaps

**Unknown Information:**
- Real name/identity
- Physical location
- Other active personas
- Full extent of victim count
- Total financial proceeds (only 1 wallet analyzed)

**Investigative Limitations:**
- ProtonMail won't disclose user info without legal process
- Tor network prevents IP identification
- Cloudflare hides origin server
- Tornado Cash mixer breaks transaction trail
- No law enforcement authority for subpoenas

---

## Secondary Subjects

### Victim 1 (Consented to Include)

**Identifier:** V001
**Platform:** Twitter
**Loss Amount:** 2.5 ETH (~$4,500 USD)
**Contact Date:** December 20, 2024

**Incident Summary:**
- Received DM from @crypto_scammer_example
- Clicked link to phishing site
- Deposited 2.5 ETH expecting "presale tokens"
- Never received tokens, funds stolen

**Evidence Provided:**
- DM screenshots: `../03-Evidence/victim-reports/victim-001-dm.png`
- Transaction hash: 0xabc123...
- Wallet address: 0xdef456...

---

### Impersonated Influencer: @RealCryptoGuru

**Real Account:**
```
Handle: @RealCryptoGuru
Display Name: Michael Chen
Verification: ✅ Verified (Blue checkmark)
Followers: 247,000
Since: 2019
```

**Impact:**
- Reputation damage (followers confused)
- Loss of trust in community
- Time spent addressing fake accounts
- Potential legal liability concerns

**Cooperation:**
- Provided statement confirming impersonation
- Posted public warning about fake accounts
- Assisted in platform reporting

---

## Related Subjects (For Further Investigation)

**Potential Accomplices:**
- Unknown (subject appears to operate solo)

**Similar Active Scams:**
- @crypto_advisor_pro (Twitter) - Similar MO, different persona
- @nft_presale_official (Twitter) - Same phishing domain infrastructure

**Recommendation:** Cross-reference with other reported crypto scams for pattern matching.

---

## Evidence Summary

**Total Evidence Items Related to Subject:**
- Screenshots: 23
- WHOIS records: 4
- Blockchain data: 8 transactions + wallet analysis
- Social media archives: 3
- Victim statements: 15

**Evidence Location:**
- Primary: `../03-Evidence/`
- Backup: Encrypted external drive (per evidence handling SOP)

**Chain of Custody:**
- All evidence logged in [[02-Collection-Log]]
- SHA-256 hashes recorded for integrity
- Access restricted to authorized investigators

---

**Profile Last Updated:** 2025-01-15
**Next Review:** 2025-01-22
**Status:** 🟢 Active Subject

---

## Reference Example: Organization Profiling

### Related Entity - "CryptoVault Solutions LLC"

**Note:** This is an additional example showing how to profile an **organization entity** (not directly related to the Alex Morgan scam case above).

**Entity Type:** Organization (Offshore Company)
**Primary Use:** Demonstrates organization profiling methodology

For the complete organization dossier example, see:
- Full methodology: [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier SOP]]
- Organization structure includes: Corporate registry searches, beneficial ownership, regulatory status, financial indicators, blockchain wallets (if crypto-related), court records, media coverage

**Key Differences from Person Profiling:**
- Focus on corporate structure, not demographics
- Regulatory compliance vs. personal behavior
- Beneficial owners vs. personal associates
- Financial statements vs. income sources
- Business operations vs. lifestyle patterns

**Where to find example:**
For a fully-worked organization profile example with all sections completed, refer to the Entity Dossier SOP which contains comprehensive templates for both person and organization entities.
