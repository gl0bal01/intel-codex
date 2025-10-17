---
type: sop
title: OSINT Collection Log & Chain of Custody
description: "Evidence documentation guide: SHA-256 hashing, chain of custody, metadata preservation & forensically sound collection for legal admissibility."
tags: [sop, log, chain-of-custody, evidence, documentation]
template_version: 2025-10-05
---

# OSINT Collection Log & Chain of Custody

> **Purpose:** Maintain forensically sound evidence collection practices for OSINT investigations. Ensure integrity, admissibility, and reproducibility of digital evidence through proper documentation and verification.

---

## Overview

### Why Chain of Custody Matters

**Legal Admissibility:**
- Courts require proof that evidence hasn't been tampered with
- Chain of custody demonstrates evidence integrity from collection to presentation
- Gaps in documentation can lead to evidence being inadmissible

**Investigation Integrity:**
- Enables peer review and quality assurance
- Allows reproduction of findings by other analysts
- Protects against claims of fabrication or manipulation

**Regulatory Compliance:**
- Many jurisdictions require documented evidence handling (GDPR, CCPA, etc.)
- Financial investigations may require specific documentation (FinCEN, AML regulations)
- Internal policies often mandate evidence tracking

---

## 1. Collection Log Template (integrate with [[sop-entity-dossier|Entity Dossier]])

### Standard Collection Log Entry

| Field                   | Description                | Example                                          |
| ----------------------- | -------------------------- | ------------------------------------------------ |
| **Timestamp (UTC)**     | Exact date/time of capture | 2025-10-05 14:30:22 UTC                          |
| **Item Description**    | What was collected         | X profile screenshot (@username)                 |
| **Source/URL**          | Full URL or identifier     | https://x.com/username                           |
| **Collection Method**   | Tool/technique used        | SingleFile browser extension                     |
| **File Hash (SHA-256)** | Cryptographic hash         | a1b2c3d4e5f6...                                  |
| **File Path**           | Storage location           | /Evidence/CASE-001/20251005/twitter_profile.html |
| **Operator**            | Analyst name/ID            | Analyst Name (ID: A123)                          |
| **Notes**               | Additional context         | Account verified, 50k followers                  |

### Example Collection Log


```markdown
# Collection Log - CASE-2025-1005-001

| Timestamp (UTC) | Item | Source/URL | Method | SHA-256 | Operator | Notes |
|-----------------|------|------------|--------|---------|----------|-------|
| 2025-10-05 14:30:22 | X profile (HTML) | https://x.com/crypto_alex | SingleFile | a1b2c3d4... | Analyst A123 | Account active, verified |
| 2025-10-05 14:31:15 | X profile (screenshot) | https://x.com/crypto_alex | Firefox screenshot | b2c3d4e5... | Analyst A123 | Full page capture |
| 2025-10-05 14:35:40 | Instagram post | https://instagram.com/p/ABC123 | SingleFile + screenshot | c3d4e5f6... | Analyst A123 | Location tagged: SF |
| 2025-10-05 15:10:05 | WHOIS record | domain.com | whois CLI output | d4e5f6g7... | Analyst A123 | Privacy protected |
| 2025-10-05 15:25:30 | Website archive | https://example.com | Archive.org Wayback | e5f6g7h8... | Analyst A123 | Snapshot from 2024-01-15 |
```

---

## 2. Capture Procedures

### Standard Capture Workflow

**Step 1: Pre-Capture Documentation** (see [[sop-opsec-plan|OPSEC Planning SOP]])
```markdown
- [ ] Record investigation context (case ID, target entity, objective)
- [ ] Note current date/time (UTC)
- [ ] Document access method (browser, API, command-line tool)
- [ ] Log OPSEC measures (VPN, burner account, etc.)
```

**Step 2: Multi-Format Capture**

**Why multiple formats:**
- HTML preserves dynamic content and metadata
- PDF provides human-readable archival format
- Screenshot proves visual appearance at capture time
- WARC archives include HTTP headers and embedded resources

**Capture commands:**

