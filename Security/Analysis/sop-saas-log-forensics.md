---
type: sop
title: SaaS Log Forensics SOP
description: "SaaS-tenant identity and collaboration plane forensics: Microsoft 365 Unified Audit Log + Purview eDiscovery, Google Workspace Admin SDK Reports + Vault, Okta System Log + Identity Threat Protection, Slack Audit Logs + Discovery API, Salesforce Setup Audit Trail + Real-Time Event Monitoring, GitHub / GitLab audit logs, OAuth consent-grant abuse reconstruction, cross-tenant collaboration forensics (Slack Connect / Workspace external sharing / Entra ID B2B), inbox-rule and mailbox-audit forensics, retention-cliff and discovery-export discipline."
tags:
  - sop
  - saas-forensics
  - dfir
  - incident-response
  - m365
  - google-workspace
  - okta
  - slack
  - salesforce
  - github
  - oauth
created: 2026-04-27
updated: 2026-10-30
template_version: 2026-04-27
---

# SaaS Log Forensics SOP

> **Authorized environments only.** SaaS log forensics is a defensive discipline. This SOP covers post-incident evidence collection and analysis on tenants the investigator is authorized to access — incident response retainer scope, internal SOC / DFIR work on tenants the team owns, regulator-directed examinations under appropriate authority, or law-enforcement collection backed by warrant / MLAT / preservation letter. It does **not** authorize unauthorized tenant access, account take-overs, app-impersonation persistence, or pivoting into adversary infrastructure observed during the investigation. Cross-references: [[sop-legal-ethics|Legal & Ethics]] for jurisdictional framing and breach-notification clocks, [[sop-opsec-plan|OPSEC]] for investigator account hygiene during an active incident, [[sop-forensics-investigation|Digital Forensics Investigation]] as the parent template for host / disk / memory forensics methodology, [[../../Investigations/Techniques/sop-collection-log|Collection Log]] for chain-of-custody discipline on every exported audit-log file and discovery export, and [[sop-cloud-forensics|Cloud Forensics]] (sibling — IaaS-plane forensics) for hybrid incidents that span the cloud-provider control plane and the SaaS-tenant identity plane.

## Table of Contents

