---
title: "OSINT Investigation Workflow Guide"
description: "Complete OSINT investigation workflow from authorization to closure. Master evidence collection, analysis, reporting with checklists, timelines & best practices."
---

# OSINT Investigation Workflow Guide

**Visual guide to the investigation process from start to finish.**

---

## 📊 Investigation Lifecycle Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    OSINT INVESTIGATION WORKFLOW                  │
└─────────────────────────────────────────────────────────────────┘

Phase 1: PREPARATION (1-2 hours)
    ↓
Phase 2: AUTHORIZATION & SCOPING (30 min - 2 hours)
    ↓
Phase 3: COLLECTION (Hours to Weeks)
    ↓
Phase 4: ANALYSIS & CORRELATION (Hours to Weeks)
    ↓
Phase 5: REPORTING (1-5 hours)
    ↓
Phase 6: CLOSURE & ARCHIVAL (1-2 hours)
```

---

## Phase 1: Preparation 🎯

**Duration:** 1-2 hours (first time), 30 minutes (experienced)

### Checklist:

```
┌─────────────────────────────────────┐
│         PREPARATION PHASE           │
├─────────────────────────────────────┤
│ [ ] Read Legal & Ethics SOP         │
│ [ ] Review OPSEC Planning SOP       │
│ [ ] Set up isolated environment     │
│     ├─ VPN/Tor configured          │
│     ├─ Burner browser profile      │
│     ├─- Encrypted storage ready     │
│     └─- Screenshot tool ready       │
│ [ ] Prepare folder structure        │
│ [ ] Review relevant platform SOPs   │
│ [ ] Understand case requirements    │
└─────────────────────────────────────┘
```

### Setup Your Investigation Environment:

**Tools Needed:**
- VPN or Tor Browser (OPSEC)
- Screenshot tool (Flameshot, Greenshot, built-in)
- Hashing tool (sha256sum, CertUtil on Windows)
- Text editor for notes (Obsidian, Notepad++, VS Code)
- Evidence storage (encrypted volume)

**Folder Structure to Create:**
```
YYYY-NNN-Case-Name/
├── 00-Case-Overview.md
├── 01-Subject-Profiles.md
├── 02-Collection-Log.md
├── 03-Evidence/
│   ├── screenshots/
│   ├── documents/
│   ├── domains/
│   └── social-media/
├── 04-Reports/
└── 05-Admin/
    ├── authorization.pdf
    └── case-notes.md
```

---

## Phase 2: Authorization & Scoping 📋

**Duration:** 30 minutes - 2 hours

### Workflow:

```
┌──────────────────────────────────────────────────────────────┐
│               AUTHORIZATION & SCOPING PHASE                   │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Receive Investigation Request                            │
│           ↓                                                   │
│  2. Review for Legal/Ethical Issues                          │
│           ↓                                                   │
│  3. Obtain Written Authorization ←─────┐                     │
│           ↓                             │                     │
│  4. Define Scope (In/Out of Scope) ────┤ If unclear,        │
│           ↓                             │ clarify with       │
│  5. Identify Platforms & Techniques ────┤ requestor          │
│           ↓                             │                     │
│  6. Set Objectives (3-5 clear goals) ───┘                    │
│           ↓                                                   │
│  7. Document Everything in 00-Case-Overview.md               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Key Questions to Answer:

**Authorization:**
- ✅ Do I have written authorization?
- ✅ Who authorized this investigation?
- ✅ What is the legal basis for this investigation?

**Scope:**
- ✅ What am I authorized to investigate? (Platforms, subjects, timeframes)
- ❌ What is explicitly OUT of scope?
- ⚠️ What requires additional authorization?

**Objectives:**
- What are the 3-5 primary goals?
- What does success look like?
- What deliverables are expected?

### Red Flags - STOP If:
- ❌ No written authorization
- ❌ Request involves illegal activity (hacking, unauthorized access)
- ❌ Investigating friends/family without proper authorization
- ❌ Scope is vague or unlimited
- ❌ Requestor asks you to violate ToS/laws

---

## Phase 3: Collection 📸

**Duration:** Varies (hours to weeks depending on scope)

### Collection Workflow:

```
┌────────────────────────────────────────────────────────────────┐
│                    COLLECTION PHASE                             │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  FOR EACH PIECE OF EVIDENCE:                             │ │
│  ├──────────────────────────────────────────────────────────┤ │
│  │  1. Capture Evidence                                     │ │
│  │     ├─ Screenshot (with timestamp visible)              │ │
│  │     ├─ Save HTML/source (if applicable)                 │ │
│  │     ├─ Save WHOIS/DNS output                            │ │
│  │     └─ Download files (if relevant)                     │ │
│  │              ↓                                            │ │
│  │  2. Calculate SHA-256 Hash                               │ │
│  │     └─ sha256sum filename.png                            │ │
│  │              ↓                                            │ │
│  │  3. Log in Collection Log (02-Collection-Log.md)        │ │
│  │     ├─ Evidence ID (E001, E002...)                      │ │
│  │     ├─ Date/Time collected                              │ │
│  │     ├─ Source URL                                        │ │
│  │     ├─ SHA-256 hash                                      │ │
│  │     ├─ Description                                       │ │
│  │     └─ Collector name                                    │ │
│  │              ↓                                            │ │
│  │  4. Organize in Evidence Folder                          │ │
│  │     └─ 03-Evidence/[category]/filename.png              │ │
│  │              ↓                                            │ │
│  │  5. Add Notes to Case Notes                              │ │
│  │     └─ 05-Admin/case-notes.md                           │ │
│  │              ↓                                            │ │
│  │  REPEAT for next piece of evidence                       │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Evidence Collection Best Practices:

**✅ DO:**
- Screenshot with browser URL bar visible
- Include timestamps in filenames (YYYY-MM-DD format)
- Hash immediately after capture
- Log before moving to next item
- Save multiple formats (screenshot + HTML)
- Verify evidence integrity regularly

**❌ DON'T:**
- Edit or modify evidence
- Delete original files
- Skip hashing
- Delay logging (do it immediately)
- Forget to document source URLs
- Take screenshots with personal account visible

### Platform-Specific Collection:

**Social Media (Twitter, LinkedIn, etc.):**
```
1. Profile page (full view)
2. Bio/About section
3. Profile picture (close-up)
4. Recent posts (5-10 screenshots)
5. Follower/Following counts
6. Account creation date (if visible)
7. Links in bio
```

**Domains (WHOIS/DNS):**
```
1. WHOIS raw output → save to .txt
2. DNS A, MX, TXT, NS records → save to .txt
3. SSL certificate details → screenshot
4. Certificate Transparency logs → screenshot
5. Historical WHOIS → screenshot
```

**Blockchain:**
```
1. Wallet address transactions → screenshot
2. Transaction hashes → save to .txt
3. Blockchain explorer URL → log
4. Transaction graph/visualization → screenshot
```

---

## Phase 4: Analysis & Correlation 🔍

**Duration:** Varies (hours to weeks depending on complexity)

### Analysis Workflow:

```
┌────────────────────────────────────────────────────────────────┐
│                     ANALYSIS PHASE                              │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  STEP 1: Entity Profiling                                      │
│  ├─ Build comprehensive subject profile (01-Subject-Profiles)  │
│  ├─ Document all identifiers (usernames, emails, etc.)        │
│  ├─ Map digital footprint across platforms                     │
│  └─ Assess confidence for each data point                      │
│           ↓                                                     │
│  STEP 2: Cross-Platform Correlation                            │
│  ├─ Verify information across multiple sources                 │
│  ├─ Identify consistencies and discrepancies                   │
│  ├─ Create correlation matrix                                  │
│  └─ Flag contradictions for further investigation              │
│           ↓                                                     │
│  STEP 3: Timeline Reconstruction                               │
│  ├─ Extract all dated events from evidence                     │
│  ├─ Sort chronologically                                       │
│  ├─ Identify patterns and anomalies                            │
│  └─ Assess significance of each event                          │
│           ↓                                                     │
│  STEP 4: Pattern Analysis                                      │
│  ├─ Activity patterns (when, where, how often)                │
│  ├─ Content themes and topics                                  │
│  ├─ Behavioral indicators                                      │
│  └─ Network/relationship mapping                               │
│           ↓                                                     │
│  STEP 5: Risk Assessment                                       │
│  ├─ Identify threat indicators                                 │
│  ├─ Assess overall risk level (Low/Medium/High/Critical)      │
│  ├─ Document intelligence gaps                                 │
│  └─ Recommend next steps                                       │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Confidence Assessment Framework:

| Confidence Level | Criteria | Example |
|-----------------|----------|---------|
| **High** | Verified across 3+ independent sources | Email found in WHOIS, GitHub profile, and LinkedIn |
| **Medium** | Verified across 2 sources | Username on Twitter and Reddit with matching profile pics |
| **Low** | Single source, unverified | Claim made in one tweet, no other evidence |

### Analysis Outputs:

1. **Subject Profile** (01-Subject-Profiles.md)
   - Identity overview
   - Digital footprint summary
   - Behavioral analysis
   - Attribution assessment

2. **Timeline** (in 00-Case-Overview.md)
   - Chronological event list
   - Source citations
   - Significance ratings