```bash
# Web page capture - SingleFile (browser extension)
# 1. Install SingleFile extension (Firefox/Chrome)
# 2. Navigate to target URL
# 3. Click SingleFile icon → Save as HTML
# 4. Result: Complete page in single HTML file

# Screenshot (full page)
# Firefox: Right-click → Take Screenshot → Save Full Page
# Chrome: Ctrl+Shift+P → "Capture full size screenshot"
# Or use command-line:
firefox --screenshot=fullpage.png https://example.com

# Command-line archival (wget WARC)
wget --warc-file=archive \
     --warc-cdx \
     --page-requisites \
     --convert-links \
     --user-agent="Mozilla/5.0" \
     https://example.com

# Archive.org Wayback Machine submission
curl -X POST "https://web.archive.org/save/https://example.com"

# Twitter archival (Nitter + SingleFile)
# 1. Navigate to nitter.net/username (privacy-respecting Twitter frontend)
# 2. Use SingleFile to capture
# 3. Screenshot for visual proof

# API-based capture (Twitter API v2 example)
# Requires authentication and API key
curl -s "https://api.x.com/2/tweets/TWEET_ID?expansions=author_id&tweet.fields=created_at,text&user.fields=username,name" \
  -H "Authorization: Bearer $YOUR_ACCESS_TOKEN" \
  -o tweet_data.json

```

**Step 3: Hash Calculation** (see [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods SOP]])

```bash
# Linux/macOS
sha256sum captured_file.html > captured_file.sha256

# Windows (PowerShell)
Get-FileHash -Path "captured_file.html" -Algorithm SHA256 | Format-List

# Batch processing (all files in directory)
# Linux:
find /Evidence/CASE-001/20251005/ -type f -exec sha256sum {} \; > SHA256SUMS

# Windows:
Get-ChildItem -Path "C:\Evidence\CASE-001\20251005\" -File | Get-FileHash -Algorithm SHA256 | Export-Csv -Path "hashes.csv"
```

**Step 4: Metadata Extraction** (see [[sop-image-video-osint|Image/Video OSINT SOP]] for advanced analysis)

```bash
# Web page metadata
exiftool captured_page.html | tee metadata.txt

# Image metadata (if screenshot or photo)
exiftool screenshot.png

# PDF metadata
exiftool document.pdf

# Extract HTTP headers from WARC
zcat archive.warc.gz | grep -A 20 "WARC-Type: response"
```

**Step 5: Evidence Storage**

```bash
# Create case directory structure
mkdir -p /Evidence/CASE-2025-1005-001/{screenshots,html,archives,documents,metadata}

# Move captured files
mv twitter_profile.html /Evidence/CASE-2025-1005-001/html/20251005_twitter_profile.html
mv twitter_screenshot.png /Evidence/CASE-2025-1005-001/screenshots/20251005_twitter_screenshot.png

# Generate master hash file
cd /Evidence/CASE-2025-1005-001/
find . -type f -exec sha256sum {} \; > MANIFEST_SHA256SUMS.txt

# Create evidence package (password-protected)
7z a -pinfected -mhe=on CASE-2025-1005-001_evidence.7z /Evidence/CASE-2025-1005-001/
```

---

## 3. Collection Methods by Source Type

### Social Media Platforms

**Twitter/X:** (see [[../Platforms/sop-platform-twitter-x|Twitter/X Platform SOP]])
```bash
# Method 1: Nitter + SingleFile (no account required)
# Navigate to: https://nitter.net/username
# Use SingleFile to capture HTML
# Screenshot for visual proof

# Method 2: Twitter API (requires authentication)
# Get user profile
curl -X GET "https://api.x.com/2/users/by/username/crypto_alex" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_user_data.json

# Get user tweets
curl -X GET "https://api.x.com/2/users/USER_ID/tweets?max_results=100" \
     -H "Authorization: Bearer $TWITTER_BEARER_TOKEN" \
     > twitter_tweets.json

# Method 3: Twint (archived tweets, no API needed - may be deprecated)
twint -u username --json -o tweets.json
```

**Instagram:** (see [[../Platforms/sop-platform-instagram|Instagram Platform SOP]])
```bash
# Browser-based (SingleFile + Screenshot)
# 1. Navigate to instagram.com/username
# 2. Scroll to load all posts (if needed)
# 3. SingleFile to capture HTML
# 4. Screenshot each post individually

# Instaloader (command-line, no login required for public profiles)
instaloader --no-videos --no-video-thumbnails username
# Downloads: profile pic, posts, metadata
```

