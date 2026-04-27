---
type: sop
title: Legal, Ethics & Data Governance for OSINT
description: "Essential legal & ethical boundaries for OSINT: GDPR/CPRA/state-privacy compliance, authorization, cross-border transfer, sensitive-data handling & responsible disclosure."
created: 2025-10-05
updated: 2026-04-26
template_version: 2026-04-26
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
- **CFAA (18 U.S.C. § 1030):** Computer Fraud and Abuse Act — prohibits unauthorized access. Scope narrowed by *Van Buren v. United States* (2021) and *hiQ Labs v. LinkedIn* (9th Cir. 2022).
- **ECPA (18 U.S.C. § 2510):** Electronic Communications Privacy Act — wiretapping, stored communications.
- **SCA (18 U.S.C. § 2701):** Stored Communications Act — unauthorized access to stored electronic communications.
- **DMCA § 1201 (17 U.S.C. § 1201):** Anti-circumvention of technological protection measures. Triennial Librarian-of-Congress rulemaking sets security-research exemptions; **most recent cycle was 2024** (37 CFR 201.40(b)(7)) [verify 2026-04-26].
- **CSAM reporting (18 U.S.C. § 2258A):** Mandatory NCMEC CyberTipline reporting by US-provider electronic-communication services. REPORT Act (Pub. L. 118-59, May 2024) expanded reporting categories to include enticement and trafficking [verify 2026-04-26].
- **State privacy laws:** California **CCPA** (2018) as amended by **CPRA** (operative Jan 1, 2023; CPPA enforcement); **VCDPA** (Virginia, Jan 2023), **CPA** (Colorado, July 2023), **CTDPA** (Connecticut, July 2023), **UCPA** (Utah, Dec 2023). ~15+ additional state comprehensive privacy laws active or imminent through 2025–2026 (TX, OR, MT, IA, DE, NJ, NH, KY, IN, TN, MD, MN, RI, etc.) — verify the current list at iapp.org or NCSL before scoping a multi-state matter [verify 2026-04-26].

**European Union:**
- **GDPR (Regulation (EU) 2016/679):** General Data Protection Regulation — data processing, privacy rights. Article 6 lawful basis, Article 9 special-category data, Article 14(5)(b) OSINT-relevant notification carve-out.
- **ePrivacy Directive (2002/58/EC):** Cookie consent, electronic communications privacy. (ePrivacy Regulation proposal still pending as of 2026 [verify 2026-04-26].)
- **Cybercrime Directive (2013/40/EU):** Harmonizes member-state criminal law on attacks against information systems (analogue to CFAA).
- **NIS2 Directive ((EU) 2022/2555):** Network and information security; member-state transposition deadline October 17, 2024.
- **DORA (Digital Operational Resilience Act, (EU) 2022/2554):** Applies to financial-sector entities from January 17, 2025.
- **EU AI Act (Regulation (EU) 2024/1689):** In force August 1, 2024. Prohibited-practices ban from February 2, 2025; GPAI obligations August 2, 2025; full applicability August 2, 2026 [verify 2026-04-26]. Article 50 transparency obligations are relevant to synthetic-media OSINT.
- **e-Evidence Regulation ((EU) 2023/1543) and Directive ((EU) 2023/1544):** Cross-border production/preservation orders for electronic evidence; staged application from August 18, 2026 [verify 2026-04-26].
- **EU–US Data Privacy Framework (DPF):** European Commission adequacy decision adopted July 10, 2023, replacing the Schrems-II-invalidated Privacy Shield. Self-certification via dataprivacyframework.gov; subject to ongoing CJEU review.

