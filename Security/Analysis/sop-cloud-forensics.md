---
type: sop
title: Cloud Forensics SOP
description: "IaaS-plane forensics methodology: AWS CloudTrail / Azure Monitor + Sentinel / GCP Audit Logs collection, IAM principal-action reconstruction, region-sweep, log-tampering detection, container-runtime artifacts (EKS / AKS / GKE), cloud-volume snapshot preservation with hash-chain integrity, and cross-cloud correlation."
tags:
  - sop
  - cloud-forensics
  - dfir
  - incident-response
  - iaas
  - aws
  - azure
  - gcp
  - kubernetes
  - container-forensics
created: 2026-04-27
updated: 2026-04-27
template_version: 2026-04-27
---

# Cloud Forensics SOP

> **Authorized environments only.** Cloud forensics is a defensive discipline. This SOP covers post-incident IaaS-plane evidence collection and analysis on accounts the investigator is authorized to access — incident response retainer scope, internal SOC / DFIR work on tenants the team owns, regulator-directed examinations under appropriate authority, or law-enforcement collection backed by warrant / MLAT. It does **not** authorize unauthorized access, account take-overs, exploitation, or active-defense pivots into adversary infrastructure. Cross-references: [[sop-legal-ethics|Legal & Ethics]] for jurisdictional framing, [[sop-opsec-plan|OPSEC]] for investigator account hygiene during an active incident, [[sop-forensics-investigation|Digital Forensics Investigation]] as the parent template for host / disk / memory forensics (cloud forensics extends, does not replace), [[../../Investigations/Techniques/sop-collection-log|Collection Log]] for chain-of-custody discipline. Offensive cloud testing routes to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] (different posture, different authorization model).

## Table of Contents

