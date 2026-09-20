---
type: index
title: Verification Status
description: "Per-SOP verification record for the Intel Codex vault: source-check counts, oldest check, and review age for all 41 procedures."
generated: 2026-09-20
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

A SOP counts as `current` at 90 days or less, `review due` up to
180, and `overdue` beyond that. Age is measured from the **oldest**
marker in the file, so a SOP is only as fresh as its stalest claim.

## Summary

| State | SOPs |
|-------|------|
| current (≤ 90 days) | 0 |
| review due (91–180 days) | 31 |
| overdue (> 180 days) | 0 |
| no source checks recorded | 10 |
| **Total** | **41** |

## Investigations / Platforms

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| Bluesky SOP | [[sop-platform-bluesky]] | 2025-09-06 | 0 | — | — | no source checks |
| Discord SOP | [[sop-platform-discord]] | 2026-04-27 | 1 | 2026-04-27 | 146 | review due |
| Instagram SOP | [[sop-platform-instagram]] | 2025-10-01 | 0 | — | — | no source checks |
| LinkedIn SOP | [[sop-platform-linkedin]] | 2025-10-06 | 0 | — | — | no source checks |
| Reddit SOP | [[sop-platform-reddit]] | 2025-10-02 | 0 | — | — | no source checks |
| Telegram SOP | [[sop-platform-telegram]] | 2026-04-27 | 0 | — | — | no source checks |
| TikTok SOP | [[sop-platform-tiktok]] | 2025-10-08 | 0 | — | — | no source checks |
| Twitter/X SOP | [[sop-platform-twitter-x]] | 2025-10-08 | 0 | — | — | no source checks |

## Investigations / Techniques

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| Blockchain Investigation | [[sop-blockchain-investigation]] | 2026-04-26 | 49 | 2026-04-26 | 147 | review due |
| OSINT Collection Log & Chain of Custody | [[sop-collection-log]] | 2026-09-20 | 16 | 2026-04-26 | 147 | review due |
| Darkweb Investigation | [[sop-darkweb-investigation]] | 2026-09-20 | 63 | 2026-04-26 | 147 | review due |
| Entity Dossier Guide | [[sop-entity-dossier]] | 2026-09-20 | 13 | 2026-04-26 | 147 | review due |
| Financial Crime & AML OSINT | [[sop-financial-aml-osint]] | 2026-04-27 | 2 | 2026-04-25 | 148 | review due |
| Image & Video OSINT | [[sop-image-video-osint]] | 2026-04-25 | 15 | 2026-04-25 | 148 | review due |
| Legal, Ethics & Data Governance for OSINT | [[sop-legal-ethics]] | 2026-04-26 | 20 | 2026-04-26 | 147 | review due |
| Mixer & Privacy-Pool Tracing | [[sop-mixer-tracing]] | 2026-04-26 | 117 | 2026-04-26 | 147 | review due |
| OPSEC Planning for OSINT Investigations | [[sop-opsec-plan]] | 2026-09-20 | 25 | 2026-04-26 | 147 | review due |
| Reporting, Packaging & Disclosure | [[sop-reporting-packaging-disclosure]] | 2026-09-20 | 0 | — | — | no source checks |
| Sensitive Crime Intake & Escalation | [[sop-sensitive-crime-intake-escalation]] | 2026-04-26 | 29 | 2026-04-26 | 147 | review due |
| Web, DNS & WHOIS OSINT | [[sop-web-dns-whois-osint]] | 2026-04-25 | 6 | 2026-04-25 | 148 | review due |

## Security / Analysis

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| AI/ML Vulnerability & Evasion Testing SOP | [[sop-ai-vulnerability-evasion]] | 2026-04-26 | 25 | 2026-04-26 | 147 | review due |
| Cloud Forensics SOP | [[sop-cloud-forensics]] | 2026-04-27 | 39 | 2026-04-27 | 146 | review due |
| Cryptography Analysis SOP | [[sop-cryptography-analysis]] | 2026-04-25 | 7 | 2026-04-25 | 148 | review due |
| Email & BEC Forensics SOP | [[sop-email-bec-forensics]] | 2026-09-20 | 79 | 2026-04-27 | 146 | review due |
| Digital Forensics Investigation SOP | [[sop-forensics-investigation]] | 2026-04-25 | 15 | 2026-04-25 | 148 | review due |
| Hash Generation Methods for Evidence Integrity | [[sop-hash-generation-methods]] | 2026-04-26 | 4 | 2026-04-26 | 147 | review due |
| Malware Analysis SOP | [[sop-malware-analysis]] | 2026-09-20 | 0 | — | — | no source checks |
| Reverse Engineering | [[sop-reverse-engineering]] | 2026-09-20 | 1 | 2026-04-25 | 148 | review due |
| SaaS Log Forensics SOP | [[sop-saas-log-forensics]] | 2026-04-27 | 76 | 2026-04-27 | 146 | review due |
| Smart Contract Audit SOP | [[sop-smart-contract-audit]] | 2026-04-26 | 30 | 2026-04-26 | 147 | review due |

## Security / Pentesting

| SOP | File | Updated | Checks | Oldest check | Age (days) | State |
|-----|------|---------|-------:|--------------|-----------:|-------|
| Active Directory Pentesting SOP (Authorized) | [[sop-ad-pentest]] | 2026-04-26 | 16 | 2026-04-26 | 147 | review due |
| Bug Bounty Methodology SOP | [[sop-bug-bounty]] | 2026-04-25 | 3 | 2026-04-25 | 148 | review due |
| Cloud Pentesting SOP (Authorized) | [[sop-cloud-pentest]] | 2026-04-27 | 33 | 2026-04-26 | 147 | review due |
| Container & Kubernetes Pentesting SOP (Authorized) | [[sop-container-k8s-pentest]] | 2026-04-27 | 36 | 2026-04-27 | 146 | review due |
| Detection & Evasion Testing SOP (Purple Team) | [[sop-detection-evasion-testing]] | 2026-04-25 | 0 | — | — | no source checks |
| Firmware Reverse Engineering | [[sop-firmware-reverse-engineering]] | 2026-04-26 | 39 | 2026-04-26 | 147 | review due |
| Linux Pentesting SOP (Authorized) | [[sop-linux-pentest]] | 2026-04-25 | 5 | 2026-04-25 | 148 | review due |
| Mobile Security (iOS & Android) | [[sop-mobile-security]] | 2026-09-20 | 21 | 2026-04-26 | 147 | review due |
| Vulnerability Research SOP | [[sop-vulnerability-research]] | 2026-04-25 | 10 | 2026-04-25 | 148 | review due |
| Web Application Security Testing SOP | [[sop-web-application-security]] | 2026-09-20 | 8 | 2026-04-25 | 148 | review due |
| Wireless & RF Pentesting (Authorized) | [[sop-wireless-rf-pentest]] | 2026-04-26 | 31 | 2026-04-26 | 147 | review due |

---

**Generated:** 2026-09-20