3. **Risk Assessment** (in 00-Case-Overview.md)
   - Overall risk level
   - Threat indicators
   - Intelligence gaps
   - Recommendations

---

## Phase 5: Reporting 📝

**Duration:** 1-5 hours depending on complexity

### Reporting Workflow:

```
┌────────────────────────────────────────────────────────────────┐
│                      REPORTING PHASE                            │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  STEP 1: Executive Summary                                      │
│  ├─ Who, what, when, where, why (1-2 paragraphs)              │
│  ├─ Key findings (top 3-5)                                     │
│  ├─ Risk level assessment                                      │
│  └─ High-level recommendations                                 │
│           ↓                                                     │
│  STEP 2: Detailed Findings                                     │
│  ├─ Each finding with supporting evidence                      │
│  ├─ Evidence references (E001, E002, etc.)                     │
│  ├─ Confidence ratings                                         │
│  └─ Analysis and interpretation                                │
│           ↓                                                     │
│  STEP 3: Methodology Section                                   │
│  ├─ Platforms investigated                                     │
│  ├─ Tools used                                                 │
│  ├─ SOPs followed                                              │
│  └─ Limitations acknowledged                                   │
│           ↓                                                     │
│  STEP 4: Recommendations                                       │
│  ├─ Immediate actions                                          │
│  ├─ Long-term recommendations                                  │
│  ├─ Escalation needs (LE referral, platform reporting)        │
│  └─ Follow-up investigation needs                              │
│           ↓                                                     │
│  STEP 5: Evidence Package                                      │
│  ├─ Organize all evidence files                                │
│  ├─ Include evidence manifest (list with hashes)              │
│  ├─ Add chain of custody documentation                         │
│  └─ Create final ZIP/archive                                   │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Report Structure:

**Final Report Format (04-Reports/final-report.md):**

```markdown
# Investigation Report: [Case Name]

## Executive Summary
[1-2 paragraphs: who, what, findings, risk level]

## Case Information
- Case ID: YYYY-NNN
- Investigator: [Name]
- Date Range: [Start - End]
- Authorization: [Reference]

## Objectives
1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

## Methodology
- Platforms: [List]
- Tools: [List]
- SOPs: [List]
- Limitations: [Describe]

## Key Findings

### Finding 1: [Title]
- **Description:** [What you found]
- **Evidence:** E001, E005, E012
- **Confidence:** High
- **Significance:** [Why it matters]

### Finding 2: [Title]
[Repeat structure]

## Timeline of Events
[Chronological table or list]

## Risk Assessment
- **Overall Risk:** Medium
- **Risk Factors:** [List]
- **Mitigation:** [Recommendations]

## Intelligence Gaps
- [Gap 1]
- [Gap 2]

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

## Conclusion
[Final summary paragraph]

---
**Appendices:**
- Appendix A: Evidence Log
- Appendix B: Subject Profiles
- Appendix C: Technical Details
```

---

## Phase 6: Closure & Archival 📦

**Duration:** 1-2 hours

### Closure Checklist:

```
┌────────────────────────────────────────────────────────────────┐
│                  CLOSURE & ARCHIVAL PHASE                       │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [ ] Complete Case Completion Checklist                        │
│      └─ See: Case-Template/Case-Completion-Checklist.md       │
│                                                                 │
│  [ ] Verify Evidence Integrity                                 │
│      ├─ Re-hash all files                                      │
│      ├─ Compare to original hashes                             │
│      └─ Document any discrepancies                             │
│                                                                 │
│  [ ] Finalize Documentation                                    │
│      ├─ Proofread all reports                                  │
│      ├─ Verify all links work                                  │
│      ├─ Update date stamps                                     │
│      └─ Add final status to case files                         │
│                                                                 │
│  [ ] Package Evidence                                          │
│      ├─ Create evidence manifest                               │
│      ├─ Include chain of custody                               │
│      ├─ Add hash file (all hashes in one .txt)                │
│      └─ Create archive (ZIP/7z with encryption)               │
│                                                                 │
│  [ ] Submit Deliverables                                       │
│      ├─ Final report                                           │
│      ├─ Evidence package                                       │
│      ├─ Executive summary (if requested)                       │
│      └─ Any required referrals (LE, platforms)                │
│                                                                 │
│  [ ] Secure Storage                                            │
│      ├─ Archive case files                                     │
│      ├─ Store in encrypted location                            │
│      ├─ Document retention policy                              │
│      └─ Restrict access (need-to-know)                         │
│                                                                 │
│  [ ] Debrief & Lessons Learned                                │
│      ├─ What went well?                                        │
│      ├─ What could be improved?                                │
│      ├─ New techniques learned?                                │
│      └─ Document for future reference                          │
│                                                                 │
│  [ ] Update Case Status                                        │
│      └─ Mark as 🔴 Closed in README.md                        │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

