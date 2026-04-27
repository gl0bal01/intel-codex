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
updated: 2026-04-27
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

This SOP focuses on the dominant enterprise SaaS surfaces: **Microsoft 365 (Entra ID + Exchange Online + SharePoint / OneDrive + Teams + Purview)**, **Google Workspace (Cloud Identity + Gmail + Drive + Calendar + Chat + Meet + Vault)**, **Okta** (Workforce + Customer Identity), **Slack** (Standard + Enterprise Grid), **Salesforce** (Sales / Service / Experience Clouds), and **GitHub / GitLab** (org / enterprise audit). Smaller SaaS surfaces (Box, Dropbox, Atlassian, Zoom, ServiceNow, Workday, Zendesk, HubSpot, Notion, Asana, Airtable, etc.) follow recognizably similar patterns — admin audit, identity log, content-discovery export — but differ in API field names, retention defaults, and admin-permission models; treat per-vendor documentation as authoritative and apply the methodology in this SOP as the framing.

### What this SOP owns

- **M365 Unified Audit Log (UAL)** — `Search-UnifiedAuditLog` (Exchange Online PowerShell), Audit Search Graph API (`/security/auditLog/queries`), retention tiers (Standard 180-day, Audit Standard 365-day, Audit Premium 10-year add-on), record-type taxonomy across Exchange / SharePoint / OneDrive / Teams / Entra / Defender / Purview workloads.
- **Microsoft Purview / eDiscovery** — Compliance Search, eDiscovery (Standard) cases, eDiscovery (Premium) review sets, content-search export and chain-of-custody, in-place hold / litigation hold / retention policies.
- **Mailbox auditing** — Exchange Online mailbox audit log (default-on for owner / admin / delegate actions on most license tiers), `Search-MailboxAuditLog`, mailbox-folder audit, M365 mailbox audit retention.
- **Inbox-rule forensics** — `Get-InboxRule`, `Search-UnifiedAuditLog -Operations New-InboxRule,Set-InboxRule,Remove-InboxRule`, Workspace Gmail filter creation events (`CREATE_FILTER`), forwarding-rule and DND/email-forward configuration events.
- **Google Workspace Admin SDK Reports API** — login, drive, gmail, mobile, token, groups, admin, calendar, chat, meet, user_accounts, saml, jamboard, gplus, contexts, rules, access_transparency, data_studio, lookerstudio applications and their event names; retention semantics per category.
- **Workspace Vault** — matter creation, hold creation, search, export, retention rules, audit of Vault administrator activity.
- **Workspace Gmail BigQuery export** — full mail-flow event stream beyond the Reports API window.
- **Okta System Log API** (`/api/v1/logs`) — 90-day default retention, longer with subscription; Workforce Identity vs Customer Identity (formerly Auth0) tenant differences; Universal Directory event taxonomy; Identity Threat Protection (ITP) signal sources.
- **Slack** — Audit Logs API (Enterprise Grid only — no equivalent on Pro / Business+ Standard), Discovery API for message and file content, retention vs E-Discovery split, Slack Connect cross-organization shared channels.
- **Salesforce** — Setup Audit Trail (180-day window of admin / setup changes), Event Monitoring (Real-Time Event Monitoring add-on), Threat Detection (Salesforce Shield), Login History, API Total Usage.
- **GitHub Audit Log** — organization / enterprise audit (free for enterprise, retention varies), event taxonomy across `repo`, `org`, `team`, `oauth_application`, `personal_access_token`, `user`, `business`, `git`, `protected_branch`, `secret_scanning`, `code_scanning` categories; API + log-streaming.
- **GitLab Audit Events** — group / instance audit-event API, premium-tier requirement, retention.
- **OAuth consent-grant abuse forensics** — multi-tenant app drift, consent-event reconstruction, app-registration audit, attacker-app token persistence (the "OAuth-consent BEC" variant per the buildout-plan scope contract for the forensics trio).
- **Cross-tenant forensics** — Entra ID guest / B2B / cross-tenant access settings, Workspace external sharing, Slack Connect, Salesforce Experience Cloud / Communities, and the SaaS-side identity-federation surface (SAML / OIDC consumed *by* the SaaS app — distinct from [[sop-cloud-forensics|Cloud Forensics]] §3.3 / §7, which covers the IdP-provider side).
- **Retention-cliff and discovery-export discipline** — the dominant SaaS-forensics failure mode is "data was deleted before we could collect." This SOP elevates retention sampling and legal-hold mechanics to first-class concerns, separate from the per-vendor sections.

### Hard exclusions (out of scope)

- **IaaS / cloud-provider control plane.** AWS CloudTrail, Azure Activity Log + Resource Logs, GCP Cloud Audit Logs, IAM forensics on cloud resources, region-sweep, log-tampering detection on CloudTrail digest chains, container / Kubernetes runtime audit, and snapshot preservation of cloud volumes all live in [[sop-cloud-forensics|Cloud Forensics]]. The boundary is the resource the action targeted: if the action targeted SaaS application data (mail, file, message, record, repo), it lives here; if it targeted IaaS resources (VM, bucket, IAM role on a cloud resource, Kubernetes apiserver), it routes to [[sop-cloud-forensics|Cloud Forensics]]. Hybrid incidents — an Entra ID sign-in event that triggered both a mailbox-access action and an Azure-resource-plane action — are split across the two SOPs at the action level, with the identity event referenced from both sides.
- **Email header forensics / SPF / DKIM / DMARC / ARC / wire-recall / lookalike-domain BEC scenario reconstruction.** Routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. The deliberate trio split is: #7 cloud-forensics = IaaS plane, #8 saas-log-forensics = SaaS-tenant identity / collaboration plane (this SOP), #9 email-bec-forensics = scenario-centric BEC. **OAuth-consent BEC variant lives here**, per the user-confirmed scope contract: when the BEC pattern is "attacker tricks user into granting an OAuth app permission to read mailbox," the mailbox-token-persistence forensics belongs to #8; when the BEC pattern is "attacker spoofs a wire request via header / lookalike domain," the header-forensics belongs to #9 — see [[sop-email-bec-forensics|Email & BEC Forensics]].
- **Offensive SaaS pentesting.** Pre-engagement enumeration, identity-based privilege escalation, attacker-controlled multi-tenant app design, lateral movement via SaaS connectors, and exfil tradecraft routes to a not-yet-built SaaS-pentest SOP — currently a "Gaps" item in `CLAUDE.md`. Forensic readers benefit from understanding the offensive playbook as the threat model but should not derive offensive instructions from this SOP.
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

- [ ] **Written engagement letter or internal IR activation** identifying the tenant(s) (M365 tenant ID + initial domain; Workspace primary domain + customer ID; Okta org URL; Slack workspace / Enterprise Grid org ID; Salesforce org ID + My Domain; GitHub org / enterprise slug), the time window of interest, and the scope of authorized actions (read-only audit-log pull? eDiscovery export? mailbox content review? user disablement? OAuth-app revocation?). State-changing actions in SaaS are billable, durable, and visible in the tenant's own audit log — written scope matters.
- [ ] **Tenant-administrator authorization** for read-only access to audit-log destinations and content. Use a dedicated investigator admin account / app-registration / API token per engagement — not a re-used personal identity — and rotate at engagement end. M365: dedicated cloud-only Global Reader + eDiscovery Manager / Reviewer roles. Workspace: dedicated investigator admin with Reports / Vault / Security Center roles, no super-admin unless required. Okta: Read-Only Admin or custom role scoped to System Log read. Slack: Org Owner with Audit Logs API token issued to the engagement. Salesforce: View Setup and Configuration / View Event Log Files / Manage Users-only profile, not System Administrator. GitHub: organization owner or audit-log-API token issued to the engagement.
- [ ] **Provider legal process where the customer cannot authorize collection on their own** — for cross-tenant evidence (tenant A is suspect, tenant B is victim, both reside on the same provider) the provider's law-enforcement portal is the route. Microsoft, Google, Salesforce, Slack, and Okta publish LE guidelines and require subpoena / warrant / MLAT / preservation letter depending on data type and jurisdiction [verify 2026-04-27].
- [ ] **Cross-border data residency review.** EU data subjects, healthcare records (HIPAA), card data (PCI), and government tenants (GCC / GCC High / DOD; Workspace Assured Controls; Okta GovCloud) all carry residency / sovereignty constraints. Verify under counsel before exporting log or content data to investigator storage outside the source region — see [[sop-legal-ethics|Legal & Ethics]] for Schrems II / DPF / SCCs framing.
- [ ] **Disclosure pathway agreed.** Notification clocks are jurisdiction- and sector-specific — GDPR Art. 33 (72h to supervisory authority), GDPR Art. 34 (high-risk-to-data-subjects notice), HIPAA Breach Notification Rule (60-day), state breach-notification laws (US), SEC cyber-disclosure rule for material incidents at registrants, NYDFS Part 500, NIS2 (EU), DORA (EU financial). Verify per-incident under counsel.
- [ ] **CSP / SaaS-vendor support case opened where useful.** Microsoft IR (Microsoft Incident Response, formerly DART), Google Workspace Premium Support, Slack Enterprise support, Salesforce Signature Success, and Okta support can unlock collection paths (extended retention, archived logs, mailbox-recovery from cold) that customer-side tooling cannot. Open the case under an executive sponsor's identity, not the investigator's, so the audit trail attributes correctly.
- [ ] **OAuth-app inventory baseline established.** Before any state-changing action, snapshot the current OAuth-app inventory — multi-tenant apps consented in the tenant, app-only permissions granted, refresh-tokens active. This is the baseline against which post-incident OAuth-revocation actions are measured. M365: `Get-MgServicePrincipal`, `Get-MgOauth2PermissionGrant`, `Get-MgServicePrincipalAppRoleAssignment`. Workspace: Admin Console → Security → API Controls → App Access Control + connected apps export. Salesforce: Connected Apps Usage. GitHub: org-level OAuth Apps, GitHub Apps, and PATs.

### Lab Environment Requirements

- **Dedicated investigator tenant or analyst seat** in each SaaS surface, separate from the affected tenant. Exports, hashed log artifacts, and analysis derivatives land here, never back into the affected tenant. The investigator's M365 / Workspace / Okta / Slack / Salesforce identity is engagement-scoped, not their personal cloud identity.
- **Investigator workstation** disk-encrypted, isolated from production, no auto-sync of artifacts to corporate storage, dedicated browser profiles or container tabs per tenant to avoid cross-tenant cookie / session leakage. PowerShell 7+ for Exchange Online / Microsoft Graph PowerShell SDK; `gcloud` + `gam7` for Workspace; `okta-cli` / direct `curl` for Okta; `slackclient` Python or direct `curl` for Slack.
- **Encrypted-at-rest investigator storage.** Exported audit logs (often hundreds of MB to multi-GB), eDiscovery exports (often tens of GB), and Vault exports (potentially TB-scale on long-window matters) all encrypted with engagement-specific keys. Cross-region copy of the engagement bucket / storage account / Cloud Storage bucket for resilience.
- **Time-sync discipline.** All analysis systems running NTP / chrony to a known source; time-zone normalized to UTC end-to-end; investigator note timestamps use ISO 8601 / RFC 3339 with explicit `Z` suffix per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. SaaS providers report event times with mixed precision and time-zone hints — UAL `CreationTime` is UTC; Workspace Reports `id.time` is RFC 3339 UTC; Okta `published` is ISO 8601 UTC; Slack Audit Logs `date_create` is Unix epoch seconds; Salesforce `EventDate` / `LogDate` is ISO 8601 with timezone offset; GitHub `@timestamp` is RFC 3339 UTC.
- **API-throttling awareness.** Production SaaS tenants under stress can ratelimit aggressive forensic queries. UAL `Search-UnifiedAuditLog` returns at most 5000 records per call (legacy) and is being phased toward the Audit Search Graph API (asynchronous, paged) for large pulls [verify 2026-04-27]. Workspace Reports API has per-customer quota; use bulk export to BigQuery / Cloud Storage where possible. Okta System Log API enforces a rate limit per org and per token. Slack Audit Logs API has tier-1 / tier-2 / tier-3 / tier-4 method-class quotas. Salesforce REST / SOAP API has per-org daily limits.
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
3. **Retention is shorter and more provider-controlled.** IaaS-plane logs (CloudTrail, Activity Log, Cloud Audit Logs) have predictable, customer-configurable retention. SaaS-plane logs have shorter defaults (UAL 180-day Standard, Okta 90-day, Salesforce SAT 180-day), tier-gated extensions (UAL Audit Premium 10-year, Salesforce Real-Time Event Monitoring add-on), and hard floors below which the customer cannot pay for retention without an admin process (Workspace Reports per-application retention is Google-controlled, not customer-controlled). Retention sampling is not a luxury — it is a precondition to promising a reconstruction.

### 3.2 SaaS Evidence Planes

SaaS forensic surfaces partition into five planes. Each has distinct artifacts, retention defaults, and forensic value.