**LinkedIn:** (see [[../Platforms/sop-platform-linkedin|LinkedIn Platform SOP]])
```bash
# Manual capture (no API access for OSINT)
# 1. Navigate to linkedin.com/in/username
# 2. SingleFile + Screenshot (must be logged in to see full profile)
# 3. Export profile as PDF (LinkedIn feature: More → Save to PDF)

# IMPORTANT: LinkedIn ToS prohibits scraping - manual only
```

**Telegram:** (see [[../Platforms/sop-platform-telegram|Telegram Platform SOP]])
```bash
# Public channels/groups only
# Method 1: Web preview (no account)
# https://t.me/channelname (preview mode)
# SingleFile + Screenshot

# Method 2: Export chat (requires Telegram Desktop)
# Open channel → ⋮ Menu → Export Chat History → HTML format
# Includes: messages, media, metadata
```

### Websites & Infrastructure (see [[sop-web-dns-whois-osint|Web/DNS/WHOIS OSINT SOP]])

**Web Pages:**
```bash
# Full page archive (wget WARC)
wget --warc-file=example_com_20251005 \
     --warc-cdx \
     --page-requisites \
     --recursive \
     --level=1 \
     --convert-links \
     --adjust-extension \
     --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
     https://example.com

# Archive.org submission
curl -X POST "https://web.archive.org/save/https://example.com"

# Check existing archives
curl "https://archive.org/wayback/available?url=example.com" | jq
```

**WHOIS Records:**
```bash
# Current WHOIS
whois example.com > whois_example_com_20251005.txt

# Historical WHOIS (requires commercial service)
# DomainTools: https://whois.domaintools.com/example.com
# SecurityTrails: https://securitytrails.com/domain/example.com/history/whois

# Calculate hash
sha256sum whois_example_com_20251005.txt
```

**DNS Records:**
```bash
# Complete DNS enumeration
dig example.com ANY > dns_example_com_20251005.txt

# Specific record types
dig example.com A
dig example.com MX
dig example.com TXT
dig example.com NS

# Historical DNS (passive DNS)
# SecurityTrails, DomainTools (commercial)
```

**SSL Certificates:**
```bash
# Certificate transparency search
curl -s "https://crt.sh/?q=%25.example.com&output=json" | jq > certs_example_com_20251005.json

# Current certificate
echo | openssl s_client -connect example.com:443 -servername example.com 2>/dev/null | openssl x509 -text > cert_example_com_20251005.txt
```

### Blockchain & Cryptocurrency (see [[sop-financial-aml-osint|Financial/AML OSINT SOP]])

**Bitcoin Transactions:**
```bash
# Blockchain.info API
# https://www.blockchain.com/fr/explorer/api/blockchain_api
curl -s "https://blockchain.info/rawaddr/BITCOIN_ADDRESS" | jq > btc_address_20251005.json

# Calculate hash
sha256sum btc_address_20251005.json

# Screenshot blockchain explorer
# Navigate to: https://blockchain.info/address/BITCOIN_ADDRESS
# Screenshot with timestamp visible
```

**Ethereum Transactions:**
```bash
# Etherscan API
curl -s "https://api.etherscan.io/api?module=account&action=txlist&address=ETH_ADDRESS&startblock=0&endblock=99999999&sort=asc&apikey=YourApiKey" | jq > eth_address_20251005.json

# Screenshot Etherscan page
# https://etherscan.io/address/ETH_ADDRESS
```

### Data Breach Databases

**Have I Been Pwned:**
```bash
# Check email for breaches (requires API key)
curl -H "hibp-api-key: YOUR_API_KEY" \
     "https://haveibeenpwned.com/api/v3/breachedaccount/email@example.com" \
     | jq > hibp_results_20251005.json

# Calculate hash
sha256sum hibp_results_20251005.json
```

### Email & Documents

**Email Messages:**
```bash
# Save as .eml format (preserves headers)
# In email client: File → Save As → .eml format

# Extract headers
grep -E "^(From|To|Subject|Date|Received|Return-Path|X-|Message-ID):" email.eml > email_headers.txt

# Calculate hash of original .eml
sha256sum email.eml
```

