---
title: Intel Codex
sidebar_label: Intel Codex Overview
sidebar_position: 1
description: Comprehensive collection of OSINT investigation techniques, security procedures, and real-world case studies from the field.
---

:::info What is Intel Codex?

Intel Codex is an operational manual for digital investigators, security analysts, and OSINT practitioners, containing:

- **Standard Operating Procedures (SOPs)** for investigations and security assessments
- **Platform-specific guides** for social media and communications
- **Case studies** with practical applications
- **Malware analysis** and penetration testing methods
- **Legal, ethical, and OPSEC** frameworks

All content reflects current best practices and is actively maintained.

:::

## 📊 Quick Stats

**Total SOPs:** 20+
**Categories:** Investigations (16) | Security (13) | CTF (9)

---

## 🎯 First Time Here?

**Start with these essentials before any investigation:**
1. [[Investigations/Techniques/sop-legal-ethics.md|Legal & Ethics]] ← **Must read** - Compliance and boundaries
2. [[Investigations/Techniques/sop-opsec-plan.md|OPSEC Planning]] ← **Critical** - Protect your identity
3. [[Cases/Investigation-Workflow.md|Investigation Workflow]] ← Visual guide to the complete process
4. [[Cases/Glossary.md|OSINT Glossary]] ← Learn the terminology

**Then explore:**
- [[Investigations/Platforms/Platforms-Index.md|Platform Guides]] for specific social media investigations
- [[Cases/README.md|Case Studies]] for real-world examples

---

## 🔍 Investigations

### Platform-Specific Guides
- [[Investigations/Platforms/sop-platform-twitter-x.md|Twitter/X]] | [[Investigations/Platforms/sop-platform-instagram.md|Instagram]] | [[Investigations/Platforms/sop-platform-telegram.md|Telegram]]
- [[Investigations/Platforms/sop-platform-linkedin.md|LinkedIn]] | [[Investigations/Platforms/sop-platform-reddit.md|Reddit]]
- [[Investigations/Platforms/sop-platform-tiktok.md|TikTok]] | [[Investigations/Platforms/sop-platform-bluesky.md|Bluesky]]
- [[Investigations/Platforms/Platforms-Index.md|Full Platforms Index]]

### Investigation Techniques
- [[Investigations/Techniques/sop-legal-ethics.md|Legal & Ethics]] - Read before every investigation
- [[Investigations/Techniques/sop-opsec-plan.md|OPSEC Planning]] - Protect investigator identity
- [[Investigations/Techniques/sop-entity-dossier.md|Entity Dossier Building]]
- [[Investigations/Techniques/sop-collection-log.md|Collection Logging]]
- [[Investigations/Techniques/sop-image-video-osint.md|Image & Video Analysis]]
- [[Investigations/Techniques/sop-web-dns-whois-osint.md|Web, DNS & WHOIS]]
- [[Investigations/Techniques/sop-financial-aml-osint.md|Financial & AML]]
- [[Investigations/Techniques/sop-reporting-packaging-disclosure.md|Reporting & Disclosure]]
- [[Investigations/Techniques/sop-sensitive-crime-intake-escalation.md|Sensitive Crime Escalation]]
- [[Investigations/Techniques/Techniques-Index.md|Full Techniques Index]]

### Investigation Cases & Templates
- [[Cases/README.md|Investigation Cases]] - Complete examples, templates, student exercises
- [[Cases/Case-Template/README.md|Case Template]] - Blank case structure for new investigations
- [[Cases/2025-001-Example-Investigation/README.md|Example Case]] - Full cryptocurrency scam investigation
- [[Cases/Investigation-Workflow.md|Investigation Workflow]] - Visual process guide with flowcharts
- [[Cases/Glossary.md|OSINT Glossary]] - 100+ terms defined
- [[Cases/Student-Exercises/Exercise-01-Username-Investigation/README.md|Student Exercises]] - Hands-on practice (3 exercises)

---

## 🛡️ Security & Malware Analysis