| Plane | What it captures | Highest-value events | Default retention posture |
|---|---|---|---|
| **Identity** | Sign-in, MFA, federation, conditional access, session, token issuance / refresh, account-state changes | Suspicious sign-ins, MFA bypass, impossible travel, federated-IdP token consumption, OAuth token issuance | Short (90-180 days) but consistently present across vendors |
| **Activity** | Per-user, per-document, per-message access — read, edit, share, send, download, delete | Mailbox access by non-owner, mass file download, mass DM access, mass repo clone, mass record export | Variable: opt-in for Data Access in some vendors; enabled by default for some others |
| **Content** | Actual mail / file / message / record content (separate from access metadata) | Content of suspect messages, attached files, shared documents | Indefinite (until user-deleted), but discoverable only via eDiscovery / Vault / Discovery API |
| **Configuration** | Tenant settings, role assignments, OAuth-app installations, SSO configuration, retention policies | Role escalation, MFA-policy changes, conditional-access bypass added, OAuth-app installed, retention-policy reduced | Variable by vendor; usually 6-24 months |
| **Device-trust** | MDM enrollment / posture / compliance, BYOD identity, app-protection policies | Sign-in from unmanaged device, jailbroken / rooted device, device-compliance bypass | Variable; tied to MDM platform retention rather than SaaS audit |

Most SaaS-forensics work depends on the **identity** and **activity** planes; **content** is reached through eDiscovery / Vault / Discovery only when the access metadata indicates a need; **configuration** changes are the highest-signal indicators of attacker persistence; **device-trust** correlates the identity event to a physical or policy-violating device.

### 3.3 The Retention-Cliff Problem

The dominant SaaS-forensics failure mode is "data was deleted before we could collect." Default retentions across the major vendors:

| Vendor | Surface | Default retention | Long-term option |
|---|---|---|---|
| Microsoft 365 | Unified Audit Log (E3 / E5 baseline) | **180 days** Audit Standard included with most plans [verify 2026-04-27] | Audit (Standard) extends to 365 days; Audit (Premium) add-on extends to 10 years and adds the `MailItemsAccessed` / `Send` / `SearchQueryInitiatedExchange` / `SearchQueryInitiatedSharePoint` event family |
| Microsoft 365 | Mailbox audit log (per-mailbox) | **90 days** for default-on actions [verify 2026-04-27] | Per-mailbox `AuditLogAgeLimit` extension; up to 1 year baseline, longer with retention policies |
| Microsoft 365 | Defender for Cloud Apps (formerly MCAS) activities | **180 days** [verify 2026-04-27] | Continuous report export, Sentinel ingest |
| Microsoft 365 | Entra ID sign-in and audit logs | **30 days** in Entra portal (free / Free); **90 days** with P1 / P2 [verify 2026-04-27] | Diagnostic-settings export to Log Analytics workspace, Event Hub, or Storage Account |
| Google Workspace | Reports API (most applications) | **6 months** [verify 2026-04-27] | BigQuery / Cloud Storage export via Workspace logs export to GCP; some applications have application-specific defaults |
| Google Workspace | Vault retention policies (when configured) | Per-policy (admin-set; can be indefinite) | N/A — Vault is the long-term option |
| Okta | System Log | **90 days** default (Workforce Identity); some plans differ; Customer Identity (formerly Auth0) similar [verify 2026-04-27] | Log streaming to AWS EventBridge, Splunk, custom HTTPS sinks; longer retention via subscription tier |
| Slack | Audit Logs (Enterprise Grid) | **6 months** in the API; longer via export [verify 2026-04-27] | Continuous SIEM ingest; Discovery API for content (separate retention model) |
| Slack | Discovery API (content) | Tied to message-retention policy; defaults workspace-set | E-Discovery hold via Discovery API |
| Salesforce | Setup Audit Trail | **180 days** | Field Audit Trail (Salesforce Shield add-on) extends per-field history to **10 years** |
| Salesforce | Login History | **6 months** [verify 2026-04-27] | Real-Time Event Monitoring (Shield add-on) provides 10K records / streaming / longer retention |
| Salesforce | Real-Time Event Monitoring | Streaming + storage period determined by Shield contract [verify 2026-04-27] | N/A — already long-term |
| GitHub | Audit log (org / enterprise) | **6 months** in API; some events longer; varies by tier [verify 2026-04-27] | Audit log streaming to Splunk / Datadog / Azure Event Hubs / AWS S3 / Google Cloud Storage |
| GitLab | Instance / group audit events | Per-tier, premium-required for full surface; retention varies [verify 2026-04-27] | Self-managed: customer-controlled retention via PostgreSQL; SaaS: GitLab-controlled |

**Practical implication.** The median dwell time for SaaS-tenant compromises trends 30-100+ days [verify 2026-04-27]; long-tail incidents discovered after default retention has expired are routine. The first pre-engagement question is *not* "what happened?" — it is "what evidence exists?" Customers without long-term audit-log export (UAL Premium, Workspace logs to BigQuery, Slack SIEM ingest, Salesforce Shield, GitHub log streaming) lose evidence to retention silently.

### 3.4 Per-Tenant Terminology Crosswalk

Cross-vendor incidents demand a shared vocabulary. The same concept gets different names per SaaS surface:

| Concept | Microsoft 365 | Google Workspace | Okta | Slack | Salesforce | GitHub |
|---|---|---|---|---|---|---|
| Tenant boundary | Tenant (Entra ID + initial domain) | Customer (Cloud Identity + primary domain) | Org (`<org>.okta.com`) | Workspace / Enterprise Grid org | Org (`<MyDomain>.my.salesforce.com`) | Organization / Enterprise |
| User identity | UPN / Object ID | Primary email / User ID | User ID (Okta UID) | User ID (`U0…`) | User ID (`005…`) | Username / User ID |
| Service identity | Service principal / managed identity | Service account | OAuth client / API service app | App / bot user | Connected App / Named Credential | OAuth App / GitHub App / PAT / Deploy Key |
| Sign-in audit | Entra ID sign-in logs (interactive / non-interactive / sp / mi) | Reports API `login` application | System Log `user.session.start` | Audit Logs `user_login` | Login History | Audit Log `user.login` |
| Admin / config audit | Entra ID audit logs + UAL `Microsoft.Office.AzureActiveDirectory` workload | Reports API `admin` | System Log `system.…` events | Audit Logs `workspace.*`, `org.*` | Setup Audit Trail | Audit Log `org.*`, `enterprise.*` |
| Content access | UAL Exchange / SharePoint / OneDrive operations | Reports API `drive`, `gmail`, `chat` | N/A (identity-only) | Discovery API | Event Monitoring `RestApiEvent`, `BulkApi*Event` | Audit Log `git.*`, `repo.*` |
| eDiscovery / hold | Purview eDiscovery (Standard + Premium) | Vault | N/A | Discovery API | Field Audit Trail | N/A |
| OAuth-app inventory | Service Principals + `oauth2PermissionGrants` | Connected apps + `tokens` | OAuth clients | Apps | Connected Apps | OAuth Apps + Apps + PATs |
| Cross-tenant collaboration | B2B / guest accounts; cross-tenant access settings | External sharing; trusted domains | Hub-and-spoke (Workforce); B2B (Customer) | Slack Connect | Experience Cloud / Communities | Outside collaborators; org cross-references |

---

## 4. Microsoft 365 — Unified Audit Log & Purview

The M365 ecosystem is the single largest SaaS-forensic surface for most enterprises. The Unified Audit Log (UAL) is the canonical event store; mailbox audit, Entra ID sign-in / audit, Defender for Cloud Apps, and Purview eDiscovery / Compliance Search round out the toolkit.

### 4.1 UAL Retention Tiers

| Tier | Default retention | Notable extra events |
|---|---|---|
| **Audit (Standard)** — included with most M365 plans (E3, E5, F3, M365 Apps for business / enterprise) | **180 days** of UAL events for most record types [verify 2026-04-27] | Baseline UAL — sign-in, mailbox, SharePoint / OneDrive activity, Entra ID directory changes, Teams meetings, etc. |
| **Audit (Standard) — extended** | Up to **365 days** when Audit (Standard) is licensed at the tenant level [verify 2026-04-27] | Same record types as 180-day baseline |
| **Audit (Premium)** — paid add-on (or included with E5 / G5 / A5 / F5 Compliance / F5 Security & Compliance) | Up to **10 years** with the appropriate Audit Premium 10-year retention add-on [verify 2026-04-27] | Adds high-value events: `MailItemsAccessed`, `Send`, `SearchQueryInitiatedExchange`, `SearchQueryInitiatedSharePoint`. These are the **canonical "what mail did the attacker read?"** events, otherwise unavailable. Custom audit-log retention policies up to 10 years. |

> **Operational rule.** When Audit (Premium) is **not** licensed, the answer to "what mail did the attacker read?" frequently defaults to "we cannot tell from UAL alone — only that the mailbox was accessed." Document this gap in the report rather than overstating evidence.

### 4.2 Search-UnifiedAuditLog (Exchange Online PowerShell)

The legacy synchronous cmdlet — still the workhorse for ad-hoc investigations under ~50K records per query. Connect with the modern Exchange Online PowerShell module (V3 or later) using a service-principal or interactive auth.

```powershell
# Modern connect (V3+, with certificate-based service-principal auth recommended for repeatable use)
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName <admin>@<tenant>.onmicrosoft.com -ShowBanner:$false

# Window-bounded UAL search (UTC; max 5000 records per call — paginate via -SessionId / -SessionCommand for legacy mode)
$results = Search-UnifiedAuditLog `
    -StartDate (Get-Date "2026-04-01T00:00:00Z") `
    -EndDate (Get-Date "2026-04-27T00:00:00Z") `
    -UserIds "<suspect-upn>@<tenant>.com" `
    -ResultSize 5000 `
    -Formatted

# Operations filter — common high-value operations
Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
    -Operations "New-InboxRule","Set-InboxRule","UpdateInboxRules","MailboxLogin","Send","MailItemsAccessed","FileAccessed","FileDownloaded","Add-MailboxPermission","Add app role assignment to service principal"

# Record-type filter (workload-scoped)
Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
    -RecordType ExchangeItem,SharePointFileOperation,AzureActiveDirectory,MicrosoftTeams

# Output to file with chain-of-custody hash
$results | Export-Csv -NoTypeInformation -Path "ual-2026-04-01-to-2026-04-27.csv"
Get-FileHash -Algorithm SHA256 ual-2026-04-01-to-2026-04-27.csv | Format-List
```

**Pagination caveat.** The legacy paged mode (`-SessionId <guid> -SessionCommand ReturnLargeSet`) is the only way to retrieve more than 5000 results per query window via the cmdlet, and it is documented as best-effort: results may be inconsistent across paged calls if events are still landing during the query. For windows known to contain >50K records, prefer the Audit Search Graph API (§4.3) [verify 2026-04-27].

### 4.3 Audit Search Graph API (Recommended for Large Pulls)

Microsoft documents the Audit Search Graph API as the recommended path for large or programmatic UAL pulls. It is asynchronous, supports paged retrieval over hundreds of thousands of records, and exposes record types not surfaced via the legacy cmdlet for some plan tiers [verify 2026-04-27].

```bash
# Endpoint (beta as of writing; promotion to v1.0 anticipated [verify 2026-04-27])
# POST https://graph.microsoft.com/beta/security/auditLog/queries
# GET  https://graph.microsoft.com/beta/security/auditLog/queries/{id}
# GET  https://graph.microsoft.com/beta/security/auditLog/queries/{id}/records?$top=100

# Required app permissions (admin consent): AuditLogsQuery.Read.All

# Step 1: Create a query
curl -X POST 'https://graph.microsoft.com/beta/security/auditLog/queries' \
  -H "Authorization: Bearer $GRAPH_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "displayName": "case-2026-04-27 forensic UAL pull",
    "filterStartDateTime": "2026-04-01T00:00:00Z",
    "filterEndDateTime": "2026-04-27T00:00:00Z",
    "userPrincipalNameFilters": ["<suspect-upn>@<tenant>.com"],
    "operationFilters": ["MailItemsAccessed","Send","New-InboxRule","Set-InboxRule"]
  }'

# Step 2: Poll status (status transitions: notStarted -> running -> succeeded | failed | cancelled)
curl 'https://graph.microsoft.com/beta/security/auditLog/queries/<query-id>' \
  -H "Authorization: Bearer $GRAPH_TOKEN"

# Step 3: Page records when status == succeeded
curl 'https://graph.microsoft.com/beta/security/auditLog/queries/<query-id>/records?$top=100' \
  -H "Authorization: Bearer $GRAPH_TOKEN"
