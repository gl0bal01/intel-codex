---
type: index
title: Verification Status
description: "Per-SOP verification record for the Intel Codex vault: source-check counts, oldest check, and review age for all 41 procedures."
generated: 2026-10-29
generator: tools/build-vault-state.sh
tags:
  - index
  - verification
---

# Verification Status

> **Generated file. Do not edit directly.** Re-run `./tools/build-vault-state.sh`.

Every SOP in this vault carries inline `[verify YYYY-MM-DD]` markers. One marker
is one claim — a command flag, a statute reference, a vendor behaviour, a tool
default — checked against its primary source on that date.

This page publishes that record so the age of a procedure is visible without
having to take the page's word for it. Read it for what it is: **it reports when
claims were last checked against sources, not that a procedure was executed end
to end in a lab.** No SOP here is labelled field-tested, because none of them has
the evidence that label would require.

Claims are re-checked on a **six-month cadence**. A SOP reads `current` until
150 days, `due soon` in the month before the cadence expires, and
`overdue` past 180. Age is measured from the **oldest** marker in the
file, so a SOP is only as fresh as its stalest claim.

## Summary

| State | SOPs |
|-------|------|
| current (≤ 150 days) | 12 |
| due soon (151–180 days) | 0 |
| overdue (> 180 days) | 29 |
| no source checks recorded | 0 |
| **Total** | **41** |

## Investigations / Platforms

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| Bluesky SOP | [[sop-platform-bluesky]] | 2026-10-18 | 56 | 2026-10-18 | 11 | current |
| Discord SOP | [[sop-platform-discord]] | 2026-10-18 | 2 | 2026-04-27 | 185 | overdue |
| Instagram SOP | [[sop-platform-instagram]] | 2026-10-18 | 38 | 2026-10-18 | 11 | current |
| LinkedIn SOP | [[sop-platform-linkedin]] | 2026-10-18 | 61 | 2026-10-18 | 11 | current |
| Reddit SOP | [[sop-platform-reddit]] | 2026-10-29 | 46 | 2026-10-18 | 11 | current |
| Telegram SOP | [[sop-platform-telegram]] | 2026-10-18 | 33 | 2026-10-18 | 11 | current |
| TikTok SOP | [[sop-platform-tiktok]] | 2026-10-18 | 39 | 2026-10-18 | 11 | current |
| Twitter/X SOP | [[sop-platform-twitter-x]] | 2026-10-29 | 56 | 2026-10-18 | 11 | current |

## Investigations / Techniques

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| Blockchain Investigation | [[sop-blockchain-investigation]] | 2026-04-26 | 49 | 2026-04-26 | 186 | overdue |
| OSINT Collection Log & Chain of Custody | [[sop-collection-log]] | 2026-10-29 | 17 | 2026-04-26 | 186 | overdue |
| Darkweb Investigation | [[sop-darkweb-investigation]] | 2026-09-20 | 63 | 2026-04-26 | 186 | overdue |
| Entity Dossier Guide | [[sop-entity-dossier]] | 2026-10-18 | 14 | 2026-04-26 | 186 | overdue |
| Financial Crime & AML OSINT | [[sop-financial-aml-osint]] | 2026-04-27 | 2 | 2026-04-25 | 187 | overdue |
| Image & Video OSINT | [[sop-image-video-osint]] | 2026-04-25 | 15 | 2026-04-25 | 187 | overdue |
| Legal, Ethics & Data Governance for OSINT | [[sop-legal-ethics]] | 2026-10-29 | 131 | 2026-10-25 | 4 | current |
| Mixer & Privacy-Pool Tracing | [[sop-mixer-tracing]] | 2026-04-26 | 117 | 2026-04-26 | 186 | overdue |
| OPSEC Planning for OSINT Investigations | [[sop-opsec-plan]] | 2026-10-29 | 187 | 2026-10-25 | 4 | current |
| Reporting, Packaging & Disclosure | [[sop-reporting-packaging-disclosure]] | 2026-10-29 | 47 | 2026-10-18 | 11 | current |
| Sensitive Crime Intake & Escalation | [[sop-sensitive-crime-intake-escalation]] | 2026-10-29 | 32 | 2026-04-26 | 186 | overdue |
| Web, DNS & WHOIS OSINT | [[sop-web-dns-whois-osint]] | 2026-04-25 | 6 | 2026-04-25 | 187 | overdue |

