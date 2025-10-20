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
- [Investigation Techniques Index](Investigations/Investigations-Index.md) - Complete guide to investigation workflows
- [Platform-Specific SOPs](Investigations/Platforms/Platforms-Index.md) - Twitter/X, Instagram, Telegram, LinkedIn, Reddit, TikTok, Bluesky
- [Investigation Techniques](Investigations/Techniques/Techniques-Index.md) - Entity dossiers, collection logs, legal/ethics, OPSEC

**Core SOPs:**
- [Legal & Ethics Review](Investigations/Techniques/sop-legal-ethics.md) - Pre-investigation compliance
- [OPSEC Planning](Investigations/Techniques/sop-opsec-plan.md) - Operational security for investigations
- [Entity Dossier](Investigations/Techniques/sop-entity-dossier.md) - Person/org profiling templates
- [Collection Log](Investigations/Techniques/sop-collection-log.md) - Evidence tracking and chain of custody
- [Image/Video OSINT](Investigations/Techniques/sop-image-video-osint.md) - Reverse search, geolocation, metadata
- [Web/DNS/WHOIS](Investigations/Techniques/sop-web-dns-whois-osint.md) - Infrastructure analysis
- [Financial/AML OSINT](Investigations/Techniques/sop-financial-aml-osint.md) - Blockchain, company records, sanctions

---

### Case Studies

Real-world investigation workflows and example cases demonstrating practical application of techniques.

**Available Cases:**
- [Investigation Workflow Guide](Cases/Investigation-Workflow.md) - Standard investigation process
- [Case Management README](Cases/README.md) - How to structure and document cases
- [2025-001: Example Investigation](Cases/2025-001-Example-Investigation/README.md) - Crypto scammer investigation walkthrough
- [Glossary](Cases/Glossary.md) - Common terms and definitions

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
- [Pentesting Index](Security/Pentesting/Pentesting-Index.md) - Complete pentesting guide

**Available SOPs:**
- [Linux Penetration Testing](Security/Pentesting/sop-linux-pentest.md)
- [Active Directory Security](Security/Pentesting/sop-ad-pentest.md)
- [Web Application Security](Security/Pentesting/sop-web-application-security.md)
- [Mobile Security Assessment](Security/Pentesting/sop-mobile-security.md)
- [Vulnerability Research](Security/Pentesting/sop-vulnerability-research.md)
- [Bug Bounty Methodology](Security/Pentesting/sop-bug-bounty.md)
- [Firmware Reverse Engineering](Security/Pentesting/sop-firmware-reverse-engineering.md)
- [Detection Evasion Testing](Security/Pentesting/sop-detection-evasion-testing.md)


#### Security Analysis Procedures

Procedures for analyzing malicious software, cryptographic systems, and security implementations.

**Quick Links:**
- [Analysis Index](Security/Analysis/Analysis-Index.md) - Complete analysis guide

**Available SOPs:**
- [Malware Analysis](Security/Analysis/sop-malware-analysis.md) - Static and dynamic analysis procedures
- [Forensics Investigation](Security/Analysis/sop-forensics-investigation.md) - Precedures and workflow
- [Reverse Engineering](Security/Analysis/sop-reverse-engineering.md) - Binary analysis techniques
- [Cryptography Analysis](Security/Analysis/sop-cryptography-analysis.md) - Crypto system evaluation
- [Hash Generation Methods](Security/Analysis/sop-hash-generation-methods.md) - Evidence integrity verification

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

1. **Foundations**: [Legal & Ethics](Investigations/Techniques/sop-legal-ethics.md) + [OPSEC](Investigations/Techniques/sop-opsec-plan.md) first
2. **Platform**: Choose from [Platform SOPs](Investigations/Platforms/Platforms-Index.md)
3. **Document**: Use [Collection Log](Investigations/Techniques/sop-collection-log.md) and [Entity Dossier](Investigations/Techniques/sop-entity-dossier.md)
4. **Learn**: Study [Case Studies](Cases/README.md) and [Student Exercises](Cases/Student-Exercises.md)

### For Security Analysts

1. **Start here**: [Pentesting Index](Security/Pentesting/Pentesting-Index.md) or [Malware Analysis SOP](Security/Analysis/sop-malware-analysis.md)
2. **Evidence integrity**: [Hash Generation](Security/Analysis/sop-hash-generation-methods.md)
3. **Specialized**: Choose SOPs based on assessment scope

### For Researchers

Browse [Investigation Index](Investigations/Investigations-Index.md) and [Case Studies](Cases/README.md) for real-world applications.

---

## 🧭 Navigation Tips

- **Sidebar** - Explore all sections hierarchically
- **Search** (top right) - Find specific techniques or platforms
- **Index pages** - Comprehensive navigation hubs:
  - [Investigations Index](Investigations/Investigations-Index.md)
  - [Pentesting Index](Security/Pentesting/Pentesting-Index.md)
  - [Analysis Index](Security/Analysis/Analysis-Index.md)
- **Tags** - Discover related content across sections

---

## 🎓 Learning Paths

### Path 1: Investigations Specialist
**Timeline**: 6 weeks
- **Week 1-2**: [Legal & Ethics](Investigations/Techniques/sop-legal-ethics.md), [OPSEC](Investigations/Techniques/sop-opsec-plan.md), Platform basics
- **Week 3-4**: Advanced techniques ([Image/Video](Investigations/Techniques/sop-image-video-osint.md), [Financial](Investigations/Techniques/sop-financial-aml-osint.md))
- **Week 5-6**: Practice investigations, [report writing](Investigations/Techniques/sop-reporting-packaging-disclosure.md)

### Path 2: Security Analyst
**Timeline**: 6 weeks
- **Week 1-2**: [Malware Analysis](Security/Analysis/sop-malware-analysis.md) fundamentals
- **Week 3-4**: [Reverse Engineering](Security/Analysis/sop-reverse-engineering.md) basics
- **Week 5-6**: Advanced malware analysis, IOC generation

### Path 3: Penetration Tester
**Timeline**: 6 weeks
- **Week 1-2**: [Web Application Security](Security/Pentesting/sop-web-application-security.md) (OWASP Top 10)
- **Week 3-4**: [Linux](Security/Pentesting/sop-linux-pentest.md)/[AD](Security/Pentesting/sop-ad-pentest.md) pentesting
- **Week 5-6**: [Mobile](Security/Pentesting/sop-mobile-security.md)/[Firmware](Security/Pentesting/sop-firmware-reverse-engineering.md) security testing

### Path 4: Bug Bounty Hunter
**Timeline**: 6 weeks
- **Week 1-2**: [Web App Security](Security/Pentesting/sop-web-application-security.md) + [Bug Bounty SOP](Security/Pentesting/sop-bug-bounty.md)
- **Week 3-4**: [Vulnerability Research](Security/Pentesting/sop-vulnerability-research.md) techniques
- **Week 5-6**: Practice on bug bounty platforms (HackerOne, Bugcrowd)

### Path 5: CTF Competitor
**Timeline**: 6 weeks
- **Week 1-2**: [Reverse Engineering](Security/Analysis/sop-reverse-engineering.md) + [Cryptography](Security/Analysis/sop-cryptography-analysis.md)
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
