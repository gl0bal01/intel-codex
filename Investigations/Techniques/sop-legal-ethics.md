---
type: sop
title: Legal, Ethics & Data Governance for OSINT
description: "Essential legal & ethical boundaries for OSINT: GDPR compliance, authorization requirements, privacy laws & responsible disclosure protocols."
created: 2025-10-05
tags: [sop, legal, ethics, compliance, gdpr, privacy, data-governance]
---

# Legal, Ethics & Data Governance for OSINT

> **Purpose:** Comprehensive legal and ethical framework for conducting OSINT investigations in compliance with data protection laws, privacy regulations, and professional ethics standards.

---

## Table of Contents

1. [Overview](#overview)
2. [Legal Basis & Authority](#legal-basis--authority)
3. [Jurisdictional Considerations](#jurisdictional-considerations)
4. [Prohibited Actions](#prohibited-actions)
5. [Data Minimization & Proportionality](#data-minimization--proportionality)
6. [Privacy & Data Protection](#privacy--data-protection)
7. [Retention & Data Lifecycle](#retention--data-lifecycle)
8. [Evidentiary Integrity](#evidentiary-integrity)
9. [Ethical Guidelines](#ethical-guidelines)
10. [Escalation & Safeguarding](#escalation--safeguarding)
11. [Legal Compliance Checklist](#legal-compliance-checklist)

---

## Overview

### Why Legal & Ethical Compliance Matters

**Legal risks of non-compliance:**
- **Criminal liability:** Unauthorized access (CFAA, Computer Misuse Act), harassment, stalking
- **Civil liability:** Privacy violations, defamation, intentional infliction of emotional distress
- **Regulatory penalties:** GDPR fines (up to €20M or 4% of global revenue), data breach notifications
- **Evidence exclusion:** Illegally obtained evidence inadmissible in court (Fruit of the Poisonous Tree doctrine)
- **Organizational consequences:** License revocation, contracts terminated, reputational damage

**Ethical considerations:**
- **Proportionality:** Is the investigation justified by the harm being investigated?
- **Privacy:** Are you respecting individuals' reasonable expectation of privacy?
- **Transparency:** Can you justify your methods to the public or a court?
- **Harm minimization:** Are you avoiding unnecessary harm to subjects or third parties?

### Regulatory Framework

**Key Laws & Regulations:**

**United States:**
- **CFAA (18 U.S.C. § 1030):** Computer Fraud and Abuse Act - prohibits unauthorized access
- **ECPA (18 U.S.C. § 2510):** Electronic Communications Privacy Act - wiretapping, stored communications
- **SCA (18 U.S.C. § 2701):** Stored Communications Act - unauthorized access to stored electronic communications
- **State privacy laws:** CCPA (California), VCDPA (Virginia), CPA (Colorado)

**European Union:**
- **GDPR (Regulation 2016/679):** General Data Protection Regulation - data processing, privacy rights
- **ePrivacy Directive (2002/58/EC):** Cookie consent, electronic communications privacy
- **Data Retention Directive:** Varies by member state

**United Kingdom:**
- **Data Protection Act 2018:** UK implementation of GDPR
- **Computer Misuse Act 1990:** Unauthorized access to computer systems
- **Investigatory Powers Act 2016:** Surveillance and interception
- **Modern Slavery Act 2015:** Mandatory reporting of trafficking

**Australia:**
- **Privacy Act 1988:** Australian Privacy Principles (APPs)
- **Cybercrime Act 2001:** Unauthorized access, data interference
- **Surveillance Devices Act:** Varies by state

**International:**
- **Budapest Convention on Cybercrime:** International cooperation on cybercrime
- **UN Guiding Principles on Business & Human Rights:** Corporate responsibility for human rights

---

## Legal Basis & Authority

### Establishing Legal Authority

**OSINT investigations must have a lawful basis. Common bases:**

**1. Contract:**
- Investigation requested by client under service agreement
- Due diligence for business transaction
- Employment background check (with consent)

**Example:** "Client X has retained our firm to conduct due diligence on Company Y for acquisition purposes under Contract dated 2025-10-01."

**2. Legal Obligation:**
- Compliance with anti-money laundering (AML) regulations
- Know Your Customer (KYC) requirements
- Mandatory reporting (child safety, terrorism)

**Example:** "Bank is conducting enhanced due diligence on high-risk customer per FinCEN AML requirements (31 CFR § 1020.210)."

**3. Public Task / Public Interest:**
- Journalism in the public interest
- Academic research
- Law enforcement (with proper authorization)

**Example:** "Investigation into public corruption by elected officials serves public interest under journalism privilege."

**4. Vital Interests:**
- Life-threatening emergency
- Missing person search
- Imminent threat to safety

**Example:** "Missing child case, investigation authorized to protect vital interests of minor under GDPR Article 6(1)(d)."

**5. Legitimate Interest:**
- Fraud investigation (protecting organization's interests)
- Cybersecurity threat intelligence
- Reputation management (limited scope)

**Example:** "Investigation into data breach affecting company customers serves legitimate interest in security under GDPR Article 6(1)(f)."

**6. Consent:**
- Subject has provided informed, freely given consent
- Consent can be withdrawn at any time

**Example:** "Individual requested background check on themselves and provided written consent."

### Scope of Authority

**Defined in writing before investigation begins:**

```markdown
# Investigation Scope Document

**Case ID:** CASE-2025-1005-001
**Date:** 2025-10-05
**Investigator:** [Your Name]
**Client/Requesting Party:** [Client Name]

## Legal Basis
**Authority:** [Contract / Legal Obligation / Public Interest / Vital Interests / Legitimate Interest]
**Legal Citation:** [Reference to contract, statute, regulation, or policy]

## Investigation Scope
**Subject(s):**
- [Name or identifier of investigation subject]

**Purpose:**
- [Specific question(s) to be answered]

**Permitted Actions:**
- ✅ Search publicly available social media profiles
- ✅ Review publicly accessible business records
- ✅ Analyze blockchain transactions (public ledger)
- ❌ NO unauthorized access to private accounts
- ❌ NO social engineering or pretexting
- ❌ NO purchase of illegally obtained data

**Jurisdictions:**
- Primary: [Country/state where subject is located]
- Secondary: [Where investigator is located, if different]

**Data Categories:**
- Biographical information (name, age, location)
- Professional background (employment, education)
- Business affiliations (companies, partnerships)
- ❌ NO sensitive data (health, religion, sexual orientation) unless essential and lawful

**Duration:**
- Start: [Start date]
- End: [End date or "until completion"]

**Reporting:**
- Report to: [Client contact]
- Format: [Written report, oral briefing]
- Disclosure restrictions: [Confidential, attorney-client privilege, etc.]

---

**Authorized by:** [Client signature/approval]
**Date:** 2025-10-05
```

### Authorization Documentation

**Maintain records of authorization:**
- Client engagement letter or contract
- Investigative task order or work authorization
- Email or written approval from supervisor
- Court order or subpoena (if applicable)
- Data Processing Agreement (DPA) for GDPR compliance

---

## Jurisdictional Considerations

### Multi-Jurisdictional Investigations

**When investigating subjects in multiple countries:**

**Scenario 1: US investigator, US subject**
- **Governing law:** US federal + state laws (CFAA, state privacy laws)
- **Key compliance:** Terms of Service, CFAA "exceeding authorized access"

**Scenario 2: US investigator, EU subject**
- **Governing law:** US laws + GDPR (extraterritorial application)
- **Key compliance:** GDPR lawful basis, data subject rights, cross-border transfer restrictions

**Scenario 3: EU investigator, US subject**
- **Governing law:** GDPR + US state privacy laws (if subject is CA resident under CCPA)
- **Key compliance:** GDPR + CCPA consumer rights

**Scenario 4: Investigating multinational corporation**
- **Governing law:** Laws of all countries where company operates
- **Key compliance:** Most restrictive jurisdiction applies (GDPR is often strictest)

### Conflict of Laws

**When laws conflict:**

**Example:** US First Amendment protects publication of leaked documents, but UK Official Secrets Act criminalizes it.

**Resolution:**
- Consult legal counsel before proceeding
- Apply most restrictive law (safest approach)
- Consider where investigation will be used (jurisdiction of legal proceedings)
- Document legal analysis and risk assessment

### Extraterritorial Application

**GDPR applies to:**
- Organizations established in EU (regardless of where data is processed)
- Organizations outside EU that offer goods/services to EU residents
- Organizations outside EU that monitor behavior of EU residents

**Example:** US-based OSINT firm investigating EU resident for US client must comply with GDPR.

**CCPA applies to:**
- For-profit businesses doing business in California
- Collecting personal information of California residents
- Meeting revenue/data volume thresholds

---

## Prohibited Actions

### Absolutely Prohibited (Criminal Acts)

**1. Unauthorized Access (Hacking)**

**Prohibited:**
- ❌ Guessing or cracking passwords to access private accounts
- ❌ Exploiting vulnerabilities to access non-public systems
- ❌ Using stolen credentials (even if publicly leaked)
- ❌ Bypassing paywalls or authentication mechanisms

**Legal risk:**
- **US:** CFAA violation (18 U.S.C. § 1030) - up to 10 years imprisonment
- **UK:** Computer Misuse Act 1990 - up to 2 years imprisonment
- **EU:** Varies by member state

**Case law:**
- *Van Buren v. United States* (2021): Accessing data you're authorized to access for unauthorized purposes may NOT violate CFAA (narrow ruling)
- *hiQ Labs v. LinkedIn* (2022): Scraping publicly accessible data does NOT violate CFAA
- **Caution:** Case law evolving, consult counsel

**Permitted:**
- ✅ Accessing publicly available information (no authentication required)
- ✅ Using publicly disclosed credentials (e.g., default passwords, if legal in jurisdiction)
- ✅ Accessing data you have permission to access (Terms of Service compliance)

**2. Social Engineering / Pretexting**

**Prohibited:**
- ❌ Impersonating law enforcement, government officials, or other authority
- ❌ Creating fake personas to befriend targets and extract information
- ❌ Phishing or sending malicious links to targets
- ❌ Calling under false pretenses to obtain information (pretexting)

**Legal risk:**
- **US:** Wire fraud (18 U.S.C. § 1343), identity theft, state anti-pretexting laws
- **UK:** Fraud Act 2006 (false representation)

**Permitted:**
- ✅ Passive OSINT using burner accounts (no active deception of target)
- ✅ Viewing public profiles without interaction
- ✅ Using pseudonyms for investigator safety (no impersonation)

**3. Purchase of Illegally Obtained Data**

**Prohibited:**
- ❌ Purchasing data from data breaches (stolen credentials, PII)
- ❌ Buying access to private databases (medical records, financial records)
- ❌ Purchasing phone records, text message logs, or location data from unauthorized sources

**Legal risk:**
- **US:** Conspiracy, receipt of stolen property, CFAA
- **EU:** GDPR violation (processing unlawfully obtained data)

**Permitted:**
- ✅ Searching public breach databases (Have I Been Pwned) for email verification
- ✅ Using leaked data if already publicly available (no payment, passive collection)
- ✅ Purchasing legitimately obtained data (credit reports with consent, public records)

**4. Entrapment & Inducement**

**Prohibited:**
- ❌ Inducing someone to commit a crime they wouldn't otherwise commit
- ❌ Offering financial incentives for illegal actions
- ❌ Creating fake criminal opportunities to ensnare targets

**Legal risk:**
- Entrapment defense (criminal case dismissed)
- Civil liability for inducement
- Evidence exclusion

**Permitted (Law Enforcement Only):**
- ✅ Undercover operations (with proper authorization)
- ✅ Sting operations (if subject already predisposed to crime)

**5. Harassment, Stalking, or Intimidation**

**Prohibited:**
- ❌ Repeated unwanted contact with subject
- ❌ Threats or coercion to obtain information
- ❌ Publishing private information to harass (doxxing)
- ❌ Physical surveillance that constitutes stalking

**Legal risk:**
- **US:** Federal stalking statute (18 U.S.C. § 2261A), state stalking laws, restraining orders
- **UK:** Protection from Harassment Act 1997

**Permitted:**
- ✅ Single contact attempt (if lawful and non-threatening)
- ✅ Passive online monitoring (no interaction with subject)
- ✅ Publishing information in public interest (journalism privilege, limited)

### Highly Restricted (Require Special Authorization)

**1. Surveillance & Tracking**

**Restricted:**
- ⚠️ GPS tracking of vehicles (may require court order)
- ⚠️ Installation of tracking software (may violate wiretap laws)
- ⚠️ Use of surveillance drones (FAA regulations, privacy laws)
- ⚠️ Audio/video recording in private spaces (two-party consent states)

**Authorization required:**
- Court order or warrant (law enforcement)
- Consent of subject (one-party or all-party, depending on jurisdiction)
- Private investigator license (varies by state)

**2. Communications Interception**

**Restricted:**
- ⚠️ Intercepting emails, messages, or phone calls in transit
- ⚠️ Accessing stored communications without authorization
- ⚠️ Installing keyloggers or spyware

**Legal framework:**
- **US:** Wiretap Act (18 U.S.C. § 2511), Stored Communications Act (18 U.S.C. § 2701)
- **EU:** ePrivacy Directive, national wiretap laws
- Requires court order or consent

**3. Sensitive Personal Data (GDPR "Special Categories")**

**Restricted data types:**
- ⚠️ Racial or ethnic origin
- ⚠️ Political opinions
- ⚠️ Religious or philosophical beliefs
- ⚠️ Trade union membership
- ⚠️ Genetic data
- ⚠️ Biometric data (for identification)
- ⚠️ Health data
- ⚠️ Sex life or sexual orientation

**GDPR requirements:**
- Explicit consent, OR
- Legal obligation, OR
- Vital interests (life-threatening emergency), OR
- Substantial public interest (with legal basis)

**Best practice:** Avoid collecting sensitive data unless absolutely necessary and lawfully authorized.

---

## Data Minimization & Proportionality

### Principle of Data Minimization

**GDPR Article 5(1)(c):** Data must be "adequate, relevant and limited to what is necessary."

**In practice:**
- Collect only data that answers the Priority Intelligence Requirements (PIRs)
- Do NOT collect extraneous personal information
- Do NOT create comprehensive dossiers beyond investigation scope

**Example:**

**Investigation scope:** "Is Subject X affiliated with sanctioned entities?"

✅ **Collect:**
- Business registrations, directorships
- Known associates in business context
- Financial transactions (public records)

❌ **Do NOT collect:**
- Subject's dating profile
- Family photos on social media
- Health information
- Religious affiliation

### Proportionality Assessment

**Balancing test:**
- **Necessity:** Is the data collection necessary to achieve the investigation purpose?
- **Proportionality:** Is the privacy intrusion proportionate to the harm being investigated?
- **Alternatives:** Are there less intrusive methods to obtain the same information?

**Example:**

**High-value investigation (terrorism, child safety, organized crime):**
- ✅ Extensive OSINT justified
- ✅ Collection of associates, travel patterns, financial indicators
- ✅ Coordination with law enforcement

**Low-value investigation (employment background check):**
- ❌ NOT justified to create comprehensive social media dossier
- ✅ Limited to employment history, criminal records (with consent), professional references
- ❌ NOT justified to investigate family members or romantic relationships

### Priority Intelligence Requirements (PIRs)

**Define PIRs before investigation:**

```markdown
# Priority Intelligence Requirements (PIRs)

**Case ID:** CASE-2025-1005-001
**Investigation:** Due diligence on Company XYZ for acquisition

## PIRs (in priority order):

1. **Corporate structure:**
   - Legal entities, subsidiaries, ownership structure
   - Beneficial owners, directors, officers

2. **Financial indicators:**
   - Public financial records, SEC filings
   - Bankruptcy, liens, judgments
   - Sanctions screening (OFAC, EU, UN)

3. **Reputation & litigation:**
   - News articles, press releases
   - Lawsuits, regulatory actions
   - Industry reputation

4. **Key personnel:**
   - Background of CEO, CFO, directors
   - Criminal records (public only)
   - Professional misconduct

## Out of Scope:
- ❌ Personal social media of employees
- ❌ Family members of executives
- ❌ Health or medical information
- ❌ Political opinions or religious beliefs
```

**Stop collecting when PIRs are answered.**

---

## Privacy & Data Protection

### GDPR Compliance (EU Subjects)

**Key GDPR Principles:**

**1. Lawfulness, Fairness, Transparency (Article 5(1)(a))**
- Process data lawfully (establish legal basis)
- Process data fairly (proportionality, no deception)
- Be transparent (provide privacy notice, subject access rights)

**2. Purpose Limitation (Article 5(1)(b))**
- Collect data for specified, explicit purposes
- Do NOT use data for incompatible purposes

**3. Data Minimization (Article 5(1)(c))**
- Collect only necessary data

**4. Accuracy (Article 5(1)(d))**
- Ensure data is accurate and up-to-date
- Correct errors when identified

**5. Storage Limitation (Article 5(1)(e))**
- Retain data only as long as necessary
- Delete or anonymize when no longer needed

**6. Integrity & Confidentiality (Article 5(1)(f))**
- Protect data with appropriate security measures
- Prevent unauthorized access or disclosure

### Data Subject Rights (GDPR)

**Subjects have the right to:**

**1. Right to be Informed (Article 13-14)**
- Privacy notice explaining data processing
- **OSINT exception:** May delay notification if it would undermine investigation (Article 14(5)(b))

**2. Right of Access (Article 15)**
- Subject can request copy of their data
- Provide within 30 days (can extend to 90 days if complex)

**3. Right to Rectification (Article 16)**
- Subject can request correction of inaccurate data
- Update records within 30 days

**4. Right to Erasure / "Right to be Forgotten" (Article 17)**
- Subject can request deletion
- **Exceptions:** Legal obligation, public interest, establishment/defense of legal claims

**5. Right to Restrict Processing (Article 18)**
- Subject can request processing be limited
- Apply if accuracy is contested or processing is unlawful

**6. Right to Data Portability (Article 20)**
- Subject can request data in machine-readable format
- Typically not applicable to OSINT (no automated processing)

**7. Right to Object (Article 21)**
- Subject can object to processing for legitimate interests
- Must stop unless compelling legitimate grounds override

**Handling DSAR (Data Subject Access Request):**

```markdown
# DSAR Response Template

**Request received:** 2025-10-05
**Requester:** [Subject name]
**Case reference:** DSAR-2025-1005-001

## Data Holdings

**Personal data we hold about you:**
1. Name, date of birth, address (from public records)
2. Employment history (LinkedIn public profile)
3. Business affiliations (company registrations)
4. Social media posts (public tweets, archived)

**Source:** Publicly available information (no direct collection from you)

**Purpose:** Due diligence investigation for client acquisition

**Legal basis:** Legitimate interest (Article 6(1)(f))

**Retention:** Data will be retained until [date], then securely deleted

**Your rights:**
- Right to rectification (if data is inaccurate)
- Right to erasure (limited by legal obligations)
- Right to object to processing

**How to exercise rights:** Contact [Data Protection Officer email]

**Provided:** [Attached data export]
```

### CCPA Compliance (California Residents)

**CCPA Consumer Rights:**

**1. Right to Know (§ 1798.100)**
- Categories of personal information collected
- Sources, purposes, third parties with access

**2. Right to Delete (§ 1798.105)**
- Request deletion of personal information
- **Exceptions:** Legal compliance, security, legal claims

**3. Right to Opt-Out of Sale (§ 1798.120)**
- Prohibit sale of personal information
- **Note:** OSINT investigations typically do NOT constitute "sale"

**4. Right to Non-Discrimination (§ 1798.125)**
- Cannot discriminate for exercising CCPA rights

**CCPA Definitions:**
- **Personal Information:** Information that identifies, relates to, or could reasonably be linked to a California resident
- **Sale:** Includes disclosure for valuable consideration (broadly defined)

### Privacy by Design

**Build privacy into investigation process:**

**1. Pseudonymization:**
- Replace identifying information with pseudonyms in analysis
- Example: "Subject A" instead of real name in internal notes

**2. Anonymization (when possible):**
- Remove identifying information if individual identity not necessary
- Example: "45-year-old male executive in tech industry" vs. "John Doe, CEO of Acme Corp"

**3. Access Controls:**
- Limit access to investigation data to need-to-know personnel
- Use role-based access control (RBAC)
- Log all access to sensitive data

**4. Encryption:**
- Encrypt data at rest and in transit
- Use full-disk encryption for investigation workstations
- Encrypted communication channels (Signal, ProtonMail)

---

## Retention & Data Lifecycle

### Data Retention Policy

**Retention periods (examples):**

**Active investigation:**
- Retain all data until investigation complete and report delivered

**Post-investigation (client deliverables):**
- Client report: Retain per client contract (typically 3-7 years)
- Attorney work product: Retain per legal hold requirements
- Regulatory: Retain per applicable regulations (AML: 5 years)

**Post-investigation (working files):**
- Raw data, notes, drafts: Delete 90 days after case closure (unless legal hold)
- Evidence in legal proceedings: Retain until final disposition + appeals

**GDPR storage limitation:**
- Delete or anonymize data when no longer necessary for original purpose
- Review retention every 12 months

**Retention schedule:**

| Data Type | Retention Period | Justification | Deletion Method |
|-----------|------------------|---------------|-----------------|
| Final client report | 7 years | Legal claims limitation period | Secure deletion (7-pass wipe) |
| Evidence (ongoing litigation) | Until case closed + 5 years | Legal hold | Secure deletion after release |
| Working files (notes, drafts) | 90 days post-case | No business need beyond delivery | Secure deletion |
| Publicly sourced data | 1 year | Reference for similar cases | Secure deletion or anonymization |
| Sensitive data (CSAM, terrorism) | Transfer to LE, then delete | Legal prohibition on possession | Immediate secure deletion post-transfer |

### Data Destruction

**Secure deletion procedures:**

```bash
# Cryptographic wiping (DoD 5220.22-M standard)

# Linux (shred):
shred -vfz -n 7 /path/to/file
# -v: verbose, -f: force, -z: zero after shred, -n 7: 7 passes

# Windows (sdelete):
sdelete -p 7 -s C:\Path\To\Directory
# -p 7: 7 passes, -s: recurse subdirectories

# Verify deletion:
# File should not be recoverable with forensic tools

# Document destruction:
echo "Deleted: /path/to/file on $(date) via shred -n 7" >> deletion_log.txt
```

**Physical media destruction:**
- Hard drives: Physical destruction (shred, degauss, incinerate)
- USB drives: Physical destruction or cryptographic wipe
- Paper documents: Cross-cut shred or incinerate
- Optical media (CD/DVD): Physical destruction (shred)

**Deletion log:**

```markdown
# Data Deletion Log

**Case ID:** CASE-2025-1005-001
**Deletion Date:** 2025-12-01
**Deleted by:** [Your Name]
**Authorization:** Case closed 2025-09-01, 90-day retention period expired

## Deleted Items

| File/Folder | Size | Method | Verification |
|-------------|------|--------|--------------|
| /Evidence/CASE-2025-1005-001/ | 2.3 GB | shred -n 7 | Not recoverable |
| Working_Notes_2025-1005.docx | 150 KB | sdelete -p 7 | Not recoverable |
| Backup_USB_Drive_Serial_ABC123 | 16 GB | Physical destruction | Device shredded |

**Exceptions (retained):**
- Final_Report_CASE-2025-1005-001.pdf (retained per client contract)

**Verified by:** [Supervisor Name]
**Date:** 2025-12-01
```

---

## Evidentiary Integrity

### Chain of Custody

**Purpose:** Demonstrate evidence has not been tampered with from collection to presentation in court.

**Required for:**
- Criminal prosecutions
- Civil litigation
- Regulatory proceedings
- Internal disciplinary actions

**Chain of Custody elements:**

```markdown
# Chain of Custody Log

**Evidence ID:** EVID-2025-1005-001-A
**Description:** Screenshot of Twitter post by @suspect_account
**Case ID:** CASE-2025-1005-001

## Collection
- **Collected by:** [Your Name]
- **Date/Time:** 2025-10-05 14:30:00 UTC
- **Location:** https://twitter.com/suspect_account/status/123456789
- **Method:** Browser screenshot (Firefox 120.0), URL visible in screenshot
- **Original filename:** suspect_tweet_20251005_1430.png
- **Hash (SHA-256):** a1b2c3d4e5f6...

## Storage
- **Location:** /Evidence/CASE-2025-1005-001/screenshots/
- **Access restrictions:** Encrypted volume, access limited to case team
- **Backup:** Encrypted cloud backup (AWS S3, encrypted at rest)

## Transfers

| Date/Time | From | To | Purpose | Signature |
|-----------|------|-----|---------|-----------|
| 2025-10-05 14:35 | [Your Name] | Encrypted evidence drive | Initial storage | [Signature] |
| 2025-10-10 09:00 | [Your Name] | Legal Counsel | Attorney review | [Signature] |
| 2025-11-01 10:00 | Legal Counsel | Court (via secure filing) | Evidence submission | [Signature] |

## Integrity Verification

| Date | Verified by | Hash (SHA-256) | Status |
|------|-------------|----------------|--------|
| 2025-10-05 | [Your Name] | a1b2c3d4e5f6... | ✅ Match |
| 2025-10-10 | Legal Counsel | a1b2c3d4e5f6... | ✅ Match |
| 2025-11-01 | Court Clerk | a1b2c3d4e5f6... | ✅ Match |
```

### Hashing & Integrity Verification

**Calculate cryptographic hashes immediately upon collection:**

```bash
# SHA-256 (recommended):
sha256sum evidence_file.png
# Output: a1b2c3d4e5f6... evidence_file.png

# MD5 (legacy, collision attacks exist, avoid for security):
md5sum evidence_file.png

# Create manifest file:
sha256sum *.png > SHA256SUMS

# Verify integrity later:
sha256sum -c SHA256SUMS
# Output: evidence_file.png: OK
```

**Hash verification workflow:**
1. **Collection:** Calculate SHA-256 hash, record in evidence log
2. **Storage:** Verify hash matches before archiving
3. **Transfer:** Recipient verifies hash upon receipt
4. **Court submission:** Verify hash before submission, include hash in evidence certification

### Immutable Storage

**Prevent tampering:**
- **Write-once media:** Burn evidence to DVD-R or BD-R
- **Immutable cloud storage:** AWS S3 Object Lock, Azure Immutable Blob Storage
- **Blockchain timestamping:** OpenTimestamps for proof of existence at specific time
- **Forensic imaging:** Create forensic image (dd, FTK Imager) with write-blocking

**Example (DVD-R evidence archive):**

```bash
# Create ISO image of evidence directory:
mkisofs -o CASE-2025-1005-001.iso -R -J /Evidence/CASE-2025-1005-001/

# Calculate hash of ISO:
sha256sum CASE-2025-1005-001.iso > CASE-2025-1005-001.iso.sha256

# Burn to DVD-R (write-once):
cdrecord -v dev=/dev/sr0 CASE-2025-1005-001.iso

# Verify burn:
dd if=/dev/sr0 | sha256sum
# Compare with original ISO hash
```

### Legal Admissibility Standards

**Daubert Standard (US Federal Courts):**
- Scientific validity of methods
- Peer review and publication
- Known error rate
- General acceptance in relevant community

**Apply to OSINT:**
- Use accepted tools (WHOIS, Google, Archive.org)
- Document methodology
- Peer review (supervisor verification)
- Industry standards (OSINT framework, Bellingcat methodology)

**Best Evidence Rule:**
- Original document preferred over copy
- For digital evidence: Original file + metadata, not screenshot
- Exception: Original unavailable (deleted tweet → screenshot acceptable with authentication)

**Authentication (FRE 901):**
- Witness testimony: "I personally collected this screenshot on [date] from [URL]"
- Chain of custody: Demonstrating evidence is what you claim it is
- Hash verification: Proving file has not been altered

---

## Ethical Guidelines

### Professional Ethics Codes

**OSINT-specific ethics frameworks:**
- **Bellingcat's Digital Investigations Guide:** https://bellingcat.gitbook.io/toolkit/resources/guides-and-handbooks
- **UN OHCHR Berkeley Protocol:** https://www.ohchr.org/en/publications/policy-and-methodological-publications/berkeley-protocol-digital-open-source

**Key ethical principles:**

**1. Do No Harm**
- Minimize harm to investigation subjects, victims, and third parties
- Consider unintended consequences (will publication endanger sources?)
- Protect vulnerable populations (children, trafficking victims)

**2. Respect for Persons**
- Respect privacy and dignity
- Avoid unnecessary intrusion into personal lives
- Consider proportionality (is investigation justified?)

**3. Accuracy & Verification**
- Verify information from multiple sources
- Acknowledge uncertainty and limitations
- Correct errors promptly

**4. Transparency & Accountability**
- Be transparent about methods (to extent consistent with security)
- Accept accountability for mistakes
- Submit to oversight (legal, organizational, public)

**5. Public Interest**
- Ensure investigation serves legitimate purpose
- Weigh public interest against individual privacy
- Avoid investigations for prurient or malicious purposes

### Ethical Decision-Making Framework

**When facing ethical dilemma:**

```markdown
# Ethical Decision-Making Template

**Dilemma:** [Describe the ethical issue]

Example: "Subject's social media post suggests suicidal ideation. Should I notify authorities, or respect subject's privacy?"

## Step 1: Identify Stakeholders
- Subject (privacy, safety)
- Investigation client (expects results)
- Potential victims (if subject harms self or others)
- Public (if subject is public figure or threat)

## Step 2: Identify Applicable Laws & Regulations
- Mandatory reporting laws (duty to report imminent harm?)
- Privacy laws (GDPR, CCPA)
- Professional ethics codes

## Step 3: Identify Ethical Principles in Tension
- **Respect for privacy** vs. **Duty to protect life (Do No Harm)**
- **Client obligations** vs. **Moral duty to intervene**

## Step 4: Evaluate Options

**Option A: Notify authorities (emergency services, crisis hotline)**
- ✅ Protects life (paramount ethical duty)
- ✅ May be legally required (mandatory reporting)
- ❌ Violates subject's privacy
- ❌ May damage trust if subject learns of report

**Option B: Do nothing, respect privacy**
- ✅ Respects subject's autonomy and privacy
- ❌ Subject may harm self
- ❌ Legal liability if mandatory reporting applies
- ❌ Ethical liability (could have prevented harm)

**Option C: Notify client, escalate decision**
- ✅ Transfers decision to appropriate authority
- ❌ Delays response (may be too slow if imminent)

## Step 5: Decision
**Chosen option:** Option A (notify authorities)

**Justification:** Duty to protect life outweighs privacy concerns when threat is imminent. Consult [[sop-sensitive-crime-intake-escalation]] for procedures.

**Consultation:** Discussed with supervisor [Name], legal counsel [Name]

**Documentation:** Escalation report filed, reference ESC-2025-1005-001
```

### Avoiding Conflicts of Interest

**Disclose and avoid conflicts:**

**Financial conflicts:**
- ❌ Investigating competitor for personal financial gain
- ❌ Shorting stock based on non-public negative information from investigation
- ✅ Disclose any financial interest in investigation outcome to client

**Personal conflicts:**
- ❌ Investigating ex-spouse, romantic partner, or family member
- ❌ Investigating close friend or personal enemy
- ✅ Recuse yourself if personal relationship creates bias

**Professional conflicts:**
- ❌ Investigating current or former client without conflict waiver
- ❌ Representing both sides of dispute
- ✅ Maintain independence from investigation subject

---

## Escalation & Safeguarding

### Mandatory Escalation Triggers

**Immediately escalate to appropriate authority if you discover:**

**1. Child Sexual Abuse Material (CSAM)**
- Report to: NCMEC CyberTipline (US), IWF (UK), INHOPE (EU)
- Timeframe: Immediate (within 1 hour)
- **DO NOT** download or possess CSAM
- See: [[sop-sensitive-crime-intake-escalation]]

**2. Imminent Threat to Life**
- Report to: Emergency services (911, 999, 112)
- Timeframe: Immediate
- Examples: Suicide threat, kidnapping, active violence
- See: [[sop-sensitive-crime-intake-escalation]]

**3. Terrorism / National Security**
- Report to: FBI (US), MI5 (UK), national authorities
- Timeframe: Immediate (within 1 hour for imminent threats)
- See: [[sop-sensitive-crime-intake-escalation]]

**4. Human Trafficking**
- Report to: National Human Trafficking Hotline (US: 1-888-373-7888), Modern Slavery Helpline (UK)
- Timeframe: Within 24 hours
- See: [[sop-sensitive-crime-intake-escalation]]

**5. Serious Crime (Non-Imminent)**
- Report to: Law enforcement, internal legal/compliance
- Timeframe: Within 72 hours
- Examples: Large-scale fraud, organized crime, cybercrime

**Legal obligations:**
- **US:** Federal law (18 U.S.C. § 2258A) requires CSAM reporting
- **UK:** Modern Slavery Act 2015 requires trafficking reporting
- **Professional duty:** Attorney-client privilege may apply, consult counsel

---

## Legal Compliance Checklist

### Pre-Investigation Checklist

**Legal Basis:**
- [ ] Legal authority established (contract, legal obligation, public interest, vital interests, legitimate interest, consent)
- [ ] Authority documented in writing (client contract, engagement letter, court order)
- [ ] Scope of investigation defined (subjects, purpose, duration, permitted actions)
- [ ] Jurisdictional analysis completed (identify applicable laws)

**Privacy & Data Protection:**
- [ ] GDPR compliance assessed (if EU subjects involved)
- [ ] CCPA compliance assessed (if California residents involved)
- [ ] Data Protection Impact Assessment (DPIA) completed (if high-risk processing)
- [ ] Data Processing Agreement (DPA) in place (if processing on behalf of client)
- [ ] Privacy notice prepared (if direct interaction with subjects required)

**Prohibited Actions Review:**
- [ ] Confirmed NO unauthorized access (hacking, password cracking)
- [ ] Confirmed NO social engineering or pretexting
- [ ] Confirmed NO purchase of illegally obtained data
- [ ] Confirmed NO entrapment or inducement
- [ ] Confirmed NO harassment, stalking, or intimidation

**Ethical Review:**
- [ ] Proportionality assessed (privacy intrusion justified by investigation purpose?)
- [ ] Public interest considered (does investigation serve legitimate purpose?)
- [ ] Conflicts of interest identified and disclosed
- [ ] Vulnerable populations considered (children, trafficking victims, etc.)

### During Investigation Checklist

**Data Minimization:**
- [ ] Collecting only data necessary to answer PIRs
- [ ] NOT collecting sensitive data (health, religion, sexual orientation) unless essential
- [ ] NOT creating excessive dossiers beyond scope

**Evidence Integrity:**
- [ ] Cryptographic hashes calculated for all evidence (SHA-256)
- [ ] Chain of custody documented
- [ ] Evidence stored securely (encrypted, access-controlled)
- [ ] Metadata preserved (timestamps, URLs, sources)

**OPSEC & Legal Compliance:**
- [ ] No terms of service violations (respecting platform rules)
- [ ] No exceeding authorized access (CFAA compliance)
- [ ] Research personas do not impersonate real individuals
- [ ] No direct engagement with subjects without authorization

**Escalation Monitoring:**
- [ ] Monitoring for escalation triggers (CSAM, imminent harm, terrorism, trafficking)
- [ ] Escalation contacts identified (NCMEC, FBI, local authorities)
- [ ] Escalation procedures reviewed: [[sop-sensitive-crime-intake-escalation]]

### Post-Investigation Checklist

**Deliverables & Reporting:**
- [ ] Final report completed per client requirements
- [ ] Evidence appendix with hashes and chain of custody
- [ ] Legal disclaimers included (attorney work product, sources and methods)
- [ ] Recommendations provided (next steps, further investigation)

**Data Retention:**
- [ ] Retention schedule determined (client deliverables, working files)
- [ ] Deletion dates set for temporary data
- [ ] Legal hold checked (is data subject to preservation order?)
- [ ] Data retention policy documented

**Data Subject Rights:**
- [ ] DSAR (Data Subject Access Request) response plan in place
- [ ] Data subject rights notification sent (if required by GDPR)
- [ ] Mechanism for rectification, erasure, or objection established

**Compliance Documentation:**
- [ ] Legal compliance log completed (authority, jurisdiction, prohibited actions avoided)
- [ ] Ethical decision-making documented (if dilemmas encountered)
- [ ] Supervisor review completed
- [ ] Client acceptance obtained

---

## Appendix

### Relevant Legal Citations

**United States:**
- **CFAA:** 18 U.S.C. § 1030 (Computer Fraud and Abuse Act)
- **ECPA:** 18 U.S.C. § 2510 (Electronic Communications Privacy Act)
- **SCA:** 18 U.S.C. § 2701 (Stored Communications Act)
- **CSAM Reporting:** 18 U.S.C. § 2258A
- **CCPA:** California Civil Code § 1798.100

**European Union:**
- **GDPR:** Regulation (EU) 2016/679
- **ePrivacy Directive:** Directive 2002/58/EC

**United Kingdom:**
- **Data Protection Act 2018**
- **Computer Misuse Act 1990**
- **Modern Slavery Act 2015**

### DPIA (Data Protection Impact Assessment) Template

```markdown
# Data Protection Impact Assessment (DPIA)

**Case ID:** CASE-2025-1005-001
**Date:** 2025-10-05
**Conducted by:** [Your Name]

## 1. Description of Processing

**Purpose:** [e.g., Due diligence investigation for acquisition]
**Subjects:** [e.g., Company executives, 10-15 individuals]
**Data categories:** [e.g., Name, employment history, business affiliations, public social media posts]
**Processing operations:** [e.g., Collection from public sources, analysis, reporting to client]

## 2. Necessity & Proportionality

**Is processing necessary?** Yes - required for client due diligence per contract
**Is scope proportionate?** Yes - limited to professional background, no personal/sensitive data
**Less intrusive alternatives?** No - public records insufficient, OSINT necessary

## 3. Risks to Data Subjects

| Risk | Likelihood | Severity | Impact |
|------|------------|----------|--------|
| Reputation harm (false information) | Low | Medium | Verify accuracy, allow rectification |
| Privacy intrusion (excessive data) | Medium | Low | Data minimization, limit scope to PIRs |
| Security breach (data leaked) | Low | High | Encryption, access controls |

## 4. Measures to Address Risks

- ✅ Data minimization (collect only necessary data)
- ✅ Accuracy verification (multi-source corroboration)
- ✅ Security measures (encryption, access controls)
- ✅ Retention limits (delete after case closure + 90 days)
- ✅ Subject rights (mechanism for rectification, erasure)

## 5. Consultation

- Legal counsel: [Name, consulted 2025-10-05]
- Data Protection Officer: [Name, consulted 2025-10-05]
- Supervisor: [Name, approved 2025-10-05]

## 6. Conclusion

**Risk level:** LOW
**Processing approved:** YES
**Conditions:** Adhere to data minimization, verify accuracy, secure storage, delete per retention schedule

**Approved by:** [DPO/Supervisor Name]
**Date:** 2025-10-05
```

### Resources & References

**Legal Frameworks:**
- GDPR Full Text: https://gdpr-info.eu/
- CCPA Full Text: https://oag.ca.gov/privacy/ccpa
- CFAA Guide: https://www.justice.gov/criminal-ccips/ccmanual

**Ethics Guides:**
- Bellingcat Digital Investigations Ethics: https://bellingcat.gitbook.io/toolkit/resources/guides-and-handbooks
- Berkeley Protocol (UN OHCHR): https://www.ohchr.org/en/publications/policy-and-methodological-publications/berkeley-protocol-digital-open-source

**Mandatory Reporting:**
- NCMEC CyberTipline: https://report.cybertip.org/
- FBI Tips: https://tips.fbi.gov/
- National Human Trafficking Hotline: 1-888-373-7888

---

**Version:** 2.0
**Last Updated:** 2025-10-05
**Review Cycle:** Yearly
**Next Review:** 2025-11-05

---

**Related SOPs:**
[[sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] | [[sop-opsec-plan|OPSEC Planning]] | [[sop-collection-log|Collection Log]] | [[sop-reporting-packaging-disclosure|Reporting & Disclosure]] | [[../OSINT-Index|OSINT Index]]
