---
type: index
title: OSINT Investigation Techniques
description: "Advanced OSINT methods: social media intelligence, domain reconnaissance, geolocation, people search & comprehensive open-source investigation tactics."
tags: [index, techniques, osint, investigation, sop]
created: 2025-10-09
updated: 2025-10-09
---

# OSINT Investigation Techniques Index

> **Purpose:** Comprehensive catalog of standard operating procedures (SOPs) and methodologies for conducting open-source intelligence investigations.

---

## Overview

This directory contains detailed SOPs covering core investigation techniques, evidence handling, operational security, and specialized analysis methods. Each SOP provides step-by-step procedures, tools, commands, and best practices for OSINT practitioners.

---

## Core Investigation Techniques

### Evidence Collection & Management

#### [[sop-collection-log|OSINT Collection Log & Chain of Custody]]
- **Purpose:** Maintain forensically sound evidence collection practices
- **Coverage:** Evidence logging, hash verification, multi-format capture, integrity verification
- **Key Topics:**
  - Collection log templates and chain of custody documentation
  - Capture procedures (HTML, screenshots, WARC archives)
  - Evidence packaging and storage protocols
  - Platform-specific collection methods (social media, websites, blockchain)
  - Hash calculation and verification workflows
  - Legal admissibility requirements

#### [[sop-entity-dossier|Entity Dossier Template]]
- **Purpose:** Comprehensive entity profiling framework
- **Coverage:** Person/organization/asset profiling, link analysis, risk assessment
- **Key Topics:**
  - Entity overview and basic information structure
  - Aliases, identifiers, and visual markers
  - Digital footprint analysis (data breaches, crypto activity)
  - Links and pivots (WHOIS, DNS, social media)
  - Evidence repository management
  - Confidence and risk assessment frameworks
  - Intelligence gap identification

### Operational Security

#### [[sop-opsec-plan|OPSEC Planning for OSINT Investigations]]
- **Purpose:** Protect investigator identity and prevent attribution during investigations
- **Coverage:** Threat modeling, anonymity techniques, platform-specific OPSEC, incident response
- **Key Topics:**
  - Threat modeling and adversary profiles (5 levels)
  - Investigation environment isolation (VMs, containers, Whonix, Tails, Exegol)
  - Network security (VPN, Tor, DNS security)
  - Research persona development and warming
  - Browser security and fingerprint resistance
  - Platform-specific attribution risks and countermeasures
  - Detection indicators and self-assessment
  - OPSEC incident response procedures

---

## Domain-Specific Techniques

### Financial Intelligence

#### [[sop-financial-aml-osint|Financial & AML OSINT]]
- **Purpose:** Anti-money laundering and financial intelligence investigations
- **Coverage:** Cryptocurrency analysis, financial records, transaction tracking
- **Key Topics:**
  - Blockchain analysis and wallet clustering
  - Financial data sources and corporate registries
  - Sanctions screening and compliance checks
  - Transaction pattern analysis
  - Money laundering red flags

### Multimedia Analysis

#### [[sop-image-video-osint|Image & Video OSINT]]
- **Purpose:** Extract intelligence from visual media
- **Coverage:** Metadata extraction, geolocation, reverse image search, deepfake detection
- **Key Topics:**
  - EXIF metadata extraction and interpretation
  - Reverse image search techniques (Google, TinEye, Yandex, PimEyes)
  - Geolocation via landmarks, shadows, vegetation
  - Video frame extraction and timeline analysis
  - Deepfake and manipulation detection
  - Facial recognition and biometric analysis

### Infrastructure & Web Analysis

#### [[sop-web-dns-whois-osint|Web, DNS & WHOIS OSINT]]
- **Purpose:** Investigate web infrastructure and domain ownership
- **Coverage:** WHOIS lookups, DNS enumeration, certificate analysis, website archiving
- **Key Topics:**
  - WHOIS data interpretation and privacy protection bypass
  - DNS record enumeration (A, MX, TXT, NS, SPF, DMARC)
  - SSL/TLS certificate transparency searches
  - Website archiving (Archive.org, archive.today)
  - Subdomain discovery and virtual host enumeration
  - Passive DNS and historical data analysis

---

## Reporting & Documentation

#### [[sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]]
- **Purpose:** Professional reporting standards and evidence presentation
- **Coverage:** Report structure, evidence packaging, disclosure protocols
- **Key Topics:**
  - Executive summary and findings presentation
  - Evidence citation and referencing
  - Confidence levels and analytical tradecraft
  - Disclosure procedures and recipient handling
  - Report security and classification

---

## Legal & Ethical Guidelines

#### [[sop-legal-ethics|Legal & Ethics SOP]]
- **Purpose:** Legal boundaries and ethical considerations in OSINT
- **Coverage:** Jurisdiction issues, privacy laws, Terms of Service, ethical frameworks
- **Key Topics:**
  - Legal frameworks (GDPR, CCPA, ECPA, CFAA)
  - Terms of Service compliance
  - Ethical investigation boundaries
  - Privacy considerations and consent
  - Admissibility and evidence standards
  - International jurisdiction challenges

#### [[sop-sensitive-crime-intake-escalation|Sensitive Crime Intake & Escalation]]
- **Purpose:** Handling investigations involving serious crimes or vulnerable populations
- **Coverage:** CSAM handling, violent extremism, trafficking, escalation procedures
- **Key Topics:**
  - Content warning systems
  - Mandatory reporting obligations
  - Investigator safety and psychological support
  - Evidence preservation for law enforcement
  - Escalation chains and jurisdictional handoff
  - Victim protection protocols

---

## Quick Reference Matrix

