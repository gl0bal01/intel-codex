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

## 📊 By the Numbers

**29+ SOPs** across all disciplines | **16 Investigation Guides** | **13 Security Procedures** | **9 CTF Resources**

---

## Main Sections

### OSINT Investigations

Comprehensive investigation techniques, platform guides, and operational procedures for conducting digital investigations.

**Quick Links:**
- [[Investigations/Investigations-Index|Investigation Techniques Index]] - Complete guide to investigation workflows
- [[Investigations/Platforms/Platforms-Index|Platform-Specific SOPs]] - Twitter/X, Instagram, Telegram, LinkedIn, Reddit, TikTok, Bluesky
- [[Investigations/Techniques/Techniques-Index|Investigation Techniques]] - Entity dossiers, collection logs, legal/ethics, OPSEC

**Core SOPs:**
- [[Investigations/Techniques/sop-legal-ethics|Legal & Ethics Review]] - Pre-investigation compliance
- [[Investigations/Techniques/sop-opsec-plan|OPSEC Planning]] - Operational security for investigations
- [[Investigations/Techniques/sop-entity-dossier|Entity Dossier]] - Person/org profiling templates
- [[Investigations/Techniques/sop-collection-log|Collection Log]] - Evidence tracking and chain of custody
- [[Investigations/Techniques/sop-image-video-osint|Image/Video OSINT]] - Reverse search, geolocation, metadata
- [[Investigations/Techniques/sop-web-dns-whois-osint|Web/DNS/WHOIS]] - Infrastructure analysis
- [[Investigations/Techniques/sop-financial-aml-osint|Financial/AML OSINT]] - Blockchain, company records, sanctions

---

### Case Studies

Real-world investigation workflows and example cases demonstrating practical application of techniques.

**Available Cases:**
- [[Cases/Investigation-Workflow|Investigation Workflow Guide]] - Standard investigation process
- [[Cases/README|Case Management README]] - How to structure and document cases
- [[Cases/2025-001-Example-Investigation/README|2025-001: Example Investigation]] - Crypto scammer investigation walkthrough
- [[Cases/Glossary|Glossary]] - Common terms and definitions

**What You'll Learn:**
- How to structure an investigation from start to finish
- Proper evidence collection and documentation
- Entity profiling and relationship mapping
- Escalation procedures for sensitive cases
- Report writing and disclosure

---

### Security Operations

Malware analysis procedures, penetration testing methodologies, and security assessment frameworks.

#### Penetration Testing

Comprehensive guides for offensive security operations across multiple domains.

**Quick Links:**
- [[Security/Pentesting/Pentesting-Index|Pentesting Index]] - Complete pentesting guide

**Available SOPs:**
- [[Security/Pentesting/sop-linux-pentest|Linux Penetration Testing]]
- [[Security/Pentesting/sop-ad-pentest|Active Directory Security]]
- [[Security/Pentesting/sop-web-application-security|Web Application Security]]
- [[Security/Pentesting/sop-mobile-security|Mobile Security Assessment]]
- [[Security/Pentesting/sop-vulnerability-research|Vulnerability Research]]
- [[Security/Pentesting/sop-bug-bounty|Bug Bounty Methodology]]
- [[Security/Pentesting/sop-firmware-reverse-engineering|Firmware Reverse Engineering]]
- [[Security/Pentesting/sop-detection-evasion-testing|Detection Evasion Testing]]


#### Security Analysis Procedures

Procedures for analyzing malicious software, cryptographic systems, and security implementations.

**Quick Links:**
- [[Security/Analysis/Analysis-Index|Analysis Index]] - Complete analysis guide

**Available SOPs:**
- [[Security/Analysis/sop-malware-analysis|Malware Analysis]] - Static and dynamic analysis procedures
- [[Security/Analysis/sop-forensics-investigation|Forensics Investigation]] - Precedures and workflow
- [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]] - Binary analysis techniques
- [[Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]] - Crypto system evaluation
- [[Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]] - Evidence integrity verification

---

### CTF & Hands-On Practice

Resources for Capture The Flag competitions and practical skill development.

**Available Resources:**
- Student Exercises - Hands-on investigation practice scenarios
- CTF Challenge Methodology - Systematic approach to CTF competitions
- Writeups - Documented solutions from real CTF challenges
- Practice Guides - Step-by-step tutorials for common challenge types

**Skills Covered:**
- Binary exploitation and reverse engineering
- Web application vulnerabilities
- Cryptography challenges
- Digital forensics puzzles

---

## How to Use Intel Codex

### For Investigators

