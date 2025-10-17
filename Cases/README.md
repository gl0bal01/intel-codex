---
title: "Investigation Cases"
description: "Complete OSINT investigation workflows: case templates, student exercises & examples. Learn evidence collection, profiling & reporting with hands-on practice."
---

# Investigation Cases

This directory contains investigation case files demonstrating complete OSINT investigation workflows from intake to reporting.

## ⚠️ STUDENT SAFETY & LEGAL WARNINGS

**BEFORE YOU START ANY INVESTIGATION - READ THIS CAREFULLY:**

### Legal Requirements ✋

- ✅ **Get written authorization** from instructor/supervisor BEFORE starting
- ✅ **Only use publicly available information** (no hacking, no unauthorized access)
- ✅ **Use fictional/dummy data** for practice exercises
- ❌ **NEVER attempt to hack, access, or "test" systems** without explicit written permission
- ❌ **NEVER contact subjects directly** (no social engineering, no pretexting)
- ❌ **NEVER use information for personal purposes** or gain

### Ethical Boundaries 🛑

- ✅ Report illegal content (CSAM, violence, threats) to authorities immediately
- ✅ Respect privacy and data protection laws (GDPR, CCPA, etc.)
- ✅ Maintain confidentiality of case information
- ❌ **NEVER investigate real people without proper authorization**
- ❌ **NEVER share case data** outside your authorized team/class
- ❌ **NEVER investigate friends, family, classmates, or ex-partners**

### Common Student Mistakes to Avoid 🚨

1. **Don't investigate friends/family** - Serious ethical violation, potential legal issues
2. **Don't use personal social media accounts** - OPSEC failure, compromises investigation
3. **Don't skip documentation** - Evidence without proper logging is inadmissible
4. **Don't assume data is accurate** - Always verify from multiple sources
5. **Don't work alone on sensitive cases** - Use buddy system, debrief with instructor
6. **Don't let curiosity override ethics** - Just because you *can* doesn't mean you *should*

**IF IN DOUBT, ASK YOUR INSTRUCTOR FIRST. IT'S BETTER TO ASK THAN TO VIOLATE LAW/ETHICS.**

---

## Purpose

**Cases** provide end-to-end investigation examples showing:
- Proper case structure and organization
- Evidence collection and chain of custody
- Entity profiling and link analysis
- Timeline reconstruction
- Final reporting and disclosure

## 🎓 Quick Start Guide for Students

### New to OSINT Investigations? Start Here!

**Step 1: Learn the Basics (1-2 hours)**
1. Read [Legal & Ethics SOP](../Investigations/Techniques/sop-legal-ethics.md) - **MANDATORY**
2. Review [OPSEC Planning](../Investigations/Techniques/sop-opsec-plan.md) - Protect yourself
3. Study the [Glossary](Glossary.md) - Learn key terminology
4. Review the [Investigation Workflow Diagram](Investigation-Workflow.md)

**Step 2: Review an Example (2-3 hours)**
1. Open [2025-001-Example-Investigation](2025-001-Example-Investigation/README.md)
2. Read through each file to understand the structure
3. Note how evidence is documented and organized
4. Study the subject profiling techniques used

**Step 3: Practice with Exercises (3-5 hours each)**
1. Start with [Exercise 01: Username Investigation](Student-Exercises/Exercise-01-Username-Investigation/)
2. Progress to [Exercise 02: Domain Analysis](Student-Exercises/Exercise-02-Domain-Analysis/)
3. Complete [Exercise 03: Social Media Timeline](Student-Exercises/Exercise-03-Social-Media-Timeline/)

**Step 4: Your First Real Case (8-12 hours)**
1. Get written authorization from your instructor
2. Copy the [Case-Template](Case-Template/) folder
3. Fill out each section step-by-step
4. Use the [Case Completion Checklist](Case-Template/Case-Completion-Checklist.md)
5. Submit for review

### Time Estimates by Difficulty Level

| Level | Duration | Best For | Example |
|-------|----------|----------|---------|
| 📗 **Beginner** | 8-12 hours | First investigation | Single username across 2-3 platforms |
| 📙 **Intermediate** | 15-25 hours | Building skills | Multi-platform investigation with timeline |
| 📕 **Advanced** | 30-50+ hours | Experienced students | Complex case with blockchain/infrastructure |

### Learning Path Recommendation