1. [Objectives & Scope](#1-objectives--scope)
2. [Pre-Engagement & Authorization](#2-pre-engagement--authorization)
3. [Cloud Forensics Landscape](#3-cloud-forensics-landscape)
4. [AWS — IaaS-Plane Forensics](#4-aws--iaas-plane-forensics)
5. [Azure — IaaS-Plane Forensics](#5-azure--iaas-plane-forensics)
6. [GCP — IaaS-Plane Forensics](#6-gcp--iaas-plane-forensics)
7. [IAM Forensics: Principal-Action Reconstruction](#7-iam-forensics-principal-action-reconstruction)
8. [Region-Sweep Methodology](#8-region-sweep-methodology)
9. [Log-Tampering Detection](#9-log-tampering-detection)
10. [Container & Kubernetes Runtime Artifacts](#10-container--kubernetes-runtime-artifacts)
11. [Evidence Preservation for Cloud Volumes](#11-evidence-preservation-for-cloud-volumes)
12. [Cross-Cloud Correlation](#12-cross-cloud-correlation)
13. [Cloud-Native IR Tooling](#13-cloud-native-ir-tooling)
14. [Hand-off Boundaries](#14-hand-off-boundaries)
15. [Tools Reference](#15-tools-reference)
16. [Risks & Limitations](#16-risks--limitations)
17. [Common Pitfalls](#17-common-pitfalls)
18. [Real-World Scenarios](#18-real-world-scenarios)
19. [Related SOPs](#19-related-sops)
20. [External & Reference Resources](#20-external--reference-resources)

---

## 1. Objectives & Scope

Cloud forensics extends classical DFIR (host imaging, memory analysis, disk artifact parsing — see [[sop-forensics-investigation|Digital Forensics Investigation]]) into the IaaS control plane, where the most material evidence is no longer on a disk but in API audit logs, IAM action histories, snapshots, and managed-service event streams. The deliverable is a defensible reconstruction of the incident across the cloud-provider control plane, IAM, network, storage, and compute layers, with chain-of-custody discipline equivalent to disk forensics.

This SOP focuses on **AWS, Azure, and GCP IaaS-plane forensics** because they together own the dominant share of enterprise cloud workloads. Smaller / regional providers (Alibaba Cloud, OVHcloud, Oracle Cloud, IBM Cloud) follow recognizably similar patterns but differ in API field names, retention defaults, and tenant boundaries; treat per-engagement vendor documentation as authoritative.

### What this SOP owns

- **IaaS control-plane log collection, integrity, and retention** — AWS CloudTrail (management + data + Insights events; CloudTrail Lake), Azure Activity Log + Resource Logs + Microsoft Sentinel, GCP Cloud Audit Logs (Admin Activity, Data Access, System Event, Policy Denied) and log sinks.
- **IAM forensics** — principal-action reconstruction, AWS STS `AssumeRole` chain reconstruction, Azure service-principal and managed-identity action graphs, GCP service-account impersonation chains, access-key / token abuse, Workload Identity Federation cross-cloud trust pivots.
- **Region-sweep methodology** — incident scope rarely matches the region the alert fired in; this SOP enumerates the sweep for each CSP.
- **Log-tampering detection** — CloudTrail digest validation (SHA-256 hash chain), CloudTrail Lake immutability posture, AWS Config history snapshot, Azure storage immutable blob + WORM, GCP log sinks + organization-level aggregated exports, deletion-event detection across providers.
- **Container-runtime forensics on managed Kubernetes** — EKS / AKS / GKE control-plane (apiserver) audit logs, ECR / GCR / ACR pull events, runtime detection feeds (Falco, GuardDuty Runtime Monitoring, Defender for Cloud Defender for Containers, Security Command Center / Container Threat Detection), node-level artifacts (containerd / CRI-O / Docker shim).
- **Evidence preservation for cloud volumes** — EBS snapshot for forensics with hash-chain integrity, Azure managed-disk snapshot, GCP persistent-disk snapshot, encrypted-snapshot handling, cross-account / cross-region snapshot copy for evidence isolation.
- **Cross-cloud correlation** — multi-cloud incidents are routine; this SOP enumerates the correlation surface (federated identity, cross-cloud egress, common attacker tooling).
- **Cloud-native IR tooling** — AWS Detective + Athena + Macie, Azure Sentinel + Defender for Cloud, GCP Chronicle + Security Command Center, plus open-source (Cartography, Steampipe, Cloud Custodian, CloudGrappler, Falco, Stratus Red Team for purple-team validation).

### Hard exclusions (out of scope)

- **SaaS-tenant identity / collaboration plane.** Microsoft 365 Unified Audit Log (UAL), Google Workspace Admin SDK / Reports API, Okta System Log, Slack Discovery / Audit Logs, Salesforce Setup Audit Trail, Box / Dropbox / Atlassian admin trails, and OAuth consent-grant abuse all live in the [[sop-saas-log-forensics|SaaS Log Forensics]] SOP. The line: if the artifact is about identity / collaboration / messaging at the application tenant level, route to [[sop-saas-log-forensics|SaaS Log Forensics]]. If it is about IaaS resources (compute, storage, network, IAM) at the cloud-provider tenant level, it belongs here. Hybrid cases (Entra ID sign-ins that triggered an Azure-resource-plane action) are bridged by §7 IAM Forensics.
- **Email header / SPF / DKIM / DMARC / wire-recall / BEC scenario reconstruction.** Routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. OAuth-consent BEC variants route to [[sop-saas-log-forensics|SaaS Log Forensics]]. Scope is a deliberate split: this SOP does not duplicate header-forensics tradecraft.
- **Offensive cloud testing.** Pre-engagement enumeration, IAM-privesc methodology, lateral movement, persistence, exfil tradecraft live in [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]]. Forensic readers benefit from understanding the offensive playbook (it is the threat model) but should not derive offensive instructions from this SOP.
- **General host / disk / memory forensics.** Image acquisition, memory acquisition (LiME / AVML / WinPmem), MFT / USN / Prefetch / Amcache / ShimCache parsing, Volatility 3 plugins, and timeline construction all live in [[sop-forensics-investigation|Digital Forensics Investigation]]. This SOP layers on top: a snapshot-derived volume is mounted and parsed using forensics-investigation methodology; the cloud-specific surface is the snapshot-creation, integrity, and chain-of-custody discipline, not the offline parsing.
- **Smart-contract / on-chain forensics.** Web3 / blockchain post-exploit fund tracing routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; mixer-defeat tradecraft routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]; smart-contract code review routes to [[sop-smart-contract-audit|Smart Contract Audit]]. Cloud-resident crypto-mining / wallet-stealer payloads are dual-routed: malware artifacts to [[sop-malware-analysis|Malware Analysis]], on-chain consequences to the investigations track.
- **Container / Kubernetes offensive testing.** Pod escapes, RBAC abuse, admission-controller bypass, runtime exploitation route to (planned) `sop-container-k8s-pentest` (referenced by [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]]). This SOP covers control-plane audit-log forensics and runtime-detection artifact collection only.

### Engagement types covered

- **Incident response retainer.** Customer reports unusual cloud activity; DFIR firm engages under retainer or hourly; this SOP defines the standard collection and analysis workflow.
- **Internal SOC investigation.** SOC analyst pivots from a SIEM alert into deep forensics on the affected cloud account.
- **Regulator-directed examination.** A regulator (financial, health, privacy) directs the tenant owner to produce evidence; the cloud-forensics output supports the regulator deliverable.
- **Law-enforcement collection.** LE investigation backed by warrant / MLAT / preservation letter; the cloud forensics output supports an evidentiary chain that may end up in court.
- **Post-incident retrospective.** Months after containment, a structured forensic reconstruction supports lessons-learned, board reporting, insurance claim, or customer-notification scoping.

---

## 2. Pre-Engagement & Authorization

### Authorization Checklist

- [ ] **Written engagement letter or internal incident-response activation** identifying the affected tenant(s) (AWS account ID, Azure tenant + subscription, GCP organization + project), the time window of interest, and the scope of authorized actions (read-only collection? authorized to disable principals? authorized to take snapshots? authorized to rotate keys?). Cloud-forensics actions can move state — a snapshot creation is a billable, durable side-effect — so written scope matters.
- [ ] **Tenant-administrator authorization** for read-only access to audit-log destinations, IAM, storage, compute, and managed-Kubernetes control planes. Use a dedicated investigator IAM role (AWS IAM Role / Azure custom role / GCP custom role) — not a re-used personal identity — and rotate it at engagement end.
- [ ] **Provider legal process where the customer cannot authorize collection on their own** — for cross-tenant evidence (tenant-A user is suspect, tenant-B is victim, both reside on the same provider) the provider's law-enforcement portal is the route. AWS, Microsoft, and Google publish LE request guidelines and require subpoena / warrant / MLAT depending on data type. [verify 2026-04-27]
- [ ] **Cross-border data residency review.** EU data subjects, healthcare records (HIPAA), card data (PCI), and government cloud (GovCloud / Azure Government / GCP Assured Workloads) all carry residency / sovereignty constraints. Verify under counsel before exporting log data to investigator-controlled storage outside the source region — see [[sop-legal-ethics|Legal & Ethics]].
- [ ] **Disclosure pathway agreed.** Who receives interim findings; who receives the final report; what gets published; whether regulators / customers / law enforcement get notified and on what timeline. Notification clocks are jurisdiction-specific (GDPR Art. 33: 72h to supervisory authority; SEC cyber-disclosure rule for material incidents; state breach-notification laws; sectoral rules for finance / health). Verify per-incident under counsel.
- [ ] **Counterparty awareness.** When the affected workload is multi-tenant or the customer shares infrastructure with downstream consumers, decide who learns of the engagement and when.
- [ ] **CSP support-case opened where useful.** Provider IR support (AWS Support, Azure Rapid Response, Google Cloud IR) can unlock collection paths (extended-retention CloudTrail Lake queries, Sentinel data retrieval, log-sink reconstruction) that customer-side tooling cannot. Open the support case under an executive sponsor's identity, not the investigator's, so the audit trail attributes the action correctly.

### Lab Environment Requirements

- **Dedicated investigator account / project / subscription** in each CSP, separate from the affected tenant. Snapshots, log exports, and analysis artifacts land here, never back into the affected tenant. AWS pattern: dedicated `forensics-<engagement-id>` account in the same Organization (or external if the affected Org is under suspicion); Azure pattern: dedicated subscription under a dedicated management group; GCP pattern: dedicated project under a dedicated folder.
- **Investigator workstation** isolated from production: disk-encrypted laptop or dedicated VM, no shared credential vault with other engagements, no auto-sync of artifacts to corporate storage, dedicated `aws/azure/gcloud` CLI profiles per engagement.
- **Encrypted-at-rest investigator storage.** All exported logs, snapshot copies, parsed artifacts, and notes encrypted with engagement-specific keys. Cross-region copy of the engagement bucket / storage account / Cloud Storage bucket for resilience.
- **Time-sync discipline.** All analysis systems running NTP / chrony to a known source; time-zone normalized to UTC end-to-end; investigator note timestamps use ISO 8601 / RFC 3339 with explicit `Z` suffix per [[../../Investigations/Techniques/sop-collection-log|Collection Log]].
- **Network-isolation discipline.** No direct outbound from the investigator workstation to the suspect tenant beyond the audited collection paths. If the adversary is plausibly observing the customer tenant, treat all collection paths as monitored and discipline what queries you run accordingly — see [[sop-opsec-plan|OPSEC]] for investigator-side hygiene.
- **CSP CLI versions pinned per engagement.** Record `aws --version`, `az version`, `gcloud version` at engagement start; CLI behavior changes between minor versions (default region, output format, default credential resolution order).
- **Read-only IAM by default.** Investigator role grants `*Read*` / `*List*` / `*Describe*` / `*Get*` / `*Lookup*` actions; any action that mutates state requires an explicit, documented authorization step. Use AWS IAM `aws-managed/SecurityAudit` or `ReadOnlyAccess`, Azure `Reader` + `Security Reader`, GCP `roles/iam.securityReviewer` + `roles/logging.viewer` as starting points, narrowed per engagement.

### Disclosure-Ready Posture

Cloud-forensics findings frequently land with regulators, insurers, customers, or law enforcement. Stage the deliverable shape early:

- **Chain-of-custody record** opened at engagement start — every collection step recorded per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]. Hash every exported log file (SHA-256 baseline) at the moment of export; record source-tenant resource IDs, source-API endpoint, time range of the export, executing principal, and destination URI.
- **Evidence-handling policy** decided before the first collection: retention period for engagement artifacts, encryption-at-rest standard, access list, deletion / handover discipline at engagement end.
- **Reporting timeline** agreed: interim notes (daily?), interim summary (weekly?), final report. Cloud incidents move fast; the regulator / customer / counsel may need an interim summary by day 3 even when the full forensic reconstruction will take weeks.
- **Disclosure pathway** for findings that touch third parties (a compromised customer's API key found in CloudTrail; a vendor-issued credential abused by the adversary; an upstream supply-chain compromise indicator). Coordinate with [[sop-legal-ethics|Legal & Ethics]] and [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]].

---

## 3. Cloud Forensics Landscape

Cloud forensics partitions into four planes. Each plane has distinct artifacts, retention defaults, and tampering surfaces. The planes are not strictly hierarchical — an attacker can pivot between them — but the artifact discipline differs.

### 3.1 Control Plane

API actions against the cloud provider — `RunInstances`, `CreateBucket`, `AssumeRole`, `Microsoft.Compute/virtualMachines/start/action`, `compute.instances.insert`. The control plane is the **highest-value forensic surface** because it captures both adversarial and routine action with full principal attribution, source IP, user agent, and request parameters.

| CSP | Primary control-plane log | Default retention | Long-term retention |
|---|---|---|---|
| AWS | CloudTrail management events | 90 days in Event history (free) | Trail to S3 (configurable, often years); CloudTrail Lake (default 7 years, max 10 years [verify 2026-04-27]) |
| Azure | Activity Log | 90 days in portal | Diagnostic settings export to Log Analytics workspace (configurable), Event Hubs, or Storage Account |
| GCP | Cloud Audit Logs — Admin Activity | 400 days, free, cannot be disabled | Log sinks to Cloud Storage / BigQuery / Pub/Sub for longer / different retention |

### 3.2 Data Plane

Resource-level access — S3 `GetObject`, Azure Blob `Get Blob`, GCS object reads, RDS / Azure SQL / Cloud SQL queries. Data-plane logging is **opt-in and expensive** in all three CSPs:

| CSP | Data-plane log | Default state | Notes |
|---|---|---|---|
| AWS | CloudTrail data events; S3 Server Access Logging; VPC Flow Logs | Off | Per-bucket / per-Lambda / per-DynamoDB-table opt-in; high volume |
| Azure | Resource Logs (per-service `Diagnostic Settings`) | Off | Each resource type publishes its own `category`; storage / SQL / Key Vault all separate |
| GCP | Cloud Audit Logs — Data Access | Off (except for some BigQuery defaults) | Per-service opt-in; can be filtered by principal to reduce volume |

If data-plane logging was off at the time of the incident, the data-access reconstruction is bounded by what control-plane evidence (e.g., temporary credentials minted, VPC traffic) can imply. Document this gap explicitly in the report — it is frequently the largest evidentiary limitation in cloud cases.

### 3.3 Identity Plane

Authentication, authorization, and federation events. Where a user signed in from, what MFA assertion was used, what role was assumed, and what cross-tenant trust was traversed.

| CSP | Identity log | Notes |
|---|---|---|
| AWS | CloudTrail (sign-in via STS / IAM Identity Center / federated SAML); IAM Identity Center logs | STS `AssumeRole`, `AssumeRoleWithSAML`, `AssumeRoleWithWebIdentity` are the assume-role-chain anchor events |
| Azure | Microsoft Entra ID sign-in logs; Entra ID audit logs | Sign-in logs cover interactive + non-interactive + service principals; audit logs cover directory changes |
| GCP | Cloud Identity / Workspace login audit (separate from Cloud Audit Logs); IAM `setIamPolicy` events | Federated identity (Workforce Identity / Workload Identity Federation) issues short-lived tokens visible at consumption |

Identity-plane events frequently sit in a different log destination than control-plane events — Entra ID sign-in logs are not the same store as Activity Log; Workspace login audit is not the same as Cloud Audit Logs. Both must be collected.

### 3.4 Runtime Plane

Process / network / file-system events inside running compute (EC2, VMs, GCE, container pods, Lambda, Functions, Cloud Run). Runtime visibility depends on what the customer deployed:

- **Agentless host telemetry** — CSP runtime detection (GuardDuty Runtime Monitoring, Defender for Cloud Defender for Servers / Defender for Containers, Security Command Center Container Threat Detection / VM Threat Detection), Wiz / Lacework / Orca / Sysdig SaaS — varies per customer.
- **Agent-based EDR** — CrowdStrike Falcon, SentinelOne, Microsoft Defender for Endpoint, Carbon Black, Elastic Defend.
- **Open-source** — Falco for container / Linux runtime; auditd for Linux syscall; Sysmon for Windows.
- **Provider-native logs** — VPC Flow Logs (AWS), NSG Flow Logs (Azure), VPC Flow Logs (GCP), all at the network edge; serverless-runtime logs (Lambda CloudWatch Logs, Functions Application Insights, Cloud Run / Cloud Functions Cloud Logging).

The runtime plane is where classic host / disk / memory forensics applies (see [[sop-forensics-investigation|Digital Forensics Investigation]]); cloud-specific tradecraft is the snapshot-acquisition path (§11).

### 3.5 Per-CSP Terminology Crosswalk

Cross-cloud incidents demand a shared vocabulary. The same concept gets different names per CSP:

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Tenant boundary | Account | Tenant + Subscription | Organization + Project |
| Identity directory | IAM + IAM Identity Center | Microsoft Entra ID | Cloud Identity |
| Resource-action audit | CloudTrail | Activity Log + Resource Logs | Cloud Audit Logs |
| Sign-in audit | CloudTrail (AssumeRole*) | Entra ID sign-in logs | Cloud Identity login audit |
| SIEM / analytics | Security Lake + Athena + Detective | Microsoft Sentinel | Chronicle / Security Command Center |
| Threat detection | GuardDuty | Defender for Cloud | Security Command Center (Premium / Enterprise) |
| Asset inventory | AWS Config + Resource Explorer | Azure Resource Graph | Cloud Asset Inventory |
| Identity federation | IAM Identity Center / OIDC / SAML | Entra ID External Identities; Workload Identity Federation | Workforce Identity / Workload Identity Federation |

---

## 4. AWS — IaaS-Plane Forensics

### 4.1 CloudTrail Collection

CloudTrail is the canonical AWS audit trail. It records management events (control-plane API calls), data events (resource-level access — opt-in), and Insights events (anomalous-rate detection — opt-in).

```bash
# Confirm trails configured and where they write
aws cloudtrail describe-trails --include-shadow-trails
aws cloudtrail get-trail-status --name <trail-name>
aws cloudtrail get-event-selectors --trail-name <trail-name>      # which data events are captured
aws cloudtrail list-channels                                       # CloudTrail Lake event-data-store channels

# Lookup recent management events via the API (90-day window)
aws cloudtrail lookup-events \
    --start-time 2026-04-01T00:00:00Z --end-time 2026-04-27T00:00:00Z \
    --lookup-attributes AttributeKey=Username,AttributeValue=<suspect-iam-user>

# Lookup by event name (action-driven hunting)
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole

# Pull underlying CloudTrail logs from S3 (gzipped JSON, ~5-min batches per region per account)
aws s3 sync \
    s3://<cloudtrail-bucket>/AWSLogs/<account-id>/CloudTrail/ /evidence/cloudtrail/ \
    --exclude "*" --include "*/2026/04/*"

# Extract a single event for inspection
gunzip -c /evidence/cloudtrail/.../some-event.json.gz | jq .

# Hash the export at acquisition (chain-of-custody)
find /evidence/cloudtrail -type f -name '*.json.gz' \
    | xargs -I{} sha256sum {} > /evidence/cloudtrail.sha256
```

### 4.2 CloudTrail Lake (Recommended for Multi-Year Forensics)

CloudTrail Lake is AWS's first-party event-data-store with SQL-queryable storage and configurable retention up to 10 years (Insights retention to 7) [verify 2026-04-27]. It removes the Athena / S3 / Glue plumbing the legacy pattern required.

```bash
# List event data stores
aws cloudtrail list-event-data-stores

# Run a SQL query against Lake (CloudTrail Lake's SQL is a subset of standard SQL)
aws cloudtrail start-query --query-statement \
    "SELECT eventTime, userIdentity.arn, eventName, sourceIPAddress, requestParameters
     FROM <eds-id>
     WHERE eventTime > '2026-04-01 00:00:00.000'
       AND userIdentity.arn LIKE '%<suspect-principal>%'
     ORDER BY eventTime"

# Retrieve results
aws cloudtrail get-query-results --query-id <query-id>
```

### 4.3 Athena Pattern (Legacy / Self-Hosted)

For trails written to S3 without Lake, Athena over partitioned CloudTrail logs remains the standard query path. The CloudFormation / Terraform pattern most teams use creates a partition projection so Athena does not require an external `MSCK REPAIR`.

```sql
-- Create external table (CloudFormation-equivalent DDL; abbreviated)
CREATE EXTERNAL TABLE cloudtrail_logs (
    eventVersion STRING,
    userIdentity STRUCT<...>,
    eventTime STRING,
    eventSource STRING,
    eventName STRING,
    awsRegion STRING,
    sourceIPAddress STRING,
    userAgent STRING,
    errorCode STRING,
    errorMessage STRING,
    requestParameters STRING,
    responseElements STRING,
    additionalEventData STRING,
    requestID STRING,
    eventID STRING,
    resources ARRAY<STRUCT<...>>,
    eventType STRING,
    apiVersion STRING,
    readOnly STRING,
    recipientAccountId STRING,
    serviceEventDetails STRING,
    sharedEventID STRING,
    vpcEndpointId STRING
)
ROW FORMAT SERDE 'com.amazon.emr.hive.serde.CloudTrailSerde'
LOCATION 's3://<cloudtrail-bucket>/AWSLogs/<account-id>/CloudTrail/';

-- Hunt for unusual ConsoleLogin events
SELECT eventTime, userIdentity.arn, sourceIPAddress, additionalEventData
FROM cloudtrail_logs
WHERE eventName = 'ConsoleLogin'
  AND eventTime BETWEEN '2026-04-01' AND '2026-04-27'
  AND additionalEventData LIKE '%MFAUsed%false%';

-- Hunt for IAM permission changes
SELECT eventTime, userIdentity.arn, eventName, requestParameters
FROM cloudtrail_logs
WHERE eventName IN (
    'CreateAccessKey', 'CreateUser', 'AttachUserPolicy', 'AttachRolePolicy',
    'PutUserPolicy', 'PutRolePolicy', 'CreatePolicyVersion',
    'CreateLoginProfile', 'UpdateAssumeRolePolicy'
);
```

### 4.4 GuardDuty + Security Lake

GuardDuty produces threat findings derived from CloudTrail, VPC Flow Logs, DNS query logs, EKS audit logs, S3 data events, RDS login events, EBS malware scans, Runtime Monitoring (EKS / ECS / EC2 / Fargate) [verify 2026-04-27]. Findings are themselves forensic artifacts.

```bash
# Pull all GuardDuty findings in the time window
aws guardduty list-detectors
aws guardduty list-findings --detector-id <id> \
    --finding-criteria '{"Criterion": {"updatedAt": {"GreaterThanOrEqual": 1711929600000}}}'
aws guardduty get-findings --detector-id <id> --finding-ids <id-list>
```

AWS Security Lake [verify 2026-04-27] consolidates multi-source security data (CloudTrail, VPC Flow, Route 53, GuardDuty, custom sources) in OCSF format on S3, queryable from Athena, OpenSearch, and partner SIEMs. For forensics, Security Lake's value is the **normalized schema** (OCSF) which makes cross-source queries simpler than per-source SerDes.

### 4.5 VPC Flow Logs (Network-Plane Evidence)

VPC Flow Logs capture IP-level connection metadata (5-tuple, accept / reject, packet / byte count). They sit in S3 or CloudWatch Logs.

```bash
# Confirm flow logs are configured per VPC / subnet / ENI
aws ec2 describe-flow-logs

# Sync to investigator S3 (or directly to Athena over S3)
aws s3 sync s3://<flow-logs-bucket>/AWSLogs/<acct>/vpcflowlogs/<region>/2026/04/ \
    /evidence/vpc-flow-logs/

# Athena query (assumes external table created over flow logs)
SELECT *
FROM vpc_flow_logs
WHERE srcaddr = '<suspect-ip>' OR dstaddr = '<suspect-ip>'
  AND start >= 1711929600  -- epoch
ORDER BY start;
```

### 4.6 S3 Server Access Logging

S3 Server Access Logs record per-object access (HTTP method, requester, request URI, response code, bytes, referer, user agent). They are separate from CloudTrail data events and live in a customer-owned target bucket.

```bash
# Confirm logging configured for a specific bucket
aws s3api get-bucket-logging --bucket <suspect-bucket>

# Sync the access log objects
aws s3 sync s3://<log-target-bucket>/<log-prefix>/ /evidence/s3-access-logs/
```

### 4.7 IAM Access Analyzer + Config

`AWS Config` captures resource-state history (every change recorded as a configuration item). IAM Access Analyzer surfaces over-permissioned roles and external-trust relationships. Both are forensic adjuncts:

```bash
# Pull Config history for a specific resource
aws configservice get-resource-config-history \
    --resource-type AWS::IAM::Role --resource-id <role-id> \
    --earlier-time 2026-04-01T00:00:00Z

# Access Analyzer findings (current state, not historical)
aws accessanalyzer list-analyzers
aws accessanalyzer list-findings --analyzer-arn <arn>
```

### 4.8 Macie (Data Classification)

Macie scans S3 buckets for sensitive data (PII, credentials, financial records). For a data-exfil investigation, Macie's prior scan results indicate which buckets held high-value data — even if the exfil itself was not logged.

```bash
aws macie2 list-findings
aws macie2 get-findings --finding-ids <id-list>
```

---

## 5. Azure — IaaS-Plane Forensics

### 5.1 Activity Log (Subscription Control Plane)

Activity Log records subscription-scoped management operations, service-health events, alerts, autoscale, recommendations, and policy events. Default retention is 90 days; durable retention requires diagnostic settings export.

```bash
# Recent subscription-scope operations
az monitor activity-log list \
    --start-time 2026-04-01T00:00:00Z --end-time 2026-04-27T00:00:00Z \
    --max-events 1000 --output json > activity-log.json

# Filter by caller / resource group
az monitor activity-log list --caller <upn-or-spn-id> --offset 30d
az monitor activity-log list --resource-group <rg-name> --offset 30d

# Export to Log Analytics workspace for KQL queries (durable retention)
az monitor diagnostic-settings list --resource <subscription-resource-id>
```

### 5.2 Microsoft Entra ID (Identity Plane)

Entra ID sign-in and audit logs are the canonical source for identity-compromise reconstruction. They are **separate** from Activity Log — both must be collected.

```bash
# Sign-in logs (interactive + non-interactive + service-principal + managed-identity)
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/auditLogs/signIns?\$filter=createdDateTime ge 2026-04-01T00:00:00Z&\$top=999"

# Service-principal sign-ins specifically (often where compromise hides)
az rest --method GET \
    --uri "https://graph.microsoft.com/beta/auditLogs/signIns?\$filter=signInEventTypes/any(t:t eq 'servicePrincipal')&\$top=999"

# Directory audit logs (role assignments, app registrations, conditional-access changes)
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?\$filter=activityDateTime ge 2026-04-01T00:00:00Z"

# OAuth consent grants (high-signal for OAuth-abuse BEC and adversary persistence)
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants"
```

> **SaaS hand-off note.** OAuth consent abuse, mailbox-rule creation, M365 UAL, and app-token issuance routes to [[sop-saas-log-forensics|SaaS Log Forensics]]. Entra ID sign-in / audit logs are dual-routed: identity events that triggered Azure-resource-plane actions (e.g., a compromised service principal that ran VMs) belong here in §5; identity events that triggered Microsoft 365 application-tier actions (mailbox access, SharePoint reads, Teams DM exfil) belong to [[sop-saas-log-forensics|SaaS Log Forensics]]. The boundary is the resource the action targeted, not the identity itself.

### 5.3 Resource Logs (Per-Service Diagnostic Logs)

Each Azure service emits its own Resource Logs categories — Storage Account `StorageRead` / `StorageWrite` / `StorageDelete`; Key Vault `AuditEvent`; SQL Database `SQLSecurityAuditEvents`; Network Security Group `NetworkSecurityGroupFlowEvent`; etc. They route to a Log Analytics workspace, an Event Hub (for SIEM), or a Storage Account (cheapest long-term).

```bash
# List diagnostic settings for a specific resource
az monitor diagnostic-settings list --resource <resource-id>

# Query Log Analytics workspace via KQL
az monitor log-analytics query \
    --workspace <workspace-id> \
    --analytics-query 'AzureActivity
        | where TimeGenerated >= ago(7d)
        | where Caller == "<suspect-upn>"
        | project TimeGenerated, OperationNameValue, ResourceGroup, ActivityStatusValue'
```

### 5.4 Microsoft Sentinel (Cloud-Native SIEM)

Sentinel sits on top of a Log Analytics workspace and provides KQL hunting, analytic rules, incidents, hunting queries, watchlists, and notebooks. For cloud forensics, Sentinel is where the **cross-source query** lives:

```kusto
// KQL — multi-source identity-pivot query
union
    SigninLogs, AuditLogs, AzureActivity, OfficeActivity
| where TimeGenerated between (datetime(2026-04-01) .. datetime(2026-04-27))
| where UserPrincipalName == "<suspect-upn>" or Caller == "<suspect-upn>"
| project TimeGenerated, Type, OperationName, IPAddress, ResultDescription
| order by TimeGenerated asc

// KQL — service-principal anomalous activity (newly granted scope, unusual IP)
SigninLogs
| where TimeGenerated > ago(7d)
| where ServicePrincipalName != ""
| summarize count() by ServicePrincipalName, IPAddress, Location
| where count_ > 0
| order by count_ desc
```

### 5.5 Defender for Cloud + Defender XDR

Defender for Cloud is Azure's CSPM / CWPP / runtime-detection product (formerly Azure Security Center, Azure Defender). Findings (Microsoft.Security `SecurityAlerts`) are forensic artifacts.

```bash
# List recent security alerts
az security alert list --output json
```

Defender XDR (the Microsoft 365 + Azure unified XDR pane) is the umbrella over Defender for Endpoint / Identity / Cloud / Office. Cross-product correlation lives there; KQL via the advanced-hunting endpoint.

### 5.6 Storage Immutability for Tamper Resistance

Azure Storage supports **immutable blob storage** (legal hold / time-based retention via Azure Storage WORM) — once configured, blobs cannot be deleted or overwritten until the policy expires [verify 2026-04-27]. For evidence buckets, this is the per-blob deletion-resistance equivalent of S3 Object Lock.

```bash
az storage container immutability-policy create \
    --account-name <evidence-account> --container-name evidence \
    --period 365 --resource-group <rg>
```

### 5.7 NSG Flow Logs (Network-Plane Evidence)

NSG Flow Logs capture L4 metadata at the Network Security Group level. They land in a Storage Account and are queryable via Traffic Analytics (Log Analytics workspace).

```bash
az network watcher flow-log list --location <region>
```

---

## 6. GCP — IaaS-Plane Forensics

### 6.1 Cloud Audit Logs

GCP Cloud Audit Logs split into four streams:

| Stream | Default state | Notes |
|---|---|---|
| **Admin Activity** | Always-on, free, 400-day retention, cannot be disabled | Project / org IAM, resource creation / modification / deletion |
| **Data Access** | Off by default (except some BigQuery defaults), billable, 30-day default retention | Per-API opt-in via `setIamPolicy` audit config |
| **System Event** | Always-on, free, 400-day retention | GCP-initiated events (e.g., live migration) |
| **Policy Denied** | Always-on, free, 30-day retention | Org policy / VPC service-controls denials |

```bash
# IAM-related Admin Activity events
gcloud logging read \
    'protoPayload.serviceName="iam.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json > gcp-iam-audit.json

# Sign-in events (Workspace customers, cross-checked with Cloud Identity)
gcloud logging read \
    'protoPayload.serviceName="login.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"' \
    --organization=<org-id> --format=json

# Service-account impersonation events (canonical privilege-escalation primitive)
gcloud logging read \
    'protoPayload.methodName=~"GenerateAccessToken|GenerateIdToken|SignBlob|SignJwt"' \
    --project=<project> --format=json
```

### 6.2 Log Sinks (Tamper-Resistant Long-Term Retention)

A **log sink** routes log entries to Cloud Storage, BigQuery, or Pub/Sub. Sinks at the **organization level** capture all child projects — investigators should configure or audit the org-level sink as a forensic anchor.

```bash
# List sinks at org level
gcloud logging sinks list --organization=<org-id>

# Aggregated org-level sink to a forensics bucket (audit existence; do not change without authorization)
gcloud logging sinks describe <sink-name> --organization=<org-id>
```

The forensic value of an org-aggregated sink: even if an attacker disables Data Access logs in a single project, the org sink continues to capture Admin Activity, and the act of disabling Data Access logs is itself an Admin Activity event.

### 6.3 BigQuery Pattern (Recommended for Long-Term Forensics)

```sql
-- BigQuery query against audit-log dataset (assumes sink to BigQuery configured)
SELECT
  timestamp,
  protopayload_auditlog.authenticationInfo.principalEmail AS principal,
  protopayload_auditlog.methodName AS method,
  protopayload_auditlog.resourceName AS resource,
  protopayload_auditlog.requestMetadata.callerIp AS caller_ip
FROM
  `<project>.audit_log_dataset.cloudaudit_googleapis_com_activity_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20260401' AND '20260427'
  AND protopayload_auditlog.authenticationInfo.principalEmail = '<suspect-principal>'
ORDER BY
  timestamp;
```

### 6.4 Chronicle (Google's Cloud-Native SIEM)

Chronicle (Google Security Operations) [verify 2026-04-27] ingests Cloud Audit Logs, Workspace, third-party sources, and threat intelligence. It is sold to enterprise customers separately from GCP and is the canonical IR query surface for organizations that have it.

```bash
# YARA-L 2.0 detection rules (Chronicle) -- example shape
rule suspicious_iam_role_modification {
  meta:
    severity = "HIGH"
  events:
    $e.metadata.event_type = "USER_RESOURCE_UPDATE_PERMISSIONS"
    $e.principal.user.email_addresses != ""
  condition:
    $e
}
```

### 6.5 Security Command Center

Security Command Center (SCC) is GCP's CSPM / threat-detection pane. Premium / Enterprise tiers include Container Threat Detection, Event Threat Detection, VM Threat Detection, Web Security Scanner [verify 2026-04-27].

```bash
gcloud scc findings list --organization=<org-id> \
    --filter='state="ACTIVE" AND severity="HIGH"' \
    --format=json
```

### 6.6 VPC Flow Logs

```bash
# Confirm flow logs enabled per subnet
gcloud compute networks subnets describe <subnet-name> --region=<region>

# Query flow logs from log sink
gcloud logging read 'logName="projects/<project>/logs/compute.googleapis.com%2Fvpc_flows"' \
    --project=<project> --format=json
```

### 6.7 Cloud Asset Inventory

Cloud Asset Inventory tracks resource state across projects with a 35-day history (longer with feed export to Pub/Sub or BigQuery). Useful for detecting "this resource existed at time T but not at time T+1" without re-running enumeration.

```bash
gcloud asset search-all-resources --scope=organizations/<org-id>
gcloud asset get-history --asset-names=<asset> \
    --start-time=2026-04-01T00:00:00Z --end-time=2026-04-27T00:00:00Z
```

---

## 7. IAM Forensics: Principal-Action Reconstruction

The most common cloud-incident question is: **what did this principal do, where did the principal originate, and what did the principal pivot to?** IAM forensics answers all three.

### 7.1 AWS — `AssumeRole` Chain Reconstruction

AWS's STS `AssumeRole` is the canonical privilege-pivot primitive. Reconstructing the chain requires walking events backward from each session credential to the originating identity.

```sql
-- Athena / CloudTrail Lake -- find the originating identity for a session ARN
-- Step 1: from the action-of-interest event, capture the session ARN
SELECT eventTime, userIdentity.arn, userIdentity.sessionContext, eventName
FROM cloudtrail_logs
WHERE eventID = '<action-event-id>';
-- userIdentity.arn looks like: arn:aws:sts::<acct>:assumed-role/<role-name>/<session-name>
-- userIdentity.sessionContext.sessionIssuer.arn names the role

-- Step 2: find the AssumeRole event that minted that session
SELECT eventTime, userIdentity.arn, userIdentity.principalId,
       requestParameters, responseElements, sourceIPAddress
FROM cloudtrail_logs
WHERE eventName = 'AssumeRole'
  AND responseElements LIKE '%<session-name>%'
  AND eventTime > '<some-prior-window>';

-- Step 3: walk back recursively until userIdentity.type IN ('IAMUser', 'Root', 'SAMLUser', 'WebIdentityUser')
```

`AssumeRoleWithSAML` and `AssumeRoleWithWebIdentity` events anchor federated identity to the originating IdP — the SAML attribute / OIDC claim is in `requestParameters` and connects the AWS session to the upstream identity provider's audit trail (often Microsoft Entra ID, Okta, or Google Workspace).

### 7.2 AWS — Access-Key Abuse Indicators

Long-lived IAM access keys are a primary attack surface. Forensic indicators of abuse:

- **`UpdateAccessKey` to `Active`** when the key was previously inactive, or **`CreateAccessKey`** for a user that already has one.
- **`GetCallerIdentity` from a new IP / ASN / country** for an existing access key.
- **`AssumeRole` from an access key** that historically only made S3 / SES / specific-service calls.
- **`DeleteAccessKey` shortly after the suspect window** (cleanup).
- **Concurrent use** of the same access key from geographically incompatible source IPs within a short window.

### 7.3 Azure — Service-Principal and Managed-Identity Forensics

Azure's privilege-pivot primitives are service principals (with client secrets, certificates, or federated credentials) and managed identities (system-assigned or user-assigned). Forensic queries:

```kusto
// Service-principal sign-in spikes
AADServicePrincipalSignInLogs
| where TimeGenerated > ago(30d)
| summarize count() by ServicePrincipalName, IPAddress
| where count_ > 100

// New federated credential added to a service principal (often persistence)
AuditLogs
| where OperationName == "Update application – Certificates and secrets management"
| extend AppId = tostring(TargetResources[0].id)
| project TimeGenerated, InitiatedBy, AppId, AdditionalDetails

// Managed-identity token requests (high-volume from a single resource is unusual)
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.MANAGEDIDENTITY"
| summarize count() by Resource, ClientIP
```

### 7.4 GCP — Service-Account Impersonation Chains

GCP's privilege-pivot is the `iam.serviceAccountTokenCreator` role, which lets one principal mint short-lived tokens for another service account. Reconstruct the impersonation chain via `protoPayload.methodName` events.

```bash
# Find all impersonation events in window
gcloud logging read \
    'protoPayload.methodName="GenerateAccessToken" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json | \
    jq '.[] | {time:.timestamp,
               minter:.protoPayload.authenticationInfo.principalEmail,
               minted:.protoPayload.request.name,
               caller_ip:.protoPayload.requestMetadata.callerIp}'
```

Cross-walk the `minter → minted` graph; recursive impersonation chains are an attacker's fingerprint.

### 7.5 Cross-Cloud — Workload Identity Federation

Workload Identity Federation (WIF) lets a workload in one cloud (or in GitHub Actions, GitLab CI, on-prem K8s) assume an identity in another cloud without a stored secret. AWS supports OIDC and SAML federation; Azure supports federated credentials on app registrations; GCP supports Workload Identity Federation via OIDC.

For forensics, WIF events are **dual-cloud** — the originating workload's audit trail in cloud A pairs with the target cloud B's `AssumeRoleWithWebIdentity` / Entra federated-credential token / `GenerateAccessToken` event. Both must be collected.

```bash
# AWS side -- WIF assumptions
SELECT eventTime, userIdentity.arn, requestParameters.tokenType, sourceIPAddress
FROM cloudtrail_logs
WHERE eventName = 'AssumeRoleWithWebIdentity'
  AND eventTime > '2026-04-01';

# GitHub Actions side (where the WIF originated) -- pair via the OIDC `jti` / `sub` claim recorded in CloudTrail requestParameters
```

### 7.6 IAM Forensic Checklist

- [ ] List all access keys created in the engagement window (per-CSP API).
- [ ] List all role / service-principal / service-account creations and modifications.
- [ ] List all federated-credential additions to existing apps / SPs.
- [ ] Reconstruct every `AssumeRole*` / token-creator chain initiated from suspect principals.
- [ ] Identify all cross-account / cross-tenant trust relationships modified in window.
- [ ] Enumerate persistence primitives — newly created users, newly attached policies, new login profiles, cross-account roles with `*` trust.
- [ ] Cross-walk identity events to source IPs and ASNs; flag any that are Tor exit nodes, residential proxies, or VPS providers (CSP IP, AS attribution required at engagement-time).

---

## 8. Region-Sweep Methodology

> **Core rule.** The region the alert fired in is rarely the only region affected. Cloud attackers routinely operate across regions to evade region-scoped detection rules and to land resources in regions the customer does not actively monitor.

### 8.1 AWS Region Sweep

```bash
# Enumerate all enabled regions (the customer may have opted into non-default regions)
aws account list-regions --region-opt-status-contains ENABLED ENABLED_BY_DEFAULT

# Per-region pass: lookup events
for r in $(aws account list-regions --region-opt-status-contains ENABLED ENABLED_BY_DEFAULT --output text --query 'Regions[].RegionName'); do
    echo "=== Region: $r ==="
    aws cloudtrail lookup-events --region $r --max-results 100 \
        --start-time 2026-04-01T00:00:00Z \
        --lookup-attributes AttributeKey=Username,AttributeValue=<suspect-iam-user>
done

# Per-region resource enumeration via Resource Explorer (if customer has it configured)
aws resource-explorer-2 list-views

# Multi-region trail confirmation -- a single trail with `IsMultiRegionTrail=true` captures all regions
aws cloudtrail describe-trails --query 'trailList[?IsMultiRegionTrail==`true`]'
```

CloudTrail's Event history (the 90-day free lookup) is **per-region**; if the trail is not multi-region, only the trail-defined region's events land in S3. For a non-multi-region trail customer, the region sweep is the only way to see the full picture.

### 8.2 Azure Region Sweep

```bash
# Activity Log is subscription-scoped, not region-scoped — single query covers all regions in subscription
# Resource Logs via diagnostic settings are per-resource; the region matters only at the resource level

# Enumerate all locations with deployed resources
az resource list --query '[].location' --output tsv | sort -u

# KQL — surface activity per location
AzureActivity
| where TimeGenerated > ago(30d)
| extend Location = tostring(parse_json(Properties).resource[0].location)
| summarize count() by Location, OperationNameValue
```

### 8.3 GCP Region Sweep

```bash
# Cloud Audit Logs are global (or org-aggregated) -- single sink covers all regions
# Per-resource logs land in the resource's region

# Enumerate all regions with deployed compute
gcloud compute instances list --format='value(zone)' | sort -u

# Asset inventory for global view
gcloud asset list --scope=projects/<project> --asset-types=compute.googleapis.com/Instance
```

### 8.4 Region-Sweep Forensic Indicators

- **Resources in regions the customer did not historically use.** Often crypto-mining (cheap-region preference) or data staging (regulated-data egress).
- **Identity events from regions that do not match the customer's user base.** A US-only customer with sign-ins from `eu-north-1` and `ap-southeast-3` warrants attention.
- **VPC peering / cross-region replication newly configured.** Adversary cross-region staging.
- **Snapshot copy events to non-customary regions.** Exfiltration via cross-region snapshot.

---

## 9. Log-Tampering Detection

Adversaries with sufficient privilege can disable logs, redirect them, delete archived copies, or spoof events by manipulating principals. Log-tampering detection is the meta-forensic problem.

### 9.1 AWS — CloudTrail Digest Validation

CloudTrail trails optionally produce **digest files** — SHA-256 hash chains over each hour's log files, signed by AWS-managed KMS. Validation is built into the CLI:

```bash
# Validate a trail's digest chain over a window
aws cloudtrail validate-logs \
    --trail-arn arn:aws:cloudtrail:us-east-1:<acct>:trail/<trail-name> \
    --start-time 2026-04-01T00:00:00Z --end-time 2026-04-27T00:00:00Z

# Output: every log file's hash matched the digest, or named files where the chain broke
```

A broken chain indicates either log deletion, log modification, or digest deletion. The digest files themselves should be in a separate, locked-down bucket (S3 Object Lock recommended).

### 9.2 AWS — CloudTrail Lake Immutability

CloudTrail Lake event-data-stores are append-only by design — events cannot be edited or deleted within retention [verify 2026-04-27]. The retention period itself can be reduced (which deletes events outside the new retention) — the act of reducing retention is itself a CloudTrail event.

```sql
-- Detect Lake retention reduction
SELECT eventTime, userIdentity.arn, requestParameters.retentionPeriod
FROM <lake-event-data-store>
WHERE eventName = 'UpdateEventDataStore';

-- Detect trail / Lake deletion or stop attempts
SELECT eventTime, userIdentity.arn, eventName
FROM <lake-event-data-store>
WHERE eventName IN ('DeleteTrail', 'StopLogging', 'DeleteEventDataStore', 'PutEventSelectors');
```

### 9.3 AWS — S3 Object Lock for Evidence Buckets

Object Lock in **Compliance mode** prevents deletion (even by root) for the retention period [verify 2026-04-27]; Governance mode requires `s3:BypassGovernanceRetention` permission for deletion. For evidence and CloudTrail digest buckets, Compliance mode is the right default.

```bash
aws s3api put-object-lock-configuration --bucket <evidence-bucket> \
    --object-lock-configuration '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Days":365}}}'
```

### 9.4 Azure — Immutable Storage and Diagnostic Setting Changes

Azure's tamper-resistance posture rests on:

- **Immutable Storage policies** on the destination Storage Account containing exported Activity / Resource Logs.
- **Azure Policy** denying `Microsoft.Insights/diagnosticSettings/delete` and `Microsoft.Insights/diagnosticSettings/write` outside an allowed change-management process.
- **Microsoft Sentinel analytic rules** alerting on `AuditLogs` events with `OperationName == "Disable diagnostic setting"` or similar.

```kusto
// Detect diagnostic-setting disable / delete operations
AzureActivity
| where OperationNameValue has "Microsoft.Insights/diagnosticSettings"
| where ActivityStatusValue in ("Started", "Succeeded")
| project TimeGenerated, OperationNameValue, Caller, ResourceGroup, _ResourceId

// Detect Log Analytics workspace deletion
AzureActivity
| where OperationNameValue == "Microsoft.OperationalInsights/workspaces/delete"
```

### 9.5 GCP — Log Sink Changes and Org-Level Aggregation

GCP's tamper-resistance posture rests on:

- **Org-level aggregated log sink** — even if a project's sinks are tampered, the org sink continues capturing.
- **Cloud Storage bucket retention policies** on the sink destination (set retention with `gsutil retention set 7y gs://<sink-bucket>`) prevent log deletion within the retention window.
- **Bucket-level uniform access** + **Bucket Lock** make the retention policy irrevocable.

```bash
# Detect sink modifications
gcloud logging read \
    'protoPayload.methodName=~"google.logging.v2.ConfigServiceV2.(Delete|Update)Sink"' \
    --organization=<org-id> --format=json

# Confirm bucket lock on the sink destination
gsutil retention get gs://<sink-bucket>
gsutil retention lock gs://<sink-bucket>     # irrevocable
```

### 9.6 Cross-CSP Tamper-Indicators (Hunting Patterns)

| Indicator | AWS event(s) | Azure event(s) | GCP event(s) |
|---|---|---|---|
| Audit logging stopped | `StopLogging`, `DeleteTrail` | `Microsoft.Insights/diagnosticSettings/delete` | `google.logging.v2.ConfigServiceV2.DeleteSink` |
| Retention reduced | `UpdateEventDataStore` (CloudTrail Lake), bucket lifecycle change | Workspace `retentionInDays` decrease | Sink filter narrowed; bucket retention reduced |
| Encryption-key disabled (logs unreadable) | KMS `DisableKey` on log-encryption KMS key | Key Vault `Disable` on workspace key | Cloud KMS `DisableCryptoKeyVersion` on log-bucket key |
| Notifications muted | `EventBridge` rule disabled / SNS subscription deleted | Action group disabled / Sentinel analytic rule disabled | Pub/Sub subscription deleted; Cloud Monitoring alert policy disabled |
| Forwarding redirected | `PutEventSelectors` reducing scope; Lambda destination changed | Diagnostic setting target re-pointed | Sink destination changed |

---

## 10. Container & Kubernetes Runtime Artifacts

Managed Kubernetes (EKS / AKS / GKE) splits forensic surfaces between the **cloud-provider control plane** (where managed-Kubernetes audit logs live) and the **node / pod runtime** (where classic host forensics applies, see [[sop-forensics-investigation|Digital Forensics Investigation]]). This SOP owns the cloud-side; pod-internal exploitation methodology lives in (planned) `sop-container-k8s-pentest`.

### 10.1 Kubernetes Audit Logs (apiserver)

apiserver audit events capture every Kubernetes API request — pod creation, secret access, service-account token issuance, RBAC changes, exec into pods. They are the highest-value k8s-forensic artifact.

```bash
# AWS EKS -- audit logs go to CloudWatch Logs
aws eks describe-cluster --name <cluster-name> --query 'cluster.logging'
aws logs filter-log-events --log-group-name /aws/eks/<cluster>/cluster \
    --start-time <epoch-ms> --filter-pattern '"audit"'

# Azure AKS -- audit logs go to Log Analytics workspace via diagnostic settings
# AzureDiagnostics | where Category == "kube-audit" | ...

# GCP GKE -- audit logs go to Cloud Logging under cluster's project
gcloud logging read \
    'resource.type="k8s_cluster" AND protoPayload.methodName=~"k8s.io/apps/v1.deployments.(create|update|delete)"' \
    --project=<project> --format=json
```

### 10.2 High-Value Audit Events

- **`pods/exec` and `pods/attach`** — interactive shell into a running pod. Almost always significant in incident response.
- **`secrets/get` and `serviceaccounts/token`** — credential harvest.
- **`rolebindings.create` / `clusterrolebindings.create`** — privilege grants.
- **`pods.create` with `hostNetwork: true`, `hostPID: true`, `privileged: true`, or `volumes.hostPath` mount of `/`** — host-escape primitives.
- **`networkpolicies.delete`** — east-west isolation removal.
- **`mutatingwebhookconfigurations.create`** — admission-controller injection (persistence + tampering).

### 10.3 Container Image Pull Events

Image pulls are recorded per-CSP at the registry layer:

```bash
# AWS ECR
aws cloudtrail lookup-events --lookup-attributes \
    AttributeKey=EventSource,AttributeValue=ecr.amazonaws.com

# Azure ACR -- ACRPull event in resource logs
az monitor activity-log list --resource-group <rg> --offset 30d \
    --query "[?contains(operationName.value, 'Microsoft.ContainerRegistry')]"

# GCP GCR / Artifact Registry
gcloud logging read \
    'protoPayload.serviceName="artifactregistry.googleapis.com"
     AND protoPayload.methodName=~".+pull"' \
    --project=<project>
```

A pulled image whose hash differs from prior pulls of the same tag is a supply-chain indicator.

### 10.4 Runtime Detection Sources

- **AWS GuardDuty Runtime Monitoring** for EKS / ECS / Fargate / EC2 [verify 2026-04-27] — eBPF-based per-process / per-syscall telemetry; findings include process injection, reverse shells, crypto-mining patterns.
- **Azure Defender for Containers** [verify 2026-04-27] — agent-based runtime detection on AKS + Arc-connected clusters; integrated with Defender XDR.
- **GCP Container Threat Detection** (part of Security Command Center Premium / Enterprise) [verify 2026-04-27] — kernel-instrumented detection for GKE.
- **Falco** (CNCF) — open-source runtime detection driven by configurable rules; deployed by the customer; logs to syslog / Falcosidekick / SIEM.
- **Tetragon** (CNCF, Cilium) — eBPF-based observability and enforcement.

### 10.5 Node-Level Artifacts

When access to the underlying compute node is authorized, classical host forensics applies (see [[sop-forensics-investigation|Digital Forensics Investigation]]). Container-specific artifacts:

- **containerd / CRI-O / Docker shim logs** — `/var/log/syslog`, `/var/log/messages`, `journalctl -u containerd`.
- **Container layer storage** — `/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/` / `/var/lib/docker/overlay2/`. Layer mounts retain the file-system state of running and recently-stopped containers.
- **Kubelet logs** — `/var/log/kubelet.log` or via `journalctl -u kubelet`.
- **Pod logs** — `/var/log/pods/<namespace>_<pod>_<uid>/<container>/0.log`.
- **Volume mounts** — host-path mounts and persistent-volume claims with backing storage on the node or attached cloud disks.

---

## 11. Evidence Preservation for Cloud Volumes

When a compromised compute resource needs forensic preservation, the cloud-native path is **snapshot, copy, isolate, hash**. Snapshots are atomic, hash-chainable, and far cheaper to store than raw disk dumps.

### 11.1 AWS — EBS Snapshot for Forensics

```bash
# Step 1 -- identify the affected instance and its volumes
aws ec2 describe-instances --instance-ids <instance-id> \
    --query 'Reservations[].Instances[].BlockDeviceMappings'

# Step 2 -- create snapshot(s) with descriptive metadata
aws ec2 create-snapshot \
    --volume-id vol-<id> \
    --description "Forensic snapshot - case <case-id> - $(date -u +%Y%m%dT%H%M%SZ)" \
    --tag-specifications 'ResourceType=snapshot,Tags=[
        {Key=case,Value=<case-id>},
        {Key=type,Value=forensic},
        {Key=collected_by,Value=<investigator>},
        {Key=collected_at,Value=2026-04-27T00:00:00Z}]'

# Step 3 -- copy snapshot to investigator account / dedicated forensics account
aws ec2 modify-snapshot-attribute \
    --snapshot-id snap-<id> \
    --create-volume-permission Add="UserId=<forensics-acct-id>"
# Then in forensics account:
aws ec2 copy-snapshot \
    --source-region <region> --source-snapshot-id snap-<id> \
    --description "Forensic copy - case <case-id>"

# Step 4 -- attach to a forensic analysis instance, mount read-only, and hash
# (the mounted device path varies; assume /dev/xvdf for this example)
sudo mount -o ro,noexec /dev/xvdf1 /mnt/evidence
sudo sha256sum /dev/xvdf > /evidence/<case-id>-vol.sha256

# Step 5 -- record chain-of-custody per sop-collection-log
```

For **encrypted volumes**, snapshots inherit the source KMS key. Cross-account snapshot sharing requires (a) the source key permits the forensics account in its key policy and (b) the forensics account re-encrypts on copy with its own key.

### 11.2 Azure — Managed-Disk Snapshot

```bash
# Create snapshot
az snapshot create \
    --resource-group <rg> --name <case-id>-osdisk-snap \
    --source <source-disk-id> \
    --tags case=<case-id> type=forensic collected_by=<investigator>

# Grant SAS access to forensics subscription / storage
az snapshot grant-access --resource-group <rg> --name <snap-name> --duration-in-seconds 3600

# Download the underlying VHD via the SAS URL
azcopy cp "<sas-url>" /evidence/<case-id>-osdisk.vhd

# Hash on download
sha256sum /evidence/<case-id>-osdisk.vhd > /evidence/<case-id>-osdisk.sha256
```

### 11.3 GCP — Persistent-Disk Snapshot

```bash
# Create snapshot
gcloud compute snapshots create <case-id>-pd-snap \
    --source-disk=<disk-name> --source-disk-zone=<zone> \
    --description="Forensic snapshot - case <case-id>" \
    --labels=case=<case-id>,type=forensic,collected_by=<investigator>

# Copy to forensics project (re-create disk from snapshot in the forensics project after sharing)
gcloud compute snapshots add-iam-policy-binding <snap-name> \
    --member=serviceAccount:<forensics-project-sa> \
    --role=roles/compute.viewer

# In forensics project, create disk from snapshot, attach to a forensics VM, mount read-only, hash
```

### 11.4 Snapshot Chain-of-Custody

Every snapshot lifecycle event must be logged per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]:

- **Source identification** — original instance / VM / GCE name, region, account / subscription / project, attached volumes / disks at snapshot time, instance state (running / stopped) at snapshot time.
- **Snapshot creation** — timestamp, executing principal, source-volume ID, snapshot ID.
- **Cross-account / cross-region copy** — every transfer logged.
- **Hashing** — SHA-256 (baseline) + SHA3-256 (defensive paired) as soon as the snapshot is downloadable as a single artifact, per [[sop-hash-generation-methods|Hash Generation Methods]]. Recompute and verify before any analysis.
- **Mount discipline** — read-only mount only; the original snapshot is never modified; analysis happens on a copy or via a read-only block-device mount.
- **Storage location** — investigator-controlled S3 / Storage / GCS, encrypted at rest with a key the suspect tenant cannot access.

### 11.5 Memory Acquisition from Cloud VMs

Live RAM acquisition from a running cloud VM is harder than disk. Options:

- **AWS** — Use an in-instance agent (AVML for Linux, WinPmem for Windows) over SSM Session Manager or the in-instance agent already deployed (CrowdStrike RTR, etc.). Stream the memory image to S3 or a forensics SSH tunnel.
- **Azure** — Same agent-based pattern over Azure Bastion / RunCommand / Azure VM Agent.
- **GCP** — Same agent-based pattern over IAP TCP tunneling / OS Login.

Cloud-provider memory-snapshot APIs (e.g., `lguestmem` etc.) generally are not customer-facing for forensics use [verify 2026-04-27]; agent-based capture remains the practical path. AWS Nitro EC2 instance memory is not directly readable from outside the instance.

---

## 12. Cross-Cloud Correlation

Multi-cloud incidents are routine — adversaries pivot from a compromised AWS access key to an Azure tenant via the same federated SaaS IdP, or from GCP service-account impersonation to a Workload-Identity-Federated AWS role. Cross-cloud correlation is the integration step that classical single-cloud forensics misses.

### 12.1 Correlation Anchors

- **Federated identity events.** A SAML / OIDC sign-in event in the IdP (Okta, Entra ID, Workspace) pairs with `AssumeRoleWithSAML` / `AssumeRoleWithWebIdentity` / Entra federated-credential token / GCP `GenerateAccessToken` events in the consumer cloud.
- **Workload Identity Federation tokens.** A workload running in cloud A produces an OIDC token; cloud B accepts it and mints a session. Both sides log the event.
- **Common source IPs / ASNs.** Adversaries reuse infrastructure; an IP that signed in to AWS may also appear in Azure sign-in logs.
- **Common user agents.** AWS CLI default user agent `aws-cli/<version>`, custom Python / Go SDK strings, attacker-tooling fingerprints (Pacu, ScoutSuite, Stratus Red Team, etc.) are detectable across clouds.
- **Common timing.** Same-millisecond bursts of activity across clouds rarely originate from independent humans.
- **Common credentials artifacts.** A leaked `~/.aws/credentials` file may also contain `~/.azure/` / `~/.config/gcloud/` credentials; the breach scope crosses clouds even if the initial detection did not.

### 12.2 Correlation Workflow

1. **Build a per-cloud timeline** for the suspect window (CloudTrail, Activity Log, Cloud Audit Logs).
2. **Extract source IPs, ASNs, user agents, and federated-identity claims** from each cloud's events.
3. **Cross-walk identity claims** — the OIDC `sub`, `aud`, `iss` claims tie federated sessions back to a single upstream identity.
4. **Construct a unified timeline** indexed by event time (UTC), with a `cloud` column identifying source.
5. **Look for "impossible travel" across clouds** — sign-ins from incompatible geographies in tight windows.
6. **Look for resource-creation-then-resource-creation chains across clouds** in tight windows — adversary staging.
7. **Cross-walk to non-cloud artifacts** — VPN logs, EDR telemetry, on-prem AD audit, IdP logs, SaaS-tenant logs (route to [[sop-saas-log-forensics|SaaS Log Forensics]]).

### 12.3 Tooling Notes

- **Cartography** ([github.com/cartography-cncf/cartography](https://github.com/cartography-cncf/cartography)) — Neo4j graph of multi-cloud asset and identity relationships; useful for mapping "what could principal X reach" rather than "what did principal X do."
- **Steampipe / Powerpipe / Flowpipe** ([steampipe.io](https://steampipe.io)) — SQL over multi-cloud APIs; enables ad-hoc cross-cloud queries.
- **CloudGrappler** ([permiso.io](https://permiso.io)) [verify 2026-04-27] — open-source detection across CloudTrail / Azure Activity / Sentinel for known TTPs.
- **Sigma** ([github.com/SigmaHQ/sigma](https://github.com/SigmaHQ/sigma)) — vendor-neutral detection rule format with cloud-source rule packs; convertible to KQL / Athena SQL / Splunk SPL.

---

## 13. Cloud-Native IR Tooling

### 13.1 AWS

- **Amazon Detective** [verify 2026-04-27] — graph-based investigation surface over CloudTrail + VPC Flow + GuardDuty + EKS audit. Particularly strong for IAM principal / role-chain visualization.
- **Athena** — SQL over CloudTrail / VPC Flow / WAF / S3 access logs in S3.
- **CloudTrail Lake** — built-in long-term store (§4.2).
- **Security Lake** — OCSF-normalized cross-source store (§4.4).
- **Macie** — sensitive-data classification (§4.8).
- **GuardDuty** — managed threat detection (§4.4).
- **AWS IR (Incident Response service)** [verify 2026-04-27] — first-party IR tooling for AWS-hosted incidents; manages investigator access, evidence collection, and CSP coordination.

### 13.2 Azure

- **Microsoft Sentinel** — KQL-based SIEM; the canonical forensic query surface for Azure-heavy customers.
- **Defender for Cloud** — CSPM + CWPP + runtime detection; finding feed.
- **Defender XDR** — cross-product (Endpoint + Identity + Cloud + Office) advanced hunting.
- **Microsoft Incident Response (formerly DART)** — Microsoft's in-house IR team available under support contracts.

### 13.3 GCP

- **Chronicle (Google SecOps)** — cloud-native SIEM with YARA-L 2.0 detection and 12-month default retention.
- **Security Command Center** — CSPM + CWPP; finding feed.
- **BigQuery over log sinks** — most flexible long-term forensic-query surface for GCP-heavy customers.
- **Mandiant** (Google-owned) — IR and threat-intel; available under support contracts.

### 13.4 Open-Source / Vendor-Neutral

| Tool | Purpose | Notes |
|---|---|---|
| Cartography | Multi-cloud asset / identity graph (Neo4j) | Exploration and what-if reasoning |
| Steampipe | SQL over multi-cloud APIs | Ad-hoc cross-cloud queries |
| Cloud Custodian | Policy-as-code remediation engine | Useful for evidence-collection automation |
| Falco | Runtime detection (containers / Linux) | CNCF graduated |
| Tetragon | eBPF observability + enforcement | Cilium |
| CloudGrappler | TTP-based hunting across CloudTrail / Azure / GCP | [verify 2026-04-27] |
| Stratus Red Team | Adversary emulation in cloud | Validates detection coverage; not for live exploitation |
| Sigma | Detection rule format | Vendor-neutral; convertible to KQL / Athena / Splunk |
| Prowler | CSPM scanner with forensic-relevant findings | Multi-CSP |
| ScoutSuite | Multi-CSP audit toolkit | Snapshot of misconfigurations |
| LiME / AVML / WinPmem | RAM acquisition (run inside cloud VM) | See [[sop-forensics-investigation|Digital Forensics Investigation]] |
| Velociraptor | Cross-platform endpoint hunting / collection | Works on cloud VMs via agent |
| GRR | Live-response framework | Less actively maintained as of 2026-04-27 [verify] |
| Kape | Triage collection (Windows) | See [[sop-forensics-investigation|Digital Forensics Investigation]] |

---

## 14. Hand-off Boundaries

| When the investigation observes... | Routes to... |
|---|---|
| SaaS-tenant identity / collaboration evidence (M365 UAL, Workspace Reports, Okta System Log, Slack Discovery, OAuth consent grants) | [[sop-saas-log-forensics|SaaS Log Forensics]] |
| Email header / SPF / DKIM / DMARC / wire-recall / lookalike-domain BEC pattern | [[sop-email-bec-forensics|Email & BEC Forensics]] |
| OAuth-consent BEC variant (attacker-app token persistence) | [[sop-saas-log-forensics|SaaS Log Forensics]] |
| Cloud-resident malware payload (binary in S3 / Storage / GCS, Lambda / Function code, container image) | [[sop-malware-analysis|Malware Analysis]] |
| Crypto-mining / wallet-stealer payload — on-chain consequences | [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] |
| Mixer / privacy-pool laundering downstream of cloud-resident wallet drain | [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] |
| Smart-contract code review (post-exploit smart-contract analysis) | [[sop-smart-contract-audit|Smart Contract Audit]] |
| Cryptographic primitive concern in customer-managed KMS key (curve / hash / KEM choice) | [[sop-cryptography-analysis|Cryptography Analysis]] |
| Pod escape / RBAC abuse / admission-controller bypass methodology | (planned) `sop-container-k8s-pentest` |
| Host / disk / memory parsing of a snapshot-derived volume | [[sop-forensics-investigation|Digital Forensics Investigation]] |
| Authorized offensive cloud testing (red-team, post-incident validation, purple-team) | [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] |
| SIEM-evasion / detection-coverage validation | [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] |
| 0-day in CSP service surface (RCE in a managed service) discovered during investigation | [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] + CSP coordinated-disclosure pathway |
| Sensitive-crime indicators (CSAM in S3 bucket, trafficking pattern in cloud-resident comms) | [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — **hard-stop** for CSAM; URL + timestamp only, no content preservation |
| Final reporting / disclosure mechanics | [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] |
| Authorization, jurisdiction, prohibited actions | [[sop-legal-ethics|Legal & Ethics]] |
| Investigator infrastructure / artifact hygiene / pre-disclosure handling | [[sop-opsec-plan|OPSEC]] |

---

## 15. Tools Reference

### Provider-Native Forensic Surfaces

| Tool | CSP | Purpose |
|------|-----|---------|
| CloudTrail / CloudTrail Lake | AWS | Control-plane audit, long-term retention |
| Athena | AWS | SQL over S3-stored logs |
| Detective | AWS | Graph-based IR investigation |
| GuardDuty | AWS | Managed threat detection |
| Security Lake | AWS | OCSF-normalized cross-source data lake |
| Macie | AWS | S3 sensitive-data classification |
| Config | AWS | Resource configuration history |
| Activity Log | Azure | Subscription-scope control-plane audit |
| Microsoft Entra ID logs | Azure | Identity-plane audit |
| Microsoft Sentinel | Azure | Cloud-native SIEM (KQL) |
| Defender for Cloud | Azure | CSPM + runtime detection |
| Defender XDR | Azure | Cross-product hunting |
| Cloud Audit Logs | GCP | Admin Activity / Data Access / System Event / Policy Denied |
| Chronicle / Google SecOps | GCP | Cloud-native SIEM (YARA-L 2.0) |
| Security Command Center | GCP | CSPM + threat detection |
| BigQuery (log sink target) | GCP | Long-term log analytics |
| Cloud Asset Inventory | GCP | Resource state history |

### Open-Source / Vendor-Neutral

| Tool | Purpose | Link |
|------|---------|------|
| Cartography | Multi-cloud asset / identity graph (Neo4j) | https://github.com/cartography-cncf/cartography |
| Steampipe | SQL over multi-cloud APIs | https://steampipe.io |
| Cloud Custodian | Cloud governance / policy-as-code | https://cloudcustodian.io |
| Falco | Runtime detection (CNCF) | https://falco.org |
| Tetragon | eBPF observability + enforcement (CNCF, Cilium) | https://tetragon.io |
| CloudGrappler | TTP-driven cloud-log hunting (Permiso) | https://github.com/Permiso-io-tools/CloudGrappler |
| Stratus Red Team | Cloud adversary emulation (DataDog) | https://github.com/DataDog/stratus-red-team |
| Sigma | Vendor-neutral detection rule format | https://github.com/SigmaHQ/sigma |
| Prowler | CSPM scanner (multi-CSP) | https://github.com/prowler-cloud/prowler |
| ScoutSuite | Multi-CSP audit toolkit | https://github.com/nccgroup/ScoutSuite |
| Velociraptor | Cross-platform endpoint hunting / collection | https://docs.velociraptor.app |
| Volatility 3 | Memory analysis (parent template) | https://github.com/volatilityfoundation/volatility3 |
| AVML | Linux RAM acquisition | https://github.com/microsoft/avml |
| WinPmem | Windows RAM acquisition | https://github.com/Velocidex/WinPmem |
| Aws2Neo4j / AzureHound (data-source) | Identity graph extraction (offensive-leaning, useful for understanding adversary view) | various |

### Reference / Documentation

| Resource | Purpose |
|----------|---------|
| AWS CloudTrail User Guide | https://docs.aws.amazon.com/awscloudtrail/ |
| Microsoft Security Operations Guide | https://learn.microsoft.com/security/operations/ |
| Google Cloud Logging | https://cloud.google.com/logging/docs |
| MITRE ATT&CK for Cloud | https://attack.mitre.org/matrices/enterprise/cloud/ |
| MITRE ATT&CK for Containers | https://attack.mitre.org/matrices/enterprise/containers/ |
| NIST SP 800-86 | Guide to Integrating Forensic Techniques into Incident Response |
| NIST SP 800-53 / 800-171 | Security and privacy controls |
| NIST IR 8517 (Cloud-Native Application Protection) | https://csrc.nist.gov/ [verify 2026-04-27] |
| CSA Cloud Controls Matrix | https://cloudsecurityalliance.org/research/cloud-controls-matrix/ |
| SANS Cloud Forensics Resources | https://www.sans.org/cyber-security-courses/cloud-security-essentials/ |

---

## 16. Risks & Limitations

- **Data-plane logging gaps.** When data events / Resource Logs / Data Access logs were not enabled before the incident, the data-access reconstruction is bounded by what control-plane and network-plane evidence can imply. This is the largest evidentiary limitation in most cloud cases. Document the gap in the report rather than overstating evidence.
- **Retention cliffs.** Default retentions (CloudTrail Event history 90 days, Activity Log 90 days, GCP Cloud Audit Logs Admin Activity 400 days, Data Access 30 days) are short relative to most incident-discovery timelines (median dwell times for cloud incidents trend 30-60 days; long-tail incidents discovered after default retention has expired are common). Customers without long-term log export lose evidence to retention silently. Verify retention end-to-end before promising a reconstruction.
- **Sub-account / sub-tenant boundary visibility.** AWS Organizations service-control policies, Azure management-group hierarchy, and GCP organization policy can restrict cross-tenant log visibility. The investigator's IAM scope must be sufficient for the engagement's visibility needs; insufficient scope is itself a finding to document.
- **Provider-side log latency.** CloudTrail events can lag 5-20 minutes. Activity Log events lag similarly. GCP Cloud Audit Logs are usually faster but vary per service. Real-time alerting and forensic reconstruction tolerate this differently — the investigator must not infer "the event did not happen" from a same-millisecond gap.
- **Log volume vs query budget.** Long-window cross-region queries against multi-TB log stores are expensive. Athena scan-bytes, CloudTrail Lake event-scan-bytes, BigQuery slot-time, Sentinel ingest GB all bill. Pre-engagement budget conversation with the client.
- **Service-coverage drift.** New CSP services launch monthly; not every service emits structured audit logs at launch. Forensic visibility for the newest services may be limited or completely absent. Confirm per-service event coverage in current CSP documentation.
- **Provider-internal action attribution.** Some events are emitted by the provider's own infrastructure (system maintenance, automated lifecycle actions) and look superficially like adversary activity. Familiarize with the per-service "system" principal patterns before flagging.
- **Cross-cloud cross-correlation latency.** When multiple clouds and multiple SaaS providers are involved, log-export pipelines latency-stack; the unified timeline lags the truth by hours.
- **Evidence integrity end-to-end.** A SHA-256 hash at export proves nothing about the source-side integrity (the log writer could already have been compromised). CloudTrail digest validation, GCP sink immutability, Azure WORM all push the integrity boundary closer to the source — but none push it to the source.
- **Encrypted-volume snapshot key dependency.** If the source KMS key is later revoked (or the source account is closed), the snapshot becomes unreadable even from the forensics account. Re-encrypt with a forensics-controlled key during the cross-account copy.
- **Memory acquisition is hard.** Cloud VM memory is rarely directly readable. Agent-based capture requires advance deployment. Many incidents have no live memory to capture.
- **Court-admissibility of cloud evidence is jurisdiction-dependent.** Cloud-provider declarations, log-integrity attestations, and chain-of-custody form the evidentiary spine. Daubert (US) / Calderone (international) admissibility framing is well-trodden for AWS / Azure / GCP control-plane evidence; less so for newer or smaller providers. See [[sop-legal-ethics|Legal & Ethics]] for the current jurisdictional framing.
- **Adversary log-aware behavior.** Sophisticated cloud-incident operators know about CloudTrail digest validation, Azure immutability, GCP sinks. They target the configuration of these controls — disabling logs, redirecting sinks — as their primary anti-forensic move. Treat the absence of expected events as a finding, not a clean bill.
- **Multi-tenant blast radius.** Cloud-incident scope can balloon when shared infrastructure (cross-account roles, cross-tenant trust, shared CI / CD pipelines) is in play. Initial scope estimates often understate the surface.

---

## 17. Common Pitfalls

- **Treating an alert as the scope.** The alert fired on one resource; the incident touched a region you didn't query.
- **Relying on Event history / portal lookup beyond default retention.** The free 90-day surface is for triage, not reconstruction. Long-window reconstruction requires the durable log store.
- **Querying without timezone discipline.** Mixing local time, UTC, and CSP-local time across providers produces a timeline that does not survive review. Normalize to UTC at ingestion.
- **Snapshot in source account only.** If the source account is the suspect, leaving evidence under suspect control is a chain-of-custody problem. Always copy out to a dedicated forensics account / subscription / project.
- **Hash after analysis, not at acquisition.** Hashing should be the first action after export, before the artifact lands on any analysis disk.
- **Skipping the digest validation step.** CloudTrail digest validation is one CLI command. Running it is non-optional for evidence going to court / regulators.
- **Conflating service-principal sign-ins with user sign-ins.** Service-principal activity dwarfs user activity in volume; filtering it out (or not separating it) hides the human-driven actions in the noise.
- **Ignoring federated-identity events.** A user sign-in via SAML / OIDC may have been the initial attack vector; the IdP-side audit (Okta, Entra, Workspace) is required for the full picture.
- **Treating GuardDuty / Defender / SCC findings as ground truth.** They are findings, not facts. Validate each against the underlying log evidence.
- **Skipping VPC Flow Logs.** Network-plane evidence is high-signal for exfil and lateral movement; control-plane logs alone miss the network surface.
- **Forgetting CloudShell history.** AWS CloudShell, Azure Cloud Shell, GCP Cloud Shell preserve user history under user-controlled paths; if the suspect used them, the history is investigative gold (and is also at risk of attacker cleanup).
- **Letting the CSP's IR support do everything.** Provider IR support is helpful but their access is broader than the engagement's authorization. Run the CSP support case under the customer's account, not the investigator's; record what they did.
- **Failing to sample retention before promising reconstruction.** A pre-engagement check (`describe-trails` / `diagnostic-settings list` / `logging sinks list`) reveals what evidence actually exists. Promise based on what's there, not what should be there.
- **Querying production accounts without rate awareness.** API throttling on a stressed production account can cause secondary incidents. Use bulk-export paths (S3 sync, Storage download, BigQuery export) over high-cardinality API loops.
- **Re-running region sweeps from a single endpoint.** Some CSP regional endpoints are slow / unreliable; iterate per-region rather than relying on a single global endpoint to fan out.
- **Overlooking encrypted snapshots for cross-account copy.** Without KMS key permission and re-encryption discipline, cross-account snapshot copy fails silently or produces unreadable artifacts.
- **Treating IR retainer access as engagement authorization.** Retainer scope and engagement scope are different. Verify the engagement-specific authorization separately.
- **Ignoring Workload Identity Federation in the threat model.** WIF is a routine privilege-escalation primitive that crosses cloud boundaries; if your threat model only covers one cloud, you miss it.
- **Skipping the disclosure-clock conversation.** GDPR Art. 33, SEC cyber-disclosure, state notification laws have hard timelines. The forensic team cannot issue a final report and then let counsel discover the clock has expired.
- **Pasting raw event JSON into the report.** Tooling output is appendix material; findings are interpreted prose with referenced evidence IDs.
- **Stale credentials in investigator notes.** Old engagement credentials in the investigator's note-taking tools become a future-engagement liability. Rotate and document destruction at engagement end.

---

## 18. Real-World Scenarios

The scenarios below abstract observed cloud-incident patterns to illustrate how the methodology in this SOP applies. They are pattern catalogues, not engagement-specific narratives.

### 18.1 Scenario — Stolen Long-Lived AWS Access Key Used for Resource Hijacking

**Pattern.** A developer's `~/.aws/credentials` file is exfiltrated via a compromised laptop. The attacker authenticates from a residential-proxy IP, calls `GetCallerIdentity` to confirm, then `RunInstances` in a low-cost region the customer does not historically use, deploys crypto-miners on `c7g.16xlarge` instances, and sets up an SES-based phishing infrastructure. The customer is alerted by AWS Trust & Safety after the SES reputation impacts the broader AWS region.

**Forensic catch.** §4.1 CloudTrail collection identifies the access key's use; §4.7 IAM Access Analyzer + Config flags the access-key creation history; §7.2 access-key abuse indicators (new IP / ASN, anomalous user agent) confirm. §8.1 region sweep enumerates all regions for resources tied to the suspect access key. §11.1 EBS snapshot preserves the `c7g.16xlarge` boot volumes for malware analysis. §13.1 Detective visualizes the principal-action graph for the report.

**Hand-off.** Cryptocurrency-mining wallet addresses route to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]. Phishing infrastructure (sender domains, bait pages) routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. Underlying laptop compromise routes to [[sop-forensics-investigation|Digital Forensics Investigation]] for endpoint disk / memory analysis.

### 18.2 Scenario — Compromised CI/CD Pipeline Pivots via Workload Identity Federation

**Pattern.** A GitHub Actions workflow with broad WIF permission to an AWS account is hijacked via a malicious dependency in the build (typo-squatted package). The malicious code executes during CI, the GitHub OIDC token is exchanged for an AWS session via `AssumeRoleWithWebIdentity`, and the session enumerates Secrets Manager and S3 buckets, exfiltrating customer data.

**Forensic catch.** §4.1 CloudTrail collection identifies the `AssumeRoleWithWebIdentity` event with `requestParameters.tokenSubject` referencing a GitHub workflow run; §7.5 cross-cloud WIF reconstruction pairs the AWS session with the GitHub Actions workflow run. §7.1 `AssumeRole` chain reconstruction walks subsequent privilege use. §4.5 VPC Flow Logs identify the data-egress destinations. §12.2 cross-cloud correlation timeline shows the GitHub event → AWS event pairing.

**Hand-off.** Compromised dependency analysis routes to [[sop-malware-analysis|Malware Analysis]]. GitHub-side audit (workflow run, artifact, secret access) routes to [[sop-saas-log-forensics|SaaS Log Forensics]]. Pipeline / supply-chain hardening recommendations route to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] for purple-team validation.

### 18.3 Scenario — GKE Cluster Compromise via Exposed Workload Service Account

**Pattern.** A pod in a GKE cluster mounts the cluster's default service account (rather than a least-privilege workload-identity-bound SA). A web-app vulnerability in the pod (server-side request forgery) lets the attacker reach the GCP metadata server and harvest the service account's token. The token has `roles/storage.admin` at the project level. The attacker enumerates buckets and exfiltrates data.

**Forensic catch.** §6.1 Cloud Audit Logs identify the service-account token use from the pod; §7.4 service-account impersonation forensics reconstructs the chain (in this case, no impersonation — direct token use). §10.1 Kubernetes apiserver audit logs identify the pod's service-account binding and the absence of a Workload Identity binding. §10.4 Container Threat Detection (if enabled) may have flagged the runtime SSRF execution. §6.6 VPC Flow Logs from the GKE pod's egress show the connection to the GCP metadata server (an unusual egress pattern). §11.3 persistent-disk snapshots of the affected pod nodes preserve container layer state.

**Hand-off.** Pod / container exploit methodology (the SSRF itself, container-escape primitives) routes to (planned) `sop-container-k8s-pentest`. SSRF web-app-side analysis routes to [[../Pentesting/sop-web-application-security|Web Application Security]]. Bucket-data sensitivity analysis (PII / PHI / regulated data) routes to compliance counsel via [[sop-legal-ethics|Legal & Ethics]] for breach-notification timeline. Hardening recommendation: bind workloads to dedicated service accounts via Workload Identity; disable default service account; deploy [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] purple-team validation against the new boundary.

### 18.4 Scenario — Adversary Disables Logging Before Action

**Pattern.** An attacker with a high-privilege AWS role first disables CloudTrail logging (`StopLogging`), waits 5 minutes, performs the actions of interest, then re-enables logging (`StartLogging`). The intervening window has no CloudTrail visibility.

**Forensic catch.** §9.1 digest validation immediately flags the gap (the digest chain breaks where logging was off). §9.6 cross-CSP tamper-indicators identify the `StopLogging` / `StartLogging` events themselves (which **do** appear in CloudTrail because they are management events independent of trail-status). Cross-correlation with §4.5 VPC Flow Logs (network-plane, separate from CloudTrail) and §10.4 GuardDuty Runtime Monitoring (runtime-plane, separate) reconstructs adversary action during the blind window from non-CloudTrail telemetry.

**Hand-off.** Detection-coverage hardening (preventing future `StopLogging` via SCP, alerting on CloudTrail-disable events in real-time) routes to [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] for purple-team validation. The adversary's likely awareness of CloudTrail digest validation suggests sophisticated tooling — TTPs route to threat-intel for upstream attribution.

---

## 19. Related SOPs

**Analysis (parent and adjacent):**
- [[sop-forensics-investigation|Digital Forensics Investigation]] — parent template; host / disk / memory forensics methodology that this SOP extends into the cloud control plane. Snapshot-derived volumes are mounted and parsed using forensics-investigation methodology; the cloud-specific surface is the snapshot lifecycle.
- [[sop-malware-analysis|Malware Analysis]] — receives hand-off for cloud-resident payloads (binaries in S3 / Storage / GCS, Lambda / Function code, container images).
- [[sop-hash-generation-methods|Hash Generation Methods]] — evidence-integrity hashing for snapshot copies, log exports, and analysis artifacts.
- [[sop-cryptography-analysis|Cryptography Analysis]] — KMS / Key Vault / Cloud KMS primitive review; envelope-encryption reasoning.
- [[sop-smart-contract-audit|Smart Contract Audit]] — on-chain code review when the cloud workload includes smart-contract operations.
- [[sop-reverse-engineering|Reverse Engineering]] — when cloud-resident binaries require deep static / dynamic analysis.
- [[sop-saas-log-forensics|SaaS Log Forensics]] — sibling SOP covering the SaaS-tenant identity / collaboration plane (M365 UAL, Workspace Reports, Okta System Log, Slack Discovery, OAuth consent grants). Hybrid incidents that bridge identity events to cloud-resource actions are split at the action level.
- [[sop-email-bec-forensics|Email & BEC Forensics]] — sibling SOP covering email-vector incident reconstruction (header forensics, SPF / DKIM / DMARC / ARC, lookalike-domain detection, wire-recall pathway). When BEC-stolen credentials enable cloud-resource action, the email side stays in #9 and the cloud-resource action routes here.

**Pentesting (offensive counterparts):**
- [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] — offensive cloud testing; the threat model that this SOP's defensive methodology answers. Purple-team validation of detection coverage routes here.
- [[../Pentesting/sop-detection-evasion-testing|Detection & Evasion Testing]] — SIEM / EDR / cloud-detection coverage validation.
- [[../Pentesting/sop-vulnerability-research|Vulnerability Research]] — for 0-day discovery in CSP service surfaces during investigation.
- [[../Pentesting/sop-web-application-security|Web Application Security]] — when the initial vector is a web-app vulnerability in a cloud-hosted workload.
- [[../Pentesting/sop-mobile-security|Mobile Security]] — for mobile-app integrations with cloud back-ends.

**Investigations (cross-domain):**
- [[../../Investigations/Techniques/sop-collection-log|Collection Log]] — canonical chain-of-custody and evidence-hashing workflow.
- [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]] — when cloud-resident wallet drains or crypto-mining payouts produce on-chain consequences.
- [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]] — when on-chain consequences route through mixers / privacy pools.
- [[../../Investigations/Techniques/sop-financial-aml-osint|Financial & AML OSINT]] — fiat AML, banking pivots, corporate UBO when cloud findings touch payment infrastructure.
- [[../../Investigations/Techniques/sop-web-dns-whois-osint|Web / DNS / WHOIS OSINT]] — when adversary infrastructure has clearnet pivots.
- [[../../Investigations/Techniques/sop-darkweb-investigation|Darkweb Investigation]] — when cloud-resident credentials surface in marketplace / forum / leak-site contexts.
- [[../../Investigations/Techniques/sop-entity-dossier|Entity Dossier]] — for dossier compilation on identified threat actors.
- [[../../Investigations/Techniques/sop-image-video-osint|Image / Video OSINT]] — for analysis of screenshot / video evidence collected during the engagement.
- [[../../Investigations/Techniques/sop-sensitive-crime-intake-escalation|Sensitive-Crime Intake & Escalation]] — for CSAM / trafficking / threat-to-life findings (hard-stop routing).
- [[../../Investigations/Techniques/sop-reporting-packaging-disclosure|Reporting, Packaging & Disclosure]] — for disclosure mechanics and coordinated publication.

**Cross-cutting:**
- [[sop-legal-ethics|Legal & Ethics]] — canonical jurisdictional framework, breach-notification timelines, cross-border data-transfer constraints.
- [[sop-opsec-plan|OPSEC]] — investigator infrastructure, artifact hygiene, and pre-disclosure handling discipline.

**Forward references (planned, not yet built):**
- (planned) `sop-container-k8s-pentest` — pod escapes / RBAC abuse / admission-controller bypass methodology.

---

## Legal & Ethical Considerations

> Canonical jurisdictional framework lives in [[sop-legal-ethics|Legal & Ethics]]. The summary below is operational guidance for cloud-forensics engagements specifically; do not substitute it for the cross-referenced source.

### Authorization

- **Tenant-administrator authorization** is the typical engagement authority. The cloud account / tenant / org owner authorizes the investigator's read-only role and any state-changing actions (snapshot creation, principal disablement). Without it, the investigator's access is unauthorized regardless of the suspect's behavior.
- **Provider legal process** is the route for cross-tenant evidence (tenant A is suspect, tenant B is victim). Subpoena / warrant / MLAT to AWS / Microsoft / Google. Provider-published LE guidelines define the form. [verify 2026-04-27]
- **Cross-jurisdiction authorization.** EU-data, healthcare, payment, and government-cloud workloads can carry residency / sovereignty constraints that limit cross-border evidence transfer even with tenant authorization. CLOUD Act executive agreements (US-UK, US-AU, US-CA in progress, etc.) and the Budapest Convention Second Additional Protocol shape MLAT alternatives. Verify under counsel.
- **Engagement scope drift.** Cloud incidents tend to expand mid-engagement (initial scope: one account; mid-engagement scope: an Organization with 30 accounts and three SaaS providers). Any scope expansion needs documented re-authorization.

### Anti-Hacking Statute Framing

Cloud-forensics actions are typically read-only against tenants the investigator is authorized to access — far inside the CFAA / Computer Misuse Act / Cybercrime Directive lines. Specifically:

- **Read-only collection within authorized tenants** — allowed.
- **State-changing actions (snapshot creation, principal disablement, log export, role assumption)** — allowed only when the engagement explicitly authorizes them; document each action with attribution.
- **Pivoting into adversary infrastructure observed during the investigation** — generally **not** authorized. "We saw the attacker's IP — let's scan their VPS" crosses into unauthorized access. Attribution and intelligence are valuable; offensive pivots are not the investigator's job. Route adversary-infrastructure findings through threat-intel channels.
- **Active-defense actions** (sinkholing, beaconing payloads back, credential canaries) — verify under counsel before any deployment; actions framed as "defensive" can be charged as offensive in some jurisdictions.

### Data-Subject and Privacy Considerations

- **GDPR Art. 6 / 9** — processing of personal data during investigation requires a lawful basis; legitimate interest is the typical basis but is balanced against data-subject rights.
- **GDPR Art. 33** — supervisory-authority notification within 72 hours of becoming aware of a personal-data breach.
- **GDPR Art. 34** — data-subject notification when the breach is high-risk to the data subjects.
- **HIPAA Breach Notification Rule** — covered entities + business associates have 60-day notification windows.
- **State breach laws** (US) — varies by state; California (CCPA / CPRA), New York (SHIELD), and many others have specific timelines and requirements.
- **PCI DSS Incident Response Plan** — required for cardholder-data environments; provider notification paths defined.
- **Sectoral rules** — finance (NYDFS Part 500, FFIEC, EBA / DORA), healthcare (HIPAA, NIS2 in EU), telecom (sectoral) — verify per engagement.

### Disclosure Discipline

- Pre-disclosure findings are restricted to the engagement team and the client per the engagement contract.
- Findings affecting third parties (a vendor's credential abused; a customer's API key found in suspect activity; an upstream supply-chain compromise indicator) are escalated through the affected party's security contact, not embedded silently in the client's report.
- CSP coordination is sometimes warranted (provider-resident vulnerability in service surface; widespread credential-leak indicator). AWS Security, MSRC, and Google VRP each publish coordinated-disclosure paths.
- Live-incident findings (the investigation discovers an active exploit on a tenant the investigator does not own and is not authorized for) trigger immediate client escalation; the operational response is the client's, not the investigator's, unless explicitly contracted.

### Conflict-of-Interest Posture

- The investigator does not hold or trade securities of the affected entity during the engagement window.
- The investigator does not publish independent commentary on the engagement's substance during the engagement window.
- The investigator discloses any prior or concurrent engagements with adjacent parties (the affected entity's vendors, customers, competitors) before commencing.

### Post-Engagement Records

- Engagement repo + analysis artifacts retained per contract terms (typically 1-7 years; sometimes longer for litigation-hold cases).
- Snapshot copies retained per evidence-handling policy (cryptographically destroyed at engagement end if the contract requires; otherwise retained encrypted under engagement-specific keys).
- PoC / hunting scripts retained encrypted at rest per [[sop-opsec-plan|OPSEC]].
- Litigation-hold provisions: if the affected tenant is later subject to litigation, prior engagement material can become discoverable. Document engagement decisions accordingly.

### Ethical Research Checklist

**Before engagement:**
- [ ] Written engagement contract (or internal IR activation) defining scope, time, deliverable, disclosure
- [ ] Tenant-admin authorization for read-only access; documented authority for state-changing actions
- [ ] Counsel review of cross-border data-transfer constraints
- [ ] Conflict-of-interest disclosure complete

**During engagement:**
- [ ] Only access in-scope tenants; only act per scope
- [ ] Hash artifacts at acquisition; validate digests where available
- [ ] Maintain chain-of-custody record per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]
- [ ] No pivots into adversary infrastructure
- [ ] No disclosure to non-engagement parties without explicit authorization

**After engagement:**
- [ ] Report delivered per contract
- [ ] Notification clocks (GDPR / SEC / state laws / sectoral) met under counsel direction
- [ ] Snapshot copies / log exports / analysis artifacts handled per evidence-retention policy
- [ ] Engagement IAM roles and access keys rotated / revoked

---

## 20. External & Reference Resources

**CSP-specific forensics documentation:**
- AWS — CloudTrail User Guide — https://docs.aws.amazon.com/awscloudtrail/
- AWS — IR Service Documentation — https://docs.aws.amazon.com/security-ir/ [verify 2026-04-27]
- AWS Customer Incident Response Team (CIRT) blog — https://aws.amazon.com/security/aws-customer-incident-response-team/ [verify 2026-04-27]
- Microsoft — Security Operations / IR Guide — https://learn.microsoft.com/security/operations/
- Microsoft — Sentinel Documentation — https://learn.microsoft.com/azure/sentinel/
- Microsoft — Defender for Cloud Documentation — https://learn.microsoft.com/azure/defender-for-cloud/
- Microsoft Incident Response (DART) blog — https://www.microsoft.com/security/blog/topic/microsoft-incident-response/ [verify 2026-04-27]
- Google Cloud — Logging / Audit — https://cloud.google.com/logging/docs
- Google Cloud — Security Command Center — https://cloud.google.com/security-command-center/docs
- Google Cloud — Chronicle Documentation — https://cloud.google.com/chronicle/docs [verify 2026-04-27]
- Mandiant blog (Google-owned) — https://www.mandiant.com/resources/blog [verify 2026-04-27]

**Standards and frameworks:**
- NIST SP 800-86 — Guide to Integrating Forensic Techniques into Incident Response
- NIST SP 800-53 / 800-171 — Security and Privacy Controls
- NIST SP 800-61 — Computer Security Incident Handling Guide
- NIST IR 8517 — Cloud-Native Application Protection [verify 2026-04-27]
- ISO/IEC 27037 — Identification, collection, acquisition, and preservation of digital evidence
- ISO/IEC 27041 — Investigative process assurance
- ISO/IEC 27042 — Analysis and interpretation
- ISO/IEC 27043 — Incident investigation principles and processes
- CSA Cloud Controls Matrix — https://cloudsecurityalliance.org/research/cloud-controls-matrix/
- CIS Benchmarks (AWS / Azure / GCP / EKS / AKS / GKE) — https://www.cisecurity.org/cis-benchmarks
- MITRE ATT&CK for Cloud — https://attack.mitre.org/matrices/enterprise/cloud/
- MITRE ATT&CK for Containers — https://attack.mitre.org/matrices/enterprise/containers/
- ENISA — Cloud Forensics Resources — https://www.enisa.europa.eu/ [verify 2026-04-27]
- Berkeley Protocol (UN OHCHR 2022) — for human-rights / open-source intelligence dimensions where applicable

**Open-source projects and tools:**
- Cartography — https://github.com/cartography-cncf/cartography
- Steampipe — https://steampipe.io
- Cloud Custodian — https://cloudcustodian.io
- Falco — https://falco.org
- Tetragon — https://tetragon.io
- CloudGrappler — https://github.com/Permiso-io-tools/CloudGrappler [verify 2026-04-27]
- Stratus Red Team — https://github.com/DataDog/stratus-red-team
- Sigma — https://github.com/SigmaHQ/sigma
- Prowler — https://github.com/prowler-cloud/prowler
- ScoutSuite — https://github.com/nccgroup/ScoutSuite
- Velociraptor — https://docs.velociraptor.app
- AVML — https://github.com/microsoft/avml
- WinPmem — https://github.com/Velocidex/WinPmem
- Volatility 3 — https://github.com/volatilityfoundation/volatility3
- OCSF (Open Cybersecurity Schema Framework) — https://schema.ocsf.io/

**Training and certification:**
- SANS FOR509 — Enterprise Cloud Forensics and Incident Response [verify 2026-04-27]
- SANS FOR578 — Cyber Threat Intelligence
- Offensive Security — for cloud-pentesting / detection-evasion adjacent skills (cross-link to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]])
- AWS — Security Specialty / CIRT Track
- Microsoft — SC-200 / SC-100 (Security Operations Analyst / Cybersecurity Architect)
- Google Cloud — Professional Cloud Security Engineer

**Research and commentary:**
- Permiso Security blog — https://permiso.io/blog [verify 2026-04-27]
- DataDog Security Labs blog — https://securitylabs.datadoghq.com/ [verify 2026-04-27]
- Wiz Threat Research — https://www.wiz.io/blog [verify 2026-04-27]
- Orca Security blog — https://orca.security/resources/blog/ [verify 2026-04-27]
- Lacework Labs (now Fortinet FortiCNAPP) — [verify 2026-04-27]
- Christophe Tafani-Dereeper blog — https://blog.christophetd.fr/ [verify 2026-04-27]
- Rami McCarthy / Securosis cloud-research — [verify 2026-04-27]
- Nick Frichette ("Hacking the Cloud") — https://hackingthe.cloud/ [verify 2026-04-27]

**Incident catalogues and case studies:**
- Cloud Security Alliance — Top Threats reports — https://cloudsecurityalliance.org/research/topics/top-threats/
- Verizon DBIR — annual incident analysis (cloud breakouts each year) — https://www.verizon.com/business/resources/reports/dbir/
- CrowdStrike Global Threat Report — annual — https://www.crowdstrike.com/global-threat-report/
- Mandiant M-Trends — annual — https://www.mandiant.com/m-trends [verify 2026-04-27]
- Sysdig Cloud-Native Security and Usage Reports — annual [verify 2026-04-27]

---

**Version:** 1.0
**Last Updated:** 2026-04-27
**Review Frequency:** Quarterly (CSP control-plane API field renames, retention defaults, managed-Kubernetes audit-log structure, and cloud-native threat-detection product feature drift on a quarterly cadence; classical DFIR fundamentals and evidence-discipline are slower)