### Core Analysis & Research
- [[Security/Analysis/sop-malware-analysis.md|Malware Analysis]]
- [[Security/Analysis/sop-reverse-engineering.md|Reverse Engineering]]
- [[Security/Analysis/sop-forensics-investigation.md|Forensics Investigation]]
- [[Security/Analysis/sop-cryptography-analysis.md|Cryptography Analysis]]
- [[Security/Analysis/sop-hash-generation-methods.md|Hash Generation Methods]]
- [[Security/Analysis/Analysis-Index.md|Full Analysis Index]]

### Pentesting & Vulnerability Research
- [[Security/Pentesting/sop-web-application-security.md|Web Application Security]]
- [[Security/Pentesting/sop-mobile-security.md|Mobile Security (iOS/Android)]]
- [[Security/Pentesting/sop-firmware-reverse-engineering.md|Firmware Reverse Engineering]]
- [[Security/Pentesting/sop-vulnerability-research.md|Vulnerability Research]]
- [[Security/Pentesting/sop-ad-pentest.md|Active Directory Pentesting]]
- [[Security/Pentesting/sop-linux-pentest.md|Linux Pentesting]]
- [[Security/Pentesting/sop-bug-bounty.md|Bug Bounty Methodology]]
- [[Security/Pentesting/sop-detection-evasion-testing.md|Detection & Evasion Testing]]
- [[Security/Pentesting/Pentesting-Index.md|Full Pentesting Index]]

---

## 🎯 Common Workflows

### Starting an Investigation
1. Review [[Investigations/Techniques/sop-legal-ethics.md|Legal & Ethics]] ← Read first
2. Check [[Investigations/Techniques/sop-opsec-plan.md|OPSEC Planning]] ← Protect yourself
3. Choose platform: [[Investigations/Platforms/Platforms-Index.md|Platform SOPs]]
4. [[Investigations/Techniques/sop-collection-log.md|Log everything]]
5. [[Investigations/Techniques/sop-reporting-packaging-disclosure.md|Write report]]

### Malware Analysis Workflow
1. [[Security/Analysis/sop-malware-analysis.md|Malware Analysis SOP]] ← Follow step-by-step
2. [[Security/Analysis/sop-reverse-engineering.md|Reverse Engineering]] ← For deeper analysis
3. [[Security/Analysis/sop-hash-generation-methods.md|Hash Generation]] ← For identification

### Forensics Investigation
1. [[Security/Analysis/sop-forensics-investigation.md|Forensics Investigation]] ← Full methodology
2. [[Security/Analysis/sop-hash-generation-methods.md|Hash Generation]] ← Evidence integrity
3. [[Security/Analysis/sop-malware-analysis.md|Malware Analysis]] ← If malware is found

### Web Pentesting
1. [[Security/Pentesting/sop-web-application-security.md|Web App Security]] ← OWASP Top 10
2. [[Security/Pentesting/sop-bug-bounty.md|Bug Bounty]] ← If reporting
3. [[Security/Pentesting/sop-vulnerability-research.md|Vuln Research]] ← For 0-days

### Binary Exploitation / CTF
1. [[Security/Analysis/sop-reverse-engineering.md|Reverse Engineering]]
2. [[Security/Pentesting/sop-vulnerability-research.md|Vulnerability Research]]
3. [[Security/Analysis/sop-cryptography-analysis.md|Cryptography Analysis]]
4. [[CTF/CTF_Challenge_Methodology.md|CTF Methodology]]

### Mobile Security Testing
1. [[Security/Pentesting/sop-mobile-security.md|Mobile Security (iOS/Android)]]
2. [[Security/Analysis/sop-reverse-engineering.md|Reverse Engineering]] ← For native code
3. [[Security/Analysis/sop-cryptography-analysis.md|Crypto Analysis]] ← For crypto flaws

### IoT / Firmware Analysis
1. [[Security/Pentesting/sop-firmware-reverse-engineering.md|Firmware Reverse Engineering]]
2. [[Security/Analysis/sop-reverse-engineering.md|Reverse Engineering]] ← For binaries
3. [[Security/Pentesting/sop-vulnerability-research.md|Vuln Research]]