```
Week 1: Theory + Example Review
  ├─ Read all SOPs (Legal, OPSEC, Collection)
  ├─ Study 2025-001-Example-Investigation
  └─ Complete Glossary review

Week 2-3: Guided Exercises
  ├─ Exercise 01 (Username Investigation)
  ├─ Exercise 02 (Domain Analysis)
  └─ Exercise 03 (Social Media Timeline)

Week 4-6: First Independent Case
  ├─ Get authorization
  ├─ Select subject (with instructor approval)
  ├─ Complete investigation
  └─ Submit final report
```

---

## Directory Structure

```
Cases/
├── README.md                          # This file
├── Glossary.md                        # OSINT terminology definitions
├── Investigation-Workflow.md          # Visual workflow guide
├── Case-Template/                     # Empty case template for new investigations
│   └── Case-Completion-Checklist.md   # How to know when you're done
├── Student-Exercises/                 # Hands-on practice assignments
│   ├── Exercise-01-Username-Investigation/
│   ├── Exercise-02-Domain-Analysis/
│   └── Exercise-03-Social-Media-Timeline/
└── [YYYY-NNN-Case-Name]/             # Individual case folders
    ├── README.md                      # Case overview and quick links
    ├── 00-Case-Overview.md            # Detailed case summary
    ├── 01-Subject-Profiles.md         # Entity dossiers
    ├── 02-Collection-Log.md           # Evidence tracking
    ├── 03-Evidence/                   # All collected evidence
    ├── 04-Reports/                    # Investigation reports
    └── 05-Admin/                      # Administrative files
```

## Available Cases

### Example Cases (Dummy Data)

- 📕 **[2025-001-Example-Investigation](2025-001-Example-Investigation/README.md)** - Social media fraud / cryptocurrency scam investigation
  - **Difficulty:** Advanced (comprehensive example)
  - **Type:** Social media fraud, financial crime
  - **Demonstrates:** Platform OSINT, blockchain analysis, multi-source evidence collection
  - **Best For:** Reference material, understanding complete case structure
  - **Time to Review:** 2-3 hours

### Student Practice Exercises

- 📗 **[Exercise-01-Username-Investigation](Student-Exercises/Exercise-01-Username-Investigation/)** - Track a username across platforms
  - **Difficulty:** Beginner
  - **Time:** 3-5 hours
  - **Skills:** Username enumeration, platform identification, basic profiling

- 📗 **[Exercise-02-Domain-Analysis](Student-Exercises/Exercise-02-Domain-Analysis/)** - Investigate a suspicious domain
  - **Difficulty:** Beginner
  - **Time:** 3-5 hours
  - **Skills:** WHOIS lookups, DNS analysis, SSL certificate investigation

- 📙 **[Exercise-03-Social-Media-Timeline](Student-Exercises/Exercise-03-Social-Media-Timeline/)** - Reconstruct timeline from social media
  - **Difficulty:** Intermediate
  - **Time:** 5-8 hours
  - **Skills:** Timeline analysis, content correlation, evidence documentation

### Templates

- **[Case-Template](Case-Template/README.md)** - Empty case structure for starting new investigations
  - Includes [Case Completion Checklist](Case-Template/Case-Completion-Checklist.md)
  - Contains blank Subject Profiles template with prompts for entity profiling

## Starting a New Investigation

### 1. Review Prerequisites

Before starting any investigation:
1. Read [Legal & Ethics SOP](../Investigations/Techniques/sop-legal-ethics.md) - **REQUIRED**
2. Review [OPSEC Planning](../Investigations/Techniques/sop-opsec-plan.md)
3. Obtain proper authorization
4. Set up isolated investigation environment

### 2. Create Case Folder

```bash
# Copy template structure
cp -r Cases/Case-Template Cases/YYYY-NNN-Case-Name

# Example: 2025-002-Domain-Investigation
cp -r Cases/Case-Template Cases/2025-002-Domain-Investigation
```

### 3. Complete Case Files

Follow this workflow:

1. **00-Case-Overview.md** - Document case details, scope, objectives
2. **01-Subject-Profiles.md** - Build entity dossiers using [Entity Dossier SOP](../Investigations/Techniques/sop-entity-dossier.md)
3. **02-Collection-Log.md** - Track all evidence using [Collection Log SOP](../Investigations/Techniques/sop-collection-log.md)
4. **03-Evidence/** - Store all collected materials with SHA-256 hashes
5. **04-Reports/** - Compile findings using [Reporting SOP](../Investigations/Techniques/sop-reporting-packaging-disclosure.md)
6. **05-Admin/** - Maintain authorization, chain of custody, case notes

### 4. Apply Relevant SOPs

Choose platform-specific SOPs based on investigation type:
- [Twitter/X OSINT](../Investigations/Platforms/sop-platform-twitter-x.md)
- [Telegram OSINT](../Investigations/Platforms/sop-platform-telegram.md)
- [Instagram OSINT](../Investigations/Platforms/sop-platform-instagram.md)
- [Web/DNS/WHOIS](../Investigations/Techniques/sop-web-dns-whois-osint.md)
- [Financial/Crypto](../Investigations/Techniques/sop-financial-aml-osint.md)
- [Image/Video Analysis](../Investigations/Techniques/sop-image-video-osint.md)

## Case Naming Convention

**Format:** `YYYY-NNN-Brief-Description`

- **YYYY** - Year (e.g., 2025)
- **NNN** - Sequential case number (001, 002, 003...)
- **Brief-Description** - Short kebab-case description (e.g., Domain-Investigation)

**Examples:**
- `2025-001-Example-Investigation`
- `2025-002-Twitter-Impersonation`
- `2025-003-Phishing-Domain-Analysis`

## Case Status Indicators

Use these status indicators in case README files:

- 🟢 **Active** - Investigation in progress
- 🟡 **On Hold** - Paused pending additional information
- 🔴 **Closed** - Investigation complete
- 📚 **Example** - Training/demonstration case (dummy data)

## Evidence Management

### Best Practices

1. **Immediate Hashing** - Calculate SHA-256 for all collected evidence
2. **Multiple Formats** - Capture HTML, screenshots, and WARC archives
3. **Chain of Custody** - Document every transfer and access
4. **Secure Storage** - Use encrypted volumes (AES-256)
5. **Regular Verification** - Check file integrity weekly

### Evidence Organization

```
03-Evidence/
├── screenshots/           # All screenshots (organized by source)
├── domains/              # WHOIS, DNS, certificate data
├── social-media/         # Platform exports and archives
├── blockchain/           # Transaction data, wallet info
├── images/               # Photos, profile pictures (with EXIF)
├── documents/            # PDFs, emails, text files
├── network/              # Network scan results, passive DNS
└── victim-reports/       # Victim statements and communications
```

## Legal & Ethical Considerations

**CRITICAL REMINDERS:**

- ✅ Only investigate with proper authorization
- ✅ Stay within legal boundaries (no unauthorized access)
- ✅ Respect Terms of Service (document violations if necessary)
- ✅ Maintain chain of custody for legal admissibility
- ✅ Escalate sensitive content immediately (CSAM, violence)
- ❌ Never fabricate evidence
- ❌ Never use obtained information for personal gain
- ❌ Never share case data without authorization

See [Legal & Ethics SOP](../Investigations/Techniques/sop-legal-ethics.md) for complete guidelines.

## Reporting & Disclosure

When investigation concludes:

1. **Internal Report** - Summary for organization/client
2. **Evidence Package** - Organized evidence with chain of custody
3. **Law Enforcement Referral** - If criminal activity identified (see [Escalation SOP](../Investigations/Techniques/sop-sensitive-crime-intake-escalation.md))
4. **Platform Reporting** - ToS violations reported to platforms

Follow [Reporting & Disclosure SOP](../Investigations/Techniques/sop-reporting-packaging-disclosure.md).

## Related Resources

### Investigation Techniques
- [Legal & Ethics](../Investigations/Techniques/sop-legal-ethics.md)
- [OPSEC Planning](../Investigations/Techniques/sop-opsec-plan.md)
- [Entity Dossier Building](../Investigations/Techniques/sop-entity-dossier.md)
- [Collection Logging](../Investigations/Techniques/sop-collection-log.md)
- [Reporting & Disclosure](../Investigations/Techniques/sop-reporting-packaging-disclosure.md)

### Platform SOPs
- [Platforms Index](../Investigations/Platforms/Platforms-Index.md)
- [Techniques Index](../Investigations/Techniques/Techniques-Index.md)

---

**Last Updated:** 2025-10-12
**Maintainer:** gl0bal01