```

The Graph API endpoint, request shape, and permission scopes are versioned and documented at `learn.microsoft.com/graph/api/resources/security-auditlogquery` [verify 2026-04-27] — confirm current shape per engagement before scripting against it.

### 4.4 UAL Record-Type Taxonomy

UAL events are categorized by `RecordType`. Major workloads and their high-value record types:

| Workload | RecordType examples | High-value operations |
|---|---|---|
| Exchange Online | `ExchangeAdmin`, `ExchangeItem`, `ExchangeItemGroup`, `ExchangeItemAggregated`, `ExchangeAggregatedOperation` | `MailItemsAccessed` (Premium), `Send`, `New-InboxRule`, `Set-InboxRule`, `Update-InboxRules`, `MoveToDeletedItems`, `HardDelete`, `Add-MailboxPermission`, `Set-Mailbox`, `Add-MailboxFolderPermission` |
| SharePoint / OneDrive | `SharePointFileOperation`, `SharePointSharingOperation`, `SharePoint`, `SharePointListOperation` | `FileAccessed`, `FileDownloaded`, `FileSyncDownloadedFull`, `FileModified`, `FileDeleted`, `SharingInvitationCreated`, `AnonymousLinkCreated`, `SecureLinkCreated` |
| Microsoft Teams | `MicrosoftTeams`, `MicrosoftTeamsAdmin`, `MicrosoftTeamsAnalytics`, `MicrosoftTeamsShifts` | `MessageSent`, `MessageRead`, `MeetingDetail`, `MeetingParticipantDetail`, `TeamCreated`, `MemberAdded`, `MemberRemoved`, `BotAddedToTeam`, `AppInstalled` |
| Microsoft Entra ID | `AzureActiveDirectory`, `AzureActiveDirectoryAccountLogon`, `AzureActiveDirectoryStsLogon` | `Add app role assignment to service principal`, `Consent to application`, `Add service principal`, `Update service principal`, `Add member to role`, `Add owner to application` |
| Defender for Cloud Apps (formerly MCAS) | `CloudAppEvents`, `MCASAlerts`, `ThreatIntelligence`, `ThreatIntelligenceUrl`, `ThreatIntelligenceAtpContent` | Anomaly-detection triggers, malware-detection events, suspicious-OAuth-app alerts |
| Microsoft Purview | `ComplianceDLPSharePoint`, `ComplianceDLPExchange`, `ComplianceSupervisionExchange`, `Discovery`, `DataInsightsRestApiAudit` | DLP rule matches, supervision review actions, eDiscovery search / export operations |
| Power Platform | `PowerAppsApp`, `PowerAppsPlan`, `PowerBIAudit`, `PowerBIDatasets`, `MicrosoftFlow` | App creation / sharing, dataset access, Flow execution (high signal for OAuth-bound exfil scenarios) |

The full canonical list of `RecordType` values and `Operations` is documented at `learn.microsoft.com/purview/audit-log-activities` [verify 2026-04-27]; refresh per engagement.

### 4.5 Mailbox Audit Log

Per-mailbox auditing has been default-on since 2019 for owner / admin / delegate actions on most M365 plans [verify 2026-04-27]. Default-audited owner actions include `MailItemsAccessed` (with Audit Premium), `Send`, `SoftDelete`, `HardDelete`, `MoveToDeletedItems`, `Update`, `UpdateFolderPermissions`, `UpdateInboxRules`. Default-audited delegate / admin actions include `SendAs`, `SendOnBehalf`, `Create`, `MailItemsAccessed` (subset).

```powershell
# Search the mailbox audit log directly (Search-MailboxAuditLog - legacy; Get-MailboxAuditLog also legacy)
# Microsoft has been moving customers toward UAL / Graph as the canonical surface; verify active-supported path.
Search-MailboxAuditLog `
    -Identity <upn>@<tenant>.com `
    -StartDate "2026-04-01" -EndDate "2026-04-27" `
    -LogonTypes Owner,Delegate,Admin `
    -ResultSize 5000

# Inspect mailbox audit configuration
Get-Mailbox -Identity <upn> | Format-List Audit*
# Output of interest: AuditEnabled (should be True), AuditLogAgeLimit (default 90 days), AuditOwner, AuditDelegate, AuditAdmin
```

### 4.6 Inbox-Rule Forensics

Mailbox inbox rules are the canonical BEC-pivot persistence primitive. The attacker, once in possession of credentials or a session token, creates a rule that auto-forwards / auto-deletes / moves-to-archive specific messages (e.g., wire-confirmation requests from the CFO). UAL captures every rule-creation and rule-modification event.

```powershell
# Hunt for inbox-rule creation in window
Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
    -Operations New-InboxRule,Set-InboxRule,Remove-InboxRule,Disable-InboxRule,UpdateInboxRules,Update-InboxRules `
    -ResultSize 5000 | `
    Select-Object CreationDate,UserIds,Operations,AuditData

# Enumerate current rules on a suspect mailbox
Get-InboxRule -Mailbox <upn>@<tenant>.com | `
    Format-List Identity,Name,Description,Enabled,Priority,RedirectTo,ForwardTo,ForwardAsAttachmentTo,DeleteMessage,MoveToFolder,MarkAsRead,FromAddressContainsWords,SubjectContainsWords,BodyContainsWords

# Hidden-rule forensics — attacker-created rules with whitespace-only or unicode-zero-width names are common evasion
Get-InboxRule -Mailbox <upn> -BypassScopeCheck:$true | Where-Object {[string]::IsNullOrWhiteSpace($_.Name)}
```

**Indicators of malicious rule creation:**

- Forward-to-external-domain rule (`ForwardTo`, `RedirectTo`) targeting a mailbox at a domain the user has no legitimate correspondence with.
- Move-to-RSS-Feeds / Move-to-Archive / Move-to-Junk rule scoped to specific keywords (`wire`, `invoice`, `payment`, `bank`, `confirm`) — pattern is "hide the legitimate confirmation from the user."
- Mark-as-read + delete-permanently combination.
- Rule name that is whitespace, single character, zero-width unicode, or otherwise designed to be invisible in the Outlook GUI.
- Rule created from a sign-in event whose source IP / user agent does not match the user's historical pattern — correlate with §4.2 sign-in logs.

### 4.7 Microsoft Purview / eDiscovery

Purview eDiscovery (Standard) is included with most M365 E3 / E5 / G3 / G5 plans; eDiscovery (Premium) is an E5 add-on or included with M365 E5 [verify 2026-04-27]. The forensic capability stack:

- **Compliance Search** — search across Exchange mailboxes, SharePoint / OneDrive sites, Teams chats, Yammer / Viva Engage. Returns hit counts and statistics; export requires escalation to eDiscovery.
- **eDiscovery (Standard) cases** — case-scoped searches with custodian assignment, hold management, and export to PST / standard-eDiscovery format.
- **eDiscovery (Premium) cases** — adds review sets (parsed, deduped, threaded content), advanced indexing, ML-driven relevance scoring, transparent-litigation-hold notifications, and forensic-export packages.
- **In-place hold / litigation hold / retention policies** — preservation mechanisms that prevent end-user or admin deletion within the hold scope.

```powershell
# Connect to Security & Compliance PowerShell (separate endpoint from Exchange Online)
Connect-IPPSSession -UserPrincipalName <admin>@<tenant>.onmicrosoft.com

# Create an eDiscovery (Standard) case
New-ComplianceCase -Name "Case-2026-04-27-Forensic" -CaseType eDiscovery

# Add a custodian (the suspect's mailbox + OneDrive)
New-CaseHoldPolicy -Name "Case-2026-04-27-Hold" -Case "Case-2026-04-27-Forensic" `
    -ExchangeLocation <suspect-upn>@<tenant>.com `
    -SharePointLocation https://<tenant>-my.sharepoint.com/personal/<suspect-upn-tokenized>

# Create a search inside the case
New-ComplianceSearch -Name "Case-2026-04-27-Search" `
    -ExchangeLocation <suspect-upn>@<tenant>.com `
    -ContentMatchQuery '(Sent>=2026-04-01) AND (Sent<=2026-04-27)'

Start-ComplianceSearch -Identity "Case-2026-04-27-Search"

# Wait for completion, then export
New-ComplianceSearchAction -SearchName "Case-2026-04-27-Search" -Export -Format Fxstream
```

### 4.8 Compliance Search & Content-Search Export

For non-case-scoped quick searches (e.g., "find all emails containing this IOC across the tenant"):

```powershell
# Tenant-wide compliance search (no case scope; useful for IOC sweeping)
New-ComplianceSearch -Name "IOC-Sweep-2026-04-27" `
    -ExchangeLocation All -SharePointLocation All `
    -ContentMatchQuery '"<suspect-domain>" OR "<suspect-attachment-hash>"'

Start-ComplianceSearch -Identity "IOC-Sweep-2026-04-27"

# Result counts (hit counts only; no content)
Get-ComplianceSearch -Identity "IOC-Sweep-2026-04-27" | Format-List Items,Size

# Promote to export when content is needed
New-ComplianceSearchAction -SearchName "IOC-Sweep-2026-04-27" -Preview
```

**Chain-of-custody for content exports.** Every Purview / eDiscovery export package includes a manifest and a hash. Hash the export package itself at receipt (SHA-256), record source-tenant ID, executing-admin UPN, search query, time range, and item / size counts in [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Treat the export as evidence equivalent to a disk image — read-only, encrypted at rest, access-controlled.

### 4.9 Defender for Cloud Apps (Formerly MCAS)

Defender for Cloud Apps surfaces SaaS-app activity, anomaly detection, and OAuth-app risk scoring. Findings live in the M365 Defender portal and are queryable via the advanced-hunting endpoint (KQL):

```kusto
// Suspicious sign-in activity (DCA cross-source)
CloudAppEvents
| where Timestamp > ago(30d)
| where ApplicationId in (15600 /* Exchange */, 11161 /* SharePoint */, 28375 /* Teams */)
| where ActionType in ("MailItemsAccessed", "FileDownloaded", "MessageRead")
| where AccountObjectId == "<suspect-objectid>"
| project Timestamp, ApplicationId, ActionType, AccountObjectId, IPAddress, ISP, City, CountryCode

// OAuth-app anomaly findings
AlertInfo
| where Timestamp > ago(30d)
| where ServiceSource == "Microsoft Defender for Cloud Apps"
| where Title contains "OAuth"
```

DCA's `MailItemsAccessed` cross-source signal is **distinct from** the UAL `MailItemsAccessed` event; both should be collected when investigating mailbox compromise. DCA's strength is correlating across applications and surfacing risk-scored anomalies; UAL's strength is per-event ground truth.

---

## 5. Google Workspace — Admin SDK Reports & Vault

The Workspace audit surface is the Admin SDK Reports API (`admin.googleapis.com/admin/reports/v1/`), supplemented by Workspace Vault for content discovery / hold and Gmail BigQuery export for full mail-flow visibility.

### 5.1 Reports API Event Categories

The Reports API exposes per-application activity feeds. Each `applicationName` has its own event taxonomy:

| `applicationName` | Coverage | High-value events |
|---|---|---|
| `login` | User sign-in, suspicious sign-in, MFA challenges | `login_success`, `login_failure`, `login_challenge`, `suspicious_login`, `2sv_disable`, `2sv_enroll`, `account_disabled_password_leak` |
| `admin` | Super-admin and delegated-admin actions on the directory | `CHANGE_USER_PASSWORD`, `CHANGE_USER_ADMIN_STATUS`, `CHANGE_USER_LICENSE`, `CREATE_USER`, `DELETE_USER`, `UNDELETE_USER`, `GRANT_DELEGATED_ADMIN_PRIVILEGES`, `REVOKE_DELEGATED_ADMIN_PRIVILEGES`, `CHANGE_DOMAIN_PRIMARY`, `CREATE_DOMAIN_ALIAS`, `CHANGE_OAUTH2_CLIENT_*`, `AUTHORIZE_API_CLIENT_ACCESS`, `REVOKE_API_CLIENT_ACCESS` |
| `drive` | File create / view / edit / share / download / move / trash | `view`, `download`, `edit`, `change_acl_editors`, `change_user_access`, `add_to_folder`, `create`, `move`, `trash`, `untrash`, `print`, `change_document_visibility` |
| `gmail` | Mail-flow events (subset; full mail flow needs BigQuery export) | `gmail_*` event family — note: per-message granularity for most users requires BigQuery export, not Reports API |
| `mobile` | MDM / device-management events | `DEVICE_REGISTER`, `DEVICE_WIPE`, `FAILED_LOGIN_ATTEMPTS`, `DEVICE_COMPROMISED` |
| `token` | OAuth / API client authorizations | `authorize`, `revoke`, `request` (failure); user-granted scope reflects in `scopeData` |
| `groups` | Group create / delete / membership changes | `CREATE_GROUP`, `DELETE_GROUP`, `ADD_GROUP_MEMBER`, `REMOVE_GROUP_MEMBER`, `WHITELISTED_GROUPS_UPDATED` |
| `calendar` | Event create / modify / delete; access controls | `create_event`, `change_event_*`, `delete_event` |
| `chat` | Google Chat (formerly Hangouts Chat) message and room events | `message_create`, `message_delete`, `room_create`, `room_member_add`, `room_member_remove`, `dm_create` |
| `meet` | Google Meet call records | `call_ended`, `call_recording_started`, `livestream_started` |
| `user_accounts` | User-initiated account-self-service events (password changes, recovery info edits) | `password_edit`, `recovery_email_edit`, `recovery_phone_edit`, `2sv_enrollment`, `2sv_disable` |
| `saml` | SAML sign-in events (when Workspace is the SAML SP for third-party IdP) | `login_success`, `login_failure` for SAML-routed sign-ins |
| `access_transparency` | Google-side admin access events (when GAT is licensed) | Google support / admin access to customer data with justification codes |
| `data_studio` / `lookerstudio` | Looker Studio (formerly Data Studio) sharing / access | `view_*`, `change_owner`, `share_object` |
| `gplus`, `jamboard`, `gcp`, etc. | Application-specific event feeds | Per-application docs |

```bash
# OAuth: requires admin user impersonation OR a service account with domain-wide delegation
# Required scope: https://www.googleapis.com/auth/admin.reports.audit.readonly

# Login events for a user in the window
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

`gam7` (the modern `gam` fork) wraps these endpoints and is the standard CLI in many Workspace shops:

```bash
gam7 report login fields user,event,ipAddress,parameters startTime 2026-04-01T00:00:00Z endTime 2026-04-27T00:00:00Z user <suspect-email>
gam7 report drive fields user,event,doc_id,doc_title,owner,visibility startTime 2026-04-01T00:00:00Z eventName download
gam7 report admin fields actor,event,parameters startTime 2026-04-01T00:00:00Z
gam7 report token startTime 2026-04-01T00:00:00Z eventName authorize
```

### 5.2 Retention Defaults Per Category

Workspace Reports API retention is per-application and is **Google-controlled**, not customer-tunable [verify 2026-04-27]. Long-term retention requires export to GCP (BigQuery, Cloud Storage, Pub/Sub) via the Workspace logs export feature, which is configured at the customer level and writes log-event streams to a customer GCP project.

```bash
# Export configuration (Admin Console → Reporting → Audit and investigation → Data export)
# Configures continuous export to BigQuery for long-term retention beyond the Reports API window.
# The exported dataset is queryable via standard BigQuery tooling.

# Example BigQuery query against the exported activity dataset
bq query --use_legacy_sql=false '
SELECT
  TIMESTAMP_TRUNC(event_time, SECOND) AS event_time,
  actor.email AS actor,
  type AS event_type,
  name AS event_name,
  parameters
FROM `<project>.<dataset>.activity`
WHERE event_time BETWEEN TIMESTAMP("2026-04-01") AND TIMESTAMP("2026-04-27")
  AND actor.email = "<suspect>@<domain>"
ORDER BY event_time
'
```

### 5.3 Gmail BigQuery Export

The Workspace Gmail BigQuery export is **distinct from** the Reports API `gmail` application feed. It captures full mail-flow events at message granularity (recipient address, subject hash, attachments metadata, RFC 822 message-id) and is the canonical surface for "what mail went through this tenant" reconstruction beyond the limited Reports API window. Configuration is Admin Console → Apps → Google Workspace → Gmail → Logs → Export Gmail logs to BigQuery.

```sql
-- Mail-flow query against the Gmail BigQuery export (table layout per Google docs;
-- field names verify against the current schema at engagement time [verify 2026-04-27])
SELECT
  message_info.timestamp AS event_time,
  message_info.message_id AS message_id,
  message_info.subject AS subject,
  message_info.source.address AS sender,
  ARRAY(SELECT address FROM UNNEST(message_info.destination)) AS recipients,
  message_info.action AS action  -- received, sent, etc.
FROM
  `<project>.<gmail-dataset>.daily_<YYYYMMDD>`
WHERE
  DATE(message_info.timestamp) BETWEEN "2026-04-01" AND "2026-04-27"
  AND message_info.source.address = "<suspect>@<domain>";
```

### 5.4 Workspace Vault

Vault is the Workspace eDiscovery / litigation-hold platform. It is licensed separately on some plans (included with Business Plus, Enterprise Standard, Enterprise Plus, Education Standard, Education Plus, Frontline Plus [verify 2026-04-27]).

```bash
# Vault admin console pattern (UI, not script):
# Apps → Google Workspace → Vault → Matters → Create matter
#   → Add hold (custodian: <suspect>@<domain>; corpus: Mail / Drive / Chat / Voice / Sites / Calendar)
#   → Search (within matter; query by date / participant / keyword / file-type)
#   → Export (delivers a downloadable archive — PST for mail, native files for Drive,
#             with a searchable XML manifest)

# Vault API (alpha / beta promotions ongoing — verify current path)
# https://developers.google.com/vault/reference/rest [verify 2026-04-27]

# Required scope: https://www.googleapis.com/auth/ediscovery
curl -X POST 'https://vault.googleapis.com/v1/matters' \
  -H "Authorization: Bearer $VAULT_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name": "Case-2026-04-27", "description": "Forensic matter"}'