1. [Objectives & Scope](#1-objectives--scope)
2. [Pre-Engagement & Authorization](#2-pre-engagement--authorization)
3. [SaaS Forensics Landscape](#3-saas-forensics-landscape)
4. [Microsoft 365 — Unified Audit Log & Purview](#4-microsoft-365--unified-audit-log--purview)
5. [Google Workspace — Admin SDK Reports & Vault](#5-google-workspace--admin-sdk-reports--vault)
6. [Okta — System Log & Identity Threat Protection](#6-okta--system-log--identity-threat-protection)
7. [Slack — Audit Logs & Discovery](#7-slack--audit-logs--discovery)
8. [Salesforce — Setup Audit Trail & Event Monitoring](#8-salesforce--setup-audit-trail--event-monitoring)
9. [GitHub & GitLab — Audit Log Forensics](#9-github--gitlab--audit-log-forensics)
10. [OAuth Consent-Grant Abuse Forensics](#10-oauth-consent-grant-abuse-forensics)
11. [Cross-Tenant Forensics](#11-cross-tenant-forensics)
12. [Retention-Cliff & Discovery-Export Discipline](#12-retention-cliff--discovery-export-discipline)
13. [SaaS-Native IR Tooling](#13-saas-native-ir-tooling)
14. [Hand-off Boundaries](#14-hand-off-boundaries)
15. [Tools Reference](#15-tools-reference)
16. [Risks & Limitations](#16-risks--limitations)
17. [Common Pitfalls](#17-common-pitfalls)
18. [Real-World Scenarios](#18-real-world-scenarios)
19. [Related SOPs](#19-related-sops)
20. [External & Reference Resources](#20-external--reference-resources)

---

## 1. Objectives & Scope

SaaS log forensics is the discipline of reconstructing incidents from the audit, identity, collaboration, and content-access logs that SaaS application tenants emit. The deliverable is a defensible reconstruction of who signed in, what tokens were minted, what mail / files / messages / records were accessed, what configuration changed, and what data left the tenant — with chain-of-custody equivalent to disk forensics.

This SOP focuses on the dominant enterprise SaaS surfaces: **Microsoft 365 (Entra ID + Exchange Online + SharePoint / OneDrive + Teams + Purview)**, **Google Workspace (Cloud Identity + Gmail + Drive + Calendar + Chat + Meet + Vault)**, **Okta** (Workforce Identity + Okta Customer Identity) and **Auth0**, **Slack** (paid plans + Enterprise), **Salesforce** (Sales / Service / Experience Clouds), and **GitHub / GitLab** (org / enterprise audit). Smaller SaaS surfaces (Box, Dropbox, Atlassian, Zoom, ServiceNow, Workday, Zendesk, HubSpot, Notion, Asana, Airtable, etc.) follow recognizably similar patterns — admin audit, identity log, content-discovery export — but differ in API field names, retention defaults, and admin-permission models; treat per-vendor documentation as authoritative and apply the methodology in this SOP as the framing.

### What this SOP owns

- **M365 Unified Audit Log (UAL)** — `Search-UnifiedAuditLog` (Exchange Online PowerShell), Audit Search Graph API (`/security/auditLog/queries`), retention tiers (Audit (Standard) 180 days; Audit (Premium) 1 year for Entra / Exchange / SharePoint / OneDrive records, 180 days for other workloads unless a custom retention policy extends them; up to 10 years only with the 10-Year Audit Log Retention add-on), record-type taxonomy across Exchange / SharePoint / OneDrive / Teams / Entra / Defender / Purview workloads. [verify 2026-10-30]
- **Microsoft Purview / eDiscovery** — Compliance Search, eDiscovery (Standard) cases, eDiscovery (Premium) review sets, content-search export and chain-of-custody, in-place hold / litigation hold / retention policies.
- **Mailbox auditing** — Exchange Online mailbox audit log (default-on for owner / admin / delegate actions on most license tiers), `Search-UnifiedAuditLog -RecordType ExchangeItem` / `ExchangeItemGroup` / `ExchangeItemAggregated` (`Search-MailboxAuditLog` / `New-MailboxAuditLogSearch` are being deprecated in Exchange Online), mailbox-folder audit, M365 mailbox audit retention. [verify 2026-10-30]
- **Inbox-rule forensics** — `Get-InboxRule`, `Search-UnifiedAuditLog -Operations New-InboxRule,Set-InboxRule,Remove-InboxRule`, Workspace Gmail filter / forwarding enumeration (no documented per-user filter-creation audit event; `user_accounts` `email_forwarding_out_of_domain` is the documented forwarding event), forwarding-rule and DND/email-forward configuration events. [verify 2026-10-30]
- **Google Workspace Admin SDK Reports API** — login, drive, gmail, mobile, token, groups, admin, calendar, chat, meet, user_accounts, saml, jamboard, gplus, context_aware_access, rules, access_transparency, data_studio applications and their event names; retention semantics per category. [verify 2026-10-30]
- **Workspace Vault** — matter creation, hold creation, search, export, retention rules, audit of Vault administrator activity.
- **Workspace Gmail BigQuery export** — full mail-flow event stream beyond the Reports API window.
- **Okta System Log API** (`/api/v1/logs`) — 90-day default retention; Okta platform (Workforce Identity, Okta Customer Identity) vs Auth0 (separate platform, briefly branded Okta Customer Identity Cloud) tenant differences; Universal Directory event taxonomy; Identity Threat Protection (ITP) signal sources.
- **Slack** — Audit Logs API (Enterprise plan only — not available on Pro or Business+), Discovery API for message and file content, retention vs E-Discovery split, Slack Connect cross-organization shared channels.
- **Salesforce** — Setup Audit Trail (180-day window of admin / setup changes), Event Monitoring (Real-Time Event Monitoring add-on), Threat Detection (Salesforce Shield), Login History, API Total Usage.
- **GitHub Audit Log** — organization / enterprise audit (free for enterprise, retention varies), event taxonomy across `repo`, `org`, `team`, `oauth_application`, `personal_access_token`, `user`, `business`, `git`, `protected_branch`, `secret_scanning`, `code_scanning` categories; API + log-streaming.
- **GitLab Audit Events** — group / instance audit-event API, premium-tier requirement, retention.
- **OAuth consent-grant abuse forensics** — multi-tenant app drift, consent-event reconstruction, app-registration audit, attacker-app token persistence (the "OAuth-consent BEC" variant per the buildout-plan scope contract for the forensics trio).
- **Cross-tenant forensics** — Entra ID guest / B2B / cross-tenant access settings, Workspace external sharing, Slack Connect, Salesforce Experience Cloud / Communities, and the SaaS-side identity-federation surface (SAML / OIDC consumed *by* the SaaS app — distinct from [[sop-cloud-forensics|Cloud Forensics]] §3.3 / §7, which covers the IdP-provider side).
- **Retention-cliff and discovery-export discipline** — the dominant SaaS-forensics failure mode is "data was deleted before we could collect." This SOP elevates retention sampling and legal-hold mechanics to first-class concerns, separate from the per-vendor sections.

### Hard exclusions (out of scope)

- **IaaS / cloud-provider control plane.** AWS CloudTrail, Azure Activity Log + Resource Logs, GCP Cloud Audit Logs, IAM forensics on cloud resources, region-sweep, log-tampering detection on CloudTrail digest chains, container / Kubernetes runtime audit, and snapshot preservation of cloud volumes all live in [[sop-cloud-forensics|Cloud Forensics]]. The boundary is the resource the action targeted: if the action targeted SaaS application data (mail, file, message, record, repo), it lives here; if it targeted IaaS resources (VM, bucket, IAM role on a cloud resource, Kubernetes apiserver), it routes to [[sop-cloud-forensics|Cloud Forensics]]. Hybrid incidents — an Entra ID sign-in event that triggered both a mailbox-access action and an Azure-resource-plane action — are split across the two SOPs at the action level, with the identity event referenced from both sides.
- **Email header forensics / SPF / DKIM / DMARC / ARC / wire-recall / lookalike-domain BEC scenario reconstruction.** Routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. The deliberate trio split is: #7 cloud-forensics = IaaS plane, #8 saas-log-forensics = SaaS-tenant identity / collaboration plane (this SOP), #9 email-bec-forensics = scenario-centric BEC. **OAuth-consent BEC variant lives here**, per the user-confirmed scope contract: when the BEC pattern is "attacker tricks user into granting an OAuth app permission to read mailbox," the mailbox-token-persistence forensics belongs to #8; when the BEC pattern is "attacker spoofs a wire request via header / lookalike domain," the header-forensics belongs to #9 — see [[sop-email-bec-forensics|Email & BEC Forensics]].
- **Offensive SaaS pentesting.** Pre-engagement enumeration, identity-based privilege escalation, attacker-controlled multi-tenant app design, lateral movement via SaaS connectors, and exfil tradecraft route to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] §12 SaaS Collaboration Plane. Forensic readers benefit from understanding the offensive playbook as the threat model but should not derive offensive instructions from this SOP.
- **General host / disk / memory forensics.** Disk imaging, memory acquisition, MFT / USN / Prefetch / Amcache / ShimCache / registry-hive parsing, Volatility 3, and timeline construction all live in [[sop-forensics-investigation|Digital Forensics Investigation]] (parent template). When SaaS forensics produces an artifact that requires offline parsing (an exported PST that contains malware-bearing attachments; a downloaded Workspace Takeout archive; a Slack export with embedded files), the static / dynamic analysis routes to [[sop-malware-analysis|Malware Analysis]] and [[sop-reverse-engineering|Reverse Engineering]] as appropriate.
- **Smart-contract / on-chain forensics.** When SaaS-resident credentials (a leaked AWS access key in a SharePoint document, a wallet seed pasted in a Slack DM) lead to on-chain consequences, that surface is owned by [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]], [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]], and [[sop-smart-contract-audit|Smart Contract Audit]]; this SOP stops at "the credential was exfiltrated from the SaaS tenant."
- **Sensitive-crime hard-stops.** CSAM in OneDrive / SharePoint / Workspace Drive / Slack uploads / Salesforce Files; trafficking-pattern indicators in cross-tenant collaboration; threat-to-life findings — all hard-stop to [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]]. Treat as URL / file-hash / timestamp only; **do not preserve content**; provider-LE process is the route. Same posture as the darkweb and cloud-forensics SOPs.

### Engagement types covered

- **Incident response retainer.** Customer reports a credential phishing → mailbox compromise → mass-forwarding-rule pattern; retainer firm is engaged to reconstruct.
- **Internal SOC investigation.** SOC analyst pivots from a SIEM alert (Defender for Cloud Apps anomaly, Workspace alert, Okta ITP signal) into deep audit-log review.
- **Regulator-directed examination.** A regulator directs the tenant owner to produce evidence of access to specific records / mailboxes / Files; eDiscovery / Vault / Compliance Search outputs are the deliverable.
- **Law-enforcement collection.** LE investigation backed by warrant / MLAT / preservation letter — provider legal-process portals (Microsoft Online Services Legal Compliance, Google LERS, Slack Law Enforcement Information, Salesforce LE Guidelines, Okta Legal) are the route for cross-tenant evidence.
- **Insider-threat / data-loss investigation.** Departing-employee data-exfil reconstruction across mail / Drive / SharePoint / Slack DMs / GitHub repo clones.
- **Post-incident retrospective.** Months after containment, structured forensic reconstruction supporting lessons-learned, board reporting, insurance claim, or notification scoping.

---

## 2. Pre-Engagement & Authorization

### Authorization Checklist

- [ ] **Written engagement letter or internal IR activation** identifying the tenant(s) (M365 tenant ID + initial domain; Workspace primary domain + customer ID; Okta org URL; Slack workspace / Enterprise organization ID; Salesforce org ID + My Domain; GitHub org / enterprise slug), the time window of interest, and the scope of authorized actions (read-only audit-log pull? eDiscovery export? mailbox content review? user disablement? OAuth-app revocation?). State-changing actions in SaaS are billable, durable, and visible in the tenant's own audit log — written scope matters.
- [ ] **Tenant-administrator authorization** for read-only access to audit-log destinations and content. Use a dedicated investigator admin account / app-registration / API token per engagement — not a re-used personal identity — and rotate at engagement end. M365: dedicated cloud-only Global Reader + eDiscovery Manager / Reviewer roles (Global Reader cannot run `Get-InboxRule`, so §4.6 rule enumeration needs a separately authorized Exchange role). Workspace: dedicated investigator admin with Reports / Vault / Security Center roles, no super-admin unless required. Okta: Read-Only Admin or custom role scoped to System Log read. Slack: Org Owner with Audit Logs API token issued to the engagement. Salesforce: View Setup and Configuration / View Event Log Files / Manage Users-only profile, not System Administrator. GitHub: organization owner or audit-log-API token issued to the engagement. [verify 2026-10-30]
- [ ] **Provider legal process where the customer cannot authorize collection on their own** — for cross-tenant evidence (tenant A is suspect, tenant B is victim, both reside on the same provider) the provider's law-enforcement portal is the route. Microsoft, Google, Salesforce, Slack, and Okta publish LE guidelines and require subpoena / warrant / MLAT / preservation letter depending on data type and jurisdiction [verify 2026-10-30].
- [ ] **Cross-border data residency review.** EU data subjects, healthcare records (HIPAA), card data (PCI), and government tenants (GCC / GCC High / DOD; Workspace Assured Controls; Okta GovCloud) all carry residency / sovereignty constraints. Verify under counsel before exporting log or content data to investigator storage outside the source region — see [[sop-legal-ethics|Legal & Ethics]] for Schrems II / DPF / SCCs framing.
- [ ] **Disclosure pathway agreed.** Notification clocks are jurisdiction- and sector-specific — GDPR Art. 33 (72h to supervisory authority), GDPR Art. 34 (high-risk-to-data-subjects notice), HIPAA Breach Notification Rule (60-day), state breach-notification laws (US), SEC cyber-disclosure rule for material incidents at registrants, NYDFS Part 500, NIS2 (EU), DORA (EU financial). Verify per-incident under counsel.
- [ ] **CSP / SaaS-vendor support case opened where useful.** Microsoft IR (Microsoft Incident Response, formerly DART), Google Workspace Premium Support, Slack Enterprise support, Salesforce Signature Success, and Okta support can unlock collection paths (extended retention, archived logs, mailbox-recovery from cold) that customer-side tooling cannot. Open the case under an executive sponsor's identity, not the investigator's, so the audit trail attributes correctly.
- [ ] **OAuth-app inventory baseline established.** Before any state-changing action, snapshot the current OAuth-app inventory — multi-tenant apps consented in the tenant, app-only permissions granted, refresh-tokens active. This is the baseline against which post-incident OAuth-revocation actions are measured. M365: `Get-MgServicePrincipal`, `Get-MgOauth2PermissionGrant`, `Get-MgServicePrincipalAppRoleAssignment`. Workspace: Admin Console → Security → API Controls → App Access Control + connected apps export. Salesforce: Connected Apps Usage. GitHub: org-level OAuth Apps, GitHub Apps, and PATs. [verify 2026-10-30]

### Lab Environment Requirements

- **Dedicated investigator tenant or analyst seat** in each SaaS surface, separate from the affected tenant. Exports, hashed log artifacts, and analysis derivatives land here, never back into the affected tenant. The investigator's M365 / Workspace / Okta / Slack / Salesforce identity is engagement-scoped, not their personal cloud identity.
- **Investigator workstation** disk-encrypted, isolated from production, no auto-sync of artifacts to corporate storage, dedicated browser profiles or container tabs per tenant to avoid cross-tenant cookie / session leakage. PowerShell 7+ for Exchange Online / Microsoft Graph PowerShell SDK; `gcloud` + `gam` (GAM7) for Workspace; `okta-cli` / direct `curl` for Okta; `slackclient` Python or direct `curl` for Slack.
- **Encrypted-at-rest investigator storage.** Exported audit logs (often hundreds of MB to multi-GB), eDiscovery exports (often tens of GB), and Vault exports (potentially TB-scale on long-window matters) all encrypted with engagement-specific keys. Cross-region copy of the engagement bucket / storage account / Cloud Storage bucket for resilience.
- **Time-sync discipline.** All analysis systems running NTP / chrony to a known source; time-zone normalized to UTC end-to-end; investigator note timestamps use ISO 8601 / RFC 3339 with explicit `Z` suffix per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. SaaS providers report event times with mixed precision and time-zone hints — UAL `CreationTime` is UTC; Workspace Reports `id.time` is RFC 3339 UTC; Okta `published` is ISO 8601 UTC; Slack Audit Logs `date_create` is Unix epoch seconds; Salesforce `EventDate` / `LogDate` is ISO 8601 with timezone offset; GitHub `@timestamp` is Unix epoch milliseconds. [verify 2026-10-30]
- **API-throttling awareness.** Production SaaS tenants under stress can ratelimit aggressive forensic queries. UAL `Search-UnifiedAuditLog` returns 100 records by default and `-SessionCommand` is required for more (at most 5000 per call via `-ResultSize`); `-SessionId` with `-SessionCommand ReturnLargeSet` pages up to 50,000, and the Office 365 Management Activity API or the Audit Search Graph API (v1.0, asynchronous) suit programmatic bulk pulls [verify 2026-10-30]. Workspace Reports API has per-customer quota; use bulk export to BigQuery / Cloud Storage where possible. Okta System Log API enforces a rate limit per org and per token. Slack Audit Logs API has tier-1 / tier-2 / tier-3 / tier-4 method-class quotas. Salesforce REST / SOAP API has per-org daily limits.
- **Read-only by default.** Investigator tokens / roles should not include user-disablement, mailbox-modification, OAuth-app-revocation, repo-deletion, or content-modification permissions unless explicitly authorized. The forensic record is more defensible when state-changing actions are gated behind a separate, narrowly-scoped account.

### Disclosure-Ready Posture

SaaS-forensics findings frequently land with regulators, insurers, customers, or law enforcement. Stage the deliverable shape early:

- **Chain-of-custody record** opened at engagement start — every audit-log pull, every eDiscovery export, every Vault download, every API call recorded per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Hash every exported artifact (SHA-256 baseline) at the moment of export; record source-tenant ID, source-API endpoint, time range, executing principal, and destination URI.
- **Evidence-handling policy** decided before the first pull: retention period for engagement artifacts, encryption-at-rest standard, access list, deletion / handover discipline at engagement end.
- **Reporting timeline** agreed: interim notes (daily?), interim summary (weekly?), final report. SaaS incidents move fast; the regulator / customer / counsel may need an interim summary by day 2-3 even when full reconstruction will take weeks.
- **Disclosure pathway** for findings touching third parties — a compromised customer's credentials surfaced in a Slack message; a vendor's API token found in a SharePoint document; an upstream multi-tenant OAuth app abused to attack other tenants. Coordinate with [[sop-legal-ethics|Legal & Ethics]] and [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]].

---

## 3. SaaS Forensics Landscape

### 3.1 Why SaaS forensics is different from IaaS forensics

SaaS forensics shares the high-level discipline of [[sop-cloud-forensics|Cloud Forensics]] (audit logs are the highest-value evidence; retention is opt-in and fragile; chain-of-custody hashing applies at export) but differs in three structural ways:

1. **Identity is the resource.** In IaaS, the resource is a VM, a bucket, an IAM role, a Kubernetes namespace — the identity *acts on* a separate resource. In SaaS, the resource frequently *is* the identity (a mailbox, a Drive owner, a Slack DM channel, a Salesforce user record); the identity-and-resource boundary is collapsed. This makes "did this user access another user's mail?" the central forensic question, far more so than in IaaS.
2. **Content is in-band with the audit trail.** IaaS forensics rarely needs to read S3 object content; the access log is enough. SaaS forensics frequently must read mail / file / message content (eDiscovery, Vault, Discovery API) to answer "what was exfiltrated?" — and that content is often the most sensitive material in the tenant. The forensic discipline is closer to litigation-eDiscovery than to classical DFIR; chain-of-custody on content exports is non-negotiable.
3. **Retention is shorter and more provider-controlled.** IaaS-plane logs (CloudTrail, Activity Log, Cloud Audit Logs) have predictable, customer-configurable retention. SaaS-plane logs have shorter defaults (UAL 180-day Audit (Standard), Okta 90-day, Salesforce SAT 180-day), tier-gated extensions (UAL Audit (Premium) 1-year, 10-year with the add-on; Salesforce Real-Time Event Monitoring add-on), and hard floors below which the customer cannot pay for retention without an admin process (Workspace Reports per-application retention is Google-controlled, not customer-controlled). Retention sampling is not a luxury — it is a precondition to promising a reconstruction. [verify 2026-10-30]

### 3.2 SaaS Evidence Planes

SaaS forensic surfaces partition into five planes. Each has distinct artifacts, retention defaults, and forensic value.

| Plane | What it captures | Highest-value events | Default retention posture |
|---|---|---|---|
| **Identity** | Sign-in, MFA, federation, conditional access, session, token issuance / refresh, account-state changes | Suspicious sign-ins, MFA bypass, impossible travel, federated-IdP token consumption, OAuth token issuance | Short: Entra ID 7 days (Free) / 30 days (P1 / P2); Okta System Log 90 days; Auth0 1-30 days by plan. Consistently present across vendors [verify 2026-10-30] |
| **Activity** | Per-user, per-document, per-message access — read, edit, share, send, download, delete | Mailbox access by non-owner, mass file download, mass DM access, mass repo clone, mass record export | Variable: opt-in for Data Access in some vendors; enabled by default for some others |
| **Content** | Actual mail / file / message / record content (separate from access metadata) | Content of suspect messages, attached files, shared documents | Indefinite (until user-deleted), but discoverable only via eDiscovery / Vault / Discovery API |
| **Configuration** | Tenant settings, role assignments, OAuth-app installations, SSO configuration, retention policies | Role escalation, MFA-policy changes, conditional-access bypass added, OAuth-app installed, retention-policy reduced | Variable by vendor; usually 6-24 months |
| **Device-trust** | MDM enrollment / posture / compliance, BYOD identity, app-protection policies | Sign-in from unmanaged device, jailbroken / rooted device, device-compliance bypass | Variable; tied to MDM platform retention rather than SaaS audit |

Most SaaS-forensics work depends on the **identity** and **activity** planes; **content** is reached through eDiscovery / Vault / Discovery only when the access metadata indicates a need; **configuration** changes are the highest-signal indicators of attacker persistence; **device-trust** correlates the identity event to a physical or policy-violating device.

### 3.3 The Retention-Cliff Problem

The dominant SaaS-forensics failure mode is "data was deleted before we could collect." Default retentions across the major vendors:

| Vendor | Surface | Default retention | Long-term option |
|---|---|---|---|
| Microsoft 365 | Unified Audit Log (E3 / E5 baseline) | **180 days** with Audit (Standard) | Audit (Premium): **1 year** for Entra / Exchange / SharePoint / OneDrive records (180 days for other workloads unless a custom retention policy extends them); up to **10 years** only with the 10-Year Audit Log Retention add-on. `MailItemsAccessed` and `Send` are Audit (Standard) events; Premium adds intelligent-insight properties (e.g. `SensitivityLabel` on `MailItemsAccessed`) and the `SearchQueryInitiatedExchange` / `SearchQueryInitiatedSharePoint` search events [verify 2026-10-30] |
| Microsoft 365 | Mailbox audit log (per-mailbox) | Held in the UAL under Purview Audit retention: **180 days** (Standard); **1 year** for Exchange records with Audit (Premium) | Audit log retention policies (up to 10 years with the add-on); `AuditLogAgeLimit` no longer applies to retention [verify 2026-10-30] |
| Microsoft 365 | Defender for Cloud Apps (formerly MCAS) activities | **180 days** [verify 2026-10-30] | Continuous report export, Sentinel ingest |
| Microsoft 365 | Entra ID sign-in and audit logs | **7 days** (Entra ID Free); **30 days** with P1 / P2 (risky sign-ins: 90 days with P2) [verify 2026-10-30] | Diagnostic-settings export to Log Analytics workspace, Event Hub, or Storage Account |
| Google Workspace | Reports API (most applications) | **6 months** [verify 2026-10-30] | BigQuery / Cloud Storage export via Workspace logs export to GCP; some applications have application-specific defaults |
| Google Workspace | Vault retention policies (when configured) | Per-policy (admin-set; can be indefinite) [verify 2026-10-30] | N/A — Vault is the long-term option |
| Okta | System Log | **90 days** (Okta platform: Workforce Identity and Okta Customer Identity); Auth0 (separate platform, briefly branded Okta Customer Identity Cloud): 1-30 days by plan [verify 2026-10-30] | Log Streaming to Amazon EventBridge or Splunk Cloud, or a SIEM that polls the System Log API |
| Slack | Audit Logs (Enterprise plan) [verify 2026-10-30] | Not documented in Slack's Audit Logs API reference; treat as undefined | Continuous SIEM ingest; Discovery API for content (separate retention model) |
| Slack | Discovery API (content) | Tied to message-retention policy; defaults workspace-set | Legal hold (UI or Legal Holds API); held data read via Discovery API or JSON export |
| Salesforce | Setup Audit Trail | **180 days** [verify 2026-10-30] | Field Audit Trail (Salesforce Shield add-on) extends per-field history to **10 years** |
| Salesforce | Login History | **6 months** [verify 2026-10-30] | Real-Time Event Monitoring (Shield add-on) provides 10K records / streaming / longer retention |
| Salesforce | Real-Time Event Monitoring | Storage events kept up to 6 months (`LoginEvent` and `IdentityVerificationEvent`: up to 10 years); streaming events up to 3 days [verify 2026-10-30] | N/A — already long-term |
| GitHub | Audit log (org / enterprise) | **180 days** (Git events: 7 days) [verify 2026-10-30] | Audit log streaming to Splunk / Datadog / Azure Event Hubs / AWS S3 / Google Cloud Storage |
| GitLab | Instance / group audit events | Group / project / instance audit events need Premium or Ultimate (successful sign-in events at all tiers); GitLab documents audit events as retained indefinitely [verify 2026-10-30] | Self-managed: customer-controlled retention via PostgreSQL; SaaS: GitLab-controlled |

**Practical implication.** SaaS-tenant compromises are often discovered after some default retention windows have expired, so long-tail incidents with missing evidence are routine. The first pre-engagement question is *not* "what happened?" — it is "what evidence exists?" Customers without long-term audit-log export (UAL Premium, Workspace logs to BigQuery, Slack SIEM ingest, Salesforce Shield, GitHub log streaming) lose evidence to retention silently.

### 3.4 Per-Tenant Terminology Crosswalk

Cross-vendor incidents demand a shared vocabulary. The same concept gets different names per SaaS surface:

| Concept | Microsoft 365 | Google Workspace | Okta | Slack | Salesforce | GitHub |
|---|---|---|---|---|---|---|
| Tenant boundary | Tenant (Entra ID + initial domain) | Customer (Cloud Identity + primary domain) | Org (`<org>.okta.com`) | Workspace / Enterprise org [verify 2026-10-30] | Org (`<MyDomain>.my.salesforce.com`) | Organization / Enterprise |
| User identity | UPN / Object ID | Primary email / User ID | User ID (Okta UID) | User ID (`U0…`) | User ID (`005…`) | Username / User ID |
| Service identity | Service principal / managed identity | Service account | OAuth client / API service app | App / bot user | Connected App / Named Credential | OAuth App / GitHub App / PAT / Deploy Key |
| Sign-in audit | Entra ID sign-in logs (interactive / non-interactive / sp / mi) | Reports API `login` application | System Log `user.session.start` | Audit Logs `user_login` [verify 2026-10-30] | Login History | Account security log `user.login` / `user.failed_login` (not in the org / enterprise audit log) |
| Admin / config audit | Entra ID audit logs + UAL `Workload = AzureActiveDirectory` [verify 2026-10-30] | Reports API `admin` | System Log `system.…` events | Audit Logs `workspace.*`, `org.*` | Setup Audit Trail | Audit Log `org.*`, `enterprise.*` |
| Content access | UAL Exchange / SharePoint / OneDrive operations | Reports API `drive`, `gmail`, `chat` | N/A (identity-only) | Discovery API | RTEM `ApiEvent`, `BulkApiResultEvent`, `ReportEvent` [verify 2026-10-30] | Audit Log `git.*`, `repo.*` |
| eDiscovery / hold | Purview eDiscovery (Standard + Premium) | Vault | N/A | Discovery API | Field Audit Trail | N/A |
| OAuth-app inventory | Service Principals + `oauth2PermissionGrants` | Connected apps + `tokens` | OAuth clients | Apps | Connected Apps | OAuth Apps + Apps + PATs |
| Cross-tenant collaboration | B2B / guest accounts; cross-tenant access settings | External sharing; trusted domains | Hub-and-spoke (Workforce); B2B (Customer) | Slack Connect | Experience Cloud / Communities | Outside collaborators; org cross-references |

---

## 4. Microsoft 365 — Unified Audit Log & Purview

The M365 ecosystem is the single largest SaaS-forensic surface for most enterprises. The Unified Audit Log (UAL) is the canonical event store; mailbox audit, Entra ID sign-in / audit, Defender for Cloud Apps, and Purview eDiscovery / Compliance Search round out the toolkit.

### 4.1 UAL Retention Tiers

| Tier | Default retention | Notable extra events |
|---|---|---|
| **Audit (Standard)** — included with Microsoft 365 E3 / E5, A1 / A3 / A5, G3 / G5, F1 / F3; Office 365 E1 / E3 / E5; Microsoft 365 Business Basic / Standard / Premium | **180 days** of UAL events [verify 2026-10-30] | Baseline UAL — sign-in, mailbox (including `Send`, and `MailItemsAccessed` on by default for E3 / E5 users), SharePoint / OneDrive activity, Entra ID directory changes, Teams meetings, etc. |
| **Audit (Premium)** — Microsoft 365 / Office 365 E5, A5, G5; Microsoft Purview Suite (incl. EDU / GOV / FLW); Microsoft 365 E5 / G5 / F5 eDiscovery & Audit add-on | **1 year** for Entra / Exchange / SharePoint / OneDrive records; 180 days for other workloads; custom retention policies up to 10 years only for users with the 10-Year Audit Log Retention add-on [verify 2026-10-30] | Adds the `SearchQueryInitiatedExchange` / `SearchQueryInitiatedSharePoint` search events, intelligent-insight properties (`SensitivityLabel` on `MailItemsAccessed`, Teams `AppAccessContext`), custom audit-log retention policies, and higher-bandwidth Office 365 Management Activity API access. |

> **Operational rule.** `MailItemsAccessed` is available to E3 (Audit (Standard)) tenants, so "what mail did the attacker read?" is usually answerable from the UAL. The limiting factor is retention (180 days under Standard vs 1 year for Exchange records under Premium), not event availability; record the retention window in the report rather than overstating evidence [verify 2026-10-30].

### 4.2 Search-UnifiedAuditLog (Exchange Online PowerShell)

The legacy synchronous cmdlet — still the workhorse for ad-hoc investigations under ~50K records per query. Connect with the modern Exchange Online PowerShell module (V3 or later) using a service-principal or interactive auth.

```powershell
# Modern connect (V3+, with certificate-based service-principal auth recommended for repeatable use) [verify 2026-10-30]
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName <admin>@<tenant>.onmicrosoft.com -ShowBanner:$false

# Window-bounded UAL search (UTC). 100 records by default; -SessionCommand is required for more
# (ReturnLargeSet pages up to 50,000, unsorted). Repeat the session until it returns nothing. [verify 2026-10-30]
$sid = "case-$([guid]::NewGuid())"
$results = do {
    $page = Search-UnifiedAuditLog `
        -StartDate (Get-Date "2026-04-01T00:00:00Z") `
        -EndDate (Get-Date "2026-04-27T00:00:00Z") `
        -UserIds "<suspect-upn>@<tenant>.com" `
        -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000 `
        -Formatted
    $page
} while ($page)

# Operations filter — common high-value operations. Entra (AzureActiveDirectory) operation names
# end with a period, which must be kept inside the quotes. Same session loop as above. [verify 2026-10-30]
$sid = "case-ops-$([guid]::NewGuid())"
$byOp = do {
    $page = Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
        -Operations "New-InboxRule","Set-InboxRule","UpdateInboxRules","MailboxLogin","Send","MailItemsAccessed","FileAccessed","FileDownloaded","Add-MailboxPermission","Add app role assignment to service principal.","Consent to application." `
        -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000
    $page
} while ($page)

# Record-type filter (workload-scoped). -RecordType takes a single value, so run one session per type and
# repeat it until it returns nothing (ReturnLargeSet: unsorted, max 50,000 per session). [verify 2026-10-30]
$byType = foreach ($rt in 'ExchangeItem','SharePointFileOperation','AzureActiveDirectory','MicrosoftTeams') {
    $sid = "case-$rt-$([guid]::NewGuid())"
    do {
        $page = Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
            -RecordType $rt -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000
        $page
    } while ($page)
}

# Output to file with chain-of-custody hash [verify 2026-10-30]
$results | Export-Csv -NoTypeInformation -Path "ual-2026-04-01-to-2026-04-27.csv"
Get-FileHash -Algorithm SHA256 ual-2026-04-01-to-2026-04-27.csv | Format-List
```

**Pagination caveat.** The paged mode (`-SessionId <id> -SessionCommand ReturnLargeSet`) is the only way to retrieve more than 5000 results per query window via the cmdlet; it returns unsorted results and caps out at 50,000 per session. Mixing `ReturnLargeSet` and `ReturnNextPreviewPage` on one session ID limits output to 10,000. For windows known to contain >50K records, split the window or use the Audit Search Graph API (§4.3) [verify 2026-10-30].

### 4.3 Audit Search Graph API (Asynchronous Queries)

The Audit Search Graph API (`auditLogQuery`, v1.0) is available with both Audit (Standard) and Audit (Premium). It is asynchronous: create a query, poll its status, then page the records. For continuous programmatic export Microsoft recommends the Office 365 Management Activity API [verify 2026-10-30].

```bash
# Endpoint (v1.0, GA; beta also available) [verify 2026-10-30]
# POST https://graph.microsoft.com/v1.0/security/auditLog/queries
# GET  https://graph.microsoft.com/v1.0/security/auditLog/queries/{id}
# GET  https://graph.microsoft.com/v1.0/security/auditLog/queries/{id}/records

# Required app permissions (admin consent): AuditLogsQuery.Read.All, or the workload-scoped permission that matches the records queried (e.g. AuditLogsQuery-Exchange.Read.All for MailItemsAccessed / inbox-rule records) [verify 2026-10-30]

# Step 1: Create a query [verify 2026-10-30]
curl -X POST 'https://graph.microsoft.com/v1.0/security/auditLog/queries' \
  -H "Authorization: Bearer $GRAPH_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "displayName": "case-2026-04-27 forensic UAL pull",
    "filterStartDateTime": "2026-04-01T00:00:00Z",
    "filterEndDateTime": "2026-04-27T00:00:00Z",
    "userPrincipalNameFilters": ["<suspect-upn>@<tenant>.com"],
    "operationFilters": ["MailItemsAccessed","Send","New-InboxRule","Set-InboxRule"]
  }'

# Step 2: Poll status (status transitions: notStarted -> running -> succeeded | failed | cancelled) [verify 2026-10-30]
curl 'https://graph.microsoft.com/v1.0/security/auditLog/queries/<query-id>' \
  -H "Authorization: Bearer $GRAPH_TOKEN"

# Step 3: when status == succeeded, check the query's isRecordCountLimitExceeded (true = truncated; split the window), then page records following @odata.nextLink until it is absent [verify 2026-10-30]
curl 'https://graph.microsoft.com/v1.0/security/auditLog/queries/<query-id>/records' \
  -H "Authorization: Bearer $GRAPH_TOKEN"
```

The Graph API endpoint, request shape, and permission scopes are versioned and documented at `learn.microsoft.com/graph/api/resources/security-auditlogquery` [verify 2026-10-30] — confirm current shape per engagement before scripting against it.

### 4.4 UAL Record-Type Taxonomy

UAL events are categorized by `RecordType`. Major workloads and their high-value record types:

| Workload | RecordType examples | High-value operations |
|---|---|---|
| Exchange Online | `ExchangeAdmin`, `ExchangeItem`, `ExchangeItemGroup`, `ExchangeItemAggregated`, `ExchangeAggregatedOperation` | `MailItemsAccessed`, `Send`, `New-InboxRule`, `Set-InboxRule`, `UpdateInboxRules`, `MoveToDeletedItems`, `HardDelete`, `Add-MailboxPermission`, `Set-Mailbox`, `Add-MailboxFolderPermission` [verify 2026-10-30] |
| SharePoint / OneDrive | `SharePointFileOperation`, `SharePointSharingOperation`, `SharePoint`, `SharePointListOperation` | `FileAccessed`, `FileDownloaded`, `FileSyncDownloadedFull`, `FileModified`, `FileDeleted`, `SharingInvitationCreated`, `AnonymousLinkCreated`, `SecureLinkCreated` [verify 2026-10-30] |
| Microsoft Teams | `MicrosoftTeams`, `MicrosoftTeamsAdmin`, `MicrosoftTeamsAnalytics`, `MicrosoftTeamsShifts` | `MessageSent`, `MessageRead`, `MeetingDetail`, `MeetingParticipantDetail`, `TeamCreated`, `MemberAdded`, `MemberRemoved`, `BotAddedToTeam`, `AppInstalled` [verify 2026-10-30] |
| Microsoft Entra ID | `AzureActiveDirectory`, `AzureActiveDirectoryStsLogon` (`AzureActiveDirectoryAccountLogon` is deprecated) | `Add app role assignment to service principal.`, `Consent to application.`, `Add service principal.`, `Update service principal.`, `Add member to role.`, `Add owner to application.` (UAL keeps the trailing period on Entra operation names) [verify 2026-10-30] |
| Defender for Cloud Apps (formerly MCAS) | `MCASAlerts` [verify 2026-10-30] | Anomaly-detection triggers, malware-detection events, suspicious-OAuth-app alerts |
| Defender for Office 365 / EOP | `ThreatIntelligence`, `ThreatIntelligenceUrl`, `ThreatIntelligenceAtpContent` [verify 2026-10-30] | Phishing / malware detections, Safe Links block and override events |
| Microsoft Purview | `ComplianceDLPSharePoint`, `ComplianceDLPExchange`, `ComplianceSupervisionExchange`, `Discovery`, `DataInsightsRestApiAudit` [verify 2026-10-30] | DLP rule matches, supervision review actions, eDiscovery search / export operations |
| Power Platform | `PowerAppsApp`, `PowerAppsPlan`, `PowerBIAudit` (covers Power BI dataset activity), `MicrosoftFlow` [verify 2026-10-30] | App creation / sharing, dataset access, Flow execution (high signal for OAuth-bound exfil scenarios) |

The full canonical list of `RecordType` values and `Operations` is documented at `learn.microsoft.com/purview/audit-log-activities` [verify 2026-10-30]; refresh per engagement.

### 4.5 Mailbox Audit Log

Per-mailbox auditing has been default-on since 2019 for owner / admin / delegate actions on most M365 plans [verify 2026-10-30]. Default-audited owner actions include `MailItemsAccessed`, `Send`, `SoftDelete`, `HardDelete`, `MoveToDeletedItems`, `Update`, `UpdateFolderPermissions`, `UpdateInboxRules`. Default-audited delegate / admin actions include `SendAs`, `SendOnBehalf`, `Create`, `MailItemsAccessed`.

```powershell
# Search-MailboxAuditLog / New-MailboxAuditLogSearch are being deprecated in Exchange Online in favour of
# Search-UnifiedAuditLog. Mailbox audit records sit in the UAL as ExchangeItem (single item),
# ExchangeItemGroup (multi-item) and ExchangeItemAggregated (MailItemsAccessed). [verify 2026-10-30]
# One session per type, repeated until it returns nothing (ReturnLargeSet: unsorted, max 50,000 per session).
$mbx = foreach ($rt in 'ExchangeItem','ExchangeItemGroup','ExchangeItemAggregated') {
    $sid = "mbx-$rt-$([guid]::NewGuid())"
    do {
        $page = Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
            -RecordType $rt -UserIds <upn>@<tenant>.com `
            -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000
        $page
    } while ($page)
}

# Inspect mailbox audit configuration. Org level first: AuditDisabled False = mailbox auditing on [verify 2026-10-30]
Get-OrganizationConfig | Format-List AuditDisabled
Get-Mailbox -Identity <upn> | Format-List Audit*,DefaultAuditSet
# Output of interest: AuditEnabled (always True while org-level default auditing is on), DefaultAuditSet,
# AuditOwner, AuditDelegate, AuditAdmin. AuditLogAgeLimit no longer governs retention (Purview audit retention does). [verify 2026-10-30]
```

### 4.6 Inbox-Rule Forensics

Mailbox inbox rules are the canonical BEC-pivot persistence primitive. The attacker, once in possession of credentials or a session token, creates a rule that auto-forwards / auto-deletes / moves-to-archive specific messages (e.g., wire-confirmation requests from the CFO). UAL captures every rule-creation and rule-modification event.

```powershell
# Hunt for inbox-rule creation in window; repeat the session until it returns nothing [verify 2026-10-30]
$sid = "rules-$([guid]::NewGuid())"
do {
    $page = Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
        -Operations New-InboxRule,Set-InboxRule,Remove-InboxRule,Disable-InboxRule,UpdateInboxRules `
        -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000
    $page | Select-Object CreationDate,UserIds,Operations,AuditData
} while ($page)

# Enumerate current rules on a suspect mailbox [verify 2026-10-30]
Get-InboxRule -Mailbox <upn>@<tenant>.com | `
    Format-List Identity,Name,Description,Enabled,Priority,RedirectTo,ForwardTo,ForwardAsAttachmentTo,DeleteMessage,MoveToFolder,MarkAsRead,FromAddressContainsWords,SubjectContainsWords,BodyContainsWords

# Hidden-rule forensics — attacker-created rules with whitespace-only or unicode-zero-width names are common evasion;
# -IncludeHidden returns hidden rules (-BypassScopeCheck only skips the caller's RBAC scope check) [verify 2026-10-30]
Get-InboxRule -Mailbox <upn> -IncludeHidden | Where-Object { [string]::IsNullOrWhiteSpace($_.Name) -or $_.Name -match '^[\s\u200B-\u200D\uFEFF]+$' }
```

**Indicators of malicious rule creation:**

- Forward-to-external-domain rule (`ForwardTo`, `RedirectTo`) targeting a mailbox at a domain the user has no legitimate correspondence with.
- Move-to-RSS-Feeds / Move-to-Archive / Move-to-Junk rule scoped to specific keywords (`wire`, `invoice`, `payment`, `bank`, `confirm`) — pattern is "hide the legitimate confirmation from the user."
- Mark-as-read + delete-permanently combination.
- Rule name that is whitespace, single character, zero-width unicode, or otherwise designed to be invisible in the Outlook GUI.
- Rule created from a sign-in event whose source IP / user agent does not match the user's historical pattern — correlate with §4.2 sign-in logs.

### 4.7 Microsoft Purview / eDiscovery

Purview eDiscovery (Standard) is included with Microsoft 365 / Office 365 E3 / E5 / G3 / G5 plans; eDiscovery (Premium) needs E5 / A5 / G5, Microsoft Purview Suite, or the E5 eDiscovery & Audit add-on. Microsoft retired the classic eDiscovery experiences (classic Content Search, eDiscovery (Standard) and eDiscovery (Premium)) on 31 August 2025; cases and searches now run in the unified Purview eDiscovery experience [verify 2026-10-30]. The forensic capability stack:

- **Compliance Search** — search across Exchange mailboxes, SharePoint / OneDrive sites, Teams chats, Yammer / Viva Engage. Returns hit counts and statistics; export requires escalation to eDiscovery.
- **eDiscovery (Standard) cases** — case-scoped searches with custodian assignment, hold management, and export to PST / standard-eDiscovery format.
- **eDiscovery (Premium) cases** — adds review sets (parsed, deduped, threaded content), advanced indexing, ML-driven relevance scoring, transparent-litigation-hold notifications, and forensic-export packages.
- **In-place hold / litigation hold / retention policies** — preservation mechanisms that prevent end-user or admin deletion within the hold scope.

```powershell
# Connect to Security & Compliance PowerShell (separate endpoint from Exchange Online). In the cloud,
# New-ComplianceCase / New-ComplianceSearch need ExchangeOnlineManagement 3.9.0+ and -EnableSearchOnlySession. [verify 2026-10-30]
Connect-IPPSSession -UserPrincipalName <admin>@<tenant>.onmicrosoft.com -EnableSearchOnlySession

# Create an eDiscovery (Standard) case [verify 2026-10-30]
New-ComplianceCase -Name "Case-2026-04-27-Forensic" -CaseType eDiscovery

# Place the custodian (mailbox + OneDrive) on hold: the policy names the locations, the rule applies the hold [verify 2026-10-30]
New-CaseHoldPolicy -Name "Case-2026-04-27-Hold" -Case "Case-2026-04-27-Forensic" `
    -ExchangeLocation <suspect-upn>@<tenant>.com `
    -SharePointLocation https://<tenant>-my.sharepoint.com/personal/<suspect-upn-tokenized>
New-CaseHoldRule -Name "Case-2026-04-27-HoldRule" -Policy "Case-2026-04-27-Hold"

# Create a search inside the case (-Case associates it; keep spaces out of -Name when using -Case) [verify 2026-10-30]
New-ComplianceSearch -Name "Case-2026-04-27-Search" -Case "Case-2026-04-27-Forensic" `
    -ExchangeLocation <suspect-upn>@<tenant>.com `
    -ContentMatchQuery '(Sent>=2026-04-01) AND (Sent<=2026-04-27)'

Start-ComplianceSearch -Identity "Case-2026-04-27-Search"

# Export: New-ComplianceSearchAction -Export is functional only in on-premises Exchange since the
# May 2025 Purview eDiscovery changes. In Microsoft 365, export from the case in the Purview portal or via the
# Graph v1.0 eDiscovery API (ediscoverySearch: exportResult; ediscoveryReviewSet: export). [verify 2026-10-30]
```

### 4.8 Compliance Search & Content-Search Export

For non-case-scoped quick searches (e.g., "find all emails containing this IOC across the tenant"):

```powershell
# Tenant-wide compliance search (no case scope; useful for IOC sweeping) [verify 2026-10-30]
New-ComplianceSearch -Name "IOC-Sweep-2026-04-27" `
    -ExchangeLocation All -SharePointLocation All `
    -ContentMatchQuery '"<suspect-domain>" OR "<suspect-attachment-hash>"'

Start-ComplianceSearch -Identity "IOC-Sweep-2026-04-27"

# Result counts (hit counts only; no content) [verify 2026-10-30]
Get-ComplianceSearch -Identity "IOC-Sweep-2026-04-27" | Format-List Items,Size

# Preview / export when content is needed: New-ComplianceSearchAction -Preview / -Export are functional only in
# on-premises Exchange; in Microsoft 365 preview and export in the Purview eDiscovery experience or via Graph. [verify 2026-10-30]
```

**Chain-of-custody for content exports.** Every Purview / eDiscovery export package includes a manifest and a hash. Hash the export package itself at receipt (SHA-256), record source-tenant ID, executing-admin UPN, search query, time range, and item / size counts in [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Treat the export as evidence equivalent to a disk image — read-only, encrypted at rest, access-controlled.

### 4.9 Defender for Cloud Apps (Formerly MCAS)

Defender for Cloud Apps surfaces SaaS-app activity, anomaly detection, and OAuth-app risk scoring. Findings live in the Microsoft Defender portal and are queryable via advanced hunting (KQL) [verify 2026-10-30]:

```kusto
// Suspicious sign-in activity (DCA cross-source). Filter on Application names; list the tenant's
// ApplicationId values with: CloudAppEvents | distinct Application, ApplicationId  [verify 2026-10-30]
CloudAppEvents
| where Timestamp > ago(30d)
| where Application has_any ("Exchange", "SharePoint", "Teams")
| where ActionType in ("MailItemsAccessed", "FileDownloaded", "MessageRead")
| where AccountObjectId == "<suspect-objectid>"
| project Timestamp, Application, ApplicationId, ActionType, AccountObjectId, IPAddress, Isp, City, CountryCode

// OAuth-app anomaly findings [verify 2026-10-30]
AlertInfo
| where Timestamp > ago(30d)
| where ServiceSource == "Microsoft Defender for Cloud Apps"
| where Title contains "OAuth"
```

DCA's `MailItemsAccessed` cross-source signal is **distinct from** the UAL `MailItemsAccessed` event; both should be collected when investigating mailbox compromise. DCA's strength is correlating across applications and surfacing risk-scored anomalies; UAL's strength is per-event ground truth.

---

## 5. Google Workspace — Admin SDK Reports & Vault

The Workspace audit surface is the Admin SDK Reports API (`admin.googleapis.com/admin/reports/v1/`), supplemented by Workspace Vault for content discovery / hold and Gmail BigQuery export for full mail-flow visibility. [verify 2026-10-30]

### 5.1 Reports API Event Categories

The Reports API exposes per-application activity feeds. Each `applicationName` has its own event taxonomy:

| `applicationName` | Coverage | High-value events |
|---|---|---|
| `login` | User sign-in, suspicious sign-in, MFA challenges | `login_success`, `login_failure`, `login_challenge`, `suspicious_login`, `2sv_disable`, `2sv_enroll`, `account_disabled_password_leak` [verify 2026-10-30] |
| `admin` | Super-admin and delegated-admin actions on the directory | `CHANGE_PASSWORD`, `GRANT_ADMIN_PRIVILEGE`, `REVOKE_ADMIN_PRIVILEGE`, `GRANT_DELEGATED_ADMIN_PRIVILEGES`, `ASSIGN_ROLE`, `UNASSIGN_ROLE`, `USER_LICENSE_ASSIGNMENT`, `USER_LICENSE_REVOKE`, `CREATE_USER`, `DELETE_USER`, `UNDELETE_USER`, `CHANGE_PRIMARY_DOMAIN`, `ADD_DOMAIN_ALIAS`, `AUTHORIZE_API_CLIENT_ACCESS`, `REMOVE_API_CLIENT_ACCESS`, `ADD_TO_TRUSTED_OAUTH2_APPS`, `ALLOW_SERVICE_FOR_OAUTH2_ACCESS` [verify 2026-10-30] |
| `drive` | File create / view / edit / share / download / move / trash | `view`, `download`, `edit`, `change_acl_editors`, `change_user_access`, `add_to_folder`, `create`, `move`, `trash`, `untrash`, `print`, `change_document_visibility` [verify 2026-10-30] |
| `gmail` | Per-message delivery events | `eventName` is always `delivery`; the event type is in `event_info.mail_event_type`. `startTime` and `endTime` are required and at most 30 days apart [verify 2026-10-30] |
| `mobile` | MDM / device-management events | `DEVICE_REGISTER_UNREGISTER_EVENT`, `DEVICE_ACTION_EVENT` (wipe shows in `ACTION_TYPE`), `FAILED_PASSWORD_ATTEMPTS_EVENT`, `DEVICE_COMPROMISED_EVENT`, `SUSPICIOUS_ACTIVITY_EVENT` [verify 2026-10-30] |
| `token` | OAuth / API client authorizations | `authorize`, `revoke`, `request` (failure); user-granted scope reflects in `scope_data` [verify 2026-10-30] |
| `groups` | Group create / delete / membership changes | `create_group`, `delete_group`, `add_user`, `remove_user`, `invite_user`, `change_acl_permission` [verify 2026-10-30] |
| `calendar` | Event create / modify / delete; access controls | `create_event`, `change_event_*`, `delete_event` [verify 2026-10-30] |
| `chat` | Google Chat (formerly Hangouts Chat) message and room events | `message_posted`, `message_deleted`, `message_edited`, `room_created`, `add_room_member`, `remove_room_member`, `direct_message_started`, `attachment_download` [verify 2026-10-30] |
| `meet` | Google Meet call records | `call_ended`, `recording_activity`, `broadcast_activity`, `livestream_watched` [verify 2026-10-30] |
| `user_accounts` | User-initiated account-self-service events (password changes, recovery info edits) | `password_edit`, `recovery_email_edit`, `recovery_phone_edit`, `2sv_enroll`, `2sv_disable`, `email_forwarding_out_of_domain` [verify 2026-10-30] |
| `saml` | SAML sign-in events (when Workspace is the SAML SP for third-party IdP) | `login_success`, `login_failure` for SAML-routed sign-ins [verify 2026-10-30] |
| `access_transparency` | Google-side admin access events (when GAT is licensed) | Google support / admin access to customer data with justification codes |
| `data_studio` | Looker Studio (formerly Data Studio) sharing / access | `VIEW`, `EDIT`, `DATA_EXPORT`, `DOWNLOAD_REPORT`, `CHANGE_USER_ACCESS`, `CHANGE_ASSET_LINK_SHARING_VISIBILITY` [verify 2026-10-30] |
| `gplus`, `jamboard`, `gcp`, etc. | Application-specific event feeds | Per-application docs |

```bash
# OAuth: requires admin user impersonation OR a service account with domain-wide delegation
# Required scope: https://www.googleapis.com/auth/admin.reports.audit.readonly [verify 2026-10-30]

# Login events for a user in the window [verify 2026-10-30]
curl -s -H "Authorization: Bearer $GOOGLE_ADMIN_TOKEN" \
  "https://admin.googleapis.com/admin/reports/v1/activity/users/<suspect-email>/applications/login?startTime=2026-04-01T00:00:00Z&endTime=2026-04-27T00:00:00Z" \
  | jq

# Drive activity for the user (`all` = all users; replace with email for per-user)
curl -s -H "Authorization: Bearer $GOOGLE_ADMIN_TOKEN" \
  "https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/drive?eventName=download&startTime=2026-04-01T00:00:00Z" \
  | jq

# OAuth token authorizations
curl -s -H "Authorization: Bearer $GOOGLE_ADMIN_TOKEN" \
  "https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/token?startTime=2026-04-01T00:00:00Z" \
  | jq

# Admin actions
curl -s -H "Authorization: Bearer $GOOGLE_ADMIN_TOKEN" \
  "https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/admin?startTime=2026-04-01T00:00:00Z" \
  | jq
```

GAM7 (installed as the `gam` command) wraps these endpoints and is the standard CLI in many Workspace shops:

```bash
# GAM7 report grammar: user / start / end / event; output is CSV with every event parameter [verify 2026-10-30]
gam report login user <suspect-email> start 2026-04-01T00:00:00Z end 2026-04-27T00:00:00Z
gam report drive start 2026-04-01T00:00:00Z event download
gam report admin start 2026-04-01T00:00:00Z
gam report token start 2026-04-01T00:00:00Z event authorize
```

### 5.2 Retention Defaults Per Category

Workspace Reports API retention is per-application and is **Google-controlled**, not customer-tunable [verify 2026-10-30]. Long-term retention requires export to GCP (BigQuery, Cloud Storage, Pub/Sub) via the Workspace logs export feature, which is configured at the customer level and writes log-event streams to a customer GCP project.

```bash
# Export configuration (Admin Console → Reporting → Data integrations → BigQuery Export) [verify 2026-10-30]
# Configures continuous export to BigQuery for long-term retention beyond the Reports API window.
# The exported dataset is queryable via standard BigQuery tooling.

# Example BigQuery query against the exported activity table (columns per Google's example queries) [verify 2026-10-30]
bq query --use_legacy_sql=false '
SELECT
  TIMESTAMP_MICROS(time_usec) AS event_time,
  email AS actor,
  record_type,
  event_type,
  event_name,
  ip_address
FROM `<project>.<dataset>.activity`
WHERE TIMESTAMP_MICROS(time_usec) BETWEEN TIMESTAMP("2026-04-01") AND TIMESTAMP("2026-04-27")
  AND email = "<suspect>@<domain>"
ORDER BY time_usec
'
```

### 5.3 Gmail BigQuery Export

The Workspace Gmail BigQuery export is **distinct from** the Reports API `gmail` application feed. It captures full mail-flow events at message granularity (recipient address, subject hash, attachments metadata, RFC 822 message-id) and is the canonical surface for "what mail went through this tenant" reconstruction beyond the limited Reports API window. It is configured through the unified Workspace BigQuery Export (Admin Console → Reporting → Data integrations → BigQuery Export); Gmail records land in the same `activity` table under the `gmail` field [verify 2026-10-30].

```sql
-- Mail-flow query against the Gmail records in the BigQuery Export activity table
-- (field names per Google's "Schema for Gmail logs in BigQuery") [verify 2026-10-30]
SELECT
  TIMESTAMP_MICROS(gmail.event_info.timestamp_usec) AS event_time,
  gmail.message_info.rfc2822_message_id AS message_id,
  gmail.message_info.subject AS subject,
  gmail.message_info.source.address AS sender,
  ARRAY(SELECT address FROM UNNEST(gmail.message_info.destination)) AS recipients,
  gmail.message_info.action_type AS action_type  -- integer delivery-stage code; see the schema doc
FROM
  `<project>.<dataset>.activity`
WHERE
  DATE(TIMESTAMP_MICROS(gmail.event_info.timestamp_usec)) BETWEEN "2026-04-01" AND "2026-04-27"
  AND gmail.message_info.source.address = "<suspect>@<domain>";
```

### 5.4 Workspace Vault

Vault is the Workspace eDiscovery / litigation-hold platform. It is licensed separately on some plans (included with Business Plus, Enterprise Standard / Plus, Enterprise Essentials / Essentials Plus (domain-verified only), all Education editions, Frontline Standard / Plus and G Suite Business; available as an add-on licence for other editions [verify 2026-10-30]).

```bash
# Vault admin console pattern (UI, not script):
# Apps → Google Workspace → Vault → Matters → Create matter
#   → Add hold (custodian: <suspect>@<domain>; corpus: Mail / Drive / Chat / Voice / Sites / Calendar)
#   → Search (within matter; query by date / participant / keyword / file-type)
#   → Export (delivers a downloadable archive — PST for mail, native files for Drive,
#             with a searchable XML manifest)

# Vault API v1 (service vault.googleapis.com)
# https://developers.google.com/workspace/vault/reference/rest [verify 2026-10-30]

# Required scope: https://www.googleapis.com/auth/ediscovery [verify 2026-10-30]
curl -X POST 'https://vault.googleapis.com/v1/matters' \
  -H "Authorization: Bearer $VAULT_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name": "Case-2026-04-27", "description": "Forensic matter"}'

# Export workflow returns a job ID; poll for completion; download archive when ready;
# verify SHA-256 against the archive manifest at receipt.
```

**Hold semantics.** A Vault hold preserves data **indefinitely** within hold scope, overriding user-deletion and tenant retention rules. Holds are visible to Vault admins but not to end users. Apply hold first, then search — the inverse order risks evidence-spoliation if the user is alerted by some other channel.

### 5.5 External Sharing & Cross-Domain Forensics

Workspace external sharing is the dominant data-exfil channel for insider-threat and post-credential-compromise scenarios. Reports API `drive` events with `change_user_access`, `change_acl_editors`, `change_document_access_scope`, or `change_document_visibility` capture share creations. [verify 2026-10-30]

```bash
# Drive share events to external domains (CSV includes doc_id, doc_title, target_user, visibility,
# visibility_change) [verify 2026-10-30]
# The row filter tests only the target_user column, so rows whose actor is internal are kept [verify 2026-10-30]
gam config csv_output_row_filter 'target_user:notregex:@<your-primary-domain>$' \
  report drive start 2026-04-01T00:00:00Z event change_user_access

# Mass-download events (single user, large file count)
gam report drive user <suspect-email> start 2026-04-01T00:00:00Z event download

# `gam user <suspect-email> print drivefileacls <fileId>` enumerates current ACLs on a file — useful as a snapshot baseline [verify 2026-10-30]
```

### 5.6 Filter / Forwarding Rule Forensics

Workspace's equivalent of the M365 inbox-rule attack is Gmail filter creation:

```bash
# No documented Reports API event records Gmail filter creation; the documented user-level
# forwarding event is user_accounts email_forwarding_out_of_domain [verify 2026-10-30]
gam report useraccounts start 2026-04-01T00:00:00Z event email_forwarding_out_of_domain

# Current forwarding and filter state per user (snapshot by enumeration) [verify 2026-10-30]
gam user <suspect-email> show forwardingaddresses
gam user <suspect-email> show forward
gam user <suspect-email> show filters
```

Workspace exposes no documented per-user "filter created" audit event, so filter persistence is found by enumerating current filters and forwarding settings; a filter that forwards to an external mailbox, or an `email_forwarding_out_of_domain` event, is the Workspace BEC-pivot persistence indicator. Cross-correlate with sign-in events from §5.1 `login` to identify the source IP / session around the change [verify 2026-10-30].

---

## 6. Okta — System Log & Identity Threat Protection

Okta is the canonical identity-provider audit surface for many enterprises (Workforce Identity) and consumer-facing apps (Okta Customer Identity; Auth0 runs on its own separate platform, see §6.3). System Log API events are the forensic spine.

### 6.1 System Log API

```bash
# /api/v1/logs - paginated, time-ordered
# Required: SSWS API token (inherits the creating admin's role) or OAuth 2.0 access token with the `okta.logs.read` scope [verify 2026-10-30]
# Retention: System Log data older than 90 days isn't returned [verify 2026-10-30]
# limit: 0-1000 per page (default 100); follow the Link: rel="next" header [verify 2026-10-30]

curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logs?since=2026-04-01T00:00:00Z&until=2026-04-27T00:00:00Z&limit=1000" \
  | jq

# Filter on actor / target / event. Filters can't use `published`; bound time with since / until [verify 2026-10-30]
curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logs?since=2026-04-01T00:00:00Z&filter=actor.id+eq+%22<okta-uid>%22" \
  | jq

# eventType filter (high-value) [verify 2026-10-30]
curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logs?filter=eventType+eq+%22user.session.start%22+OR+eventType+eq+%22user.authentication.auth_via_mfa%22+OR+eventType+eq+%22application.user_membership.add%22" \
  | jq
```

### 6.2 Retention & Log Streaming

90-day default retention is the structural floor; longer retention requires Log Streaming (native targets: Amazon EventBridge, Splunk Cloud) or a SIEM connector that polls the System Log API [verify 2026-10-30]. Without log streaming, an investigation initiated more than 90 days post-event is bounded by what downstream sinks (corporate SIEM, identity-provider analytics) retained.

```bash
# Confirm log-streaming configuration (admin console → Reports → Log Streaming) [verify 2026-10-30]
curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logStreams" \
  | jq

# Log-stream destinations show whether long-term retention is in place
```

### 6.3 Workforce Identity vs Auth0

Workforce Identity (`<org>.okta.com` / OIE) and Auth0 (`<tenant>.auth0.com`; briefly branded Okta Customer Identity Cloud, a separate platform from Okta Customer Identity) have **distinct** audit log APIs and event taxonomies. Auth0 events use the `/api/v2/logs` endpoint with codes like `s` (success login), `f` (failed login), `fp` (incorrect password), `seacft` (authorization code exchanged for access token), `ssa` (silent authentication success), `sertft` (refresh token exchanged for access token) [verify 2026-10-30].

```bash
# Auth0 log query (Management API, read:logs scope; Lucene date range in q) [verify 2026-10-30]
curl -s -H "Authorization: Bearer $AUTH0_MGMT_TOKEN" \
  "https://<tenant>.auth0.com/api/v2/logs?q=date%3A%5B2026-04-01%20TO%202026-04-27%5D" \
  | jq

# Auth0 log retention is short and plan-dependent: Starter 1 day, Essentials 5, Professional 10, Enterprise 30 [verify 2026-10-30]
```

When the engagement covers consumer-facing identity (a B2C SaaS tenant that Okta Customer Identity or Auth0 protects), confirm whether Workforce Identity, Okta Customer Identity, Auth0, or a combination are in scope.

### 6.4 Identity Threat Protection (ITP) Signal Sources

Okta ITP (Identity Threat Protection) is a 2024-era add-on that generates risk signals on suspicious sign-in patterns, session-token abuse, and identity-graph anomalies. ITP signals surface in System Log as `user.risk.detect` (renamed from `user.risk.change` in 2024.09.0), `policy.entity_risk.evaluate` / `policy.entity_risk.action`, `user.session.context.change`, `policy.auth_reevaluate.*` and `security.events.provider.receive_event` (Shared Signals), with the reason in the event's Behaviors and Risk fields [verify 2026-10-30]. ITP draws on:

- IP reputation (Okta-curated + customer-provided lists).
- Device-trust posture (Okta Verify, Okta FastPass enrollment, Okta Device SDK signals).
- Behavioral baselines (login-time, login-location, login-device).
- Session-token abuse (token replay across geographies, refresh-token-without-recent-auth).
- Third-party signal ingestion from security event providers via the Shared Signals Framework (launch partners included CrowdStrike, Jamf, Netskope, Palo Alto Networks, Zscaler) [verify 2026-10-30].

ITP-flagged sign-ins are forensic gold even when the action that followed was logged as benign — the ITP score tells you which sessions warrant deeper inspection.

### 6.5 Universal Directory Event Taxonomy

Okta System Log event types are grouped by dotted prefix (`user.*`, `application.*`, `policy.*`, `system.*`, `security.*`, …). High-value families for forensics [verify 2026-10-30]:

| Family | Examples | Forensic value |
|---|---|---|
| `user.session.*` | `start`, `end`, `expire` | Sign-in / sign-out reconstruction [verify 2026-10-30] |
| `user.authentication.*` | `auth_via_mfa`, `auth_via_social`, `auth_via_IDP`, `auth_via_inbound_SAML`, `sso` (no `auth_via_password` event; password use shows as `authenticationContext.credentialType` = `PASSWORD`) | MFA bypass, federated-IdP consumption [verify 2026-10-30] |
| `user.account.*` | `unlock`, `lock`, `update_password`, `reset_password`, `privilege.grant`, `privilege.revoke` | Account-state changes (often attacker persistence) [verify 2026-10-30] |
| `user.lifecycle.*` | `create`, `delete.initiated`, `activate`, `suspend`, `unsuspend`, `deactivate` | New-user provisioning (potential persistence) [verify 2026-10-30] |
| `application.user_membership.*` | `add`, `remove` | App-assignment changes (potential lateral) [verify 2026-10-30] |
| `application.lifecycle.*` | `create`, `update`, `delete` | New SP / OIDC client created in tenant [verify 2026-10-30] |
| `policy.*` | `policy.lifecycle.create`, `policy.lifecycle.update`, `policy.lifecycle.delete`, `policy.evaluate_sign_on`, `policy.rule.add` / `update` / `delete` | Conditional-access / sign-on policy changes [verify 2026-10-30] |
| `system.*` | `system.api_token.create`, `system.api_token.revoke`, `system.idp.lifecycle.*`, `system.org.*` | High-privilege configuration changes [verify 2026-10-30] |
| `user.risk.*` / `policy.entity_risk.*` / `security.threat.*` | `user.risk.detect`, `policy.entity_risk.evaluate`, `security.threat.detected` | Risk-scored user / session events [verify 2026-10-30] |

### 6.6 Cross-Tenant Impersonation Indicators

When Okta is the IdP for both source and target tenants (e.g., a managed-service-provider model where one Okta org federates into customer tenants via inbound federation), `user.authentication.auth_via_inbound_SAML` / `auth_via_IDP` events on the **target** tenant must be cross-walked to the **source** tenant's session events. Sophisticated attackers abuse delegated-admin or partner-portal access to impersonate tenant admins; the forensic signature is a sign-in event chain that crosses Okta org boundaries within seconds.

---

## 7. Slack — Audit Logs & Discovery

Slack's forensic surface is **gated by tier**. Audit Logs API requires a Slack Enterprise plan (an Enterprise organization; Slack's current pricing lists audit logs only on Enterprise+), with no equivalent on Pro / Business+; Discovery API is also Enterprise-only and must be requested by an Org Owner [verify 2026-10-30]. Customers on Pro / Business+ have access to compliance exports via the workspace owner UI, but no programmatic audit-log API.

### 7.1 Audit Logs API (Enterprise plan)

```bash
# Required: user token (xoxp-) with `auditlogs:read`, from an app installed by the Enterprise org Owner [verify 2026-10-30]
# https://api.slack.com/audit/v1/logs (REST endpoint distinct from the Slack Web API); limit max 9999, action max 30 [verify 2026-10-30]
curl -s -H "Authorization: Bearer $SLACK_AUDIT_TOKEN" \
  "https://api.slack.com/audit/v1/logs?oldest=$(date -u -d '2026-04-01' +%s)&latest=$(date -u -d '2026-04-27' +%s)&limit=1000" \
  | jq

# Action filter
curl -s -H "Authorization: Bearer $SLACK_AUDIT_TOKEN" \
  "https://api.slack.com/audit/v1/logs?action=user_login,app_installed,user_channel_join&limit=1000" \
  | jq
```

High-value Audit Logs API actions:

- `user_login`, `user_login_failed`, `user_logout` — sign-in audit [verify 2026-10-30].
- `user_channel_join`, `user_channel_leave`, `public_channel_created`, `private_channel_created` — channel activity [verify 2026-10-30].
- `app_installed`, `app_uninstalled`, `app_scopes_expanded`, `app_approved` — Slack-app inventory changes [verify 2026-10-30].
- `domain_verified`, `domain_created`, `domain_deleted`, `organization_domain_changed` — domain trust changes [verify 2026-10-30].
- `workspace_created`, `workspace_deleted`, `workspace_accepted_migration` — Enterprise org structure changes [verify 2026-10-30].
- `external_shared_channel_invite_created`, `external_shared_channel_invite_accepted`, `external_shared_channel_connected`, `connect_dm_invite_accepted` — cross-organization shared-channel / DM formation (high signal for cross-tenant lateral) [verify 2026-10-30].
- `native_dlp_rule_action_applied` — native DLP rule matches (when DLP is licensed) [verify 2026-10-30].

### 7.2 Discovery API for Content

Discovery API exposes full message and file content for E-Discovery use cases — separate from Audit Logs API and tightly access-controlled. Discovery API is available on Enterprise plans and is enabled on request by the Primary Org Owner or an Org Owner [verify 2026-10-30]; not every Enterprise org has it active.

```bash
# Discovery endpoints (verify current shape per Slack docs; no public method reference is published,
# see https://slack.com/help/articles/360002079527-A-guide-to-Slacks-Discovery-APIs) [verify 2026-10-30]
# GET /discovery.enterprise.info  - org configuration
# GET /discovery.users.list       - user enumeration
# POST /discovery.conversations.history - message content per conversation
# GET /discovery.conversations.recent   - recent messages cross-tenant

curl -s -H "Authorization: Bearer $SLACK_DISCOVERY_TOKEN" \
  "https://slack.com/api/discovery.conversations.history?channel=<C…>&oldest=$(date -u -d '2026-04-01' +%s)" \
  | jq
```

**Edited and deleted content.** Per Slack, the Discovery API returns edited and deleted content only if it was preserved by retention policies or legal holds [verify 2026-10-30]; whether a deleted message leaves a tombstone (existence and timestamp without the body) is not documented publicly, so confirm in the tenant before relying on it. Pair with legal holds (§12.3; Slack Connect conversations are not covered) to preserve content before deletion.

### 7.3 Retention vs E-Discovery

Slack message retention is workspace-policy-controlled (admin sets delete-after-N-days). When retention is short (some workspaces set 30 or 90 days), forensic windows are bounded. A legal hold (§12.3) saves the held members' messages and files regardless of workspace retention; the Discovery API or a JSON export reads the held data [verify 2026-10-30].

### 7.4 Slack Connect Cross-Tenant Forensics

Slack Connect (formerly "shared channels") creates a single channel that lives in two or more Slack orgs. Each side sees the channel and its messages, with per-org governance. For forensics, Slack Connect events are dual-cloud: the Audit Logs of both sides should be collected when investigating cross-tenant data movement.

```bash
# Surfacing Slack Connect channels and DMs (audit-log token required) [verify 2026-10-30]
curl -s -H "Authorization: Bearer $SLACK_AUDIT_TOKEN" \
  "https://api.slack.com/audit/v1/logs?action=external_shared_channel_invite_accepted,external_shared_channel_connected,connect_dm_invite_accepted&limit=1000" \
  | jq
```

Risk patterns: a Slack Connect invitation accepted by a compromised user, granting the attacker's external org persistent visibility into channels the user is a member of.

---

## 8. Salesforce — Setup Audit Trail & Event Monitoring

Salesforce splits its forensic surface across Setup Audit Trail (free, 180-day window of admin / setup changes), Login History (6 months), and Real-Time Event Monitoring (Salesforce Shield add-on; long-term, streaming, content-rich) [verify 2026-10-30].

### 8.1 Setup Audit Trail (180-Day)

SAT captures every admin-level setup / metadata change — profile / permission-set edits, custom-object creation, OAuth Connected App authorization, sharing-rule changes, login-IP-range modifications, etc. Free with all editions [verify 2026-10-30].

```bash
# REST API query (SetupAuditTrail fields: Action, Section, Display, DelegateUser, CreatedDate) [verify 2026-10-30]
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+CreatedDate,CreatedBy.Username,Action,Section,Display,DelegateUser+FROM+SetupAuditTrail+WHERE+CreatedDate+%3E+2026-04-01T00:00:00Z" \
  | jq

# UI: Setup → Quick Find → "View Setup Audit Trail" → Download (CSV)
```

High-value SAT actions. Salesforce documents no enumeration of `SetupAuditTrail.Action` values, so the strings below are unverified examples: pull `Action, Section, Display` for the window and pivot on the values the org actually emits before hunting on exact strings.

- `assignedRoleToUser`, `assignedPermissionSetToUser`, `assignedProfileToUser` — privilege assignment.
- `connectedAppAuthorized`, `connectedAppRevoked` — OAuth Connected App lifecycle.
- `loginAsGrantedToOrg`, `loginAsGrantedToUser` — admin-impersonation grants (a top BEC-pivot indicator on Salesforce).
- `changedSamlConfig`, `changedSsoConfig`, `changedCorpDomain` — federation configuration.
- `dataExportRequested`, `dataExportDownloaded` — full-tenant data export (high-volume exfil indicator).
- `appExchangeAppInstalled` — third-party app installation.

### 8.2 Real-Time Event Monitoring (Shield Add-On)

RTEM streams per-API-call, per-record-access, per-report-export, per-session-event in near-real-time to a Big Object store and to external SIEMs. Storage event types include `ApiEvent`, `BulkApiResultEvent` (stored as `BulkApiResultEventStore`), `LoginEvent`, `LogoutEvent`, `LoginAsEvent`, `ReportEvent`, `LightningUriEvent`, `ListViewEvent`, `UriEvent`, `FileEvent`, `PermissionSetEvent` [verify 2026-10-30]. A subset is also available without the add-on via the `EventLogFile` object (log files, not real-time), but the streaming and long-retention layer requires Shield or the Event Monitoring add-on.

```bash
# RTEM via REST query (Shield / Event Monitoring orgs); field names per the ReportEvent reference [verify 2026-10-30]
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+EventDate,Username,SourceIp,Operation,ReportId,RowsProcessed,QueriedEntities+FROM+ReportEvent+WHERE+EventDate+%3E+2026-04-01T00:00:00Z" \
  | jq

# `EventLogFile`: 1-day retention without the add-on (limited event types); 30 days to 1 year with Shield / Event Monitoring
# (Salesforce's FAQ and developer guide disagree on the default, so confirm in the org) [verify 2026-10-30]
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+Id,EventType,LogFile,LogDate+FROM+EventLogFile+WHERE+LogDate+%3E+2026-04-01T00:00:00Z" \
  | jq
```

### 8.3 Threat Detection (Shield)

Salesforce Threat Detection is an ML-driven anomaly-detection feature within Shield. Event types include `ApiAnomalyEvent`, `CredentialStuffingEvent`, `ReportAnomalyEvent`, `SessionHijackingEvent` [verify 2026-10-30]. Findings are queryable via REST and surface in the Salesforce Threat Detection app.

### 8.4 Login History

```bash
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+UserId,LoginTime,SourceIp,LoginType,Status,Browser,Platform,LoginUrl+FROM+LoginHistory+WHERE+LoginTime+%3E+2026-04-01T00:00:00Z" \
  | jq
```

### 8.5 Salesforce Communities / Experience Cloud

Communities (rebranded Experience Cloud) are external-user portals embedded in a Salesforce org. Cross-tenant impersonation risk: a compromised internal account creates a Community user whose permissions overlap with internal records, then accesses via the external portal. SAT captures the user-creation action (strings such as `createdCustomerPortalUser` / `createdPartnerUser` are unverified; confirm against the org's own `Action` values); RTEM `LoginEvent.LoginType` distinguishes Community sign-ins from internal sign-ins (confirm the portal / Experience Cloud values against the org's `LoginType` picklist).

---

## 9. GitHub & GitLab — Audit Log Forensics

Source-control SaaS audit is high-value for both insider-threat (mass-clone, mass-fork) and supply-chain-attack (token theft, malicious workflow injection) scenarios. The audit surface is org/enterprise-tier-gated for both vendors.

### 9.1 GitHub Audit Log

The GitHub Organization audit log (and Enterprise audit log for enterprise customers) covers all administrative events on the org / enterprise. Audit retention via the API is 180 days (Git events: 7 days); long-term retention requires enterprise-level audit-log streaming to Amazon S3, Azure Blob Storage, Azure Event Hubs, Datadog, Google Cloud Storage, or Splunk [verify 2026-10-30].

```bash
# Org audit log via REST (GitHub Enterprise Cloud; token with read:audit_log) [verify 2026-10-30]
curl -s -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/<org>/audit-log?phrase=created:2026-04-01..2026-04-27&per_page=100" \
  | jq

# Enterprise audit log (enterprise admin token required) [verify 2026-10-30]
curl -s -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/enterprises/<slug>/audit-log?phrase=created:2026-04-01..2026-04-27&per_page=100" \
  | jq

# Git events (git.clone / git.fetch / git.push) are returned only with include=git (or include=all) and are
# retained for 7 days. The GraphQL audit log cannot return Git events and is deprecated (removal 2026-04-01). [verify 2026-10-30]
curl -s -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/<org>/audit-log?phrase=created:2026-04-20..2026-04-27&include=git&per_page=100" \
  | jq
```

### 9.2 GitHub Audit Log Event Taxonomy

| Category | Examples | Forensic value |
|---|---|---|
| `git.*` | `git.clone`, `git.fetch`, `git.push` | Mass-clone exfil indicator (high signal); REST API with `include=git` / `include=all` (7-day retention), streaming for longer [verify 2026-10-30] |
| `repo.*` | `repo.create`, `repo.destroy`, `repo.transfer`, `repo.access`, `repo.actions_enabled`, `repo.add_member` | Repo-lifecycle events (`repo.access` = visibility change); new public repo from a private-only org is anomalous [verify 2026-10-30] |
| `org.*` | `org.invite_member`, `org.remove_member`, `org.update_member`, `org.add_outside_collaborator`, `org.update_default_repository_permission` | Org-level membership changes [verify 2026-10-30] |
| `oauth_application.*` | `oauth_application.create`, `oauth_application.transfer`, `oauth_application.revoke_tokens` | OAuth-app lifecycle [verify 2026-10-30] |
| `personal_access_token.*` | `personal_access_token.access_granted`, `personal_access_token.access_revoked` | Fine-grained PAT issuance and approval [verify 2026-10-30] |
| `workflows.*` | `workflows.cancel_workflow_run`, `workflows.disable_workflow`, `workflows.rerun_workflow_run`, `workflows.delete_workflow_run` | CI/CD pipeline manipulation [verify 2026-10-30] |
| `protected_branch.*` | `protected_branch.create`, `protected_branch.destroy`, `protected_branch.update_admin_enforced` | Branch-protection bypass [verify 2026-10-30] |
| `secret_scanning_alert.*`, `secret_scanning.*` | `secret_scanning_alert.resolve`, `secret_scanning_alert.reopen`, `secret_scanning.disable` | Suspicious dismissal of secret-leak alerts [verify 2026-10-30] |
| `code_scanning.*` | `code_scanning.alert_closed_by_user`, `code_scanning.alert_closure_requested` | Code-scanning policy bypass [verify 2026-10-30] |
| `business.*` | `business.add_organization`, `business.add_admin` | Enterprise structural changes [verify 2026-10-30] |

Mass-clone detection (the canonical insider-threat signal) depends on Git events. Without streaming, `git.clone` events are retrievable only through the REST API with `include=git` for seven days [verify 2026-10-30]; after that the signal must come from `repo.access` events (when public-private toggles are involved) or downstream telemetry (CDN logs, employee egress monitoring).

### 9.3 GitLab Audit Events

```bash
# Group audit events (Premium / Ultimate) [verify 2026-10-30]
curl -s -H "PRIVATE-TOKEN: $GL_TOKEN" \
  "https://gitlab.com/api/v4/groups/<group-id>/audit_events?created_after=2026-04-01T00:00:00Z" \
  | jq

# Instance audit events (self-managed, instance-admin scope)
curl -s -H "PRIVATE-TOKEN: $GL_TOKEN" \
  "https://gitlab.example.com/api/v4/audit_events?created_after=2026-04-01T00:00:00Z" \
  | jq

# Project audit events
curl -s -H "PRIVATE-TOKEN: $GL_TOKEN" \
  "https://gitlab.com/api/v4/projects/<project-id>/audit_events" \
  | jq
```

GitLab event taxonomy parallels GitHub at the conceptual level (member changes, repo changes, settings changes, runner / pipeline events) but differs in field shapes; verify against current `/api/v4` documentation [verify 2026-10-30].

### 9.4 CI/CD Secret Access Reconstruction

When a CI/CD pipeline is suspected of credential theft (a workflow run accessed an AWS / Azure / GCP / Slack / Stripe / Twilio token from secrets and exfiltrated it), the reconstruction joins:

- **GitHub Actions** — `workflows.created_workflow_run`, `workflows.completed_workflow_run` events; the `repository.id` + `run_id` + `head_branch` + `actor` triad identifies the run; run logs and artifacts are retained 90 days by default (configurable 1-90 days for public repos, 1-400 days for private) [verify 2026-10-30]. Subsequent token use is in the downstream cloud (route to [[sop-cloud-forensics|Cloud Forensics]] §7 IAM Forensics).
- **GitLab CI** — pipeline / job audit, runner audit, masked variable audit (variables marked masked are not logged in plaintext, but their *use* in a job is logged at the job-event level).
- **Workload Identity Federation pivot** — when the CI provider issues an OIDC token consumed by AWS / Azure / GCP, the `aud` / `sub` / `iss` claims tie the cloud-side `AssumeRoleWithWebIdentity` / Entra federated-credential / GCP `GenerateAccessToken` event back to the source workflow run. Cross-walk documented in [[sop-cloud-forensics|Cloud Forensics]] §7.5.

---

## 10. OAuth Consent-Grant Abuse Forensics

OAuth consent-grant abuse — frequently called "OAuth-app phishing," "illicit consent grant," or "OAuth-BEC variant" — is an attacker pattern that defeats MFA and session-token rotation by establishing a *separate* persistence channel: an attacker-controlled OAuth application that the victim consents to. Once consent is granted, the attacker holds offline-access refresh tokens and can read mailboxes, files, calendars, or whatever the granted scope permits, **without ever signing in as the victim**. Per the buildout-plan scope contract for the forensics trio, this variant lives in #8 (this SOP), not in [[sop-email-bec-forensics|Email & BEC Forensics]] (which covers header-spoofing / wire-recall BEC).

### 10.1 The Pattern

1. **App registration.** Attacker registers a multi-tenant OAuth app in their own tenant (M365: app registration in attacker Entra ID; Workspace: OAuth client in attacker GCP project; Salesforce / Okta / Slack: vendor-specific OAuth client).
2. **Consent harvest.** Attacker phishes the victim with a link to the app's consent screen. The victim sees an official-looking consent dialog from Microsoft / Google / Salesforce and accepts.
3. **Token issuance.** Provider mints access + refresh tokens scoped to whatever permissions the victim granted (commonly: `Mail.Read`, `Files.Read.All`, `User.Read`, `offline_access`) [verify 2026-10-30].
4. **Persistent access.** Attacker uses refresh tokens to read mail / files / messages on demand. MFA does not help — no interactive sign-in is required after consent. Password rotation does not help — refresh tokens are independent of password.
5. **Continuation.** Attacker abuses the access for BEC (read inbound payment-confirmation mail), data theft (download Drive contents), or reconnaissance (read calendar / address book / org chart).

### 10.2 M365 — `oauth2PermissionGrants` and App-Role Assignments

```bash
# Required Graph permissions: Application.Read.All, Directory.Read.All [verify 2026-10-30]
# List calls are paged: follow @odata.nextLink in each response until it is absent

# Enumerate all delegated-permission grants in the tenant (this list supports only $filter with eq) [verify 2026-10-30]
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants" \
  > oauth-grants.json

# Enumerate all app-role assignments to service principals (application permissions); max page size 100 [verify 2026-10-30]
# $expand returns at most 20 assignments per SP with no nextLink; for a complete inventory call GET /servicePrincipals/{id}/appRoleAssignments
# per SP (or Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId <id> -All) [verify 2026-10-30]
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/servicePrincipals?\$expand=appRoleAssignments&\$top=100" \
  > sp-app-roles.json

# High-risk app-only Microsoft Graph permissions (Mail.*, Files.*, Sites.FullControl.*). Assignments carry appRoleId GUIDs,
# not names, so resolve them against the Graph service principal's appRoles (appId 00000003-0000-0000-c000-000000000000) [verify 2026-10-30]
GRAPH_SP="https://graph.microsoft.com/v1.0/servicePrincipals(appId='00000003-0000-0000-c000-000000000000')"
az rest --method GET --uri "$GRAPH_SP?\$select=id,appRoles" > graph-sp.json
az rest --method GET --uri "$GRAPH_SP/appRoleAssignedTo" > graph-app-role-assignments.json
jq --slurpfile sp graph-sp.json '
  ($sp[0].appRoles | map({key: .id, value: .value}) | from_entries) as $roles
  | .value[]
  | {principalDisplayName, principalId, principalType, permission: $roles[.appRoleId]}
  | select((.permission // "") | test("^(Mail\\.|Files\\.|Sites\\.FullControl)"))' graph-app-role-assignments.json
```

UAL events of interest (from §4.4):

- `Add app role assignment to service principal.` — admin or user grants application-only permission. **Highest signal**: app-only permissions can act without a user [verify 2026-10-30].
- `Consent to application.` — user or admin consents to an OAuth app. `IsAdminConsent` in the event details is `True` for admin consent (org-wide) and `False` for user consent (single user) [verify 2026-10-30].
- `Add service principal.` — new service principal materialized in the tenant (typically when a multi-tenant app is first consented to) [verify 2026-10-30].
- `Add delegated permission grant.` — delegated (oauth2PermissionGrant) permissions granted [verify 2026-10-30].
- `Add owner to application.`, `Add member to role.`, `Update service principal.` — post-consent privilege changes [verify 2026-10-30].

```powershell
# Entra operation names keep their trailing period inside the quotes (see §4.2) [verify 2026-10-30]
# Repeat the session until it returns nothing (ReturnLargeSet: unsorted, max 50,000 per session)
$sid = "consent-$([guid]::NewGuid())"
do {
    $page = Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
        -Operations "Consent to application.","Add service principal.","Add app role assignment to service principal.","Add delegated permission grant." `
        -SessionId $sid -SessionCommand ReturnLargeSet -ResultSize 5000
    $page | Select CreationDate,UserIds,Operations,AuditData
} while ($page)
```

### 10.3 Workspace — OAuth Token Issuance Audit

Workspace `token` Reports API surfaces both `authorize` (consent issuance) and `revoke` events [verify 2026-10-30]:

```bash
# CSV output carries every event parameter, including client_id, app_name and scope [verify 2026-10-30]
gam report token start 2026-04-01T00:00:00Z event authorize

# Cross-walk to currently-authorized apps per user [verify 2026-10-30]
gam user <suspect-email> show oauth
```

Workspace's OAuth verification status (verified vs unverified) and the App Access Control admin policy gate which OAuth clients can be consented to — but historical incidents may pre-date a tighter policy. Pre-engagement App Access Control audit clarifies which apps were authorized with which scopes during the suspect window.

### 10.4 App-Registration Forensics

For each OAuth app implicated:

1. **Tenant of origin** — app registrations live in the *publisher* tenant; consents live in the *consumer* tenant. Identifying the publisher tenant is the first step in attribution.
2. **Verified-publisher status** — Microsoft Verified Publisher, Google verified developer, Slack-app-directory listing — verified status raises the bar against impersonation but is not a guarantee.
3. **Reply URLs / redirect URIs** — attacker apps frequently use `localhost`, ngrok-style tunnels, or short-lived domain-fronted endpoints. URLs not on the publisher's documented domain are suspect.
4. **Permissions / scopes requested** — broad scopes (`Mail.ReadWrite`, `Files.ReadWrite.All`, `Sites.FullControl.All`, `https://www.googleapis.com/auth/gmail.readonly`) demand justification [verify 2026-10-30].
5. **Client-secret / federated-credential rotation** — sudden changes to publisher credentials post-consent are a tampering signal.

### 10.5 Consent-Event Reconstruction

The full consent timeline:

| Step | M365 event | Workspace event | Investigative value |
|---|---|---|---|
| User clicks consent link | (no event — pre-consent) | (no event) | Phishing-vector reconstruction comes from email logs and [[sop-cloud-forensics|Cloud Forensics]] sign-in logs |
| User authenticates (if not already) | Entra ID `Sign-in` (interactive, with the consent app as `appDisplayName`) | `login_success` | Identifies the user, source IP, MFA method [verify 2026-10-30] |
| User clicks "Accept" on consent screen | UAL `Consent to application.` | `token authorize` | Captures user, app, granted scopes [verify 2026-10-30] |
| Provider issues access + refresh tokens | (token issuance is internal) | (internal) | Forensic gap — tokens are not audited at issuance; their *use* is |
| Attacker uses access token to read mail | UAL `MailItemsAccessed` (Audit (Standard); on by default for E3 / E5 users) | Reports API `gmail` events (sparse — full visibility via BigQuery export) | Captures mail-item-level read; `AppId` / `ClientAppId` identify the consenting app [verify 2026-10-30] |
| Attacker uses refresh token to obtain new access token | (no separate event) | (no separate event) | Forensic gap — refresh-flow is not visible per use |
| Optional: attacker rotates app secret to lock the victim out | UAL `Update service principal.` | (no documented Workspace event — attacker-side client changes happen in the attacker's project, outside the consumer tenant's logs) | Tampering signal [verify 2026-10-30] |

Provider-side mitigations the report should recommend:

- M365: tenant-level admin-consent policy to require admin approval for non-Verified-Publisher apps and / or non-low-risk-permission apps.
- Workspace: App Access Control restrictions on third-party apps; OAuth scope review.
- Salesforce: Connected App approval workflow; My Domain login policies.
- Okta: API access management with explicit allowlisting.

---

## 11. Cross-Tenant Forensics

Cross-tenant collaboration features are a routine attack vector — the attacker's tenant is the persistence host, the victim's tenant is the resource. These features are designed to be quiet about cross-tenant access, which is forensic feature *and* bug.

### 11.1 Entra ID — B2B / Guest / Cross-Tenant Access Settings

B2B guest accounts, cross-tenant sync, and cross-tenant access settings define which external Entra tenants can authenticate into the local tenant and what they can do once in.

```bash
# List guest users (users list: $top up to 999) [verify 2026-10-30]
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/users?\$filter=userType eq 'Guest'&\$top=999"

# Cross-tenant access policy [verify 2026-10-30]
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/default"
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners"

# Cross-tenant identity sync (Entra ID Premium feature) [verify 2026-10-30]
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners/<tenantId>/identitySynchronization"
```

Entra ID audit activities (UAL copies keep a trailing period): `Invite external user`, `Add user`, `Add a partner to cross-tenant access setting`, `Update a partner cross-tenant access setting`, `Update the company default cross-tenant access setting`, `Reset the cross-tenant access default setting`, `Add policy`. Sign-in logs (Graph beta `signIn` resource and the portal; not in v1.0): `crossTenantAccessType` distinguishes `none`, `b2bCollaboration`, `b2bDirectConnect`, `microsoftSupport`, `serviceProvider`, `passthrough` (`passthrough` needs the `Prefer: include-unknown-enum-members` header) [verify 2026-10-30].

### 11.2 Workspace — External Sharing

```bash
# Drive sharing events whose target_user is outside your domain. GAM output is CSV (not JSON); the
# change_user_access parameter is target_user, and the row filter tests only that column [verify 2026-10-30]
gam config csv_output_row_filter 'target_user:notregex:@<your-domain>$' \
  report drive start 2026-04-01T00:00:00Z event change_user_access

# Tenant-wide sharing policy (admin console — no API for full policy state)
# Apps → Google Workspace → Drive and Docs → Sharing settings
```

### 11.3 Slack Connect

Per §7.4 above — `external_shared_channel_invite_created`, `external_shared_channel_invite_accepted`, `external_shared_channel_connected` (and `connect_dm_invite_accepted` for Slack Connect DMs) are the events; both organizations' Audit Logs should be collected [verify 2026-10-30].

### 11.4 Salesforce Communities / Experience Cloud

Per §8.5 above — internal-user-creates-Community-user pattern; SAT user-creation action (exact `Action` string unverified, confirm in the org), RTEM `LoginEvent.LoginType` (confirm portal values against the org's `LoginType` picklist).

### 11.5 SaaS-Side Identity Federation (vs. IdP-Side in Cloud Forensics)

[[sop-cloud-forensics|Cloud Forensics]] §3.3 / §7 / §12 covers the **IdP-provider side** — Entra ID, Workspace, Okta acting as the IdP that *issues* SAML / OIDC tokens consumed by AWS / Azure / GCP / SaaS apps. This SOP covers the **SaaS-app side** — the SAML SP / OIDC RP configuration *within* the SaaS app that consumes those tokens. The attack surface is the same federation, but the audit artifact lives on the *consumer* side here.

| Surface | SaaS-side audit event | Forensic value |
|---|---|---|
| M365 (federated to external IdP) | UAL `Set domain authentication.`, Entra ID audit `Set domain authentication` / `Set federation settings on domain` [verify 2026-10-30] | New federation = tenant-wide identity-trust change (e.g., the historical "Solorigate / SUNBURST" abuse pattern) |
| Workspace (federated to external IdP) | Reports API `admin` `CHANGE_SSO_SETTINGS`, `TOGGLE_SSO_ENABLED` | Federation reconfiguration [verify 2026-10-30] |
| Okta (inbound federation from another IdP) | System Log `system.idp.lifecycle.create`, `system.idp.lifecycle.update`, `system.idp.key.update` | IdP-side trust change [verify 2026-10-30] |
| Salesforce | SAT SAML / SSO setting changes (`changedSamlConfig` / `changedSsoConfig` are unverified examples; confirm the org's `Action` values); RTEM `LoginEvent` for the SAML sign-ins that follow | SAML SP config change |
| Slack | Audit Logs `pref.sso_setting_changed` | SSO reconfiguration [verify 2026-10-30] |
| GitHub | Audit Log `org.update_saml_provider_settings`, `oauth_application.create` | SSO / OAuth config change [verify 2026-10-30] |

Federation reconfiguration is a top-tier persistence primitive — an attacker who modifies the SaaS-app's federation trust to an attacker-controlled IdP can mint valid tokens for any user without ever touching the legitimate IdP. The signature is a SAML / OIDC config event in the SaaS audit followed by sign-ins via the new federation that do not appear in the legitimate IdP's logs.

---

## 12. Retention-Cliff & Discovery-Export Discipline

The dominant SaaS-forensics failure mode is "data was deleted before we could collect." This section codifies the pre-engagement and engagement disciplines that keep evidence preserved long enough to be reconstructed.

### 12.1 The Failure Mode

Concrete failure shapes seen in the wild:

- **Default retention expired.** Investigation initiated 200 days post-incident; UAL Audit Standard retention is 180; 20 days of evidence are gone. No long-term export was configured [verify 2026-10-30].
- **Attacker-disabled retention.** Sophisticated attacker turns off UAL recording (`Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $false`; the cmdlet's age-limit parameters are on-premises only), turns off mailbox auditing org-wide (`Set-OrganizationConfig -AuditDisabled $true`) or exempts accounts with `Set-MailboxAuditBypassAssociation`, or shortens Purview audit-log retention policies, narrows Workspace logs export filter, deletes Vault holds, or revokes the SIEM-ingest API token. Evidence vanishes during the dwell window [verify 2026-10-30].
- **User-deleted content.** End user (often the attacker, after credential theft) deletes mail / files / messages. Default retention does not cover content; only the access metadata remains.
- **Tenant-deleted artifact.** Entire mailbox / OneDrive / Drive / Slack channel deleted. Cold-recovery windows are short: an Exchange Online soft-deleted mailbox is kept 30 days, then permanently purged; files in Drive Trash are deleted forever after 30 days, and admins can restore Drive data for 25 days after a user empties Trash (20 days after account deletion); Slack keeps deleted content only where retention policies or legal holds preserved it [verify 2026-10-30].
- **License downgrade.** Customer downgrades from E5 to E3 mid-incident; Audit (Premium) 1-year retention and audit-log retention policies stop applying, so new records get the 180-day Audit (Standard) lifetime. Microsoft says licensing changes don't affect previously committed audit items; record the licence history in the report [verify 2026-10-30].
- **Cross-region transfer required.** EU-resident tenant with US-investigator team. Data-residency rule blocks export until counsel review; the review takes weeks; retention expires.

### 12.2 Pre-Engagement Retention Sampling

The first-day procedure for every SaaS-forensics engagement:

1. **Inventory licenses and retention configuration.** UAL tier (Standard / Premium); Audit retention policy; org-level mailbox auditing (`Get-OrganizationConfig | Format-List AuditDisabled` = False) and audit-bypass accounts (`Get-MailboxAuditBypassAssociation`), since per-mailbox `AuditEnabled` always reads True and proves nothing [verify 2026-10-30]; Workspace logs export configuration; Vault hold inventory; Okta log-streaming destinations; Slack workspace retention policy; Salesforce Shield licensing; GitHub audit-log streaming.
2. **Run a probe query.** Pull 1 hour of UAL / Reports API / System Log / Audit Logs at the engagement start; confirm events return; confirm fields look as expected; confirm no unusual gaps. A probe that returns zero events for a period the customer believes was active is itself a finding.
3. **Lock the evidence window.** Apply Vault holds, eDiscovery cases, Salesforce Field Audit Trail (if Shield), Slack legal holds — *before* deepening the investigation, *before* the user is alerted [verify 2026-10-30].
4. **Promise based on evidence, not on what should be there.** Frame the report's evidentiary scope on the day-1 probe results. If `MailItemsAccessed` records are missing (auditing not on for the mailbox, or outside retention), do not promise mail-item-level reconstruction [verify 2026-10-30].

### 12.3 Provider-Specific Legal-Hold Mechanisms

| Vendor | Hold mechanism | Override tenant retention? |
|---|---|---|
| Microsoft 365 | In-Place Hold (retired — can no longer be created or applied; check older mailboxes for legacy ones); Litigation hold (per-mailbox); Retention policies (Purview, scoped); eDiscovery hold (case-scoped) [verify 2026-10-30] | Yes — retention-policy preserves; litigation-hold preserves indefinitely until removed |
| Google Workspace | Vault hold | Yes — overrides workspace and per-user retention indefinitely [verify 2026-10-30] |
| Okta | (No customer-side content hold; identity events only — handled via log streaming) | N/A |
| Slack | Legal holds (Enterprise plan; Legal Holds Admin role; Organization settings → Security → Legal Holds, or the Legal Holds API); held data is read via a JSON export or the Discovery API | Yes — saved regardless of retention settings; Slack Connect conversations are excluded and a deleted channel's data is not saved [verify 2026-10-30] |
| Salesforce | Field Audit Trail (Shield); per-record locking; legal-hold via custom apps | Yes — Field Audit Trail preserves field-level history per the rules (up to 10 years) [verify 2026-10-30] |
| GitHub | Audit-log streaming destination retention; archived-org policy | Indirect — original events streamed, source retention may expire |

Hold scope is tight: a hold preserves what is *already* in the system at hold time. It does not retroactively bring back data that was already deleted. The hold-first discipline (§12.2 step 3) is the only durable mitigation.

### 12.4 Export-Format & Chain-of-Custody Discipline

Per [[../../Investigations/Techniques/sop-collection-log|Collection Log]], every SaaS export must be:

- **Hashed at export.** SHA-256 of the export package immediately on download, before any analysis. Record source-tenant ID, source-API endpoint, time range, executing-admin identity, destination URI.
- **Stored read-only.** Encrypted at rest, access-controlled, with a `read-only` filesystem permission set as a secondary safeguard.
- **Archived in a fixed format.** Native or vendor-export formats (PST for M365 mail; PST or MBOX for Workspace mail via Vault; JSON for log artifacts) are preferable to converted formats; conversion is post-evidence-archive. Vault converts Google-native Drive files on export (Docs → DOCX, Sheets → XLSX, Slides → PPTX, Drawings → PDF); keep Vault's metadata files and MD5 checksum file alongside your SHA-256 [verify 2026-10-30].
- **Logged in a chain-of-custody table.** Per-export entry: who exported, when, from where, hash, size, recipients, evidence-locker location.
- **Retained per engagement contract.** Cryptographic destruction at engagement end if contract requires; otherwise retained encrypted under engagement-specific keys; litigation-hold provisions per [[sop-legal-ethics|Legal & Ethics]].

For multi-vendor engagements, cross-vendor export naming convention reduces confusion: `<case-id>-<vendor>-<surface>-<YYYY-MM-DD>-<window>.<ext>` (e.g., `case-2026-04-27-m365-ual-2026-04-01-to-2026-04-27.json`).

---

## 13. SaaS-Native IR Tooling

### 13.1 Microsoft

- **Microsoft Sentinel** (when ingesting M365 + Entra ID + DCA) — KQL hunting across SigninLogs, AuditLogs, OfficeActivity, CloudAppEvents, SecurityAlert tables [verify 2026-10-30]. The canonical cross-source query surface for M365-heavy customers.
- **Microsoft Defender XDR** — Advanced Hunting endpoint with `CloudAppEvents`, `AlertInfo`, `EmailEvents`, `EmailAttachmentInfo`, `IdentityLogonEvents`, `IdentityQueryEvents`, `IdentityDirectoryEvents` schemas across Defender for Endpoint / Identity / Cloud Apps / Office [verify 2026-10-30].
- **Microsoft Defender for Cloud Apps** — direct SaaS-anomaly engine; OAuth-app risk scoring; activity browsing across connected apps (M365 and third-party OAuth-connected apps).
- **Microsoft Purview** — unified eDiscovery (searches, including the Content Search case; cases; holds; review sets) + DLP (§4.7-4.8). The classic Content Search and eDiscovery (Standard / Premium) experiences retired on 31 August 2025 [verify 2026-10-30].
- **Microsoft Incident Response (formerly DART)** — first-party IR team available under support contract; can unlock collection paths customer-side tooling cannot [verify 2026-10-30].

### 13.2 Google Workspace

- **Workspace Security Center** (Enterprise Standard / Plus, Education Standard / Plus, Frontline Standard / Plus, Enterprise Essentials Plus; Gmail and Drive data are not available on Enterprise Standard or Frontline Standard) — cross-application investigation tool with security health, dashboard, and investigation tool (filter / pivot across Reports API events from a single UI) [verify 2026-10-30].
- **Workspace Alert Center** — alert feed (suspicious sign-in, leaked passwords, drive sharing alerts, gmail phishing alerts, government-backed attack alerts).
- **Google Security Operations (Google SecOps, formerly Chronicle)** — when ingesting Workspace via the connector, cross-source detection and YARA-L 2.0 rules [verify 2026-10-30].
- **Workspace logs export to GCP** — long-term retention (§5.2) [verify 2026-10-30].

### 13.3 Okta

- **Okta Workflows** — ITP-driven automation; can trigger session-revoke on risk signals [verify 2026-10-30].
- **Okta Identity Threat Protection** — risk-scored identity signals (§6.4) [verify 2026-10-30].
- **Log streaming** — primary long-retention surface (§6.2).

### 13.4 Salesforce

- **Salesforce Shield** — Platform Encryption + Event Monitoring (incl. real-time threat detection and Transaction Security Policies) + Field Audit Trail + Data Detect (§8.2-8.3) [verify 2026-10-30].
- **Salesforce Health Check** — baseline configuration assessment.

### 13.5 Slack

- **Audit Logs API + SIEM ingest** — primary forensic surface (§7.1).
- **Discovery API + DLP** — content-level review when E-Discovery is active.

### 13.6 Open-Source / Vendor-Neutral

| Tool | Purpose | Notes |
|---|---|---|
| Hawk | M365 / Entra ID forensic-data collection PowerShell module | Open-source, community-maintained (T0pCyber); originated with Microsoft Support engineers; a collection tool with basic flagging, not a detector [verify 2026-10-30] |
| Untitled Goose Tool (CISA) | Entra ID / Azure / M365 hunt and IR data collection | CISA-published [verify 2026-10-30] |
| Magnet Axiom Cyber (commercial) | Cloud-workplace acquisition (M365 admin-authorized: mailbox, audit log, OneDrive, SharePoint; other sources per Magnet's support matrix) | Commercial; verify case-fit before licensing [verify 2026-10-30] |
| Cellebrite Endpoint Inspector (commercial) | Remote endpoint + cloud-workplace-app collection (Office 365, Google Workspace, Slack, Box) | Commercial; corporate / eDiscovery-focused [verify 2026-10-30] |
| Aware (Mimecast; commercial) | Slack / Microsoft Teams / Zoom collaboration-data security and compliance | Commercial DLP / discovery [verify 2026-10-30] |
| GAM7 (Workspace) | CLI for Workspace admin operations including audit / Vault | Open-source; community-maintained [verify 2026-10-30] |
| Sigma rules | Vendor-neutral detection rules with M365 / Workspace / Okta / GitHub log-source rule sets | https://github.com/SigmaHQ/sigma; sigma-cli backends convert to KQL, Splunk, Elasticsearch and others [verify 2026-10-30] |
| Splunk SOAR / Cortex XSOAR / Tines / Torq | SOAR platforms with SaaS connectors | Vendor-neutral wrappers around per-vendor APIs |
| BloodHound / AzureHound | Identity-graph extraction (offensive-leaning, useful for understanding the adversary view) | https://github.com/SpecterOps [verify 2026-10-30] |
| ROADtools | Entra ID / M365 enumeration toolkit (read-only modes useful for forensics inventory) | https://github.com/dirkjanm/ROADtools [verify 2026-10-30] |
| Seatbelt / SharpHound (when host telemetry is available) | Host-side identity / token enumeration | Cross-link to [[sop-forensics-investigation|Digital Forensics Investigation]] for host-side forensic use [verify 2026-10-30] |

---

## 14. Hand-off Boundaries

| When the investigation observes... | Routes to... |
|---|---|
| IaaS plane evidence (CloudTrail / Activity Log + Resource Logs / Cloud Audit Logs; IAM forensics on cloud resources; container / Kubernetes runtime audit; cloud-volume snapshot) | [[sop-cloud-forensics|Cloud Forensics]] |
| Email header / SPF / DKIM / DMARC / ARC / wire-recall / lookalike-domain BEC scenario reconstruction | [[sop-email-bec-forensics|Email & BEC Forensics]] |
| OAuth-consent BEC variant (attacker-app token persistence) — **owned by this SOP** | This SOP §10; contrast with header-spoofing BEC routed to [[sop-email-bec-forensics|Email & BEC Forensics]] |
| Cloud-resident malware payload (binary in OneDrive / SharePoint / Drive / Slack / Salesforce Files; OAuth-app code; CI/CD malicious dependency) | [[sop-malware-analysis|Malware Analysis]] |
| Crypto-mining / wallet-stealer payload — on-chain consequences | [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] |
| Mixer / privacy-pool laundering downstream of SaaS-resident wallet drain | [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] |
| Smart-contract code review (post-exploit smart-contract analysis) | [[sop-smart-contract-audit|Smart Contract Audit]] |
| Cryptographic-primitive concern in customer-managed signing key (SAML signing cert, JWT signing key, FIDO2 metadata) | [[sop-cryptography-analysis|Cryptography Analysis]] |
| Identity-provider side (IdP issuing tokens consumed by AWS / Azure / GCP) | [[sop-cloud-forensics|Cloud Forensics]] §3.3 / §7 |
| Identity-consumer side (SAML SP / OIDC RP within SaaS app) | This SOP §11.5 |
| Host / disk / memory parsing of an exported PST / Workspace Takeout / Slack export / GitHub repo clone | [[sop-forensics-investigation|Digital Forensics Investigation]] |
| Authorized offensive SaaS testing (red-team, post-incident validation, purple-team) | [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] §12 SaaS Collaboration Plane |
| SIEM / EDR / cloud-detection coverage validation (purple-team) | [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] |
| 0-day in SaaS service surface (RCE in a managed service) discovered during investigation | [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] + vendor coordinated-disclosure pathway |
| Sensitive-crime indicators (CSAM in OneDrive / Drive / Slack uploads / Salesforce Files; trafficking pattern in cross-tenant comms) | [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — **hard-stop** for CSAM; URL + timestamp only, no content preservation |
| Final reporting / disclosure mechanics | [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] |
| Authorization, jurisdiction, prohibited actions | [[sop-legal-ethics|Legal & Ethics]] |
| Investigator infrastructure / artifact hygiene / pre-disclosure handling | [[sop-opsec-plan|OPSEC]] |

---

## 15. Tools Reference

### Vendor-Native Forensic Surfaces

| Tool | Vendor | Purpose |
|------|--------|---------|
| Search-UnifiedAuditLog | M365 | Legacy synchronous UAL query (Exchange Online PowerShell; 100 results by default; `-SessionCommand` is required for more, and `ReturnLargeSet` pages up to 50,000) [verify 2026-10-30] |
| Audit Search Graph API | M365 | Async UAL query (Audit (Standard) and Audit (Premium)) [verify 2026-10-30] |
| Search-MailboxAuditLog | M365 | Being deprecated in Exchange Online — use `Search-UnifiedAuditLog -RecordType ExchangeItem` (plus ExchangeItemGroup / ExchangeItemAggregated) [verify 2026-10-30] |
| Microsoft Graph PowerShell SDK | M365 | Scriptable Graph access including `oauth2PermissionGrants`, `servicePrincipals` |
| Microsoft Sentinel | M365 | KQL-based SIEM with M365 + Entra ID connectors |
| Defender XDR Advanced Hunting | M365 | KQL across Defender product family |
| Defender for Cloud Apps | M365 | SaaS-anomaly engine + OAuth-app risk |
| Microsoft Purview eDiscovery | M365 | Unified eDiscovery: searches (incl. the Content Search case), cases, holds, review sets, export [verify 2026-10-30] |
| Workspace Reports API | Google Workspace | Per-application activity feeds |
| GAM7 | Google Workspace | CLI wrapper for Reports API + Vault + admin [verify 2026-10-30] |
| Workspace logs export to BigQuery | Google Workspace | Long-term audit retention [verify 2026-10-30] |
| Gmail BigQuery export | Google Workspace | Full mail-flow events |
| Workspace Vault | Google Workspace | eDiscovery + holds |
| Workspace Security Center | Google Workspace | Cross-application investigation tool |
| Google SecOps (formerly Chronicle) | Google Workspace | Cloud-native SIEM (YARA-L 2.0) [verify 2026-10-30] |
| Okta System Log API | Okta | Identity event audit |
| Okta Workflows | Okta | Automation / response to ITP signals [verify 2026-10-30] |
| Slack Audit Logs API | Slack | Org-level audit (Enterprise plan) [verify 2026-10-30] |
| Slack Discovery API | Slack | Content E-Discovery |
| Salesforce Setup Audit Trail | Salesforce | 180-day setup-change audit [verify 2026-10-30] |
| Salesforce Real-Time Event Monitoring | Salesforce | Streaming / long-retention event log (Shield) |
| Salesforce EventLogFile | Salesforce | Daily log files (available the next day); without the add-on only a free subset (e.g. Login, Logout, API Total Usage) with 1-day retention; hourly files (3-6 h lag) and the full event set need Shield / Event Monitoring [verify 2026-10-30] |
| Salesforce Threat Detection | Salesforce | ML anomaly detection (Shield) [verify 2026-10-30] |
| GitHub Audit Log API | GitHub | Org / enterprise audit events [verify 2026-10-30] |
| GitHub Audit Log streaming | GitHub | Long-term retention to S3 / Splunk / Datadog / etc. [verify 2026-10-30] |
| GitLab Audit Events API | GitLab | Group / instance audit events |

### Open-Source / Vendor-Neutral

| Tool | Purpose | Link |
|------|---------|------|
| Hawk | Community-maintained M365 / Entra ID forensic-collection PowerShell module (originated with Microsoft Support engineers) | https://github.com/T0pCyber/hawk [verify 2026-10-30] |
| Untitled Goose Tool | CISA hunt / IR collection for Entra ID, Azure and M365 | https://github.com/cisagov/untitledgoosetool [verify 2026-10-30] |
| GAM7 | Workspace admin / audit CLI | https://github.com/GAM-team/GAM [verify 2026-10-30] |
| Sigma | Vendor-neutral detection rules | https://github.com/SigmaHQ/sigma [verify 2026-10-30] |
| ROADtools | Entra ID / M365 enumeration | https://github.com/dirkjanm/ROADtools [verify 2026-10-30] |
| BloodHound | Identity-graph (AD + Entra); BloodHound Community Edition | https://github.com/SpecterOps/BloodHound [verify 2026-10-30] |
| AzureHound | Entra ID / Azure data collector for BloodHound | https://github.com/SpecterOps/AzureHound [verify 2026-10-30] |
| TeamFiltration | M365 / Entra ID enumeration, password-spraying, exfiltration and backdooring framework (offensive; useful for understanding the adversary view) | https://github.com/Flangvik/TeamFiltration [verify 2026-10-30] |
| MicroBurst | Azure security-assessment scripts | https://github.com/NetSPI/MicroBurst [verify 2026-10-30] |

### Reference / Documentation

| Resource | Purpose |
|----------|---------|
| Microsoft Purview audit log activities | https://learn.microsoft.com/purview/audit-log-activities [verify 2026-10-30] |
| Microsoft Graph audit logs | https://learn.microsoft.com/graph/api/resources/auditlogroot [verify 2026-10-30] |
| Workspace Reports API reference | https://developers.google.com/workspace/admin/reports/reference/rest [verify 2026-10-30] |
| Workspace Vault API reference | https://developers.google.com/workspace/vault/reference/rest [verify 2026-10-30] |
| Okta System Log reference | https://developer.okta.com/docs/api/openapi/okta-management/management/tags/systemlog [verify 2026-10-30] |
| Slack Audit Logs API | https://docs.slack.dev/admins/audit-logs-api/ [verify 2026-10-30] |
| Slack Discovery API | https://slack.com/help/articles/360002079527-A-guide-to-Slacks-Discovery-APIs [verify 2026-10-30] |
| Salesforce Setup Audit Trail | https://help.salesforce.com/s/articleView?id=sf.admin_monitorsetup.htm [verify 2026-10-30] |
| Salesforce Event Monitoring | https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/event_monitoring.htm |
| GitHub audit log reference | https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization [verify 2026-10-30] |
| MITRE ATT&CK Enterprise cloud matrices (Office Suite + Identity Provider + SaaS + IaaS) | https://attack.mitre.org/matrices/enterprise/cloud/ [verify 2026-10-30] |
| MITRE ATT&CK Identity Provider matrix | https://attack.mitre.org/matrices/enterprise/cloud/identityprovider/ [verify 2026-10-30] |
| CISA SCuBA (Secure Cloud Business Applications) | https://www.cisa.gov/resources-tools/services/secure-cloud-business-applications-scuba-project — M365 / Workspace secure configuration baselines (ScubaGear / ScubaGoggles) [verify 2026-10-30] |
| NIST SP 800-86 | Guide to Integrating Forensic Techniques into Incident Response [verify 2026-10-30] |
| NIST SP 800-61 Rev. 3 | Incident Response Recommendations and Considerations for Cybersecurity Risk Management: A CSF 2.0 Community Profile (April 2025; supersedes Rev. 2) [verify 2026-10-30] |

---

## 16. Risks & Limitations

- **Retention is a structural limit.** Default retention floors (UAL Standard 180-day, Okta 90-day, Salesforce SAT 180-day, Slack workspace-set, GitHub ~6 months) bound the maximum reachable evidence window when long-term export is not configured. Investigations initiated past the floor are reconstructions, not reproductions; document the gap [verify 2026-10-30].
- **License-tier gates.** UAL Audit (Premium) (1-year default retention, the 10-year add-on, audit-log retention policies, search-query events, and intelligent-insight properties such as `SensitivityLabel` on `MailItemsAccessed`; `MailItemsAccessed` and `Send` themselves are Audit (Standard) events on E3 / E5), Salesforce Shield (Real-Time Event Monitoring + Threat Detection + Field Audit Trail), Slack Enterprise plan (Audit Logs API), GitHub Enterprise (full audit + log streaming), Workspace Security Center (Enterprise / Education / Frontline editions; Gmail and Drive data not on Enterprise Standard or Frontline Standard) are paywalls. Customers without the relevant tier cannot retrieve the relevant events; the investigator cannot retroactively buy them in [verify 2026-10-30].
- **Data-plane logging gaps.** Per-mail-item, per-file, per-message access events are opt-in or paywalled across most SaaS surfaces. Without them, "did the attacker read mail X?" cannot be answered from logs alone — only "did the attacker access the mailbox?"
- **Provider-side log latency.** UAL audit records are typically available 60-90 minutes after the event for core services (Exchange, SharePoint, OneDrive, Teams), later for other services or during outages, and Microsoft doesn't commit to a specific time [verify 2026-10-30]. Workspace Reports API events have variable latency. Real-time alerting and forensic reconstruction tolerate this differently — the investigator must not infer "the event did not happen" from a same-millisecond gap.
- **API-throttling under stress.** Aggressive forensic queries against a production tenant can hit per-user, per-token, or per-tenant rate limits, particularly during an active incident. Use bulk-export paths (eDiscovery, Vault, BigQuery export, log streaming) over high-cardinality API loops.
- **Evidence-spoliation risk during investigation.** Querying mailboxes, files, or repositories can change `LastAccessTime` or trigger user-visible notifications (e.g., Workspace "someone shared with you" or Slack "added to channel" telemetry). Read-only API paths are preferred over UI-driven access.
- **Cross-tenant log visibility is asymmetric.** A cross-tenant collaboration event (Slack Connect, Workspace external sharing, Entra B2B) appears on both sides, but the investigator typically only authorized for one side. The other tenant's audit is reachable only via provider legal process.
- **Court-admissibility framing.** SaaS-evidence Daubert posture is well-trodden for M365 / Workspace eDiscovery exports with provider declarations, but less so for Reports API / System Log / Audit Logs API outputs that did not pass through an eDiscovery or Vault hold. The hold-then-search discipline (§12) addresses this; raw API pulls without prior hold may face hearsay / authentication challenges.
- **Adversary log-aware behavior.** Sophisticated SaaS-incident operators target audit configuration — disabling UAL ingestion at the org level (where tier permits), shortening Okta log-streaming, narrowing Workspace logs export filter, revoking Slack audit tokens. The defensive answer is real-time alerting on configuration changes themselves and out-of-tenant log ingest beyond the suspect's reach.
- **Multi-tenant blast radius.** SaaS-incident scope balloons via shared infrastructure (a multi-tenant OAuth app abused across many customer tenants; a Slack Connect channel that touches a dozen organizations; an upstream identity provider that federates into hundreds of customer orgs). Initial scope estimates often understate the surface.
- **Evidence integrity end-to-end.** A SHA-256 hash at export proves nothing about the source-side integrity (the audit log writer could already have been compromised, or the provider could have a bug). UAL, eDiscovery, and Vault have provider-side declarations that pair with the customer-side hash; raw Reports API / System Log / Audit Logs API pulls do not carry a provider-signed integrity chain.
- **Tenant-deletion is a hard floor.** When an entire tenant or org is deleted (rare but happens during regulator-directed examinations), cold-recovery windows are short and provider-controlled. Engagement-time inventory and hold are the only durable mitigation.
- **OAuth-app revocation is not retroactive.** Revoking an attacker-controlled OAuth app stops *future* token use, but issued access tokens may continue to work until expiry (Entra ID default: a random 60-90 minutes; up to 24-28 hours for CAE-capable clients) and the data already exfiltrated is gone. Revocation is containment, not evidence preservation [verify 2026-10-30].

---

## 17. Common Pitfalls

- **Treating an alert as the scope.** The alert fired on one user; the incident touched a half-dozen mailboxes via a delegated-permission OAuth app you didn't query.
- **Relying on portal "last 30 days" surfaces.** Entra ID portal sign-in default view is short; UAL portal search has lower record-type coverage than the cmdlet; Slack admin UI surfaces a small slice of audit. Programmatic API access is the forensic-grade surface.
- **Skipping retention sampling.** Promising a 6-month reconstruction without confirming what evidence actually exists is a recipe for an embarrassing day-3 update.
- **Querying without time-zone discipline.** UAL is UTC; Workspace Reports is UTC; Okta is UTC; Slack is Unix epoch (UTC); Salesforce is timezone-tagged ISO 8601; GitHub is UTC. Mixing offsets across vendors corrupts the unified timeline.
- **Paginating Search-UnifiedAuditLog wrong.** Default is 100 results and `-SessionCommand` is required for more (5,000 per call max); `-SessionCommand ReturnLargeSet` pages up to 50,000 unsorted results [verify 2026-10-30]. Above that, split the time window; for scripted bulk export Microsoft recommends the Office 365 Management Activity API over the cmdlet.
- **Ignoring sign-ins from service principals / managed identities.** Service-principal sign-in volume dwarfs user volume; filtering them out as noise hides the human-driven actions; not separating them as a distinct surface hides automated abuse.
- **Treating Defender for Cloud Apps / Workspace Alert Center / Salesforce Threat Detection findings as ground truth.** They are findings, not facts. Validate each against the underlying log evidence.
- **Conflating UAL `Consent to application` with `Add app role assignment to service principal`.** The first is delegated-permission consent; the second is application-permission grant. Application permissions are the higher-risk class and frequently require admin consent.
- **Skipping the inbox-rule sweep.** Mailbox-rule forensics is a 30-second query that catches one of the most common BEC persistence primitives.
- **Treating an OAuth-app revocation as forensic preservation.** Revocation is containment. Capture the app's metadata, granted scopes, recent activity, and consent timeline *before* revocation, and preserve in evidence.
- **Relying on user-side behavior (e.g., browser history) when SaaS audit suffices.** SaaS audit is more authoritative and less easily destroyed than client-side artifacts.
- **Pre-filtering the export.** Filtering at the API call ("only events where `eventName=download`") loses context (the surrounding events that explain *why* the user was downloading). Pull broad, filter at analysis time.
- **Mixing eDiscovery export and Vault export across cases.** Per-case exports must be kept distinct; cross-case export contamination is a chain-of-custody problem.
- **Hashing late.** The hash must be the first action after export, before the artifact lands on any analysis disk.
- **Not collecting both sides of a Slack Connect / B2B / external-sharing event.** Single-side audit is incomplete; provider legal process is the route for the unauthorized side.
- **Letting end users discover the investigation.** Workspace "shared with you" notifications, Slack "X added you to a channel" pings, Salesforce "an admin viewed your record" emails (some configurations) all leak the investigator's footprint. Read-only APIs and dedicated investigator tokens reduce this surface.
- **Using a personal admin account for the investigation.** Audit-log review by an admin account that also has business-as-usual administrative duties contaminates the audit trail. Issue an engagement-scoped admin identity at engagement start.
- **Over-reading `MailItemsAccessed` gaps.** A `Sync` record means a client downloaded the folder, and reads after an offline sync never reach the audit log; only `Bind` records give per-message reads. The `IsThrottled` throttling Microsoft once described is no longer on its current MailItemsAccessed investigation page, so confirm it with Microsoft before relying on it. Don't infer "no access" from a missing per-item record [verify 2026-10-30].
- **Skipping the OAuth-app inventory baseline.** Without a pre-engagement inventory, post-engagement detection of newly added OAuth apps is harder to distinguish from legitimate business activity.
- **Pasting raw event JSON into the report.** Tooling output is appendix material; findings are interpreted prose with referenced evidence IDs.
- **Stale credentials and tokens in investigator notes.** Engagement tokens (UAL admin token, GAM7 service-account key, Okta API token, Slack audit token, GitHub PAT) become a future-engagement liability. Rotate and document destruction at engagement end.

---

## 18. Real-World Scenarios

The scenarios below abstract observed SaaS-incident patterns to illustrate how the methodology in this SOP applies. They are pattern catalogues, not engagement-specific narratives.

### 18.1 Scenario — OAuth-Consent BEC: Multi-Tenant Attacker App Harvests Mailbox Tokens

**Pattern.** Attacker registers a multi-tenant Entra ID app named `Microsoft 365 Mail Helper` with a Microsoft logo. The attacker phishes a target organization with a link to `https://login.microsoftonline.com/common/oauth2/v2.0/authorize?...` requesting `Mail.Read` and `offline_access` scopes. A user clicks "Accept." The attacker's app receives access + refresh tokens, then over weeks reads inbound mail looking for invoice / wire / payment-confirmation patterns. When a wire-confirmation email arrives, the attacker creates an inbox rule via the *user's own session* (the access token grants Mail.ReadWrite if the scope was broad enough; otherwise via a session-token replay) to auto-forward incoming wire confirmations to an external address. The actual wire-fraud BEC pivots from there — but the lookalike-domain / header-spoofing piece is in [[sop-email-bec-forensics|Email & BEC Forensics]] per the trio split.

**Forensic catch.** §10.2 OAuth grant inventory surfaces the suspicious app. §4.4 `Consent to application` UAL events show the consent action with user, source IP, and timestamp. §4.4 `MailItemsAccessed` events (Audit (Standard); on by default for E3 / E5 users) show per-mail-item reads tied to the app's `AppId` [verify 2026-10-30]. §4.6 inbox-rule events identify the persistent auto-forward. §13.1 Defender for Cloud Apps OAuth-app risk score may have flagged the app pre-incident; verify whether the alert was suppressed.

**Hand-off.** Mailbox-content review for the actually-compromised mailboxes routes through Purview eDiscovery (§4.7). Wire-recall pathway and lookalike-domain analysis (if the attacker also spoofed a vendor domain) routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. Adversary multi-tenant app take-down coordination (a Microsoft-managed app revocation across all victim tenants) routes through MSRC.

### 18.2 Scenario — Credential-Phishing Mailbox Compromise → BEC Inbox-Rule Pivot

**Pattern.** Attacker phishes a user with a credential-harvest page that proxies the M365 sign-in flow (adversary-in-the-middle / EvilGinx-style). MFA is bypassed because the attacker captures the post-MFA session token, not the credentials alone. Attacker authenticates from a residential-proxy IP, immediately creates an inbox rule that moves any mail with subject containing "wire," "invoice," or "payment" to RSS Feeds (a low-visibility folder), and waits. When the rule fires, the attacker reads the moved mail via the captured session, replies from the user's mailbox to the wire-counterparty with updated routing details.

**Forensic catch.** §4.2 sign-in event from anomalous IP / ASN / device. §4.2 inbox-rule creation event correlated with the suspicious sign-in. §4.5 mailbox-audit `Send` events from the attacker session showing replies to the wire counterparty. §4.4 `MailItemsAccessed` (Audit (Standard); on by default for E3 / E5 users) shows the attacker reading the moved mail. §13.1 Defender for Cloud Apps suspicious-mailbox-rule alert is the typical detector. §13.1 Sentinel KQL hunt: `OfficeActivity | where Operation in ("New-InboxRule", "Set-InboxRule") | where Parameters has_any ("RSS Feeds", "Junk Email")` [verify 2026-10-30].

**Hand-off.** Header-forensic verification of the attacker's outbound replies (was the From-header spoofed; did the recipient's MTA mark DKIM-pass; what was the SPF posture) routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. Wire-recall mechanics route to [[sop-email-bec-forensics|Email & BEC Forensics]]. Adversary-in-the-middle phishing-page take-down routes through provider abuse + DNS-takedown coordination per [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]].

### 18.3 Scenario — Workspace External-Sharing Data Exfil via Compromised Account

**Pattern.** Insider with departing-employee disposition, or compromised employee account, modifies dozens of Drive documents to be shared with an external `gmail.com` address. Documents are sensitive (contract, customer list, strategic roadmap). The share events are visible in the Reports API `drive` feed.

**Forensic catch.** §5.1 / §5.5 Reports API `drive` `change_user_access` events to external domains. §5.1 `download` events from the external account (when the same account also appears as `actor` in subsequent reads — typically only if the external account is also Workspace-managed and the customer has cross-domain visibility, otherwise inferable only from share events). §5.4 Vault matter scoped to the user surfaces full content for review. §5.6 forwarding-rule sweep ensures no parallel email-forwarding persistence is in place.

**Hand-off.** External-account attribution (Gmail address registration date, recovery info, prior breach exposure) routes to [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] + [[../../Investigations/Techniques/sop-darkweb-investigation|Darkweb Investigation]] (if the address surfaces in known breach corpora). Human-resources investigation pathway is the customer's, not the investigator's.

### 18.4 Scenario — GitHub PAT Compromise → CI/CD Secret Theft → Cloud Pivot

**Pattern.** A developer's GitHub fine-grained PAT is exfiltrated via a compromised laptop. Attacker enumerates the user's accessible repos, identifies a repo with GitHub Actions workflows that grant cloud access via Workload Identity Federation, modifies the workflow to add a step that exfiltrates the OIDC token's downstream cloud session credentials. The next CI run pushes the credentials to attacker-controlled S3.

**Forensic catch.** §9.1-9.2 GitHub audit log: `personal_access_token.access_granted` + `repo.add_member` (if PAT is scoped to repo membership) + `git.push` events on the affected repo (when Git events streaming is configured). §9.4 GitHub Actions workflow run history shows the modified workflow execution (retention defaults to 90 days and is configurable 1-400 days on private repos; since 1 October 2026 the setting also covers workflow runs, so confirm the org / repo value) [verify 2026-10-30]. Cross-cloud pivot reconstruction — the WIF token consumed in AWS / Azure / GCP — routes to [[sop-cloud-forensics|Cloud Forensics]] §7.5 cross-cloud Workload Identity Federation reconstruction.

**Hand-off.** Compromised-laptop forensics routes to [[sop-forensics-investigation|Digital Forensics Investigation]] for endpoint disk / memory analysis. Cloud-side IAM forensics + region sweep + log-tampering detection route to [[sop-cloud-forensics|Cloud Forensics]] §4-§9. Pipeline / supply-chain hardening recommendations route to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] for purple-team validation.

### 18.5 Scenario — Salesforce Admin-Impersonation via Login-As

**Pattern.** Attacker compromises a Salesforce administrator. Salesforce's `Login As` feature lets admins impersonate any user for support purposes. Attacker uses Login As to assume identities of executives, browses sensitive opportunities and contracts, and exports records via the Data Loader API.

**Forensic catch.** §8.2 RTEM `LoginAsEvent` (Shield / Event Monitoring add-on) records each Login-As session with `SourceIp` and `DelegatedUsername` (the impersonated user); §8.1 SAT rows with `DelegateUser` populated show Setup changes made by the admin on another user's behalf. §8.2 RTEM `BulkApiResultEvent` / `ApiEvent` / `ReportEvent` show data-export volume from the impersonated session [verify 2026-10-30]. §8.4 Login History identifies the original admin sign-in pattern that preceded the impersonation chain.

**Hand-off.** Source-of-compromise for the admin account (was it credential phishing, was it a supply-chain admin tool compromise, was it OAuth-token theft via a Connected App) loops back to §10 OAuth Consent-Grant Abuse Forensics or routes to [[sop-email-bec-forensics|Email & BEC Forensics]] if the admin's mailbox is the lateral surface. Customer-records breach-notification scoping routes to [[sop-legal-ethics|Legal & Ethics]] for state and sectoral notification clocks.

---

## 19. Related SOPs

**Analysis (parent and adjacent):**
- [[sop-cloud-forensics|Cloud Forensics]] — sibling SOP covering the IaaS plane (CloudTrail / Activity Log / Cloud Audit Logs / IAM forensics on cloud resources). This SOP and #7 share the forensics-trio scope contract: hybrid incidents that touch both planes are split at the action level, with identity events referenced from both sides.
- [[sop-forensics-investigation|Digital Forensics Investigation]] — parent template; host / disk / memory forensics methodology applied to artifacts produced by SaaS exports (PST / Workspace Takeout / Slack export / GitHub repo clone).
- [[sop-malware-analysis|Malware Analysis]] — receives hand-off for SaaS-resident payloads (binaries in OneDrive / SharePoint / Drive / Slack / Salesforce Files; OAuth-app code; CI/CD malicious dependencies).
- [[sop-hash-generation-methods|Hash Generation Methods]] — evidence-integrity hashing for audit-log exports, eDiscovery / Vault packages, and analysis derivatives.
- [[sop-cryptography-analysis|Cryptography Analysis]] — when SaaS-resident signing keys (SAML signing certificates, JWT signing keys, FIDO2 metadata) require primitive review.
- [[sop-smart-contract-audit|Smart Contract Audit]] — when SaaS-resident credentials lead to on-chain consequences.
- [[sop-reverse-engineering|Reverse Engineering]] — when SaaS-resident binaries require deep static / dynamic analysis.
- [[sop-email-bec-forensics|Email & BEC Forensics]] — sibling SOP completing the forensics trio. Per the buildout-plan scope contract, header-spoofing / lookalike-domain / wire-fraud BEC scenario reconstruction lives in #9; the OAuth-consent BEC variant lives in this SOP §10. Hybrid BEC incidents that pivot through mailbox compromise are split: the *messages* live in #9, the *mailbox audit* lives here.

**Pentesting (offensive counterparts):**
- [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] — closest tooling counterpart; offensive cloud testing's threat model overlaps with SaaS-tenant compromise patterns covered defensively here.
- [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] — SIEM / SaaS-detection coverage validation; purple-team validation of UAL / Reports / System Log alerting.
- [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] — for 0-day discovery in SaaS service surfaces during investigation.
- [[../Pentesting/sop-web-application-security|Web Application Security]] — when the initial vector is a web-app vulnerability in a SaaS-integrated application.

**Investigations (cross-domain):**
- [[../../Investigations/Techniques/sop-collection-log|Collection Log]] — canonical chain-of-custody and evidence-hashing workflow for every SaaS export.
- [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] — when SaaS-resident credentials lead to on-chain consequences.
- [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] — when on-chain consequences route through mixers / privacy pools.
- [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — fiat AML, banking pivots, corporate UBO when SaaS findings touch payment / wire infrastructure.
- [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] — when adversary infrastructure (phishing landing pages, OAuth-app reply URLs, exfil destinations) requires clearnet pivot analysis.
- [[../../Investigations/Techniques/sop-darkweb-investigation|Darkweb Investigation]] — when SaaS-resident credentials surface in marketplace / forum / leak-site contexts.
- [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] — for dossier compilation on identified threat actors.
- [[../../Investigations/Techniques/sop-image-video-osint|Image / Video OSINT]] — for analysis of screenshot evidence captured during the engagement.
- [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — for CSAM / trafficking / threat-to-life findings (hard-stop routing).
- [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — for disclosure mechanics and coordinated publication.

**Cross-cutting:**
- [[sop-legal-ethics|Legal & Ethics]] — canonical jurisdictional framework, breach-notification timelines, cross-border data-transfer constraints.
- [[sop-opsec-plan|OPSEC]] — investigator infrastructure, artifact hygiene, and pre-disclosure handling discipline.

---

## Legal & Ethical Considerations

> Canonical jurisdictional framework lives in [[sop-legal-ethics|Legal & Ethics]]. The summary below is operational guidance for SaaS-forensics engagements specifically; do not substitute it for the cross-referenced source.

### Authorization

- **Tenant-administrator authorization** is the typical engagement authority. The tenant owner authorizes the investigator's read-only role, eDiscovery / Vault access, and any state-changing actions (OAuth-app revocation, mailbox-rule disablement, user-account suspension). Without it, the investigator's access is unauthorized regardless of the suspect's behavior.
- **Provider legal process** is the route for cross-tenant evidence (tenant A is suspect, tenant B is victim). Subpoena / warrant / MLAT / preservation letter to Microsoft / Google / Slack / Salesforce / Okta / GitHub. Provider-published LE guidelines define the form. [verify 2026-10-30]
- **Cross-jurisdiction authorization.** EU-data, healthcare, payment, and government-tenant workloads can carry residency / sovereignty constraints that limit cross-border evidence transfer even with tenant authorization. Schrems II / DPF / SCCs framing, CLOUD Act executive agreements, and the Budapest Convention Second Additional Protocol (CETS 224; not yet in force — four of the five required ratifications as of April 2026) shape MLAT alternatives. Verify under counsel [verify 2026-10-30].
- **Engagement scope drift.** SaaS incidents tend to expand mid-engagement (initial scope: one mailbox; mid-engagement scope: a tenant with hundreds of compromised mailboxes via an OAuth-app, plus three Slack workspaces, plus a GitHub org). Any scope expansion needs documented re-authorization.

### Anti-Hacking Statute Framing

SaaS-forensics actions are typically read-only against tenants the investigator is authorized to access — far inside the CFAA / Computer Misuse Act / Cybercrime Directive lines. Specifically:

- **Read-only collection within authorized tenants** — allowed.
- **State-changing actions (eDiscovery hold, OAuth-app revocation, user-account disablement, inbox-rule deletion, mailbox-content export)** — allowed only when the engagement explicitly authorizes them; document each action with attribution.
- **Pivoting into adversary infrastructure observed during the investigation** — generally **not** authorized. "We saw the attacker's IP — let's port-scan their VPS" or "we saw the attacker's OAuth-app tenant — let's enumerate it" crosses into unauthorized access. Attribution and intelligence are valuable; offensive pivots are not the investigator's job. Route adversary-infrastructure findings through threat-intel channels and provider abuse pathways.
- **Active-defense actions** (sinkhole the attacker's reply URL, beacon canary documents, deploy honeytoken credentials) — verify under counsel before any deployment; actions framed as "defensive" can be charged as offensive in some jurisdictions.

### Data-Subject and Privacy Considerations

- **GDPR Art. 6 / 9** — processing of personal data during investigation requires a lawful basis; legitimate interest is the typical basis but is balanced against data-subject rights. Mailbox / Drive / Slack content frequently contains special-category data; Art. 9 balancing is non-trivial.
- **GDPR Art. 33** — supervisory-authority notification within 72 hours of becoming aware of a personal-data breach.
- **GDPR Art. 34** — data-subject notification when the breach is high-risk to the data subjects. SaaS compromises that exposed mailbox / Drive / Slack DM content frequently meet the high-risk bar.
- **HIPAA Breach Notification Rule** — covered entities + business associates have 60-day notification windows. SaaS tenants holding ePHI (M365 / Workspace under BAA, Salesforce under HIPAA-covered configuration) trigger this rule on compromise [verify 2026-10-30].
- **State breach laws** (US) — varies by state; California (CCPA / CPRA), New York (SHIELD), and many others have specific timelines and requirements.
- **PCI DSS Incident Response Plan** — required for cardholder-data environments; SaaS tenants holding CHD trigger this even when the storage is provider-managed.
- **Sectoral rules** — finance (NYDFS Part 500, FFIEC, EBA / DORA), healthcare (HIPAA, NIS2 in EU), telecom — verify per engagement.

### Disclosure Discipline

- Pre-disclosure findings are restricted to the engagement team and the client per the engagement contract.
- Findings affecting third parties (a customer's API key found in a SharePoint document; a vendor's PAT abused; an upstream multi-tenant OAuth app abused across many customer tenants) are escalated through the affected party's security contact, not embedded silently in the client's report.
- Vendor coordination is sometimes warranted (provider-resident vulnerability in service surface; widespread credential-leak indicator). MSRC, Google VRP, GitHub Bug Bounty, Salesforce Security Response, Okta Security each publish coordinated-disclosure paths.
- Live-incident findings (the investigation discovers an active exploit on a tenant the investigator does not own and is not authorized for) trigger immediate client escalation; the operational response is the client's, not the investigator's, unless explicitly contracted.

### Conflict-of-Interest Posture

- The investigator does not hold or trade securities of the affected entity during the engagement window.
- The investigator does not publish independent commentary on the engagement's substance during the engagement window.
- The investigator discloses any prior or concurrent engagements with adjacent parties (the affected entity's vendors, customers, competitors) before commencing.

### Post-Engagement Records

- Engagement repo + analysis artifacts retained per contract terms (typically 1-7 years; sometimes longer for litigation-hold cases).
- eDiscovery / Vault exports retained per evidence-handling policy (cryptographically destroyed at engagement end if the contract requires; otherwise retained encrypted under engagement-specific keys).
- PoC / hunting scripts retained encrypted at rest per [[sop-opsec-plan|OPSEC]].
- Investigator engagement-scoped tokens (UAL admin, GAM7 service account, Okta API, Slack audit, GitHub PAT) rotated and destroyed at engagement end. Document the destruction.
- Litigation-hold provisions: if the affected tenant is later subject to litigation, prior engagement material can become discoverable. Document engagement decisions accordingly.

### Ethical Research Checklist

**Before engagement:**
- [ ] Written engagement contract (or internal IR activation) defining scope, time, deliverable, disclosure
- [ ] Tenant-admin authorization for read-only access; documented authority for state-changing actions
- [ ] Counsel review of cross-border data-transfer constraints
- [ ] Conflict-of-interest disclosure complete

**During engagement:**
- [ ] Only access in-scope tenants; only act per scope
- [ ] Hash artifacts at acquisition; pair with provider-side declarations where available (eDiscovery / Vault)
- [ ] Maintain chain-of-custody record per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]
- [ ] No pivots into adversary infrastructure
- [ ] No disclosure to non-engagement parties without explicit authorization

**After engagement:**
- [ ] Report delivered per contract
- [ ] Notification clocks (GDPR / SEC / state laws / sectoral) met under counsel direction
- [ ] eDiscovery / Vault exports / log artifacts / analysis derivatives handled per evidence-retention policy
- [ ] Engagement tokens / admin roles rotated / revoked

---

## 20. External & Reference Resources

**Vendor-specific forensics and audit documentation:**
- Microsoft — Purview audit log activities — https://learn.microsoft.com/purview/audit-log-activities [verify 2026-10-30]
- Microsoft — Purview eDiscovery — https://learn.microsoft.com/purview/edisc [verify 2026-10-30]
- Microsoft — Audit Search Graph API — https://learn.microsoft.com/graph/api/resources/security-auditlogquery [verify 2026-10-30]
- Microsoft — Defender for Cloud Apps documentation — https://learn.microsoft.com/defender-cloud-apps/ [verify 2026-10-30]
- Microsoft — Security Blog, incident response topic — https://www.microsoft.com/en-us/security/blog/topic/incident-response/ [verify 2026-10-30]
- Google — Workspace Reports API reference — https://developers.google.com/workspace/admin/reports/reference/rest [verify 2026-10-30]
- Google — Vault API reference — https://developers.google.com/workspace/vault/reference/rest [verify 2026-10-30]
- Google — Workspace logs export to BigQuery — https://knowledge.workspace.google.com/admin/reports/set-up-service-log-exports-to-bigquery [verify 2026-10-30]
- Okta — System Log API reference — https://developer.okta.com/docs/api/openapi/okta-management/management/tags/systemlog [verify 2026-10-30]
- Okta — Identity Threat Protection — https://help.okta.com/oie/en-us/content/topics/itp/overview.htm [verify 2026-10-30]
- Slack — Audit Logs API — https://docs.slack.dev/admins/audit-logs-api/ [verify 2026-10-30]
- Slack — Discovery API — https://slack.com/help/articles/360002079527-A-guide-to-Slacks-Discovery-APIs [verify 2026-10-30]
- Salesforce — Setup Audit Trail — https://help.salesforce.com/s/articleView?id=sf.admin_monitorsetup.htm [verify 2026-10-30]
- Salesforce — Event Monitoring (EventLogFile via REST) — https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/event_monitoring.htm
- Salesforce — Threat Detection — https://help.salesforce.com/s/articleView?id=sf.real_time_em_threat_detection.htm [verify 2026-10-30]
- GitHub — Audit log for organizations — https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization [verify 2026-10-30]
- GitHub — Audit log streaming — https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/streaming-the-audit-log-for-your-enterprise [verify 2026-10-30]
- GitLab — Audit events documentation — https://docs.gitlab.com/user/compliance/audit_events/ (API: https://docs.gitlab.com/api/audit_events/) [verify 2026-10-30]

**Standards and frameworks:**
- NIST SP 800-86 — Guide to Integrating Forensic Techniques into Incident Response [verify 2026-10-30]
- NIST SP 800-53 Rev. 5 — Security and Privacy Controls for Information Systems and Organizations; NIST SP 800-171 Rev. 3 — Protecting Controlled Unclassified Information in Nonfederal Systems and Organizations [verify 2026-10-30]
- NIST SP 800-61 Rev. 3 — Incident Response Recommendations and Considerations for Cybersecurity Risk Management: A CSF 2.0 Community Profile (April 2025; supersedes Rev. 2) — https://csrc.nist.gov/pubs/sp/800/61/r3/final [verify 2026-10-30]
- ISO/IEC 27037:2012 — Guidelines for identification, collection, acquisition and preservation of digital evidence [verify 2026-10-30]
- ISO/IEC 27041:2015 — Guidance on assuring suitability and adequacy of incident investigative method [verify 2026-10-30]
- ISO/IEC 27042:2015 — Guidelines for the analysis and interpretation of digital evidence [verify 2026-10-30]
- ISO/IEC 27043:2015 — Incident investigation principles and processes [verify 2026-10-30]
- CSA Cloud Controls Matrix — https://cloudsecurityalliance.org/research/cloud-controls-matrix/ [verify 2026-10-30]
- CIS Microsoft 365 Foundations Benchmark — https://www.cisecurity.org/benchmark/microsoft_365 [verify 2026-10-30]
- CIS Google Workspace Foundations Benchmark — https://www.cisecurity.org/benchmark/google_workspace [verify 2026-10-30]
- MITRE ATT&CK Enterprise cloud matrices (Office Suite + Identity Provider + SaaS + IaaS) — https://attack.mitre.org/matrices/enterprise/cloud/ [verify 2026-10-30]
- MITRE ATT&CK Identity Provider matrix — https://attack.mitre.org/matrices/enterprise/cloud/identityprovider/ [verify 2026-10-30]
- CISA SCuBA (Secure Cloud Business Applications) — M365 + Workspace secure configuration baselines — https://www.cisa.gov/resources-tools/services/secure-cloud-business-applications-scuba-project [verify 2026-10-30]
- Berkeley Protocol on Digital Open Source Investigations (UN OHCHR + UC Berkeley HRC, 2022) — for human-rights / open-source intelligence dimensions where applicable [verify 2026-10-30]

**Open-source projects and tools:**
- Hawk — https://github.com/T0pCyber/hawk [verify 2026-10-30]
- Untitled Goose Tool (CISA) — https://github.com/cisagov/untitledgoosetool [verify 2026-10-30]
- GAM7 — https://github.com/GAM-team/GAM [verify 2026-10-30]
- Sigma — https://github.com/SigmaHQ/sigma [verify 2026-10-30]
- ROADtools — https://github.com/dirkjanm/ROADtools [verify 2026-10-30]
- BloodHound (Community Edition) — https://github.com/SpecterOps/BloodHound [verify 2026-10-30]
- AzureHound — https://github.com/SpecterOps/AzureHound [verify 2026-10-30]
- TeamFiltration — https://github.com/Flangvik/TeamFiltration [verify 2026-10-30]
- MicroBurst — https://github.com/NetSPI/MicroBurst [verify 2026-10-30]
- Microsoft-Extractor-Suite (Invictus IR) — https://github.com/invictus-ir/Microsoft-Extractor-Suite [verify 2026-10-30]
- DFIR-O365RC (ANSSI) — https://github.com/ANSSI-FR/DFIR-O365RC [verify 2026-10-30]

**Vendor IR / threat-research blogs:**
- Microsoft Threat Intelligence — https://www.microsoft.com/security/blog/topic/threat-intelligence/ [verify 2026-10-30]
- Microsoft Security Blog, incident response — https://www.microsoft.com/en-us/security/blog/topic/incident-response/ [verify 2026-10-30]
- Google Threat Intelligence / Mandiant blog — https://cloud.google.com/blog/topics/threat-intelligence [verify 2026-10-30]
- Volexity (M365 / Entra deep-dives) — https://www.volexity.com/blog/ [verify 2026-10-30]
- Permiso Security (identity-threat research) — https://permiso.io/blog [verify 2026-10-30]
- Inversecos (Australian DFIR; M365 deep-dives) — https://www.inversecos.com/ [verify 2026-10-30]
- Invictus IR — https://www.invictus-ir.com/news [verify 2026-10-30]
- Sekoia blog — https://www.sekoia.com/blog [verify 2026-10-30]
- Huntress — https://www.huntress.com/blog [verify 2026-10-30]

**Training and certification:**
- SANS FOR509 — Enterprise Cloud Forensics and Incident Response (covers M365 / Google Workspace / AWS / Azure / GCP / Kubernetes) [verify 2026-10-30]
- SANS FOR578 — Cyber Threat Intelligence [verify 2026-10-30]
- Microsoft — SC-200 / SC-100 / SC-401 (Security Operations Analyst / Cybersecurity Architect / Information Security Administrator; SC-400 retired May 2025) [verify 2026-10-30]
- Google Cloud — Professional Cloud Security Engineer (Google Cloud platform security; not a Workspace certification) [verify 2026-10-30]

**Incident catalogues and case studies:**
- Verizon DBIR — annual incident analysis (cloud / SaaS breakouts each year) — https://www.verizon.com/business/resources/reports/dbir/ [verify 2026-10-30]
- CrowdStrike Global Threat Report — annual — https://www.crowdstrike.com/global-threat-report/ [verify 2026-10-30]
- Mandiant M-Trends — annual — https://cloud.google.com/security/resources/m-trends [verify 2026-10-30]
- Microsoft Digital Defense Report — annual — https://www.microsoft.com/en-us/corporate-responsibility/topics/cybersecurity/reports/microsoft-digital-defense-report/ (short: https://microsoft.com/mddr) [verify 2026-10-30]

---

**Version:** 1.0
**Last Updated:** 2026-10-30
**Review Frequency:** Quarterly (M365 / Workspace / Okta / Slack / Salesforce / GitHub API field renames, retention defaults, license-tier feature drift, and OAuth-consent abuse TTPs evolve on a quarterly cadence; classical eDiscovery / chain-of-custody fundamentals are slower)
