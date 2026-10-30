---
type: sop
title: Email & BEC Forensics SOP
description: "Scenario-centric Business Email Compromise forensics: email header forensics (Received-chain reconstruction, Authentication-Results parsing), SPF / DKIM / DMARC / ARC mechanics, lookalike-domain and brand-impersonation detection (IDN homograph, typosquatting, dnstwist patterns, CT-log monitoring), Microsoft 365 Get-MessageTraceV2 and Google Workspace Email Log Search, secure-email-gateway forensics (Mimecast / Proofpoint / Barracuda envelope-vs-header), phishing-kit static analysis (defensive — kit acquisition, telltale strings, AiTM detection), wire-recall pathway (SWIFT ISO 20022 pacs.008 / camt.056, Fedwire / SEPA recall mechanics, Financial Fraud Kill Chain, FBI IC3 reporting, FinCEN SAR triggers, beneficiary-bank coordination), and BEC scenario taxonomy (CEO fraud, vendor-invoice fraud, payroll-redirect, attorney-impersonation, real-estate / closing-funds, gift-card scam)."
tags:
  - sop
  - email-forensics
  - bec
  - dfir
  - incident-response
  - dmarc
  - dkim
  - spf
  - arc
  - phishing-kit
  - wire-recall
created: 2026-04-27
updated: 2026-10-30
template_version: 2026-09-20
---

# Email & BEC Forensics SOP

> **Authorized environments only.** Email and Business Email Compromise (BEC) forensics is a defensive discipline. This SOP covers post-incident reconstruction of email-vector incidents on tenants, mailboxes, and domains the investigator is authorized to access — incident-response retainer scope, internal SOC / DFIR work on infrastructure the team owns, regulator-directed examinations under appropriate authority, or law-enforcement collection backed by warrant / MLAT / preservation letter. It does **not** authorize unauthorized mailbox access, header-forging tradecraft, phishing-delivery methodology, or pivots into adversary infrastructure observed during the investigation. Phishing-kit *analysis* (acquisition, decomposition, IOC extraction) is in scope as defensive forensics; phishing-kit *delivery* (operating the kit against targets) is not. Cross-references: [[sop-legal-ethics|Legal & Ethics]] for jurisdictional framing, breach-notification clocks, and wire-fraud-statute interaction; [[sop-opsec-plan|OPSEC]] for investigator account and infrastructure hygiene during an active BEC incident; [[sop-forensics-investigation|Digital Forensics Investigation]] as the parent template for host / disk / memory parsing of derived artifacts (PST exports, header dumps, recovered phishing-kit archives); [[../../Investigations/Techniques/sop-collection-log|Collection Log]] for chain-of-custody discipline on every header export, eDiscovery package, and gateway-log pull; [[sop-saas-log-forensics|SaaS Log Forensics]] (sibling — SaaS-tenant identity / collaboration plane) for the mailbox-side of any BEC incident that pivots through an OAuth-consent grant or a credential-phishing → mailbox-rule pattern; [[sop-cloud-forensics|Cloud Forensics]] (sibling — IaaS plane) for cases where exfiltrated credentials lead to cloud-resource action; [[sop-malware-analysis|Malware Analysis]] (template parent for attachment / phishing-kit deep RE handoff); and [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] for fiat-banking pivots, Suspicious Activity Report (SAR) triggers, and Ultimate Beneficial Ownership (UBO) work downstream of wire fraud.

## Table of Contents