# Export workflow returns a job ID; poll for completion; download archive when ready;
# verify SHA-256 against the archive manifest at receipt.
```

**Hold semantics.** A Vault hold preserves data **indefinitely** within hold scope, overriding user-deletion and tenant retention rules. Holds are visible to Vault admins but not to end users. Apply hold first, then search — the inverse order risks evidence-spoliation if the user is alerted by some other channel.

### 5.5 External Sharing & Cross-Domain Forensics

Workspace external sharing is the dominant data-exfil channel for insider-threat and post-credential-compromise scenarios. Reports API `drive` events with `change_user_access`, `change_acl_editors`, `change_document_access_scope`, or `change_document_visibility` capture share creations.

```bash
# Drive share events to external domains
gam7 report drive fields user,event,doc_id,doc_title,target_user,visibility,visibility_change \
    startTime 2026-04-01T00:00:00Z \
    eventName change_user_access \
  | grep -v "@<your-primary-domain>"

# Mass-download events (single user, large file count)
gam7 report drive fields user,event,doc_id,doc_title \
    startTime 2026-04-01T00:00:00Z \
    eventName download \
    user <suspect-email>

# `gam7 print drivefileacls` enumerates current ACLs on a file — useful as a snapshot baseline
```

### 5.6 Filter / Forwarding Rule Forensics

Workspace's equivalent of the M365 inbox-rule attack is Gmail filter creation:

```bash
# Filter creation events
gam7 report admin fields actor,event,parameters \
    startTime 2026-04-01T00:00:00Z \
    eventName CREATE_FILTER

# Forwarding rules per-user
gam7 user <suspect-email> show forwardingaddresses
gam7 user <suspect-email> show filters
```

`CREATE_FILTER` events to `parameters.filter_destination = "FORWARD"` toward an external mailbox is the canonical Workspace BEC-pivot persistence indicator. Cross-correlate with sign-in events from §5.1 `login` to identify the source IP / session that created the filter.

---

## 6. Okta — System Log & Identity Threat Protection

Okta is the canonical identity-provider audit surface for many enterprises (Workforce Identity) and consumer-facing apps (Customer Identity, formerly Auth0). System Log API events are the forensic spine.

### 6.1 System Log API

```bash
# /api/v1/logs - paginated, time-ordered
# Required: API token with `okta.logs.read` admin role; or OAuth2 with appropriate scopes
# Default retention: 90 days (Workforce); some plans differ; verify per tenant [verify 2026-04-27]

curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logs?since=2026-04-01T00:00:00Z&until=2026-04-27T00:00:00Z&limit=1000" \
  | jq

# Filter on actor / target / event
curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logs?filter=actor.id+eq+%22<okta-uid>%22+AND+published+gt+%222026-04-01T00:00:00Z%22" \
  | jq

# Eventtype filter (high-value)
curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logs?filter=eventType+eq+%22user.session.start%22+OR+eventType+eq+%22user.authentication.auth_via_mfa%22+OR+eventType+eq+%22application.user_membership.add%22" \
  | jq
```

### 6.2 Retention & Log Streaming

90-day default retention is the structural floor; longer retention requires Log Streaming to a customer-controlled sink (AWS EventBridge, Splunk HEC, custom HTTPS, Datadog, Sumo Logic, Microsoft Sentinel, etc.). Without log streaming, an investigation initiated more than 90 days post-event is bounded by what downstream sinks (corporate SIEM, identity-provider analytics) retained.

```bash
# Confirm log-streaming configuration (admin console → Reports → Log Streaming)
curl -s -H "Authorization: SSWS $OKTA_API_TOKEN" \
  "https://<org>.okta.com/api/v1/logStreams" \
  | jq

# Log-stream destinations show whether long-term retention is in place
```

### 6.3 Workforce Identity vs Customer Identity (Auth0)

Workforce Identity (`<org>.okta.com` / OIE) and Customer Identity (`<tenant>.auth0.com`, formerly Auth0, now Okta CIC) have **distinct** audit log APIs and event taxonomies. Auth0 events use the `/api/v2/logs` endpoint with codes like `s` (success login), `f` (failed login), `fp` (failed password), `seacft` (silent auth — refresh token grant).

```bash
# Auth0 (Customer Identity) log query
curl -s -H "Authorization: Bearer $AUTH0_MGMT_TOKEN" \
  "https://<tenant>.auth0.com/api/v2/logs?q=date%3A%5B2026-04-01%20TO%202026-04-27%5D" \
  | jq

# Auth0 default retention also short — verify per plan tier [verify 2026-04-27]
```

When the engagement covers consumer-facing identity (a B2C SaaS tenant Okta CIC / Auth0 protects), confirm whether Workforce, Customer Identity, or both are in scope.

### 6.4 Identity Threat Protection (ITP) Signal Sources

Okta ITP (Identity Threat Protection) is a 2024-era add-on that generates risk signals on suspicious sign-in patterns, session-token abuse, and identity-graph anomalies [verify 2026-04-27]. ITP signals surface in System Log as `policy.evaluate_sign_on` and `risk.assess` event families with risk score and reason codes. ITP draws on:

- IP reputation (Okta-curated + customer-provided lists).
- Device-trust posture (Okta Verify, Okta FastPass enrollment, Okta Device SDK signals).
- Behavioral baselines (login-time, login-location, login-device).
- Session-token abuse (token replay across geographies, refresh-token-without-recent-auth).
- Third-party signal ingestion (CrowdStrike, Microsoft, Google ChromeOS, etc.).

ITP-flagged sign-ins are forensic gold even when the action that followed was logged as benign — the ITP score tells you which sessions warrant deeper inspection.

### 6.5 Universal Directory Event Taxonomy

Okta's Universal Directory generates events in nine major families. High-value events for forensics:

| Family | Examples | Forensic value |
|---|---|---|
| `user.session.*` | `start`, `end`, `expire` | Sign-in / sign-out reconstruction |
| `user.authentication.*` | `auth_via_mfa`, `auth_via_password`, `auth_via_social_idp`, `auth_via_inbound_federation` | MFA bypass, federated-IdP consumption |
| `user.account.*` | `unlock`, `lock`, `update_password`, `reset_password`, `privilege_grant`, `privilege_revoke` | Account-state changes (often attacker persistence) |
| `user.lifecycle.*` | `create`, `delete`, `activate`, `suspend`, `unsuspend`, `deactivate` | New-user provisioning (potential persistence) |
| `application.user_membership.*` | `add`, `remove` | App-assignment changes (potential lateral) |
| `application.lifecycle.*` | `create`, `update`, `delete` | New SP / OIDC client created in tenant |
| `policy.*` | `policy_create`, `policy_update`, `policy_delete`, `evaluate_sign_on`, `policy_rule_*` | Conditional-access / sign-on policy changes |
| `system.*` | API-token operations, admin-role assignments, factor enrollments | High-privilege configuration changes |
| `risk.*` | `risk.assess`, ITP signals | Risk-scored sign-in / session events |

### 6.6 Cross-Tenant Impersonation Indicators

When Okta is the IdP for both source and target tenants (e.g., a managed-service-provider model where one Okta org federates into customer tenants via inbound federation), `auth_via_inbound_federation` events on the **target** tenant must be cross-walked to the **source** tenant's session events. Sophisticated attackers abuse delegated-admin or partner-portal access to impersonate tenant admins; the forensic signature is a sign-in event chain that crosses Okta org boundaries within seconds.

---

## 7. Slack — Audit Logs & Discovery

Slack's forensic surface is **gated by tier**. Audit Logs API requires Enterprise Grid (no equivalent on Pro / Business+) [verify 2026-04-27]; Discovery API requires Enterprise Grid + DLP / E-Discovery participation. Customers on Pro / Business+ have access to compliance exports via the workspace owner UI, but no programmatic audit-log API.

### 7.1 Audit Logs API (Enterprise Grid)

```bash
# Required: Org-level admin token with `auditlogs:read` scope
# /api/v1/audit/logs (REST endpoint distinct from the Slack Web API)
curl -s -H "Authorization: Bearer $SLACK_AUDIT_TOKEN" \
  "https://api.slack.com/audit/v1/logs?oldest=$(date -u -d '2026-04-01' +%s)&latest=$(date -u -d '2026-04-27' +%s)&limit=1000" \
  | jq

# Action filter
curl -s -H "Authorization: Bearer $SLACK_AUDIT_TOKEN" \
  "https://api.slack.com/audit/v1/logs?action=user_login,app_installed,user_channel_join&limit=1000" \
  | jq
```

High-value Audit Logs API actions:

- `user_login`, `user_login_failed`, `user_logout` — sign-in audit.
- `user_channel_join`, `user_channel_leave`, `public_channel_created`, `private_channel_created`, `dm_created`, `mpim_created` — channel and DM activity.
- `app_installed`, `app_uninstalled`, `app_token_rotated` — Slack-app inventory changes.
- `org_verified_domain_added`, `org_verified_domain_removed` — domain trust changes.
- `workspace_added_to_enterprise`, `workspace_removed_from_enterprise` — Enterprise Grid org structure changes.
- `slack_connect_invitation_received`, `slack_connect_invitation_accepted` — cross-organization shared-channel formation (high signal for cross-tenant lateral).
- `dlp_violation` — DLP rule matches (when DLP is licensed).

### 7.2 Discovery API for Content

Discovery API exposes full message and file content for E-Discovery use cases — separate from Audit Logs API and tightly access-controlled. Discovery API access is granted via Slack's E-Discovery program enrollment [verify 2026-04-27]; not all Enterprise Grid customers have it active.

```bash
# Discovery endpoints (verify current shape per Slack docs)
# GET /discovery.enterprise.info  - org configuration
# GET /discovery.users.list       - user enumeration
# POST /discovery.conversations.history - message content per conversation
# GET /discovery.conversations.recent   - recent messages cross-tenant

curl -s -H "Authorization: Bearer $SLACK_DISCOVERY_TOKEN" \
  "https://slack.com/api/discovery.conversations.history?channel=<C…>&oldest=$(date -u -d '2026-04-01' +%s)" \
  | jq
