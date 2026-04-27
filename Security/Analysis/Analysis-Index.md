---
type: index
title: "Security Analysis SOPs"
description: "Expert security analysis techniques: malware investigation, reverse engineering, cryptography audits, hash verification, smart-contract audit, cloud forensics, SaaS log forensics, email & BEC forensics & threat intelligence research."
tags: [index, security, analysis, malware, reverse-engineering, smart-contract, cloud-forensics, saas-forensics, email-forensics, bec]
updated: 2026-04-27
---

# Security Analysis SOPs

This directory contains Standard Operating Procedures (SOPs) for security analysis, reverse engineering, cryptographic analysis, smart-contract audit, cloud forensics, SaaS log forensics, and email & BEC forensics.

## Available Analysis SOPs

- [[sop-malware-analysis|Malware Analysis]]
- [[sop-reverse-engineering|Reverse Engineering]]
- [[sop-cryptography-analysis|Cryptography Analysis]]
- [[sop-hash-generation-methods|Hash Generation Methods]]
- [[sop-forensics-investigation|Digital Forensics Investigation]]
- [[sop-smart-contract-audit|Smart Contract Audit]]
- [[sop-cloud-forensics|Cloud Forensics]]
- [[sop-saas-log-forensics|SaaS Log Forensics]]
- [[sop-email-bec-forensics|Email & BEC Forensics]]

## Purpose

These SOPs provide standardized procedures for:
- Analyzing malicious software and binaries
- Reverse engineering applications and protocols
- Evaluating cryptographic implementations
- Generating and verifying file hashes for integrity
- Conducting digital forensics investigations and evidence preservation
- Auditing smart contracts (vulnerability classes, tooling, formal verification, audit-report structure)
- Conducting cloud forensics across IaaS control planes (AWS / Azure / GCP), IAM, container runtimes, and cloud volumes
- Conducting SaaS log forensics across M365 (UAL + Purview), Google Workspace (Reports + Vault), Okta (System Log + ITP), Slack (Audit + Discovery), Salesforce (Setup Audit Trail + Real-Time Event Monitoring), GitHub / GitLab audit, OAuth consent-grant abuse, and cross-tenant collaboration patterns
- Reconstructing email-vector incidents and Business Email Compromise: header forensics (Received-chain, Authentication-Results), SPF / DKIM / DMARC / ARC evaluation, lookalike-domain and brand-impersonation detection, Microsoft 365 / Workspace message tracing, secure-email-gateway forensics (Mimecast / Proofpoint / Barracuda), phishing-kit defensive analysis (kit acquisition, AiTM detection), wire-recall pathway and Financial Fraud Kill Chain coordination, and BEC scenario taxonomy (CEO fraud, vendor-invoice, payroll-redirect, attorney-impersonation, real-estate / closing-funds, gift-card, cryptocurrency-payout variants)

## Common Workflows

### Malware Analysis
1. [[sop-malware-analysis|Malware Analysis]] - Full analysis workflow
2. [[sop-reverse-engineering|Reverse Engineering]] - For deeper code analysis
3. [[sop-hash-generation-methods|Hash Generation]] - For sample identification

### Binary Analysis
1. [[sop-reverse-engineering|Reverse Engineering]] - Disassembly and decompilation
2. [[sop-cryptography-analysis|Cryptography Analysis]] - For crypto routines
3. [[sop-hash-generation-methods|Hash Generation]] - For file verification

### Incident Response & Forensics
1. [[sop-forensics-investigation|Digital Forensics Investigation]] - Evidence collection and preservation
2. [[sop-malware-analysis|Malware Analysis]] - Analyze malicious artifacts
3. [[sop-reverse-engineering|Reverse Engineering]] - Deep dive on custom malware
4. [[sop-hash-generation-methods|Hash Generation]] - Evidence integrity verification

### Smart Contract Audit
1. [[sop-smart-contract-audit|Smart Contract Audit]] - Audit lifecycle, threat modeling, vulnerability classes, tooling, formal verification, report structure
2. [[sop-cryptography-analysis|Cryptography Analysis]] - For primitive-level review (curve choice, hash construction, ZK-circuit soundness)
3. [[sop-reverse-engineering|Reverse Engineering]] - For bytecode-only contracts requiring decompilation
4. [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] - For post-exploit fund tracing once findings move on-chain

