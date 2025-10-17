---
type: sop
title: Reporting, Packaging & Disclosure
description: "Professional OSINT reporting: executive summaries, evidence packaging, chain of custody, law enforcement disclosure & responsible reporting protocols."
created: 2025-10-10
tags: [sop, reporting, evidence, disclosure, documentation]
---

# Reporting, Packaging & Disclosure

> **Purpose:** Comprehensive guidance for documenting OSINT investigations, packaging evidence with proper chain of custody, and securely disclosing findings to authorized recipients.

---

## Table of Contents

1. [Overview](#overview)
2. [Report Structure](#report-structure)
3. [Writing Guidelines](#writing-guidelines)
4. [Evidence Packaging](#evidence-packaging)
5. [Metadata Scrubbing](#metadata-scrubbing)
6. [Redaction Techniques](#redaction-techniques)
7. [Disclosure Protocols](#disclosure-protocols)
8. [Version Control](#version-control)
9. [Quality Assurance Checklist](#quality-assurance-checklist)
10. [Templates & Examples](#templates--examples)
11. [Tools & Resources](#tools--resources)

---

## Overview

### Why Proper Reporting Matters

**Investigation reports serve multiple purposes:**
- **Legal evidence** - May be submitted in court proceedings or regulatory actions
- **Decision support** - Inform organizational decisions and policy
- **Knowledge preservation** - Document methods and findings for future reference
- **Accountability** - Demonstrate proper procedures and ethical compliance
- **Reproducibility** - Enable others to verify findings independently

**Consequences of poor reporting:**
- Evidence inadmissible in legal proceedings
- Investigator identity exposed through metadata or attribution
- Findings misinterpreted due to unclear language
- Chain of custody broken, evidence integrity questioned
- Legal liability from improper disclosure or redaction failures

### Report Types

**1. Intelligence Report**
- **Audience:** Internal security teams, management
- **Focus:** Threat assessment, risk analysis, recommendations
- **Format:** Structured intelligence format with confidence levels
- **Length:** 5-15 pages + annexes

**2. Legal/Forensic Report**
- **Audience:** Legal counsel, law enforcement, courts
- **Focus:** Facts, evidence, chain of custody, methodology
- **Format:** Formal, objective, detailed methodology section
- **Length:** 10-50+ pages with extensive exhibits

**3. Executive Briefing**
- **Audience:** C-suite, board members, non-technical stakeholders
- **Focus:** Key findings, business impact, recommendations
- **Format:** Visual (slides), executive summary only
- **Length:** 5-10 slides or 2-3 page summary

**4. Technical Report**
- **Audience:** Security researchers, technical teams
- **Focus:** Technical details, IOCs, TTPs, reproduction steps
- **Format:** Technical documentation with code/commands
- **Length:** Variable, includes technical annexes

---

## Report Structure

### 1. Executive Summary

**Purpose:** Provide decision-makers with key information in 1-2 pages without technical details.

**Components:**
- **Investigation objectives** - What question were you answering?
- **Key findings** - Top 3-5 discoveries (bullet points)
- **Confidence assessment** - Overall confidence level and key uncertainties
- **Recommendations** - Actionable next steps (3-5 items)
- **Timeline** - Investigation dates and critical event dates

**Example:**

```markdown
## Executive Summary

**Investigation Objective:**
Determine the identity and organizational affiliations of threat actor "DarkPhoenix"
targeting our infrastructure between September-October 2025.

**Key Findings:**
- HIGH CONFIDENCE: DarkPhoenix is likely 32-year-old software developer based in Bucharest, Romania
- MEDIUM CONFIDENCE: Individual operates as independent contractor, not part of organized group
- HIGH CONFIDENCE: Previous targeting of 15+ organizations in financial services sector
- LOW CONFIDENCE: Possible connection to 2023 XYZ Bank breach (weak correlation)

**Recommendations:**
1. Coordinate with law enforcement (Romanian Cybercrime Division) for potential prosecution
2. Implement blocking of infrastructure tied to threat actor (15 domains, 8 IP addresses)
3. Notify peer organizations in financial sector of active threat
4. Review and strengthen perimeter defenses against social engineering tactics

**Timeline:** Investigation conducted October 1-10, 2025. Target activity observed September 15 - October 8, 2025.
```

**Writing Tips:**
- Lead with the most important finding
- Use active voice ("We identified..." not "It was identified that...")
- Avoid jargon - write for non-technical audience
- Include confidence levels (see [Confidence & Caveats](#confidence--caveats))
- Keep under 2 pages - details go in Findings section

---

### 2. Methodology

**Purpose:** Document investigation process for reproducibility, legal defensibility, and transparency.

**Components:**

**Investigation Scope:**
```markdown
**Scope:**
- **In Scope:** Public social media profiles, WHOIS records, leaked database entries,
  archived websites, blockchain transactions
- **Out of Scope:** Private communications, paid data brokers, active network reconnaissance
- **Timeframe:** Data collected from 2020-01-01 to 2025-10-10
- **Geographic Focus:** Romania, United States, United Kingdom
```

**Data Sources:**
```markdown
**Primary Sources:**
- Twitter/X: Public tweets, profile information, follower/following relationships
- LinkedIn: Professional profile (public view), employment history
- GitHub: Public repositories, commit history, code contributions
- Blockchain explorers: Bitcoin transactions (12 addresses identified)

**Secondary Sources:**
- Archive.org: Historical website snapshots (2018-2024)
- Have I Been Pwned: Email presence in data breaches
- WHOIS databases: Domain registration records (15 domains)

**Tools Used:**
- Maltego: Link analysis and visualization
- theHarvester: Email and subdomain enumeration
- Sherlock: Username enumeration across platforms
- Bitcoin explorer (blockchain.info): Transaction tracing
```

**OPSEC Measures:**
```markdown
**Operational Security:**
- All collection performed via Mullvad VPN (Swedish exit nodes)
- Isolated investigation VM (Ubuntu 22.04, snapshot-based)
- Research personas used for platform requiring authentication (see Persona Log)
- No direct engagement with investigation targets
- Evidence stored on encrypted volume (AES-256)

**Compliance:**
- Investigation authorized by [Legal Team] on 2025-10-01
- SOPs followed: [[sop-opsec-plan|OPSEC Planning]], [[sop-legal-ethics|Legal & Ethics]], [[sop-collection-log|Collection Log]]
- No TOS violations or unauthorized access
- No collection of sensitive personal data beyond public information
```

**Limitations & Bias:**
```markdown
**Limitations:**
- Cannot confirm identity through government-issued ID or biometric data
- Social media profile information is self-reported and unverified
- Language barrier: Romanian-language content translated via Google Translate (accuracy variable)
- VPN/Tor usage by target may have obscured additional infrastructure

**Potential Bias:**
- Investigator fluency in English may have favored English-language sources
- Focus on technical platforms (GitHub, Twitter) may underrepresent non-technical activities
- Confirmation bias: Early identification of Romanian connection may have influenced source selection
```

**Writing Tips:**
- Be transparent about limitations - builds credibility
- Document tools with version numbers (e.g., Maltego 4.6.0)
- Explain why certain methods were NOT used
- Note any deviations from standard SOPs
- Include enough detail for another investigator to reproduce your work

---

### 3. Findings

**Purpose:** Present facts and analysis in a clear, structured, evidence-backed format.

**Structure:**

**Facts First, Analysis Second:**
```markdown
### Finding 1: Target Identity - "DarkPhoenix" is likely John Doe (Romanian national)

**Evidence:**
1. **Username correlation** (HIGH CONFIDENCE)
   - Twitter handle @DarkPhoenix1993 matches GitHub username DarkPhoenix1993
   - Both accounts created within 2 weeks (2013-05-12 and 2013-05-24)
   - Consistent posting timezone (UTC+2, Romanian time)

2. **Profile information** (MEDIUM CONFIDENCE)
   - LinkedIn profile "John Doe" lists same employer as GitHub sponsor company (TechCorp SRL, Bucharest)
   - Profile photo facial features match across Twitter, LinkedIn, GitHub (see Exhibit A: Photo Comparison)
   - Romanian-language posts on Twitter (15% of total posts) using local idioms

3. **Technical indicators** (MEDIUM CONFIDENCE)
   - GitHub commits show Romanian IP addresses (see Exhibit B: Git Metadata)
   - Code comments in Romanian language (5 instances, 2018-2020)
   - Timezone in commits: UTC+2 (Bucharest)

**Analysis:**
The convergence of username, timezone, employer, language, and facial features provides
strong evidence that @DarkPhoenix1993 is John Doe, 32, software developer based in Bucharest.

**Alternative Hypotheses:**
- Stolen identity: Unlikely due to consistent activity patterns over 10+ years
- Account compromise: No indicators of compromise (no sudden language/behavior changes)
- Shared account: Unlikely due to single consistent writing style and posting patterns

**Confidence: HIGH** (80-95% certainty) - Multiple independent indicators converge on same identity
```

**Inline Exhibits:**
- Reference exhibits inline (e.g., "see Exhibit A")
- Include thumbnails or excerpts directly in findings
- Place full-resolution exhibits in annexes

**Confidence Levels** (see [Confidence & Caveats](#confidence--caveats)):
- **HIGH:** 80-95% confidence - multiple independent sources confirm
- **MEDIUM:** 50-79% confidence - some corroboration but gaps remain
- **LOW:** 20-49% confidence - single source or weak correlation
- **SPECULATIVE:** <20% confidence - hypothesis only, minimal evidence

**Writing Tips:**
- Lead with evidence, then analysis
- Cite exhibit numbers for all claims
- Consider alternative explanations
- Use structured confidence language
- Separate facts (observable data) from inference (your conclusions)

---

### 4. Timeline

**Purpose:** Visualize key events chronologically with sources for each entry.

**Format:**

```markdown
## Timeline of Events

| Date | Event | Source | Confidence |
|------|-------|--------|-----------|
| 2013-05-12 | DarkPhoenix1993 Twitter account created | Twitter profile | HIGH |
| 2018-03-15 | First GitHub commit to malware repository | GitHub commit history | HIGH |
| 2020-06-20 | Target changes employer (LinkedIn: TechCorp SRL) | LinkedIn profile | MEDIUM |
| 2023-08-10 | Possible involvement in XYZ Bank breach | Timing correlation, TTPs | LOW |
| 2025-09-15 | First reconnaissance activity against our infrastructure | IDS logs | HIGH |
| 2025-09-22 | Phishing campaign launched (15 employees targeted) | Email logs, reported phishing | HIGH |
| 2025-10-08 | Last observed activity (credential stuffing attempts) | WAF logs | HIGH |
| 2025-10-09 | Investigation initiated | Case file | HIGH |
```

**Visual Timeline (Optional):**
- Use timeline visualization tools (TimelineJS, Tiki-Toki, or custom)
- Include in executive briefing deck for visual impact
- Color-code by event type (reconnaissance, exploitation, etc.)

---

### 5. Dossiers & Annexes

**Entity Dossiers:**
- Use standardized format: [[sop-entity-dossier|Entity Dossier Template]]
- One dossier per person, organization, or infrastructure entity
- Include summary, attributes, relationships, and evidence references

**Exhibits:**
```markdown
## Exhibit Index

**Exhibit A: Photo Comparison**
- File: exhibit_a_photo_comparison.png
- SHA-256: a3f2b8c9d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1
- Description: Side-by-side comparison of Twitter, LinkedIn, GitHub profile photos
- Source: Public profile images captured 2025-10-05

**Exhibit B: Git Metadata**
- File: exhibit_b_git_metadata.json
- SHA-256: b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1a2b3c4d5e6f7f8a9b0c1d2e3f4a5
- Description: Git commit metadata showing Romanian IP addresses and UTC+2 timezone
- Source: GitHub repository commit history, collected 2025-10-06

**Exhibit C: Network Infrastructure Map**
- File: exhibit_c_infrastructure_map.pdf
- SHA-256: c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1a2b3c4d5e6f7f8a9b0c1d2e3f4a5b6
- Description: Maltego graph showing relationships between domains, IPs, and personas
- Source: Maltego analysis, created 2025-10-07
```

**Technical Annexes:**
- **Annex A: Indicators of Compromise (IOCs)** - IPs, domains, hashes, email addresses
- **Annex B: Collection Log** - Full audit trail from [[sop-collection-log|Collection Log Template]]
- **Annex C: Persona Documentation** - Research personas used, activity logs (see [[sop-opsec-plan#identity-management|OPSEC - Identity Management]])
- **Annex D: Tool Outputs** - Raw tool outputs (theHarvester, Sherlock, etc.)

---

## Writing Guidelines

### Confidence & Caveats

**Structured Confidence Language (Inspired by Intelligence Community Standards):**

| Level | Range | Description | Usage |
|-------|-------|-------------|-------|
| **HIGH** | 80-95% | Multiple independent sources confirm; high-quality evidence | "We assess with high confidence that..." |
| **MEDIUM** | 50-79% | Some corroboration; gaps remain; relies on credible sources | "We assess with medium confidence that..." |
| **LOW** | 20-49% | Single source or weak correlation; significant uncertainties | "We assess with low confidence that..." |
| **SPECULATIVE** | <20% | Hypothesis only; minimal evidence; included for completeness | "It is possible that..." or "One hypothesis is..." |

**Expressing Uncertainty:**

```markdown
**What we know:**
- Target uses username "DarkPhoenix1993" across 5 platforms (HIGH CONFIDENCE)
- Target resides in Bucharest based on timezone, language, IP data (HIGH CONFIDENCE)

**What we don't know:**
- Target's legal name (MEDIUM CONFIDENCE on "John Doe" based on LinkedIn/photo match)
- Whether target works alone or with others (LOW CONFIDENCE)
- Target's motivation (financial gain vs. ideology) (SPECULATIVE)

**What would change our assessment:**
- Government-issued ID or biometric confirmation would increase identity confidence to VERY HIGH
- Discovery of encrypted communications would clarify organizational affiliation
- Financial records showing payments would establish motivation
```

**Avoid Absolute Language:**
- ❌ "DarkPhoenix is definitely John Doe"
- ✅ "We assess with high confidence that DarkPhoenix is John Doe"

- ❌ "Target will attack again in the next 30 days"
- ✅ "Based on historical patterns, target is likely to resume activity within 30 days (MEDIUM CONFIDENCE)"

### Objective Tone

**Be Factual, Not Sensational:**
- ❌ "The attacker is a dangerous cybercriminal mastermind"
- ✅ "The individual has targeted 15+ organizations over 5 years"

**Avoid Judgment:**
- ❌ "Target foolishly exposed their identity by reusing usernames"
- ✅ "Target's reuse of usernames across platforms enabled correlation"

**Stick to Observable Facts:**
- ❌ "Target hates financial institutions"
- ✅ "Target has exclusively targeted financial sector organizations (15/15 known victims)"

### Attribution Protection

**Remove Investigator Identifiers:**
- Use "the investigation team" or "we" instead of personal names
- Remove organization names unless legally required
- Scrub metadata from all files (see [Metadata Scrubbing](#metadata-scrubbing) and [[sop-opsec-plan#golden-rules|OPSEC Golden Rules]])

**Sanitize Screenshots:**
- Remove taskbar, browser tabs, file paths
- Remove timestamps showing investigator timezone
- Redact investigator usernames or email addresses
- Use dedicated screenshot tools (Greenshot, ShareX with redaction)

---

## Evidence Packaging

### File Organization

**Evidence Bundle Structure:**

```
investigation_darkphoenix_2025-10-10/
├── 00_README.md                          # Investigation summary, file manifest, hashes
├── 01_report/
│   ├── report_final.pdf                  # Main report (redacted, scrubbed)
│   ├── report_final.pdf.sha256           # SHA-256 hash
│   └── briefing_deck.pptx                # Executive briefing (optional)
├── 02_exhibits/
│   ├── exhibit_a_photo_comparison.png
│   ├── exhibit_b_git_metadata.json
│   ├── exhibit_c_infrastructure_map.pdf
│   └── exhibit_index.csv                 # Exhibit list with hashes
├── 03_raw_evidence/
│   ├── twitter/
│   │   ├── profile_screenshot_2025-10-05.png
│   │   ├── tweets_export.json
│   │   └── followers_list.csv
│   ├── github/
│   │   ├── commit_history.json
│   │   └── repository_metadata.xml
│   └── blockchain/
│       └── bitcoin_transactions.csv
├── 04_collection_log/
│   └── collection_log_2025-10-01_to_2025-10-10.csv
├── 05_technical_data/
│   ├── maltego_graph.mtgx
│   ├── shodan_results.json
│   └── whois_records.txt
└── 06_chain_of_custody/
    └── chain_of_custody_log.csv
```

### README.md Template

```markdown
# OSINT Investigation: DarkPhoenix Identity Assessment

**Case ID:** INV-2025-1010-001
**Investigation Period:** 2025-10-01 to 2025-10-10
**Investigator:** [REDACTED]
**Organization:** [REDACTED]
**Classification:** CONFIDENTIAL - INTERNAL USE ONLY

## Investigation Summary

This evidence bundle contains all materials related to the identification of threat
actor "DarkPhoenix" who targeted [ORGANIZATION] infrastructure in September-October 2025.

**Key Finding:** HIGH CONFIDENCE identification of threat actor as John Doe, 32,
Bucharest, Romania.

## File Manifest

Total files: 47
Total size: 1.2 GB (1,234,567,890 bytes)
Bundle created: 2025-10-10 18:30:00 UTC
Bundle hash (SHA-256): f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5

### File Hashes (SHA-256)

| File | SHA-256 Hash |
|------|--------------|
| 01_report/report_final.pdf | a3f2b8c9d4e5f6a7... |
| 02_exhibits/exhibit_a_photo_comparison.png | b4c5d6e7f8a9b0c1... |
| ... | ... |

*Full hash list: see file_hashes.txt*

## Reproduction Instructions

To verify findings:
1. Review collection log (04_collection_log/) for source URLs and timestamps
2. Verify file integrity using hashes in file_hashes.txt
3. Re-collect public sources using URLs in collection log
4. Compare original evidence with re-collected data

## Tools Required

- Maltego 4.6.0 (for 05_technical_data/maltego_graph.mtgx)
- Any PDF reader (for report)
- Any image viewer (for exhibits)
- CSV/JSON viewer (for structured data)

## Contact

For questions regarding this investigation, contact [REDACTED] at [REDACTED].

## Legal Notice

This evidence bundle contains sensitive information collected under authorization
[AUTH-2025-001] dated 2025-10-01. Unauthorized disclosure, copying, or distribution
is prohibited.
```

### Chain of Custody

**Purpose:** Document who accessed evidence, when, and why to maintain legal integrity.

**Chain of Custody Log (CSV format):**

```csv
Timestamp,Action,Person,Role,File/Item,Purpose,Hash_Before,Hash_After,Notes
2025-10-01 09:00:00,Created,John Smith,Lead Investigator,investigation_darkphoenix/,Initial case setup,N/A,N/A,Case authorized by Legal
2025-10-05 14:23:15,Added,John Smith,Lead Investigator,twitter/profile_screenshot_2025-10-05.png,Evidence collection,N/A,a3f2b8c9d4e5f6a7,Screenshot captured via VPN
2025-10-07 10:15:00,Accessed,Jane Doe,Analyst,maltego_graph.mtgx,Analysis,a1b2c3d4e5f6a7b8,a1b2c3d4e5f6a7b8,Read-only access for review
2025-10-10 16:00:00,Modified,John Smith,Lead Investigator,report_final.pdf,Redaction,b2c3d4e5f6a7b8c9,c3d4e5f6a7b8c9d0,Applied redactions per legal guidance
2025-10-10 18:30:00,Sealed,John Smith,Lead Investigator,investigation_darkphoenix_2025-10-10.zip,Final packaging,N/A,f4a5b6c7d8e9f0a1,Encrypted with AES-256
2025-10-11 09:00:00,Transferred,John Smith,Lead Investigator,investigation_darkphoenix_2025-10-10.zip,Disclosure to Legal,f4a5b6c7d8e9f0a1,f4a5b6c7d8e9f0a1,Sent via secure file transfer
2025-10-11 09:15:00,Received,Sarah Johnson,Legal Counsel,investigation_darkphoenix_2025-10-10.zip,Legal review,f4a5b6c7d8e9f0a1,f4a5b6c7d8e9f0a1,Hash verified on receipt
```

**Best Practices:**
- Log every access, modification, and transfer
- Calculate and verify hashes before and after any modification
- Use UTC timestamps consistently
- Require acknowledgment of receipt for transfers
- Store chain of custody log separately from evidence (backup location)

### Encryption & Hashing

**Generate SHA-256 Hashes (All Files):**

For detailed hash generation methods, see [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods SOP]].

```bash
# Linux/macOS: Generate hashes for all files
find . -type f -exec sha256sum {} \; > file_hashes.txt

# Windows PowerShell:
Get-ChildItem -Recurse -File | ForEach-Object {
    "$($_.FullName): $((Get-FileHash $_.FullName -Algorithm SHA256).Hash)"
} > file_hashes.txt
```

**Encrypt Evidence Bundle (AES-256):**

```bash
# 7-Zip (Windows/Linux/macOS):
7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p investigation_darkphoenix_2025-10-10.7z investigation_darkphoenix_2025-10-10/

# OpenSSL (Linux/macOS):
tar -czf - investigation_darkphoenix_2025-10-10/ | openssl enc -aes-256-cbc -salt -pbkdf2 -out investigation_darkphoenix_2025-10-10.tar.gz.enc

# GPG (asymmetric encryption for specific recipients):
tar -czf investigation_darkphoenix_2025-10-10.tar.gz investigation_darkphoenix_2025-10-10/
gpg --encrypt --recipient legal@organization.com investigation_darkphoenix_2025-10-10.tar.gz
```

**Password Management:**
- Use strong passphrase (20+ characters, random words, or use password generator)
- Transmit password via separate secure channel (Signal, encrypted email, in-person)
- Never include password in same email/message as encrypted file
- Consider using asymmetric encryption (GPG) for high-security disclosures

---

## Metadata Scrubbing

**Why Scrub Metadata?**

Metadata can leak investigator identity, location, tools, and methods:
- **EXIF data** in images (GPS coordinates, camera model, timestamps)
- **Office documents** (author name, organization, edit history)
- **PDFs** (creator software, modification dates, document properties)
- **Screenshots** (file paths, taskbar showing username, browser tabs)

### EXIF Data Removal (Images)

**ExifTool (Recommended - CLI):**

```bash
# Remove ALL metadata from single image:
exiftool -all= photo.jpg

# Remove metadata from entire directory (recursive):
exiftool -all= -r ./evidence_photos/

# Verify metadata removed:
exiftool photo.jpg
# Should show minimal metadata (dimensions, format only)

# Batch process and backup originals:
exiftool -all= -overwrite_original_in_place -r ./evidence_photos/
```

**Windows: Remove Properties:**
```
Right-click image → Properties → Details tab → "Remove Properties and Personal Information"
→ Select "Remove the following properties" → Check all → OK
```

**macOS: ImageOptim (GUI):**
- Download: https://imageoptim.com/
- Drag images into ImageOptim window
- Automatically strips EXIF and optimizes file size

### Office Documents (Word, Excel, PowerPoint)

**Microsoft Office (Built-in Inspector):**

```
File → Info → Inspect Document → Check for Issues → Inspect Document
→ Check all boxes (Comments, Hidden Text, Personal Info, etc.) → Remove All
```

**LibreOffice:**

```
File → Properties → General tab → "Apply user data" (uncheck)
→ Reset Properties button → OK
```

**PDF Metadata Removal:**

**Adobe Acrobat Pro:**
```
File → Properties → Description tab → Clear all fields (Author, Title, Subject, Keywords)
→ File → Save As → Optimized PDF → Discard user data
```

**ExifTool (PDF):**
```bash
exiftool -all= report.pdf
```

**PDF Redaction** (see [Redaction Techniques](#redaction-techniques))

### Screenshot Sanitization

**Best Practices:**
- Use screenshot tools with built-in redaction (Greenshot, ShareX)
- Crop to relevant area only (remove taskbar, browser UI, tabs)
- Remove visible file paths, usernames, timestamps
- Use "Save As" to strip embedded metadata after editing

**Greenshot (Windows - Free):**
- Download: https://getgreenshot.org/
- Capture region, window, or full screen
- Built-in editor: redact sensitive areas, crop, blur
- Export as PNG with metadata stripped

**ShareX (Windows - Free):**
- Download: https://getsharex.com/
- Advanced features: scrolling capture, URL shortening, OCR
- Built-in editor with blur, pixelate, redaction tools
- Auto-upload to cloud (disable for OPSEC)

**Flameshot (Linux - Free):**
```bash
sudo apt install flameshot
flameshot gui  # Interactive screenshot with annotation
```

---

## Redaction Techniques

**What to Redact:**
- **PII (Personally Identifiable Information):**
  - Full names (if not relevant to investigation)
  - Addresses, phone numbers, email addresses (non-target individuals)
  - Social Security Numbers, national ID numbers, passport numbers
  - Financial information (credit cards, bank accounts)

- **Sensitive Content:**
  - CSAM (Child Sexual Abuse Material) - hash and report, never include in reports
  - Graphic violence or self-harm imagery
  - Confidential business information not relevant to findings

- **Investigator Attribution:**
  - Investigator names, usernames, email addresses
  - Organization names (unless legally required)
  - File paths revealing usernames (C:\Users\investigator\Desktop\...)
  - Research persona credentials

- **Operational Details:**
  - VPN providers, IP addresses used for collection
  - Specific tools beyond what's necessary for reproduction
  - Persona account details (passwords, email addresses)

### PDF Redaction (Permanent)

**Adobe Acrobat Pro (Recommended for Legal/Forensic Reports):**

```
Tools → Redact → Mark for Redaction → Draw boxes over sensitive text
→ Apply Redactions → Permanently remove hidden information → OK
→ File → Save As (creates redacted version)
```

**IMPORTANT:** "Mark for Redaction" is not final - must click "Apply Redactions" to permanently remove text.

**Verify Redaction:**
- Open redacted PDF in text editor (Notepad++) - redacted text should not appear
- Search PDF for sensitive terms - should return no results

**PDF Redaction CLI (pdftk + ImageMagick):**

```bash
# Convert PDF to images, redact, then re-create PDF
pdftk report.pdf burst
# Manually redact images with image editor
convert *.jpg redacted_report.pdf
```

### Image Redaction

**GIMP (Free, Cross-Platform):**
```
Open image → Select Rectangle Tool → Draw over sensitive area →
Edit → Fill with FG Color (black) → Flatten Image → Export As PNG
```

**ImageMagick (CLI):**
```bash
# Draw black box over region (x, y, width, height):
convert original.png -fill black -draw "rectangle 100,200,400,250" redacted.png
```

**Blur vs. Pixelate vs. Black Box:**
- ❌ **Blur:** Can sometimes be reversed with image enhancement
- ⚠️ **Pixelate:** More secure than blur, but some advanced techniques can de-pixelate
- ✅ **Black box:** Most secure - complete data destruction

**For high-security redactions:** Use black boxes, not blur/pixelate.

---

## Disclosure Protocols

### Authorization & Approvals

**Pre-Disclosure Checklist:**

```markdown
- [ ] Investigation authorized by supervisor/legal team
- [ ] Report reviewed by legal counsel (if required)
- [ ] Redactions applied and verified
- [ ] Metadata scrubbed from all files
- [ ] File hashes generated and documented
- [ ] Recipient authorized to receive information
- [ ] Disclosure method approved (encryption, secure transfer)
- [ ] Disclosure logged in chain of custody
```

**Authorization Matrix:**

| Recipient Type | Authorization Required | Encryption Required | Redaction Level |
|----------------|------------------------|---------------------|-----------------|
| Internal team (same org) | Supervisor approval | Recommended | Minimal (investigator names only) |
| Legal counsel | Supervisor approval | Required | Medium (PII of non-targets) |
| Law enforcement | Legal + LE liaison approval | Required | Medium (protect sources/methods) |
| External partners | Legal + executive approval | Required | High (all PII, investigator details) |
| Court/Regulatory | Legal approval | As required by court | Per legal guidance |

### Secure Transmission

**Option 1: Encrypted Email (GPG/PGP)**

```bash
# Encrypt report for specific recipient:
gpg --encrypt --recipient legal@organization.com report_final.pdf

# Result: report_final.pdf.gpg (encrypted file)
# Send via email with subject: "Encrypted OSINT Report - Case INV-2025-1010-001"
# Transmit password/decryption key via separate channel (Signal, phone call)
```

**Option 2: Secure File Transfer (SFTP/SCP)**

```bash
# Upload to secure server:
scp -r investigation_darkphoenix_2025-10-10.7z user@secure-server.org:/incoming/

# Or use SFTP clients: FileZilla (SFTP mode), WinSCP, Cyberduck
```

**Option 3: Secure Cloud Storage (Encrypted)**

- **Tresorit** (end-to-end encrypted, zero-knowledge)
- **ProtonDrive** (encrypted, privacy-focused)
- **SpiderOak** (zero-knowledge encryption)

❌ **Avoid:** Google Drive, Dropbox, OneDrive (not end-to-end encrypted by default)

**Option 4: Physical Transfer (High-Security Investigations)**

- Encrypted USB drive (BitLocker, LUKS, VeraCrypt)
- Hand-delivered with signed receipt
- Chain of custody maintained throughout transfer

### Disclosure Log

**Track all report disclosures:**

```csv
Date,Case_ID,Report_Version,Recipient,Organization,Transfer_Method,Hash_Verified,Authorization,Notes
2025-10-11,INV-2025-1010-001,v1.0,Sarah Johnson,Legal Dept,Encrypted email (GPG),Yes,AUTH-2025-001,Initial disclosure
2025-10-15,INV-2025-1010-001,v1.1,Det. Mike Brown,Local PD,SFTP,Yes,AUTH-2025-002,Updated with additional evidence
2025-10-20,INV-2025-1010-001,v1.1,Jane Smith,Partner Org,Encrypted USB,Yes,AUTH-2025-003,In-person transfer, receipt signed
```

**Recipient Acknowledgment Template:**

```markdown
I, [RECIPIENT NAME], acknowledge receipt of the following OSINT investigation materials:

**Case ID:** INV-2025-1010-001
**Report Title:** DarkPhoenix Identity Assessment
**Report Version:** v1.0
**Date Received:** 2025-10-11
**Files Received:** investigation_darkphoenix_2025-10-10.7z (1.2 GB)
**SHA-256 Hash:** f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5
**Hash Verified:** ✅ Yes / ❌ No

I understand that this material is CONFIDENTIAL and shall not be disclosed to unauthorized
parties. I will handle this material in accordance with [ORGANIZATION] policies and applicable laws.

Signature: _____________________
Date: _____________________
```

---

## Version Control

**Why Version Control Matters:**
- Reports often require updates as investigation progresses
- Legal/compliance may require changes (redactions, clarifications)
- Multiple stakeholders may need different versions (redaction levels)
- Audit trail documents what changed and why

### Versioning Scheme

**Semantic Versioning for Reports:**

```
v[MAJOR].[MINOR]
```

- **MAJOR:** Significant findings change (e.g., identity changed from Person A to Person B)
- **MINOR:** Additional evidence, clarifications, minor corrections

**Examples:**
- `v1.0` - Initial release
- `v1.1` - Added additional evidence (GitHub commits)
- `v1.2` - Corrected timeline dates, added Exhibit D
- `v2.0` - Re-assessed target identity (major change)

### Change Log

**Include in report or separate CHANGELOG.md:**

```markdown
# Change Log - Investigation: DarkPhoenix Identity Assessment

## [v1.2] - 2025-10-15
### Added
- Exhibit D: Blockchain transaction analysis (3 additional BTC addresses)
- Annex E: Romanian-language social media posts (translated)

### Changed
- Updated timeline with newly discovered GitHub activity (2021-2022)
- Revised confidence on employer affiliation from MEDIUM to HIGH (new LinkedIn evidence)

### Fixed
- Corrected timeline date for "First reconnaissance activity" (was 2025-09-12, corrected to 2025-09-15)

## [v1.1] - 2025-10-12
### Added
- Exhibit C: Infrastructure map showing 5 additional domains
- Section 4.3: Analysis of target's operational security practices

### Changed
- Enhanced Methodology section with additional tool version numbers

## [v1.0] - 2025-10-10
- Initial release
```

### File Naming Convention

**Format:**
```
[CASE_ID]_[REPORT_TYPE]_v[VERSION]_[YYYY-MM-DD].[ext]

Examples:
INV-2025-1010-001_report_v1.0_2025-10-10.pdf
INV-2025-1010-001_report_v1.1_2025-10-12.pdf
INV-2025-1010-001_briefing_v1.0_2025-10-10.pptx
INV-2025-1010-001_evidence_bundle_v1.2_2025-10-15.7z
```

**Benefits:**
- Sortable by date
- Clear version identification
- Easy to track report evolution
- No ambiguity about which version is latest

---

## Quality Assurance Checklist

### Pre-Release Checklist

**Content Review:**
- [ ] Executive summary accurately reflects findings
- [ ] All claims backed by cited evidence (exhibit numbers)
- [ ] Confidence levels assigned to all assessments
- [ ] Alternative hypotheses considered and addressed
- [ ] Methodology section includes limitations and bias statement
- [ ] Timeline entries have source citations
- [ ] All exhibits referenced in text are included in annexes
- [ ] Writing is objective, factual, and avoids speculation
- [ ] Grammar and spelling checked (Grammarly, ProWritingAid, or manual)

**Evidence Integrity:**
- [ ] All evidence files present in bundle
- [ ] SHA-256 hashes calculated for all files (see [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]])
- [ ] Hashes verified against collection log
- [ ] Chain of custody log complete and accurate
- [ ] Evidence bundle structure organized and logical
- [ ] README.md included with reproduction instructions

**Security & Privacy:**
- [ ] Metadata scrubbed from all files (EXIF, Office properties, PDF metadata)
- [ ] Redactions applied per legal/ethical guidance
- [ ] Redactions verified (search PDFs for sensitive terms)
- [ ] Investigator attribution removed (names, emails, file paths)
- [ ] Research persona credentials not exposed
- [ ] OPSEC measures documented (VPN, personas, tools)
- [ ] No TOS violations or ethical violations occurred

**Legal & Ethics:**
- [ ] Investigation authorized by supervisor/legal team
- [ ] SOPs followed: [[sop-legal-ethics|Legal & Ethics]], [[sop-opsec-plan|OPSEC Planning]], [[sop-collection-log|Collection Log]]
- [ ] No unauthorized access or hacking performed
- [ ] No collection of highly sensitive data (CSAM, financial records, health data) without proper authorization (see [[sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]])
- [ ] Report reviewed by legal counsel (if required)
- [ ] Disclosure recipients authorized and logged

**Packaging & Delivery:**
- [ ] Evidence bundle encrypted (AES-256 via 7z or GPG)
- [ ] Encryption password transmitted via separate secure channel
- [ ] File integrity hash provided (SHA-256 of encrypted bundle)
- [ ] Disclosure logged in chain of custody
- [ ] Recipient acknowledgment obtained (signed receipt)
- [ ] Backup copy stored in secure location

---

## Templates & Examples

### Executive Summary Template

```markdown
## Executive Summary

**Investigation Objective:**
[One sentence describing what question you were answering]

**Key Findings:**
- [HIGH/MEDIUM/LOW CONFIDENCE]: [Key finding 1 - most important first]
- [HIGH/MEDIUM/LOW CONFIDENCE]: [Key finding 2]
- [HIGH/MEDIUM/LOW CONFIDENCE]: [Key finding 3]

**Recommendations:**
1. [Actionable recommendation 1]
2. [Actionable recommendation 2]
3. [Actionable recommendation 3]

**Timeline:**
Investigation conducted [START DATE] to [END DATE].
Key events occurred [EVENT START DATE] to [EVENT END DATE].

**Confidence Assessment:**
Overall confidence: [HIGH/MEDIUM/LOW].
Primary uncertainties: [What we don't know that would change assessment]
```

### Finding Template

```markdown
### Finding [N]: [Title - claim being made]

**Evidence:**
1. **[Evidence category]** ([CONFIDENCE LEVEL])
   - [Specific observation 1]
   - [Specific observation 2] (see Exhibit [X])
   - [Specific observation 3]

2. **[Evidence category]** ([CONFIDENCE LEVEL])
   - [Specific observation 1]
   - [Specific observation 2]

**Analysis:**
[Your interpretation of the evidence - what does it mean?]

**Alternative Hypotheses:**
- [Alternative explanation 1]: [Why you assess this as unlikely]
- [Alternative explanation 2]: [Why you assess this as unlikely]

**Confidence: [HIGH/MEDIUM/LOW]** ([X]% certainty) - [Rationale for confidence level]
```

### Exhibit Entry Template

```markdown
**Exhibit [X]: [Title]**
- **File:** exhibit_[x]_[description].[ext]
- **SHA-256:** [hash]
- **Description:** [What this exhibit shows and why it matters]
- **Source:** [Where/how this evidence was collected]
- **Collection Date:** [YYYY-MM-DD]
- **Collection Method:** [Tool/technique used]
- **Relevance:** [How this supports findings]
```

---

## Tools & Resources

### Recommended Tools

| Tool | Category | Purpose | Platform |
|------|----------|---------|----------|
| **ExifTool** | Metadata Scrubbing | Remove EXIF/metadata from images, PDFs, Office docs | CLI (all platforms) |
| **Adobe Acrobat Pro** | Redaction | Professional PDF redaction with permanent removal | Windows, macOS |
| **Greenshot** | Screenshots | Screenshot tool with built-in annotation/redaction | Windows |
| **ShareX** | Screenshots | Advanced screenshot tool with auto-upload, OCR | Windows |
| **Flameshot** | Screenshots | Screenshot tool with annotation for Linux | Linux |
| **7-Zip** | Encryption | AES-256 encryption for evidence bundles | Windows, Linux, macOS |
| **GPG/PGP** | Encryption | Asymmetric encryption for secure email/file transfer | CLI (all platforms) |
| **KeePassXC** | Password Management | Store encryption passwords securely | Windows, Linux, macOS |
| **Grammarly** | Writing | Grammar and spelling checker | Web, browser extension |
| **Maltego** | Visualization | Create entity relationship graphs for annexes | Windows, Linux, macOS |
| **Obsidian** | Documentation | Link analysis and note-taking for report drafting | Windows, Linux, macOS |

### File Hash Tools

For comprehensive hash generation guidance, see [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods SOP]].

**Generate SHA-256 Hashes:**

```bash
# Linux/macOS:
sha256sum file.pdf
find . -type f -exec sha256sum {} \; > file_hashes.txt

# Windows PowerShell:
Get-FileHash file.pdf -Algorithm SHA256
Get-ChildItem -Recurse -File | Get-FileHash -Algorithm SHA256 > file_hashes.txt

# Windows Command Prompt (certutil):
certutil -hashfile file.pdf SHA256
```

### Encryption Tools

**7-Zip (AES-256 encryption):**
```bash
# Compress and encrypt:
7z a -t7z -m0=lzma2 -mx=9 -mhe=on -p output.7z input_folder/

# Decrypt:
7z x output.7z
```

**GPG (Asymmetric encryption):**
```bash
# Generate GPG key pair (first time):
gpg --full-generate-key

# Encrypt file for recipient:
gpg --encrypt --recipient recipient@email.com file.pdf

# Decrypt received file:
gpg --decrypt file.pdf.gpg > file.pdf
```

### Resources & References

**Report Writing Guides:**
- SANS DFIR Report Writing Guide: https://www.sans.org/white-papers/37437/
- NIST SP 800-86 (Integration of Forensics): https://csrc.nist.gov/publications/detail/sp/800-86/final
- UK National Archives Digital Continuity: https://www.nationalarchives.gov.uk/

**Intelligence Standards:**
- ODNI Confidence Levels (ICD 203): https://www.dni.gov/index.php/ic-legal-reference-book/intelligence-community-directive-203
- Admiralty Code (Source Reliability): https://en.wikipedia.org/wiki/Admiralty_code

**Metadata & Privacy:**
- ExifTool Documentation: https://exiftool.org/
- PDF Redaction Guide: https://www.adobe.com/acrobat/hub/how-to-redact-pdf.html
- Metadata Anonymization Toolkit (MAT): https://0xacab.org/jvoisin/mat2

**Chain of Custody:**
- NIST Digital Evidence Guidelines: https://csrc.nist.gov/publications/detail/sp/800-101/rev-1/final
- FBI Digital Evidence Policy: https://www.fbi.gov/file-repository/digital-evidence-policy-guide.pdf

---

**Version:** 2.0
**Last Updated:** 2025-10-10
**Review Cycle:** Yearly

---

**Related SOPs:**
[[sop-legal-ethics|Legal & Ethics]] | [[sop-opsec-plan|OPSEC Planning]] | [[sop-collection-log|Collection Log]] | [[sop-entity-dossier|Entity Dossier]] | [Investigations-Index](../Investigations-Index.md)