```

**Tombstone semantics.** Slack's Discovery API can return tombstones for messages deleted via retention policy — the message body is gone but the existence and timestamp remain. This is the "user deleted the message" forensic signal; pair with hold mechanisms (Discovery API holds, Compliance Export with E-Discovery retention) to preserve content before deletion.

### 7.3 Retention vs E-Discovery

Slack message retention is workspace-policy-controlled (admin sets delete-after-N-days). When retention is short (some workspaces set 30 or 90 days), forensic windows are bounded. E-Discovery via Discovery API + retention hold overrides workspace retention for the held custodians.

### 7.4 Slack Connect Cross-Tenant Forensics

Slack Connect (formerly "shared channels") creates a single channel that lives in two or more Slack orgs. Each side sees the channel and its messages, with per-org governance. For forensics, Slack Connect events are dual-cloud: the Audit Logs of both sides should be collected when investigating cross-tenant data movement.

```bash
# Surfacing Slack Connect channels (admin token required)
curl -s -H "Authorization: Bearer $SLACK_AUDIT_TOKEN" \
  "https://api.slack.com/audit/v1/logs?action=slack_connect_invitation_accepted,external_org_added" \
  | jq
```

Risk patterns: a Slack Connect invitation accepted by a compromised user, granting the attacker's external org persistent visibility into channels the user is a member of.

---

## 8. Salesforce — Setup Audit Trail & Event Monitoring

Salesforce splits its forensic surface across Setup Audit Trail (free, 180-day window of admin / setup changes), Login History (6 months), and Real-Time Event Monitoring (Salesforce Shield add-on; long-term, streaming, content-rich).

### 8.1 Setup Audit Trail (180-Day)

SAT captures every admin-level setup / metadata change — profile / permission-set edits, custom-object creation, OAuth Connected App authorization, sharing-rule changes, login-IP-range modifications, etc. Free with all editions.

```bash
# REST API query
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+CreatedDate,CreatedBy.Username,Action,Section,Display,DelegateUser+FROM+SetupAuditTrail+WHERE+CreatedDate+%3E+2026-04-01T00:00:00Z" \
  | jq

# UI: Setup → Quick Find → "View Setup Audit Trail" → Download (CSV)
```

High-value SAT actions:

- `assignedRoleToUser`, `assignedPermissionSetToUser`, `assignedProfileToUser` — privilege assignment.
- `connectedAppAuthorized`, `connectedAppRevoked` — OAuth Connected App lifecycle.
- `loginAsGrantedToOrg`, `loginAsGrantedToUser` — admin-impersonation grants (a top BEC-pivot indicator on Salesforce).
- `changedSamlConfig`, `changedSsoConfig`, `changedCorpDomain` — federation configuration.
- `dataExportRequested`, `dataExportDownloaded` — full-tenant data export (high-volume exfil indicator).
- `appExchangeAppInstalled` — third-party app installation.

### 8.2 Real-Time Event Monitoring (Shield Add-On)

RTEM streams per-API-call, per-record-access, per-report-export, per-session-event in near-real-time to a Big Object store and to external SIEMs. Event types include `ApiEvent`, `BulkApiResultEvent`, `LoginEvent`, `LogoutEvent`, `ReportEvent`, `LightningPageViewEvent`, `RestApiEvent`, `SessionEvent`, `UriEvent`. Subset is also available without Shield via the `EventLogFile` object (24-hour-old hourly logs), but the streaming and long-retention layer requires Shield.

```bash
# RTEM via REST query (Shield-licensed orgs)
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+EventDate,Username,SourceIp,EventType,Operation,Records,Query+FROM+ReportEvent+WHERE+EventDate+%3E+2026-04-01T00:00:00Z" \
  | jq

# `EventLogFile` (non-Shield) — 24-hour-delayed hourly logs, retention 1-30 days depending on edition
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+Id,EventType,LogFile,LogDate+FROM+EventLogFile+WHERE+LogDate+%3E+2026-04-01T00:00:00Z" \
  | jq
```

### 8.3 Threat Detection (Shield)

Salesforce Threat Detection is an ML-driven anomaly-detection feature within Shield [verify 2026-04-27]. Event types include `ApiAnomalyEvent`, `CredentialStuffingEvent`, `ReportAnomalyEvent`, `SessionHijackingEvent`. Findings are queryable via REST and surface in the Salesforce Threat Detection app.

### 8.4 Login History

```bash
curl -s -H "Authorization: Bearer $SF_TOKEN" \
  "https://<MyDomain>.my.salesforce.com/services/data/v60.0/query/?q=SELECT+UserId,LoginTime,SourceIp,LoginType,Status,Browser,Platform,LoginUrl+FROM+LoginHistory+WHERE+LoginTime+%3E+2026-04-01T00:00:00Z" \
  | jq
```

### 8.5 Salesforce Communities / Experience Cloud

Communities (rebranded Experience Cloud) are external-user portals embedded in a Salesforce org. Cross-tenant impersonation risk: a compromised internal account creates a Community user whose permissions overlap with internal records, then accesses via the external portal. SAT captures the user-creation action (`createdCustomerPortalUser`, `createdPartnerUser`); RTEM `LoginEvent.LoginType = 'Login Sub Site'` distinguishes Community sign-ins from internal sign-ins.

---

## 9. GitHub & GitLab — Audit Log Forensics

Source-control SaaS audit is high-value for both insider-threat (mass-clone, mass-fork) and supply-chain-attack (token theft, malicious workflow injection) scenarios. The audit surface is org/enterprise-tier-gated for both vendors.

### 9.1 GitHub Audit Log

The GitHub Organization audit log (and Enterprise audit log for enterprise customers) covers all administrative events on the org / enterprise. Organization-tier audit retention is short via the API (~6 months); long-term retention requires audit-log streaming to S3, Azure Event Hubs, Datadog, Splunk, Google Cloud Storage, or Sumo Logic [verify 2026-04-27].

```bash
# Org audit log via REST
curl -s -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/<org>/audit-log?phrase=created:2026-04-01..2026-04-27&per_page=100" \
  | jq

# Enterprise audit log (enterprise admin token required)
curl -s -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/enterprises/<slug>/audit-log?phrase=created:2026-04-01..2026-04-27&per_page=100" \
  | jq

# GraphQL audit (alternative shape; enterprise-only, includes Git events when streaming is configured)
gh api graphql -f query='
query($org: String!, $cursor: String) {
  organization(login: $org) {
    auditLog(first: 100, after: $cursor) {
      nodes { ... on AuditEntry { actorLogin createdAt action } }
      pageInfo { hasNextPage endCursor }
    }
  }
}' -f org=<org>
```

### 9.2 GitHub Audit Log Event Taxonomy

| Category | Examples | Forensic value |
|---|---|---|
| `git.*` | `git.clone`, `git.fetch`, `git.push` | Mass-clone exfil indicator (high signal); requires Git events streaming enabled [verify 2026-04-27] |
| `repo.*` | `repo.create`, `repo.destroy`, `repo.transfer`, `repo.access`, `repo.actions_enabled`, `repo.add_member`, `repo.access_visibility_change` | Repo-lifecycle events; new public repo from a private-only org is anomalous |
| `org.*` | `org.invite_member`, `org.remove_member`, `org.update_member`, `org.add_outside_collaborator`, `org.update_default_repository_permission` | Org-level membership changes |
| `oauth_application.*` | `oauth_application.create`, `oauth_application.transfer`, `oauth_application.revoke_tokens` | OAuth-app lifecycle |
| `personal_access_token.*` | `personal_access_token.access_granted`, `personal_access_token.access_revoked` | Fine-grained PAT issuance and approval |
| `workflows.*`, `actions.*` | `workflows.cancel_workflow_run`, `workflows.disable_workflow`, `workflows.repair_workflow_runs` | CI/CD pipeline manipulation |
| `protected_branch.*` | `protected_branch.create`, `protected_branch.destroy`, `protected_branch.update_admin_enforced` | Branch-protection bypass |
| `secret_scanning.*` | `secret_scanning.alert_resolved`, `secret_scanning.alert_dismiss` | Suspicious dismissal of secret-leak alerts |
| `code_scanning.*` | `code_scanning.configure_scan`, `code_scanning.alert_dismiss` | Code-scanning policy bypass |
| `business.*` | `business.create_organization`, `business.add_admin` | Enterprise structural changes |

Mass-clone detection (the canonical insider-threat signal) requires Git events streaming. Without it, `git.clone` actions are not visible in the API; the forensic signal must come from `repo.access` events (when public-private toggles are involved) or downstream telemetry (CDN logs, employee egress monitoring).

### 9.3 GitLab Audit Events

```bash
# Group audit events (Premium tier+ required for full coverage)
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

GitLab event taxonomy parallels GitHub at the conceptual level (member changes, repo changes, settings changes, runner / pipeline events) but differs in field shapes; verify against current `/api/v4` documentation [verify 2026-04-27].

### 9.4 CI/CD Secret Access Reconstruction

When a CI/CD pipeline is suspected of credential theft (a workflow run accessed an AWS / Azure / GCP / Slack / Stripe / Twilio token from secrets and exfiltrated it), the reconstruction joins:

- **GitHub Actions** — `workflows.workflow_run.created`, `workflows.workflow_run.completed` events; the `repository.id` + `run_id` + `head_branch` + `actor` triad identifies the run; logs are 400-day retained at the run level [verify 2026-04-27]. Subsequent token use is in the downstream cloud (route to [[sop-cloud-forensics|Cloud Forensics]] §7 IAM Forensics).
- **GitLab CI** — pipeline / job audit, runner audit, masked variable audit (variables marked masked are not logged in plaintext, but their *use* in a job is logged at the job-event level).
- **Workload Identity Federation pivot** — when the CI provider issues an OIDC token consumed by AWS / Azure / GCP, the `aud` / `sub` / `iss` claims tie the cloud-side `AssumeRoleWithWebIdentity` / Entra federated-credential / GCP `GenerateAccessToken` event back to the source workflow run. Cross-walk documented in [[sop-cloud-forensics|Cloud Forensics]] §7.5.

---

## 10. OAuth Consent-Grant Abuse Forensics

OAuth consent-grant abuse — frequently called "OAuth-app phishing," "illicit consent grant," or "OAuth-BEC variant" — is an attacker pattern that defeats MFA and session-token rotation by establishing a *separate* persistence channel: an attacker-controlled OAuth application that the victim consents to. Once consent is granted, the attacker holds offline-access refresh tokens and can read mailboxes, files, calendars, or whatever the granted scope permits, **without ever signing in as the victim**. Per the buildout-plan scope contract for the forensics trio, this variant lives in #8 (this SOP), not in [[sop-email-bec-forensics|Email & BEC Forensics]] (which covers header-spoofing / wire-recall BEC).

### 10.1 The Pattern

1. **App registration.** Attacker registers a multi-tenant OAuth app in their own tenant (M365: app registration in attacker Entra ID; Workspace: OAuth client in attacker GCP project; Salesforce / Okta / Slack: vendor-specific OAuth client).
2. **Consent harvest.** Attacker phishes the victim with a link to the app's consent screen. The victim sees an official-looking consent dialog from Microsoft / Google / Salesforce and accepts.
3. **Token issuance.** Provider mints access + refresh tokens scoped to whatever permissions the victim granted (commonly: `Mail.Read`, `Files.Read.All`, `User.Read`, `offline_access`).
4. **Persistent access.** Attacker uses refresh tokens to read mail / files / messages on demand. MFA does not help — no interactive sign-in is required after consent. Password rotation does not help — refresh tokens are independent of password.
5. **Continuation.** Attacker abuses the access for BEC (read inbound payment-confirmation mail), data theft (download Drive contents), or reconnaissance (read calendar / address book / org chart).

### 10.2 M365 — `oauth2PermissionGrants` and App-Role Assignments

```bash
# Required Graph permissions: Application.Read.All, Directory.Read.All, OAuth2PermissionGrant.Read.All

# Enumerate all delegated-permission grants in the tenant
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?\$top=999" \
  > oauth-grants.json

# Enumerate all app-role assignments to service principals (application permissions)
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/servicePrincipals?\$expand=appRoleAssignments&\$top=999" \
  > sp-app-roles.json

# Enumerate apps with "Send mail as", "Read mail in all mailboxes", "Files.Read.All", and other high-risk app-only permissions
jq '.value[] | select(.appRoles[]?.value | test("Mail\\.|Files\\.|Sites\\.FullControl"))' sp-app-roles.json
```

UAL events of interest (from §4.4):

- `Add app role assignment to service principal` — admin or user grants application-only permission. **Highest signal**: app-only permissions can act without a user.
- `Consent to application` — user or admin consents to an OAuth app. The `ConsentContext` field in `AuditData` distinguishes admin-consent (org-wide) from user-consent (single user).
- `Add service principal` — new service principal materialized in the tenant (typically when a multi-tenant app is first consented to).
- `Add owner to application`, `Add member to role`, `Update service principal` — post-consent privilege changes.

```powershell
Search-UnifiedAuditLog -StartDate "2026-04-01" -EndDate "2026-04-27" `
    -Operations "Consent to application","Add service principal","Add app role assignment to service principal","Add OAuth2PermissionGrant" `
    -ResultSize 5000 | Select CreationDate,UserIds,Operations,AuditData
```

### 10.3 Workspace — OAuth Token Issuance Audit

Workspace `token` Reports API surfaces both `authorize` (consent issuance) and `revoke` events:

```bash
gam7 report token startTime 2026-04-01T00:00:00Z eventName authorize \
  fields user,event,client_id,app_name,scope

# Cross-walk to currently-authorized apps per user
gam7 user <suspect-email> show oauth
```

Workspace's OAuth verification status (verified vs unverified) and the App Access Control admin policy gate which OAuth clients can be consented to — but historical incidents may pre-date a tighter policy. Pre-engagement App Access Control audit clarifies which apps were authorized with which scopes during the suspect window.

### 10.4 App-Registration Forensics

For each OAuth app implicated:

1. **Tenant of origin** — app registrations live in the *publisher* tenant; consents live in the *consumer* tenant. Identifying the publisher tenant is the first step in attribution.
2. **Verified-publisher status** — Microsoft Verified Publisher, Google verified developer, Slack-app-directory listing — verified status raises the bar against impersonation but is not a guarantee.
3. **Reply URLs / redirect URIs** — attacker apps frequently use `localhost`, ngrok-style tunnels, or short-lived domain-fronted endpoints. URLs not on the publisher's documented domain are suspect.
4. **Permissions / scopes requested** — broad scopes (`Mail.ReadWrite`, `Files.ReadWrite.All`, `Sites.FullControl.All`, `https://www.googleapis.com/auth/gmail.readonly`) demand justification.
5. **Client-secret / federated-credential rotation** — sudden changes to publisher credentials post-consent are a tampering signal.

### 10.5 Consent-Event Reconstruction

The full consent timeline:

| Step | M365 event | Workspace event | Investigative value |
|---|---|---|---|
| User clicks consent link | (no event — pre-consent) | (no event) | Phishing-vector reconstruction comes from email logs and [[sop-cloud-forensics|Cloud Forensics]] sign-in logs |
| User authenticates (if not already) | Entra ID `Sign-in` (interactive, with the consent app as `appDisplayName`) | `login_success` | Identifies the user, source IP, MFA method |
| User clicks "Accept" on consent screen | UAL `Consent to application` | `token authorize` | Captures user, app, granted scopes |
| Provider issues access + refresh tokens | (token issuance is internal) | (internal) | Forensic gap — tokens are not audited at issuance; their *use* is |
| Attacker uses access token to read mail | UAL `MailItemsAccessed` (Premium) | Reports API `gmail` events (sparse — full visibility via BigQuery export) | Captures mail-item-level read; `AppId` field identifies the consenting app |
| Attacker uses refresh token to obtain new access token | (no separate event) | (no separate event) | Forensic gap — refresh-flow is not visible per use |
| Optional: attacker rotates app secret to lock the victim out | UAL `Update service principal` | `CHANGE_OAUTH2_CLIENT_*` | Tampering signal |

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
# List guest users
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/users?\$filter=userType eq 'Guest'&\$top=999"

# Cross-tenant access policy
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/default"
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners"

# Cross-tenant identity sync (Entra ID Premium feature)
az rest --method GET \
  --uri "https://graph.microsoft.com/v1.0/policies/crossTenantAccessPolicy/partners/<tenantId>/identitySynchronization"
```

UAL events: `Invite external user`, `Add user`, `Update cross-tenant access policy`, `Add policy`. Sign-in logs: `crossTenantAccessType` field distinguishes `b2bCollaboration`, `b2bDirectConnect`, `passthrough`, `serviceProvider`, `none`.

### 11.2 Workspace — External Sharing

```bash
# Drive event filter for external sharing
gam7 report drive fields user,event,doc_id,doc_title,target_user,visibility \
    startTime 2026-04-01T00:00:00Z \
    eventName change_user_access \
  | jq 'select(.events[].parameters[]? | select(.name == "target_user_email") | .value | contains("@<your-domain>") | not)'