1. **Foundations**: [[Investigations/Techniques/sop-legal-ethics|Legal & Ethics]] + [[Investigations/Techniques/sop-opsec-plan|OPSEC]] first
2. **Platform**: Choose from [[Investigations/Platforms/Platforms-Index|Platform SOPs]]
3. **Document**: Use [[Investigations/Techniques/sop-collection-log|Collection Log]] and [[Investigations/Techniques/sop-entity-dossier|Entity Dossier]]
4. **Learn**: Study [[Cases/README|Case Studies]] and [[Cases/Student-Exercises|Student Exercises]]

### For Security Analysts

1. **Start here**: [[Security/Pentesting/Pentesting-Index|Pentesting Index]] or [[Security/Analysis/sop-malware-analysis|Malware Analysis SOP]]
2. **Evidence integrity**: [[Security/Analysis/sop-hash-generation-methods|Hash Generation]]
3. **Specialized**: Choose SOPs based on assessment scope

### For Researchers

Browse [[Investigations/Investigations-Index|Investigation Index]] and [[Cases/README|Case Studies]] for real-world applications.

---

## 🧭 Navigation Tips

- **Sidebar** - Explore all sections hierarchically
- **Search** (top right) - Find specific techniques or platforms
- **Index pages** - Comprehensive navigation hubs:
  - [[Investigations/Investigations-Index|Investigations Index]]
  - [[Security/Pentesting/Pentesting-Index|Pentesting Index]]
  - [[Security/Analysis/Analysis-Index|Analysis Index]]
- **Tags** - Discover related content across sections

---

## 🎓 Learning Paths

### Path 1: Investigations Specialist
**Timeline**: 6 weeks
- **Week 1-2**: [[Investigations/Techniques/sop-legal-ethics|Legal & Ethics]], [[Investigations/Techniques/sop-opsec-plan|OPSEC]], Platform basics
- **Week 3-4**: Advanced techniques ([[Investigations/Techniques/sop-image-video-osint|Image/Video]], [[Investigations/Techniques/sop-financial-aml-osint|Financial]])
- **Week 5-6**: Practice investigations, [[Investigations/Techniques/sop-reporting-packaging-disclosure|report writing]]

### Path 2: Security Analyst
**Timeline**: 6 weeks
- **Week 1-2**: [[Security/Analysis/sop-malware-analysis|Malware Analysis]] fundamentals
- **Week 3-4**: [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]] basics
- **Week 5-6**: Advanced malware analysis, IOC generation

### Path 3: Penetration Tester
**Timeline**: 6 weeks
- **Week 1-2**: [[Security/Pentesting/sop-web-application-security|Web Application Security]] (OWASP Top 10)
- **Week 3-4**: [[Security/Pentesting/sop-linux-pentest|Linux]]/[[Security/Pentesting/sop-ad-pentest|AD]] pentesting
- **Week 5-6**: [[Security/Pentesting/sop-mobile-security|Mobile]]/[[Security/Pentesting/sop-firmware-reverse-engineering|Firmware]] security testing

### Path 4: Bug Bounty Hunter
**Timeline**: 6 weeks
- **Week 1-2**: [[Security/Pentesting/sop-web-application-security|Web App Security]] + [[Security/Pentesting/sop-bug-bounty|Bug Bounty SOP]]
- **Week 3-4**: [[Security/Pentesting/sop-vulnerability-research|Vulnerability Research]] techniques
- **Week 5-6**: Practice on bug bounty platforms (HackerOne, Bugcrowd)

### Path 5: CTF Competitor
**Timeline**: 6 weeks
- **Week 1-2**: [[Security/Analysis/sop-reverse-engineering|Reverse Engineering]] + [[Security/Analysis/sop-cryptography-analysis|Cryptography]]
- **Week 3-4**: Binary exploitation, Web challenges
- **Week 5-6**: Practice CTFs (HTB, TryHackMe, picoCTF)

---

## Content Philosophy

Intel Codex follows these principles:

- **Practical over theoretical**: Every SOP is based on real-world operations
- **Legal and ethical first**: All techniques emphasize compliance and responsible use
- **OPSEC by default**: Operational security considerations in every procedure
- **Living documentation**: Regular updates based on field experience
- **Template-driven**: Reusable templates for consistent documentation

---

## Related Resources

Looking for more OSINT foundations? Check out [OSINT Foundations](/osint) for theoretical frameworks, sockpuppet operations, and strategic approaches.

**Other gl0bal01.com sections:**
- [OSINT Foundations](/osint) - Theory, frameworks, and sockpuppet operations
- [Cybersecurity](/cyber) - General security topics and best practices
- [Reverse Engineering](/reverse) - Binary analysis and reverse engineering guides
- [AI](/ai) - Artificial intelligence and machine learning resources
- [Cheatsheets](/cheatsheets) - Quick reference guides and command sheets

---

**Last Updated**: 2025-10-16
**Source**: Synced from private Obsidian vault via automated plugin
**Maintained by**: gl0bal01