**Documents (PDF, Office files):**
```bash
# Calculate hash immediately
sha256sum document.pdf

# Extract metadata
exiftool document.pdf > document_metadata.txt

# Create read-only copy
cp document.pdf document_EVIDENCE.pdf
chmod 444 document_EVIDENCE.pdf
```

---

## 4. Evidence Packaging & Storage

### Directory Structure

```
/Evidence/
├── CASE-2025-1005-001/
│   ├── 20251005/                    (date-based subdirectory)
│   │   ├── screenshots/
│   │   │   ├── 143022_twitter_profile.png
│   │   │   ├── 143115_twitter_profile_fullpage.png
│   │   │   └── 153540_instagram_post.png
│   │   ├── html/
│   │   │   ├── 143022_twitter_profile.html
│   │   │   └── 153540_instagram_post.html
│   │   ├── archives/
│   │   │   ├── example_com_20251005.warc.gz
│   │   │   └── wayback_20251005.html
│   │   ├── api_exports/
│   │   │   ├── twitter_tweets.json
│   │   │   └── blockchain_transactions.json
│   │   ├── documents/
│   │   │   ├── whois_example_com.txt
│   │   │   └── dns_records.txt
│   │   ├── metadata/
│   │   │   └── exiftool_outputs.txt
│   │   └── SHA256SUMS.txt            (master hash file)
│   ├── 20251006/
│   ├── collection_log.md             (this log)
│   ├── MANIFEST_SHA256SUMS.txt       (all files across all dates)
│   └── chain_of_custody.md           (formal custody log)
```

### Filename Conventions

```
Format: YYYYMMDD_HHMMSS_description.extension

Examples:
- 20251005_143022_twitter_profile.png
- 20251005_151005_whois_example_com.txt
- 20251005_152530_wayback_archive.html

Why:
- Sortable chronologically
- Timestamp embedded (prevents confusion)
- Description readable
- No spaces (filesystem compatibility)
```

### Evidence Integrity Verification

```bash
# Create master hash file (initial)
cd /Evidence/CASE-2025-1005-001/
find . -type f -not -name "SHA256SUMS*" -not -name "MANIFEST*" -exec sha256sum {} \; > MANIFEST_SHA256SUMS.txt

# Verify integrity later (weekly/monthly)
sha256sum -c MANIFEST_SHA256SUMS.txt > verification_$(date +%Y%m%d).log

# Result:
# ./20251005/screenshots/143022_twitter_profile.png: OK
# ./20251005/screenshots/143115_twitter_profile_fullpage.png: OK
# ./20251005/html/143022_twitter_profile.html: FAILED
# ⚠️ FAILED indicates file modification - investigate immediately

# Sign hash manifest (optional - advanced)
gpg --clearsign MANIFEST_SHA256SUMS.txt
# Creates MANIFEST_SHA256SUMS.txt.asc (cryptographically signed)
```

### Evidence Transfer Protocol

```bash
# Create password-protected archive
7z a -pinfected -mhe=on CASE-2025-1005-001_evidence_20251005.7z /Evidence/CASE-2025-1005-001/20251005/

# Calculate archive hash
sha256sum CASE-2025-1005-001_evidence_20251005.7z > CASE-2025-1005-001_evidence_20251005.sha256

# Transfer via secure channel
# - Physical media (USB with encryption)
# - SFTP/SCP (encrypted transfer)
# - Encrypted email (PGP/GPG)

# Receiver verification
sha256sum -c CASE-2025-1005-001_evidence_20251005.sha256
# Extract with password: infected
7z x CASE-2025-1005-001_evidence_20251005.7z
```

---

## 5. Chain of Custody Documentation

### Formal Chain of Custody Form

