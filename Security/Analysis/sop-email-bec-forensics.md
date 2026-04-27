---
type: sop
title: Email & BEC Forensics SOP
description: "Scenario-centric Business Email Compromise forensics: email header forensics (Received-chain reconstruction, Authentication-Results parsing), SPF / DKIM / DMARC / ARC mechanics, lookalike-domain and brand-impersonation detection (IDN homograph, typosquatting, dnstwist patterns, CT-log monitoring), Microsoft 365 Get-MessageTrace and Google Workspace Email Log Search, secure-email-gateway forensics (Mimecast / Proofpoint / Barracuda envelope-vs-header), phishing-kit static analysis (defensive — kit acquisition, telltale strings, AiTM detection), wire-recall pathway (SWIFT MT103 / Fedwire / SEPA recall mechanics, Financial Fraud Kill Chain, FBI IC3 reporting, FinCEN SAR triggers, beneficiary-bank coordination), and BEC scenario taxonomy (CEO fraud, vendor-invoice fraud, payroll-redirect, attorney-impersonation, real-estate / closing-funds, gift-card scam)."
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
updated: 2026-04-27
template_version: 2026-04-27
---

# Email & BEC Forensics SOP

> **Authorized environments only.** Email and Business Email Compromise (BEC) forensics is a defensive discipline. This SOP covers post-incident reconstruction of email-vector incidents on tenants, mailboxes, and domains the investigator is authorized to access — incident-response retainer scope, internal SOC / DFIR work on infrastructure the team owns, regulator-directed examinations under appropriate authority, or law-enforcement collection backed by warrant / MLAT / preservation letter. It does **not** authorize unauthorized mailbox access, header-forging tradecraft, phishing-delivery methodology, or pivots into adversary infrastructure observed during the investigation. Phishing-kit *analysis* (acquisition, decomposition, IOC extraction) is in scope as defensive forensics; phishing-kit *delivery* (operating the kit against targets) is not. Cross-references: [[sop-legal-ethics|Legal & Ethics]] for jurisdictional framing, breach-notification clocks, and wire-fraud-statute interaction; [[sop-opsec-plan|OPSEC]] for investigator account and infrastructure hygiene during an active BEC incident; [[sop-forensics-investigation|Digital Forensics Investigation]] as the parent template for host / disk / memory parsing of derived artifacts (PST exports, header dumps, recovered phishing-kit archives); [[../../Investigations/Techniques/sop-collection-log|Collection Log]] for chain-of-custody discipline on every header export, eDiscovery package, and gateway-log pull; [[sop-saas-log-forensics|SaaS Log Forensics]] (sibling — SaaS-tenant identity / collaboration plane) for the mailbox-side of any BEC incident that pivots through an OAuth-consent grant or a credential-phishing → mailbox-rule pattern; [[sop-cloud-forensics|Cloud Forensics]] (sibling — IaaS plane) for cases where exfiltrated credentials lead to cloud-resource action; [[sop-malware-analysis|Malware Analysis]] (template parent for attachment / phishing-kit deep RE handoff); and [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] for fiat-banking pivots, Suspicious Activity Report (SAR) triggers, and Ultimate Beneficial Ownership (UBO) work downstream of wire fraud.

## Table of Contents

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
- **Lookalike-domain detection** — IDN homograph (Punycode `xn--` representation, mixed-script, confusable-Unicode TR39), typosquatting (Levenshtein distance, keyboard-adjacency, character-substitution / -insertion / -deletion / -transposition), brand-confusable Unicode, registered-domain monitoring (Certificate Transparency log monitoring, dnstwist patterns, urlinsane, urlcrazy, DomainTools / Iris / RiskIQ / Group-IB visibility), TLD-substitution patterns (`.com` → `.co` / `.cm` / `.com.<cctld>`).
- **M365 / Workspace message tracing** — `Get-MessageTrace` / `Get-MessageTraceDetail` (last 10 days online, 90 days via historical search) and `Get-MessageTraceV2` migration timeline, `Search-MessageTrackingLog` (on-prem Exchange), Workspace **Email Log Search** (Admin console → Reporting → Email Log Search), Gmail BigQuery export message-level event surface, mailbox-side context cross-link to [[sop-saas-log-forensics|SaaS Log Forensics]] for inbox-rule and mailbox-audit forensics.
- **Secure-email-gateway forensics** — Mimecast Audits / Hold-Queue / Tracker, Proofpoint Smart Search / Threat Insight, Microsoft Defender for Office 365 Threat Explorer, Cisco Secure Email (formerly Ironport ESA) message tracking, Barracuda Email Security Gateway / ESS message logs, Sophos Email Appliance message search, recipient-side envelope-vs-header forensics.
- **Phishing-kit analysis (defensive)** — kit acquisition (open directory, archive download, takedown-coordinated copy), static analysis hooks (PHP / JavaScript / Python kit decomposition, hand-off to [[sop-malware-analysis|Malware Analysis]] for deeper RE), telltale strings (kit-author signatures, hardcoded exfil endpoints, anti-analyst checks), evilginx / modlishka / muraena adversary-in-the-middle (AiTM) detection signatures, infrastructure indicators (Cloudflare Tunnel, ngrok, serverless-host abuse, residential-proxy egress).
- **Wire-recall pathway** — SWIFT MT103 / Fedwire / SEPA / FedNow / SWIFT GPI recall mechanics, FBI IC3 reporting workflow and Financial Fraud Kill Chain (FFKC), FinCEN SAR-filing triggers, FinCEN Rapid Response Program coordination, beneficiary-bank coordination, correspondent-banking layer (cross-link to [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — do not duplicate banking-pivot tradecraft), 24-hour / 48-hour / 72-hour recovery windows.
- **BEC scenario taxonomy** — CEO-fraud / wire-fraud, vendor-invoice fraud (VIF), payroll-redirect, attorney-impersonation, real-estate / closing-funds fraud, gift-card scam, account-compromise lateral, and the cryptocurrency-payout BEC variant (where the scenario reconstruction lives here; on-chain trace hands off to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]).
- **BEC monetary-recovery timeline** — 24h / 48h / 72h windows, wire-recall vs ACH-recall vs check-recall mechanics, fraud-claim-to-bank, IC3 within 72 hours of the wire, insurance-carrier notification, and the policy-coverage interaction with social-engineering vs computer-fraud riders.

### Hard exclusions (out of scope)