---

## Decision Trees

### Should I Investigate This?

```
                    Investigation Request Received
                              ↓
                   Is there written authorization?
                    ↓                           ↓
                   YES                          NO → STOP - Get authorization first
                    ↓
            Is request legal and ethical?
                    ↓                           ↓
                   YES                          NO → STOP - Decline request
                    ↓
             Is scope clearly defined?
                    ↓                           ↓
                   YES                          NO → Clarify scope with requestor
                    ↓
          Do I have skills/tools needed?
                    ↓                           ↓
                   YES                          NO → Seek training or refer to specialist
                    ↓
                PROCEED with investigation
```

### What If I Find Illegal Content?

```
                Encountered Illegal Content
                         ↓
              What type of content?
                         ↓
        ┌────────────────┴────────────────┐
        ↓                                  ↓
    CSAM/CSEM                      Other Serious Crime
    (Child Abuse Material)         (Violence, Threats, etc.)
        ↓                                  ↓
    1. STOP collection immediately    1. Stop and document
    2. Do NOT save/download          2. Take single screenshot (if safe)
    3. Report to NCMEC CyberTipline  3. Report to law enforcement
       (CyberTipline.org)               (IC3.gov or local LE)
    4. Report to platform            4. Report to platform
    5. Notify supervisor             5. Notify supervisor
    6. Document incident             6. Continue investigation per LE guidance
```

### Should I Escalate This Case?

```
                Evidence of Criminal Activity?
                              ↓
                ┌─────────────┴─────────────┐
                ↓                           ↓
               YES                          NO
                ↓                           ↓
      How serious is the crime?      Continue investigation
                ↓                     per normal procedures
    ┌───────────┴───────────┐
    ↓                       ↓
Serious/Violent          Non-Violent
(Murder, Terrorism,      (Fraud, ToS violation,
CSAM, etc.)             Impersonation)
    ↓                       ↓
IMMEDIATE escalation    Document and report at
to law enforcement     case completion
(Call, don't wait)     (IC3, platform reporting)
```

---

## Time Management

### Typical Investigation Timeline (Beginner Case)

```
Week 1:
├─ Day 1: Setup & Authorization (2 hours)
├─ Day 2-3: Collection Phase (4-6 hours)
└─ Day 4-5: More collection (4-6 hours)

Week 2:
├─ Day 1-2: Analysis & Correlation (6-8 hours)
├─ Day 3-4: Timeline reconstruction (4-6 hours)
└─ Day 5: Begin reporting (2-3 hours)

Week 3:
├─ Day 1-2: Complete report (4-6 hours)
├─ Day 3: Review and quality check (2 hours)
└─ Day 4: Closure and submission (2 hours)

Total: 30-45 hours over 3 weeks (part-time)
```

---

## Common Pitfalls & How to Avoid Them

| Pitfall | Impact | Prevention |
|---------|--------|------------|
| **No authorization** | Legal liability | Always get written authorization first |
| **Poor OPSEC** | Tipped off subject | Use VPN, burner accounts, don't interact |
| **Skipping documentation** | Inadmissible evidence | Log as you go, don't rely on memory |
| **Single-source verification** | False conclusions | Always cross-reference 2-3 sources |
| **Scope creep** | Wasted time, legal issues | Stick to defined scope, get approval for changes |
| **Evidence tampering** | Invalidated case | Never edit, only view. Hash immediately |
| **Delayed escalation** | Victims harmed | Report serious crimes immediately |
| **Burned out** | Poor quality work | Take breaks, set realistic timelines |

---

## Quick Reference: Investigation Checklist

### Pre-Investigation:
- [ ] Authorization obtained
- [ ] Scope defined
- [ ] Environment set up
- [ ] SOPs reviewed

### During Investigation:
- [ ] Evidence logged immediately
- [ ] All files hashed
- [ ] OPSEC maintained
- [ ] Regular backups

### Post-Investigation:
- [ ] All objectives met
- [ ] Report completed
- [ ] Evidence packaged
- [ ] Case closed properly

---

## Related Resources

- [Legal & Ethics SOP](../Investigations/Techniques/sop-legal-ethics.md)
- [OPSEC Planning SOP](../Investigations/Techniques/sop-opsec-plan.md)
- [Collection Logging SOP](../Investigations/Techniques/sop-collection-log.md)
- [Reporting & Disclosure SOP](../Investigations/Techniques/sop-reporting-packaging-disclosure.md)
- [Case Completion Checklist](Case-Template/Case-Completion-Checklist.md)
- [Glossary](Glossary.md)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-12
**Maintainer:** gl0bal01