```markdown
# Chain of Custody Log - CASE-2025-1005-001

## Evidence Item: Twitter Profile (@crypto_alex)

| Field | Value |
|-------|-------|
| **Case ID** | CASE-2025-1005-001 |
| **Evidence ID** | EVID-20251005-001 |
| **Description** | Twitter profile HTML capture and screenshot |
| **Source** | https://twitter.com/crypto_alex |
| **Collection Date/Time** | 2025-10-05 14:30:22 UTC |
| **Collected By** | Analyst Name (ID: A123) |
| **Storage Location** | /Evidence/CASE-2025-1005-001/20251005/ |
| **File Hash (SHA-256)** | a1b2c3d4e5f6789012345678901234567890... |

## Custody Transfer Log

| Date/Time (UTC) | From | To | Purpose | Signature |
|-----------------|------|-----|---------|-----------|
| 2025-10-05 14:30 | Analyst A123 | Evidence locker | Initial storage | AA |
| 2025-10-06 09:00 | Evidence locker | Analyst B456 | Peer review | BB |
| 2025-10-06 15:00 | Analyst B456 | Evidence locker | Review complete | BB |
| 2025-10-08 10:00 | Evidence locker | Legal team | Case filing | LT |

## Integrity Verification Log

| Date/Time (UTC) | Verified By | Hash Match | Notes |
|-----------------|-------------|------------|-------|
| 2025-10-05 14:30 | Analyst A123 | ✓ MATCH | Initial hash calculation |
| 2025-10-06 09:00 | Analyst B456 | ✓ MATCH | Pre-review verification |
| 2025-10-08 10:00 | Legal team | ✓ MATCH | Pre-filing verification |
| 2025-10-15 14:00 | QA Analyst | ✓ MATCH | Weekly integrity check |

## Access Log

| Date/Time (UTC) | Accessor | Purpose | Duration |
|-----------------|----------|---------|----------|
| 2025-10-05 14:30 | Analyst A123 | Evidence collection | 30 min |
| 2025-10-06 09:00 | Analyst B456 | Peer review | 2 hours |
| 2025-10-08 10:00 | Legal team | Case preparation | 1 hour |
```

---

## 6. Reproducibility & Documentation

### Reproducibility Checklist

To ensure another analyst can reproduce your findings:

**Required documentation:**
- [ ] Exact URL or query string
- [ ] Timestamp (UTC) of capture
- [ ] Browser/tool version (e.g., Firefox 119.0, wget 1.21)
- [ ] User-Agent string used
- [ ] Geographic location/VPN endpoint (if relevant)
- [ ] Login status (logged in vs. public view)
- [ ] Filters applied (date range, language, etc.)
- [ ] Search operators used (Google dorks, Boolean queries)
- [ ] API parameters (if applicable)
- [ ] Screen resolution (for screenshots - affects layout)

**Example reproducibility documentation:**

```markdown
## Collection Details - Twitter Profile Capture

**Target:** @crypto_alex
**URL:** https://twitter.com/crypto_alex
**Timestamp:** 2025-10-05 14:30:22 UTC
**Method:** Nitter frontend (nitter.net/crypto_alex)
**Tool:** Firefox 119.0 + SingleFile extension v1.22.59
**User-Agent:** Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/119.0
**Login Status:** Not logged in (public view via Nitter)
**VPN:** Active (exit node: Switzerland, Mullvad)
**Screen Resolution:** 1920x1080
**Page State:** Scrolled to load 20 tweets
**JavaScript:** Enabled (default browser settings)
**Cookies:** Disabled
**Notes:** Account verified (blue checkmark), 45k followers at time of capture

## Reproduction Steps:
1. Configure Firefox with user-agent string above
2. Enable SingleFile extension
3. Navigate to https://nitter.net/crypto_alex
4. Wait 5 seconds for page load
5. Scroll down to load first 20 tweets
6. Click SingleFile icon → Save complete page
7. Take full-page screenshot (Right-click → Take Screenshot → Save Full Page)
8. Calculate SHA-256 hash of both files
```

---

## 7. Quality Assurance & Verification

### Pre-Archive Checklist

Before storing evidence, verify:

**Visual Quality:**
- [ ] Screenshot is readable (text not blurry)
- [ ] Full page captured (no truncation)
- [ ] Timestamp visible in screenshot (taskbar clock or overlay)
- [ ] URL visible in address bar (for screenshots)

**Technical Quality:**
- [ ] HTML file opens correctly in browser
- [ ] External resources loaded (images, CSS - if using SingleFile)
- [ ] WARC file contains complete HTTP transaction
- [ ] JSON/API response is valid (can be parsed)
- [ ] File size reasonable (not corrupted/truncated)

