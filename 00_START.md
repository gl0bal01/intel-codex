# OSINT & Security Reference Library

**Quick access to investigation methods, malware analysis procedures, and CTF techniques.**

## 📊 Quick Stats

**Total SOPs:** 29
**Categories:** Investigations (16) | Security (13) | CTF (9)

---

## 🔍 Investigations

### Platform-Specific Guides
- [[Investigations/Platforms/sop-platform-twitter-x|Twitter/X]] | [[Investigations/Platforms/sop-platform-instagram|Instagram]] | [[Investigations/Platforms/sop-platform-telegram|Telegram]]
- [[Investigations/Platforms/sop-platform-linkedin|LinkedIn]] | [[Investigations/Platforms/sop-platform-reddit|Reddit]]
- [[Investigations/Platforms/sop-platform-tiktok|TikTok]] | [[Investigations/Platforms/sop-platform-bluesky|Bluesky]]
- [[Investigations/Platforms/Platforms-Index|Full Platforms Index]]

### Investigation Techniques
- [[Investigations/Techniques/sop-legal-ethics|Legal & Ethics]] - Read before every investigation
- [[Investigations/Techniques/sop-opsec-plan|OPSEC Planning]] - Protect investigator identity
- [[Investigations/Techniques/sop-entity-dossier|Entity Dossier Building]]
- [[Investigations/Techniques/sop-collection-log|Collection Logging]]
- [[Investigations/Techniques/sop-image-video-osint|Image & Video Analysis]]
- [[Investigations/Techniques/sop-web-dns-whois-osint|Web, DNS & WHOIS]]
- [[Investigations/Techniques/sop-financial-aml-osint|Financial & AML]]
- [[Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting & Disclosure]]
- [[Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive Crime Escalation]]
- [[Investigations/Techniques/Techniques-Index|Full Techniques Index]]

### Investigation Cases & Templates
- [[Cases/README|Investigation Cases]] - Complete examples, templates, student exercises
- [[Cases/Case-Template/README|Case Template]] - Blank case structure for new investigations
- [[Cases/2025-001-Example-Investigation/README|Example Case]] - Full cryptocurrency scam investigation
- [[Cases/Investigation-Workflow|Investigation Workflow]] - Visual process guide with flowcharts
- [[Cases/Glossary|OSINT Glossary]] - 100+ terms defined
- [[Cases/Student-Exercises/Exercise-01-Username-Investigation/README|Student Exercises]] - Hands-on practice (3 exercises)

---

## 🛡️ Security & Malware Analysis

### Core Analysis & Research
- [[Security/Analysis/sop-malware-analysis|Malware Analysis]]
- [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]]
- [[Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]]
- [[Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]]
- [[Security/Analysis/Analysis-Index|Full Analysis Index]]

### Pentesting & Vulnerability Research
- [[Security/Pentesting/sop-web-application-security|Web Application Security]]
- [[Security/Pentesting/sop-mobile-security|Mobile Security (iOS/Android)]]
- [[Security/Pentesting/sop-firmware-reverse-engineering|Firmware Reverse Engineering]]
- [[Security/Pentesting/sop-vulnerability-research|Vulnerability Research]]
- [[Security/Pentesting/sop-ad-pentest|Active Directory Pentesting]]
- [[Security/Pentesting/sop-linux-pentest|Linux Pentesting]]
- [[Security/Pentesting/sop-bug-bounty|Bug Bounty Methodology]]
- [[Security/Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]]
- [[Security/Pentesting/sop-forensics-investigation|Forensics Investigation]]
- [[Security/Pentesting/Pentesting-Index|Full Pentesting Index]]

---

## 🎯 Common Workflows

### Starting an Investigation
1. Review [[Investigations/Techniques/sop-legal-ethics|Legal & Ethics]] ← Read first
2. Check [[Investigations/Techniques/sop-opsec-plan|OPSEC Planning]] ← Protect yourself
3. Choose platform: [[Investigations/Platforms/Platforms-Index|Platform SOPs]]
4. [[Investigations/Techniques/sop-collection-log|Log everything]]
5. [[Investigations/Techniques/sop-reporting-packaging-disclosure|Write report]]

### Malware Analysis Workflow
1. [[Security/Analysis/sop-malware-analysis|Malware Analysis SOP]] ← Follow step-by-step
2. [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]] ← For deeper analysis
3. [[Security/Analysis/sop-hash-generation-methods|Hash Generation]] ← For identification

### Web Pentesting
1. [[Security/Pentesting/sop-web-application-security|Web App Security]] ← OWASP Top 10
2. [[Security/Pentesting/sop-bug-bounty|Bug Bounty]] ← If reporting
3. [[Security/Pentesting/sop-vulnerability-research|Vuln Research]] ← For 0-days

### Binary Exploitation / CTF
1. [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]]
2. [[Security/Pentesting/sop-vulnerability-research|Vulnerability Research]]
3. [[Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]]
4. [[CTF/CTF_Challenge_Methodology|CTF Methodology]]

### Mobile Security Testing
1. [[Security/Pentesting/sop-mobile-security|Mobile Security (iOS/Android)]]
2. [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]] ← For native code
3. [[Security/Analysis/sop-cryptography-analysis|Crypto Analysis]] ← For crypto flaws

### IoT / Firmware Analysis
1. [[Security/Pentesting/sop-firmware-reverse-engineering|Firmware Reverse Engineering]]
2. [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]] ← For binaries
3. [[Security/Pentesting/sop-vulnerability-research|Vuln Research]]

---

## 📁 Folder Structure

```
ObsidianVault/
├── Investigations/
│   ├── Platforms/          (7 platform-specific SOPs)
│   └── Techniques/         (9 investigation SOPs)
├── Security/
│   ├── Analysis/           (4 analysis/research SOPs)
│   └── Pentesting/         (9 pentesting SOPs)
├── CTF/
│   ├── Writeups/           (4 example writeups)
│   └── [Guides]            (5 methodology guides)
└── Cases/
    ├── Case-Template/      (Empty case structure)
    ├── Templates/          (Entity dossier templates)
    └── [Examples]          (Complete investigation examples)
```

---

## 🎓 Learning Paths

### Path 1: Investigations Specialist
Week 1-2: Legal/Ethics, OPSEC, Platform basics
Week 3-4: Advanced techniques (Image/Video, Financial)
Week 5-6: Practice investigations, report writing

### Path 2: Security Analyst
Week 1-2: Malware Analysis fundamentals
Week 3-4: Reverse Engineering basics
Week 5-6: Advanced malware analysis, IOC generation

### Path 3: Penetration Tester
Week 1-2: Web Application Security (OWASP Top 10)
Week 3-4: Linux/AD pentesting
Week 5-6: Mobile/Firmware security testing

### Path 4: Bug Bounty Hunter
Week 1-2: Web App Security + Bug Bounty SOP
Week 3-4: Vulnerability Research techniques
Week 5-6: Practice on bug bounty platforms (HackerOne, Bugcrowd)

### Path 5: CTF Competitor
Week 1-2: Reverse Engineering + Cryptography
Week 3-4: Binary exploitation, Web challenges
Week 5-6: Practice CTFs (HTB, TryHackMe, picoCTF)

---

**Last Updated**: 2025-10-12