**United Kingdom:**
- **UK GDPR + Data Protection Act 2018:** Domestic implementation of GDPR (post-Brexit). Data (Use and Access) Bill / DPDI reform debate ongoing through 2024–2026 [verify 2026-04-26].
- **Computer Misuse Act 1990:** § 1 unauthorized access, § 3 unauthorized modification, § 3ZA serious damage to systems. Home Office launched a CMA reform consultation in 2023; status of any successor legislation is unsettled [verify 2026-04-26].
- **Investigatory Powers Act 2016:** Surveillance and interception. Amended by Investigatory Powers (Amendment) Act 2024.
- **Modern Slavery Act 2015:** § 52 duty to notify the Single Competent Authority (NRM referrals); § 54 supply-chain transparency statements (different obligation — do not conflate).
- **Online Safety Act 2023:** User-to-user / search-service duties; Ofcom enforcement phasing in through 2025–2026 [verify 2026-04-26].

**Australia:**
- **Privacy Act 1988:** Australian Privacy Principles (APPs); reform tranches in progress 2024–2026 (statutory tort for serious invasion of privacy; mandatory data-breach uplift) [verify 2026-04-26].
- **Cybercrime Act 2001:** Unauthorized access, data interference (Criminal Code Part 10.7).
- **Surveillance Devices Act:** Federal Surveillance Devices Act 2004 + state/territory equivalents — recording-consent rules vary materially by state.

**International:**
- **Budapest Convention on Cybercrime (CETS 185, 2001) + Second Additional Protocol (CETS 224, 2022):** International cooperation on cybercrime; Second Protocol covers direct cooperation with service providers and joint investigations.
- **Council of Europe Convention 108+ (CETS 223, modernized 2018):** Open for signature; ratification status varies by state [verify 2026-04-26].
- **UN OHCHR Berkeley Protocol on Digital Open Source Investigations (2022):** Methodology benchmark for human-rights and accountability OSINT.
- **UN Guiding Principles on Business & Human Rights:** Corporate responsibility for human rights.

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
- Organizations outside EU that monitor behavior of EU residents (Article 3(2) — explicitly captures behavioural OSINT against EU subjects)

**Example:** US-based OSINT firm investigating EU resident for US client must comply with GDPR. Where personal data is transferred from the EU to the US, a valid Chapter V transfer mechanism is required (DPF self-certification, SCCs + Transfer Impact Assessment, or Article 49 derogation).

**CCPA / CPRA applies to:**
- For-profit businesses doing business in California that meet at least one of: (a) annual gross revenue > $25M (adjusted), (b) buy/sell/share PI of ≥ 100,000 consumers or households, or (c) derive ≥ 50% of revenue from selling/sharing PI [verify 2026-04-26 — thresholds adjusted by CPPA regulations]
- Collecting personal information of California residents
- "Sensitive Personal Information" (SPI) under CPRA carries additional limit-of-use obligations

### Cross-Border Transfer (EU → Third Countries)

**Post-Schrems II (2020) baseline:** Privacy Shield invalidated; transfers to the US require an Article 46 transfer mechanism + Transfer Impact Assessment.

**Current valid mechanisms (2026):**
- **EU–US Data Privacy Framework** (adequacy decision July 10, 2023) for self-certified US recipients — verify recipient on the official DPF list before transferring.
- **Standard Contractual Clauses** (2021/914) + Transfer Impact Assessment — required for non-DPF US recipients and most other third countries.
- **Binding Corporate Rules** (Article 47) — intra-group transfers.
- **Article 49 derogations** (consent, contract necessity, important public interest, legal claims, vital interests) — narrow, occasional use only; not a substitute for a transfer mechanism.

**UK transfers:** Use the UK International Data Transfer Agreement (IDTA) or the UK Addendum to the EU SCCs; UK extension to the DPF was implemented October 12, 2023 [verify 2026-04-26].

**Government access requests (CLOUD Act, 2018):** US providers may be compelled to produce stored data regardless of location; UK 2019 and Australia 2021 executive agreements operate as bilateral exceptions [verify 2026-04-26 — Canada and EU agreements still in negotiation].

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
- **US:** CFAA violation (18 U.S.C. § 1030) — penalties scale with conduct (1–10 years for first-offense unauthorized access; 5–20 years where damage, fraud, or critical-infrastructure elements apply) [verify 2026-04-26].
- **UK:** Computer Misuse Act 1990 § 1 (basic unauthorized access) — up to 2 years; § 3 / § 3ZA (modification / serious damage) — up to 10 years / life.
- **EU:** Member-state implementation of Cybercrime Directive 2013/40/EU; minimum-maximum sentences vary by state.