# Tenant-wide sharing policy (admin console — no API for full policy state)
# Apps → Google Workspace → Drive and Docs → Sharing settings
```

### 11.3 Slack Connect

Per §7.4 above — `slack_connect_invitation_received`, `slack_connect_invitation_accepted`, `external_org_added` are the events; both organizations' Audit Logs should be collected.

### 11.4 Salesforce Communities / Experience Cloud

Per §8.5 above — internal-user-creates-Community-user pattern; SAT `createdCustomerPortalUser` event, RTEM `LoginEvent.LoginType = 'Login Sub Site'`.

### 11.5 SaaS-Side Identity Federation (vs. IdP-Side in Cloud Forensics)

[[sop-cloud-forensics|Cloud Forensics]] §3.3 / §7 / §12 covers the **IdP-provider side** — Entra ID, Workspace, Okta acting as the IdP that *issues* SAML / OIDC tokens consumed by AWS / Azure / GCP / SaaS apps. This SOP covers the **SaaS-app side** — the SAML SP / OIDC RP configuration *within* the SaaS app that consumes those tokens. The attack surface is the same federation, but the audit artifact lives on the *consumer* side here.

| Surface | SaaS-side audit event | Forensic value |
|---|---|---|
| M365 (federated to external IdP) | UAL `Update domain authentication`, Entra ID audit `Set federation settings on domain` | New federation = tenant-wide identity-trust change (e.g., the historical "Solorigate / SUNBURST" abuse pattern) |
| Workspace (federated to external IdP) | Reports API `admin` `CREATE_GATEWAY_SETTING`, `MODIFY_GATEWAY_SETTING`, SAML config events | Federation reconfiguration |
| Okta (inbound federation from another IdP) | System Log `policy.sso.update_admin_settings`, `idp.update.idp_default_settings` | IdP-side trust change |
| Salesforce | SAT `changedSamlConfig`, `changedSsoConfig`; RTEM `SamlEvent` | SAML SP config change |
| Slack | Audit Logs `org_sso_settings_changed` | SSO reconfiguration |
| GitHub | Audit Log `org.update_saml_provider_settings`, `oauth_application.create` | SSO / OAuth config change |

Federation reconfiguration is a top-tier persistence primitive — an attacker who modifies the SaaS-app's federation trust to an attacker-controlled IdP can mint valid tokens for any user without ever touching the legitimate IdP. The signature is a SAML / OIDC config event in the SaaS audit followed by sign-ins via the new federation that do not appear in the legitimate IdP's logs.

---

## 12. Retention-Cliff & Discovery-Export Discipline

The dominant SaaS-forensics failure mode is "data was deleted before we could collect." This section codifies the pre-engagement and engagement disciplines that keep evidence preserved long enough to be reconstructed.

### 12.1 The Failure Mode

Concrete failure shapes seen in the wild:

- **Default retention expired.** Investigation initiated 200 days post-incident; UAL Audit Standard retention is 180; 20 days of evidence are gone. No long-term export was configured.
- **Attacker-disabled retention.** Sophisticated attacker reduces UAL retention via `Set-AdminAuditLogConfig`, narrows Workspace logs export filter, deletes Vault holds, or revokes the SIEM-ingest API token. Evidence vanishes during the dwell window.
- **User-deleted content.** End user (often the attacker, after credential theft) deletes mail / files / messages. Default retention does not cover content; only the access metadata remains.
- **Tenant-deleted artifact.** Entire mailbox / OneDrive / Drive / Slack channel deleted. Cold-recovery windows (M365 30-day soft delete + 30-day hard delete; Workspace 25-day Trash; Slack tombstones) are short.
- **License downgrade.** Customer downgrades from E5 to E3 mid-incident; UAL Premium events become unavailable on the new tier. The old events are not retroactively accessible.
- **Cross-region transfer required.** EU-resident tenant with US-investigator team. Data-residency rule blocks export until counsel review; the review takes weeks; retention expires.

### 12.2 Pre-Engagement Retention Sampling

The first-day procedure for every SaaS-forensics engagement:

1. **Inventory licenses and retention configuration.** UAL tier (Standard / Premium); Audit retention policy; Mailbox `AuditLogAgeLimit`; Workspace logs export configuration; Vault hold inventory; Okta log-streaming destinations; Slack workspace retention policy; Salesforce Shield licensing; GitHub audit-log streaming.
2. **Run a probe query.** Pull 1 hour of UAL / Reports API / System Log / Audit Logs at the engagement start; confirm events return; confirm fields look as expected; confirm no unusual gaps. A probe that returns zero events for a period the customer believes was active is itself a finding.
3. **Lock the evidence window.** Apply Vault holds, eDiscovery cases, Salesforce Field Audit Trail (if Shield), Slack Discovery holds — *before* deepening the investigation, *before* the user is alerted.
4. **Promise based on evidence, not on what should be there.** Frame the report's evidentiary scope on the day-1 probe results. If UAL Premium events are unavailable, do not promise mail-item-level reconstruction.

### 12.3 Provider-Specific Legal-Hold Mechanisms

| Vendor | Hold mechanism | Override tenant retention? |
|---|---|---|
| Microsoft 365 | In-place hold (legacy); Litigation hold (per-mailbox); Retention policies (Purview, scoped); eDiscovery hold (case-scoped) | Yes — retention-policy preserves; litigation-hold preserves indefinitely until removed |
| Google Workspace | Vault hold | Yes — overrides workspace and per-user retention indefinitely |
| Okta | (No customer-side content hold; identity events only — handled via log streaming) | N/A |
| Slack | Discovery API hold; Compliance Export retention | Yes — overrides workspace retention |
| Salesforce | Field Audit Trail (Shield); per-record locking; legal-hold via custom apps | Yes — Field Audit Trail preserves field-level history per the rules |
| GitHub | Audit-log streaming destination retention; archived-org policy | Indirect — original events streamed, source retention may expire |

Hold scope is tight: a hold preserves what is *already* in the system at hold time. It does not retroactively bring back data that was already deleted. The hold-first discipline (§12.2 step 3) is the only durable mitigation.

### 12.4 Export-Format & Chain-of-Custody Discipline

Per [[../../Investigations/Techniques/sop-collection-log|Collection Log]], every SaaS export must be:

- **Hashed at export.** SHA-256 of the export package immediately on download, before any analysis. Record source-tenant ID, source-API endpoint, time range, executing-admin identity, destination URI.
- **Stored read-only.** Encrypted at rest, access-controlled, with a `read-only` filesystem permission set as a secondary safeguard.
- **Archived in a fixed format.** Native vendor formats (PST for M365 mail, MBOX for Workspace mail, JSON for log artifacts, native Drive formats for Workspace files) are preferable to converted formats; conversion is post-evidence-archive.
- **Logged in a chain-of-custody table.** Per-export entry: who exported, when, from where, hash, size, recipients, evidence-locker location.
- **Retained per engagement contract.** Cryptographic destruction at engagement end if contract requires; otherwise retained encrypted under engagement-specific keys; litigation-hold provisions per [[sop-legal-ethics|Legal & Ethics]].

For multi-vendor engagements, cross-vendor export naming convention reduces confusion: `<case-id>-<vendor>-<surface>-<YYYY-MM-DD>-<window>.<ext>` (e.g., `case-2026-04-27-m365-ual-2026-04-01-to-2026-04-27.json`).

---

## 13. SaaS-Native IR Tooling

### 13.1 Microsoft

- **Microsoft Sentinel** (when ingesting M365 + Entra ID + DCA) — KQL hunting across SigninLogs, AuditLogs, OfficeActivity, CloudAppEvents, SecurityAlert tables. The canonical cross-source query surface for M365-heavy customers.
- **Microsoft Defender XDR** — Advanced Hunting endpoint with `CloudAppEvents`, `AlertInfo`, `EmailEvents`, `EmailAttachmentInfo`, `IdentityLogonEvents`, `IdentityQueryEvents`, `IdentityDirectoryEvents` schemas across Defender for Endpoint / Identity / Cloud Apps / Office.
- **Microsoft Defender for Cloud Apps** — direct SaaS-anomaly engine; OAuth-app risk scoring; activity browsing across connected apps (M365 and third-party OAuth-connected apps).
- **Microsoft Purview** — eDiscovery + Compliance Search + DLP (§4.7-4.8).
- **Microsoft Incident Response (formerly DART)** — first-party IR team available under support contract; can unlock collection paths customer-side tooling cannot.

### 13.2 Google Workspace

- **Workspace Security Center** (Enterprise tier) — cross-application investigation tool with security health, dashboard, and investigation tool (filter / pivot across Reports API events from a single UI).
- **Workspace Alert Center** — alert feed (suspicious sign-in, leaked passwords, drive sharing alerts, gmail phishing alerts, government-backed attack alerts).
- **Chronicle / Google SecOps** — when ingesting Workspace via the connector, cross-source detection and YARA-L 2.0 rules.
- **Workspace logs export to GCP** — long-term retention (§5.2).

### 13.3 Okta

- **Okta Workflows** — ITP-driven automation; can trigger session-revoke on risk signals.
- **Okta Identity Threat Protection** — risk-scored identity signals (§6.4).
- **Log streaming** — primary long-retention surface (§6.2).

### 13.4 Salesforce

- **Salesforce Shield** — Event Monitoring + Field Audit Trail + Platform Encryption + Threat Detection bundle (§8.2-8.3).
- **Salesforce Health Check** — baseline configuration assessment.

### 13.5 Slack

- **Audit Logs API + SIEM ingest** — primary forensic surface (§7.1).
- **Discovery API + DLP** — content-level review when E-Discovery is active.

### 13.6 Open-Source / Vendor-Neutral

| Tool | Purpose | Notes |
|---|---|---|
| Hawk (CrowdStrike) | M365 Compromise Analysis PowerShell | Pre-canned UAL queries focused on common compromise patterns; updated periodically [verify 2026-04-27] |
| MIA (CISA Microsoft Incident Analysis) | UAL / Entra ID query toolkit | CISA-published; aligns with CISA's compromise-detection guidance |
| Untitled Goose Tool (CISA) | Multi-CSP + M365 / Entra triage | CISA-published cross-cloud / SaaS triage tool [verify 2026-04-27] |
| GoosePack / DART tools | Microsoft DART investigative toolkit (when shared by engagement) | Subject to availability; verify support-contract scope |
| Magnet Axiom Cloud (commercial) | M365 / Workspace / Slack content acquisition | Commercial; verify case-fit before licensing |
| Cellebrite Endpoint Inspector / Cloud (commercial) | Cloud-platform acquisition | Commercial; LE-focused |
| Aware (commercial) | Slack / Teams / Workspace collaboration data analytics | Commercial DLP / discovery |
| GAM7 (Workspace) | CLI for Workspace admin operations including audit / Vault | Open-source; community-maintained |
| Sigma rules (SaaS-Sigma) | Vendor-neutral detection rules with M365 / Workspace / Okta / GitHub backends | https://github.com/SigmaHQ/sigma; convertible to KQL / Athena / Splunk / Elastic |
| Splunk SOAR / Cortex XSOAR / Tines / Torq | SOAR platforms with SaaS connectors | Vendor-neutral wrappers around per-vendor APIs |
| BloodHound / AzureHound | Identity-graph extraction (offensive-leaning, useful for understanding the adversary view) | https://github.com/BloodHoundAD |
| ROADtools | Entra ID / M365 enumeration toolkit (read-only modes useful for forensics inventory) | https://github.com/dirkjanm/ROADtools |
| Seatbelt / SharpHound (when host telemetry is available) | Host-side identity / token enumeration | Cross-link to [[sop-forensics-investigation|Digital Forensics Investigation]] for host-side forensic use |

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
| Authorized offensive SaaS testing (red-team, post-incident validation, purple-team) | (planned) — SaaS pentesting SOP not yet built; CLAUDE.md "Gaps" item |
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
| Search-UnifiedAuditLog | M365 | Legacy synchronous UAL query (Exchange Online PowerShell) |
| Audit Search Graph API | M365 | Async UAL query (recommended for large pulls) |
| Search-MailboxAuditLog | M365 | Per-mailbox audit (legacy) |
| Microsoft Graph PowerShell SDK | M365 | Scriptable Graph access including `oauth2PermissionGrants`, `servicePrincipals` |
| Microsoft Sentinel | M365 | KQL-based SIEM with M365 + Entra ID connectors |
| Defender XDR Advanced Hunting | M365 | KQL across Defender product family |
| Defender for Cloud Apps | M365 | SaaS-anomaly engine + OAuth-app risk |
| Microsoft Purview / eDiscovery | M365 | Compliance Search, eDiscovery (Standard + Premium), holds |
| Workspace Reports API | Google Workspace | Per-application activity feeds |
| GAM7 | Google Workspace | CLI wrapper for Reports API + Vault + admin |
| Workspace logs export to BigQuery | Google Workspace | Long-term audit retention |
| Gmail BigQuery export | Google Workspace | Full mail-flow events |
| Workspace Vault | Google Workspace | eDiscovery + holds |
| Workspace Security Center | Google Workspace | Cross-application investigation tool |
| Chronicle / Google SecOps | Google Workspace | Cloud-native SIEM (YARA-L 2.0) |
| Okta System Log API | Okta | Identity event audit |
| Okta Workflows | Okta | Automation / response to ITP signals |
| Slack Audit Logs API | Slack | Org-level audit (Enterprise Grid) |
| Slack Discovery API | Slack | Content E-Discovery |
| Salesforce Setup Audit Trail | Salesforce | 180-day setup-change audit |
| Salesforce Real-Time Event Monitoring | Salesforce | Streaming / long-retention event log (Shield) |
| Salesforce EventLogFile | Salesforce | 24-hour-delayed hourly logs (non-Shield) |
| Salesforce Threat Detection | Salesforce | ML anomaly detection (Shield) |
| GitHub Audit Log API | GitHub | Org / enterprise audit events |
| GitHub Audit Log streaming | GitHub | Long-term retention to S3 / Splunk / Datadog / etc. |
| GitLab Audit Events API | GitLab | Group / instance audit events |

### Open-Source / Vendor-Neutral

| Tool | Purpose | Link |
|------|---------|------|
| Hawk | CrowdStrike-published M365 compromise-analysis PowerShell | https://github.com/T0pCyber/hawk [verify 2026-04-27] |
| MIA (Microsoft Incident Analysis) | CISA-published M365 / Entra triage | https://github.com/cisagov/untitledgoosetool [verify 2026-04-27] |
| Untitled Goose Tool | CISA cross-cloud + M365 / Entra triage | https://github.com/cisagov/untitledgoosetool |
| GAM7 | Workspace admin / audit CLI | https://github.com/GAM-team/GAM |
| Sigma | Vendor-neutral detection rules | https://github.com/SigmaHQ/sigma |
| ROADtools | Entra ID / M365 enumeration | https://github.com/dirkjanm/ROADtools |
| BloodHound | Identity-graph (AD + Entra) | https://github.com/BloodHoundAD/BloodHound |
| AzureHound | Entra ID identity collector | https://github.com/BloodHoundAD/AzureHound |
| TeamFiltration | M365 / Entra ID hunt + abuse toolkit (offensive-leaning; useful for understanding adversary view) | https://github.com/Flangvik/TeamFiltration [verify 2026-04-27] |
| MicroBurst | Azure / M365 attack-surface scanning | https://github.com/NetSPI/MicroBurst |
| Robust Cloud Trail Hunter (RCTH) | Cloud-multi-vendor hunting | (verify availability) [verify 2026-04-27] |

### Reference / Documentation

| Resource | Purpose |
|----------|---------|
| Microsoft Purview audit log activities | https://learn.microsoft.com/purview/audit-log-activities |
| Microsoft Graph audit logs | https://learn.microsoft.com/graph/api/resources/auditlogroot |
| Workspace Reports API reference | https://developers.google.com/admin-sdk/reports/v1/reference |
| Workspace Vault API reference | https://developers.google.com/vault/reference/rest |
| Okta System Log reference | https://developer.okta.com/docs/reference/api/system-log/ |
| Slack Audit Logs API | https://api.slack.com/admins/audit-logs |
| Slack Discovery API | https://api.slack.com/enterprise/discovery |
| Salesforce Setup Audit Trail | https://help.salesforce.com/s/articleView?id=sf.admin_monitorsetup.htm |
| Salesforce Event Monitoring | https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/event_monitoring.htm |
| GitHub audit log reference | https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization |
| MITRE ATT&CK for Cloud (Office 365 + Google Workspace + SaaS) | https://attack.mitre.org/matrices/enterprise/cloud/ |
| MITRE ATT&CK for Identity Provider | https://attack.mitre.org/matrices/enterprise/cloud/identity-provider/ |
| CISA SCuBA (Secure Cloud Business Applications) | https://www.cisa.gov/scuba — M365 / Workspace baseline configurations [verify 2026-04-27] |
| NIST SP 800-86 | Guide to Integrating Forensic Techniques into Incident Response |
| NIST SP 800-61 | Computer Security Incident Handling Guide |

---

## 16. Risks & Limitations

- **Retention is a structural limit.** Default retention floors (UAL Standard 180-day, Okta 90-day, Salesforce SAT 180-day, Slack workspace-set, GitHub ~6 months) bound the maximum reachable evidence window when long-term export is not configured. Investigations initiated past the floor are reconstructions, not reproductions; document the gap.
- **License-tier gates.** UAL Audit Premium (`MailItemsAccessed`, `Send`, search-query events), Salesforce Shield (Real-Time Event Monitoring + Threat Detection + Field Audit Trail), Slack Enterprise Grid (Audit Logs API), GitHub Enterprise (full audit + log streaming), Workspace Enterprise+ (Security Center) are paywalls. Customers without the relevant tier cannot retrieve the relevant events; the investigator cannot retroactively buy them in.
- **Data-plane logging gaps.** Per-mail-item, per-file, per-message access events are opt-in or paywalled across most SaaS surfaces. Without them, "did the attacker read mail X?" cannot be answered from logs alone — only "did the attacker access the mailbox?"
- **Provider-side log latency.** UAL surfaces events with 30-60 minute latency typically; Search-UnifiedAuditLog can lag further during high-volume periods [verify 2026-04-27]. Workspace Reports API events have variable latency. Real-time alerting and forensic reconstruction tolerate this differently — the investigator must not infer "the event did not happen" from a same-millisecond gap.
- **API-throttling under stress.** Aggressive forensic queries against a production tenant can hit per-user, per-token, or per-tenant rate limits, particularly during an active incident. Use bulk-export paths (eDiscovery, Vault, BigQuery export, log streaming) over high-cardinality API loops.
- **Evidence-spoliation risk during investigation.** Querying mailboxes, files, or repositories can change `LastAccessTime` or trigger user-visible notifications (e.g., Workspace "someone shared with you" or Slack "added to channel" telemetry). Read-only API paths are preferred over UI-driven access.
- **Cross-tenant log visibility is asymmetric.** A cross-tenant collaboration event (Slack Connect, Workspace external sharing, Entra B2B) appears on both sides, but the investigator typically only authorized for one side. The other tenant's audit is reachable only via provider legal process.
- **Court-admissibility framing.** SaaS-evidence Daubert posture is well-trodden for M365 / Workspace eDiscovery exports with provider declarations, but less so for Reports API / System Log / Audit Logs API outputs that did not pass through an eDiscovery or Vault hold. The hold-then-search discipline (§12) addresses this; raw API pulls without prior hold may face hearsay / authentication challenges.
- **Adversary log-aware behavior.** Sophisticated SaaS-incident operators target audit configuration — disabling UAL ingestion at the org level (where tier permits), shortening Okta log-streaming, narrowing Workspace logs export filter, revoking Slack audit tokens. The defensive answer is real-time alerting on configuration changes themselves and out-of-tenant log ingest beyond the suspect's reach.
- **Multi-tenant blast radius.** SaaS-incident scope balloons via shared infrastructure (a multi-tenant OAuth app abused across many customer tenants; a Slack Connect channel that touches a dozen organizations; an upstream identity provider that federates into hundreds of customer orgs). Initial scope estimates often understate the surface.
- **Evidence integrity end-to-end.** A SHA-256 hash at export proves nothing about the source-side integrity (the audit log writer could already have been compromised, or the provider could have a bug). UAL, eDiscovery, and Vault have provider-side declarations that pair with the customer-side hash; raw Reports API / System Log / Audit Logs API pulls do not carry a provider-signed integrity chain.
- **Tenant-deletion is a hard floor.** When an entire tenant or org is deleted (rare but happens during regulator-directed examinations), cold-recovery windows are short and provider-controlled. Engagement-time inventory and hold are the only durable mitigation.
- **OAuth-app revocation is not retroactive.** Revoking an attacker-controlled OAuth app stops *future* token use, but issued access tokens may continue to work until expiry (typically 1 hour) and the data already exfiltrated is gone. Revocation is containment, not evidence preservation.

---

## 17. Common Pitfalls

- **Treating an alert as the scope.** The alert fired on one user; the incident touched a half-dozen mailboxes via a delegated-permission OAuth app you didn't query.
- **Relying on portal "last 30 days" surfaces.** Entra ID portal sign-in default view is short; UAL portal search has lower record-type coverage than the cmdlet; Slack admin UI surfaces a small slice of audit. Programmatic API access is the forensic-grade surface.
- **Skipping retention sampling.** Promising a 6-month reconstruction without confirming what evidence actually exists is a recipe for an embarrassing day-3 update.
- **Querying without time-zone discipline.** UAL is UTC; Workspace Reports is UTC; Okta is UTC; Slack is Unix epoch (UTC); Salesforce is timezone-tagged ISO 8601; GitHub is UTC. Mixing offsets across vendors corrupts the unified timeline.
- **Paginating Search-UnifiedAuditLog wrong.** Default page is 100; max is 5000; legacy session-id paged mode is best-effort. Use Audit Search Graph API for >50K events per query.
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
- **Ignoring `MailItemsAccessed` throttling.** The Premium event family includes a documented "throttle bit" — when too many access events occur in a window, the provider may emit a single "throttled" event in lieu of per-item events. This is a documented behavior, not an attacker action [verify 2026-04-27]. Don't infer "no access" from a throttle event.
- **Skipping the OAuth-app inventory baseline.** Without a pre-engagement inventory, post-engagement detection of newly added OAuth apps is harder to distinguish from legitimate business activity.
- **Pasting raw event JSON into the report.** Tooling output is appendix material; findings are interpreted prose with referenced evidence IDs.
- **Stale credentials and tokens in investigator notes.** Engagement tokens (UAL admin token, GAM7 service-account key, Okta API token, Slack audit token, GitHub PAT) become a future-engagement liability. Rotate and document destruction at engagement end.

---

## 18. Real-World Scenarios

The scenarios below abstract observed SaaS-incident patterns to illustrate how the methodology in this SOP applies. They are pattern catalogues, not engagement-specific narratives.

### 18.1 Scenario — OAuth-Consent BEC: Multi-Tenant Attacker App Harvests Mailbox Tokens

**Pattern.** Attacker registers a multi-tenant Entra ID app named `Microsoft 365 Mail Helper` with a Microsoft logo. The attacker phishes a target organization with a link to `https://login.microsoftonline.com/common/oauth2/v2.0/authorize?...` requesting `Mail.Read` and `offline_access` scopes. A user clicks "Accept." The attacker's app receives access + refresh tokens, then over weeks reads inbound mail looking for invoice / wire / payment-confirmation patterns. When a wire-confirmation email arrives, the attacker creates an inbox rule via the *user's own session* (the access token grants Mail.ReadWrite if the scope was broad enough; otherwise via a session-token replay) to auto-forward incoming wire confirmations to an external address. The actual wire-fraud BEC pivots from there — but the lookalike-domain / header-spoofing piece is in [[sop-email-bec-forensics|Email & BEC Forensics]] per the trio split.