0. [Quick Mode](#quick-mode)
1. [Objectives & Scope](#1-objectives--scope)
2. [Pre-Engagement & Authorization](#2-pre-engagement--authorization)
3. [BEC Forensics Landscape](#3-bec-forensics-landscape)
4. [Email Header Forensics](#4-email-header-forensics)
5. [SPF Forensics](#5-spf-forensics)
6. [DKIM Forensics](#6-dkim-forensics)
7. [DMARC Forensics & Reporting Infrastructure](#7-dmarc-forensics--reporting-infrastructure)
8. [ARC Forensics](#8-arc-forensics)
9. [Lookalike-Domain & Brand-Impersonation Detection](#9-lookalike-domain--brand-impersonation-detection)
10. [M365 / Workspace Message Tracing](#10-m365--workspace-message-tracing)
11. [Secure-Email-Gateway Forensics](#11-secure-email-gateway-forensics)
12. [Phishing-Kit Analysis (Defensive)](#12-phishing-kit-analysis-defensive)
13. [Wire-Recall Pathway & Financial Recovery](#13-wire-recall-pathway--financial-recovery)
14. [Hand-off Boundaries](#14-hand-off-boundaries)
15. [Tools Reference](#15-tools-reference)
16. [Risks & Limitations](#16-risks--limitations)
17. [Common Pitfalls](#17-common-pitfalls)
18. [Real-World Scenarios](#18-real-world-scenarios)
19. [Related SOPs](#19-related-sops)
20. [External & Reference Resources](#20-external--reference-resources)

---

## Quick Mode

> One screen for an operator already mid-task. Every line points at the section
> that actually tells you how. This is an order-of-operations aid, not a
> substitute for the procedure.

**First hour — the money moves faster than the forensics**
- [ ] Wire-recall pathway opened in parallel with the analysis, not after it — [§13](#13-wire-recall-pathway--financial-recovery)
- [ ] Authorisation, scope and the disclosure clock confirmed — [§2](#2-pre-engagement--authorization)
- [ ] Original message preserved with full headers, before anyone "cleans up"

**Header chain, in this order**
- [ ] Received chain read bottom-up — [§4](#4-email-header-forensics)
- [ ] SPF — [§5](#5-spf-forensics) · DKIM — [§6](#6-dkim-forensics) · DMARC — [§7](#7-dmarc-forensics--reporting-infrastructure)
- [ ] ARC, if the message crossed a forwarder — [§8](#8-arc-forensics)

**Then the surrounding infrastructure**
- [ ] Lookalike domain and impersonation check — [§9](#9-lookalike-domain--brand-impersonation-detection)
- [ ] Tenant-side trace: rules, sign-ins, delegation — [§10](#10-m365--workspace-message-tracing)
- [ ] Gateway verdicts and why they missed — [§11](#11-secure-email-gateway-forensics)

**Stop and hand off**
- Analysis of the phishing kit stays defensive — [§12](#12-phishing-kit-analysis-defensive)
- Anything beyond the scope contract — [§14](#14-hand-off-boundaries)
- The victim's bank has its own SAR obligations; do not impede them — [§13](#13-wire-recall-pathway--financial-recovery)

---

## 1. Objectives & Scope

Email and BEC forensics is the discipline of reconstructing email-vector incidents — Business Email Compromise, vendor-invoice fraud, CEO impersonation, payroll-redirect, attorney-impersonation, real-estate / closing-funds fraud, and the broader family of social-engineering-via-email patterns — from the artifacts that survive: message headers, MTA hop records, authentication results (SPF / DKIM / DMARC / ARC), gateway logs, mailbox audit trails, and downstream financial-system records. The deliverable is a defensible reconstruction of who sent what, from where, with which authentication posture, what the recipient's mail flow did with it, what the recipient organization did about it, and where any wire / ACH / gift-card / cryptocurrency transfer ended up — with chain-of-custody equivalent to disk forensics.

This SOP is **scenario-centric**. The SaaS-tenant audit-log surface (Microsoft 365 UAL, Workspace Reports, Okta System Log, Slack Audit Logs, mailbox audit, inbox-rule forensics, OAuth-app token persistence) is the canonical evidence layer for the *identity / mailbox-compromise side* of a BEC and lives in [[sop-saas-log-forensics|SaaS Log Forensics]]. This SOP owns the **email-flow side** — the messages themselves, the headers they carried, the authentication results downstream MTAs recorded, the lookalike domains they came from, the gateways they passed through, and the financial pathway that paid out — and reconstructs the BEC scenario as a unified narrative that spans both planes.

### What this SOP owns

- **Email header forensics** — Received-chain reconstruction (top-down vs bottom-up reading), `Authentication-Results` parsing, MTA hop analysis with timestamp deltas, source-IP geolocation cross-walk, BIMI / VMC indicators, and the per-client header-rendering quirks (Outlook desktop vs OWA vs Gmail vs Apple Mail).
- **SPF forensics** — record evaluation, mechanism precedence (`all` / `include` / `a` / `mx` / `ip4` / `ip6` / `ptr` / `exists` / `redirect`), policy outcome (`Pass` / `Fail` / `SoftFail` / `Neutral` / `None` / `TempError` / `PermError`), include-explosion and the 10-DNS-lookup limit (RFC 7208 §4.6.4), `+all` / `~all` / `-all` / `?all` deployment posture, void-lookup limits, MX vs A-record evaluation.
- **DKIM forensics** — signature verification, selector lookup via DNS, key-rotation semantics, body-canonicalization (`relaxed` vs `simple`), header-canonicalization, the `l=` length-tag attack surface (signature-stripping / replay attacks), `t=` timestamp / `x=` expiry semantics, multi-signature messages, and key-strength expectations.
- **DMARC forensics** — policy evaluation (`p=none` / `p=quarantine` / `p=reject`), alignment (`adkim=r` / `adkim=s` / `aspf=r` / `aspf=s`, SPF aligned-with-`From`, DKIM aligned-with-`From`), aggregate (`rua`) and forensic (`ruf`) report parsing, `sp=` sub-domain policy, `pct=` percentage rollout, `fo=` failure-reporting options.
- **DMARC reporting infrastructure** — `rua` / `ruf` consumer setup (in-house parser, dmarcian, Valimail, Postmark DMARC, MXToolbox, Cloudflare DMARC Management, EasyDMARC), aggregation patterns, daily / weekly cadence, and analyst-report shapes.
- **ARC forensics** — `ARC-Authentication-Results`, `ARC-Message-Signature`, `ARC-Seal` chain reconstruction, ARC-instance numbering (`i=`), validation across mailing-list / forwarder hops, and the indirect-mail-flow problem ARC solves (mailing lists, vacation auto-forwards, Microsoft 365 transport rules) for chain-of-custody verification of authentication results.
- **Lookalike-domain detection** — IDN homograph (Punycode `xn--` representation, mixed-script, confusable-Unicode TR39), typosquatting (Levenshtein distance, keyboard-adjacency, character-substitution / -insertion / -deletion / -transposition), brand-confusable Unicode, registered-domain monitoring (Certificate Transparency log monitoring, dnstwist patterns, urlinsane, urlcrazy, DomainTools / Iris / threat intelligence in the Microsoft Defender portal (formerly Defender TI, ex-RiskIQ) / Group-IB visibility) [verify 2026-10-30], TLD-substitution patterns (`.com` → `.co` / `.cm` / `.com.<cctld>`).
- **M365 / Workspace message tracing** — `Get-MessageTraceV2` / `Get-MessageTraceDetailV2` (last 90 days, max 10 days per query; legacy `Get-MessageTrace` / `Get-MessageTraceDetail` cover 10 days and are "replaced by the Get-MessageTraceV2 cmdlet and will eventually be deprecated" per Microsoft) [verify 2026-10-30], `Start-HistoricalSearch` for report-driven pulls, `Get-MessageTrackingLog` (on-prem Exchange), Workspace **Email Log Search** (Admin console → Reporting → Email Log Search), Gmail BigQuery export message-level event surface, mailbox-side context cross-link to [[sop-saas-log-forensics|SaaS Log Forensics]] for inbox-rule and mailbox-audit forensics.
- **Secure-email-gateway forensics** — Mimecast Audits / Hold-Queue / Tracker, Proofpoint Smart Search / Threat Insight, Microsoft Defender for Office 365 Threat Explorer, Cisco Secure Email (formerly Ironport ESA) message tracking, Barracuda Email Gateway Defense / Email Security Gateway message logs, Sophos Central Email message search (the on-prem Sophos Email Appliance is end of life), recipient-side envelope-vs-header forensics.
- **Phishing-kit analysis (defensive)** — kit acquisition (open directory, archive download, takedown-coordinated copy), static analysis hooks (PHP / JavaScript / Python kit decomposition, hand-off to [[sop-malware-analysis|Malware Analysis]] for deeper RE), telltale strings (kit-author signatures, hardcoded exfil endpoints, anti-analyst checks), evilginx / modlishka / muraena adversary-in-the-middle (AiTM) detection signatures, infrastructure indicators (Cloudflare Tunnel, ngrok, serverless-host abuse, residential-proxy egress).
- **Wire-recall pathway** — SWIFT (ISO 20022 pacs.008; camt.056 cancellation) / Fedwire / SEPA / FedNow / SWIFT gpi (UETR) recall mechanics, FBI IC3 reporting workflow and Financial Fraud Kill Chain (FFKC), FinCEN SAR-filing triggers, FinCEN Rapid Response Program coordination, beneficiary-bank coordination, correspondent-banking layer (cross-link to [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — do not duplicate banking-pivot tradecraft), 24-hour / 48-hour / 72-hour recovery windows.
- **BEC scenario taxonomy** — CEO-fraud / wire-fraud, vendor-invoice fraud (VIF), payroll-redirect, attorney-impersonation, real-estate / closing-funds fraud, gift-card scam, account-compromise lateral, and the cryptocurrency-payout BEC variant (where the scenario reconstruction lives here; on-chain trace hands off to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]).
- **BEC monetary-recovery timeline** — 24h / 48h / 72h windows, wire-recall vs ACH-recall vs check-recall mechanics, fraud-claim-to-bank, IC3 within 72 hours of the wire, insurance-carrier notification, and the policy-coverage interaction with social-engineering vs computer-fraud riders.

### Hard exclusions (out of scope)

- **IaaS / cloud-provider control plane.** AWS CloudTrail, Azure Activity Log + Resource Logs, GCP Cloud Audit Logs, IAM forensics on cloud resources, container / Kubernetes runtime, and snapshot preservation all live in [[sop-cloud-forensics|Cloud Forensics]]. When a BEC pivots into stolen cloud credentials and the attacker acts on cloud resources, the email side stays here; the cloud-resource action routes to [[sop-cloud-forensics|Cloud Forensics]].
- **SaaS-tenant identity / collaboration audit (the mailbox-compromise side of a BEC).** Microsoft 365 Unified Audit Log, mailbox audit log (`Search-UnifiedAuditLog -RecordType ExchangeItem` / `ExchangeItemGroup` / `ExchangeItemAggregated` — `MailItemsAccessed` lands in `ExchangeItemAggregated`; Microsoft says `Search-MailboxAuditLog` "will be deprecated in the cloud-based service"; `Search-UnifiedAuditLog` returns 100 records by default, so for more set `$sid = "case-$([guid]::NewGuid())"` once per record type, then run `do { $page = Search-UnifiedAuditLog ... -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000; $page } while ($page)` — a new SessionId restarts at the first block, so never generate it inside the loop; max 50,000 per session) [verify 2026-10-30], inbox-rule forensics (`Get-InboxRule`, UAL `New-InboxRule` / `Set-InboxRule` / `Remove-InboxRule`), OAuth-app token-persistence forensics, `oauth2PermissionGrants` enumeration, Workspace Admin SDK Reports API, Okta System Log, Slack Audit Logs, Salesforce Setup Audit Trail, GitHub audit and the cross-tenant collaboration surface all live in [[sop-saas-log-forensics|SaaS Log Forensics]]. **The OAuth-consent BEC variant lives in [[sop-saas-log-forensics|SaaS Log Forensics]].** This SOP references the carve-in but does not duplicate that SOP's §10 OAuth Consent-Grant Abuse Forensics methodology; when the BEC pattern is "attacker tricks user into granting an OAuth app permission to read mailbox," that is SaaS Log Forensics' surface. The header-spoofing BEC, lookalike-domain BEC, and pure-social-engineering BEC variants live here.
- **Mailbox-rule / mailbox-audit forensics.** When the BEC pivots into mailbox compromise (credential phishing → adversary-in-the-middle session-token capture → mailbox-rule auto-forward → wire diversion), the mailbox-side reconstruction is owned by [[sop-saas-log-forensics|SaaS Log Forensics]] §4.5–§4.6. This SOP covers what the inbound and outbound *messages* looked like; the mailbox-audit log of who-accessed-what is SaaS Log Forensics' surface.
- **General malware analysis of attachments.** When a BEC incident includes a malicious attachment (Office macro dropper, ISO / IMG container, HTA, LNK, OneNote with embedded payload), this SOP covers the email-as-vector framing — header pivot, gateway disposition, recipient-side delivery — and hands off the binary / document analysis itself to [[sop-malware-analysis|Malware Analysis]] §3 (Rapid Triage), §4 (Behavior), §6.2 (Office / Macro), §6.3 (PDF), §6.4 (Script Analysis), §6.5 (Archive), §6.7 (HTA), §6.8 (Disk Image / ISO). Phishing-kit *analysis* is in scope here per §12 below; deep static / dynamic RE of harvested kits routes to [[sop-malware-analysis|Malware Analysis]] / [[sop-reverse-engineering|Reverse Engineering]].
- **Smart-contract / on-chain forensics.** When a BEC payout is in BTC / USDT / USDC / ETH or another on-chain rail (the cryptocurrency-payout BEC variant is increasingly common), the scenario reconstruction (which message, which lookalike domain, which payout instruction, which wallet address surfaced in the message body) lives here; the on-chain trace once funds are deposited routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]. Mixer / privacy-pool laundering downstream routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. Smart-contract code review (when the payout funnels through a contract) routes to [[sop-smart-contract-audit|Smart Contract Audit]].
- **Fiat AML / SAR-filing / banking-pivot tradecraft.** [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] is the canonical SOP for SAR-filing decision criteria, the structuring / smurfing / shell-company / UBO investigative patterns, and the broader correspondent-banking / SWIFT-network tradecraft. This SOP covers wire-recall *operations* (the mechanics of getting money back; the IC3 / FFKC / SWIFT camt.056 cancellation path) and routes the *intelligence* / *typology* / *AML-analyst* layer to [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]].
- **General host / disk / memory forensics.** Disk imaging, memory acquisition, MFT / USN / Prefetch / Amcache / ShimCache / registry-hive parsing, Volatility 3, and timeline construction live in [[sop-forensics-investigation|Digital Forensics Investigation]] (parent template). When a BEC investigation produces a recovered laptop (a victim user device, an authorized seizure of an adversary endpoint, a phishing-kit operator's host), the host-forensics side routes to the parent template; this SOP terminates at "the email and the financial pathway."
- **Offensive phishing / red-team email tradecraft.** Pre-engagement target enumeration, payload crafting, lure design, evasion of secure-email-gateways, sender-reputation warm-up, and click-rate / credential-harvest operations are red-team / social-engineering disciplines. Currently no Intel Codex SOP owns offensive phishing. Forensic readers benefit from understanding the offensive playbook as the threat model but should not derive offensive instructions from this SOP. Phishing-kit *analysis* (decomposing a recovered kit defensively) is explicitly in scope; phishing-kit *operation* is not.
- **Sensitive-crime hard-stops.** CSAM in attachments / linked content; trafficking-pattern indicators in BEC-adjacent extortion / sextortion mail; threat-to-life findings — all hard-stop to [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]]. Treat as URL / file-hash / timestamp only; **do not preserve content**; provider-LE process is the route. Same posture as the darkweb, cloud-forensics, and SaaS-log-forensics SOPs.

### Engagement types covered

- **Active wire-fraud incident.** Customer reports a fraudulent wire just sent (or just received-and-paid); minutes matter for recall. The BEC reconstruction is concurrent with the financial-recovery operation.
- **Post-payment forensic review.** Wire is gone, recall window has closed; the engagement is forensic reconstruction for insurance, regulator notification, board reporting, civil litigation, or LE referral.
- **Suspected-but-unconfirmed BEC.** A user reports a "suspicious email" that *might* have been acted on; the engagement is to determine whether action occurred and what the blast radius is.
- **Vendor-invoice-fraud campaign retrospective.** A vendor reports their customers are receiving fake invoices; engagement is to reconstruct the campaign's footprint and notification scope.
- **Domain-impersonation discovery.** A brand-protection alert (CT-log, dnstwist, threat-intel feed) flags a registered lookalike domain; engagement is to determine whether mail has been sent from it, by whom, to whom.
- **Litigation-driven retrospective.** A wire-fraud case has moved to civil discovery; engagement is to produce a forensically-defensible reconstruction supporting depositions / expert testimony.

---

## 2. Pre-Engagement & Authorization

### Authorization Checklist

- [ ] **Written engagement letter or internal IR activation** identifying the affected mailbox(es), domain(s), tenant(s), the time window of interest, and the scope of authorized actions (read-only message-trace pull? mailbox export? domain DNS-record query? SEG-log retrieval? wire-recall operation in the customer's name? IC3 referral? FinCEN SAR participation?). State-changing actions (mailbox-rule disablement, sender block, domain take-down request, wire-recall) are billable, durable, and visible in audit logs of the systems they touch — written scope matters.
- [ ] **Tenant-administrator authorization** for the message-trace / SEG-log / mailbox-export surfaces. Use a dedicated investigator admin account / app-registration / API token per engagement — not a re-used personal identity — and rotate at engagement end. M365: dedicated cloud-only Global Reader + eDiscovery Manager + Compliance Search role; Workspace: dedicated investigator admin with Reports / Vault / Email Log Search; Mimecast / Proofpoint / Defender / Barracuda: dedicated read-only console role per engagement.
- [ ] **Sender-domain-owner authorization where the sender is the customer's own.** When the BEC was a *spoofed* CEO of customer A targeting an employee of customer A, the customer authorizes investigation. When the spoofed sender is a *third party's* domain (a vendor whose identity was impersonated to attack a customer), notification of the third party is a downstream disclosure obligation; pre-engagement check that this is on the disclosure plan.
- [ ] **Provider legal process where the customer cannot authorize collection on their own.** For cross-tenant evidence (the attacker's tenant is on the same provider; the recipient organization is not the customer; the upstream MTA is a third-party SEG) the provider's law-enforcement portal is the route. Microsoft, Google, Proofpoint, Cloudflare, AWS (SES), Twilio (SendGrid) and Sinch (Mailgun) publish law-enforcement / legal-process guidance; the required instrument (subpoena / warrant / MLAT / preservation letter) depends on data type and jurisdiction [verify 2026-10-30].
- [ ] **Cross-border data residency review.** EU-data-subject mail content (GDPR), healthcare (HIPAA), card data (PCI), and government tenants all carry residency / sovereignty constraints. Verify under counsel before exporting message content to investigator storage outside the source region — see [[sop-legal-ethics|Legal & Ethics]] for Schrems II / DPF / SCCs framing.
- [ ] **Disclosure pathway agreed.** Notification clocks are jurisdiction- and sector-specific — GDPR Art. 33 (72h to supervisory authority), GDPR Art. 34 (high-risk-to-data-subject notice), HIPAA Breach Notification Rule (60-day), state breach-notification laws (US), SEC cyber-disclosure rule for material incidents at registrants, NYDFS Part 500, NIS2 (EU), DORA (EU financial). Wire fraud also triggers FinCEN SAR considerations for the customer's bank under the Bank Secrecy Act and 31 CFR 1020.320 [verify 2026-10-30]; the customer's financial institution has independent SAR obligations the investigation should not impede.
- [ ] **IC3 / FFKC pre-positioning.** When the engagement begins inside the 72-hour wire-recall window, the IC3 referral and Financial Fraud Kill Chain (FFKC) request are time-critical. Pre-engagement: the customer has the wire confirmation, the originating-bank fraud team, and beneficiary-bank details ready; the investigator coordinates the timeline rather than owning the customer's banking relationship. See §13 below.
- [ ] **Insurance-carrier notification.** Cyber and crime policies have notification clocks (often 24-72 hours from discovery, sometimes "immediate"); failure to notify can void coverage. Confirm carrier and policy before any state-changing action that might affect the claim — under counsel.
- [ ] **OAuth-app inventory baseline.** When the engagement involves any mailbox-compromise pivot (most non-trivial BEC), an OAuth-app inventory is established before any state-changing action — multi-tenant apps consented in the tenant, app-only permissions, refresh tokens active. Per [[sop-saas-log-forensics|SaaS Log Forensics]] §2, the baseline is: M365 `Get-MgServicePrincipal` / `Get-MgOauth2PermissionGrant`; Workspace App Access Control + connected-apps export; Salesforce Connected Apps Usage; GitHub org-level OAuth + PAT inventory.

### Lab Environment Requirements

- **Dedicated investigator tenant or analyst seat** in each SaaS / SEG surface, separate from the affected tenant. Header dumps, message exports, and analysis derivatives land here, never back into the affected tenant. The investigator's M365 / Workspace / Mimecast / Proofpoint identity is engagement-scoped, not their personal cloud identity.
- **Investigator workstation** disk-encrypted, isolated from production, no auto-sync of artifacts to corporate storage, dedicated browser profiles or container tabs per tenant. PowerShell 7+ for Exchange Online; `gcloud` + GAM7 (installs as `gam`) for Workspace; `dnstwist`, `dnsx`, `mxtoolbox`-CLI-equivalents (`dig`, `drill` from ldns), `swaks` for SMTP testing in a sandbox lane only (never against production with real targets), `parsedmarc` for DMARC-report parsing [verify 2026-10-30].
- **Encrypted-at-rest investigator storage.** Exported message bodies and attachments may contain customer-confidential material, third-party PII, or LE-sensitive evidence; encrypted with engagement-specific keys; access-controlled.
- **Time-sync discipline.** All analysis systems running NTP / chrony to a known source; time-zone normalized to UTC end-to-end; investigator note timestamps use ISO 8601 / RFC 3339 with explicit `Z` suffix per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Email systems report event times with mixed precision and time-zone hints — Received-header `;` clauses use the RFC 5322 §3.3 date-time format with numeric offset; Microsoft `MessageTrace` is UTC; Workspace Email Log Search exports UTC; Mimecast `received_date` is UTC; Proofpoint Smart Search is UTC; recipient mail-client display rendering localizes silently. Capture authoritative-source timestamps, not display-rendered ones.
- **API-throttling awareness.** Production tenants under stress will rate-limit aggressive forensic queries. Exchange Online message trace (`Get-MessageTraceV2` / `Get-MessageTraceDetailV2`) accepts at most 100 query requests per tenant in a 5-minute running window; message-trace support in the legacy Reporting Web Service began deprecating on 8 April 2026 and is replaced by the Microsoft Graph message-trace API — script against Graph [verify 2026-10-30]. Workspace Reports API has per-customer quotas. Mimecast, Proofpoint, and Defender have console-driven retrieval that masks API limits; bulk pulls require API tokens.
- **Read-only by default.** Investigator tokens / roles should not include sender-block, mailbox-rule disablement, message-purge (Defender Threat Explorer's "Move to junk folder," "Move to inbox," "Move to deleted items," "Soft delete," "Hard delete" actions), or domain-take-down permissions unless explicitly authorized. The forensic record is more defensible when state-changing actions are gated behind a separate, narrowly-scoped account.

### Disclosure-Ready Posture

BEC-forensics findings frequently land with the customer's bank, with regulators, with insurers, with law enforcement (FBI, Secret Service, state AGs), and with civil litigators. Stage the deliverable shape early:

- **Chain-of-custody record** opened at engagement start — every header pull, every message export, every gateway-log export, every DNS query against suspect domains recorded per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Hash every exported artifact (SHA-256 baseline) at the moment of export; record source-system, source-API endpoint, time range, executing principal, and destination URI.
- **Evidence-handling policy** decided before the first pull: retention period for engagement artifacts, encryption-at-rest standard, access list, deletion / handover discipline at engagement end. Wire-fraud cases frequently move to civil litigation 6-24 months after the incident; engagement artifacts may need to survive that window.
- **Reporting timeline** agreed: interim notes (often hourly during active recall), interim summary (daily for the first week), final report. BEC incidents move fast on the recovery side and slow on the reconstruction side; the regulator / customer / counsel may need an interim summary by hour 4-12 even when the full reconstruction will take weeks.
- **Disclosure pathway** for findings touching third parties — a vendor whose identity was impersonated; a customer whose mailbox the attacker monitored to time the pivot; an upstream SEG vendor whose detection failed. Coordinate with [[sop-legal-ethics|Legal & Ethics]] and [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]].

---

## 3. BEC Forensics Landscape

### 3.1 Why BEC Forensics Is Different from General DFIR

BEC reconstruction shares the high-level discipline of [[sop-forensics-investigation|Digital Forensics Investigation]] (chain-of-custody on evidence; methodical timeline; defensible documentation) but differs in three structural ways:

1. **The artifact is a message, not a host.** The dominant evidence is in headers, gateway logs, and audit trails — none of which the investigator typically *imaged*. The forensic surface is a *living* mail flow that the investigator queries through provider APIs; what is preserved at query time is what survives. Hold-first discipline (per [[sop-saas-log-forensics|SaaS Log Forensics]] §12) is non-negotiable when the mailbox-side is in scope.
2. **Money is moving in real time.** Most BEC investigations open with "we just sent / received a fraudulent wire" or "the wire is going out tomorrow." The 24h / 48h / 72h recall windows (§13) make BEC the rare DFIR sub-discipline where the *reconstruction* and the *recovery* run concurrently. The IR team coordinates with the customer's bank, IC3, and FinCEN while header analysis is still in progress.
3. **The attacker disappears at the SMTP boundary.** BEC operators sit behind residential proxies, hijacked SMTP relays, free-mail providers (Gmail / Outlook.com / ProtonMail), commodity bulk-mailer infrastructure (SendGrid / Mailgun / Amazon SES — not because those vendors permit abuse, but because abuse leaks into them and detection takes time), or compromised legitimate sender infrastructure. Source-IP attribution is bounded; the forensic prize is *pattern* (kit fingerprint, infrastructure overlap, lookalike-domain registrar pattern, payout typology) more often than *attribution* to a named actor.

### 3.2 BEC Scenario Taxonomy

The FBI IC3 BEC working definition covers a family of scenarios. Investigators benefit from naming the scenario early — the timeline, the evidence priorities, and the recovery options vary materially.

| Scenario | Pretext | Typical action | Header / authentication signature | Recovery posture |
|---|---|---|---|---|
| **CEO fraud / wire fraud** | Spoofed executive directs employee to wire funds urgently | Wire transfer to attacker-controlled bank account | `From:` lookalike / display-name spoof; `Reply-To:` to free-mail; SPF / DKIM may pass on a separate sender domain | IC3 + FFKC; recall via originating bank within 24-72h |
| **Vendor-invoice fraud (VIF)** | Spoofed or compromised vendor sends "updated banking details" before a real invoice falls due | Wire / ACH to redirected beneficiary | `From:` spoofed vendor or compromised vendor mailbox; thread-hijack into legitimate prior conversation | IC3 + bank coordination; vendor's own IR engaged in parallel |
| **Account-compromise lateral** | Attacker compromises mailbox A and uses it to spoof internal targets, contacts, customers | Mail-hijack with attacker reading inbound replies | Authentic SPF / DKIM / DMARC because mail is from a legitimate compromised mailbox; mailbox-rule + reply-redirect persistence | Mailbox-side reconstruction routes to [[sop-saas-log-forensics|SaaS Log Forensics]]; this SOP covers the outbound-message footprint |
| **Payroll redirect** | Spoofed or compromised employee asks HR / payroll to update direct-deposit account | ACH to attacker-controlled account | `From:` spoofed or compromised employee; HR portal misuse downstream | The employer originated an ACH credit, so ask the originating bank at once to request a recall / reversal (with a Hold Harmless Letter or Letter of Indemnity) and file with IC3; the unauthorized-debit return windows (R10 / R29) do not cover a credit the victim sent [verify 2026-10-30] |
| **Attorney impersonation** | Spoofed law firm or M&A counsel directs urgent confidential wire | Wire transfer; pretext invokes confidentiality to suppress verification | `From:` lookalike firm domain; legitimate-looking signature block; pressure to bypass verification policy | IC3 + bank; civil discovery subpoenas downstream |
| **Real-estate / closing-funds fraud** | Spoofed title agent or closing attorney redirects buyer's down-payment / closing funds | Wire transfer at closing | Lookalike title-agent domain; thread-hijack into legitimate closing chain; well-rehearsed timing | IC3 + bank; ALTA escrow procedures; FBI Real Estate Wire Fraud guidance |
| **Gift-card scam (BEC-adjacent)** | Spoofed executive directs urgent gift-card purchase for "client appreciation" / "team lunch" | Apple / Google Play / Amazon gift-card codes sent back | Free-mail `From:` or display-name spoof; mobile-text follow-up common | Generally unrecoverable; reporting to retailer fraud teams; pattern attribution |
| **Cryptocurrency-payout BEC** | Any of the above scenarios but payout is BTC / USDT / USDC / ETH to an attacker-controlled wallet | On-chain transfer | Same as base scenario; payment instruction includes wallet address (or QR code) | On-chain trace via [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; sanctions-screening overlay; recall is generally not feasible — focus on trace + freeze-at-CEX |

The scenarios overlap and chain. A vendor-invoice-fraud often follows a successful account-compromise of the vendor; a real-estate fraud often pairs lookalike-domain BEC against the buyer with thread-hijack against the title agent. The investigator names the *primary* scenario for the report's classification line and tracks chained patterns separately.

### 3.3 The Financial Fraud Kill Chain (FFKC)

The FBI IC3 Financial Fraud Kill Chain is a coordination mechanism, run by the IC3 Recovery Asset Team, for freezing funds from fraudulent transfers. IC3 publishes no dollar threshold: "Regardless of the amount lost, file a complaint with www.ic3.gov as soon as possible" (IC3 PSA, 11 September 2024). Speed is the criterion that matters — FinCEN is "most likely to be able to interdict or recover funds when fraudulently induced wire transfers are reported to law enforcement within 72 hours of the transaction" (FinCEN Rapid Response Program fact sheet, April 2026). The older USD 50,000 / SWIFT MT103 / 72-hour / international-beneficiary eligibility list is historical and unpublished; never use it as a reason to skip a filing [verify 2026-10-30]. For international transfers the coordination invokes the FBI legal attaché in the destination jurisdiction, the foreign financial-intelligence unit (FIU), and the beneficiary bank. Recovery rates depend heavily on speed of activation.

The investigator does not own the FFKC request — the IC3 Recovery Asset Team initiates it from an IC3 complaint filed by the customer or the customer's bank, often coordinated through the customer's legal counsel and the FBI field office. The investigator's role is to *enable* the activation: produce the BEC reconstruction (the email; the lookalike domain; the social-engineering chain) that the FBI and the bank will reference, and produce the wire-confirmation cross-walk (the customer's wire reference, the SWIFT GPI Unique End-to-End Transaction Reference (UETR), the originating-bank reference, the beneficiary-bank reference, the beneficiary account / IBAN).

### 3.4 Monetary-Recovery Timeline

| Window from wire-send | What is feasible | Action |
|---|---|---|
| **0-4 hours** | Wire may still be in originating-bank or correspondent-bank queue | Customer's bank requests recall; SWIFT cancellation request (camt.056) issued; FedNow has its own cancel path; customer files at IC3 immediately (no dollar threshold) |
| **4-24 hours** | Wire is at beneficiary bank but funds may be unwithdrawn / on hold | Beneficiary bank receives recall; if funds untouched, freeze and return are the most likely outcome |
| **24-72 hours** | Funds typically dispersed onward to secondary accounts / ATM withdrawal / FX conversion | IC3 RAT / FFKC follow-up; FBI legal attaché engages destination FIU; civil restraining order in destination jurisdiction may be possible |
| **72h - 30 days** | Funds gone; investigation pivots to civil action and AML / SAR-driven typology trace | Civil discovery; SAR-driven correlation; partial recovery via destination-bank cooperation possible |
| **>30 days** | Recovery is uncommon | Insurance claim; tax loss; LE referral pursued primarily for prosecution / disruption |

ACH recall is shorter and more rigid than wire — the receiving (account-holder's) bank can return an unauthorized debit to a consumer account within 60 days (Nacha R10; Reg E 60-day dispute window), but only if the consumer disputes; for non-consumer (B2B) accounts the unauthorized-debit return (R29) window is 2 banking days under the Nacha Operating Rules [verify 2026-10-30]. An ACH credit the victim originated (payroll redirect, vendor payment) is not an unauthorized debit; the originating bank requests a recall / reversal instead (§13.6). Check fraud is governed by UCC Articles 3 (Negotiable Instruments) and 4 (Bank Deposits and Collections). Cryptocurrency payouts are not recallable; the equivalent recovery operation is *seizure-at-CEX* via the destination centralized exchange's compliance team, downstream of the on-chain trace per [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]].

### 3.5 Email-Authentication Posture as a Forensic Tell

A single message carries six layers of authentication context. Each layer is a forensic data-point.

| Layer | What it captures | Forensic tell when present | Forensic tell when absent |
|---|---|---|---|
| **SPF** | Did the sending IP match the `From`-domain's published list? | Pass on a domain whose owner did not send = sender-IP is in the published list (legitimate or hijacked relay) | Fail / SoftFail / Neutral / None — `From`-domain owner did not authorize this sender |
| **DKIM** | Did the message carry a valid signature from a key published in the signing domain's DNS? | Pass = signing domain controls the message body and signed-header fields; signing domain may differ from `From`-domain | Fail / Missing — body modified post-signature, or signing domain absent |
| **DMARC** | Does SPF or DKIM align with `From`-domain, and what does the domain owner's policy say to do otherwise? | Pass = at least one of SPF / DKIM is aligned with `From` | Fail + `p=none` = monitoring only, message delivered; Fail + `p=quarantine` / `p=reject` = blocked at MTA |
| **ARC** | Did intermediate forwarders preserve auth-state through the transit path? | Validated chain across mailing-list / forwarder hops | Broken chain or absent — auth-state at receiver may not reflect origin |
| **BIMI / VMC** | Is the sender's brand logo cryptographically tied to a verified mark? | Logo display = DMARC-enforcing sender + verified mark certificate | Absent = neutral (most senders do not deploy BIMI yet) |
| **Mail-flow gateway disposition** | What did the recipient SEG / mailbox provider do? | Delivered / Quarantined / Blocked / Stripped / Released | Disposition gap may indicate gateway misconfiguration or attacker bypass |

A BEC that passed all layers (SPF + DKIM aligned, DMARC pass, ARC clean, gateway delivered) is generally either a **compromised legitimate mailbox** (attacker sent from inside) or a **lookalike domain that established its own clean authentication** (attacker registered domain, set SPF / DKIM, and waited). The reconstruction approach differs.

---

## 4. Email Header Forensics

### 4.1 Reading Headers Top-Down vs Bottom-Up

Email headers are added in *receiving* order — the **bottom-most** `Received:` header is the *earliest* hop (typically the originating MTA, or a relay near it). The top-most `Received:` header is the *most recent* hop (typically the recipient's MTA). Forensic header reading is bottom-up: walk from the bottom `Received:` upward, building the MTA-hop graph. Headers added by the sender (`From:`, `Reply-To:`, `Subject:`, `Date:`, `Message-ID:`) are user-controlled and unauthenticated unless cross-validated against `Received:` and authentication results.

### 4.2 The Received-Chain

Each `Received:` header is structured per RFC 5321 §4.4:

```
Received: from <sending-system> (<helo-or-ehlo-name> [<sender-IP>])
        by <receiving-system> (<receiver-software>)
        with <protocol> id <queue-id>
        for <envelope-recipient>;
        <date-and-time-with-offset>
```

Hop graph reconstruction:

1. **Bottom-most `Received:`** — the originating MTA's first record. Capture the `from` field (claimed sender hostname), the `helo-or-ehlo-name` (also claimed), the bracketed source IP (the receiver's observation — the most reliable origin field), the `id` (queue ID at the receiving MTA — useful for cross-walking the receiver's logs), and the `;`-delimited timestamp.
2. **Walk upward** — at each hop, the source IP of the incoming connection should equal the destination of the previous hop. Gaps (a receiver claims to have received from IP X but no prior hop terminated at X) suggest header injection or a missing hop.
3. **Geo-cross-walk source IPs** — `whois`, `mtr`, `bgp.he.net`, `peeringdb.com`, MaxMind, IPinfo, RIPE NCC, ARIN, LACNIC, AFRINIC, APNIC. Residential-proxy vendors (Bright Data (ex-Luminati), Decodo (ex-Smartproxy), Oxylabs, NetNut, IPRoyal), bulk-mailer ASNs (SendGrid AS11377, Mailgun AS396479, Amazon SES on AS16509, etc.), and commodity-host ASNs (Hetzner AS24940, OVH AS16276, DigitalOcean AS14061, Vultr AS20473, Contabo AS51167) are pattern signals — confirm the current holder on bgp.he.net or RIPEstat at investigation time [verify 2026-10-30]; not every sender from these ASNs is malicious, but BEC operators concentrate there.
4. **Hop-time anomalies** — adjacent `Received:` headers have monotonically increasing timestamps within sane bounds (seconds, sometimes minutes for queued mail). Out-of-order or far-apart timestamps suggest header forgery, mailing-list batching, or an MTA queue.

### 4.3 The `Authentication-Results` Header

RFC 8601 defines the `Authentication-Results:` header. The **trusted** `Authentication-Results:` for a given message is the one added by an MTA the recipient trusts — typically the recipient's own boundary MTA or the recipient's mailbox provider. Earlier `Authentication-Results:` added by upstream MTAs are advisory only.

Example (Microsoft 365 — Exchange Online Protection inserts):

```
Authentication-Results: spf=pass (sender IP is 198.51.100.10)
        smtp.mailfrom=example.com; dkim=pass (signature was verified)
        header.d=example.com;dmarc=pass action=none
        header.from=example.com;compauth=pass reason=100
```

Fields to extract:

- **`spf=`** — `pass` / `fail` / `softfail` / `neutral` / `none` / `temperror` / `permerror`. The `smtp.mailfrom` (or `smtp.helo` for null sender) records the identity SPF was evaluated against.
- **`dkim=`** — per-signature result; multi-signature messages produce multiple `dkim=` lines. The `header.d=` records the signing domain; `header.s=` records the selector; `header.i=` records the agent / user identifier.
- **`dmarc=`** — `pass` / `fail` / `bestguesspass` (some receivers) / `none`. In Microsoft 365 the `action=` records what the spam filter did with the DMARC result — `none`, `oreject`, `pct.quarantine` / `pct.reject` (DMARC failed but the message was delivered because the policy's `pct` was below 100), `permerror`, `temperror` [verify 2026-10-30]; `header.from=` records the `From`-domain DMARC was evaluated for.
- **`compauth=`** — Microsoft's composite authentication result; `pass` / `softpass` / `fail` / `none`; `reason=` carries a three-digit code: `000` explicit fail (DMARC fail with `p=quarantine` / `p=reject`), `001` / `6xx` implicit fail, `002` org policy prohibits spoofing for that sender/domain pair, `010` DMARC fail with `p=quarantine` / `p=reject` on an accepted domain, `1xx` / `7xx` pass, `2xx` softpass, `3xx` not checked, `4xx` / `9xx` bypassed, `501` / `502` DMARC not enforced (valid NDR) — see Microsoft's compauth reason-code table [verify 2026-10-30].
- **`arc=`** — when ARC-aware MTAs participated; `pass` / `fail` / `none` records the ARC chain validation.

### 4.4 Microsoft 365 `X-` Headers Cheat-Sheet

Microsoft 365 / Exchange Online Protection adds a family of `X-MS-` and `X-Microsoft-` headers carrying transport-rule, anti-spam, and anti-phish disposition.

| Header | Forensic value |
|---|---|
| `X-Forefront-Antispam-Report` | `CIP=` source IP, `CTRY=` country, `LANG=` body language, `SCL=` spam confidence (-1, 0-9; no longer determines the cloud verdict — read `CAT=` and `DIR=` instead), `SFV=` spam filter verdict (`SPM`, `BLK`, `SKA`, `SKQ`, `NSPM`, `SKB`, `SKI`, `SKN`, `SKS`, `SFE`) [verify 2026-10-30], `IPV=` IP-reputation verdict, `H=`/`HELO=` HELO string, `PTR=` reverse-DNS |
| `X-Microsoft-Antispam` | `BCL=` bulk complaint level — the only documented field; Microsoft says the other fields are for its anti-spam team's diagnostics [verify 2026-10-30] |
| `X-Microsoft-Antispam-Mailbox-Delivery` | Per-mailbox delivery decision; junk-folder routing |
| `X-MS-Exchange-Organization-AuthAs` | For hybrid mail-flow triage Microsoft says to focus on two values: `Anonymous` (unauthenticated / external) vs `Internal` (authenticated in some way: an Exchange Online or on-premises mailbox, or a connector treated as internal) [verify 2026-10-30] |
| `X-MS-Exchange-Organization-AuthSource` | The receiving server identity |
| `X-MS-Exchange-Organization-MessageDirectionality` | `Originating` (outbound) vs `Incoming` (inbound) |
| `X-MS-Exchange-Organization-Network-Message-Id` | The Microsoft NetworkMessageId — this is the cross-walk key into Defender Threat Explorer and Get-MessageTrace |

Workspace adds `X-Google-Smtp-Source`, `X-Received` (Google variant), and the Gmail-specific `X-Gm-Message-State`; these are undocumented internal fields, so treat any `X-Gm-*` verdict as unofficial and use Email Log Search for the authoritative Gmail disposition. SEG vendors layer their own — Mimecast adds `X-Mimecast-`-prefixed fields, Proofpoint adds `X-Proofpoint-`-prefixed, Barracuda adds `X-Barracuda-`-prefixed; treat each as an additional disposition data-point but evaluate the trusted `Authentication-Results:` first.

### 4.5 IP-Geolocation Cross-Walk

For each candidate origin IP from the bottom-most `Received:`:

```bash
# whois (RIR-authoritative)
whois 198.51.100.10

# Reverse DNS
dig -x 198.51.100.10 +short

# BGP / ASN — bgp.he.net is convenient; CLI alternatives:
whois -h whois.cymru.com " -v 198.51.100.10"

# Commercial geolocation (require API keys; MaxMind web services use geoip.maxmind.com) [verify 2026-10-30]
curl -s "https://ipinfo.io/198.51.100.10?token=$IPINFO_TOKEN" | jq
curl -s "https://geoip.maxmind.com/geoip/v2.1/insights/198.51.100.10" \
  -u "$MAXMIND_USER:$MAXMIND_LICENSE" | jq
```

Geolocation is approximate and is most reliable at the **country / ASN** level; sub-country-level inference is brittle and should not be presented as definitive. Residential proxies, VPNs, and Tor exit nodes will geolocate to consumer ISPs and present low-signal location data. The forensic value is the *combination* (ASN + country + reverse-DNS pattern + WHOIS abuse contact + observed mail-flow pattern) rather than any single field.

### 4.6 BIMI / VMC

Brand Indicators for Message Identification (BIMI — no RFC; IETF Internet-Draft `draft-brand-indicators-for-message-identification`) lets a brand publish a logo at `default._bimi.<domain>` whose display in the recipient mail client is conditioned on DMARC-pass with `p=quarantine` or `p=reject` and (for major implementers Gmail and Apple Mail) a Verified Mark Certificate (VMC) — Gmail also accepts a Common Mark Certificate (CMC) — issued by a Mark Verifying Authority (MVA) [verify 2026-10-30]. Forensic uses:

- **Sender-side** — the existence of a published BIMI record and a valid VMC indicates a brand that has invested in mail-authentication and is unlikely to be the legitimate sender of an SPF-fail / DKIM-fail message; an alleged-sender brand whose BIMI is *not* configured can still be impersonated.
- **Recipient-side** — when the recipient client renders a brand logo, the message was DMARC-aligned and the logo was VMC-validated (Gmail, Apple Mail) or CMC-validated (Gmail) at the time of rendering. This is provenance evidence; capture the logo and the BIMI / VMC records at investigation time, since they can change.

```bash
# Inspect a domain's BIMI record
dig default._bimi.example.com TXT +short
# Returns the `v=BIMI1; l=https://...; a=https://...` record

# Fetch the VMC (PEM-encoded X.509)
curl -sL https://example.com/vmc.pem | openssl x509 -text -noout
```

### 4.7 Header-Capture Discipline

- **Capture `.eml` / RFC 5322 source, never rendered HTML.** Outlook desktop "Save As" → `.msg` is acceptable but proprietary; for archival, pull the MIME source as `.eml` via Microsoft Graph `GET /users/{id}/messages/{id}/$value`. In Outlook on the web, More actions → View → View message details shows the full header block. `Get-MessageTrace` returns trace metadata, not message content [verify 2026-10-30]. Workspace: **Show Original** in Gmail UI, then **Download Original**.
- **Hash at capture.** SHA-256 of the `.eml` file at the moment of export.
- **Preserve the trusted `Authentication-Results:` line.** When forwarding to an investigator (a bad practice — forwarding strips and rewrites authentication) is unavoidable, accompany the forwarded copy with a screenshot of the trusted `Authentication-Results:` and include a header-only export.
- **Store as evidence-grade.** Per [[../../Investigations/Techniques/sop-collection-log|Collection Log]] §4 evidence-packaging discipline; per-engagement encrypted archive, manifest with hashes.

---

## 5. SPF Forensics

### 5.1 SPF Record Anatomy

SPF (RFC 7208) is a TXT record published at the `From`-domain (more precisely, at the `MAIL FROM` / Return-Path domain — see §5.4) declaring which IPs are authorized to send mail.

```
example.com.  TXT  "v=spf1 ip4:198.51.100.0/24 include:_spf.google.com include:mailgun.org -all"
```

Mechanism precedence (left-to-right, RFC 7208 §5):

| Mechanism | Meaning |
|---|---|
| `all` | Match all (terminal — typically last with `-all` or `~all` qualifier) |
| `include:<domain>` | Recursive evaluation of `<domain>`'s SPF; only a `pass` there makes the mechanism match — `fail` / `softfail` / `neutral` mean "no match" and evaluation continues; `temperror` propagates, `permerror` / `none` become `permerror` (RFC 7208 §5.2) [verify 2026-10-30]; counts toward 10-DNS-lookup limit |
| `a` / `a:<domain>` | Match A / AAAA records of this domain or named domain |
| `mx` / `mx:<domain>` | Match MX hosts of this domain or named domain |
| `ip4:<cidr>` / `ip6:<cidr>` | Match IPv4 / IPv6 CIDR |
| `ptr` / `ptr:<domain>` | Reverse-DNS-based match — **deprecated**, do not rely on, RFC 7208 §5.5 |
| `exists:<domain>` | DNS A-record lookup; matches if any A record exists; useful for macro-driven dynamic SPF |
| `redirect=<domain>` | Replace the SPF evaluation with `<domain>`'s record (single-redirect; counts toward 10-lookup limit) |
| `exp=<domain>` | Explanation TXT for failed senders (advisory, not verdict) |

Qualifier prefixes: `+` (pass, default if absent), `-` (fail), `~` (softfail), `?` (neutral).

### 5.2 Policy Outcomes

| Outcome | Meaning | Forensic interpretation |
|---|---|---|
| `Pass` | Sender IP matched a permitting mechanism | Sender IP is in the published list — legitimate sender, hijacked included service, or a broad SPF (e.g., `+all`) |
| `Fail` | Sender IP matched a `-` mechanism (typically `-all`) | Domain owner explicitly rejects this sender; disposition is the receiver's local policy (RFC 7208 §8.4) — many receivers only mark the message unless DMARC enforces [verify 2026-10-30] |
| `SoftFail` | Sender IP matched a `~` mechanism (typically `~all`) | Domain owner is in DMARC monitoring rollout — message likely accepted but flagged |
| `Neutral` | Sender IP matched a `?` mechanism | Domain owner has no opinion — equivalent to None for evaluation purposes |
| `None` | No SPF record published | Domain owner has no SPF — no authorization signal |
| `TempError` | DNS lookup failed transiently | Receiver MAY retry; investigation might rerun the lookup later |
| `PermError` | SPF record syntactically invalid, exceeded 10-lookup limit, etc. | Domain misconfiguration — sender's reputation suffers, evidence indicator that sender's mail-auth posture is poor |

### 5.3 The 10-DNS-Lookup Limit

RFC 7208 §4.6.4 caps the number of DNS lookups during SPF evaluation at 10 (counting `include:`, `a`, `mx`, `ptr`, `exists`, `redirect=`, but **not** `ip4:` / `ip6:`). Exceeding the limit produces `PermError`. SaaS-heavy customers (Salesforce + Mailchimp + SendGrid + Postmark + Microsoft + Workspace) routinely blow past 10 if they include all vendors directly. The remediation is **SPF flattening** — resolving included records to their constituent IPs and inlining (with periodic re-flattening as vendors change). Forensic indicator: a domain with a syntactically present SPF that returns `PermError` for legitimate senders is *effectively* unauthenticated at the SPF layer; DMARC evaluation will fall back to DKIM if available.

The `void-lookup` limit (RFC 7208 §4.6.4) caps `void` lookups (those returning `NOERROR` with no records, or `NXDOMAIN`) at 2 per evaluation, also producing `PermError` when exceeded. This is occasionally hit by `exists:` macros against deactivated infrastructure.

### 5.4 The `MAIL FROM` vs `From:` Distinction

SPF is evaluated against the **envelope** `MAIL FROM` (also called Return-Path / bounce-address), **not** the `From:` header the recipient sees. This is the central reason SPF alone does not stop spoofing: an attacker can send mail with `MAIL FROM: <attacker@spoofable-domain.com>` and `From: ceo@victim-domain.com`. SPF evaluates the envelope sender against `spoofable-domain.com`'s SPF; if that record is `+all` (or absent), SPF returns Pass / None — and the receiver still accepts the spoofed `From:`.

The forensic implication: in the `Authentication-Results:` header, `spf=pass smtp.mailfrom=spoofable-domain.com` does **not** authenticate `header.from=victim-domain.com`. DMARC alignment (§7) is what binds the two together; SPF in isolation is insufficient.

### 5.5 SPF Investigation Commands

```bash
# Resolve SPF record
dig example.com TXT +short | grep "v=spf1"

# Recursively expand and count lookups (Python scripty / dedicated tool)
# pyspf (RFC 7208 result codes; returns 'permerror' when the 10-lookup limit is exceeded)
python3 -c "import spf; print(spf.check2(i='198.51.100.10', s='user@example.com', h='mta.example.com'))"

# CLI tools: spfquery (Debian/Ubuntu package spf-tools-perl; the binary is spfquery.mail-spf-perl, linked as spfquery via update-alternatives) [verify 2026-10-30]
spfquery --scope mfrom --id user@example.com --ip 198.51.100.10 --helo-id mta.example.com
```

### 5.6 SPF Forensic Patterns

| Observed SPF posture | Forensic interpretation |
|---|---|
| `v=spf1 -all` (no senders) | Domain owner explicitly authorizes nothing — any sender is fail; well-deployed receivers will reject |
| `v=spf1 +all` | Domain owner authorizes everything — SPF effectively disabled; high-risk posture |
| `v=spf1 include:<vendor> -all` (well-formed, narrow) | Hardened posture; only the named vendor is authorized |
| `v=spf1 ?all` | Neutral — equivalent to None for receivers; signals immature deployment |
| `v=spf1 ... ~all` followed by `p=reject` DMARC | DMARC is the enforcement layer; SPF is monitoring |
| `PermError` from a 10-lookup blowup | Effective SPF failure regardless of mechanism intent; remediation = flatten |
| Cross-walk to known bulk-mailer ASN inside an `include:` chain | Legitimate vendor mail-flow; not an attacker tell |

---

## 6. DKIM Forensics

### 6.1 DKIM Signature Anatomy

DKIM (RFC 6376) signs selected headers and the body using a key whose public half is published in DNS at `<selector>._domainkey.<signing-domain>`.

Example header:

```
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=example.com; s=mail2024;
        t=1714224000; bh=...; h=From:To:Subject:Date:Message-ID:Reply-To;
        b=...
```

Tags:

- **`v=`** — version (always `1`).
- **`a=`** — algorithm: `rsa-sha256` (most common), `rsa-sha1` (deprecated, RFC 8301), `ed25519-sha256` (RFC 8463) [verify 2026-10-30].
- **`c=`** — canonicalization: `<header>/<body>`. Header canonicalization: `simple` (preserve as-is) or `relaxed` (lower-case header names, collapse whitespace). Body canonicalization: `simple` (preserve trailing whitespace, normalize empty-line ending) or `relaxed` (collapse runs of whitespace, ignore trailing).
- **`d=`** — signing domain. The DKIM key is published under this domain.
- **`s=`** — selector. Combines with `d=` to form the DNS lookup `<s>._domainkey.<d>`.
- **`t=`** — signature creation timestamp (Unix epoch).
- **`x=`** — signature expiry (Unix epoch). Optional.
- **`h=`** — colon-separated list of signed headers, in order.
- **`bh=`** — body hash.
- **`b=`** — signature.
- **`l=`** — *body length tag* — optional; specifies how many bytes of body to include in the hash (rest is excluded). **Attack surface** (§6.5).
- **`i=`** — agent / user identifier (defaults to `@<d>`); informational.

### 6.2 Selector Lookup

```bash
# Publish lookup
dig mail2024._domainkey.example.com TXT +short
# Returns: "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG..."

# Multi-string TXT records (long keys split)
dig mail2024._domainkey.example.com TXT +short | tr -d '"' | tr -d ' '
```

Selector rotation is a defensive practice; an absent selector under a domain that recently sent DKIM-signed mail under it is normal (key was rotated and old selector retired). For forensics, capture the selector record at investigation time *and* attempt historical resolution via passive DNS (DomainTools, SecurityTrails, threat intelligence in the Microsoft Defender portal (formerly Defender TI / RiskIQ PassiveTotal)) [verify 2026-10-30] when the message is older than the current selector deployment.

### 6.3 Key Strength

| Key length | RFC 8301 / current guidance | Forensic interpretation |
|---|---|---|
| RSA-512 / 768 | Verifiers MUST NOT treat as valid (RFC 8301 §3.2) | Signature is invalid at any compliant receiver |
| RSA-1024 | RFC 8301 floor (signers MUST use ≥1024, SHOULD use ≥2048) [verify 2026-10-30] | Weak but valid; posture signal only |
| RSA-2048 | Current minimum baseline | Standard posture |
| RSA-4096 | Hardened | Secure but expensive |
| Ed25519 | RFC 8463 — modern | Adoption is mixed; receiver support varies |

A signing-domain that uses RSA-1024 is forensically interesting as a posture signal, not as evidence of forgery: no properly generated 1024-bit RSA modulus has been publicly factored (the general-purpose record is RSA-250, 829 bits, reported in eprint.iacr.org/2020/697), but 1024-bit keys from flawed generators have been broken (shared primes, factorable.net; Infineon ROCA, crocs.fi.muni.cz/public/papers/rsa_ccs17), and 1024 sits below the RFC 8301 SHOULD-2048 guidance and signals immature mail-auth [verify 2026-10-30]. Sub-1024-bit keys are rejected by compliant verifiers.

### 6.4 Multi-Signature Messages

A message can carry multiple `DKIM-Signature:` headers — typical for messages that traverse a forwarder that re-signs (Microsoft 365 transport rules; some mailing lists). The `Authentication-Results:` will list each `dkim=` outcome separately. For DMARC alignment (§7), at least one DKIM signature where `header.d=` aligns with the `From`-domain (per the alignment mode) must pass.

### 6.5 The `l=` Length-Tag Attack Surface

If the `DKIM-Signature:` includes `l=N`, only the first `N` bytes of the body are included in the hash. An attacker who modifies (or *appends*) bytes after position `N` does not invalidate the signature. The threat is a *signature replay* / *content-injection* pattern: take a legitimately signed message (e.g., a benign newsletter) with `l=N`, replace the body content beyond byte `N` with attacker content, and the resulting message still passes DKIM verification at the recipient.

Forensic indicator: any `DKIM-Signature:` carrying `l=` is suspect; mail-flow vendors who emit `l=` should be flagged as a posture issue. Most modern senders do not emit `l=`; presence of `l=` in 2026-era messages typically indicates legacy MTA configuration or a deliberate attacker pattern. RFC 6376 §8.2 ("Misuse of Body Length Limits") describes the attack; treat any `l=` as a posture finding [verify 2026-10-30].

### 6.6 Body Modification Detection

When `Authentication-Results:` reports `dkim=fail (body hash mismatch)`, the body was modified between signing and reception. Common legitimate causes: mailing-list footers; antivirus / disclaimer injection by the recipient SEG; `Content-Transfer-Encoding` re-coding by an intermediate. ARC (§8) was designed to preserve auth-state across known modifying intermediaries.

When `dkim=fail (signature verification failure)` and the `bh=` matches but `b=` does not, the *headers* were modified post-signature — specifically, one of the headers in the `h=` list. This is a stronger spoof signal.

### 6.7 DKIM Investigation Commands

```bash
# Manual verification (Python with dkimpy)
python3 -c "import dkim; print(dkim.verify(open('msg.eml','rb').read()))"

# CLI tools
opendkim-testmsg < msg.eml
# Or the dkimpy console script (reads the message from stdin) [verify 2026-10-30]:
dkimverify < msg.eml

# Inspect a signed message's signing parameters
grep -i "DKIM-Signature\|Authentication-Results" msg.eml
```

---

## 7. DMARC Forensics & Reporting Infrastructure

### 7.1 DMARC Record Anatomy

DMARC (RFC 9989, Proposed Standard, May 2026, which obsoletes RFC 7489; aggregate reporting is RFC 9990 and failure reporting RFC 9991) is a TXT record published at `_dmarc.<domain>` declaring policy and reporting addresses for mail that fails alignment [verify 2026-10-30].

```
_dmarc.example.com.  TXT  "v=DMARC1; p=quarantine; rua=mailto:dmarc-rua@example.com;
                          ruf=mailto:dmarc-ruf@example.com; pct=100;
                          adkim=r; aspf=r; sp=reject; fo=1"
```

Tags:

- **`v=`** — version (always `DMARC1`).
- **`p=`** — policy: `none` (monitor), `quarantine` (junk-folder), `reject` (do not deliver).
- **`sp=`** — sub-domain policy (defaults to `p=` if absent). Many domains publish `p=quarantine; sp=reject` to lock down sub-domains while keeping primary-domain policy lenient.
- **`np=`** — policy for non-existent sub-domains (imported into RFC 9989 from RFC 9091); falls back to `sp=`, then `p=`.
- **`pct=`** — legacy RFC 7489 sampling tag, marked *historic* by RFC 9989; still common in published records and honoured by RFC 7489-era receivers (`pct=10` = apply the policy to 10% of failing mail) [verify 2026-10-30].
- **`t=`** — RFC 9989 test mode, replacing some `pct=` functionality: `t=y` asks receivers to apply one level below the published policy (`reject` → `quarantine`, `quarantine` → `none`); default `t=n`.
- **`adkim=`** — DKIM alignment mode: `r` (relaxed — `header.d=` is `example.com` or any sub-domain) or `s` (strict — exact match).
- **`aspf=`** — SPF alignment mode: `r` (relaxed — envelope `MAIL FROM` domain is `example.com` or any sub-domain) or `s` (strict — exact match).
- **`rua=`** — aggregate-report destination(s); comma-separated `mailto:` URIs; report cadence is daily or more frequent (RFC 9990).
- **`ruf=`** — forensic-report (failure-report) destination(s); per-message reports; not all senders honor `ruf` due to PII concerns.
- **`fo=`** — failure-reporting options: `0` (default — generate report only if both SPF and DKIM fail to produce a DMARC-pass), `1` (any auth failure), `d` (DKIM failure regardless of alignment), `s` (SPF failure regardless of alignment).
- **`rf=`** / **`ri=`** — legacy RFC 7489 tags (failure-report format / aggregate interval), marked *historic* by RFC 9989; receivers may ignore them.
- **`psd=`** — `y` / `n` / `u` (default `u`): marks a record published by a Public Suffix Domain operator; used in RFC 9989 Organizational-Domain discovery.

### 7.2 Alignment

DMARC requires that *at least one* of SPF or DKIM **align with the `From:` domain**. Alignment is the bridge between the envelope-level / signing-level identifiers and what the recipient sees as the `From:`.

| Auth method | Aligned `From:` requirement |
|---|---|
| SPF aligned-with-`From` (relaxed) | `header.from`-domain equals envelope `MAIL FROM`-domain or any sub-domain relationship |
| SPF aligned-with-`From` (strict) | Exact match |
| DKIM aligned-with-`From` (relaxed) | `header.from`-domain equals `header.d=` or sub-domain relationship |
| DKIM aligned-with-`From` (strict) | Exact match |

A message can have SPF=pass on a third-party sender (`smtp.mailfrom=mailgun.org`) and DKIM=pass signed by the legitimate domain (`header.d=example.com`); only the DKIM aligns with `From:` (`example.com`); the message passes DMARC. This is the canonical pattern for transactional email through a relay.

### 7.3 Policy Decision Logic

| SPF aligned + pass | DKIM aligned + pass | DMARC verdict |
|---|---|---|
| Yes | Any | Pass |
| Any | Yes | Pass |
| No | No | Fail (subject to `p=` / `sp=` / `np=`, `t=` or legacy `pct=`, and `fo=` for reporting) |

When both fail, the receiver applies `p=` modulated by `t=` (or legacy `pct=`) and emits aggregate / forensic reports per `rua=` / `ruf=` / `fo=`.

### 7.4 Aggregate (`rua`) Report Parsing

Aggregate reports are XML files (schema: RFC 9990 Appendix A; RFC 7489 Appendix C for legacy reporters) attached to daily mail to the `rua=` address. Each report covers one reporter (one receiver organization, one policy domain, one day), summarizing per-source-IP counts of disposition decisions.

Schema highlights:

```xml
<feedback>
  <report_metadata>
    <org_name>google.com</org_name>
    <email>noreply-dmarc-support@google.com</email>
    <report_id>...</report_id>
    <date_range><begin>1714224000</begin><end>1714310400</end></date_range>
  </report_metadata>
  <policy_published>
    <domain>example.com</domain>
    <p>quarantine</p><sp>reject</sp><pct>100</pct>
  </policy_published>
  <record>
    <row>
      <source_ip>198.51.100.10</source_ip>
      <count>42</count>
      <policy_evaluated>
        <disposition>quarantine</disposition>
        <dkim>fail</dkim><spf>pass</spf>
      </policy_evaluated>
    </row>
    <identifiers>
      <header_from>example.com</header_from>
    </identifiers>
    <auth_results>
      <dkim><domain>example.com</domain><selector>mail2024</selector><result>fail</result></dkim>
      <spf><domain>spoofable.com</domain><result>pass</result></spf>
    </auth_results>
  </record>
</feedback>
```

RFC 9990 reporters may add a top-level `<version>`, report `np` / `discovery_method` / `testing` (and no `pct`) in `policy_published`, and must include the DKIM `<selector>`; RFC 7489-era reporters still send `pct` and may omit the selector.

Forensic uses:

- **Lookalike-sender discovery** — source IPs in aggregate reports against `example.com` that the customer did *not* contract are candidate spoofers; cross-walk against ASN, country, and historical report appearance.
- **Mail-flow anomaly detection** — sudden spike in `count` for a known-bad source IP; appearance of a previously-unseen IP at high volume.
- **Authentication-posture validation** — inventory of all aligned vs unaligned senders; gaps between intended and observed posture.

### 7.5 Forensic (`ruf`) Reports

Per-message failure reports (RFC 6591 ARF format, as updated by RFC 9991). They include redacted message headers and (sometimes) body excerpts. Gmail does not support `ruf=`, and Microsoft 365 never sends failure reports even when a valid `ruf=` is published, so `ruf` coverage comes only from other receivers [verify 2026-10-30]. When available, `ruf` reports give per-message visibility — invaluable for active-incident hunting but not a reliable steady-state stream.

### 7.6 DMARC Reporting Infrastructure

Customers consume `rua` / `ruf` reports through:

| Approach | Notes |
|---|---|
| **In-house parser** | `parsedmarc` (https://github.com/domainaware/parsedmarc) is the canonical open-source parser; ingests from IMAP / Microsoft Graph / Gmail API / Maildir mailboxes or report files; outputs Elasticsearch / OpenSearch / Splunk HEC / Kafka / S3 / syslog / GELF / webhook / PostgreSQL [verify 2026-10-30] |
| **dmarcian** | Commercial DMARC analytics platform (https://dmarcian.com) |
| **Valimail** | Commercial DMARC + sender-identity platform |
| **Postmark DMARC** | Free weekly DMARC digest plus a paid monitoring tier (ActiveCampaign) |
| **MXToolbox** | Commercial DMARC monitoring |
| **Cloudflare DMARC Management** | Cloudflare-hosted aggregation for Cloudflare-DNS customers |
| **EasyDMARC** | Commercial DMARC platform |
| **OnDMARC (Red Sift)** | Commercial DMARC platform |
| **Agari DMARC Protection** | Enterprise DMARC + look-alike-domain / brand-impersonation platform; formerly Agari Brand Protection, now sold by Fortra [verify 2026-10-30] |
| **Microsoft 365 as a reporter** | Exchange Online sends `rua` aggregate reports for inbound mail only when the tenant's MX points directly at Microsoft 365, and never sends `ruf` failure reports; Microsoft offers no built-in report consumer (it points to PowerShell / Power BI automation or external services) [verify 2026-10-30] |

For active BEC investigations, the customer's existing aggregate-report archive — even if previously unparsed — is the highest-value historical lookalike-sender corpus.

### 7.7 DMARC Investigation Commands

```bash
# Resolve DMARC record
dig _dmarc.example.com TXT +short

# Subdomain DMARC (organizational-domain inheritance)
dig _dmarc.sub.example.com TXT +short

# Bulk DMARC check across customer-owned domains (psl-aware)
# Use a scripted approach with dnspython + publicsuffix2

# Aggregate-report parser (parsedmarc). Mailbox settings live in an INI file ([imap] host / user /
# password) or in PARSEDMARC_{SECTION}_{KEY} env vars; there are no --imap-* CLI flags [verify 2026-10-30]
export PARSEDMARC_IMAP_PASSWORD="$PW"   # keeps the secret out of the INI file
parsedmarc -c /etc/parsedmarc.ini -o ./rua-output

# Inspect a single XML report
unzip -p report.xml.zip | xmllint --format -
```

---

## 8. ARC Forensics

### 8.1 Why ARC Exists

DMARC is brittle across **indirect mail flows** — mailing lists, vacation auto-forwards, Microsoft 365 transport-rule rewriting — because intermediates legitimately modify messages (add `[list]` to `Subject:`, append disclaimer footers, rewrite `From:` to a list address). These modifications break DKIM body-hash; SPF alignment is already broken because the relay is the new envelope sender. Without ARC, a forwarded legitimate message arrives at the final recipient with DMARC=fail.

ARC (Authenticated Received Chain, RFC 8617, Experimental) lets each cooperating intermediate add a sealed record of *what authentication looked like when I received this*, plus a re-signature of the message *as I forwarded it*. The final recipient validates the chain and can choose to honor the auth-result the chain attests was true at origin even if direct DMARC fails.

### 8.2 ARC Headers

Three headers per ARC instance (numbered `i=1`, `i=2`, ...):

- **`ARC-Authentication-Results`** — what this hop saw at receive time (mirrors `Authentication-Results:` syntax).
- **`ARC-Message-Signature`** — DKIM-style signature over the message (headers + body) at this hop.
- **`ARC-Seal`** — signature over the prior ARC headers, anchoring the chain.

ARC instance numbering: `i=1` is the first ARC-aware MTA; subsequent hops increment. The receiver validates that each `ARC-Seal` correctly seals the prior `i-1` chain and that `ARC-Message-Signature` validates against the message-as-forwarded.

### 8.3 ARC Validation

```bash
# Python tooling (dkimpy supports ARC; needs the authres package)
python3 -c "import authres, dkim; print(dkim.arc_verify(open('msg.eml','rb').read()))"

# dkimpy also installs an ARC chain-validation CLI that reads the message on stdin [verify 2026-10-30]
arcverify < msg.eml

# OpenARC is a milter, not a one-shot verifier; the maintained fork is https://github.com/flowerysong/OpenARC
# (trusteddomainproject/OpenARC has had no push since 2024-04)
```

Trusted ARC-sealer list is the recipient policy decision: which ARC sealers does the recipient trust to attest to origin-time authentication? Gmail and Microsoft 365 document ARC support (Google's ARC help page describes the three ARC headers and the `cv=` chain-validation tag; Microsoft 365 lets admins designate trusted ARC sealers) [verify 2026-10-30]; other providers and smaller intermediates may or may not seal. A broken or absent ARC chain on a forwarded message is a routine forensic signal — it does not necessarily mean spoofing, but it limits the receiver's ability to override a direct-DMARC fail.

### 8.4 ARC Forensic Patterns

| Observation | Forensic interpretation |
|---|---|
| Valid ARC chain, `arc=pass`, direct DMARC fail | Forwarded legitimate message; receiver may have honored ARC and delivered |
| `arc=fail` with ARC headers present | Tampering during transit, chain-key revocation, or implementation bug |
| ARC headers absent, direct DMARC fail | Direct send (no forwarder) failing DMARC; do not extrapolate to "ARC would have saved it" |
| Multiple `i=` instances, all valid | Multi-hop forward through cooperating intermediates |
| ARC chain valid but signing domain unfamiliar | Capture the signing domains and selectors; cross-walk via passive DNS to identify the forwarder population |

---

## 9. Lookalike-Domain & Brand-Impersonation Detection

### 9.1 Lookalike-Domain Patterns

| Pattern | Example (against `example.com`) |
|---|---|
| Character substitution (homoglyph in ASCII) | `examp1e.com` (lowercase L → digit 1), `examplé.com` (Latin-1 letter), `exarnple.com` (`m` → `rn`) |
| Character insertion / deletion | `examplle.com`, `exmple.com` |
| Character transposition | `exmaple.com` |
| Keyboard adjacency | `exampke.com`, `wxample.com` |
| TLD substitution | `example.co`, `example.cm`, `example.org`, `example.com.<cctld>` |
| Subdomain confusion | `example.com.evil.com`, `secure-example.com`, `login-example.com` |
| IDN homograph (Punycode `xn--`) | `xn--exmple-4nf.com` displays in IDN-aware UIs as `exаmple.com` (Cyrillic `а`, U+0430); compare `xn--exmple-cua.com` = `exämple.com` (Latin `ä`) |
| Mixed-script | Combinations of Latin + Cyrillic + Greek visually identical; UTS #39 (Unicode Security Mechanisms) confusables |
| Brand-confusable (legitimate-domain-near) | `examplecorp.com` against `example-corp.com` |

### 9.2 IDN Homograph Forensics

Internationalized Domain Names encode non-ASCII characters as Punycode (RFC 3492) prefixed with `xn--`. Browsers and mail clients render the Unicode form unless safety heuristics downgrade to Punycode. Chromium (since Chrome 51, ignoring the browser's language settings) and Firefox both apply per-label script-mixing rules: Latin may not mix with Cyrillic or Greek, and disallowed characters force Punycode. Chromium also runs UTS #39 confusable checks, including whole-script confusables (an all-Cyrillic Latin look-alike on `.com` shows as Punycode), while Firefox's documented algorithm skips the checks for allow-listed TLDs and permits whole-script confusables [verify 2026-10-30]. Mail clients apply their own, inconsistent rules.

```bash
# Decode IDN
python3 -c "print('xn--exmple-4nf.com'.encode().decode('idna'))"

# Encode IDN
python3 -c "print('exаmple.com'.encode('idna').decode())"

# Detect mixed-script in a label
python3 -c "
import unicodedata
label = 'exаmple'
scripts = set()
for ch in label:
    try:
        scripts.add(unicodedata.name(ch).split()[0])
    except ValueError:
        scripts.add('UNKNOWN')
print(scripts)
"
```

### 9.3 Typosquatting Discovery

`dnstwist` (https://github.com/elceef/dnstwist) is the canonical generator-and-resolver for typosquat-pattern domain candidates against a base domain.

```bash
# Generate and resolve candidates
dnstwist --registered example.com

# JSON output for parsing
dnstwist --registered --format json example.com > squat-candidates.json

# Include WHOIS (creation date / registrar), HTTP + SMTP banners, and web-page similarity hashing.
# dnstwist has no certificate grab (use the crt.sh / openssl steps in §9.4-§9.5); --ssdeep is a hidden legacy alias [verify 2026-10-30]
dnstwist --registered --whois --banners --lsh ssdeep example.com

# Scan against multiple base domains
for d in example.com example.org example.net; do
  dnstwist --registered --format json "$d" > "squat-$d.json"
done
```

`urlcrazy` (https://github.com/urbanadventurer/urlcrazy) and `urlinsane` (https://github.com/rangertaha/urlinsane) are alternative generators with overlapping but not identical algorithm coverage.

### 9.4 Certificate Transparency Log Monitoring

CT logs (RFC 6962; RFC 9162 "CT 2.0" obsoletes it on paper, but Chrome-recognised logs implement RFC 6962 or the C2SP static-ct-api) record every TLS certificate issued by a participating CA. Monitoring CT for issuance against your brand surface catches squatters at certificate-issuance time, often before mail-sending. crt.sh, Censys, Cloudflare Radar's Certificate Transparency pages (formerly Merkle Town; ct.cloudflare.com redirects there), Google's Transparency Report, and SecurityTrails provide query interfaces; Facebook's CT monitoring tool page now returns 404 [verify 2026-10-30].

```bash
# crt.sh JSON API (free)
curl -s "https://crt.sh/?q=%25example%25&output=json" | jq '.[] | .name_value' | sort -u

# Censys (commercial; legacy censys-python CLI, certificates index). Censys says its Search v1/v2 APIs
# will be deprecated in favour of the Censys Platform (censys-sdk-python) [verify 2026-10-30]
censys search 'parsed.subject_dn: "example"' --index-type certificates

# Continuous CT monitoring — cron / scheduled job; diff against day-prior set
```

Brand-protection platforms (DomainTools Iris, Group-IB Digital Risk Protection, Microsoft Defender External Attack Surface Management (ex-RiskIQ), ZeroFox, BrandShield, Mandiant Digital Threat Monitoring [verify 2026-10-30]) provide aggregated CT + WHOIS + DNS + content monitoring.

### 9.5 Registrar / Hosting-Provider Forensics

For each suspect lookalike domain:

```bash
# WHOIS
whois lookalike.example.com

# Historical WHOIS (commercial) [verify 2026-10-30]
# DomainTools Iris: https://research.domaintools.com/ (iris.domaintools.com redirects there)
# WhoisXML API WHOIS History: https://whois-history.whoisxmlapi.com/

# DNS records (current). Many authoritative servers (Cloudflare included) answer ANY minimally
# per RFC 8482, so query each type explicitly [verify 2026-10-30]
for t in A AAAA NS MX TXT; do dig lookalike.example.com "$t" +short; done
dig _dmarc.lookalike.example.com TXT +short
dig default._domainkey.lookalike.example.com TXT +short

# SSL / TLS certificate footprint (active scan)
echo | openssl s_client -connect lookalike.example.com:443 -servername lookalike.example.com 2>/dev/null \
  | openssl x509 -text -noout

# Passive DNS (commercial)
# SecurityTrails, DomainTools, threat intelligence in the Microsoft Defender portal (formerly Defender TI / RiskIQ PassiveTotal) [verify 2026-10-30]
```

Forensic indicators:

- **Recently-registered** (within 30 days of incident) — strong signal for active campaign.
- **Privacy-protected WHOIS / GDPR-redacted** — most lookalikes are redacted in the modern WHOIS landscape; not a strong signal alone.
- **MX records pointing to commodity SMTP relays** (SendGrid, Mailgun, Amazon SES, OVH) — operational signal.
- **A records on commodity hosting** (DigitalOcean, Vultr, Linode, Hetzner, OVH, Cloudflare) — operational signal.
- **Cloudflare-fronted** — common; impedes upstream-IP discovery; pivot via SSL-cert SAN, mail-flow MX, or coordinated provider abuse.
- **No DMARC / weak SPF on the lookalike** — campaign infrastructure rarely deploys outbound mail-auth on the squat domain itself; their mail uses other infrastructure.
- **Registrar pattern** (NameCheap / NameSilo / Tucows / Porkbun / Hostinger [verify 2026-10-30]) — bulk-registration patterns are visible across sister-squats; the same registrant (even when redacted via Privacy Service) often clusters at one registrar.

### 9.6 Brand-Confusable Unicode (TR39 Confusables)

Unicode Technical Standard #39 (Unicode Security Mechanisms) publishes `confusables.txt` (https://www.unicode.org/Public/security/latest/confusables.txt), mapping similar-looking glyphs across scripts. Tools:

```bash
# Python: confusable_homoglyphs (PyPI confusable-homoglyphs). GitHub repo archived Jan 2024;
# now maintained at https://sr.ht/~valhalla/confusable_homoglyphs/ [verify 2026-10-30]
python3 -c "from confusable_homoglyphs import confusables; print(confusables.is_confusable('exаmple.com'))"

# Online ICU confusables analyzer
# https://util.unicode.org/UnicodeJsps/confusables.jsp
```

### 9.7 Lookalike Workflow

1. **Generate candidates** — `dnstwist --registered`, `urlcrazy`, `urlinsane`; cross-check confusables for IDN.
2. **Resolve** — DNS A / MX / TXT for each registered candidate.
3. **Enrich** — WHOIS, registrar, hosting ASN, SSL certs, passive DNS.
4. **Cross-walk to incident headers** — does any candidate appear in the suspect message's `From:`, `Reply-To:`, `Return-Path`, embedded URLs, signature block?
5. **Cross-walk to DMARC reports** — `source_ip` is the connecting IP and `header_from` is the customer's own domain, so a separate lookalike domain will not appear by name. Cross-walk the lookalike's A / MX IPs against `source_ip` entries, then against the customer's mail-flow alerts and SEG quarantine logs.
6. **Track campaign infrastructure** — sister-domain discovery (SSL-cert SAN expansion, registrar-data clustering, hosting-IP co-location).
7. **Coordinate take-down** — registrar abuse contact + hosting-provider abuse contact + CDN abuse contact; legal-counsel on UDRP (Uniform Domain-Name Dispute-Resolution Policy) where the brand has a registered trademark.

---

## 10. M365 / Workspace Message Tracing

### 10.1 Microsoft 365 Message Trace

The mailbox-side of any M365-hosted incident is owned by [[sop-saas-log-forensics|SaaS Log Forensics]]. This SOP covers the **mail-flow** layer specifically.

```powershell
# Connect to Exchange Online (ExchangeOnlineManagement 3.7.0+ for the V2 trace cmdlets)
Connect-ExchangeOnline -UserPrincipalName investigator@<tenant>.onmicrosoft.com

# Get-MessageTraceV2: last 90 days, at most 10 days per query, ResultSize up to 5000, no paging [verify 2026-10-30]
Get-MessageTraceV2 -StartDate (Get-Date).AddDays(-10) -EndDate (Get-Date) `
                   -SenderAddress "spoofed@example.com" `
                   -ResultSize 5000 | Export-Csv mt-recent.csv
# Next batch: rerun with -StartingRecipientAddress / -EndDate set to the last row's recipient address / received time.
# Legacy Get-MessageTrace (10 days, -PageSize) is "replaced by the Get-MessageTraceV2 cmdlet".

# Historical trace (report-based, asynchronous; up to 90 days back)
Start-HistoricalSearch -ReportTitle "BEC-investigation-2026-04-27" `
                      -StartDate (Get-Date).AddDays(-85) -EndDate (Get-Date) `
                      -ReportType MessageTrace `
                      -SenderAddress "spoofed@example.com"
# Result delivered as CSV / report by mail; pull from Get-HistoricalSearch

# Per-message detail. Documented -Event examples: RECEIVE, SEND, FAIL, DELIVER, EXPAND, TRANSFER, DEFER.
# Without -StartDate / -EndDate only the last 48 hours are searched.
Get-MessageTraceDetailV2 -MessageTraceId <guid> -RecipientAddress <recipient> `
                         -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
```

`Get-MessageTrace` / `Get-MessageTraceDetail` are replaced by `Get-MessageTraceV2` / `Get-MessageTraceDetailV2` and "will eventually be deprecated" (V2: 90-day window, 10 days per query, 100 queries per tenant per 5 minutes). Message-trace support in the legacy Reporting Web Service began deprecating on 8 April 2026 and is replaced by the Microsoft Graph message-trace API (`exchangeMessageTrace`) [verify 2026-10-30]. `Start-HistoricalSearch` remains the asynchronous, report-driven route for bulk exports.

For higher-fidelity event-level detail, Defender for Office 365 **Threat Explorer** (Plan 2; Plan 1 tenants get the lighter Real-time detections page; Defender portal → Email & collaboration → Explorer) gives the per-recipient delivery action (Blocked / Delivered / Delivered to junk / Replaced) plus original and latest delivery location (Inbox/folder, Junk, Quarantine, Deleted Items, Dropped, Failed, On-prem/external), and supports remediation actions (move to inbox / move to junk / move to deleted items / soft delete / hard delete) [verify 2026-10-30]; state-changing actions require explicit authorization.

### 10.2 On-Premises Exchange Message Tracking

```powershell
# On-premises Exchange Server message tracking. -EventId takes a single string, so filter client-side
# (or run one call per EventId); ResultSize defaults to 1000 [verify 2026-10-30]
Get-MessageTrackingLog -Server <transport-server> -Start "2026-04-27 00:00" -End "2026-04-27 23:59" `
    -Sender "spoofed@example.com" -ResultSize Unlimited |
    Where-Object { $_.EventId -in 'DELIVER','FAIL','RECEIVE','SEND','BADMAIL' }
```

Hybrid environments (Exchange Online + on-prem) require message-trace correlation across both surfaces.

### 10.3 Google Workspace Email Log Search

Workspace Email Log Search (ELS; Admin console → Reporting → Email Log Search) gives full delivery-status detail for the last 30 days (up to 1,000 messages and 15,000 log entries per message per search). Its "Older than 30 days" option needs the recipient address and Message-ID and returns post-delivery status only. Gmail log events are kept 6 months for Admin console reports and audit & investigation; longer windows need the BigQuery export, and Vault retains message *content*, not logs [verify 2026-10-30].

Search fields: Sender (full or partial address, or Return-Path), Recipient, Sender IP, Recipient IP, Subject, Message ID, and date range. Results show a status for each delivery step plus post-delivery state (labels, location, spam marking, deletion).

```bash
# GAM7 (https://github.com/GAM-team/GAM; installs as `gam`): Gmail log events via the Reports API
# (applicationName=gmail; eventName is always `delivery`; start/end window <= 30 days) [verify 2026-10-30]
gam redirect csv ./gmail-2026-04-27.csv report gmail start "2026-04-27T00:00:00Z" end "2026-04-27T23:59:59Z"

# Narrow by event_info.mail_event_type code from the Reports API Gmail appendix (e.g. 5 = message quarantined)
gam report gmail start "2026-04-27T00:00:00Z" end "2026-04-27T23:59:59Z" gmaileventtypes 5

# OAuth grants (OAuth-consent BEC variant) are the `token` application, not `gmail`
gam report token event authorize
```

### 10.4 Gmail BigQuery Export

For long-term mail-event evidence, customers can configure Workspace logs export to BigQuery, which exports the Gmail logs (delivery decisions, sender / recipient, subject, message ID, security verdict) at full granularity beyond the 30-day Email Log Search window; the export includes up to 180 days of historical activity data [verify 2026-10-30].

```sql
-- Workspace service-log export, `activity` table; Gmail fields live under `gmail.*`.
-- Tables are day-partitioned on _PARTITIONTIME (Pacific Time boundaries); filter on it to limit cost.
SELECT TIMESTAMP_MICROS(gmail.event_info.timestamp_usec) AS ts,
       gmail.message_info.subject,
       gmail.message_info.source.address AS sender,
       destination.address AS recipient,
       gmail.message_info.rfc2822_message_id,
       gmail.event_info.mail_event_type
FROM `project.dataset.activity` d, d.gmail.message_info.destination
WHERE gmail.message_info.source.address = 'spoofed@example.com'
  AND DATE(_PARTITIONTIME) BETWEEN '2026-02-01' AND '2026-04-27'
ORDER BY ts DESC
```

### 10.5 Cross-Walk to Mailbox-Compromise Side

When the BEC includes a mailbox-compromise pivot:

- **Authentication context** for the suspicious sign-in: Entra ID sign-in logs / Workspace `login` Reports → [[sop-saas-log-forensics|SaaS Log Forensics]] §4.2 / §5.1.
- **Mailbox-rule changes** (`New-InboxRule`, `Set-InboxRule`, `Remove-InboxRule`) → [[sop-saas-log-forensics|SaaS Log Forensics]] §4.6.
- **Mailbox audit** (mail accessed, sent, moved, deleted) — `Search-UnifiedAuditLog -RecordType ExchangeItem` / `ExchangeItemGroup` / `ExchangeItemAggregated`, one session per record type: set `$sid = "case-$([guid]::NewGuid())"` once, before the loop (a new SessionId restarts at the first block, so generating it inside the loop never terminates), then run `do { $page = Search-UnifiedAuditLog ... -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000; $page } while ($page)` (100 records by default without it; max 50,000 per session, unsorted). Microsoft says `Search-MailboxAuditLog` "will be deprecated in the cloud-based service" [verify 2026-10-30] → [[sop-saas-log-forensics|SaaS Log Forensics]] §4.5.
- **OAuth-app token persistence** (the OAuth-consent BEC variant) → [[sop-saas-log-forensics|SaaS Log Forensics]] §10. The mailbox-side compromise reconstruction lives there; this SOP captures the *messages* the compromised mailbox sent and received.

### 10.6 Quarantine and Junk-Folder Forensics

Recipient-side quarantine / junk-folder content is part of the mail-flow record. Defender for Office 365 / EOP quarantine retention depends on the verdict: anti-spam verdicts (spam, high-confidence spam, phishing, high-confidence phishing, bulk) keep **15 days** under the default and custom anti-spam policies (configurable 1-30 days via `QuarantineRetentionPeriod`) and 30 days under the Standard / Strict presets; anti-phishing quarantine follows the anti-spam value; malware, mail-flow-rule and Safe Attachments quarantine is a fixed **30 days**; expired messages are permanently deleted. Workspace admin **Quarantine** holds messages for a fixed 30 days, then deletes them permanently (Vault retention can hold copies longer) [verify 2026-10-30]. User **Spam**-folder retention is not stated on the admin pages checked; confirm before relying on it. Quarantine pulls (read-only) are part of evidence collection; release / delete actions are state-changing and require authorization.

```powershell
# M365 quarantine pull
Get-QuarantineMessage -StartReceivedDate (Get-Date).AddDays(-30) -EndReceivedDate (Get-Date) `
    -SenderAddress "spoofed@example.com"
Get-QuarantineMessage -Identity <id> | Format-List
# Released / deleted actions:
# Release-QuarantineMessage -Identity <id> -ReleaseToAll
# Delete-QuarantineMessage  -Identity <id>
```

---

## 11. Secure-Email-Gateway Forensics

Customer-side SEGs sit between the public internet and the mailbox provider, adding a per-vendor evidence layer between the original `Authentication-Results:` and what the mailbox finally saw.

### 11.1 Mimecast

Mimecast Audits / Tracker / Hold-Queue / Search & Recover provide message-level visibility:

- **Message Tracker** — per-message routing decision, sender / recipient, transmission time, status (Delivered / Held / Bounced / Rejected).
- **Hold Queue** — quarantined-but-not-released messages.
- **Search & Recover** — historical search across long-term archive.
- **Threat Intelligence Dashboard** — IOCs surfaced from URL Protection / Attachment Protection.
- **Audit Logs** — administrator actions (block, allow, release, deny, policy-change).

Pull via Mimecast API 2.0 (developer portal https://developer.services.mimecast.com/); the old tech-connect documentation URL now redirects to an "API 1.0 Documentation" archive, so build new integrations on 2.0 [verify 2026-10-30]. Engagement-time admin role: dedicated investigator console user with `Audit` and `Search & Recover` rights.

### 11.2 Proofpoint

Proofpoint provides:

- **Smart Search** — message-flow search with per-message detail.
- **Threat Insight** — campaign-level intelligence (matched campaigns, IOC enrichment).
- **TAP (Targeted Attack Protection)** — URL / attachment behavioral disposition.
- **Threat Response Auto-Pull (TRAP)** — post-delivery message removal events.
- **Audit Logs** — admin / API activity.

Pull via Proofpoint REST API / SIEM API (https://help.proofpoint.com/Threat_Insight_Dashboard/API_Documentation/SIEM_API) [verify 2026-10-30]. Engagement-time admin role: read-only Smart Search + Threat Insight.

### 11.3 Microsoft Defender for Office 365

Already covered at §10.1 (Threat Explorer, Quarantine). Additionally:

- **Submissions** — administrator submissions to Microsoft for mis-classification review.
- **Campaigns** (Plan 2) — Microsoft-aggregated campaign intelligence.
- **AIR for compromised users** (Plan 2) — automated investigation of suspicious-mail-flow / compromised-user alerts.
- **Attack Simulation Training** — *training* infrastructure that should not appear in real incidents (rule out as cause when investigating "received simulated phishing" reports).

### 11.4 Cisco Secure Email (formerly Ironport ESA)

- **Message Tracking** — appliance / cloud message-flow search.
- **Mail Logs** — raw MTA logs (extensible to SIEM / log-management).
- **AsyncOS** version drives feature scope and API surface [verify 2026-10-30].

### 11.5 Barracuda Email Gateway Defense / Email Security Gateway

- **Message Log** — per-message disposition and block category in Email Gateway Defense; Barracuda's documentation covers moving from the Email Security Gateway appliance to Email Gateway Defense [verify 2026-10-30].

### 11.6 Sophos Central Email

Sophos lists the on-prem **Sophos Email Appliance** under "Sophos Products Now End of Life"; treat SEA logs as legacy evidence [verify 2026-10-30].

- **Message Search** — per-message routing decision.
- **Audit Trail** — admin actions.

### 11.7 Recipient-Side Envelope-vs-Header Reconciliation

The `Authentication-Results:` from the customer's *trusted* MTA (the boundary the customer controls) is the dispositive one. Earlier `Authentication-Results:` from upstream relays — Mimecast / Proofpoint / Defender / etc. — are also evidence and frequently disagree (a SEG saw `dkim=fail` when the next hop saw `dkim=pass` because the SEG modified body / subject before passing).

When SEG and mailbox provider disagree:

- **SEG fail + mailbox pass.** SEG modified the message in transit (added disclaimer, scanned attachment, rewrote URLs); the mailbox-side DKIM was re-signed by the SEG or the SEG's modification preserved the DKIM-protected portions. Verify via `c=` canonicalization + `h=` field list + body-modification trace.
- **SEG pass + mailbox fail.** Less common; usually a downstream re-routing / forwarding step modifies the message after SEG accepted it.
- **Both pass, but `From:` is suspicious.** The most common BEC pattern — DMARC posture is weak (`p=none`, no enforcement); receiver delivers regardless of fail; investigation must rely on body-content / pretext / pattern indicators rather than the auth verdict alone.

---

## 12. Phishing-Kit Analysis (Defensive)

### 12.1 Scope and Discipline

This SOP covers the *defensive analysis* of phishing kits — kits the investigator has lawfully obtained from open directories of attacker infrastructure, takedown-coordinated copies, sandbox captures, customer-supplied artifacts, or LE-shared evidence. It does **not** cover offensive operation of phishing kits, kit purchase from criminal marketplaces (which raises the funding-of-criminal-enterprise question), or kit modification for offensive use.

Deep static / dynamic analysis of the kit binary, embedded scripts, server-side PHP, JavaScript, and Python routes to [[sop-malware-analysis|Malware Analysis]] (§3 Rapid Triage, §4 Behavior Analysis, §6.4 Script Analysis) and [[sop-reverse-engineering|Reverse Engineering]]; this section is the *email-vector framing* — what the kit fingerprint tells the email investigator about the campaign.

### 12.2 Kit Acquisition

Lawful acquisition paths:

- **Open directory exposure** — many kit operators leave directory-listing enabled on the staging server; the kit is downloadable while it is live. `wget -r -np -k <url>/<kit-path>/` archives the tree. Capture with `curl -I` first to confirm scope; respect engagement scope (do not enumerate beyond the suspect path).
- **Takedown-coordinated copy** — when working with a hosting provider's abuse team or a CDN's trust-and-safety team to take down infrastructure, the takedown coordination frequently includes a copy of the served content for evidence.
- **Sandbox capture** — detonating the phishing URL in a sandbox (Microsoft Defender for Office 365 Detonation, Joe Sandbox, ANY.RUN, Hatching Triage [verify 2026-10-30]) can capture the kit's served output and sometimes the source.
- **Customer-supplied** — the customer's IR firm captured the kit during the incident.
- **LE-shared evidence** — when an active investigation is in coordination with FBI / NCSC / Europol.

### 12.3 Kit Decomposition

Typical phishing-kit structure:

```
kit-base/
├── index.php                 # Landing page (often branded clone)
├── login.php                 # Credential intake
├── verify.php                # MFA-step intake (for AiTM kits)
├── result.php / send.php     # Exfil endpoint — POSTs credentials to Telegram bot, attacker SMTP, or attacker URL
├── config.php                # Hardcoded attacker email / Telegram bot token / exfil URL
├── allow.php / blockers.php  # IP / ASN / geo blocking against analysts (anti-analyst)
├── images/                   # Branded assets (often direct-loaded from victim brand to evade detection)
├── css/, js/                 # Branded styling
├── .htaccess                 # Anti-analyst rules (block known scanner UAs, ASNs)
└── tracker.php / log.txt     # Attacker analytics
```

Static-analysis hooks (route to [[sop-malware-analysis|Malware Analysis]] for deep RE):

- **Strings** — `strings -a -n 8 *.php | grep -E 'mail\(|smtp|telegram|@gmail|api\.telegram|hotmail|protonmail|onion'`
- **Telltale exfil patterns** — PHP `mail()`-based send to attacker `@gmail.com` / `@protonmail.com` / `@onionmail.org`; PHP `curl_*` POST to attacker URL; Telegram Bot API (`api.telegram.org/bot<token>/sendMessage?chat_id=<id>`).
- **Anti-analyst blockers** — `allow.php` / `blockers.php` filtering by IP CIDR (Google ASNs, security-vendor ASNs, Tor exits), User-Agent (`Bot`, `crawl`, `scan`, `wget`, `curl`), and GeoIP.
- **Kit-author signatures** — many kits carry author tags (`/* coded by ... */` comments, watermarks, author-website links); cross-walk against vendor and community phishing-kit research and your own corpus of kit signatures.

### 12.4 Adversary-in-the-Middle (AiTM) Detection

**EvilGinx, Modlishka, Muraena**, and a growing family of AiTM kits proxy the legitimate authentication flow — the victim sees the real login page (because the kit fetches it from the legitimate provider), enters credentials, completes MFA; the kit captures the post-MFA session cookie / token, then either passes through or fails the user out. The attacker holds a valid session token without ever needing the credential in isolation. AiTM is a widely reported route around MFA in BEC (for example Microsoft's 2022 write-up https://www.microsoft.com/en-us/security/blog/2022/07/12/from-cookie-theft-to-bec-attackers-use-aitm-phishing-sites-as-entry-point-to-further-financial-fraud/); cite a current vendor report when quoting prevalence [verify 2026-10-30].

Detection signatures:

- **Hostname pattern** — AiTM kits commonly proxy `login.microsoftonline.com` through a registered lookalike (`login-microsoftonline.<lookalike>.<tld>`); cross-walk against §9 lookalike inventory.
- **TLS-cert SAN expansion** — kits frequently issue a single cert covering multiple impersonated provider hostnames; CT-log monitoring (§9.4) catches the issuance.
- **JA3 / JA4 client-side fingerprint** — when the kit operates as an HTTP client back to the legitimate provider, the kit's TLS-stack fingerprint differs from the victim's browser. SaaS providers' anomaly engines exploit this; whether a provider will share TLS-fingerprint data depends on its legal-process / IR channel, so ask rather than assume it is available.
- **Header-based** — the proxy adds / strips / re-orders HTTP headers in characteristic ways; the legitimate provider's signal team has fingerprints.
- **Geolocation chain** — sign-in via a residential-proxy hosted in country A while victim is in country B; combined with the immediate post-sign-in session token use from a different residential-proxy ASN.

Defensive mitigation lives in [[sop-saas-log-forensics|SaaS Log Forensics]] and Conditional Access / Continuous Access Evaluation policy; this SOP names the *detection signature in mail and infrastructure*.

### 12.5 Phishing Infrastructure Indicators

| Surface | Pattern |
|---|---|
| **Cloudflare Tunnel (`*.trycloudflare.com`)** | Free-tunnel name in suspicious URL — operationally cheap and short-lived |
| **ngrok (free `*.ngrok-free.app` / `*.ngrok-free.dev`; paid `*.ngrok.app` / `*.ngrok.dev` / `*.ngrok.io`)** | Free-tunnel tooling abused for short-lived phishing |
| **Serverless (`*.azurewebsites.net`, `*.web.app`, `*.firebaseapp.com`, `*.netlify.app`, `*.vercel.app`, `*.cloudfront.net`, `*.r2.dev`, `*.pages.dev`, `*.workers.dev`)** | Serverless / managed-hosting platforms abused for phishing pages; verify provider abuse contacts |
| **Compromised legitimate domains** | Older WordPress / cPanel sites with vulnerable plugins host kits in subdirectories; `<legitimate>/<random-path>/<kit>/` |
| **Residential-proxy ASN egress** | Sign-in / phishing-victim-fetch from residential-proxy ASN |
| **Free-mail attacker addresses for exfil** | `*@gmail.com` / `*@outlook.com` / `*@protonmail.com` / `*@yandex.com` / `*@onionmail.org` in kit `config.php` |
| **Telegram bot exfil** | `api.telegram.org/bot<token>/sendMessage?chat_id=<id>` — token reuse across campaigns is common |
| **Open-directory exposure** | `Index of /` / `Apache/2.X Server` directory listing allows kit retrieval at investigation time |

### 12.6 Disclosure of Findings

- **Hosting / CDN / registrar abuse-contact disclosure** — for active infrastructure, route through documented abuse channels (AWS abuse form or trustandsafety@support.aws.com, Cloudflare abuse, the registrar's published abuse contact from WHOIS / RDAP, etc.) [verify 2026-10-30].
- **Brand-coordination disclosure** — when the kit impersonates a brand, the brand's security team is the disclosure path (Microsoft MSRC, Google security, Apple Product Security, the brand's CSIRT).
- **Threat-intel community sharing** — kit IOCs can be shared via APWG (forward to reportphishing@apwg.org), Netcraft (https://report.netcraft.com/report), OpenPhish (report@openphish.com), PhishTank (existing accounts only; new registration is disabled), MISP communities, the NCSC's suspicious-email address (report@phishing.gov.uk), CISA (formerly US-CERT; us-cert.gov redirects to cisa.gov), and sector-specific ISACs (FS-ISAC for finance, H-ISAC for healthcare) [verify 2026-10-30].
- **LE referral** — for active campaigns with significant victimization, FBI IC3 referral and Secret Service Field Office contact (US); NCSC (UK); national CERT pathway elsewhere.

---

## 13. Wire-Recall Pathway & Financial Recovery

### 13.1 What the Investigator Owns vs Doesn't

The investigator does not own the customer's banking relationship; the customer's treasurer / CFO / fraud-claims team coordinates with the bank. The investigator's job is to *enable* the recovery operation through forensic outputs:

- **A timeline** — when was the message received; when was the wire authorized; when was the wire transmitted; when was the fraud detected.
- **A wire reference** — the originating bank's wire reference number; the SWIFT GPI **UETR** (Unique End-to-End Transaction Reference, ISO 20022 [verify 2026-10-30]); the Fedwire IMAD / OMAD; the SEPA reference.
- **Beneficiary detail** — beneficiary bank, beneficiary account / IBAN, beneficiary name (often a money-mule company or individual).
- **The pretext narrative** — the BEC reconstruction package (the email; the lookalike; the spoofed-CEO chain) that the FBI and bank fraud teams will reference.

### 13.2 SWIFT Recall Mechanics

**SWIFT MT103** was the legacy customer credit transfer message; the originating bank sends it to the beneficiary bank (often through correspondent banks). Since 22 November 2025 cross-border payment instructions use ISO 20022 (**pacs.008** for customer credit transfers), and MT 103s still sent are converted and delivered in ISO 20022 format. Recall is via a cancellation request (ISO 20022 **camt.056**, FI To FI Payment Cancellation Request) citing the original payment reference. The destination-bank's compliance team evaluates the cancellation request; if funds are still on hold, return is likely. **SWIFT GPI** tracks each payment end to end by its **UETR** (Unique End-to-End Transaction Reference; field 121 in MT messages, a dedicated element in ISO 20022 messages), so quote the UETR in every recall request [verify 2026-10-30].

Cross-border wire recalls engage both banks' AML / financial-intelligence-unit (FIU) coordination; the FBI Legal Attaché in the destination jurisdiction frequently coordinates the FIU contact.

### 13.3 Fedwire Recall

Fedwire transfers are domestic US dollar (mostly inter-bank) settlements. Fedwire funds transfers are governed by Regulation J Subpart B (12 CFR 210.25–210.32, which incorporates UCC Article 4A); recall depends on bank-to-bank cooperation, and the originating bank's wire-operations team initiates it. Recovery within the same business day is most likely; cross-day recall depends on beneficiary-bank cooperation. FedNow (the Federal Reserve's instant-payment service, live since 20 July 2023) is governed by Regulation J Subpart C (12 CFR 210.40–210.47); it moves money instantly, so the recall request has to start even sooner [verify 2026-10-30].

### 13.4 SEPA / EU Recall

SEPA Credit Transfer (SCT) exception handling uses **SCT R-transactions** — Rejects, Returns, Recalls and Requests for Recall by the Originator (RFRO) — plus a separate SCT Inquiry process, all defined in the EPC (European Payments Council) SCT Rulebook. A fraud-induced transfer is recalled with reason code `FRAD` (Fraudulent Origin); the Beneficiary PSP breaches the rulebook if it does not answer a Recall or RFRO within 15 Banking Business Days (EPC135-18 v6.0, November 2024). R-transactions travel through the same clearing and settlement mechanism (CSM) as the original transfer unless the PSPs have agreed otherwise. SEPA Instant Credit Transfer (SCT Inst) is a separate EPC scheme (launched November 2017; the payee's PSP has at most ten seconds to confirm receipt and make the funds available), so the money is with the beneficiary almost at once; check the SCT Inst rulebook for its own recall rules [verify 2026-10-30].

**Payee-verification and UK reimbursement context.** Under the EU Instant Payments Regulation, euro-area PSPs must offer Verification of Payee (VoP: a name / IBAN check returning match, close match, no match or other) on standard and instant credit transfers from 9 October 2025 (non-euro Member States from 9 July 2027); a VoP warning that the victim overrode is a reconstruction data-point. In the UK, Confirmation of Payee runs the same name check on Faster Payments and CHAPS, and since 7 October 2024 the PSR's mandatory APP-fraud reimbursement protections cover individuals, microenterprises and charities (not larger businesses) up to £85,000 per claim; unreimbursed losses above that can go to the Financial Ombudsman Service (award limit £455,000 for complaints referred on or after 1 April 2026 about acts on or after 1 April 2019) [verify 2026-10-30].

### 13.5 IC3 Referral and the Financial Fraud Kill Chain

```
Customer detects BEC wire
   ↓
Customer's fraud-claims team contacts originating bank fraud desk
   ↓ (within hours)
Originating bank issues recall (SWIFT camt.056 cancellation request / Fedwire recall / SEPA recall)
   ↓ (concurrently)
Customer files at IC3.gov  (https://www.ic3.gov) — regardless of amount
   ↓
IC3 Recovery Asset Team (RAT) liaises with the banks and FBI field offices
   ↓ (no published dollar threshold; speed decides)
IC3 RAT initiates the Financial Fraud Kill Chain (FFKC)
   ↓ (international transfers)
RAT coordinates with FinCEN's Rapid Response Team and the FBI Legal Attaché (LEGAT); destination FIU engaged
   ↓
Destination FIU coordinates with destination bank for funds freeze
   ↓
Destination bank holds funds pending civil / criminal action
```

Practical investigator actions:

- **Help the customer assemble the IC3 packet** — wire confirmation; recipient bank info; beneficiary info; copy of the BEC email; lookalike domain analysis; investigator contact info. IC3 has a structured intake form; file as soon as possible — FinCEN is "most likely to be able to interdict or recover funds when fraudulently induced wire transfers are reported to law enforcement within 72 hours of the transaction" (FinCEN Rapid Response Program fact sheet, April 2026), and IC3 publishes RAT / FFKC outcomes in its annual report [verify 2026-10-30].
- **No FFKC dollar threshold** — IC3 publishes none: "Regardless of the amount lost, file a complaint with www.ic3.gov as soon as possible" (IC3 PSA, 11 September 2024). The IC3 Recovery Asset Team (established 2018) runs the FFKC for domestic and international transfers; international requests go through FinCEN's Rapid Response Team and FBI LEGAT offices (IC3 2025 Annual Report). The older USD 50,000 / SWIFT / 72-hour eligibility list is historical and unpublished; never use it as a reason to skip a filing (§3.3) [verify 2026-10-30].
- **Coordinate with bank's BSA / AML officer** — the customer's bank has Bank Secrecy Act SAR-filing obligations triggered by the fraudulent transfer (FinCEN's 31 CFR 1020.320 triggers at $5,000 aggregate when the bank knows, suspects or has reason to suspect the transaction is illicit; the prudential regulators' parallel rules — e.g. OCC 12 CFR 21.11 — add tiers: insider abuse at any amount, $5,000 or more where a suspect can be identified, $25,000 or more regardless of suspects) [verify 2026-10-30]; the SAR-filing process is the bank's, not the investigator's, but the investigator's reconstruction supports it.

### 13.6 ACH and Check Recall

ACH unauthorized debits to consumer accounts can be returned by the receiving depository financial institution (RDFI) as R10 within 60 days with a Written Statement of Unauthorized Debit (WSUD) under the Nacha Operating Rules, in line with the consumer's 60-day error-notice window under Regulation E (12 CFR 1005.11); for non-consumer (B2B) accounts the unauthorized-debit return is R29 within 2 banking days (Nacha amends its Operating Rules regularly) [verify 2026-10-30]. Regulation J covers check collection through the Reserve Banks, Fedwire and FedNow; ACH returns run under the Nacha Operating Rules. An ACH credit the victim *originated* is not an unauthorized debit: ask the originating bank to request a recall / reversal (§3.2 payroll-redirect row). Check fraud (counterfeit check, altered check, payee endorsement fraud) routes through UCC Articles 3 and 4; recovery via the originating bank's check-fraud claims process.

### 13.7 Cryptocurrency Payout Recovery

When BEC payout instructed cryptocurrency:

1. **Capture the wallet address** from the message body (or QR code via OCR) immediately; confirm on-chain receipt.
2. **Submit to sanctions / abuse databases** — Chainalysis Reactor, TRM Labs, Elliptic, Crystal Intelligence (ex-Crystal Blockchain), Etherscan label-tagging [verify 2026-10-30].
3. **Hand off the on-chain trace** to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] when funds funnel into Tornado Cash / Wasabi / Samourai-style services.
4. **Coordinate with destination CEX compliance** — when funds arrive at a centralized exchange, that exchange's compliance team can freeze the deposit if law-enforcement preservation request is in place. Binance, OKX, Kraken and Bitstamp publish law-enforcement request pathways; Kraken states it responds to lawful requests to freeze funds identified and held with it [verify 2026-10-30].
5. **Sanctions consideration** — if the wallet is on an OFAC SDN list (Treasury sanctioned address), the customer's bank and CEX have sanctions-blocking obligations; route through [[sop-legal-ethics|Legal & Ethics]] for sanctions-counsel.

### 13.8 Insurance Claim Considerations

Cyber and crime policies frequently distinguish:

- **Computer fraud** — funds obtained by a computer-fraud-pattern theft; broader coverage.
- **Funds-transfer fraud** — narrower; covers fraudulent wire / ACH / EFT.
- **Social-engineering fraud** — increasingly common rider; explicitly covers BEC; often sub-limited.
- **Reputational-harm coverage** — separate.

Notification clocks (often "as soon as practicable" but with named carrier-specific clocks of 24/48/72 hours from discovery) and forensic-vendor-panel requirements can affect coverage. Verify the carrier and the policy under counsel before any state-changing action that might prejudice the claim. The policy may *require* engaging a panel forensic firm; an off-panel firm's fees may not be reimbursable.

### 13.9 What Goes in the Final Report (Financial Section)

The wire-recall section of the BEC report typically contains:

- Transaction-level table: timestamp; originating account; beneficiary account; amount; FX rate (if cross-currency); UETR / Fedwire reference / SEPA reference.
- Recall actions taken: who acted, when, on what authority, with what bank-side reference; outcome.
- IC3 reference number (the IC3 case number issued at intake).
- FFKC engagement status (IC3 RAT request and freeze outcome).
- SAR coordination — note that the customer's bank has independent SAR obligations the investigator should not impede; the investigator's report does not file or substitute for a SAR.
- Insurance-carrier notification status.
- Funds recovered (cumulative); funds outstanding; civil / criminal action recommendations.

---

## 14. Hand-off Boundaries

| When the investigation observes... | Routes to... |
|---|---|
| SaaS-tenant identity / collaboration evidence (M365 UAL, Workspace Reports, Okta System Log, Slack Discovery, mailbox audit, inbox-rule forensics, OAuth consent grants) | [[sop-saas-log-forensics|SaaS Log Forensics]] |
| OAuth-consent BEC variant (attacker-app token persistence) | [[sop-saas-log-forensics|SaaS Log Forensics]] §10 — owned there per scope contract |
| Header-spoofing BEC / lookalike-domain BEC / wire-fraud BEC (this SOP's primary scope) | This SOP |
| IaaS plane evidence (CloudTrail / Activity Log / Cloud Audit Logs; IAM forensics on cloud resources; container / Kubernetes runtime; cloud-volume snapshots) | [[sop-cloud-forensics|Cloud Forensics]] |
| Cloud-resident malware payload (binary in OneDrive / SharePoint / Drive / Slack / Files; OAuth-app code; CI/CD malicious dependency) | [[sop-malware-analysis|Malware Analysis]] |
| Attachment static / dynamic analysis (Office macro, PDF, ISO, HTA, LNK, OneNote payload, archive) | [[sop-malware-analysis|Malware Analysis]] §3, §4, §6 |
| Recovered phishing-kit deep static / dynamic RE | [[sop-malware-analysis|Malware Analysis]] §6.4 + [[sop-reverse-engineering|Reverse Engineering]] |
| Crypto-mining / wallet-stealer payload — on-chain consequences | [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] |
| Cryptocurrency-payout BEC: scenario reconstruction lives here; on-chain trace once funds are deposited | [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] |
| Mixer / privacy-pool laundering downstream of crypto-payout BEC | [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] |
| Smart-contract code review (when payout funnels through a contract) | [[sop-smart-contract-audit|Smart Contract Audit]] |
| Cryptographic-primitive concern (DKIM key strength, signing-cert primitive review) | [[sop-cryptography-analysis|Cryptography Analysis]] |
| Banking-pivot / SAR-typology / UBO-tradecraft / structuring-pattern research | [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] |
| Wire-recall *operations* (this SOP §13) vs banking-pivot *intelligence* layer | This SOP §13 owns the recall operation; AML intelligence layer routes to financial-aml-osint |
| Host / disk / memory parsing of victim laptop, exported PST, recovered phishing-kit operator endpoint | [[sop-forensics-investigation|Digital Forensics Investigation]] |
| Adversary infrastructure clearnet pivot (lookalike domain enrichment, hosting / registrar / WHOIS investigation) | [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] |
| Adversary-tied account / handle / persona dossier | [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] |
| Marketplace / forum / leak-site presence of BEC-related credentials, kit listings, tutorials | [[../../Investigations/Techniques/sop-darkweb-investigation|Darkweb Investigation]] |
| Authorized offensive phishing / red-team email tradecraft | (no Intel Codex SOP yet) |
| Container / Kubernetes runtime forensics that follow a cloud-credential exfiltration | [[../Pentesting/sop-container-k8s-pentest|Container & Kubernetes Pentesting]] for offensive aspects; [[sop-cloud-forensics|Cloud Forensics]] §10 for forensics |
| SIEM / SEG / EDR detection-coverage validation (purple-team for BEC) | [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] |
| Bug-bounty-style web-app vulnerability in a customer-facing portal whose abuse enabled the BEC | [[../Pentesting/sop-web-application-security|Web Application Security]] + [[../Pentesting/sop-bug-bounty|Bug Bounty]] |
| Sensitive-crime indicators (CSAM in attachments / linked content; trafficking-pattern in BEC-adjacent extortion / sextortion mail; threat-to-life findings) | [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — **hard-stop** for CSAM; URL + timestamp only, no content preservation |
| Final reporting / disclosure mechanics | [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] |
| Authorization, jurisdiction, prohibited actions, wire-fraud-statute interaction | [[sop-legal-ethics|Legal & Ethics]] |
| Investigator infrastructure / artifact hygiene / pre-disclosure handling | [[sop-opsec-plan|OPSEC]] |

---

## 15. Tools Reference

### Mail-Auth and Header-Forensics

| Tool | Purpose | Link |
|------|---------|------|
| `dig` / `drill` / `kdig` | DNS lookups for SPF / DKIM / DMARC / BIMI records | (system) |
| `dkimpy` / `opendkim-testmsg` | DKIM signature verification | https://launchpad.net/dkimpy / https://github.com/trusteddomainproject/OpenDKIM |
| `pyspf` / `spf-tools` | SPF evaluation, lookup-count check | https://launchpad.net/pyspf / https://github.com/spf-tools/spf-tools |
| `parsedmarc` | DMARC aggregate + forensic report parser | https://github.com/domainaware/parsedmarc [verify 2026-10-30] |
| OpenARC | ARC chain validation (milter); upstream `trusteddomainproject/OpenARC` last pushed 2024-04, so use the maintained fork | https://github.com/flowerysong/OpenARC [verify 2026-10-30] |
| `swaks` | SMTP test client (sandbox use only — never against production with real targets) | https://github.com/jetmore/swaks |
| MXToolbox Email Header Analyzer | Web-based header parser by MXToolbox | https://mxtoolbox.com/EmailHeaders.aspx [verify 2026-10-30] |
| Microsoft Message Header Analyzer | Web-based header parser by Microsoft | https://mha.azurewebsites.net/ [verify 2026-10-30] |
| Google Toolbox MessageHeader | Web-based header parser by Google | https://toolbox.googleapps.com/apps/messageheader/analyzeheader [verify 2026-10-30] |
| MXToolbox SuperTool | Web-based DNS / mail-flow analysis | https://mxtoolbox.com/SuperTool.aspx |

### Lookalike-Domain Tooling

| Tool | Purpose | Link |
|------|---------|------|
| `dnstwist` | Generator-resolver for lookalike-domain candidates | https://github.com/elceef/dnstwist |
| `urlcrazy` | Alternate generator | https://github.com/urbanadventurer/urlcrazy |
| `urlinsane` | Alternate generator (Go) | https://github.com/rangertaha/urlinsane |
| `crt.sh` | Certificate Transparency log search (free) | https://crt.sh |
| `Censys` | CT log + internet scan + cert search (commercial, free tier) | https://censys.com |
| `confusable-homoglyphs` | Python UTS #39 confusables analyzer (GitHub repo archived Jan 2024; maintained on sr.ht) | https://sr.ht/~valhalla/confusable_homoglyphs/ [verify 2026-10-30] |
| `whois` / `whoisxmlapi` | WHOIS lookup, current and historical (commercial) | (system) / https://www.whoisxmlapi.com [verify 2026-10-30] |
| DomainTools Iris / Investigate | Commercial passive-DNS + WHOIS-history + brand-protection | https://www.domaintools.com [verify 2026-10-30] |
| Group-IB Digital Risk Protection | Commercial brand / domain monitoring | https://www.group-ib.com [verify 2026-10-30] |
| Microsoft Defender EASM (ex-RiskIQ) | Commercial external-attack-surface management (Microsoft acquired RiskIQ in 2021) | https://www.microsoft.com/en-us/security/business/cloud-security/microsoft-defender-external-attack-surface-management [verify 2026-10-30] |
| ZeroFox / BrandShield / Mandiant Digital Threat Monitoring | Commercial brand-protection platforms | https://www.zerofox.com / https://www.brandshield.com / https://cloud.google.com/security/products/digital-threat-monitoring [verify 2026-10-30] |

### M365 / Workspace / SEG Forensic Surfaces

| Tool | Vendor | Purpose |
|------|--------|---------|
| `Get-MessageTrace` / `Get-MessageTraceDetail` | Microsoft 365 (Exchange Online PowerShell) | Legacy mail-flow tracing (10-day window); Microsoft: "replaced by the Get-MessageTraceV2 cmdlet and will eventually be deprecated" |
| `Get-MessageTraceV2` / `Get-MessageTraceDetailV2` | Microsoft 365 (Exchange Online PowerShell) | Successor cmdlets: 90-day search window, at most 10 days per query, last 48 hours when run without parameters [verify 2026-10-30] |
| `Get-MessageTrackingLog` | Exchange Server (on-prem) | On-prem mail-flow tracking |
| Defender for Office 365 Threat Explorer | Microsoft 365 | Per-recipient delivery / disposition |
| Defender for Office 365 Quarantine | Microsoft 365 | Quarantined-message inspection |
| `Get-QuarantineMessage` | Microsoft 365 | Programmatic quarantine pull |
| Workspace Email Log Search | Google Workspace | 30-day per-message routing / disposition |
| GAM7 (installs as `gam`) | Google Workspace | CLI for Reports + Email Log + Vault |
| Workspace Vault | Google Workspace | eDiscovery + holds for long-term mail-content evidence |
| Gmail BigQuery export | Google Workspace | Long-window message-event evidence |
| Mimecast Tracker / Search & Recover / Audits | Mimecast | Per-message routing + archive search |
| Proofpoint Smart Search / Threat Insight / TAP / TRAP | Proofpoint | Per-message + campaign + URL / attachment analysis |
| Cisco Secure Email Message Tracking | Cisco | On-prem / cloud appliance mail-flow tracking |
| Barracuda Email Gateway Defense Message Log | Barracuda | Per-message routing |
| Sophos Central Email Message Search | Sophos | Per-message routing (the on-prem Sophos Email Appliance is end of life) |

### Phishing-Kit / Sandbox / Detonation

| Tool | Purpose | Link |
|------|---------|------|
| Microsoft Defender for Office 365 Detonation | Sandbox detonation of URLs / attachments | (in-product) |
| Joe Sandbox | Commercial sandbox | https://www.joesandbox.com [verify 2026-10-30] |
| ANY.RUN | Commercial sandbox | https://any.run [verify 2026-10-30] |
| Hatching Triage | Commercial sandbox (acquired by Recorded Future) | https://tria.ge [verify 2026-10-30] |
| URLScan.io | URL crawl with full HAR + screenshot + DOM | https://urlscan.io |
| PhishTool | Phishing analysis platform | https://www.phishtool.com [verify 2026-10-30] |
| PhishTank | Crowd-sourced phishing-URL clearinghouse | https://phishtank.org |
| OpenPhish | Phishing-URL feed | https://openphish.com |

### Wire-Recall and Financial-Recovery

| Resource | Purpose |
|----------|---------|
| FBI IC3 | https://www.ic3.gov — Internet Crime Complaint Center filing |
| FBI Field Office contact | Direct field-office contact for active wire fraud |
| Secret Service Field Office | Concurrent jurisdiction for financial crimes (US) |
| FinCEN Rapid Response Program (RRP) | https://www.fincen.gov/system/files/2026-04/RRPFactSheet.pdf — activated through an IC3 complaint or a USSS field office; FinCEN: "Please do not contact FinCEN directly" [verify 2026-10-30] |
| SWIFT gpi UETR tracking + camt.056 cancellation request | Originating-bank operations via the Swift network |
| EPC (European Payments Council) Rulebooks | SEPA / SCT Inst recall rules — https://www.europeanpaymentscouncil.eu [verify 2026-10-30] |
| NCSC (UK) | https://www.ncsc.gov.uk — UK cyber-fraud reporting + advice |
| Report Fraud (UK; replaced Action Fraud 2025-12-04) | https://www.reportfraud.police.uk — UK fraud and cyber crime reporting; 0300 123 2040; Scotland: Police Scotland 101 [verify 2026-10-29] |
| Europol EC3 | https://www.europol.europa.eu/about-europol/european-cybercrime-centre-ec3 — EU cybercrime |

### Open-Source / Vendor-Neutral

| Tool | Purpose | Link |
|------|---------|------|
| Sigma | Vendor-neutral detection rules with M365 / Workspace / SEG backends | https://github.com/SigmaHQ/sigma |
| MITRE ATT&CK for Initial Access (Phishing) | Adversary technique reference | https://attack.mitre.org/techniques/T1566/ |
| MISP | Threat-intel sharing platform with phishing-kit support | https://www.misp-project.org |
| TheHive / Cortex | IR case-management + observable enrichment | https://strangebee.com/thehive/ |
| OpenCTI | Threat-intelligence platform with kit / domain / actor objects | https://filigran.io/products/opencti [verify 2026-10-30] |

---

## 16. Risks & Limitations

- **Header forgery is trivial above the trusted MTA.** Any attacker can prepend arbitrary `Received:` / `Authentication-Results:` headers; only the headers added at and below the recipient's *trusted* boundary MTA carry evidentiary weight. Read headers bottom-up from the trusted boundary, not top-down from sender claims.
- **Display-name spoofing is the most common BEC vector and bypasses all DNS-based authentication.** A message with `From: "John CEO" <attacker@gmail.com>` may pass SPF / DKIM / DMARC because authentication validates `gmail.com`, not the display name `John CEO`. Mobile mail clients hide the address and show only the display name; recipient training plus DMARC-enforcing branded sender policies are the defensive answer, not authentication.
- **DMARC `p=none` is monitoring, not enforcement.** A domain with `p=none` collects aggregate reports but does not instruct receivers to take action; messages failing alignment are still delivered. Many large brands have lived in `p=none` for years; the BEC investigator must not infer "DMARC blocked it" from the existence of a DMARC record.
- **DMARC alignment is binary.** A message either aligns or it does not; partial alignment does not exist. Sub-domain attacks (`From: ceo@accounts.example.com`) require `sp=` consideration even when `p=` is enforced.
- **DKIM `l=` length tag enables silent body modification.** Any signing domain still emitting `l=` is forensically suspect; cross-walk to `c=` canonicalization and verify whether the modification is benign (mail-list footer) or malicious (content injection).
- **ARC trust is recipient policy.** A valid ARC chain is informational unless the recipient *trusts* the sealer. ARC does not retroactively make a forwarded spoof legitimate.
- **BIMI does not authenticate the sender's content.** A BIMI-rendered logo proves DMARC-pass + VMC validity at delivery; it does not prove the message body / pretext is honest.
- **Source-IP geolocation is approximate.** Country / ASN is reliable; city / specific-company-attribution is brittle. Residential proxies and VPNs degrade location signal substantially.
- **Lookalike-domain inventory is incomplete.** No tool catches every variant; CT logs only catch certificate-issued lookalikes; passive DNS catches only resolved lookalikes. Continuous monitoring with multiple tools and human review is the closest to a complete picture.
- **Wire recall depends on speed and beneficiary-bank cooperation.** Within 24 hours, recall is plausible; beyond 72 hours, recovery rates fall sharply. The investigator does not control the bank's response time.
- **Cryptocurrency-payout recovery is rarely possible.** Once funds are on-chain to a non-custodial wallet, recovery requires either downstream CEX-deposit + LE preservation or a court-ordered seizure path; chargeback / reversal does not exist on-chain.
- **AiTM and session-token theft defeat MFA.** "We had MFA enabled" is not protective; the attacker captures the post-MFA session. Phishing-resistant MFA (FIDO2 / certificate-based authentication), Conditional Access policies (compliant device, sign-in risk, network / named locations), Continuous Access Evaluation, and Conditional Access Token Protection (device-bound sign-in session tokens) are the layered mitigations [verify 2026-10-30].
- **Phishing-kit acquisition has legal nuance.** Lawful acquisition paths are documented in §12.2; downloading from a live-attacker server is widely accepted as defensive forensics but may interact with anti-hacking statutes if the server is owned by a non-suspect third party. Verify under counsel for anything beyond the customer's own infrastructure.
- **SAR / FinCEN obligations are the bank's, not the investigator's.** The investigator's reconstruction supports the bank's SAR but does not substitute for it; the customer's bank has independent BSA obligations.
- **Insurance coverage may exclude social-engineering BEC.** Older policies cover computer-fraud and funds-transfer-fraud but exclude social-engineering. Newer policies add a sub-limited social-engineering rider. The investigator must not promise coverage outcomes.
- **Court-admissibility of mail-flow evidence depends on chain-of-custody.** Provider-side declarations (eDiscovery export with provider attestation per [[../../Investigations/Techniques/sop-collection-log|Collection Log]] §10 FRE 902(13)/(14)) are evidentiary-grade; raw `Get-MessageTraceV2` output without provider attestation is weaker. Plan exports through eDiscovery / Vault / Discovery for litigation-bound work.
- **Cross-tenant log visibility is asymmetric.** When the suspect's tenant is on the same provider as the victim, the suspect-side mail-flow is reachable only via provider legal process (subpoena / preservation letter); the victim-side mail-flow is in scope.
- **Multi-vendor SEG disagreement is common.** Mimecast / Proofpoint / Defender / Barracuda each apply distinct policies; SEG-A may have quarantined what SEG-B delivered. The chronological reconstruction must reconcile all transit-point dispositions.

---

## 17. Common Pitfalls

- **Reading headers top-down.** The top-most `Received:` is the latest hop; the bottom-most is closest to origin. Bottom-up is the rule.
- **Trusting `From:` over `Authentication-Results:`.** The `From:` is sender-controlled; the trusted `Authentication-Results:` is the evidence.
- **Inferring "DMARC blocked it" from existence of DMARC.** Confirm the policy (`p=`) and the alignment (`adkim` / `aspf`); `p=none` is monitoring.
- **Forgetting partial rollout or test mode.** Legacy `pct=10` asks RFC 7489-era receivers to apply the policy to only 10% of failing mail; RFC 9989 `t=y` asks receivers to apply one level below the published policy. Verify the published policy is not in partial rollout or test mode.
- **Mixing envelope `MAIL FROM` with header `From:`.** SPF authenticates the envelope; DMARC requires alignment to the header `From:`.
- **Ignoring sub-domain policy (`sp=`).** Attackers register `accounts.example.com` against an `example.com` `p=reject; sp=none` posture; receiver behavior on the sub-domain is permissive.
- **Skipping the trusted-MTA boundary identification.** Without identifying which MTA is "trusted," every header is suspect and no decision is defensible.
- **Treating SEG quarantine release as recovery.** Releasing a quarantined message moves it to the inbox — the user may now act on it. Quarantine release is a state-changing action; document and require explicit authorization.
- **Releasing after recovery.** Some IR processes auto-release messages flagged in error; a release after a confirmed BEC is a *secondary* compromise.
- **Investigating without holding evidence.** The mailbox-side audit log expires; the gateway log expires; the SEG quarantine expires. Hold-first per [[sop-saas-log-forensics|SaaS Log Forensics]] §12 before deepening.
- **Not capturing the original `.eml`.** Forwarding strips and rewrites authentication; capture `.eml` from the source mailbox or via API; do not rely on forwarded copies.
- **Over-trusting passive DNS history.** Passive-DNS sources have varying coverage, retention, and freshness; cross-check at least two sources before drawing definitive timelines.
- **Skipping `Reply-To:` analysis.** A `From:` matching the legitimate sender with `Reply-To:` to a free-mail address is a classic BEC tell that authentication does not catch.
- **Skipping `Return-Path` analysis.** A spoofed `From:` with a different `Return-Path` (envelope sender) is the SPF-decoupled-from-DMARC pattern; SPF passes on the envelope while `From:` is the spoof.
- **Pre-filtering message-trace queries too narrowly.** Filtering at the `Get-MessageTraceV2` query loses surrounding context; pull broad on time and recipient, filter at analysis time.
- **Ignoring SaaS-side mailbox-rule pivots.** A clean header-forensics report does not preclude that the mailbox was compromised; cross-walk to inbox-rule / mailbox-audit forensics in [[sop-saas-log-forensics|SaaS Log Forensics]].
- **Not coordinating wire recall with the bank in the first 4 hours.** Recall before correspondent-bank settlement is materially easier; the recall conversation begins with the customer's bank fraud team, not the investigator.
- **Treating IC3 as the only LE path.** IC3 is the FBI's intake channel; FBI Field Office, Secret Service, state AGs, NCSC (UK), and Europol all have direct contact paths for active wire fraud.
- **Forgetting insurance notification clocks.** Some cyber/crime policies have 24-hour notification clocks; missing them can void coverage.
- **Operating phishing-kit decompositions outside a sandbox.** Kit code (PHP / JS / Python) frequently includes credential-harvest endpoints that auto-fire; analyze in sealed sandbox per [[sop-malware-analysis|Malware Analysis]] discipline.
- **Confusing OAuth-consent BEC with this SOP's surface.** OAuth-consent BEC mailbox-token-persistence is in [[sop-saas-log-forensics|SaaS Log Forensics]] §10 per scope contract; this SOP covers the header-spoofing / lookalike-domain / wire-pretext side. Reference the carve-in; do not duplicate.
- **Pasting raw header content into the report.** Tooling output is appendix material; findings are interpreted prose with referenced evidence IDs.
- **Stale credentials in investigator notes.** Engagement tokens (Exchange Online admin, GAM service-account key, Mimecast / Proofpoint console tokens) become a future-engagement liability. Rotate and document destruction at engagement end.

---

## 18. Real-World Scenarios

The scenarios below abstract observed BEC patterns to illustrate how the methodology in this SOP applies. They are pattern catalogues, not engagement-specific narratives.

### 18.1 Scenario — Lookalike-Domain CEO Wire Fraud

**Pattern.** Attacker registers `examp1e-corp.com` (digit `1` for letter `l`) one week before the incident. The domain is on a commodity registrar (NameSilo / Hostinger / NameCheap), DNS at Cloudflare, MX pointed at a free SMTP relay. The attacker sets up SPF (`v=spf1 include:_spf.<smtp-relay>.com -all`) and DKIM under the lookalike domain. Mail authenticates cleanly (SPF=pass on `examp1e-corp.com`; DKIM=pass for `examp1e-corp.com`; DMARC=pass because the *lookalike's* `From:` domain is the same as the SPF/DKIM signer). The attacker mails the customer's CFO from `ceo@examp1e-corp.com` (display: `John CEO <ceo@examp1e-corp.com>`) requesting an urgent USD 240,000 wire to a Hong Kong beneficiary to close a confidential M&A deal, citing the legitimate CEO's known travel pattern.

**Forensic catch.** §4.2 trusted `Authentication-Results:` confirms the message *did* pass DMARC — but for the lookalike domain, not the legitimate `example-corp.com`. §9.3 dnstwist scan against `example-corp.com` surfaces `examp1e-corp.com` (along with siblings); §9.4 CT-log search shows the cert was issued seven days before the incident (recently-registered signal). §9.5 WHOIS / DNS / hosting enrichment ties the registration to a NameSilo + Cloudflare + Hetzner pattern with sister-domain matches (`exampie-corp.com`, `examplecorp-secure.com`); §10.1 `Get-MessageTraceV2` confirms the inbound delivery and recipient action; §13 confirms the wire was transmitted at 14:42 UTC and is at the correspondent-bank stage at incident detection.

**Hand-off.** §13 wire-recall begins immediately — customer's bank sends a SWIFT camt.056 cancellation request; IC3 referral filed; IC3 RAT initiates the FFKC request. Lookalike-domain take-down request to NameSilo and Cloudflare. Adversary-infrastructure intelligence packaged for [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] follow-on. Mailbox-side audit (was the legitimate CEO's mailbox compromised, did the attacker monitor inbound?) routes to [[sop-saas-log-forensics|SaaS Log Forensics]] for confirmation.

### 18.2 Scenario — Vendor-Invoice Fraud via Compromised Vendor Mailbox

**Pattern.** A trusted vendor's accounts-receivable mailbox is compromised (the vendor falls victim to a separate AiTM phishing attack). The attacker sits silently for two weeks, monitoring the vendor's outbound invoicing rhythm. When the vendor sends a USD 87,000 invoice to the customer, the attacker — operating from the *legitimate* vendor mailbox — replies-all to the existing thread with a "banking detail update" PDF that points to an attacker-controlled bank account. The customer's AP team, seeing thread continuity and authentic SPF / DKIM / DMARC from the vendor, processes the wire to the new beneficiary.

**Forensic catch.** §4.2 trusted `Authentication-Results:` confirms full DMARC pass — because the message *did* come from the vendor's legitimate domain via the vendor's legitimate MTA. §10.1 `Get-MessageTraceV2` shows the inbound message traversed normal mail-flow. §10.5 cross-walk to mailbox-compromise side at the vendor: the vendor's [[sop-saas-log-forensics|SaaS Log Forensics]] §4.2 sign-in audit, §4.5 mailbox audit, and §4.6 inbox-rule audit (likely a forwarding rule on AP-related subjects). The forensic header analysis here captures the *outbound* messages the compromised vendor mailbox sent; the *inbound* compromise is the vendor's IR engagement, not the customer's. §12.4 AiTM signature on the vendor side: the original phishing landing page that captured the vendor's session.

**Hand-off.** Mailbox-compromise reconstruction at the *vendor* routes to [[sop-saas-log-forensics|SaaS Log Forensics]] (the vendor's own engagement, not the customer's). Wire recall per §13 (challenging — the apparent message authentication was clean, so DMARC alerts did not fire; detection was post-payment). PDF attachment (the "banking-detail update") routes to [[sop-malware-analysis|Malware Analysis]] §6.3 PDF Analysis. Customer's vendor-management process for "out-of-band verification of banking-change requests" is the structural fix recommendation.

### 18.3 Scenario — Real-Estate Closing-Funds Fraud via Title-Agent Lookalike

**Pattern.** Attacker registers `<title-agent>.<lookalike-tld>` (e.g., the legitimate title agent `ABC Title Co` operates `abctitle.com`; attacker registers `abctitle.co` or `abctitle-secure.com`). Attacker enrolls in the buyer's email thread (often via a spoofed reply at the right phase of the closing process) impersonating the title agent's closing coordinator. With closing two days away, attacker sends "wire instructions" to the buyer naming an attacker-controlled bank. Buyer wires USD 480,000.

**Forensic catch.** §4 header analysis on the attacker's "wire instructions" message — `From:` is the lookalike domain, `In-Reply-To:` may be forged or the attacker hijacked an earlier thread message via the buyer-side compromise. §9 lookalike inventory against `abctitle.com` — surfaces the squat. §10.1 `Get-MessageTraceV2` on the buyer's mailbox shows the inbound message and any earlier suspicious authenticated messages. §9.4 CT-log shows the squat cert issuance timing.

**Hand-off.** Wire recall per §13 — particularly tight 24-hour window if detected at closing. ALTA escrow procedures and title-agent's E&O insurance carrier engaged. Civil action against the registrar / hosting provider for take-down + preservation. IC3 complaint plus FBI field-office notification; the IC3 Recovery Asset Team runs real-estate BEC wires through the FFKC like any other (the IC3 2024 Annual Report cites a real-estate BEC recovered this way). The buyer's mailbox compromise (if present) routes to [[sop-saas-log-forensics|SaaS Log Forensics]]; sometimes the buyer's mailbox is *not* compromised and the attacker harvested context from a public closing-process announcement or social-media post — in which case [[../../Investigations/Techniques/sop-image-video-osint|Image / Video OSINT]] and [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] reconstruct the OSINT trail.

### 18.4 Scenario — Cryptocurrency-Payout Vendor-Invoice Fraud

**Pattern.** Vendor-invoice-fraud variant where the attacker, instead of redirecting fiat wire, instructs the customer that the vendor "now accepts USDT for invoicing efficiency" and provides an attacker-controlled USDT wallet address in the attacker-modified invoice. The customer's AP team, encountering this for the first time, accepts the change and pays USD 38,000 in USDT on Tron (TRC20).

**Forensic catch.** §4 header analysis on the attacker's invoice message; §9 lookalike check (or mailbox-compromise check per §18.2 pattern). §10.1 message trace establishes the inbound message timeline. The wallet address is captured from the message body / PDF attachment.

**Hand-off.** On-chain trace of the USDT-TRC20 wallet routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; deposit-at-CEX coordination (Binance / OKX / Bybit) for freeze-at-CEX where possible per §13.7. Sanctions-screening overlay at [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] (the wallet may be on an OFAC SDN list or cross-walk to a known threat-actor cluster). PDF attachment to [[sop-malware-analysis|Malware Analysis]] §6.3 if it carries embedded payload. Wire-recall is not applicable; recovery focus is the on-chain trace and CEX freeze.

### 18.5 Scenario — AiTM Mailbox Compromise → Outbound Spear-Phish to Customer's Customer

**Pattern.** Customer's sales executive falls to an AiTM phishing attack (per §12.4) on `login-microsoftonline.<lookalike>.<tld>`; the attacker captures the sales executive's post-MFA session token. With mailbox access, the attacker enumerates the sales executive's customers, identifies a customer in active-renewal cycle, and sends a "renewal banking-detail update" message *from the legitimate compromised mailbox* to the customer's AP team. The customer's AP wires USD 64,000 to attacker beneficiary.

**Forensic catch.** §4.2 trusted `Authentication-Results:` confirms full DMARC pass — message came from the legitimate mailbox. §10.5 cross-walk to the mailbox-compromise side: [[sop-saas-log-forensics|SaaS Log Forensics]] §4.2 sign-in audit identifies the AiTM session origin (residential-proxy IP, unusual ASN); §4.6 inbox-rule audit identifies the auto-forward rule for "renewal" / "banking" / "AP" subjects (the attacker's persistence primitive on the mailbox). §10.1 `Get-MessageTraceV2` on the *outbound* legs shows the attacker's send pattern. §12.4 AiTM signature on the original phishing landing page (the lookalike host); §9 catches the lookalike domain.

**Hand-off.** Mailbox-compromise reconstruction routes to [[sop-saas-log-forensics|SaaS Log Forensics]] §4 and §10 (whether the compromise was OAuth-consent BEC or AiTM-session-token-replay). AiTM phishing-kit analysis routes to §12 here for kit-fingerprint extraction; deeper RE to [[sop-malware-analysis|Malware Analysis]] §6.4 Script Analysis. Wire recall per §13. Customer's customer notification (the *downstream* victim) coordinated through [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]]; the duty-of-care to the downstream victim is jurisdiction-specific and counsel-led.

---

## 19. Related SOPs

**Analysis (parent and adjacent):**
- [[sop-saas-log-forensics|SaaS Log Forensics]] — sibling SOP covering the SaaS-tenant identity / collaboration plane (M365 UAL, mailbox audit, inbox-rule forensics, OAuth consent grants, mailbox-compromise reconstruction). The OAuth-consent BEC variant lives in SaaS Log Forensics; this SOP covers the email-flow and header-spoofing side. Hybrid BEC incidents that pivot through mailbox compromise are split: the *messages* live here, the *mailbox audit* lives in SaaS Log Forensics.
- [[sop-cloud-forensics|Cloud Forensics]] — sibling SOP covering the IaaS plane. When BEC-stolen credentials enable cloud-resource action, the email side stays here; the cloud-resource action routes to Cloud Forensics.
- [[sop-forensics-investigation|Digital Forensics Investigation]] — parent template; host / disk / memory forensics methodology applied to artifacts produced by BEC engagements (PST exports, recovered phishing-kit operator endpoints, victim laptops).
- [[sop-malware-analysis|Malware Analysis]] — receives hand-off for attachment static / dynamic analysis (Office macro, PDF, ISO, HTA, LNK, OneNote payload, archive) per §6.2-6.8 of that SOP, and for deep RE of recovered phishing kits per §6.4 Script Analysis.
- [[sop-reverse-engineering|Reverse Engineering]] — for binary / native-code components inside recovered kits or attached payloads.
- [[sop-hash-generation-methods|Hash Generation Methods]] — evidence-integrity hashing for `.eml` exports, header dumps, gateway-log exports, recovered-kit archives, and analysis derivatives.
- [[sop-cryptography-analysis|Cryptography Analysis]] — when DKIM key strength, BIMI VMC primitive choice, or SAML / OIDC signing-key primitives need primitive-level review.
- [[sop-smart-contract-audit|Smart Contract Audit]] — when cryptocurrency-payout BEC funnels through a smart contract requiring on-chain code review.

**Pentesting (offensive counterparts):**
- [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] — purple-team validation of SEG / mailbox-provider / SIEM detection for header-spoofing, lookalike-domain, and AiTM patterns.
- [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] — for 0-day discovery in SEG / mail-flow service surfaces during investigation.
- [[../Pentesting/sop-web-application-security|Web Application Security]] — when a customer-facing portal's vulnerability enabled the BEC pretext (account-takeover, password-reset abuse).
- [[../Pentesting/sop-bug-bounty|Bug Bounty]] — for coordinated disclosure of phishing-kit-enabling vulnerabilities in SaaS provider authentication flows.

**Investigations (cross-domain):**
- [[../../Investigations/Techniques/sop-collection-log|Collection Log]] — canonical chain-of-custody and evidence-hashing workflow for every `.eml` capture, header dump, gateway-log export, kit archive.
- [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — fiat-banking pivot, SAR-typology, UBO investigation, structuring patterns; this SOP owns wire-recall *operations*, AML *intelligence* layer routes there.
- [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] — on-chain trace once cryptocurrency-payout BEC funds are deposited.
- [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] — when on-chain cryptocurrency-payout funds funnel through mixers / privacy pools.
- [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] — adversary-infrastructure clearnet pivot for lookalike domains, kit hosting, takedown coordination.
- [[../../Investigations/Techniques/sop-darkweb-investigation|Darkweb Investigation]] — when BEC-related credentials, phishing kits, or campaign infrastructure surface in marketplace / forum / leak-site contexts.
- [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] — for dossier compilation on identified threat-actor handles, money-mule personas, kit authors.
- [[../../Investigations/Techniques/sop-image-video-osint|Image / Video OSINT]] — analysis of screenshot evidence (the rendered phishing page, signature blocks, branding artifacts).
- [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — for CSAM / trafficking / threat-to-life findings in BEC-adjacent attachments / linked content (hard-stop routing).
- [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — disclosure mechanics, regulator notification packaging, third-party (vendor / customer / downstream-victim) notification.

**Cross-cutting:**
- [[sop-legal-ethics|Legal & Ethics]] — canonical jurisdictional framework, breach-notification timelines, wire-fraud-statute interaction (18 U.S.C. §1343 wire fraud, §1349 attempt and conspiracy, §1956 / §1957 money-laundering; UK Fraud Act 2006; equivalent EU and other-jurisdiction wire-fraud statutes), insurance-coverage interaction, and counsel-led decisions on cross-border evidence transfer.
- [[sop-opsec-plan|OPSEC]] — investigator infrastructure, artifact hygiene, pre-disclosure handling discipline; particular attention during active wire-fraud incidents where adversary may be monitoring victim infrastructure and IR-team operational signal can leak.

---

## Legal & Ethical Considerations

> Canonical jurisdictional framework lives in [[sop-legal-ethics|Legal & Ethics]]. The summary below is operational guidance for email and BEC forensics engagements specifically; do not substitute it for the cross-referenced source.

### Authorization

- **Tenant-administrator authorization** is the typical engagement authority for the recipient-side mail-flow surface. The customer's mailbox-provider admin authorizes the investigator's read-only role and any state-changing actions (sender-block, message purge, mailbox-rule disablement, OAuth-app revocation). Without it, the investigator's access is unauthorized regardless of the suspect's behavior.
- **Sender-side authorization is asymmetric.** The investigator cannot authenticate, sign, or query *sender-side* logs on infrastructure they do not own; provider legal process (subpoena / preservation letter) is the route for sender-side evidence on a third-party provider.
- **Provider legal process** for cross-tenant evidence — when the suspect's tenant is on the same provider as the victim, the provider's law-enforcement portal and customer-side legal-process pathways are the route. Microsoft, Google, Proofpoint, Cisco, Barracuda, AWS (SES), Twilio (SendGrid) and Sinch (Mailgun) publish law-enforcement / legal-process guidance; the required instrument (subpoena / warrant / MLAT / preservation letter) depends on data type and jurisdiction [verify 2026-10-30].
- **Cross-jurisdiction authorization.** EU-data, healthcare, payment, and government-tenant workloads carry residency / sovereignty constraints. CLOUD Act executive agreements, Schrems II / DPF / SCCs framing, MLATs, the Budapest Convention Second Additional Protocol (CETS 224; not yet in force — four of the five required ratifications as of April 2026) and, in the EU, the e-Evidence Regulation (EU) 2023/1543 (applies from 18 August 2026) shape cross-border evidence-transfer pathways. Verify under counsel [verify 2026-10-30].
- **Wire-fraud-statute interaction.** 18 U.S.C. §1343 (wire fraud), §1349 (attempt and conspiracy), §1956 / §1957 (money-laundering); UK Fraud Act 2006; EU and other-jurisdiction wire-fraud statutes. The investigator coordinates with prosecution / civil-litigation strategy through counsel; the engagement does not direct the prosecution.
- **Engagement scope drift.** BEC investigations expand: initial scope is one wire; mid-engagement scope adds vendor-side compromise, customer's-customer notification, and a pattern campaign across multiple victims. Any scope expansion needs documented re-authorization.

### Anti-Hacking Statute Framing

Email and BEC forensics actions are typically read-only against tenants and infrastructure the investigator is authorized to access — far inside the CFAA / Computer Misuse Act / Cybercrime Directive lines. Specifically:

- **Read-only collection within authorized tenants** — allowed.
- **State-changing actions (sender-block, message purge, mailbox-rule disablement, quarantine release / delete, OAuth-app revocation, domain take-down request)** — allowed only when the engagement explicitly authorizes them; document each action with attribution.
- **Phishing-kit acquisition from a live-attacker server** — generally accepted as defensive forensics when documented and proportionate; verify under counsel for anything beyond the customer's own infrastructure or non-suspect third-party hosting. Do not enumerate the suspect's broader infrastructure beyond what is needed.
- **Pivoting into adversary infrastructure observed during the investigation** — generally **not** authorized. "We saw the attacker's IP — let's port-scan their VPS" or "we saw the attacker's Telegram bot — let's enumerate it" crosses into unauthorized access. Attribution and intelligence are valuable; offensive pivots are not the investigator's job. Route adversary-infrastructure findings through threat-intel channels and provider abuse pathways.
- **Active-defense actions** (sinkhole the attacker's reply URL, beacon canary documents, deploy honeytoken credentials) — verify under counsel before any deployment; actions framed as "defensive" can be charged as offensive in some jurisdictions.

### Data-Subject and Privacy Considerations

- **GDPR Art. 6 / 9** — processing of personal data during investigation requires a lawful basis; legitimate interest is the typical basis but is balanced against data-subject rights. Mail content frequently contains special-category data; Art. 9 balancing is non-trivial.
- **GDPR Art. 33** — supervisory-authority notification within 72 hours of becoming aware of a personal-data breach.
- **GDPR Art. 34** — data-subject notification when the breach is high-risk to data subjects. BEC compromises that exposed mail content frequently meet the high-risk bar.
- **HIPAA Breach Notification Rule** — covered entities + business associates have 60-day notification windows. Mailboxes holding ePHI trigger this rule on compromise.
- **State breach laws** (US) — varies by state; California, New York (SHIELD Act) and many others have their own timelines and requirements; check the statute of each affected data subject's state under counsel.
- **PCI DSS Incident Response Plan** — required for cardholder-data environments.
- **Sectoral rules** — finance (NYDFS 23 NYCRR 500.17 — notice within 72 hours of determining that a cybersecurity incident occurred, FFIEC, EBA / DORA, GLBA Safeguards Rule), healthcare (HIPAA, NIS2 in EU), telecom — verify per engagement.
- **Wire-fraud-related disclosure** — beyond breach laws, wire fraud may trigger SEC cyber-disclosure (registrants: Form 8-K Item 1.05 within four business days of determining the incident was material), state insurance-commissioner reporting, and bank-regulator notification (OCC / FDIC / FRB / state — for the customer's bank); the disclosure interaction with the active recall operation needs counsel coordination.

### Disclosure Discipline

- Pre-disclosure findings are restricted to the engagement team and the client per the engagement contract.
- Findings affecting third parties (a vendor whose identity was impersonated; a customer of the customer who fell to a downstream pivot; an upstream SEG vendor whose detection failed) are escalated through the affected party's security contact, not embedded silently in the client's report.
- Vendor coordination is sometimes warranted (provider-resident vulnerability in service surface; widespread credential-leak indicator). MSRC, Google VRP, Cloudflare Trust & Safety, and most SEG vendors publish coordinated-disclosure paths.
- LE coordination — IC3 and FBI Field Office for active wire fraud; Secret Service Field Office for concurrent-jurisdiction financial crimes; NCSC (UK), Report Fraud (UK; formerly Action Fraud), Europol EC3, national CERTs in other jurisdictions. [verify 2026-10-29]
- Live-incident findings (the investigation discovers an active campaign attacking customers the investigator does not own) trigger immediate client escalation; the operational response is the client's, not the investigator's, unless explicitly contracted.

### Conflict-of-Interest Posture

- The investigator does not hold or trade securities of the affected entity during the engagement window.
- The investigator does not publish independent commentary on the engagement's substance during the engagement window.
- The investigator discloses any prior or concurrent engagements with adjacent parties (the affected entity's vendors, customers, competitors, the same impersonated brand in other recent engagements) before commencing.

### Post-Engagement Records

- Engagement repo + analysis artifacts retained per contract terms (typically 1-7 years; sometimes longer for litigation-hold cases — wire-fraud civil action frequently runs 18-36 months).
- `.eml` exports / header dumps / gateway-log exports retained per evidence-handling policy (cryptographically destroyed at engagement end if the contract requires; otherwise retained encrypted under engagement-specific keys).
- Recovered phishing-kit archives retained encrypted at rest per [[sop-opsec-plan|OPSEC]]; treat as malicious code per [[sop-malware-analysis|Malware Analysis]] storage discipline.
- Investigator engagement-scoped tokens (Exchange Online admin, GAM service-account, Mimecast / Proofpoint / Defender / SEG admin tokens, Cloudflare / registrar API keys for take-down coordination) rotated and destroyed at engagement end. Document the destruction.
- Litigation-hold provisions: wire-fraud civil-recovery actions can subpoena prior engagement material; document engagement decisions accordingly.

### Ethical Research Checklist

**Before engagement:**
- [ ] Written engagement contract (or internal IR activation) defining scope, time, deliverable, disclosure
- [ ] Tenant-admin authorization for read-only access; documented authority for state-changing actions
- [ ] Counsel review of cross-border data-transfer constraints, wire-fraud statutory interaction, insurance-policy notification clocks
- [ ] Conflict-of-interest disclosure complete

**During engagement:**
- [ ] Only access in-scope tenants; only act per scope
- [ ] Hash artifacts at acquisition; pair with provider-side declarations where available (eDiscovery / Vault / SEG-archive)
- [ ] Maintain chain-of-custody record per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]
- [ ] No pivots into adversary infrastructure beyond documented lawful acquisition paths
- [ ] No disclosure to non-engagement parties without explicit authorization; LE / IC3 / FFKC routed through customer + counsel
- [ ] Wire-recall operations coordinated through customer's bank; investigator does not direct the bank

**After engagement:**
- [ ] Report delivered per contract
- [ ] Notification clocks (GDPR / SEC / state laws / sectoral / insurance) met under counsel direction
- [ ] eDiscovery / Vault / `.eml` exports / gateway-log artifacts / kit archives / analysis derivatives handled per evidence-retention policy
- [ ] Engagement tokens / admin roles rotated / revoked
- [ ] Wire-recall outcome documented; civil / criminal action recommendations finalized

---

## 20. External & Reference Resources

**RFCs and standards:**
- RFC 5321 — Simple Mail Transfer Protocol — https://www.rfc-editor.org/rfc/rfc5321
- RFC 5322 — Internet Message Format — https://www.rfc-editor.org/rfc/rfc5322
- RFC 6376 — DomainKeys Identified Mail (DKIM) Signatures — https://www.rfc-editor.org/rfc/rfc6376
- RFC 7208 — Sender Policy Framework (SPF) for Authorizing Use of Domains in Email, Version 1 — https://www.rfc-editor.org/rfc/rfc7208
- RFC 9989 — Domain-Based Message Authentication, Reporting, and Conformance (DMARC) (Proposed Standard, May 2026; obsoletes RFC 7489) — https://www.rfc-editor.org/rfc/rfc9989 [verify 2026-10-30]
- RFC 9990 — DMARC Aggregate Reporting — https://www.rfc-editor.org/rfc/rfc9990
- RFC 9991 — DMARC Failure Reporting — https://www.rfc-editor.org/rfc/rfc9991
- RFC 7489 — Domain-based Message Authentication, Reporting, and Conformance (DMARC) (obsoleted; still what older reporters implement) — https://www.rfc-editor.org/rfc/rfc7489
- RFC 8463 — A New Cryptographic Signature Method for DKIM (Ed25519-SHA256) — https://www.rfc-editor.org/rfc/rfc8463
- RFC 8617 — The Authenticated Received Chain (ARC) Protocol — https://www.rfc-editor.org/rfc/rfc8617
- RFC 8601 — Message Header Field for Indicating Message Authentication Status — https://www.rfc-editor.org/rfc/rfc8601
- RFC 8616 — Email Authentication for Internationalized Mail — https://www.rfc-editor.org/rfc/rfc8616
- BIMI — Brand Indicators for Message Identification (no RFC; IETF Internet-Draft) [verify 2026-10-30]
- RFC 6591 — Authentication Failure Reporting Using the Abuse Reporting Format — https://www.rfc-editor.org/rfc/rfc6591
- RFC 6962 — Certificate Transparency — https://www.rfc-editor.org/rfc/rfc6962
- RFC 3492 — Punycode: A Bootstring encoding of Unicode — https://www.rfc-editor.org/rfc/rfc3492
- Unicode UTS #39 — Unicode Security Mechanisms — https://www.unicode.org/reports/tr39/
- ISO 20022 — Financial-services messaging (UETR / SWIFT GPI) — https://www.iso20022.org

**Vendor documentation:**
- Microsoft — Anti-spoofing protection — https://learn.microsoft.com/en-us/defender-office-365/anti-phishing-protection-spoofing-about [verify 2026-10-30]
- Microsoft — Email message tracing — https://learn.microsoft.com/exchange/monitoring/trace-an-email-message/trace-an-email-message [verify 2026-10-30]
- Microsoft — Defender for Office 365 Threat Explorer — https://learn.microsoft.com/defender-office-365/threat-explorer-real-time-detections-about [verify 2026-10-30]
- Google Workspace — Email Log Search — https://knowledge.workspace.google.com/admin/support/troubleshooting/find-messages-with-email-log-search [verify 2026-10-30]
- Google Workspace — Workspace logs export to BigQuery — https://knowledge.workspace.google.com/admin/reports/set-up-service-log-exports-to-bigquery [verify 2026-10-30]
- Mimecast — API 2.0 developer portal — https://developer.services.mimecast.com/ (the old tech-connect URL redirects to the API 1.0 archive) [verify 2026-10-30]
- Proofpoint — Email Protection / Smart Search — https://www.proofpoint.com/us/products/email-protection [verify 2026-10-30]
- Cisco Secure Email — https://www.cisco.com/c/en/us/products/security/email-security/index.html [verify 2026-10-30]
- Barracuda Email Protection — https://www.barracuda.com/products/email-protection [verify 2026-10-30]

**FBI / IC3 / law-enforcement:**
- FBI IC3 — Internet Crime Complaint Center — https://www.ic3.gov
- FBI IC3 public-service announcements (BEC PSAs are periodic, not strictly annual) — https://www.ic3.gov/PSA [verify 2026-10-30]
- FBI Field Office locator — https://www.fbi.gov/contact-us/field-offices
- US Secret Service Field Offices — https://www.secretservice.gov/contact/field-offices
- FinCEN — https://www.fincen.gov
- FinCEN Rapid Response Program fact sheet (April 2026) — https://www.fincen.gov/system/files/2026-04/RRPFactSheet.pdf [verify 2026-10-30]
- US Treasury OFAC SDN list — https://sanctionssearch.ofac.treas.gov/
- NCSC (UK) — https://www.ncsc.gov.uk
- Report Fraud (UK; formerly Action Fraud) — https://www.reportfraud.police.uk [verify 2026-10-29]
- Europol European Cybercrime Centre (EC3) — https://www.europol.europa.eu/about-europol/european-cybercrime-centre-ec3
- Australian Cyber Security Centre (ACSC) — https://www.cyber.gov.au [verify 2026-10-30]
- Canadian Anti-Fraud Centre — https://www.antifraudcentre-centreantifraude.ca [verify 2026-10-30]

**Banking and payments standards:**
- SWIFT — https://www.swift.com
- SWIFT GPI — https://www.swift.com/our-solutions/swift-gpi
- European Payments Council — https://www.europeanpaymentscouncil.eu (SEPA / SCT / SCT Inst rulebooks)
- Nacha Operating Rules — https://www.nacha.org/newrules [verify 2026-10-30]
- Federal Reserve — Fedwire / FedNow — https://www.frbservices.org [verify 2026-10-30]

**Mail-authentication tooling and corpora:**
- parsedmarc — https://github.com/domainaware/parsedmarc [verify 2026-10-30]
- dnstwist — https://github.com/elceef/dnstwist
- urlcrazy — https://github.com/urbanadventurer/urlcrazy
- urlinsane — https://github.com/rangertaha/urlinsane
- crt.sh — https://crt.sh
- Censys — https://censys.com
- DKIMpy — https://launchpad.net/dkimpy [verify 2026-10-30]
- OpenDKIM — https://github.com/trusteddomainproject/OpenDKIM [verify 2026-10-30]
- pyspf — https://launchpad.net/pyspf [verify 2026-10-30]
- OpenARC (maintained fork; upstream trusteddomainproject/OpenARC last pushed 2024-04) — https://github.com/flowerysong/OpenARC [verify 2026-10-30]
- DMARC.org — https://dmarc.org

**Phishing-kit / threat-intel:**
- PhishTank — https://phishtank.org
- OpenPhish — https://openphish.com
- URLScan.io — https://urlscan.io
- MITRE ATT&CK — Initial Access (Phishing T1566) — https://attack.mitre.org/techniques/T1566/
- MITRE ATT&CK — T1566.002 Spearphishing Link — https://attack.mitre.org/techniques/T1566/002/
- MITRE ATT&CK — T1534 Internal Spearphishing — https://attack.mitre.org/techniques/T1534/
- Cofense — https://cofense.com [verify 2026-10-30]
- Akamai Security Research blog — https://www.akamai.com/blog/security-research [verify 2026-10-30]
- Google Threat Intelligence Group (GTIG) — https://cloud.google.com/blog/topics/threat-intelligence (the old TAG blog URL redirects to https://blog.google/security/) [verify 2026-10-30]
- Microsoft Threat Intelligence — https://www.microsoft.com/security/blog/topic/threat-intelligence/ [verify 2026-10-30]
- Volexity — https://www.volexity.com/blog/ [verify 2026-10-30]
- Proofpoint Threat Insight — https://www.proofpoint.com/us/blog/threat-insight [verify 2026-10-30]
- LevelBlue SpiderLabs blog (the Trustwave SpiderLabs URL redirects here) — https://www.levelblue.com/blogs/spiderlabs-blog [verify 2026-10-30]

**Reporting catalogues and case studies:**
- FBI IC3 Annual Internet Crime Report — annual — https://www.ic3.gov/AnnualReport/Reports [verify 2026-10-30]
- Verizon DBIR — annual incident analysis (BEC / phishing breakouts each year) — https://www.verizon.com/business/resources/reports/dbir/
- Anti-Phishing Working Group (APWG) Phishing Activity Trends Report — https://apwg.org [verify 2026-10-30]
- Microsoft Digital Defense Report — annual — https://www.microsoft.com/en-us/corporate-responsibility/topics/cybersecurity/reports/microsoft-digital-defense-report/ [verify 2026-10-30]

**Training and certification:**
- SANS FOR509 — Enterprise Cloud Forensics and Incident Response (covers M365 / Workspace / SaaS surfaces relevant to BEC) [verify 2026-10-30]
- SANS FOR578 — Cyber Threat Intelligence
- SANS SEC504 — Hacker Tools, Techniques, and Incident Handling
- M3AAWG (Messaging, Malware and Mobile Anti-Abuse Working Group) — https://www.m3aawg.org [verify 2026-10-30]
- ISC2 CCSP / CISSP — for broader IR / governance competence
- Microsoft — SC-200 (Security Operations Analyst Associate); SC-400 retired 2025-05-30 [verify 2026-10-30]

---

**Version:** 1.0
**Last Updated:** 2026-10-30
**Review Frequency:** Quarterly (BEC TTPs, AiTM kit landscape, lookalike-domain registrar patterns, M365 / Workspace / SEG message-trace API field renames, and IC3 / FFKC guidance evolve on a quarterly cadence; RFC-level SPF / DKIM / DMARC / ARC fundamentals and chain-of-custody discipline are slower)