**Case law:**
- ***Van Buren v. United States*, 593 U.S. 374 (2021):** "Exceeds authorized access" under CFAA means accessing files/folders/databases the user is forbidden from accessing — *not* misusing data the user is otherwise permitted to view. Improper-purpose-only conduct on accessible data is generally outside CFAA after Van Buren.
- ***hiQ Labs, Inc. v. LinkedIn Corp.*, 31 F.4th 1180 (9th Cir. 2022) (on remand post-Van Buren GVR):** Scraping publicly accessible website data without authentication is unlikely to violate CFAA's "without authorization" prong. The case ultimately settled in 2022 with hiQ liable on contract / DMCA-adjacent grounds — the CFAA holding did *not* immunize ToS violations or contract claims [verify 2026-04-26].
- ***Meta v. BrandTotal* (N.D. Cal.) and other 2023–2024 scraping cases:** Show continued circuit/district friction over ToS-only violations; **assume the safest jurisdiction** when scoping cross-border scraping.
- **Caution:** CFAA case law and DOJ charging policy (2022 charging-policy memo declining to prosecute good-faith security research) continue to evolve — consult counsel.

**Permitted:**
- ✅ Accessing publicly available information (no authentication required)
- ✅ Using publicly disclosed credentials only where lawful in the relevant jurisdiction *and* not contractually prohibited (default-credential discovery in your own / authorized lab is fine; reusing leaked credentials against a third-party service is not)
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

### CCPA / CPRA Compliance (California Residents)

CCPA was amended by the California Privacy Rights Act (CPRA, operative January 1, 2023). The California Privacy Protection Agency (CPPA) is the principal enforcement authority alongside the Attorney General. References below cite the post-CPRA Cal. Civ. Code.

**Consumer Rights:**

**1. Right to Know (§ 1798.100, § 1798.110, § 1798.115)**
- Categories of personal information collected
- Sources, purposes, third parties with access

**2. Right to Delete (§ 1798.105)**
- Request deletion of personal information
- **Exceptions:** Legal compliance, security, legal claims, free speech / public interest

**3. Right to Correct (§ 1798.106)** *(added by CPRA)*
- Request correction of inaccurate personal information

**4. Right to Opt-Out of Sale OR Sharing (§ 1798.120)**
- Prohibit sale *and* cross-context behavioural advertising "sharing" — CPRA broadened the opt-out beyond strict "sale"
- **Note:** OSINT investigations typically do NOT constitute "sale" or "sharing", but document the basis

**5. Right to Limit Use of Sensitive Personal Information (§ 1798.121)** *(added by CPRA)*
- SPI categories include geolocation, biometric, health, sex life/orientation, racial/ethnic origin, religious beliefs, contents of non-recipient communications, government-ID numbers, financial-account credentials

**6. Right to Non-Discrimination (§ 1798.125)**
- Cannot discriminate for exercising rights

**Definitions:**
- **Personal Information:** Information that identifies, relates to, describes, or could reasonably be linked to a California resident or household
- **Sale:** Disclosure for monetary or other valuable consideration (broadly defined)
- **Sharing:** Disclosure for cross-context behavioural advertising, even without consideration