### Cloud Forensics
1. [[sop-cloud-forensics|Cloud Forensics]] - IaaS-plane forensics: control-plane log collection, IAM principal-action reconstruction, region-sweep, log-tampering detection, container & k8s runtime artifacts, snapshot preservation, cross-cloud correlation
2. [[sop-forensics-investigation|Digital Forensics Investigation]] - Parent template; host / disk / memory parsing of snapshot-derived volumes
3. [[sop-hash-generation-methods|Hash Generation Methods]] - Evidence integrity for log exports and snapshot copies
4. [[sop-malware-analysis|Malware Analysis]] - For cloud-resident payloads (S3 / Storage / GCS objects, Lambda / Function code, container images)
5. [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] - Offensive counterpart; the threat model that defensive cloud forensics answers

### SaaS Log Forensics
1. [[sop-saas-log-forensics|SaaS Log Forensics]] - SaaS-tenant identity and collaboration plane: M365 UAL + Purview eDiscovery, Workspace Reports API + Vault, Okta System Log + ITP, Slack Audit + Discovery, Salesforce Setup Audit Trail + Real-Time Event Monitoring, GitHub / GitLab audit, OAuth consent-grant abuse, cross-tenant collaboration, retention-cliff and discovery-export discipline
2. [[sop-cloud-forensics|Cloud Forensics]] - Sibling SOP; IaaS-plane forensics for hybrid incidents that bridge identity events to cloud-resource actions
3. [[sop-forensics-investigation|Digital Forensics Investigation]] - Parent template; host / disk / memory parsing for exported PST / Workspace Takeout / Slack export / GitHub repo clone artifacts
4. [[../../Investigations/Techniques/sop-collection-log|Collection Log]] - Chain-of-custody discipline for every audit-log export, eDiscovery package, Vault export, and discovery archive
5. [[sop-malware-analysis|Malware Analysis]] - For SaaS-resident payloads (binaries in OneDrive / SharePoint / Drive / Slack / Salesforce Files; OAuth-app code; CI/CD malicious dependencies)

### Email & BEC Forensics
1. [[sop-email-bec-forensics|Email & BEC Forensics]] - Scenario-centric Business Email Compromise forensics: email header forensics (Received-chain reconstruction, Authentication-Results parsing), SPF / DKIM / DMARC / ARC mechanics, lookalike-domain and brand-impersonation detection (IDN homograph, typosquatting, dnstwist, CT-log monitoring), M365 Get-MessageTrace and Workspace Email Log Search, secure-email-gateway forensics (Mimecast / Proofpoint / Defender / Barracuda), phishing-kit defensive analysis (kit acquisition, AiTM detection — EvilGinx / Modlishka / Muraena), wire-recall pathway (SWIFT MT103 / Fedwire / SEPA / FedNow recall mechanics, Financial Fraud Kill Chain, FBI IC3 reporting, FinCEN SAR triggers, beneficiary-bank coordination), BEC scenario taxonomy (CEO fraud, vendor-invoice fraud, payroll-redirect, attorney-impersonation, real-estate / closing-funds, gift-card, cryptocurrency-payout variants)
2. [[sop-saas-log-forensics|SaaS Log Forensics]] - Sibling SOP; the OAuth-consent BEC variant lives in #8 per the buildout-plan scope contract — this SOP references the carve-in but does not duplicate it; mailbox-side compromise reconstruction (inbox-rule, mailbox-audit, OAuth token persistence) routes there
3. [[sop-cloud-forensics|Cloud Forensics]] - Sibling SOP; when BEC-stolen credentials enable cloud-resource action, the email side stays in #9 and the cloud-resource action routes here
4. [[sop-malware-analysis|Malware Analysis]] - Parent template; receives hand-off for attachment static / dynamic analysis (Office macro, PDF, ISO, HTA, LNK, OneNote payload, archive) per its §3 / §4 / §6, and for deep RE of recovered phishing kits per §6.4 Script Analysis
5. [[sop-forensics-investigation|Digital Forensics Investigation]] - Parent template; host / disk / memory parsing of derived artifacts (PST exports, recovered phishing-kit operator endpoints, victim laptops)
6. [[../../Investigations/Techniques/sop-collection-log|Collection Log]] - Chain-of-custody discipline for every `.eml` capture, header dump, gateway-log export, and recovered-kit archive
7. [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] - Banking-pivot intelligence layer (SAR-typology, UBO investigation, structuring patterns); #9 owns wire-recall *operations*, AML *intelligence* layer routes here
8. [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] - On-chain trace once cryptocurrency-payout BEC funds are deposited

## Navigation

- Return to [[../../README|Start]]
- See also: [[Security/Pentesting/Pentesting-Index|Pentesting SOPs]]