## Security / Analysis

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| AI/ML Vulnerability & Evasion Testing SOP | [[sop-ai-vulnerability-evasion]] | 2026-04-26 | 25 | 2026-04-26 | 186 | overdue |
| Cloud Forensics SOP | [[sop-cloud-forensics]] | 2026-04-27 | 39 | 2026-04-27 | 185 | overdue |
| Cryptography Analysis SOP | [[sop-cryptography-analysis]] | 2026-04-25 | 7 | 2026-04-25 | 187 | overdue |
| Email & BEC Forensics SOP | [[sop-email-bec-forensics]] | 2026-09-20 | 79 | 2026-04-27 | 185 | overdue |
| Digital Forensics Investigation SOP | [[sop-forensics-investigation]] | 2026-10-29 | 16 | 2026-04-25 | 187 | overdue |
| Hash Generation Methods for Evidence Integrity | [[sop-hash-generation-methods]] | 2026-04-26 | 4 | 2026-04-26 | 186 | overdue |
| Malware Analysis SOP | [[sop-malware-analysis]] | 2026-10-18 | 200 | 2026-10-18 | 11 | current |
| Reverse Engineering | [[sop-reverse-engineering]] | 2026-09-20 | 1 | 2026-04-25 | 187 | overdue |
| SaaS Log Forensics SOP | [[sop-saas-log-forensics]] | 2026-04-27 | 76 | 2026-04-27 | 185 | overdue |
| Smart Contract Audit SOP | [[sop-smart-contract-audit]] | 2026-04-26 | 30 | 2026-04-26 | 186 | overdue |

## Security / Pentesting

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| Active Directory Pentesting SOP (Authorized) | [[sop-ad-pentest]] | 2026-04-26 | 16 | 2026-04-26 | 186 | overdue |
| Bug Bounty Methodology SOP | [[sop-bug-bounty]] | 2026-04-25 | 3 | 2026-04-25 | 187 | overdue |
| Cloud Pentesting SOP (Authorized) | [[sop-cloud-pentest]] | 2026-04-27 | 33 | 2026-04-26 | 186 | overdue |
| Container & Kubernetes Pentesting SOP (Authorized) | [[sop-container-k8s-pentest]] | 2026-10-18 | 37 | 2026-04-27 | 185 | overdue |
| Detection & Evasion Testing SOP (Purple Team) | [[sop-detection-evasion-testing]] | 2026-10-18 | 67 | 2026-10-18 | 11 | current |
| Firmware Reverse Engineering | [[sop-firmware-reverse-engineering]] | 2026-04-26 | 39 | 2026-04-26 | 186 | overdue |
| Linux Pentesting SOP (Authorized) | [[sop-linux-pentest]] | 2026-04-25 | 5 | 2026-04-25 | 187 | overdue |
| Mobile Security (iOS & Android) | [[sop-mobile-security]] | 2026-09-20 | 21 | 2026-04-26 | 186 | overdue |
| Vulnerability Research SOP | [[sop-vulnerability-research]] | 2026-04-25 | 10 | 2026-04-25 | 187 | overdue |
| Web Application Security Testing SOP | [[sop-web-application-security]] | 2026-09-20 | 8 | 2026-04-25 | 187 | overdue |
| Wireless & RF Pentesting (Authorized) | [[sop-wireless-rf-pentest]] | 2026-04-26 | 31 | 2026-04-26 | 186 | overdue |

---

**Generated:** 2026-10-29