**Other state regimes worth scoping (non-exhaustive, 2026):** Virginia (VCDPA), Colorado (CPA), Connecticut (CTDPA), Utah (UCPA), Texas (TDPSA), Oregon (OCPA), Montana (MCDPA), Iowa, Delaware, New Jersey, New Hampshire, Tennessee, Indiana, Kentucky, Maryland, Minnesota, Rhode Island [verify 2026-04-26 — confirm effective dates and applicability against current iapp.org / NCSL trackers].

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
- Report to: **NCMEC CyberTipline** (US, https://report.cybertip.org/), **Internet Watch Foundation** (UK, https://report.iwf.org.uk/), **INHOPE** national member hotline (international, https://inhope.org/)
- Timeframe: Immediate
- **DO NOT** download, copy, hash-locally, or otherwise possess suspected CSAM. US providers must preserve and transmit per 18 U.S.C. § 2258A; non-providers must avoid possession entirely
- See: [[sop-sensitive-crime-intake-escalation]]

**2. Imminent Threat to Life**
- Report to: Emergency services (911 US/CA, 999 UK, 112 EU/AU)
- Timeframe: Immediate
- Examples: Suicide threat, kidnapping, active violence
- See: [[sop-sensitive-crime-intake-escalation]]

**3. Terrorism / National Security**
- Report to: FBI (US, https://tips.fbi.gov/), MI5 (UK, https://www.mi5.gov.uk/contact-us), national authorities elsewhere; Europol J-CAT for cross-border cyber-enabled terrorism [verify 2026-04-26]
- Timeframe: Immediate for imminent threats
- See: [[sop-sensitive-crime-intake-escalation]]

**4. Human Trafficking**
- Report to: **National Human Trafficking Hotline** (US: 1-888-373-7888, https://humantraffickinghotline.org/), **Modern Slavery & Exploitation Helpline** (UK: 08000 121 700, https://www.modernslaveryhelpline.org/)
- Timeframe: Within 24 hours; immediate where there is an imminent risk to a victim
- See: [[sop-sensitive-crime-intake-escalation]]

**5. Serious Crime (Non-Imminent)**
- Report to: Law enforcement, internal legal/compliance
- Timeframe: Within 72 hours
- Examples: Large-scale fraud, organized crime, cybercrime

**Legal obligations:**
- **US — CSAM:** 18 U.S.C. § 2258A imposes reporting on US-provider electronic-communication services. Non-providers (researchers, investigators) have no affirmative reporting duty under § 2258A but must avoid possession; report via CyberTipline as a citizen reporter. The **REPORT Act** (Pub. L. 118-59, May 7, 2024) expanded provider reporting categories to include online enticement and child sex-trafficking offences and extended NCMEC retention periods [verify 2026-04-26].
- **UK — modern slavery:** Modern Slavery Act 2015 § 52 requires "specified public authorities" (police, local authorities, gangmasters licensing) to notify the National Referral Mechanism (NRM); private investigators and most non-statutory bodies do not have a § 52 duty but should refer through the NRM or the Modern Slavery Helpline. (§ 54 transparency-statement duty is unrelated to incident reporting — do not conflate.)
- **EU — CSAM:** Interim Regulation (EU) 2021/1232 permitting voluntary provider scanning expires April 3, 2026; the proposed long-term CSAM Regulation (COM(2022) 209) remains under negotiation [verify 2026-04-26].
- **Professional duty:** Attorney-client and litigation privilege may apply to investigation work product; consult counsel before transmitting privileged material to any third party.

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
- **ECPA:** 18 U.S.C. § 2510 *et seq.* (Electronic Communications Privacy Act)
- **Wiretap Act:** 18 U.S.C. § 2511
- **SCA:** 18 U.S.C. § 2701 *et seq.* (Stored Communications Act)
- **DMCA § 1201:** 17 U.S.C. § 1201 (anti-circumvention; security-research exemption at 37 CFR 201.40(b)(7), 2024 cycle [verify 2026-04-26])
- **CSAM Reporting:** 18 U.S.C. § 2258A; REPORT Act, Pub. L. 118-59 (2024) [verify 2026-04-26]
- **Federal stalking:** 18 U.S.C. § 2261A
- **Wire fraud:** 18 U.S.C. § 1343
- **CCPA / CPRA:** California Civil Code § 1798.100 *et seq.*
- **Bank Secrecy Act / FinCEN AML:** 31 CFR Chapter X (e.g., § 1020.210 — bank AML program)

**European Union:**
- **GDPR:** Regulation (EU) 2016/679
- **ePrivacy Directive:** Directive 2002/58/EC
- **Cybercrime Directive:** Directive 2013/40/EU
- **NIS2 Directive:** Directive (EU) 2022/2555
- **DORA:** Regulation (EU) 2022/2554
- **EU AI Act:** Regulation (EU) 2024/1689
- **e-Evidence:** Regulation (EU) 2023/1543; Directive (EU) 2023/1544

**United Kingdom:**
- **UK GDPR + Data Protection Act 2018**
- **Computer Misuse Act 1990**
- **Investigatory Powers Act 2016** (as amended by the Investigatory Powers (Amendment) Act 2024)
- **Modern Slavery Act 2015** (§ 52 NRM duty; § 54 supply-chain transparency)
- **Online Safety Act 2023**

**International:**
- **Budapest Convention on Cybercrime (CETS 185)** + Second Additional Protocol (CETS 224)
- **Council of Europe Convention 108+ (CETS 223)**

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

**Legal Frameworks (primary text):**
- GDPR full text: https://gdpr-info.eu/ (annotated) / https://eur-lex.europa.eu/eli/reg/2016/679/oj (official)
- EU AI Act: https://eur-lex.europa.eu/eli/reg/2024/1689/oj
- NIS2 Directive: https://eur-lex.europa.eu/eli/dir/2022/2555/oj
- DORA: https://eur-lex.europa.eu/eli/reg/2022/2554/oj
- CCPA / CPRA: https://oag.ca.gov/privacy/ccpa ; CPPA regulations: https://cppa.ca.gov/regulations/
- US-state privacy tracker: https://iapp.org/resources/article/us-state-privacy-legislation-tracker/ [verify 2026-04-26]
- DOJ CFAA / Computer Crime Manual: https://www.justice.gov/criminal/criminal-ccips/ccips-documents-and-reports
- DMCA § 1201 triennial exemptions (Library of Congress): https://www.copyright.gov/1201/
- EU–US Data Privacy Framework: https://www.dataprivacyframework.gov/

**Ethics & Methodology:**
- Bellingcat Toolkit & Guides: https://bellingcat.gitbook.io/toolkit/resources/guides-and-handbooks
- UN OHCHR Berkeley Protocol on Digital Open Source Investigations (2022): https://www.ohchr.org/en/publications/policy-and-methodological-publications/berkeley-protocol-digital-open-source
- ISO/IEC 27037:2012 (digital evidence handling) — purchase via https://www.iso.org/standard/44381.html
- NIST SP 800-86 (forensic guide to incident response): https://csrc.nist.gov/pubs/sp/800/86/final
- Council of Europe Convention 108+ explanatory report: https://www.coe.int/en/web/data-protection/convention108-and-protocol

**Mandatory / Safeguarding Reporting:**
- NCMEC CyberTipline: https://report.cybertip.org/
- FBI Tips: https://tips.fbi.gov/
- Internet Watch Foundation (UK CSAM): https://report.iwf.org.uk/
- INHOPE national hotlines: https://inhope.org/EN/articles/child-helplines
- US National Human Trafficking Hotline: 1-888-373-7888 — https://humantraffickinghotline.org/
- UK Modern Slavery & Exploitation Helpline: 08000 121 700 — https://www.modernslaveryhelpline.org/

---

**Version:** 2.1
**Last Updated:** 2026-04-26
**Review Cycle:** Yearly (with quarterly check on fast-moving items: EU AI Act phase-in, US-state privacy tracker, DMCA § 1201 cycle, REPORT Act guidance)
**Next Review:** 2027-04-26

---

**Related SOPs:**
[[sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]] | [[sop-opsec-plan|OPSEC Planning]] | [[sop-collection-log|Collection Log]] | [[sop-reporting-packaging-disclosure|Reporting & Disclosure]] | [[Techniques-Index|Techniques Index]]