| Investigation Type | Recommended SOPs | Priority Order |
|-------------------|------------------|----------------|
| **Person Investigation** | Entity Dossier → OPSEC Plan → Collection Log → Platform SOPs | Start here for individuals |
| **Organization/Corporate** | Entity Dossier → Financial AML → Web/DNS → Collection Log | Business entities |
| **Domain/Infrastructure** | Web/DNS WHOIS → Collection Log → Entity Dossier | Websites, servers |
| **Cryptocurrency** | Financial AML → Collection Log → Entity Dossier | Wallet investigations |
| **Visual Media** | Image/Video OSINT → Collection Log | Photo/video analysis |
| **High-Risk/Adversarial** | OPSEC Plan → Collection Log → Legal/Ethics | Nation-state, criminal |
| **Sensitive Content** | Sensitive Crime Intake → Legal/Ethics → OPSEC Plan | CSAM, violence, trafficking |

---

## Investigation Workflow

### Standard Investigation Lifecycle

```text
1. Planning & Authorization
   └─> Read: Legal & Ethics, OPSEC Plan

2. Environment Setup
   └─> Read: OPSEC Plan (VM/VPN setup, persona creation)

3. Collection Phase
   └─> Read: Collection Log, Platform SOPs, Domain-specific techniques

4. Entity Profiling
   └─> Read: Entity Dossier (compile findings)

5. Analysis & Correlation
   └─> Read: Domain-specific SOPs (Financial, Image/Video, Web/DNS)

6. Documentation & Reporting
   └─> Read: Reporting & Packaging, Collection Log (chain of custody)

7. Disclosure (if required)
   └─> Read: Reporting & Packaging, Legal & Ethics, Sensitive Crime Escalation
```

---

## Related Resources

### Platform-Specific SOPs
See [[../Platforms/Platforms-Index|Platform SOPs Index]] for detailed procedures covering:
- Twitter/X, Instagram, LinkedIn, Facebook
- Telegram, Discord, Reddit, TikTok
- Dark web forums and marketplaces

### Security Analysis
See [[../../Security/Analysis/Analysis-Index|Security Analysis Index]] for:
- [[../../Security/Analysis/sop-cryptography-analysis|Cryptography Analysis]]
- [[../../Security/Analysis/sop-hash-generation-methods|Hash Generation Methods]]
- [[../../Security/Analysis/sop-reverse-engineering|Reverse Engineering]]

### Investigation Cases
See [[../Investigations-Index|Investigations Index]] for:
- Active case templates
- Investigation methodologies
- Case studies and lessons learned

---

## Tool Categories

### Evidence Collection
- **SingleFile** - Complete webpage archival (HTML)
- **wget/ArchiveBox** - WARC archival
- **ExifTool** - Metadata extraction
- **yt-dlp** - Social media download

### OPSEC & Anonymity
- **Mullvad VPN / ProtonVPN** - Anonymous networking
- **Tor Browser / Whonix / Tails** - Maximum anonymity
- **VirtualBox / VMware** - Environment isolation
- **KeePassXC** - Password management

### Analysis & Enrichment
- **Maltego** - Link analysis and visualization
- **Shodan / Censys** - Internet-wide device search
- **theHarvester** - Domain/email enumeration
- **Nuclei** - Username enumeration

### Blockchain & Financial
- **Blockchain.info / Etherscan** - Transaction analysis
- **Chainalysis** - Advanced blockchain analytics
- **OpenCorporates** - Corporate registry search

---

## Best Practices Summary

### Evidence Handling
- ✅ Calculate SHA-256 hashes immediately upon collection
- ✅ Capture in multiple formats (HTML + screenshot + archive)
- ✅ Document chain of custody from collection to storage
- ✅ Store evidence on encrypted volumes
- ✅ Verify integrity weekly/monthly

### Operational Security
- ✅ Always use VPN/Tor for investigations
- ✅ Warm personas for 30 days before active use
- ✅ Never login to personal accounts in investigation environment
- ✅ Randomize timing and behavior (avoid bot patterns)
- ✅ Test for DNS/WebRTC leaks before each session

### Legal & Ethical
- ✅ Obtain proper authorization before starting investigation
- ✅ Stay within legal boundaries (no hacking, no unauthorized access)
- ✅ Respect Terms of Service (or document violations)
- ✅ Escalate sensitive content immediately (CSAM, violence)
- ✅ Document confidence levels and analytical assumptions

### Quality Assurance
- ✅ Maintain reproducibility documentation
- ✅ Peer review findings before reporting
- ✅ Cite sources and evidence for all claims
- ✅ Use appropriate confidence levels (low/medium/high)
- ✅ Identify intelligence gaps and unknowns

---

## Training & Certification

### Recommended Learning Path
1. **Foundations:** Legal & Ethics, OPSEC Plan
2. **Core Skills:** Collection Log, Entity Dossier
3. **Specialization:** Domain-specific techniques (Financial, Image/Video, Web/DNS)
4. **Advanced:** Platform-specific SOPs, sensitive content handling

### External Resources
- **Bellingcat** - OSINT investigation guides and case studies
- **SANS FOR578** - Cyber Threat Intelligence course
- **IntelTechniques** - Michael Bazzell's OSINT resources
- **OSINT Framework** - Comprehensive tool directory

---

## Maintenance & Updates

**Document Control:**
- **Created:** 2025-10-09
- **Last Updated:** 2025-10-09
- **Review Cycle:** Yearly

---

**Navigation:**
- [[../Investigations-Index|← Investigations Index]]
- [[../Platforms/Platforms-Index|Platform SOPs →]]
- [[../../Security/Analysis/Analysis-Index|Security Analysis →]]
- [[../../00_START|↑ Start]]