**Metadata Complete:**
- [ ] File hash calculated and logged
- [ ] Timestamp documented (UTC)
- [ ] Source URL/identifier recorded
- [ ] Collection method noted
- [ ] Analyst name logged

**Chain of Custody:**
- [ ] Evidence ID assigned
- [ ] Storage location documented
- [ ] Access controls applied (read-only permissions)
- [ ] Hash added to master manifest

### Verification Script (Bash)

```bash
#!/bin/bash
# evidence_verify.sh - Verify evidence integrity

EVIDENCE_DIR="/Evidence/CASE-2025-1005-001"
MANIFEST="$EVIDENCE_DIR/MANIFEST_SHA256SUMS.txt"
LOG_FILE="verification_$(date +%Y%m%d_%H%M%S).log"

echo "Evidence Integrity Verification" > "$LOG_FILE"
echo "Date: $(date -u)" >> "$LOG_FILE"
echo "======================================" >> "$LOG_FILE"

cd "$EVIDENCE_DIR"
sha256sum -c "$MANIFEST" >> "$LOG_FILE" 2>&1

# Count results
TOTAL=$(grep -c ": " "$LOG_FILE")
OK=$(grep -c ": OK" "$LOG_FILE")
FAILED=$(grep -c ": FAILED" "$LOG_FILE")

echo "" >> "$LOG_FILE"
echo "Summary:" >> "$LOG_FILE"
echo "Total files: $TOTAL" >> "$LOG_FILE"
echo "Verified: $OK" >> "$LOG_FILE"
echo "Failed: $FAILED" >> "$LOG_FILE"

if [ "$FAILED" -gt 0 ]; then
    echo "⚠️ WARNING: $FAILED file(s) failed integrity check!" | tee -a "$LOG_FILE"
    echo "Review $LOG_FILE for details"
    exit 1
else
    echo "✓ All files verified successfully" | tee -a "$LOG_FILE"
    exit 0
fi
```

---

## 8. Common Pitfalls & Best Practices

### ❌ Common Mistakes

**Mistake 1: Forgetting to calculate hashes immediately**
```bash
# ❌ Bad:
wget https://example.com/file.pdf
# (file moved to evidence folder without hash)

# ✅ Good:
wget https://example.com/file.pdf
sha256sum file.pdf > file.pdf.sha256
mv file.pdf /Evidence/CASE-001/
mv file.pdf.sha256 /Evidence/CASE-001/
```

**Mistake 2: Modifying evidence files**
```bash
# ❌ Bad:
# Opening HTML file in editor and saving (changes file hash)

# ✅ Good:
# Always work on copies, keep original read-only
cp original.html working_copy.html
chmod 444 original.html  # Read-only
```

**Mistake 3: Incomplete screenshots**
```bash
# ❌ Bad: Screenshot without URL/timestamp visible
# ✅ Good: Include browser chrome (address bar, timestamp in screenshot)
```

**Mistake 4: Using wrong timestamp**
```bash
# ❌ Bad: Using local time (ambiguous across timezones)
# Timestamp: 2025-10-05 14:30:22

# ✅ Good: Always use UTC
# Timestamp: 2025-10-05 14:30:22 UTC
```

**Mistake 5: No reproducibility documentation**
```bash
# ❌ Bad: "Searched Google for username" (vague)
# ✅ Good: "Google search: site:twitter.com \"@username\" (exact query)"
```

### ✅ Best Practices

**1. Triple capture (HTML + Screenshot + Archive):**
- HTML: Preserves interactive content and metadata
- Screenshot: Proves visual appearance
- External archive: Third-party verification (Archive.org)

**2. Hash everything immediately:**
```bash
# Add to bash profile for quick hashing
alias sha='sha256sum'

# Quick hash and copy to clipboard (Linux)
sha256sum file.txt | tee file.txt.sha256 | xclip -selection clipboard
```

**3. Use consistent naming:**
```bash
# Always: YYYYMMDD_HHMMSS_description.extension
# Never: "screenshot.png" or "file (1).html"
```