- **IaaS / cloud-provider control plane.** AWS CloudTrail, Azure Activity Log + Resource Logs, GCP Cloud Audit Logs, IAM forensics on cloud resources, container / Kubernetes runtime, and snapshot preservation all live in [[sop-cloud-forensics|Cloud Forensics]]. When a BEC pivots into stolen cloud credentials and the attacker acts on cloud resources, the email side stays here; the cloud-resource action routes to [[sop-cloud-forensics|Cloud Forensics]].
- **SaaS-tenant identity / collaboration audit (the mailbox-compromise side of a BEC).** Microsoft 365 Unified Audit Log, mailbox audit log (`Search-MailboxAuditLog`), inbox-rule forensics (`Get-InboxRule`, UAL `New-InboxRule` / `Set-InboxRule` / `Remove-InboxRule`), OAuth-app token-persistence forensics, `oauth2PermissionGrants` enumeration, Workspace Admin SDK Reports API, Okta System Log, Slack Audit Logs, Salesforce Setup Audit Trail, GitHub audit and the cross-tenant collaboration surface all live in [[sop-saas-log-forensics|SaaS Log Forensics]]. **Per the buildout-plan scope contract for the forensics trio: the OAuth-consent BEC variant lives in #8.** This SOP references the carve-in but does not duplicate the §10 OAuth Consent-Grant Abuse Forensics methodology; when the BEC pattern is "attacker tricks user into granting an OAuth app permission to read mailbox," that is #8's surface. The header-spoofing BEC, lookalike-domain BEC, and pure-social-engineering BEC variants live here.
- **Mailbox-rule / mailbox-audit forensics.** When the BEC pivots into mailbox compromise (credential phishing → adversary-in-the-middle session-token capture → mailbox-rule auto-forward → wire diversion), the mailbox-side reconstruction is owned by [[sop-saas-log-forensics|SaaS Log Forensics]] §4.5–§4.6. This SOP covers what the inbound and outbound *messages* looked like; the mailbox-audit log of who-accessed-what is #8's surface.
- **General malware analysis of attachments.** When a BEC incident includes a malicious attachment (Office macro dropper, ISO / IMG container, HTA, LNK, OneNote with embedded payload), this SOP covers the email-as-vector framing — header pivot, gateway disposition, recipient-side delivery — and hands off the binary / document analysis itself to [[sop-malware-analysis|Malware Analysis]] §3 (Rapid Triage), §4 (Behavior), §6.2 (Office / Macro), §6.3 (PDF), §6.4 (Script Analysis), §6.5 (Archive), §6.7 (HTA), §6.8 (Disk Image / ISO). Phishing-kit *analysis* is in scope here per §12 below; deep static / dynamic RE of harvested kits routes to [[sop-malware-analysis|Malware Analysis]] / [[sop-reverse-engineering|Reverse Engineering]].
- **Smart-contract / on-chain forensics.** When a BEC payout is in BTC / USDT / USDC / ETH or another on-chain rail (the cryptocurrency-payout BEC variant is increasingly common), the scenario reconstruction (which message, which lookalike domain, which payout instruction, which wallet address surfaced in the message body) lives here; the on-chain trace once funds are deposited routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]. Mixer / privacy-pool laundering downstream routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]. Smart-contract code review (when the payout funnels through a contract) routes to [[sop-smart-contract-audit|Smart Contract Audit]].
- **Fiat AML / SAR-filing / banking-pivot tradecraft.** [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] is the canonical SOP for SAR-filing decision criteria, the structuring / smurfing / shell-company / UBO investigative patterns, and the broader correspondent-banking / SWIFT-network tradecraft. This SOP covers wire-recall *operations* (the mechanics of getting money back; the IC3 / FFKC / SWIFT GPI Stop and Recall path) and routes the *intelligence* / *typology* / *AML-analyst* layer to [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]].
- **General host / disk / memory forensics.** Disk imaging, memory acquisition, MFT / USN / Prefetch / Amcache / ShimCache / registry-hive parsing, Volatility 3, and timeline construction live in [[sop-forensics-investigation|Digital Forensics Investigation]] (parent template). When a BEC investigation produces a recovered laptop (a victim user device, an authorized seizure of an adversary endpoint, a phishing-kit operator's host), the host-forensics side routes to the parent template; this SOP terminates at "the email and the financial pathway."
- **Offensive phishing / red-team email tradecraft.** Pre-engagement target enumeration, payload crafting, lure design, evasion of secure-email-gateways, sender-reputation warm-up, and click-rate / credential-harvest operations are red-team / social-engineering disciplines. Currently no Intel Codex SOP owns offensive phishing — it remains a `CLAUDE.md` "Gaps" candidate. Forensic readers benefit from understanding the offensive playbook as the threat model but should not derive offensive instructions from this SOP. Phishing-kit *analysis* (decomposing a recovered kit defensively) is explicitly in scope; phishing-kit *operation* is not.
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
- [ ] **Provider legal process where the customer cannot authorize collection on their own.** For cross-tenant evidence (the attacker's tenant is on the same provider; the recipient organization is not the customer; the upstream MTA is a third-party SEG) the provider's law-enforcement portal is the route. Microsoft, Google, Mimecast, Proofpoint, Cloudflare, AWS SES, SendGrid, Mailgun, and most major SEGs publish LE-cooperation paths and require subpoena / warrant / MLAT / preservation letter depending on data type and jurisdiction [verify 2026-04-27].
- [ ] **Cross-border data residency review.** EU-data-subject mail content (GDPR), healthcare (HIPAA), card data (PCI), and government tenants all carry residency / sovereignty constraints. Verify under counsel before exporting message content to investigator storage outside the source region — see [[sop-legal-ethics|Legal & Ethics]] for Schrems II / DPF / SCCs framing.
- [ ] **Disclosure pathway agreed.** Notification clocks are jurisdiction- and sector-specific — GDPR Art. 33 (72h to supervisory authority), GDPR Art. 34 (high-risk-to-data-subject notice), HIPAA Breach Notification Rule (60-day), state breach-notification laws (US), SEC cyber-disclosure rule for material incidents at registrants, NYDFS Part 500, NIS2 (EU), DORA (EU financial). Wire fraud also triggers FinCEN SAR considerations for the customer's bank under the Bank Secrecy Act and 31 CFR 1020.320 [verify 2026-04-27]; the customer's financial institution has independent SAR obligations the investigation should not impede.
- [ ] **IC3 / FFKC pre-positioning.** When the engagement begins inside the 72-hour wire-recall window, the IC3 referral and Financial Fraud Kill Chain (FFKC) request are time-critical. Pre-engagement: the customer has the wire confirmation, the originating-bank fraud team, and beneficiary-bank details ready; the investigator coordinates the timeline rather than owning the customer's banking relationship. See §13 below.
- [ ] **Insurance-carrier notification.** Cyber and crime policies have notification clocks (often 24-72 hours from discovery, sometimes "immediate"); failure to notify can void coverage. Confirm carrier and policy before any state-changing action that might affect the claim — under counsel.
- [ ] **OAuth-app inventory baseline.** When the engagement involves any mailbox-compromise pivot (most non-trivial BEC), an OAuth-app inventory is established before any state-changing action — multi-tenant apps consented in the tenant, app-only permissions, refresh tokens active. Per [[sop-saas-log-forensics|SaaS Log Forensics]] §2, the baseline is: M365 `Get-MgServicePrincipal` / `Get-MgOauth2PermissionGrant`; Workspace App Access Control + connected-apps export; Salesforce Connected Apps Usage; GitHub org-level OAuth + PAT inventory.

### Lab Environment Requirements

- **Dedicated investigator tenant or analyst seat** in each SaaS / SEG surface, separate from the affected tenant. Header dumps, message exports, and analysis derivatives land here, never back into the affected tenant. The investigator's M365 / Workspace / Mimecast / Proofpoint identity is engagement-scoped, not their personal cloud identity.
- **Investigator workstation** disk-encrypted, isolated from production, no auto-sync of artifacts to corporate storage, dedicated browser profiles or container tabs per tenant. PowerShell 7+ for Exchange Online; `gcloud` + `gam7` for Workspace; `dnstwist`, `dnsx`, `mxtoolbox`-CLI-equivalents (`ldnstool`, `dig`), `swaks` for SMTP testing in a sandbox lane only (never against production with real targets), `email-deliverability` / `parsedmarc` for DMARC-report parsing.
- **Encrypted-at-rest investigator storage.** Exported message bodies and attachments may contain customer-confidential material, third-party PII, or LE-sensitive evidence; encrypted with engagement-specific keys; access-controlled.
- **Time-sync discipline.** All analysis systems running NTP / chrony to a known source; time-zone normalized to UTC end-to-end; investigator note timestamps use ISO 8601 / RFC 3339 with explicit `Z` suffix per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Email systems report event times with mixed precision and time-zone hints — Received-header `;` clauses use RFC 2822 date format with offset; Microsoft `MessageTrace` is UTC; Workspace Email Log Search exports UTC; Mimecast `received_date` is UTC; Proofpoint Smart Search is UTC; recipient mail-client display rendering localizes silently. Capture authoritative-source timestamps, not display-rendered ones.
- **API-throttling awareness.** Production tenants under stress will rate-limit aggressive forensic queries. Exchange Online `Get-MessageTrace` is paged; `Get-MessageTraceDetail` is per-message; the new Reporting API for message-trace has different throttle behavior [verify 2026-04-27]. Workspace Reports API has per-customer quotas. Mimecast, Proofpoint, and Defender have console-driven retrieval that masks API limits; bulk pulls require API tokens.
- **Read-only by default.** Investigator tokens / roles should not include sender-block, mailbox-rule disablement, message-purge (Defender Threat Explorer's "Soft Delete," "Move to Junk," "Move to Inbox," "Hard Delete" actions), or domain-take-down permissions unless explicitly authorized. The forensic record is more defensible when state-changing actions are gated behind a separate, narrowly-scoped account.

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
| **Payroll redirect** | Spoofed or compromised employee asks HR / payroll to update direct-deposit account | ACH to attacker-controlled account | `From:` spoofed or compromised employee; HR portal misuse downstream | ACH return / reversal; coordinate with bank within 5 banking days for unauthorized debit (Reg E) [verify 2026-04-27] |
| **Attorney impersonation** | Spoofed law firm or M&A counsel directs urgent confidential wire | Wire transfer; pretext invokes confidentiality to suppress verification | `From:` lookalike firm domain; legitimate-looking signature block; pressure to bypass verification policy | IC3 + bank; civil discovery subpoenas downstream |
| **Real-estate / closing-funds fraud** | Spoofed title agent or closing attorney redirects buyer's down-payment / closing funds | Wire transfer at closing | Lookalike title-agent domain; thread-hijack into legitimate closing chain; well-rehearsed timing | IC3 + bank; ALTA escrow procedures; FBI Real Estate Wire Fraud guidance |
| **Gift-card scam (BEC-adjacent)** | Spoofed executive directs urgent gift-card purchase for "client appreciation" / "team lunch" | Apple / Google Play / Amazon gift-card codes sent back | Free-mail `From:` or display-name spoof; mobile-text follow-up common | Generally unrecoverable; reporting to retailer fraud teams; pattern attribution |
| **Cryptocurrency-payout BEC** | Any of the above scenarios but payout is BTC / USDT / USDC / ETH to an attacker-controlled wallet | On-chain transfer | Same as base scenario; payment instruction includes wallet address (or QR code) | On-chain trace via [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; sanctions-screening overlay; recall is generally not feasible — focus on trace + freeze-at-CEX |

The scenarios overlap and chain. A vendor-invoice-fraud often follows a successful account-compromise of the vendor; a real-estate fraud often pairs lookalike-domain BEC against the buyer with thread-hijack against the title agent. The investigator names the *primary* scenario for the report's classification line and tracks chained patterns separately.

### 3.3 The Financial Fraud Kill Chain (FFKC)

The FBI IC3 Financial Fraud Kill Chain is a coordination mechanism that activates when the customer's fraudulent wire meets specific criteria — historically, the wire was **at least USD 50,000** and was transmitted via **SWIFT MT103 within the previous 72 hours** to a beneficiary outside the United States [verify 2026-04-27 — IC3-published threshold may have evolved, including FFKC expansion to FedNow / SEPA / domestic ACH where applicable; verify against current IC3 guidance before relying on the threshold or transit-network requirement]. The coordination invokes the FBI legal attaché in the destination jurisdiction, the foreign financial-intelligence unit (FIU), and the beneficiary bank. Recovery rates depend heavily on speed of activation.

The investigator does not own the FFKC request — that is the customer's bank, often coordinated through the customer's legal counsel and the FBI field office. The investigator's role is to *enable* the activation: produce the BEC reconstruction (the email; the lookalike domain; the social-engineering chain) that the FBI and the bank will reference, and produce the wire-confirmation cross-walk (the customer's wire reference, the SWIFT GPI Unique End-to-End Transaction Reference (UETR), the originating-bank reference, the beneficiary-bank reference, the beneficiary account / IBAN).

### 3.4 Monetary-Recovery Timeline

| Window from wire-send | What is feasible | Action |
|---|---|---|
| **0-4 hours** | Wire may still be in originating-bank or correspondent-bank queue | Customer's bank requests recall; SWIFT MT192 (Request for Cancellation) issued; FedNow has its own cancel path |
| **4-24 hours** | Wire is at beneficiary bank but funds may be unwithdrawn / on hold | Beneficiary bank receives recall; if funds untouched, freeze and return are the most likely outcome |
| **24-72 hours** | Funds typically dispersed onward to secondary accounts / ATM withdrawal / FX conversion | IC3 referral + FFKC activation (at the threshold); FBI legal attaché engages destination FIU; civil restraining order in destination jurisdiction may be possible |
| **72h - 30 days** | Funds gone; investigation pivots to civil action and AML / SAR-driven typology trace | Civil discovery; SAR-driven correlation; partial recovery via destination-bank cooperation possible |
| **>30 days** | Recovery is uncommon | Insurance claim; tax loss; LE referral pursued primarily for prosecution / disruption |

ACH recall is shorter and more rigid than wire — the originating financial institution can return an unauthorized debit within 60 days under Reg E, but only if the consumer disputes; for B2B ACH the window is much shorter, generally 24 hours [verify 2026-04-27]. Check fraud has its own UCC-3 and UCC-4 framework. Cryptocurrency payouts are not recallable; the equivalent recovery operation is *seizure-at-CEX* via the destination centralized exchange's compliance team, downstream of the on-chain trace per [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]].

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
3. **Geo-cross-walk source IPs** — `whois`, `mtr`, `bgp.he.net`, `peeringdb.com`, MaxMind, IPinfo, RIPE NCC, ARIN, LACNIC, AFRINIC, APNIC. Residential-proxy ASNs (Luminati / Bright Data, Smartproxy, Oxylabs, NetNut, IPRoyal — verify current vendor names [verify 2026-04-27]), bulk-mailer ASNs (SendGrid AS11377, Mailgun AS31034, Mailchimp AS22214, Amazon SES AS16509, etc. [verify 2026-04-27]), and commodity-host ASNs (Hetzner AS24940, OVH AS16276, DigitalOcean AS14061, Vultr AS20473, Contabo AS51167 — verify) are pattern signals; not every sender from these ASNs is malicious, but BEC operators concentrate there.
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
- **`dmarc=`** — `pass` / `fail` / `bestguesspass` (some receivers) / `none`. The `action=` records the DMARC policy applied (`none` / `quarantine` / `reject`); `header.from=` records the `From`-domain DMARC was evaluated for.
- **`compauth=`** — Microsoft's composite authentication result; `pass` / `softpass` / `fail` / `none`; `reason=` carries the numeric code (100=pass, 1nn=quarantined, 2nn=quarantined, 3nn=blocked). [verify 2026-04-27 — Microsoft's `compauth` reason-code table evolves]
- **`arc=`** — when ARC-aware MTAs participated; `pass` / `fail` / `none` records the ARC chain validation.

### 4.4 Microsoft 365 `X-` Headers Cheat-Sheet

Microsoft 365 / Exchange Online Protection adds a family of `X-MS-` and `X-Microsoft-` headers carrying transport-rule, anti-spam, and anti-phish disposition.

| Header | Forensic value |
|---|---|
| `X-Forefront-Antispam-Report` | `CIP=` source IP, `CTRY=` country, `LANG=` body language, `SCL=` spam confidence (1-9), `SFV=` spam filter verdict (`SPM`, `BLK`, `SKQ`, `NSPM`, `SKB`, `SKI`, `SKN`, `SKS`, `SFE` — verify 2026-04-27 against current EOP documentation), `IPV=` IP-reputation verdict, `H=`/`HELO=` HELO string, `PTR=` reverse-DNS |
| `X-Microsoft-Antispam` | `BCL=` bulk-confidence level, `PCL=` phishing-confidence level, additional verdict codes |
| `X-Microsoft-Antispam-Mailbox-Delivery` | Per-mailbox delivery decision; junk-folder routing |
| `X-MS-Exchange-Organization-AuthAs` | `Anonymous` / `Internal` / `Partner` — tells you whether the message was treated as inbound, intra-org, or partner |
| `X-MS-Exchange-Organization-AuthSource` | The receiving server identity |
| `X-MS-Exchange-Organization-MessageDirectionality` | `Originating` (outbound) vs `Incoming` (inbound) |
| `X-MS-Exchange-Organization-Network-Message-Id` | The Microsoft NetworkMessageId — this is the cross-walk key into Defender Threat Explorer and Get-MessageTrace |

Workspace adds `X-Google-Smtp-Source`, `X-Received` (Google variant), and Gmail-specific `X-Gm-Message-State` / `X-Gm-Spam` / `X-Gm-Phishy` indicators in some surfaces. SEG vendors layer their own — Mimecast adds `X-Mimecast-`-prefixed fields, Proofpoint adds `X-Proofpoint-`-prefixed, Barracuda adds `X-Barracuda-`-prefixed; treat each as an additional disposition data-point but evaluate the trusted `Authentication-Results:` first.

### 4.5 IP-Geolocation Cross-Walk

For each candidate origin IP from the bottom-most `Received:`:

```bash
# whois (RIR-authoritative)
whois 198.51.100.10

# Reverse DNS
dig -x 198.51.100.10 +short

# BGP / ASN — bgp.he.net is convenient; CLI alternatives:
whois -h whois.cymru.com " -v 198.51.100.10"

# Commercial geolocation (require API keys)
curl -s "https://ipinfo.io/198.51.100.10?token=$IPINFO_TOKEN" | jq
curl -s "https://api.maxmind.com/geoip/v2.1/insights/198.51.100.10" \
  -u "$MAXMIND_USER:$MAXMIND_LICENSE" | jq
```

Geolocation is approximate and is most reliable at the **country / ASN** level; sub-country-level inference is brittle and should not be presented as definitive. Residential proxies, VPNs, and Tor exit nodes will geolocate to consumer ISPs and present low-signal location data. The forensic value is the *combination* (ASN + country + reverse-DNS pattern + WHOIS abuse contact + observed mail-flow pattern) rather than any single field.

### 4.6 BIMI / VMC

Brand Indicators for Message Identification (BIMI, RFC 9690 [verify 2026-04-27]) lets a brand publish a logo at `default._bimi.<domain>` whose display in the recipient mail client is conditioned on DMARC-pass with `p=quarantine` or `p=reject` and (for major implementers Gmail and Apple Mail) a Verified Mark Certificate (VMC) issued by an Authorized Mark Authority (AMA). Forensic uses:

- **Sender-side** — the existence of a published BIMI record and a valid VMC indicates a brand that has invested in mail-authentication and is unlikely to be the legitimate sender of an SPF-fail / DKIM-fail message; an alleged-sender brand whose BIMI is *not* configured can still be impersonated.
- **Recipient-side** — when the recipient client renders a brand logo, the message was DMARC-aligned and the logo was VMC-validated (Gmail / Apple Mail) at the time of rendering. This is provenance evidence; capture the logo and the BIMI / VMC records at investigation time, since they can change.

```bash
# Inspect a domain's BIMI record
dig default._bimi.example.com TXT +short
# Returns the `v=BIMI1; l=https://...; a=https://...` record

# Fetch the VMC (PEM-encoded X.509)
curl -sL https://example.com/vmc.pem | openssl x509 -text -noout
```

### 4.7 Header-Capture Discipline

- **Capture `.eml` / RFC 822 source, never rendered HTML.** Outlook desktop "Save As" → `.msg` is acceptable but proprietary; export to `.eml` from Outlook on the web (Forward → Three-dot menu → View → View message source → Save) or via `Get-MessageTrace` / Graph API for archival. Workspace: **Show Original** in Gmail UI, then **Download Original**.
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
| `include:<domain>` | Recursively expand `<domain>`'s SPF; pass / fail / temperror cascades; counts toward 10-DNS-lookup limit |
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
| `Fail` | Sender IP matched a `-` mechanism (typically `-all`) | Domain owner explicitly rejects this sender; receiver SHOULD reject |
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
# spfcheck.py / pyspf
python3 -c "import spf; print(spf.check2(i='198.51.100.10', s='user@example.com', h='mta.example.com'))"

# CLI tools
spf-tools-perl spfquery -ip 198.51.100.10 -sender user@example.com -helo mta.example.com

# 10-lookup-limit check
# https://github.com/jsumners/spf-record (or similar) — verify 2026-04-27
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
- **`a=`** — algorithm: `rsa-sha256` (most common), `rsa-sha1` (deprecated, RFC 8301), `ed25519-sha256` (RFC 8463 — verify deployment maturity 2026-04-27).
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

Selector rotation is a defensive practice; an absent selector under a domain that recently sent DKIM-signed mail under it is normal (key was rotated and old selector retired). For forensics, capture the selector record at investigation time *and* attempt historical resolution via passive DNS (DomainTools, SecurityTrails, RiskIQ — verify 2026-04-27) when the message is older than the current selector deployment.

### 6.3 Key Strength

| Key length | RFC 8301 / current guidance | Forensic interpretation |
|---|---|---|
| RSA-512 / 768 / 1024 | Insecure; RFC 8301 deprecates RSA-1024 | Domain has weak DKIM; signatures may be forgeable by capable attackers |
| RSA-2048 | Current minimum baseline | Standard posture |
| RSA-4096 | Hardened | Secure but expensive |
| Ed25519 | RFC 8463 — modern | Adoption is mixed; receiver support varies [verify 2026-04-27] |

A signing-domain that uses RSA-1024 is forensically interesting — sophisticated attackers are documented in academic literature [verify 2026-04-27] to have factored 1024-bit RSA DKIM keys; though the practical-attack threshold is contested, the posture itself signals immature mail-auth.

### 6.4 Multi-Signature Messages

A message can carry multiple `DKIM-Signature:` headers — typical for messages that traverse a forwarder that re-signs (Microsoft 365 transport rules; some mailing lists). The `Authentication-Results:` will list each `dkim=` outcome separately. For DMARC alignment (§7), at least one DKIM signature where `header.d=` aligns with the `From`-domain (per the alignment mode) must pass.

### 6.5 The `l=` Length-Tag Attack Surface

If the `DKIM-Signature:` includes `l=N`, only the first `N` bytes of the body are included in the hash. An attacker who modifies (or *appends*) bytes after position `N` does not invalidate the signature. The threat is a *signature replay* / *content-injection* pattern: take a legitimately signed message (e.g., a benign newsletter) with `l=N`, replace the body content beyond byte `N` with attacker content, and the resulting message still passes DKIM verification at the recipient.

Forensic indicator: any `DKIM-Signature:` carrying `l=` is suspect; mail-flow vendors who emit `l=` should be flagged as a posture issue. Most modern senders do not emit `l=`; presence of `l=` in 2026-era messages typically indicates legacy MTA configuration or a deliberate attacker pattern. Microsoft has documented `l=` exploitation patterns (`l=`-stripping abuse) and Gmail's behavior toward `l=` has shifted [verify 2026-04-27 — check Microsoft / Google current guidance].

### 6.6 Body Modification Detection

When `Authentication-Results:` reports `dkim=fail (body hash mismatch)`, the body was modified between signing and reception. Common legitimate causes: mailing-list footers; antivirus / disclaimer injection by the recipient SEG; `Content-Transfer-Encoding` re-coding by an intermediate. ARC (§8) was designed to preserve auth-state across known modifying intermediaries.

When `dkim=fail (signature verification failure)` and the `bh=` matches but `b=` does not, the *headers* were modified post-signature — specifically, one of the headers in the `h=` list. This is a stronger spoof signal.

### 6.7 DKIM Investigation Commands

```bash
# Manual verification (Python with dkimpy)
python3 -c "import dkim; print(dkim.verify(open('msg.eml','rb').read()))"

# CLI tools
opendkim-testmsg < msg.eml
# Or:
dkim-verify msg.eml

# Inspect a signed message's signing parameters
grep -i "DKIM-Signature\|Authentication-Results" msg.eml
```

---

## 7. DMARC Forensics & Reporting Infrastructure

### 7.1 DMARC Record Anatomy

DMARC (RFC 7489) is a TXT record published at `_dmarc.<domain>` declaring policy and reporting addresses for mail that fails alignment.

```
_dmarc.example.com.  TXT  "v=DMARC1; p=quarantine; rua=mailto:dmarc-rua@example.com;
                          ruf=mailto:dmarc-ruf@example.com; pct=100;
                          adkim=r; aspf=r; sp=reject; fo=1"
```

Tags:

- **`v=`** — version (always `DMARC1`).
- **`p=`** — policy: `none` (monitor), `quarantine` (junk-folder), `reject` (do not deliver).
- **`sp=`** — sub-domain policy (defaults to `p=` if absent). Many domains publish `p=quarantine; sp=reject` to lock down sub-domains while keeping primary-domain policy lenient.
- **`pct=`** — percentage of failing messages to which the policy applies; rollout dial (1-100). `pct=10` means 10% of failing mail is quarantined / rejected, 90% is delivered normally.
- **`adkim=`** — DKIM alignment mode: `r` (relaxed — `header.d=` is `example.com` or any sub-domain) or `s` (strict — exact match).
- **`aspf=`** — SPF alignment mode: `r` (relaxed — envelope `MAIL FROM` domain is `example.com` or any sub-domain) or `s` (strict — exact match).
- **`rua=`** — aggregate-report destination(s); comma-separated `mailto:` URIs; report cadence is daily.
- **`ruf=`** — forensic-report (failure-report) destination(s); per-message reports; not all senders honor `ruf` due to PII concerns.
- **`fo=`** — failure-reporting options: `0` (default — generate report only if both SPF and DKIM fail to produce a DMARC-pass), `1` (any auth failure), `d` (DKIM failure regardless of alignment), `s` (SPF failure regardless of alignment).
- **`rf=`** — report format (`afrf` is the only widely-supported value).
- **`ri=`** — aggregate-report interval in seconds (default 86400 = daily).

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
| No | No | Fail (subject to `pct=`, `fo=`, `p=`) |

When both fail, the receiver applies `p=` modulated by `pct=` and emits aggregate / forensic reports per `rua=` / `ruf=` / `fo=`.

### 7.4 Aggregate (`rua`) Report Parsing

Aggregate reports are XML files (RFC 7489 Appendix C) attached to daily mail to the `rua=` address. Each report covers one reporter (one receiver organization, one policy domain, one day), summarizing per-source-IP counts of disposition decisions.

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
      <dkim><domain>example.com</domain><result>fail</result></dkim>
      <spf><domain>spoofable.com</domain><result>pass</result></spf>
    </auth_results>
  </record>
</feedback>
```

Forensic uses:

- **Lookalike-sender discovery** — source IPs in aggregate reports against `example.com` that the customer did *not* contract are candidate spoofers; cross-walk against ASN, country, and historical report appearance.
- **Mail-flow anomaly detection** — sudden spike in `count` for a known-bad source IP; appearance of a previously-unseen IP at high volume.
- **Authentication-posture validation** — inventory of all aligned vs unaligned senders; gaps between intended and observed posture.

### 7.5 Forensic (`ruf`) Reports

Per-message failure reports (RFC 6591 ARF format). They include redacted message headers and (sometimes) body excerpts. Privacy concerns mean many large receivers (Gmail, Microsoft) do not honor `ruf=` at scale or honor it only for opted-in domains [verify 2026-04-27]. When available, `ruf` reports give per-message visibility — invaluable for active-incident hunting but not a reliable steady-state stream.

### 7.6 DMARC Reporting Infrastructure

Customers consume `rua` / `ruf` reports through:

| Approach | Notes |
|---|---|
| **In-house parser** | `parsedmarc` (https://github.com/domainaware/parsedmarc) is the canonical open-source parser; ingests via IMAP / S3 / file; outputs Elasticsearch / Splunk / S3 / SQL [verify 2026-04-27] |
| **dmarcian** | Commercial DMARC analytics platform (https://dmarcian.com) |
| **Valimail** | Commercial DMARC + sender-identity platform |
| **Postmark DMARC** | Free DMARC-monitoring service (Wildbit / ActiveCampaign) |
| **MXToolbox** | Commercial DMARC monitoring |
| **Cloudflare DMARC Management** | Cloudflare-hosted aggregation for Cloudflare-DNS customers |
| **EasyDMARC** | Commercial DMARC platform |
| **OnDMARC (Red Sift)** | Commercial DMARC platform |
| **Agari Brand Protection** | Enterprise DMARC + brand-impersonation platform (acquired by Fortra) [verify 2026-04-27] |
| **Microsoft DMARC reporting** | Microsoft published DMARC aggregate-report receiver capability for tenants [verify 2026-04-27] |

For active BEC investigations, the customer's existing aggregate-report archive — even if previously unparsed — is the highest-value historical lookalike-sender corpus.

### 7.7 DMARC Investigation Commands

```bash
# Resolve DMARC record
dig _dmarc.example.com TXT +short

# Subdomain DMARC (organizational-domain inheritance)
dig _dmarc.sub.example.com TXT +short

# Bulk DMARC check across customer-owned domains (psl-aware)
# Use a scripted approach with dnspython + publicsuffix2

# Aggregate-report parser (parsedmarc)
parsedmarc --imap-host imap.example.com --imap-user dmarc-rua --imap-pass "$PW" \
           --output ./rua-output

# Inspect a single XML report
unzip -p report.xml.zip | xmllint --format -
```

---

## 8. ARC Forensics

### 8.1 Why ARC Exists

DMARC is brittle across **indirect mail flows** — mailing lists, vacation auto-forwards, Microsoft 365 transport-rule rewriting — because intermediates legitimately modify messages (add `[list]` to `Subject:`, append disclaimer footers, rewrite `From:` to a list address). These modifications break DKIM body-hash; SPF alignment is already broken because the relay is the new envelope sender. Without ARC, a forwarded legitimate message arrives at the final recipient with DMARC=fail.

ARC (Authenticated Received Chain, RFC 8617) lets each cooperating intermediate add a sealed record of *what authentication looked like when I received this*, plus a re-signature of the message *as I forwarded it*. The final recipient validates the chain and can choose to honor the auth-result the chain attests was true at origin even if direct DMARC fails.

### 8.2 ARC Headers

Three headers per ARC instance (numbered `i=1`, `i=2`, ...):

- **`ARC-Authentication-Results`** — what this hop saw at receive time (mirrors `Authentication-Results:` syntax).
- **`ARC-Message-Signature`** — DKIM-style signature over the message (headers + body) at this hop.
- **`ARC-Seal`** — signature over the prior ARC headers, anchoring the chain.

ARC instance numbering: `i=1` is the first ARC-aware MTA; subsequent hops increment. The receiver validates that each `ARC-Seal` correctly seals the prior `i-1` chain and that `ARC-Message-Signature` validates against the message-as-forwarded.

### 8.3 ARC Validation

```bash
# Python tooling (dkimpy supports ARC)
python3 -c "import authres, dkim; print(dkim.arc_verify(open('msg.eml','rb').read()))"

# OpenARC (https://github.com/trusteddomainproject/OpenARC) — verify 2026-04-27
openarc-tool < msg.eml
```

Trusted ARC-sealer list is the recipient policy decision: which ARC sealers does the recipient trust to attest to origin-time authentication? Major mailbox providers (Gmail, Microsoft 365, Yahoo, AOL — verify 2026-04-27) operate ARC sealers; smaller intermediates may or may not. A broken or absent ARC chain on a forwarded message is a routine forensic signal — it does not necessarily mean spoofing, but it limits the receiver's ability to override a direct-DMARC fail.

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
| IDN homograph (Punycode `xn--`) | `xn--exmple-cua.com` displays in IDN-aware UIs as `exаmple.com` (Cyrillic `а`) |
| Mixed-script | Combinations of Latin + Cyrillic + Greek visually identical; Unicode TR39 confusables |
| Brand-confusable (legitimate-domain-near) | `examplecorp.com` against `example-corp.com` |

### 9.2 IDN Homograph Forensics

Internationalized Domain Names encode non-ASCII characters as Punycode (RFC 3492) prefixed with `xn--`. Browsers and mail clients render the Unicode form unless safety heuristics (mixed-script, non-allowed-scripts) downgrade to Punycode. Modern browser policies (Chromium, Firefox) downgrade to Punycode display when the label contains characters outside the user's configured-scripts plus Latin, mitigating the worst homograph cases — but mail clients are inconsistent [verify 2026-04-27 — check current policy state].

```bash
# Decode IDN
python3 -c "print('xn--exmple-cua.com'.encode().decode('idna'))"

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

# Include WHOIS, banner, and SSL-cert grabbing
dnstwist --registered --whois --banners --ssdeep example.com

# Scan against multiple base domains
for d in example.com example.org example.net; do
  dnstwist --registered --format json "$d" > "squat-$d.json"
done
```

`urlcrazy` (https://github.com/urbanadventurer/urlcrazy) and `urlinsane` (https://github.com/rangertaha/urlinsane) are alternative generators with overlapping but not identical algorithm coverage.

### 9.4 Certificate Transparency Log Monitoring

CT logs (RFC 6962) record every TLS certificate issued by a participating CA. Monitoring CT for issuance against your brand surface catches squatters at certificate-issuance time, often before mail-sending. crt.sh, Censys, Cloudflare Merkle Town, Google's CT portal, Facebook's CT monitoring, and SecurityTrails all provide query APIs [verify 2026-04-27].

```bash
# crt.sh JSON API (free)
curl -s "https://crt.sh/?q=%25example%25&output=json" | jq '.[] | .name_value' | sort -u

# Censys (commercial)
censys search "parsed.subject.common_name: *example*"

# Continuous CT monitoring — cron / scheduled job; diff against day-prior set
```

Brand-protection platforms (DomainTools Iris, Group-IB Digital Risk Protection, RiskIQ Digital Footprint / Microsoft Defender External Attack Surface Management, ZeroFox, BrandShield, Mandiant Digital Threat Monitoring — verify 2026-04-27) provide aggregated CT + WHOIS + DNS + content monitoring.

### 9.5 Registrar / Hosting-Provider Forensics

For each suspect lookalike domain:

```bash
# WHOIS
whois lookalike.example.com

# Historical WHOIS (commercial)
# DomainTools Iris: https://iris.domaintools.com/
# WhoisXMLAPI: https://www.whoisxmlapi.com/whois-history-api
# verify 2026-04-27

# DNS records (current)
dig lookalike.example.com ANY +short
dig lookalike.example.com MX +short
dig _dmarc.lookalike.example.com TXT +short
dig default._domainkey.lookalike.example.com TXT +short

# SSL / TLS certificate footprint (active scan)
echo | openssl s_client -connect lookalike.example.com:443 -servername lookalike.example.com 2>/dev/null \
  | openssl x509 -text -noout

# Passive DNS (commercial)
# SecurityTrails, DomainTools, RiskIQ — verify 2026-04-27
```

Forensic indicators:

- **Recently-registered** (within 30 days of incident) — strong signal for active campaign.
- **Privacy-protected WHOIS / GDPR-redacted** — most lookalikes are redacted in the modern WHOIS landscape; not a strong signal alone.
- **MX records pointing to commodity SMTP relays** (SendGrid, Mailgun, Amazon SES, OVH) — operational signal.
- **A records on commodity hosting** (DigitalOcean, Vultr, Linode, Hetzner, OVH, Cloudflare) — operational signal.
- **Cloudflare-fronted** — common; impedes upstream-IP discovery; pivot via SSL-cert SAN, mail-flow MX, or coordinated provider abuse.
- **No DMARC / weak SPF on the lookalike** — campaign infrastructure rarely deploys outbound mail-auth on the squat domain itself; their mail uses other infrastructure.
- **Registrar pattern** (NameCheap / NameSilo / Tucows / Porkbun / Hostinger — verify 2026-04-27) — bulk-registration patterns are visible across sister-squats; the same registrant (even when redacted via Privacy Service) often clusters at one registrar.

### 9.6 Brand-Confusable Unicode (TR39 Confusables)

Unicode Technical Report 39 publishes a confusables.txt mapping similar-looking glyphs across scripts. Tools:

```bash
# Python: confusables-py
python3 -c "from confusable_homoglyphs import confusables; print(confusables.is_confusable('exаmple.com'))"

# Online ICU confusables analyzer
# https://util.unicode.org/UnicodeJsps/confusables.jsp
```

### 9.7 Lookalike Workflow

1. **Generate candidates** — `dnstwist --registered`, `urlcrazy`, `urlinsane`; cross-check confusables for IDN.
2. **Resolve** — DNS A / MX / TXT for each registered candidate.
3. **Enrich** — WHOIS, registrar, hosting ASN, SSL certs, passive DNS.
4. **Cross-walk to incident headers** — does any candidate appear in the suspect message's `From:`, `Reply-To:`, `Return-Path`, embedded URLs, signature block?
5. **Cross-walk to DMARC reports** — has this candidate appeared as a `source_ip` against the customer's domain? (No — `source_ip` is the *sender* IP. Cross-walk to the customer's mail-flow alerts and SEG quarantine logs.)
6. **Track campaign infrastructure** — sister-domain discovery (SSL-cert SAN expansion, registrar-data clustering, hosting-IP co-location).
7. **Coordinate take-down** — registrar abuse contact + hosting-provider abuse contact + CDN abuse contact; legal-counsel on UDRP (Uniform Domain-Name Dispute-Resolution Policy) where the brand has a registered trademark.

---

## 10. M365 / Workspace Message Tracing

### 10.1 Microsoft 365 Message Trace

The mailbox-side of any M365-hosted incident is owned by [[sop-saas-log-forensics|SaaS Log Forensics]]. This SOP covers the **mail-flow** layer specifically.

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName investigator@<tenant>.onmicrosoft.com

# Get-MessageTrace — last 10 days, 5000-message page
Get-MessageTrace -StartDate (Get-Date).AddDays(-10) -EndDate (Get-Date) `
                 -SenderAddress "spoofed@example.com" `
                 -PageSize 5000 | Export-Csv mt-recent.csv

# Historical trace (10-90 days; report-based, slower)
Start-HistoricalSearch -ReportTitle "BEC-investigation-2026-04-27" `
                      -StartDate "2026-02-01" -EndDate "2026-04-27" `
                      -ReportType MessageTrace `
                      -SenderAddress "spoofed@example.com"
# Result delivered as CSV / report by mail; pull from Get-HistoricalSearch

# Per-message detail (event-level: Receive, Submit, Deliver, FilterAgent, Send,
# Quarantine, AttributionFlow)
Get-MessageTraceDetail -MessageTraceId <guid> -Recipient <recipient>
```

Microsoft is migrating message trace to a new Reporting Web Service / Graph endpoint [verify 2026-04-27 — `Get-MessageTraceV2` cmdlet name and Graph endpoint are evolving; verify against current Microsoft documentation before scripting]. The legacy `Get-MessageTrace` retains 10-day visibility; longer windows require historical search, which is asynchronous and report-driven.

For higher-fidelity event-level detail, Defender for Office 365 **Threat Explorer** (Defender portal → Email & collaboration → Explorer) provides the per-recipient delivery action (Delivered / Junk / Phish / Bulk / Quarantine / Replaced / Stripped) and supports purge actions (Soft Delete / Hard Delete / Move to Junk / Move to Inbox); state-changing actions require explicit authorization.

### 10.2 On-Premises Exchange Message Tracking

```powershell
# On-premises Exchange Server message tracking
Get-MessageTrackingLog -Server <transport-server> -Start "2026-04-27 00:00" -End "2026-04-27 23:59" `
    -Sender "spoofed@example.com" -EventId "DELIVER","FAIL","RECEIVE","SEND","BADMAIL"
```

Hybrid environments (Exchange Online + on-prem) require message-trace correlation across both surfaces.

### 10.3 Google Workspace Email Log Search

Workspace Email Log Search (Admin Console → Reporting → Email Log Search) provides per-message visibility for the last 30 days, with deeper retention via Vault (when in-place) and via Gmail BigQuery export.

Query parameters: `From:`, `To:`, `Subject:`, message size, sent / received timestamp, message ID. Results include the per-recipient routing decision (Delivered / Quarantine / Spam-Marked / Phishing / Reverted) and the security verdict.

```bash
# GAM7 wrapper (https://github.com/GAM-team/GAM)
gam report email startTime "2026-04-27T00:00:00Z" endTime "2026-04-27T23:59:59Z" \
    eventName "ATTACHMENT_DELIVERY" \
    fields "user,event,message_id,recipient_email,sender_email,subject"

# Workspace Reports API (gmail application — covers a different surface than Email Log Search)
gam report gmail eventName authorize fields user,event,client_id,scope
```

### 10.4 Gmail BigQuery Export

For long-term mail-event evidence, customers can configure Workspace logs export to BigQuery, which exports the Gmail logs (delivery decisions, sender / recipient, subject, message ID, security verdict) at full granularity beyond the 30-day Email Log Search window [verify 2026-04-27].

```sql
-- Example BigQuery against `<project>.<dataset>.activity` (Workspace logs export schema)
SELECT *
FROM `project.dataset.activity`
WHERE event.name = 'message_delivered'
  AND event.parameters.sender_email LIKE '%spoofed@example.com%'
  AND TIMESTAMP_TRUNC(time, DAY) BETWEEN '2026-02-01' AND '2026-04-27'
ORDER BY time DESC
```

### 10.5 Cross-Walk to Mailbox-Compromise Side

When the BEC includes a mailbox-compromise pivot:

- **Authentication context** for the suspicious sign-in: Entra ID sign-in logs / Workspace `login` Reports → [[sop-saas-log-forensics|SaaS Log Forensics]] §4.2 / §5.1.
- **Mailbox-rule changes** (`New-InboxRule`, `Set-InboxRule`, `Remove-InboxRule`) → [[sop-saas-log-forensics|SaaS Log Forensics]] §4.6.
- **Mailbox audit** (mail accessed, sent, moved, deleted) — `Search-MailboxAuditLog` → [[sop-saas-log-forensics|SaaS Log Forensics]] §4.5.
- **OAuth-app token persistence** (the OAuth-consent BEC variant) → [[sop-saas-log-forensics|SaaS Log Forensics]] §10. The mailbox-side compromise reconstruction lives there; this SOP captures the *messages* the compromised mailbox sent and received.

### 10.6 Quarantine and Junk-Folder Forensics

Recipient-side quarantine / junk-folder content is part of the mail-flow record. Defender for Office 365 quarantine retains messages for tenant-configurable periods (default 30 days [verify 2026-04-27]); Workspace **Spam** and **Quarantine** retain for the workspace-configured retention (default 30 days [verify 2026-04-27]). Quarantine pulls (read-only) are part of evidence collection; release / delete actions are state-changing and require authorization.

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

Pull via Mimecast API (https://www.mimecast.com/tech-connect/documentation/) — version pin per engagement [verify 2026-04-27]. Engagement-time admin role: dedicated investigator console user with `Audit` and `Search & Recover` rights.

### 11.2 Proofpoint

Proofpoint provides:

- **Smart Search** — message-flow search with per-message detail.
- **Threat Insight** — campaign-level intelligence (matched campaigns, IOC enrichment).
- **TAP (Targeted Attack Protection)** — URL / attachment behavioral disposition.
- **Threat Response Auto-Pull (TRAP)** — post-delivery message removal events.
- **Audit Logs** — admin / API activity.

Pull via Proofpoint REST API / SIEM API [verify 2026-04-27]. Engagement-time admin role: read-only Smart Search + Threat Insight.

### 11.3 Microsoft Defender for Office 365

Already covered at §10.1 (Threat Explorer, Quarantine). Additionally:

- **Submissions** — administrator submissions to Microsoft for mis-classification review.
- **Campaign Views** — Microsoft-aggregated campaign intelligence.
- **Compromised User Detection** — leaked-credential / suspicious-mail-flow alerts.
- **Attack Simulation Training** — *training* infrastructure that should not appear in real incidents (rule out as cause when investigating "received simulated phishing" reports).

### 11.4 Cisco Secure Email (formerly Ironport ESA)

- **Message Tracking** — appliance / cloud message-flow search.
- **Mail Logs** — raw MTA logs (extensible to SIEM / log-management).
- **AsyncOS** version drives feature scope and API surface [verify 2026-04-27].

### 11.5 Barracuda Email Security Gateway / Email Security Service

- **Message Logs** — per-message disposition.
- **Atlas** (cloud) intelligence overlay.

### 11.6 Sophos Email Appliance / Sophos Central Email

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
- **Sandbox capture** — detonating the phishing URL in a sandbox (Microsoft Defender for Office 365 Detonation, Joe Sandbox, ANY.RUN, Hatching Triage — verify 2026-04-27) can capture the kit's served output and sometimes the source.
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
- **Kit-author signatures** — many kits carry author tags (`/* coded by ... */` comments, watermarks, author-website links); cross-walk against threat-intel kit-tracking communities (PhishKit Tracker [verify 2026-04-27], Group-IB Phishing Kit Track, Akamai Hunt, Cofense Intelligence).

### 12.4 Adversary-in-the-Middle (AiTM) Detection

**EvilGinx, Modlishka, Muraena**, and a growing family of AiTM kits proxy the legitimate authentication flow — the victim sees the real login page (because the kit fetches it from the legitimate provider), enters credentials, completes MFA; the kit captures the post-MFA session cookie / token, then either passes through or fails the user out. The attacker holds a valid session token without ever needing the credential in isolation. AiTM is the dominant pattern defeating MFA in 2024-2026 BEC [verify 2026-04-27].

Detection signatures:

- **Hostname pattern** — AiTM kits commonly proxy `login.microsoftonline.com` through a registered lookalike (`login-microsoftonline.<lookalike>.<tld>`); cross-walk against §9 lookalike inventory.
- **TLS-cert SAN expansion** — kits frequently issue a single cert covering multiple impersonated provider hostnames; CT-log monitoring (§9.4) catches the issuance.
- **JA3 / JA4 client-side fingerprint** — when the kit operates as an HTTP client back to the legitimate provider, the kit's TLS-stack fingerprint differs from the victim's browser. SaaS providers' anomaly engines exploit this; investigators can request the JA3/JA4 from the provider's incident-response team [verify 2026-04-27].
- **Header-based** — the proxy adds / strips / re-orders HTTP headers in characteristic ways; the legitimate provider's signal team has fingerprints.
- **Geolocation chain** — sign-in via a residential-proxy hosted in country A while victim is in country B; combined with the immediate post-sign-in session token use from a different residential-proxy ASN.

Defensive mitigation lives in [[sop-saas-log-forensics|SaaS Log Forensics]] and Conditional Access / Continuous Access Evaluation policy; this SOP names the *detection signature in mail and infrastructure*.

### 12.5 Phishing Infrastructure Indicators

| Surface | Pattern |
|---|---|
| **Cloudflare Tunnel (`*.trycloudflare.com`)** | Free-tunnel name in suspicious URL — operationally cheap and short-lived |
| **ngrok (`*.ngrok-free.app`, `*.ngrok.io`)** | Free-tunnel tooling abused for short-lived phishing |
| **Serverless (`*.azurewebsites.net`, `*.web.app`, `*.firebaseapp.com`, `*.netlify.app`, `*.vercel.app`, `*.cloudfront.net`, `*.r2.dev`, `*.pages.dev`, `*.workers.dev`)** | Serverless / managed-hosting platforms abused for phishing pages; verify provider abuse contacts |
| **Compromised legitimate domains** | Older WordPress / cPanel sites with vulnerable plugins host kits in subdirectories; `<legitimate>/<random-path>/<kit>/` |
| **Residential-proxy ASN egress** | Sign-in / phishing-victim-fetch from residential-proxy ASN |
| **Free-mail attacker addresses for exfil** | `*@gmail.com` / `*@outlook.com` / `*@protonmail.com` / `*@yandex.com` / `*@onionmail.org` in kit `config.php` |
| **Telegram bot exfil** | `api.telegram.org/bot<token>/sendMessage?chat_id=<id>` — token reuse across campaigns is common; cross-walk via Telegram-bot-tracking research [verify 2026-04-27] |
| **Open-directory exposure** | `Index of /` / `Apache/2.X Server` directory listing allows kit retrieval at investigation time |

### 12.6 Disclosure of Findings

- **Hosting / CDN / registrar abuse-contact disclosure** — for active infrastructure, route through documented abuse channels (AWS abuse@, Cloudflare abuse, GoDaddy abuse, Namecheap abuse, etc.).
- **Brand-coordination disclosure** — when the kit impersonates a brand, the brand's security team is the disclosure path (Microsoft MSRC, Google security, Apple Product Security, the brand's CSIRT).
- **Threat-intel community sharing** — kit IOCs can be shared via PhishTank, OpenPhish, MISP communities, NCSC Phishing Reporting, US-CERT, sector-specific ISACs (FS-ISAC for finance, H-ISAC for healthcare).
- **LE referral** — for active campaigns with significant victimization, FBI IC3 referral and Secret Service Field Office contact (US); NCSC (UK); national CERT pathway elsewhere.

---

## 13. Wire-Recall Pathway & Financial Recovery

### 13.1 What the Investigator Owns vs Doesn't

The investigator does not own the customer's banking relationship; the customer's treasurer / CFO / fraud-claims team coordinates with the bank. The investigator's job is to *enable* the recovery operation through forensic outputs:

- **A timeline** — when was the message received; when was the wire authorized; when was the wire transmitted; when was the fraud detected.
- **A wire reference** — the originating bank's wire reference number; the SWIFT GPI **UETR** (Unique End-to-End Transaction Reference, ISO 20022 — verify 2026-04-27); the Fedwire IMAD / OMAD; the SEPA reference.
- **Beneficiary detail** — beneficiary bank, beneficiary account / IBAN, beneficiary name (often a money-mule company or individual).
- **The pretext narrative** — the BEC reconstruction package (the email; the lookalike; the spoofed-CEO chain) that the FBI and bank fraud teams will reference.

### 13.2 SWIFT Recall Mechanics

**SWIFT MT103** is the Single Customer Credit Transfer message; the originating bank sends MT103 to the beneficiary bank (often through correspondent banks). Recall is via **SWIFT MT192** (Request for Cancellation), citing the original MT103 reference. The destination-bank's compliance team evaluates the cancellation request; if funds are still on hold, return is likely. The 2018-era introduction of **SWIFT GPI** added the **UETR** (Unique End-to-End Transaction Reference) and **Stop and Recall** service — a faster path for the originating bank to attempt recall across the GPI network [verify 2026-04-27].

Cross-border MT103 recalls historically engage both banks' AML / financial-intelligence-unit (FIU) coordination; the FBI Legal Attaché in the destination jurisdiction frequently coordinates the FIU contact.

### 13.3 Fedwire Recall

Fedwire transfers are domestic US dollar (mostly inter-bank) settlements. Fedwire recall is structured around the Fed Funds Rule and bank-to-bank cooperation; the originating bank's Fed funds operations team initiates the recall. Recovery within the same business day is most likely; cross-day recall depends on beneficiary-bank cooperation. FedNow (the Federal Reserve's instant-payment service launched 2023 [verify 2026-04-27]) has its own real-time recall path with shorter windows.

### 13.4 SEPA / EU Recall

SEPA Credit Transfer (SCT) recall uses **SCT R-Transactions** — Reject, Return, Refusal, Reversal, Recall — codified in the EPC (European Payments Council) Rulebook. SEPA Instant Credit Transfer (SCT Inst) has a separate, faster recall window. Cross-EU recalls coordinate through the originating-bank's national-clearing-system; intra-Eurozone recall is faster than cross-currency [verify 2026-04-27].

### 13.5 IC3 Referral and the Financial Fraud Kill Chain

```
Customer detects BEC wire
   ↓
Customer's fraud-claims team contacts originating bank fraud desk
   ↓ (within hours)
Originating bank issues recall (SWIFT MT192 / Fedwire recall / SEPA recall)
   ↓ (concurrently)
Customer files at IC3.gov  (https://www.ic3.gov)
   ↓
IC3 routes to FBI field office
   ↓ (when threshold met)
FBI activates Financial Fraud Kill Chain (FFKC)
   ↓
FBI Legal Attaché in destination jurisdiction engages destination FIU
   ↓
Destination FIU coordinates with destination bank for funds freeze
   ↓
Destination bank holds funds pending civil / criminal action
```

Practical investigator actions:

- **Help the customer assemble the IC3 packet** — wire confirmation; recipient bank info; beneficiary info; copy of the BEC email; lookalike domain analysis; investigator contact info. IC3 has a structured intake form; submitting in the first 24 hours materially improves outcomes [verify 2026-04-27 — IC3 publishes recovery statistics annually].
- **Note FFKC threshold** — historically a USD 50,000 threshold and 72-hour transmission window applied for international wire FFKC; verify against current IC3 / FBI guidance for current thresholds and FFKC service expansion (FedNow, SCT Inst, domestic ACH where applicable) [verify 2026-04-27].
- **Coordinate with bank's BSA / AML officer** — the customer's bank has Bank Secrecy Act SAR-filing obligations triggered by the fraudulent transfer (31 CFR 1020.320 SAR threshold $5,000 if there's a known suspect; $25,000 if no suspect — verify 2026-04-27); the SAR-filing process is the bank's, not the investigator's, but the investigator's reconstruction supports it.

### 13.6 ACH and Check Recall

ACH unauthorized debits can be returned by the receiving depository financial institution (RDFI) within 60 days under Regulation E for consumer accounts; for B2B / commercial accounts the unauthorized-debit return window is much shorter, generally 24 hours under Reg J / WEB / CCD authorization rules [verify 2026-04-27 — NACHA rules update annually]. Check fraud (counterfeit check, altered check, payee endorsement fraud) routes through UCC §3 / §4 frameworks; recovery via the originating bank's check-fraud claims process.

### 13.7 Cryptocurrency Payout Recovery

When BEC payout instructed cryptocurrency:

1. **Capture the wallet address** from the message body (or QR code via OCR) immediately; confirm on-chain receipt.
2. **Submit to sanctions / abuse databases** — Chainalysis Reactor, TRM Labs, Elliptic, Crystal Blockchain, Etherscan / Blockchain.com label-tagging — verify 2026-04-27.
3. **Hand off the on-chain trace** to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] when funds funnel into Tornado Cash / Wasabi / Samourai-style services.
4. **Coordinate with destination CEX compliance** — when funds arrive at a centralized exchange, that exchange's compliance team can freeze the deposit if law-enforcement preservation request is in place. Coinbase, Kraken, Binance, Bitstamp, OKX, and most major CEXes publish LE-cooperation pathways [verify 2026-04-27].
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
- FFKC engagement status (when threshold met).
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
| Authorized offensive phishing / red-team email tradecraft | (no SOP yet — `CLAUDE.md` Gaps item) |
| Container / Kubernetes runtime forensics that follow a cloud-credential exfiltration | (planned) `sop-container-k8s-pentest` for offensive aspects; [[sop-cloud-forensics|Cloud Forensics]] §10 for forensics |
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
| `parsedmarc` | DMARC aggregate + forensic report parser | https://github.com/domainaware/parsedmarc [verify 2026-04-27] |
| OpenARC | ARC chain validation | https://github.com/trusteddomainproject/OpenARC [verify 2026-04-27] |
| `swaks` | SMTP test client (sandbox use only — never against production with real targets) | https://github.com/jetmore/swaks |
| `mailheader-parser` / `mha` | Email header analyzers (web-based variants from Microsoft, Google, MXToolbox) | various — verify 2026-04-27 |
| Microsoft Message Header Analyzer | Web-based header parser by Microsoft | https://mha.azurewebsites.net/ [verify 2026-04-27] |
| Google Toolbox MessageHeader | Web-based header parser by Google | https://toolbox.googleapps.com/apps/messageheader/analyzeheader [verify 2026-04-27] |
| MXToolbox SuperTool | Web-based DNS / mail-flow analysis | https://mxtoolbox.com/SuperTool.aspx |

### Lookalike-Domain Tooling

| Tool | Purpose | Link |
|------|---------|------|
| `dnstwist` | Generator-resolver for lookalike-domain candidates | https://github.com/elceef/dnstwist |
| `urlcrazy` | Alternate generator | https://github.com/urbanadventurer/urlcrazy |
| `urlinsane` | Alternate generator (Go) | https://github.com/rangertaha/urlinsane |
| `crt.sh` | Certificate Transparency log search (free) | https://crt.sh |
| `Censys` | CT log + internet scan + cert search (commercial, free tier) | https://censys.io |
| `confusable-homoglyphs` | Python TR39-confusables analyzer | https://github.com/vhf/confusable_homoglyphs |
| `whois` / `whoisxmlapi` | WHOIS lookup, current and historical (commercial) | (system) / https://www.whoisxmlapi.com [verify 2026-04-27] |
| DomainTools Iris / Investigate | Commercial passive-DNS + WHOIS-history + brand-protection | https://www.domaintools.com [verify 2026-04-27] |
| Group-IB Digital Risk Protection | Commercial brand / domain monitoring | https://www.group-ib.com [verify 2026-04-27] |
| RiskIQ Digital Footprint / Microsoft Defender EASM | Commercial external-attack-surface management (acquired by Microsoft) | https://www.microsoft.com [verify 2026-04-27] |
| ZeroFox / BrandShield / Mandiant Digital Threat Monitoring | Commercial brand-protection platforms | various — verify 2026-04-27 |

### M365 / Workspace / SEG Forensic Surfaces

| Tool | Vendor | Purpose |
|------|--------|---------|
| `Get-MessageTrace` / `Get-MessageTraceDetail` | Microsoft 365 (Exchange Online PowerShell) | Mail-flow tracing (10-day live, 90-day historical) |
| `Get-MessageTraceV2` / new Reporting endpoint | Microsoft 365 | Successor cmdlet / API [verify 2026-04-27] |
| `Search-MessageTrackingLog` | Exchange Server (on-prem) | On-prem mail-flow tracking |
| Defender for Office 365 Threat Explorer | Microsoft 365 | Per-recipient delivery / disposition |
| Defender for Office 365 Quarantine | Microsoft 365 | Quarantined-message inspection |
| `Get-QuarantineMessage` | Microsoft 365 | Programmatic quarantine pull |
| Workspace Email Log Search | Google Workspace | 30-day per-message routing / disposition |
| GAM7 | Google Workspace | CLI for Reports + Email Log + Vault |
| Workspace Vault | Google Workspace | eDiscovery + holds for long-term mail-content evidence |
| Gmail BigQuery export | Google Workspace | Long-window message-event evidence |
| Mimecast Tracker / Search & Recover / Audits | Mimecast | Per-message routing + archive search |
| Proofpoint Smart Search / Threat Insight / TAP / TRAP | Proofpoint | Per-message + campaign + URL / attachment analysis |
| Cisco Secure Email Message Tracking | Cisco | On-prem / cloud appliance mail-flow tracking |
| Barracuda Email Security Message Logs | Barracuda | Per-message routing |
| Sophos Email Message Search | Sophos | Per-message routing |

### Phishing-Kit / Sandbox / Detonation

| Tool | Purpose | Link |
|------|---------|------|
| Microsoft Defender for Office 365 Detonation | Sandbox detonation of URLs / attachments | (in-product) |
| Joe Sandbox | Commercial sandbox | https://www.joesandbox.com [verify 2026-04-27] |
| ANY.RUN | Commercial sandbox | https://any.run [verify 2026-04-27] |
| Hatching Triage | Commercial sandbox (acquired by Recorded Future) | https://tria.ge [verify 2026-04-27] |
| URLScan.io | URL crawl with full HAR + screenshot + DOM | https://urlscan.io |
| PhishTool | Phishing analysis platform | https://www.phishtool.com [verify 2026-04-27] |
| PhishTank | Crowd-sourced phishing-URL clearinghouse | https://phishtank.org |
| OpenPhish | Phishing-URL feed | https://openphish.com |

### Wire-Recall and Financial-Recovery

| Resource | Purpose |
|----------|---------|
| FBI IC3 | https://www.ic3.gov — Internet Crime Complaint Center filing |
| FBI Field Office contact | Direct field-office contact for active wire fraud |
| Secret Service Field Office | Concurrent jurisdiction for financial crimes (US) |
| FinCEN Rapid Response Program | https://www.fincen.gov — wire-fraud rapid coordination |
| SWIFT GPI Stop and Recall | Originating-bank operations via the GPI network |
| EPC (European Payments Council) Rulebooks | SEPA / SCT Inst recall rules — https://www.europeanpaymentscouncil.eu [verify 2026-04-27] |
| NCSC (UK) | https://www.ncsc.gov.uk — UK cyber-fraud reporting + advice |
| Action Fraud (UK) | https://www.actionfraud.police.uk — UK fraud reporting |
| Europol EC3 | https://www.europol.europa.eu/about-europol/european-cybercrime-centre-ec3 — EU cybercrime |

### Open-Source / Vendor-Neutral

| Tool | Purpose | Link |
|------|---------|------|
| Sigma | Vendor-neutral detection rules with M365 / Workspace / SEG backends | https://github.com/SigmaHQ/sigma |
| MITRE ATT&CK for Initial Access (Phishing) | Adversary technique reference | https://attack.mitre.org/techniques/T1566/ |
| MISP | Threat-intel sharing platform with phishing-kit support | https://www.misp-project.org |
| TheHive / Cortex | IR case-management + observable enrichment | https://thehive-project.org |
| OpenCTI | Threat-intelligence platform with kit / domain / actor objects | https://www.filigran.io/en/products/opencti/ [verify 2026-04-27] |

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
- **AiTM and session-token theft defeat MFA.** "We had MFA enabled" is not protective; the attacker captures the post-MFA session. Conditional Access policies (compliant device, sign-in risk, location, named-locations), Continuous Access Evaluation, and FIDO2-bound tokens are the layered mitigations [verify 2026-04-27 — current best-practice landscape].
- **Phishing-kit acquisition has legal nuance.** Lawful acquisition paths are documented in §12.2; downloading from a live-attacker server is widely accepted as defensive forensics but may interact with anti-hacking statutes if the server is owned by a non-suspect third party. Verify under counsel for anything beyond the customer's own infrastructure.
- **SAR / FinCEN obligations are the bank's, not the investigator's.** The investigator's reconstruction supports the bank's SAR but does not substitute for it; the customer's bank has independent BSA obligations.
- **Insurance coverage may exclude social-engineering BEC.** Older policies cover computer-fraud and funds-transfer-fraud but exclude social-engineering. Newer policies add a sub-limited social-engineering rider. The investigator must not promise coverage outcomes.
- **Court-admissibility of mail-flow evidence depends on chain-of-custody.** Provider-side declarations (eDiscovery export with provider attestation per [[../../Investigations/Techniques/sop-collection-log|Collection Log]] §10 FRE 902(13)/(14)) are evidentiary-grade; raw `Get-MessageTrace` output without provider attestation is weaker. Plan exports through eDiscovery / Vault / Discovery for litigation-bound work.
- **Cross-tenant log visibility is asymmetric.** When the suspect's tenant is on the same provider as the victim, the suspect-side mail-flow is reachable only via provider legal process (subpoena / preservation letter); the victim-side mail-flow is in scope.
- **Multi-vendor SEG disagreement is common.** Mimecast / Proofpoint / Defender / Barracuda each apply distinct policies; SEG-A may have quarantined what SEG-B delivered. The chronological reconstruction must reconcile all transit-point dispositions.

---

## 17. Common Pitfalls

- **Reading headers top-down.** The top-most `Received:` is the latest hop; the bottom-most is closest to origin. Bottom-up is the rule.
- **Trusting `From:` over `Authentication-Results:`.** The `From:` is sender-controlled; the trusted `Authentication-Results:` is the evidence.
- **Inferring "DMARC blocked it" from existence of DMARC.** Confirm the policy (`p=`) and the alignment (`adkim` / `aspf`); `p=none` is monitoring.
- **Forgetting `pct=` rollout.** A `pct=10` rollout means 90% of failing mail is delivered. Verify the published policy is not in partial rollout.
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
- **Pre-filtering message-trace queries too narrowly.** Filtering at the `Get-MessageTrace` API loses surrounding context; pull broad on time and recipient, filter at analysis time.
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

**Forensic catch.** §4.2 trusted `Authentication-Results:` confirms the message *did* pass DMARC — but for the lookalike domain, not the legitimate `example-corp.com`. §9.3 dnstwist scan against `example-corp.com` surfaces `examp1e-corp.com` (along with siblings); §9.4 CT-log search shows the cert was issued seven days before the incident (recently-registered signal). §9.5 WHOIS / DNS / hosting enrichment ties the registration to a NameSilo + Cloudflare + Hetzner pattern with sister-domain matches (`exampie-corp.com`, `examplecorp-secure.com`); §10.1 `Get-MessageTrace` confirms the inbound delivery and recipient action; §13 confirms the wire was transmitted at 14:42 UTC and is at the correspondent-bank stage at incident detection.

**Hand-off.** §13 wire-recall begins immediately — customer's bank engages SWIFT MT192 cancellation; IC3 referral filed; FFKC threshold met. Lookalike-domain take-down request to NameSilo and Cloudflare. Adversary-infrastructure intelligence packaged for [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] follow-on. Mailbox-side audit (was the legitimate CEO's mailbox compromised, did the attacker monitor inbound?) routes to [[sop-saas-log-forensics|SaaS Log Forensics]] for confirmation.

### 18.2 Scenario — Vendor-Invoice Fraud via Compromised Vendor Mailbox

**Pattern.** A trusted vendor's accounts-receivable mailbox is compromised (the vendor falls victim to a separate AiTM phishing attack). The attacker sits silently for two weeks, monitoring the vendor's outbound invoicing rhythm. When the vendor sends a USD 87,000 invoice to the customer, the attacker — operating from the *legitimate* vendor mailbox — replies-all to the existing thread with a "banking detail update" PDF that points to an attacker-controlled bank account. The customer's AP team, seeing thread continuity and authentic SPF / DKIM / DMARC from the vendor, processes the wire to the new beneficiary.

**Forensic catch.** §4.2 trusted `Authentication-Results:` confirms full DMARC pass — because the message *did* come from the vendor's legitimate domain via the vendor's legitimate MTA. §10.1 `Get-MessageTrace` shows the inbound message traversed normal mail-flow. §10.5 cross-walk to mailbox-compromise side at the vendor: the vendor's [[sop-saas-log-forensics|SaaS Log Forensics]] §4.2 sign-in audit, §4.5 mailbox audit, and §4.6 inbox-rule audit (likely a forwarding rule on AP-related subjects). The forensic header analysis here captures the *outbound* messages the compromised vendor mailbox sent; the *inbound* compromise is the vendor's IR engagement, not the customer's. §12.4 AiTM signature on the vendor side: the original phishing landing page that captured the vendor's session.

**Hand-off.** Mailbox-compromise reconstruction at the *vendor* routes to [[sop-saas-log-forensics|SaaS Log Forensics]] (the vendor's own engagement, not the customer's). Wire recall per §13 (challenging — the apparent message authentication was clean, so DMARC alerts did not fire; detection was post-payment). PDF attachment (the "banking-detail update") routes to [[sop-malware-analysis|Malware Analysis]] §6.3 PDF Analysis. Customer's vendor-management process for "out-of-band verification of banking-change requests" is the structural fix recommendation.

### 18.3 Scenario — Real-Estate Closing-Funds Fraud via Title-Agent Lookalike

**Pattern.** Attacker registers `<title-agent>.<lookalike-tld>` (e.g., the legitimate title agent `ABC Title Co` operates `abctitle.com`; attacker registers `abctitle.co` or `abctitle-secure.com`). Attacker enrolls in the buyer's email thread (often via a spoofed reply at the right phase of the closing process) impersonating the title agent's closing coordinator. With closing two days away, attacker sends "wire instructions" to the buyer naming an attacker-controlled bank. Buyer wires USD 480,000.

**Forensic catch.** §4 header analysis on the attacker's "wire instructions" message — `From:` is the lookalike domain, `In-Reply-To:` may be forged or the attacker hijacked an earlier thread message via the buyer-side compromise. §9 lookalike inventory against `abctitle.com` — surfaces the squat. §10.1 `Get-MessageTrace` on the buyer's mailbox shows the inbound message and any earlier suspicious authenticated messages. §9.4 CT-log shows the squat cert issuance timing.

**Hand-off.** Wire recall per §13 — particularly tight 24-hour window if detected at closing. ALTA escrow procedures and title-agent's E&O insurance carrier engaged. Civil action against the registrar / hosting provider for take-down + preservation. FBI Real Estate Wire Fraud Task Force notification. The buyer's mailbox compromise (if present) routes to [[sop-saas-log-forensics|SaaS Log Forensics]]; sometimes the buyer's mailbox is *not* compromised and the attacker harvested context from a public closing-process announcement or social-media post — in which case [[../../Investigations/Techniques/sop-image-video-osint|Image / Video OSINT]] and [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] reconstruct the OSINT trail.

### 18.4 Scenario — Cryptocurrency-Payout Vendor-Invoice Fraud

**Pattern.** Vendor-invoice-fraud variant where the attacker, instead of redirecting fiat wire, instructs the customer that the vendor "now accepts USDT for invoicing efficiency" and provides an attacker-controlled USDT wallet address in the attacker-modified invoice. The customer's AP team, encountering this for the first time, accepts the change and pays USD 38,000 in USDT on Tron (TRC20).

**Forensic catch.** §4 header analysis on the attacker's invoice message; §9 lookalike check (or mailbox-compromise check per §18.2 pattern). §10.1 message trace establishes the inbound message timeline. The wallet address is captured from the message body / PDF attachment.

**Hand-off.** On-chain trace of the USDT-TRC20 wallet routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; deposit-at-CEX coordination (Binance / OKX / Bybit) for freeze-at-CEX where possible per §13.7. Sanctions-screening overlay at [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] (the wallet may be on an OFAC SDN list or cross-walk to a known threat-actor cluster). PDF attachment to [[sop-malware-analysis|Malware Analysis]] §6.3 if it carries embedded payload. Wire-recall is not applicable; recovery focus is the on-chain trace and CEX freeze.

### 18.5 Scenario — AiTM Mailbox Compromise → Outbound Spear-Phish to Customer's Customer

**Pattern.** Customer's sales executive falls to an AiTM phishing attack (per §12.4) on `login-microsoftonline.<lookalike>.<tld>`; the attacker captures the sales executive's post-MFA session token. With mailbox access, the attacker enumerates the sales executive's customers, identifies a customer in active-renewal cycle, and sends a "renewal banking-detail update" message *from the legitimate compromised mailbox* to the customer's AP team. The customer's AP wires USD 64,000 to attacker beneficiary.

**Forensic catch.** §4.2 trusted `Authentication-Results:` confirms full DMARC pass — message came from the legitimate mailbox. §10.5 cross-walk to the mailbox-compromise side: [[sop-saas-log-forensics|SaaS Log Forensics]] §4.2 sign-in audit identifies the AiTM session origin (residential-proxy IP, unusual ASN); §4.6 inbox-rule audit identifies the auto-forward rule for "renewal" / "banking" / "AP" subjects (the attacker's persistence primitive on the mailbox). §10.1 `Get-MessageTrace` on the *outbound* legs shows the attacker's send pattern. §12.4 AiTM signature on the original phishing landing page (the lookalike host); §9 catches the lookalike domain.

**Hand-off.** Mailbox-compromise reconstruction routes to [[sop-saas-log-forensics|SaaS Log Forensics]] §4 and §10 (whether the compromise was OAuth-consent BEC or AiTM-session-token-replay). AiTM phishing-kit analysis routes to §12 here for kit-fingerprint extraction; deeper RE to [[sop-malware-analysis|Malware Analysis]] §6.4 Script Analysis. Wire recall per §13. Customer's customer notification (the *downstream* victim) coordinated through [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]]; the duty-of-care to the downstream victim is jurisdiction-specific and counsel-led.

---

## 19. Related SOPs

**Analysis (parent and adjacent):**
- [[sop-saas-log-forensics|SaaS Log Forensics]] — sibling SOP covering the SaaS-tenant identity / collaboration plane (M365 UAL, mailbox audit, inbox-rule forensics, OAuth consent grants, mailbox-compromise reconstruction). Per the buildout-plan scope contract, the OAuth-consent BEC variant lives in #8; this SOP covers the email-flow and header-spoofing side. Hybrid BEC incidents that pivot through mailbox compromise are split: the *messages* live here, the *mailbox audit* lives in #8.
- [[sop-cloud-forensics|Cloud Forensics]] — sibling SOP covering the IaaS plane. When BEC-stolen credentials enable cloud-resource action, the email side stays here; the cloud-resource action routes to #7.
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
- [[sop-legal-ethics|Legal & Ethics]] — canonical jurisdictional framework, breach-notification timelines, wire-fraud-statute interaction (18 U.S.C. §1343 wire fraud, §1349 conspiracy, §1956 / §1957 money-laundering; UK Fraud Act 2006; equivalent EU and other-jurisdiction wire-fraud statutes), insurance-coverage interaction, and counsel-led decisions on cross-border evidence transfer.
- [[sop-opsec-plan|OPSEC]] — investigator infrastructure, artifact hygiene, pre-disclosure handling discipline; particular attention during active wire-fraud incidents where adversary may be monitoring victim infrastructure and IR-team operational signal can leak.

**Forward references (planned, not yet built):**
- (planned) `sop-container-k8s-pentest` — referenced from [[sop-cloud-forensics|Cloud Forensics]] §1; not directly referenced from this SOP except indirectly via cloud-pivot scenarios.

---

## Legal & Ethical Considerations

> Canonical jurisdictional framework lives in [[sop-legal-ethics|Legal & Ethics]]. The summary below is operational guidance for email and BEC forensics engagements specifically; do not substitute it for the cross-referenced source.

### Authorization

- **Tenant-administrator authorization** is the typical engagement authority for the recipient-side mail-flow surface. The customer's mailbox-provider admin authorizes the investigator's read-only role and any state-changing actions (sender-block, message purge, mailbox-rule disablement, OAuth-app revocation). Without it, the investigator's access is unauthorized regardless of the suspect's behavior.
- **Sender-side authorization is asymmetric.** The investigator cannot authenticate, sign, or query *sender-side* logs on infrastructure they do not own; provider legal process (subpoena / preservation letter) is the route for sender-side evidence on a third-party provider.
- **Provider legal process** for cross-tenant evidence — when the suspect's tenant is on the same provider as the victim, the provider's law-enforcement portal and customer-side legal-process pathways are the route. Microsoft, Google, Mimecast, Proofpoint, Cisco, Barracuda, AWS SES, SendGrid, Mailgun, and most major SEGs publish LE-cooperation paths and require subpoena / warrant / MLAT / preservation letter [verify 2026-04-27].
- **Cross-jurisdiction authorization.** EU-data, healthcare, payment, and government-tenant workloads carry residency / sovereignty constraints. CLOUD Act executive agreements, Schrems II / DPF / SCCs framing, MLATs, and the Budapest Convention Second Additional Protocol shape cross-border evidence-transfer pathways. Verify under counsel.
- **Wire-fraud-statute interaction.** 18 U.S.C. §1343 (wire fraud), §1349 (conspiracy), §1956 / §1957 (money-laundering); UK Fraud Act 2006; EU and other-jurisdiction wire-fraud statutes. The investigator coordinates with prosecution / civil-litigation strategy through counsel; the engagement does not direct the prosecution.
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
- **State breach laws** (US) — varies by state; California (CCPA / CPRA), New York (SHIELD), and many others have specific timelines and requirements; some (NY, CT, MD, VT) have specific BEC / financial-loss reporting interaction.
- **PCI DSS Incident Response Plan** — required for cardholder-data environments.
- **Sectoral rules** — finance (NYDFS Part 500 — 72-hour cyber-event notification, FFIEC, EBA / DORA, GLBA Safeguards Rule), healthcare (HIPAA, NIS2 in EU), telecom — verify per engagement.
- **Wire-fraud-related disclosure** — beyond breach laws, wire fraud may trigger SEC cyber-disclosure (for registrants, material incidents), state insurance-commissioner reporting, and bank-regulator notification (OCC / FDIC / FRB / state — for the customer's bank); the disclosure interaction with the active recall operation needs counsel coordination.

### Disclosure Discipline

- Pre-disclosure findings are restricted to the engagement team and the client per the engagement contract.
- Findings affecting third parties (a vendor whose identity was impersonated; a customer of the customer who fell to a downstream pivot; an upstream SEG vendor whose detection failed) are escalated through the affected party's security contact, not embedded silently in the client's report.
- Vendor coordination is sometimes warranted (provider-resident vulnerability in service surface; widespread credential-leak indicator). MSRC, Google VRP, Cloudflare Trust & Safety, and most SEG vendors publish coordinated-disclosure paths.
- LE coordination — IC3 and FBI Field Office for active wire fraud; Secret Service Field Office for concurrent-jurisdiction financial crimes; NCSC (UK), Action Fraud (UK), Europol EC3, national CERTs in other jurisdictions.
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
- RFC 7489 — Domain-based Message Authentication, Reporting, and Conformance (DMARC) — https://www.rfc-editor.org/rfc/rfc7489
- RFC 8463 — A New Cryptographic Signature Method for DKIM (Ed25519-SHA256) — https://www.rfc-editor.org/rfc/rfc8463
- RFC 8617 — The Authenticated Received Chain (ARC) Protocol — https://www.rfc-editor.org/rfc/rfc8617
- RFC 8601 — Message Header Field for Indicating Message Authentication Status — https://www.rfc-editor.org/rfc/rfc8601
- RFC 8616 — Email Authentication for Internationalized Mail — https://www.rfc-editor.org/rfc/rfc8616
- RFC 9690 — Brand Indicators for Message Identification (BIMI) — https://www.rfc-editor.org/rfc/rfc9690 [verify 2026-04-27]
- RFC 6591 — Authentication Failure Reporting Using the Abuse Reporting Format — https://www.rfc-editor.org/rfc/rfc6591
- RFC 6962 — Certificate Transparency — https://www.rfc-editor.org/rfc/rfc6962
- RFC 3492 — Punycode: A Bootstring encoding of Unicode — https://www.rfc-editor.org/rfc/rfc3492
- Unicode TR39 — Unicode Security Mechanisms — https://www.unicode.org/reports/tr39/
- ISO 20022 — Financial-services messaging (UETR / SWIFT GPI) — https://www.iso20022.org

**Vendor documentation:**
- Microsoft — Anti-spoofing protection in EOP — https://learn.microsoft.com/defender-office-365/anti-spoofing-protection-about [verify 2026-04-27]
- Microsoft — Email message tracing — https://learn.microsoft.com/exchange/monitoring/trace-an-email-message/trace-an-email-message [verify 2026-04-27]
- Microsoft — Defender for Office 365 Threat Explorer — https://learn.microsoft.com/defender-office-365/threat-explorer-real-time-detections-about [verify 2026-04-27]
- Google Workspace — Email Log Search — https://support.google.com/a/answer/2604578 [verify 2026-04-27]
- Google Workspace — Workspace logs export to BigQuery — https://support.google.com/a/answer/9079365 [verify 2026-04-27]
- Mimecast — Tech Connect / API — https://www.mimecast.com/tech-connect/documentation/ [verify 2026-04-27]
- Proofpoint — Email Protection / Smart Search — https://www.proofpoint.com/us/products/email-security-and-protection [verify 2026-04-27]
- Cisco Secure Email — https://www.cisco.com/c/en/us/products/security/email-security/index.html [verify 2026-04-27]
- Barracuda Email Protection — https://www.barracuda.com/products/email-protection [verify 2026-04-27]

**FBI / IC3 / law-enforcement:**
- FBI IC3 — Internet Crime Complaint Center — https://www.ic3.gov
- FBI BEC public-service announcements (annual) — https://www.ic3.gov/Media/PSA [verify 2026-04-27]
- FBI Field Office locator — https://www.fbi.gov/contact-us/field-offices
- US Secret Service Field Offices — https://www.secretservice.gov/contact/field-offices
- FinCEN — https://www.fincen.gov
- FinCEN Rapid Response Program — search FinCEN for current program scope [verify 2026-04-27]
- US Treasury OFAC SDN list — https://sanctionssearch.ofac.treas.gov/
- NCSC (UK) — https://www.ncsc.gov.uk
- Action Fraud (UK) — https://www.actionfraud.police.uk
- Europol European Cybercrime Centre (EC3) — https://www.europol.europa.eu/about-europol/european-cybercrime-centre-ec3
- Australian Cyber Security Centre (ACSC) — https://www.cyber.gov.au [verify 2026-04-27]
- Canadian Anti-Fraud Centre — https://www.antifraudcentre-centreantifraude.ca [verify 2026-04-27]

**Banking and payments standards:**
- SWIFT — https://www.swift.com
- SWIFT GPI — https://www.swift.com/our-solutions/swift-gpi
- European Payments Council — https://www.europeanpaymentscouncil.eu (SEPA / SCT / SCT Inst rulebooks)
- NACHA Operating Rules — https://www.nacha.org/rules [verify 2026-04-27]
- Federal Reserve — Fedwire / FedNow — https://www.frbservices.org [verify 2026-04-27]

**Mail-authentication tooling and corpora:**
- parsedmarc — https://github.com/domainaware/parsedmarc [verify 2026-04-27]
- dnstwist — https://github.com/elceef/dnstwist
- urlcrazy — https://github.com/urbanadventurer/urlcrazy
- urlinsane — https://github.com/rangertaha/urlinsane
- crt.sh — https://crt.sh
- Censys — https://censys.io
- DKIMpy — https://launchpad.net/dkimpy [verify 2026-04-27]
- OpenDKIM — https://github.com/trusteddomainproject/OpenDKIM [verify 2026-04-27]
- pyspf — https://launchpad.net/pyspf [verify 2026-04-27]
- OpenARC — https://github.com/trusteddomainproject/OpenARC [verify 2026-04-27]
- DMARC.org — https://dmarc.org

**Phishing-kit / threat-intel:**
- PhishTank — https://phishtank.org
- OpenPhish — https://openphish.com
- URLScan.io — https://urlscan.io
- MITRE ATT&CK — Initial Access (Phishing T1566) — https://attack.mitre.org/techniques/T1566/
- MITRE ATT&CK — T1566.002 Spearphishing Link — https://attack.mitre.org/techniques/T1566/002/
- MITRE ATT&CK — T1534 Internal Spearphishing — https://attack.mitre.org/techniques/T1534/
- Cofense Intelligence — https://cofense.com [verify 2026-04-27]
- Akamai Hunt blog — https://www.akamai.com/blog [verify 2026-04-27]
- Google Threat Analysis Group — https://blog.google/threat-analysis-group/ [verify 2026-04-27]
- Microsoft Threat Intelligence — https://www.microsoft.com/security/blog/topic/threat-intelligence/ [verify 2026-04-27]
- Volexity — https://www.volexity.com/blog/ [verify 2026-04-27]
- Proofpoint Threat Insight — https://www.proofpoint.com/us/blog/threat-insight [verify 2026-04-27]
- Trustwave SpiderLabs blog — https://www.trustwave.com/en-us/resources/blogs/spiderlabs-blog/ [verify 2026-04-27]

**Reporting catalogues and case studies:**
- FBI IC3 Annual Internet Crime Report — annual — https://www.ic3.gov/Media/AnnualReport [verify 2026-04-27]
- Verizon DBIR — annual incident analysis (BEC / phishing breakouts each year) — https://www.verizon.com/business/resources/reports/dbir/
- Anti-Phishing Working Group (APWG) Phishing Activity Trends Report — https://apwg.org [verify 2026-04-27]
- Microsoft Digital Defense Report — annual — https://www.microsoft.com/security/business/microsoft-digital-defense-report [verify 2026-04-27]

**Training and certification:**
- SANS FOR509 — Enterprise Cloud Forensics and Incident Response (covers M365 / Workspace / SaaS surfaces relevant to BEC) [verify 2026-04-27]
- SANS FOR578 — Cyber Threat Intelligence
- SANS SEC504 — Hacker Tools, Techniques, and Incident Handling
- M3AAWG (Messaging, Malware and Mobile Anti-Abuse Working Group) — https://www.m3aawg.org [verify 2026-04-27]
- (ISC)² CCSP / CISSP — for broader IR / governance competence
- Microsoft — SC-200 / SC-400 (Security Operations Analyst / Information Protection Administrator)

---

**Version:** 1.0
**Last Updated:** 2026-04-27
**Review Frequency:** Quarterly (BEC TTPs, AiTM kit landscape, lookalike-domain registrar patterns, M365 / Workspace / SEG message-trace API field renames, and IC3 / FFKC threshold guidance evolve on a quarterly cadence; RFC-level SPF / DKIM / DMARC / ARC fundamentals and chain-of-custody discipline are slower)