**Forensic catch.** §10.2 OAuth grant inventory surfaces the suspicious app. §4.4 `Consent to application` UAL events show the consent action with user, source IP, and timestamp. §4.4 `MailItemsAccessed` events (if Premium licensed) show per-mail-item reads tied to the app's `AppId`. §4.6 inbox-rule events identify the persistent auto-forward. §13.1 Defender for Cloud Apps OAuth-app risk score may have flagged the app pre-incident; verify whether the alert was suppressed.

**Hand-off.** Mailbox-content review for the actually-compromised mailboxes routes through Purview eDiscovery (§4.7). Wire-recall pathway and lookalike-domain analysis (if the attacker also spoofed a vendor domain) routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. Adversary multi-tenant app take-down coordination (a Microsoft-managed app revocation across all victim tenants) routes through MSRC.

### 18.2 Scenario — Credential-Phishing Mailbox Compromise → BEC Inbox-Rule Pivot

**Pattern.** Attacker phishes a user with a credential-harvest page that proxies the M365 sign-in flow (adversary-in-the-middle / EvilGinx-style). MFA is bypassed because the attacker captures the post-MFA session token, not the credentials alone. Attacker authenticates from a residential-proxy IP, immediately creates an inbox rule that moves any mail with subject containing "wire," "invoice," or "payment" to RSS Feeds (a low-visibility folder), and waits. When the rule fires, the attacker reads the moved mail via the captured session, replies from the user's mailbox to the wire-counterparty with updated routing details.

**Forensic catch.** §4.2 sign-in event from anomalous IP / ASN / device. §4.2 inbox-rule creation event correlated with the suspicious sign-in. §4.5 mailbox-audit `Send` events from the attacker session showing replies to the wire counterparty. §4.4 `MailItemsAccessed` (if Premium licensed) shows the attacker reading the moved mail. §13.1 Defender for Cloud Apps suspicious-mailbox-rule alert is the typical detector. §13.1 Sentinel KQL hunt: `OfficeActivity | where Operation in ("New-InboxRule", "Set-InboxRule") | where Parameters has "RSS Feeds" or has "Junk Email"`.

**Hand-off.** Header-forensic verification of the attacker's outbound replies (was the From-header spoofed; did the recipient's MTA mark DKIM-pass; what was the SPF posture) routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. Wire-recall mechanics route to [[sop-email-bec-forensics|Email & BEC Forensics]]. Adversary-in-the-middle phishing-page take-down routes through provider abuse + DNS-takedown coordination per [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]].

### 18.3 Scenario — Workspace External-Sharing Data Exfil via Compromised Account

**Pattern.** Insider with departing-employee disposition, or compromised employee account, modifies dozens of Drive documents to be shared with an external `gmail.com` address. Documents are sensitive (contract, customer list, strategic roadmap). The share events are visible in the Reports API `drive` feed.

**Forensic catch.** §5.1 / §5.5 Reports API `drive` `change_user_access` events to external domains. §5.1 `download` events from the external account (when the same account also appears as `actor` in subsequent reads — typically only if the external account is also Workspace-managed and the customer has cross-domain visibility, otherwise inferable only from share events). §5.4 Vault matter scoped to the user surfaces full content for review. §5.6 forwarding-rule sweep ensures no parallel email-forwarding persistence is in place.

**Hand-off.** External-account attribution (Gmail address registration date, recovery info, prior breach exposure) routes to [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] + [[../../Investigations/Techniques/sop-darkweb-investigation|Darkweb Investigation]] (if the address surfaces in known breach corpora). Human-resources investigation pathway is the customer's, not the investigator's.

### 18.4 Scenario — GitHub PAT Compromise → CI/CD Secret Theft → Cloud Pivot

**Pattern.** A developer's GitHub fine-grained PAT is exfiltrated via a compromised laptop. Attacker enumerates the user's accessible repos, identifies a repo with GitHub Actions workflows that grant cloud access via Workload Identity Federation, modifies the workflow to add a step that exfiltrates the OIDC token's downstream cloud session credentials. The next CI run pushes the credentials to attacker-controlled S3.

**Forensic catch.** §9.1-9.2 GitHub audit log: `personal_access_token.access_granted` + `repo.add_member` (if PAT is scoped to repo membership) + `git.push` events on the affected repo (when Git events streaming is configured). §9.4 GitHub Actions workflow run history (400-day retention) shows the modified workflow execution. Cross-cloud pivot reconstruction — the WIF token consumed in AWS / Azure / GCP — routes to [[sop-cloud-forensics|Cloud Forensics]] §7.5 cross-cloud Workload Identity Federation reconstruction.

**Hand-off.** Compromised-laptop forensics routes to [[sop-forensics-investigation|Digital Forensics Investigation]] for endpoint disk / memory analysis. Cloud-side IAM forensics + region sweep + log-tampering detection route to [[sop-cloud-forensics|Cloud Forensics]] §4-§9. Pipeline / supply-chain hardening recommendations route to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] for purple-team validation.

### 18.5 Scenario — Salesforce Admin-Impersonation via Login-As

**Pattern.** Attacker compromises a Salesforce administrator. Salesforce's `Login As` feature lets admins impersonate any user for support purposes. Attacker uses Login As to assume identities of executives, browses sensitive opportunities and contracts, and exports records via the Data Loader API.

**Forensic catch.** §8.1 SAT `loginAsGrantedToOrg` / `loginAsGrantedToUser` events identify which users were impersonated. §8.2 RTEM `LoginEvent.LoginType = 'Login As'` (Shield licensed) shows per-impersonation session start with source IP. §8.2 RTEM `BulkApiResultEvent` / `RestApiEvent` / `ReportEvent` show data-export volume from the impersonated session. §8.4 Login History identifies the original admin sign-in pattern that preceded the impersonation chain.

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
- **Provider legal process** is the route for cross-tenant evidence (tenant A is suspect, tenant B is victim). Subpoena / warrant / MLAT / preservation letter to Microsoft / Google / Slack / Salesforce / Okta / GitHub. Provider-published LE guidelines define the form. [verify 2026-04-27]
- **Cross-jurisdiction authorization.** EU-data, healthcare, payment, and government-tenant workloads can carry residency / sovereignty constraints that limit cross-border evidence transfer even with tenant authorization. Schrems II / DPF / SCCs framing, CLOUD Act executive agreements, and the Budapest Convention Second Additional Protocol shape MLAT alternatives. Verify under counsel.
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
- **HIPAA Breach Notification Rule** — covered entities + business associates have 60-day notification windows. SaaS tenants holding ePHI (M365 / Workspace under BAA, Salesforce under HIPAA-covered configuration) trigger this rule on compromise.
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
- Microsoft — Purview audit log activities — https://learn.microsoft.com/purview/audit-log-activities
- Microsoft — eDiscovery (Standard) docs — https://learn.microsoft.com/purview/ediscovery
- Microsoft — Audit Search Graph API — https://learn.microsoft.com/graph/api/resources/security-auditlogquery [verify 2026-04-27]
- Microsoft — Defender for Cloud Apps documentation — https://learn.microsoft.com/defender-cloud-apps/
- Microsoft — Microsoft Incident Response (formerly DART) blog — https://www.microsoft.com/security/blog/topic/microsoft-incident-response/ [verify 2026-04-27]
- Google — Workspace Reports API reference — https://developers.google.com/admin-sdk/reports/v1/reference
- Google — Vault API reference — https://developers.google.com/vault/reference/rest [verify 2026-04-27]
- Google — Workspace logs export to BigQuery — https://support.google.com/a/answer/9079365 [verify 2026-04-27]
- Okta — System Log API reference — https://developer.okta.com/docs/reference/api/system-log/
- Okta — Identity Threat Protection — https://help.okta.com/oie/en-us/content/topics/itp/itp.htm [verify 2026-04-27]
- Slack — Audit Logs API — https://api.slack.com/admins/audit-logs
- Slack — Discovery API — https://api.slack.com/enterprise/discovery
- Salesforce — Setup Audit Trail — https://help.salesforce.com/s/articleView?id=sf.admin_monitorsetup.htm
- Salesforce — Real-Time Event Monitoring — https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/event_monitoring.htm
- Salesforce — Threat Detection — https://help.salesforce.com/s/articleView?id=sf.real_time_em_threat_detection.htm [verify 2026-04-27]
- GitHub — Audit log for organizations — https://docs.github.com/en/organizations/keeping-your-organization-secure/managing-security-settings-for-your-organization/reviewing-the-audit-log-for-your-organization
- GitHub — Audit log streaming — https://docs.github.com/en/enterprise-cloud@latest/admin/monitoring-activity-in-your-enterprise/reviewing-audit-logs-for-your-enterprise/streaming-the-audit-log-for-your-enterprise [verify 2026-04-27]
- GitLab — Audit events documentation — https://docs.gitlab.com/ee/administration/audit_events.html

**Standards and frameworks:**
- NIST SP 800-86 — Guide to Integrating Forensic Techniques into Incident Response
- NIST SP 800-53 / 800-171 — Security and Privacy Controls
- NIST SP 800-61 — Computer Security Incident Handling Guide
- ISO/IEC 27037 — Identification, collection, acquisition, and preservation of digital evidence
- ISO/IEC 27041 — Investigative process assurance
- ISO/IEC 27042 — Analysis and interpretation
- ISO/IEC 27043 — Incident investigation principles and processes
- CSA Cloud Controls Matrix — https://cloudsecurityalliance.org/research/cloud-controls-matrix/
- CIS Microsoft 365 Foundations Benchmark — https://www.cisecurity.org/benchmark/microsoft_365 [verify 2026-04-27]
- CIS Google Workspace Foundations Benchmark — https://www.cisecurity.org/benchmark/google_workspace [verify 2026-04-27]
- MITRE ATT&CK for Cloud (Office 365 + Google Workspace + IaaS + SaaS) — https://attack.mitre.org/matrices/enterprise/cloud/
- MITRE ATT&CK for Identity Provider — https://attack.mitre.org/matrices/enterprise/cloud/identity-provider/
- CISA SCuBA (Secure Cloud Business Applications) — M365 + Workspace baseline configurations — https://www.cisa.gov/scuba [verify 2026-04-27]
- Berkeley Protocol on Digital Open Source Investigations (UN OHCHR + UC Berkeley HRC, 2022) — for human-rights / open-source intelligence dimensions where applicable

**Open-source projects and tools:**
- Hawk — https://github.com/T0pCyber/hawk [verify 2026-04-27]
- Untitled Goose Tool (CISA) — https://github.com/cisagov/untitledgoosetool [verify 2026-04-27]
- GAM7 — https://github.com/GAM-team/GAM
- Sigma — https://github.com/SigmaHQ/sigma
- ROADtools — https://github.com/dirkjanm/ROADtools
- BloodHound — https://github.com/BloodHoundAD/BloodHound
- AzureHound — https://github.com/BloodHoundAD/AzureHound
- TeamFiltration — https://github.com/Flangvik/TeamFiltration [verify 2026-04-27]
- MicroBurst — https://github.com/NetSPI/MicroBurst
- Microsoft 365 Extractor Suite (Invictus IR) — https://github.com/invictus-incident-response/Microsoft-Extractor-Suite [verify 2026-04-27]
- DFIR-O365RC (Sekoia) — https://github.com/sekoia-io/DFIR-O365RC [verify 2026-04-27]

**Vendor IR / threat-research blogs:**
- Microsoft Threat Intelligence — https://www.microsoft.com/security/blog/topic/threat-intelligence/ [verify 2026-04-27]
- Microsoft Incident Response (DART) — https://www.microsoft.com/security/blog/topic/microsoft-incident-response/ [verify 2026-04-27]
- Mandiant blog (Google-owned) — https://www.mandiant.com/resources/blog [verify 2026-04-27]
- Volexity (M365 / Entra deep-dives) — https://www.volexity.com/blog/ [verify 2026-04-27]
- Permiso Security (identity-threat research) — https://permiso.io/blog [verify 2026-04-27]
- Inversecos (Australian DFIR; M365 deep-dives) — https://www.inversecos.com/ [verify 2026-04-27]
- Invictus IR — https://www.invictus-ir.com/news [verify 2026-04-27]
- Sekoia.io blog — https://blog.sekoia.io/ [verify 2026-04-27]
- Huntress — https://www.huntress.com/blog [verify 2026-04-27]

**Training and certification:**
- SANS FOR509 — Enterprise Cloud Forensics and Incident Response (covers M365 / Workspace / Okta / SaaS) [verify 2026-04-27]
- SANS FOR578 — Cyber Threat Intelligence
- CISA SCuBA assessment training [verify 2026-04-27]
- Microsoft — SC-200 / SC-100 / SC-400 (Security Operations Analyst / Cybersecurity Architect / Information Protection Administrator)
- Google Cloud — Professional Cloud Security Engineer (covers Workspace security)

**Incident catalogues and case studies:**
- Verizon DBIR — annual incident analysis (cloud / SaaS breakouts each year) — https://www.verizon.com/business/resources/reports/dbir/
- CrowdStrike Global Threat Report — annual — https://www.crowdstrike.com/global-threat-report/
- Mandiant M-Trends — annual — https://www.mandiant.com/m-trends [verify 2026-04-27]
- Microsoft Digital Defense Report — annual — https://www.microsoft.com/security/business/microsoft-digital-defense-report [verify 2026-04-27]

---

**Version:** 1.0
**Last Updated:** 2026-04-27
**Review Frequency:** Quarterly (M365 / Workspace / Okta / Slack / Salesforce / GitHub API field renames, retention defaults, license-tier feature drift, and OAuth-consent abuse TTPs evolve on a quarterly cadence; classical eDiscovery / chain-of-custody fundamentals are slower)