**4. Document OPSEC measures:**
```markdown
## OPSEC Log
- VPN: Mullvad (Switzerland exit node)
- Browser: Firefox + uBlock Origin + NoScript
- No login accounts used
- Burner email: temp123@protonmail.com (created 2025-10-01)
```

**5. Weekly integrity checks:**
```bash
# Add to cron (Linux) or Task Scheduler (Windows)
# Run every Monday at 9am
0 9 * * 1 /path/to/evidence_verify.sh
```

---

## 9. Tools Reference

| Tool | Purpose | Platform | Command/Link |
|------|---------|----------|--------------|
| **SingleFile** | Save complete web page as single HTML | Browser extension | [Chrome/Firefox](https://github.com/gildas-lormeau/SingleFile) |
| **wget** | Archive websites to WARC format | CLI (Linux/Mac/Win) | `wget --warc-file=archive URL` |
| **ArchiveBox** | Self-hosted web archiving | CLI/Web | [archivebox.io](https://archivebox.io) |
| **Twint** | Twitter scraping (no API) | CLI (Python) | [github.com/twintproject/twint](https://github.com/twintproject/twint) |
| **Instaloader** | Instagram archival | CLI (Python) | `instaloader username` |
| **exiftool** | Metadata extraction | CLI | `exiftool file.jpg` |
| **sha256sum** | Hash calculation | CLI (Linux/Mac) | `sha256sum file.txt` |
| **Get-FileHash** | Hash calculation | PowerShell (Windows) | `Get-FileHash -Path file.txt -Algorithm SHA256` |
| **7-Zip** | Password-protected archiving | GUI/CLI | `7z a -pinfected -mhe=on archive.7z files/` |

---

## 10. Legal & Compliance (see [[sop-legal-ethics|Legal & Ethics SOP]])

### Admissibility Requirements

**Daubert Standard (US Federal Courts):**
- [ ] Evidence collection method is scientifically valid
- [ ] Method has been peer-reviewed and published
- [ ] Known error rate is acceptable
- [ ] Method is generally accepted in the field

**Best Evidence Rule:**
- [ ] Original digital file preserved (not edited copy)
- [ ] Hash proves file hasn't been altered
- [ ] Chain of custody demonstrates integrity

**Authentication (Federal Rules of Evidence 901):**
- [ ] Witness can testify to evidence origin
- [ ] Unique characteristics prove authenticity (hash)
- [ ] Process/system produces accurate result (tooling)

### GDPR Compliance (if applicable)

- [ ] Legal basis for collection documented
- [ ] Data minimization applied (collect only what's needed)
- [ ] Retention period defined (delete when no longer needed)
- [ ] Access controls implemented (who can view evidence)
- [ ] Subject access requests prepared (if individual requests their data)

---

**Quick Reference:**
- Hash calculation: `sha256sum file.txt` (Linux) or `Get-FileHash file.txt` (Windows)
- Evidence storage: `/Evidence/CASE-ID/YYYYMMDD/`
- Verification: `sha256sum -c SHA256SUMS.txt`
- Archive: `7z a -pinfected -mhe=on archive.7z files/`

**Related SOPs:**
- [[sop-legal-ethics|Legal & Ethics]]
- [[sop-opsec-plan|OPSEC Planning]]
- [[sop-reporting-packaging-disclosure|Reporting & Disclosure]]
- [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]]
- [[../../Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]]
- [[../../Security/Pentesting/sop-forensics-investigation|Forensics Investigation]]
- [[sop-web-dns-whois-osint|Web, DNS & WHOIS OSINT]]
- [[sop-financial-aml-osint|Financial & AML OSINT]]
- [[sop-image-video-osint|Image & Video OSINT]]
- [[sop-entity-dossier|Entity Dossier Creation]]
- [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]
- [[../Platforms/sop-platform-twitter-x|Platform: Twitter/X]]
- [[../Platforms/sop-platform-instagram|Platform: Instagram]]
- [[../Platforms/sop-platform-linkedin|Platform: LinkedIn]]
- [[../Platforms/sop-platform-telegram|Platform: Telegram]]
- [[../Platforms/sop-platform-reddit|Platform: Reddit]]
- [[../Platforms/sop-platform-tiktok|Platform: TikTok]]
- [[../Platforms/sop-platform-bluesky|Platform: Bluesky]]
