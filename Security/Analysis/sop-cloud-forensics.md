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
updated: 2026-10-30
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
- **Log-tampering detection** — CloudTrail digest validation (SHA-256 hash chain), CloudTrail Lake immutability posture, AWS Config history snapshot, Azure storage immutable blob + WORM, GCP log sinks + organization-level aggregated exports, deletion-event detection across providers. [verify 2026-10-30]
- **Container-runtime forensics on managed Kubernetes** — EKS / AKS / GKE control-plane (apiserver) audit logs, ECR / GCR / ACR pull events, runtime detection feeds (Falco, GuardDuty Runtime Monitoring, Defender for Cloud Defender for Containers, Security Command Center / Container Threat Detection), node-level artifacts (containerd / CRI-O / Docker shim).
- **Evidence preservation for cloud volumes** — EBS snapshot for forensics with hash-chain integrity, Azure managed-disk snapshot, GCP persistent-disk snapshot, encrypted-snapshot handling, cross-account / cross-region snapshot copy for evidence isolation.
- **Cross-cloud correlation** — multi-cloud incidents are routine; this SOP enumerates the correlation surface (federated identity, cross-cloud egress, common attacker tooling).
- **Cloud-native IR tooling** — AWS Detective + Athena + Macie, Azure Sentinel + Defender for Cloud, Google Security Operations (Google SecOps, formerly Chronicle) + Security Command Center, plus open-source (Cartography, Steampipe, Cloud Custodian, CloudGrappler, Falco, Stratus Red Team for purple-team validation). [verify 2026-10-30]

### Hard exclusions (out of scope)

- **SaaS-tenant identity / collaboration plane.** Microsoft 365 Unified Audit Log (UAL), Google Workspace Admin SDK / Reports API, Okta System Log, Slack Discovery / Audit Logs, Salesforce Setup Audit Trail, Box / Dropbox / Atlassian admin trails, and OAuth consent-grant abuse all live in the [[sop-saas-log-forensics|SaaS Log Forensics]] SOP. The line: if the artifact is about identity / collaboration / messaging at the application tenant level, route to [[sop-saas-log-forensics|SaaS Log Forensics]]. If it is about IaaS resources (compute, storage, network, IAM) at the cloud-provider tenant level, it belongs here. Hybrid cases (Entra ID sign-ins that triggered an Azure-resource-plane action) are bridged by §7 IAM Forensics.
- **Email header / SPF / DKIM / DMARC / wire-recall / BEC scenario reconstruction.** Routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. OAuth-consent BEC variants route to [[sop-saas-log-forensics|SaaS Log Forensics]]. Scope is a deliberate split: this SOP does not duplicate header-forensics tradecraft.
- **Offensive cloud testing.** Pre-engagement enumeration, IAM-privesc methodology, lateral movement, persistence, exfil tradecraft live in [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]]. Forensic readers benefit from understanding the offensive playbook (it is the threat model) but should not derive offensive instructions from this SOP.
- **General host / disk / memory forensics.** Image acquisition, memory acquisition (LiME / AVML / WinPmem), MFT / USN / Prefetch / Amcache / ShimCache parsing, Volatility 3 plugins, and timeline construction all live in [[sop-forensics-investigation|Digital Forensics Investigation]]. This SOP layers on top: a snapshot-derived volume is mounted and parsed using forensics-investigation methodology; the cloud-specific surface is the snapshot-creation, integrity, and chain-of-custody discipline, not the offline parsing.
- **Smart-contract / on-chain forensics.** Web3 / blockchain post-exploit fund tracing routes to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]; mixer-defeat tradecraft routes to [[../../Investigations/Techniques/sop-mixer-tracing|Mixer & Privacy-Pool Tracing]]; smart-contract code review routes to [[sop-smart-contract-audit|Smart Contract Audit]]. Cloud-resident crypto-mining / wallet-stealer payloads are dual-routed: malware artifacts to [[sop-malware-analysis|Malware Analysis]], on-chain consequences to the investigations track.
- **Container / Kubernetes offensive testing.** Pod escapes, RBAC abuse, admission-controller bypass, runtime exploitation route to [[../Pentesting/sop-container-k8s-pentest|Container & Kubernetes Pentesting]] (referenced by [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]]). This SOP covers control-plane audit-log forensics and runtime-detection artifact collection only.

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
- [ ] **Provider legal process where the customer cannot authorize collection on their own** — for cross-tenant evidence (tenant-A user is suspect, tenant-B is victim, both reside on the same provider) the provider's law-enforcement portal is the route. AWS, Microsoft, and Google publish LE request guidelines and require subpoena / warrant / MLAT depending on data type. [verify 2026-10-30]
- [ ] **Cross-border data residency review.** EU data subjects, healthcare records (HIPAA), card data (PCI), and government cloud (GovCloud / Azure Government / GCP Assured Workloads) all carry residency / sovereignty constraints. Verify under counsel before exporting log data to investigator-controlled storage outside the source region — see [[sop-legal-ethics|Legal & Ethics]].
- [ ] **Disclosure pathway agreed.** Who receives interim findings; who receives the final report; what gets published; whether regulators / customers / law enforcement get notified and on what timeline. Notification clocks are jurisdiction-specific (GDPR Art. 33: 72h to supervisory authority; SEC cyber-disclosure rule for material incidents; state breach-notification laws; sectoral rules for finance / health). Verify per-incident under counsel. [verify 2026-10-30]
- [ ] **Counterparty awareness.** When the affected workload is multi-tenant or the customer shares infrastructure with downstream consumers, decide who learns of the engagement and when.
- [ ] **CSP support-case opened where useful.** Provider IR support (AWS Support, Azure Rapid Response, Google Cloud IR) can unlock collection paths (CloudTrail Lake queries where the account already has event data stores — Lake closed to new customers on 2026-05-31, Sentinel data retrieval, log-sink reconstruction) that customer-side tooling cannot. Open the support case under an executive sponsor's identity, not the investigator's, so the audit trail attributes the action correctly. [verify 2026-10-30]

### Lab Environment Requirements

- **Dedicated investigator account / project / subscription** in each CSP, separate from the affected tenant. Snapshots, log exports, and analysis artifacts land here, never back into the affected tenant. AWS pattern: dedicated `forensics-<engagement-id>` account in the same Organization (or external if the affected Org is under suspicion); Azure pattern: dedicated subscription under a dedicated management group; GCP pattern: dedicated project under a dedicated folder.
- **Investigator workstation** isolated from production: disk-encrypted laptop or dedicated VM, no shared credential vault with other engagements, no auto-sync of artifacts to corporate storage, dedicated `aws/azure/gcloud` CLI profiles per engagement.
- **Encrypted-at-rest investigator storage.** All exported logs, snapshot copies, parsed artifacts, and notes encrypted with engagement-specific keys. Cross-region copy of the engagement bucket / storage account / Cloud Storage bucket for resilience.
- **Time-sync discipline.** All analysis systems running NTP / chrony to a known source; time-zone normalized to UTC end-to-end; investigator note timestamps use ISO 8601 / RFC 3339 with explicit `Z` suffix per [[../../Investigations/Techniques/sop-collection-log|Collection Log]].
- **Network-isolation discipline.** No direct outbound from the investigator workstation to the suspect tenant beyond the audited collection paths. If the adversary is plausibly observing the customer tenant, treat all collection paths as monitored and discipline what queries you run accordingly — see [[sop-opsec-plan|OPSEC]] for investigator-side hygiene.
- **CSP CLI versions pinned per engagement.** Record `aws --version`, `az version`, `gcloud version` at engagement start; CLI behavior changes between minor versions (default region, output format, default credential resolution order).
- **Read-only IAM by default.** Investigator role grants `*Read*` / `*List*` / `*Describe*` / `*Get*` / `*Lookup*` actions; any action that mutates state requires an explicit, documented authorization step. Use AWS managed policies `arn:aws:iam::aws:policy/SecurityAudit` or `arn:aws:iam::aws:policy/ReadOnlyAccess`, Azure `Reader` + `Security Reader`, GCP `roles/iam.securityReviewer` + `roles/logging.viewer` as starting points, narrowed per engagement. [verify 2026-10-30]

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
| AWS | CloudTrail management events | 90 days in Event history (free) | Trail to S3 (configurable, often years); CloudTrail Lake event data store (default 366 days / max 3,653 days under one-year extendable retention pricing; fixed 2,557 days under seven-year retention pricing) — closed to new customers since 2026-05-31, see §4.2 [verify 2026-10-30] |
| Azure | Activity Log | 90 days in portal | Diagnostic settings export to Log Analytics workspace (configurable), Event Hubs, or Storage Account [verify 2026-10-30] |
| GCP | Cloud Audit Logs — Admin Activity | 400 days, free, cannot be disabled | Log sinks to Cloud Storage / BigQuery / Pub/Sub for longer / different retention [verify 2026-10-30] |

### 3.2 Data Plane

Resource-level access — S3 `GetObject`, Azure Blob `Get Blob`, GCS object reads, RDS / Azure SQL / Cloud SQL queries. Data-plane logging is **opt-in and expensive** in all three CSPs:

| CSP | Data-plane log | Default state | Notes |
|---|---|---|---|
| AWS | CloudTrail data events; S3 Server Access Logging; VPC Flow Logs | Off | Per-bucket / per-Lambda / per-DynamoDB-table opt-in; high volume |
| Azure | Resource Logs (per-service `Diagnostic Settings`) | Off | Each resource type publishes its own `category`; storage / SQL / Key Vault all separate [verify 2026-10-30] |
| GCP | Cloud Audit Logs — Data Access | Off (except for some BigQuery defaults) | Per-service opt-in; can be filtered by principal to reduce volume [verify 2026-10-30] |

If data-plane logging was off at the time of the incident, the data-access reconstruction is bounded by what control-plane evidence (e.g., temporary credentials minted, VPC traffic) can imply. Document this gap explicitly in the report — it is frequently the largest evidentiary limitation in cloud cases.

### 3.3 Identity Plane

Authentication, authorization, and federation events. Where a user signed in from, what MFA assertion was used, what role was assumed, and what cross-tenant trust was traversed.

| CSP | Identity log | Notes |
|---|---|---|
| AWS | CloudTrail (sign-in via STS / IAM Identity Center / federated SAML); IAM Identity Center logs | STS `AssumeRole`, `AssumeRoleWithSAML`, `AssumeRoleWithWebIdentity` are the assume-role-chain anchor events |
| Azure | Microsoft Entra ID sign-in logs; Entra ID audit logs | Sign-in logs cover interactive + non-interactive + service principals; audit logs cover directory changes [verify 2026-10-30] |
| GCP | Cloud Identity / Workspace Login Audit — reaches Cloud Logging as organization-level Data Access audit logs (org `_Required` bucket) only if Workspace data sharing with Google Cloud is enabled; otherwise collect it Workspace-side; IAM `setIamPolicy` events | Federated identity (Workforce Identity / Workload Identity Federation) issues short-lived tokens visible at consumption [verify 2026-10-30] |

Identity-plane events frequently sit in a different log destination than control-plane events — Entra ID sign-in logs are not the same store as Activity Log; Workspace login audit reaches Cloud Logging only at organization scope, and only when data sharing is on. Both must be collected.

### 3.4 Runtime Plane

Process / network / file-system events inside running compute (EC2, VMs, GCE, container pods, Lambda, Functions, Cloud Run). Runtime visibility depends on what the customer deployed:

- **Agentless host telemetry** — CSP runtime detection (GuardDuty Runtime Monitoring, Defender for Cloud Defender for Servers / Defender for Containers, Security Command Center Container Threat Detection / VM Threat Detection), Wiz / Lacework FortiCNAPP (Fortinet) / Orca / Sysdig SaaS — varies per customer. [verify 2026-10-30]
- **Agent-based EDR** — CrowdStrike Falcon, SentinelOne, Microsoft Defender for Endpoint, Carbon Black, Elastic Defend.
- **Open-source** — Falco for container / Linux runtime; auditd for Linux syscall; Sysmon for Windows.
- **Provider-native logs** — VPC Flow Logs (AWS), virtual network flow logs (Azure; legacy NSG flow logs retire 2027-09-30), VPC Flow Logs (GCP), all at the network edge; serverless-runtime logs (Lambda CloudWatch Logs, Functions Application Insights, Cloud Run / Cloud Run functions Cloud Logging). [verify 2026-10-30]

The runtime plane is where classic host / disk / memory forensics applies (see [[sop-forensics-investigation|Digital Forensics Investigation]]); cloud-specific tradecraft is the snapshot-acquisition path (§11).

### 3.5 Per-CSP Terminology Crosswalk

Cross-cloud incidents demand a shared vocabulary. The same concept gets different names per CSP:

| Concept | AWS | Azure | GCP |
|---|---|---|---|
| Tenant boundary | Account | Tenant + Subscription | Organization + Project |
| Identity directory | IAM + IAM Identity Center | Microsoft Entra ID | Cloud Identity |
| Resource-action audit | CloudTrail | Activity Log + Resource Logs | Cloud Audit Logs |
| Sign-in audit | CloudTrail (AssumeRole*) | Entra ID sign-in logs | Cloud Identity login audit |
| SIEM / analytics | Security Lake + Athena + Detective | Microsoft Sentinel | Google Security Operations (formerly Chronicle) / Security Command Center [verify 2026-10-30] |
| Threat detection | GuardDuty | Defender for Cloud | Security Command Center (Standard / Premium; Enterprise tier deprecated, shuts down 2027-05-21) [verify 2026-10-30] |
| Asset inventory | AWS Config + Resource Explorer | Azure Resource Graph | Cloud Asset Inventory |
| Identity federation | IAM Identity Center / OIDC / SAML | Microsoft Entra External ID; Microsoft Entra workload identity federation | Workforce Identity / Workload Identity Federation [verify 2026-10-30] |

---

## 4. AWS — IaaS-Plane Forensics

### 4.1 CloudTrail Collection

CloudTrail is the canonical AWS audit trail. It records management events (control-plane API calls), data events (resource-level access — opt-in), network activity events (API calls through VPC endpoints — opt-in), and Insights events (anomalous-rate detection — opt-in). [verify 2026-10-30]

```bash
# Confirm trails configured and where they write [verify 2026-10-30]
aws cloudtrail describe-trails --include-shadow-trails
aws cloudtrail get-trail-status --name <trail-name>
aws cloudtrail get-event-selectors --trail-name <trail-name>      # which data events are captured
aws cloudtrail list-channels                                       # CloudTrail Lake event-data-store channels

# Lookup recent management events via the API (90-day window; one lookup attribute per call) [verify 2026-10-30]
aws cloudtrail lookup-events \
    --start-time 2026-04-01T00:00:00Z --end-time 2026-04-27T00:00:00Z \
    --lookup-attributes AttributeKey=Username,AttributeValue=<suspect-iam-user>

# Lookup by event name (action-driven hunting)
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=ConsoleLogin
aws cloudtrail lookup-events \
    --lookup-attributes AttributeKey=EventName,AttributeValue=AssumeRole

# Pull underlying CloudTrail logs from S3 (gzipped JSON, ~5-min batches per region per account) [verify 2026-10-30]
# Management + data events sit under CloudTrail/; repeat for CloudTrail-Insight/, CloudTrail-NetworkActivity/ and CloudTrail-Aggregated/ if enabled
aws s3 sync \
    s3://<cloudtrail-bucket>/AWSLogs/<account-id>/CloudTrail/ /evidence/cloudtrail/ \
    --exclude "*" --include "*/2026/04/*"

# Extract a single event for inspection
gunzip -c /evidence/cloudtrail/.../some-event.json.gz | jq .

# Hash the export at acquisition (chain-of-custody)
find /evidence/cloudtrail -type f -name '*.json.gz' \
    | xargs -I{} sha256sum {} > /evidence/cloudtrail.sha256
```

### 4.2 CloudTrail Lake (Existing Customers Only — Closed to New Customers 2026-05-31)

CloudTrail Lake is AWS's first-party SQL-queryable event data store. It closed to new customers on 2026-05-31 and now receives only critical bug fixes and security updates; trails, Insights and aggregated events are unaffected. Use it only when the affected account already has event data stores: retention is 366 days by default / 3,653 days max (one-year extendable retention pricing) or a fixed 2,557 days (seven-year retention pricing), and account-level event data stores do not ingest accounts added to the Organization after the change. AWS points to Amazon CloudWatch as the successor (historical EDS data can be imported with `aws logs create-import-task`; events before 2023 are not migrated — query them in Lake or move them to S3 first). For new engagements, rely on trails to S3 (§4.1 / §4.3) or CloudWatch. [verify 2026-10-30]

```bash
# List event data stores [verify 2026-10-30]
aws cloudtrail list-event-data-stores

# Run a SQL query against Lake (CloudTrail Lake's SQL is a Trino SELECT subset) [verify 2026-10-30]
aws cloudtrail start-query --query-statement \
    "SELECT eventTime, userIdentity.arn, eventName, sourceIPAddress, requestParameters
     FROM <eds-id>
     WHERE eventTime > '2026-04-01 00:00:00.000'
       AND userIdentity.arn LIKE '%<suspect-principal>%'
     ORDER BY eventTime"

# Retrieve results [verify 2026-10-30]
aws cloudtrail get-query-results --query-id <query-id>
```

### 4.3 Athena over Trail Logs in S3 (Default Self-Service Path)

With CloudTrail Lake closed to new customers, Athena over the trail's S3 logs is the default self-service SQL path. Either create a non-partitioned table from the CloudTrail console (Event history → Create Athena table; not available for organization trails) or run the partition-projection DDL AWS documents, which adds daily partitions automatically (no `ALTER TABLE ADD PARTITION`). [verify 2026-10-30]

```sql
-- AWS partition-projection DDL, one Region per table; repeat under another table name per Region in scope [verify 2026-10-30]
-- Source: https://docs.aws.amazon.com/athena/latest/ug/create-cloudtrail-table-partition-projection.html
-- Organization trails write under AWSLogs/<org-id>/<account-id>/CloudTrail/: adjust both S3 paths (AWS "organization wide trail" page)
CREATE EXTERNAL TABLE cloudtrail_logs(
    eventversion STRING,
    useridentity STRUCT<
        type: STRING,
        principalid: STRING,
        arn: STRING,
        accountid: STRING,
        invokedby: STRING,
        accesskeyid: STRING,
        username: STRING,
        onbehalfof: STRUCT<
             userid: STRING,
             identitystorearn: STRING>,
        sessioncontext: STRUCT<
            attributes: STRUCT<
                mfaauthenticated: STRING,
                creationdate: STRING>,
            sessionissuer: STRUCT<
                type: STRING,
                principalid: STRING,
                arn: STRING,
                accountid: STRING,
                username: STRING>,
            ec2roledelivery:string,
            webidfederationdata: STRUCT<
                federatedprovider: STRING,
                attributes: map<string,string>>
        >
    >,
    eventtime STRING,
    eventsource STRING,
    eventname STRING,
    awsregion STRING,
    sourceipaddress STRING,
    useragent STRING,
    errorcode STRING,
    errormessage STRING,
    requestparameters STRING,
    responseelements STRING,
    additionaleventdata STRING,
    requestid STRING,
    eventid STRING,
    readonly STRING,
    resources ARRAY<STRUCT<
        arn: STRING,
        accountid: STRING,
        type: STRING>>,
    eventtype STRING,
    apiversion STRING,
    recipientaccountid STRING,
    serviceeventdetails STRING,
    sharedeventid STRING,
    vpcendpointid STRING,
    vpcendpointaccountid STRING,
    eventcategory STRING,
    addendum STRUCT<
      reason:STRING,
      updatedfields:STRING,
      originalrequestid:STRING,
      originaleventid:STRING>,
    sessioncredentialfromconsole STRING,
    edgedevicedetails STRING,
    tlsdetails STRUCT<
      tlsversion:STRING,
      ciphersuite:STRING,
      clientprovidedhostheader:STRING>
  )
PARTITIONED BY (
   `timestamp` string)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS INPUTFORMAT 'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://<cloudtrail-bucket>/AWSLogs/<account-id>/CloudTrail/<region>'
TBLPROPERTIES (
  'projection.enabled'='true',
  'projection.timestamp.format'='yyyy/MM/dd',
  'projection.timestamp.interval'='1',
  'projection.timestamp.interval.unit'='DAYS',
  'projection.timestamp.range'='2026/01/01,NOW',
  'projection.timestamp.type'='date',
  'storage.location.template'='s3://<cloudtrail-bucket>/AWSLogs/<account-id>/CloudTrail/<region>/${timestamp}');

-- Hunt for ConsoleLogin events without MFA (additionalEventData.MFAUsed is the string "Yes" / "No") [verify 2026-10-30]
-- eventTime is ISO 8601 UTC ("2026-04-27T18:30:58Z"): use a half-open range so all of 27 April is included
SELECT eventTime, userIdentity.arn, sourceIPAddress, additionalEventData
FROM cloudtrail_logs
WHERE eventName = 'ConsoleLogin'
  AND eventTime >= '2026-04-01T00:00:00Z' AND eventTime < '2026-04-28T00:00:00Z'
  AND json_extract_scalar(additionalEventData, '$.MFAUsed') = 'No';

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

GuardDuty produces threat findings derived from CloudTrail, VPC Flow Logs, DNS query logs, EKS audit logs, S3 data events, RDS login events, EBS malware scans, Runtime Monitoring (EKS, ECS on Fargate, EC2; not EKS on Fargate) [verify 2026-10-30]. Findings are themselves forensic artifacts.

```bash
# Pull all GuardDuty findings in the time window (updatedAt is epoch milliseconds;
# 1775001600000 = 2026-04-01T00:00:00Z, from date -u -d @1775001600) [verify 2026-10-30]
aws guardduty list-detectors
aws guardduty list-findings --detector-id <id> \
    --finding-criteria '{"Criterion": {"updatedAt": {"GreaterThanOrEqual": 1775001600000}}}'
aws guardduty get-findings --detector-id <id> --finding-ids <id-list>
```

Amazon Security Lake consolidates multi-source security data (CloudTrail management and data events, VPC Flow Logs, Route 53 resolver query logs, EKS audit logs, WAFv2 logs, Security Hub CSPM findings — which carry GuardDuty findings — and custom sources) in OCSF / Apache Parquet on S3, queryable from Athena, OpenSearch, and partner SIEMs [verify 2026-10-30]. For forensics, Security Lake's value is the **normalized schema** (OCSF) which makes cross-source queries simpler than per-source SerDes.

### 4.5 VPC Flow Logs (Network-Plane Evidence)

VPC Flow Logs capture IP-level connection metadata (5-tuple, accept / reject, packet / byte count). They sit in S3 or CloudWatch Logs.

```bash
# Confirm flow logs are configured per VPC / subnet / ENI [verify 2026-10-30]
aws ec2 describe-flow-logs

# Sync to investigator S3 (or directly to Athena over S3) [verify 2026-10-30]
aws s3 sync s3://<flow-logs-bucket>/AWSLogs/<acct>/vpcflowlogs/<region>/2026/04/ \
    /evidence/vpc-flow-logs/
```

```sql
-- Athena query (assumes external table created over flow logs); parentheses keep the time bound on both branches [verify 2026-10-30]
SELECT *
FROM vpc_flow_logs
WHERE (srcaddr = '<suspect-ip>' OR dstaddr = '<suspect-ip>')
  AND start >= 1775001600  -- epoch seconds = 2026-04-01T00:00:00Z
ORDER BY start;
```

### 4.6 S3 Server Access Logging

S3 Server Access Logs record per-object access (HTTP method, requester, request URI, response code, bytes, referer, user agent). They are separate from CloudTrail data events and live in a customer-owned target bucket. [verify 2026-10-30]

```bash
# Confirm logging configured for a specific bucket [verify 2026-10-30]
aws s3api get-bucket-logging --bucket <suspect-bucket>

# Sync the access log objects
aws s3 sync s3://<log-target-bucket>/<log-prefix>/ /evidence/s3-access-logs/
```

### 4.7 IAM Access Analyzer + Config

`AWS Config` captures resource-state history (every change recorded as a configuration item). IAM Access Analyzer surfaces over-permissioned roles and external-trust relationships. Both are forensic adjuncts:

```bash
# Pull Config history for a specific resource [verify 2026-10-30]
aws configservice get-resource-config-history \
    --resource-type AWS::IAM::Role --resource-id <role-id> \
    --earlier-time 2026-04-01T00:00:00Z

# Access Analyzer findings (current state, not historical); list-findings covers external-access analyzers only [verify 2026-10-30]
aws accessanalyzer list-analyzers
aws accessanalyzer list-findings --analyzer-arn <arn>
# Internal-access and unused-access analyzers require ListFindingsV2
aws accessanalyzer list-findings-v2 --analyzer-arn <arn>
```

### 4.8 Macie (Data Classification)

Macie scans S3 buckets for sensitive data (PII, credentials, financial records). For a data-exfil investigation, Macie's prior scan results indicate which buckets held high-value data — even if the exfil itself was not logged.

```bash
# List finding IDs, then fetch full details [verify 2026-10-30]
aws macie2 list-findings
aws macie2 get-findings --finding-ids <id-list>
```

---

## 5. Azure — IaaS-Plane Forensics

### 5.1 Activity Log (Subscription Control Plane)

Activity Log records subscription-scoped management operations, service-health events, alerts, autoscale, recommendations, and policy events. Default retention is 90 days; durable retention requires diagnostic settings export. [verify 2026-10-30]

```bash
# Recent subscription-scope operations [verify 2026-10-30]
az monitor activity-log list \
    --start-time 2026-04-01T00:00:00Z --end-time 2026-04-27T00:00:00Z \
    --max-events 1000 --output json > activity-log.json

# Filter by caller / resource group
az monitor activity-log list --caller <upn-or-spn-id> --offset 30d
az monitor activity-log list --resource-group <rg-name> --offset 30d

# Where the Activity Log is exported (subscription-scope diagnostic settings: Log Analytics / Event Hubs / Storage) [verify 2026-10-30]
az monitor diagnostic-settings subscription list --subscription <subscription-id>
```

### 5.2 Microsoft Entra ID (Identity Plane)

Entra ID sign-in and audit logs are the canonical source for identity-compromise reconstruction. They are **separate** from Activity Log — both must be collected.

```bash
# Graph sign-in export needs Microsoft Entra ID P1/P2; v1.0 returns interactive (and successful federated) user sign-ins only [verify 2026-10-30]
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/auditLogs/signIns?\$filter=createdDateTime ge 2026-04-01T00:00:00Z&\$top=999"

# All four sign-in types (interactive, non-interactive, service principal, managed identity) need the beta signInEventTypes filter
az rest --method GET \
    --uri "https://graph.microsoft.com/beta/auditLogs/signIns?\$filter=(createdDateTime ge 2026-04-01T00:00:00Z) and signInEventTypes/any(t: t eq 'interactiveUser' OR t eq 'nonInteractiveUser' OR t eq 'servicePrincipal' OR t eq 'managedIdentity')&\$top=999"

# Service-principal sign-ins specifically (often where compromise hides) [verify 2026-10-30]
az rest --method GET \
    --uri "https://graph.microsoft.com/beta/auditLogs/signIns?\$filter=signInEventTypes/any(t:t eq 'servicePrincipal')&\$top=999"

# Directory audit logs (role assignments, app registrations, conditional-access changes) [verify 2026-10-30]
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?\$filter=activityDateTime ge 2026-04-01T00:00:00Z"

# OAuth consent grants (high-signal for OAuth-abuse BEC and adversary persistence) [verify 2026-10-30]
az rest --method GET \
    --uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants"
```

> **SaaS hand-off note.** OAuth consent abuse, mailbox-rule creation, M365 UAL, and app-token issuance routes to [[sop-saas-log-forensics|SaaS Log Forensics]]. Entra ID sign-in / audit logs are dual-routed: identity events that triggered Azure-resource-plane actions (e.g., a compromised service principal that ran VMs) belong here in §5; identity events that triggered Microsoft 365 application-tier actions (mailbox access, SharePoint reads, Teams DM exfil) belong to [[sop-saas-log-forensics|SaaS Log Forensics]]. The boundary is the resource the action targeted, not the identity itself.

### 5.3 Resource Logs (Per-Service Diagnostic Logs)

Each Azure service emits its own Resource Logs categories — Storage Account `StorageRead` / `StorageWrite` / `StorageDelete`; Key Vault `AuditEvent`; SQL Database `SQLSecurityAuditEvents`; Network Security Group `NetworkSecurityGroupEvent` / `NetworkSecurityGroupRuleCounter` (NSG *flow* logs, `NetworkSecurityGroupFlowEvent`, are a separate Network Watcher feature retiring 2027-09-30 — see §5.7); etc. They route to a Log Analytics workspace, an Event Hub (for SIEM), or a Storage Account (cheapest long-term). [verify 2026-10-30]

```bash
# List diagnostic settings for a specific resource [verify 2026-10-30]
az monitor diagnostic-settings list --resource <resource-id>

# Query Log Analytics workspace via KQL (--workspace takes the workspace GUID) [verify 2026-10-30]
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
// KQL — multi-source identity-pivot query; each table names the actor differently [verify 2026-10-30]
// SigninLogs UserPrincipalName, AuditLogs InitiatedBy.user.userPrincipalName, AzureActivity Caller, OfficeActivity UserId
union isfuzzy=true
    SigninLogs, AuditLogs, AzureActivity, OfficeActivity
| where TimeGenerated >= datetime(2026-04-01) and TimeGenerated < datetime(2026-04-28)
| where UserPrincipalName =~ "<suspect-upn>" or Caller =~ "<suspect-upn>" or UserId =~ "<suspect-upn>"
    or tostring(InitiatedBy.user.userPrincipalName) =~ "<suspect-upn>"
| project TimeGenerated, Type, OperationName, Operation, IPAddress, CallerIpAddress, ClientIP, ResultDescription
| order by TimeGenerated asc

// KQL — service-principal sign-ins by credential and source IP (AADServicePrincipalSignInLogs, not SigninLogs) [verify 2026-10-30]
AADServicePrincipalSignInLogs
| where TimeGenerated > ago(7d)
| summarize count() by ServicePrincipalName, ServicePrincipalId, IPAddress, Location, ServicePrincipalCredentialKeyId
| order by count_ desc
```

### 5.5 Defender for Cloud + Defender XDR

Defender for Cloud is Azure's CSPM / CWPP / runtime-detection product (formerly Azure Security Center, Azure Defender). Findings (Microsoft.Security `SecurityAlerts`) are forensic artifacts.

```bash
# List recent security alerts [verify 2026-10-30]
az security alert list --output json
```

Defender XDR (the Microsoft 365 + Azure unified XDR pane) is the umbrella over Defender for Endpoint / Identity / Cloud / Office. Cross-product correlation lives there; KQL via the advanced-hunting endpoint.

### 5.6 Storage Immutability for Tamper Resistance

Azure Storage supports **immutable blob storage** (legal hold / time-based retention via Azure Storage WORM) — blobs cannot be deleted or overwritten while a policy is in effect, but an **unlocked** time-based policy can itself be shortened or deleted by an admin, so lock it after testing (Microsoft recommends within 24 hours). A locked policy can only be extended. Use a legal hold when the retention end is unknown [verify 2026-10-30]. For evidence buckets, this is the per-blob deletion-resistance equivalent of S3 Object Lock.

```bash
# Create an unlocked time-based retention policy (--period is in days) [verify 2026-10-30]
az storage container immutability-policy create \
    --account-name <evidence-account> --container-name evidence \
    --period 365 --resource-group <rg>

# Lock it: locked policies cannot be shortened or deleted, only extended [verify 2026-10-30]
az storage container immutability-policy lock \
    --account-name <evidence-account> --container-name evidence \
    --resource-group <rg> --if-match "*"
```

### 5.7 Virtual Network / NSG Flow Logs (Network-Plane Evidence)

NSG flow logs capture L4 metadata at the Network Security Group level; they retire on 2027-09-30 and new NSG flow logs can no longer be created. Their replacement, virtual network flow logs (JSON `category: FlowLogFlowEvent`), is enabled per virtual network, subnet or NIC and also records Azure Virtual Network Manager security-admin rule decisions and encryption state. Both land in a Storage Account and are queryable via Traffic Analytics (Log Analytics workspace). At retirement Azure deletes the NSG flow log resources but not records already written to storage [verify 2026-10-30].

```bash
# Lists NSG and virtual network flow log resources for the region's Network Watcher [verify 2026-10-30]
az network watcher flow-log list --location <region>
```

---

## 6. GCP — IaaS-Plane Forensics

### 6.1 Cloud Audit Logs

GCP Cloud Audit Logs split into four streams:

| Stream | Default state | Notes |
|---|---|---|
| **Admin Activity** | Always-on, free, 400-day retention, cannot be disabled | Project / org IAM, resource creation / modification / deletion [verify 2026-10-30] |
| **Data Access** | Off by default (except some BigQuery defaults), billable, 30-day default retention | Per-API opt-in via `setIamPolicy` audit config [verify 2026-10-30] |
| **System Event** | Always-on, free, 400-day retention | GCP-initiated events (e.g., live migration) [verify 2026-10-30] |
| **Policy Denied** | Always-on, billable (stored in `_Default`), 30-day default retention; cannot be disabled, only excluded | Org policy / VPC service-controls denials [verify 2026-10-30] |

`gcloud logging read` returns only the last 24 hours (`--freshness` defaults to `1d`) unless the filter carries a `timestamp` term or `--freshness` is widened — every query below sets a window. [verify 2026-10-30]

```bash
# IAM-related Admin Activity events [verify 2026-10-30]
gcloud logging read \
    'protoPayload.serviceName="iam.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json > gcp-iam-audit.json

# Sign-in events (Workspace customers, cross-checked with Cloud Identity) [verify 2026-10-30]
gcloud logging read \
    'protoPayload.serviceName="login.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"' \
    --organization=<org-id> --format=json

# Service-account impersonation events (canonical privilege-escalation primitive) [verify 2026-10-30]
gcloud logging read \
    'protoPayload.methodName=~"GenerateAccessToken|GenerateIdToken|SignBlob|SignJwt" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json
```

### 6.2 Log Sinks (Tamper-Resistant Long-Term Retention)

A **log sink** routes log entries to a Logging bucket, Cloud Storage, BigQuery, Pub/Sub, or another project. An **organization-level** sink captures all child projects only when it is an aggregated sink (created with `--include-children`; `includeChildren: true` in `gcloud logging sinks describe` output) — without it, only org-level logs are routed. Investigators should configure or audit the aggregated org sink as a forensic anchor. [verify 2026-10-30]

```bash
# List sinks at org level [verify 2026-10-30]
gcloud logging sinks list --organization=<org-id>

# Aggregated org-level sink to a forensics bucket (audit existence and includeChildren; do not change without authorization)
gcloud logging sinks describe <sink-name> --organization=<org-id>
```

The forensic value of an org-aggregated sink: even if an attacker disables Data Access logs in a single project, the org sink continues to capture Admin Activity, and the act of disabling Data Access logs is itself an Admin Activity event.

### 6.3 BigQuery Pattern (Recommended for Long-Term Forensics)

```sql
-- BigQuery query against audit-log dataset (assumes sink to BigQuery configured; date-sharded tables) [verify 2026-10-30]
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

### 6.4 Google Security Operations (Google SecOps, formerly Chronicle)

Google Security Operations (Google SecOps, formerly Chronicle) [verify 2026-10-30] ingests Cloud Audit Logs, Workspace, third-party sources, and threat intelligence. It is sold to enterprise customers separately from GCP and is the canonical IR query surface for organizations that have it.

```text
# YARA-L 2.0 detection rules (Google SecOps) -- example shape [verify 2026-10-30]
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

Security Command Center (SCC) is GCP's CSPM / threat-detection pane. Container Threat Detection needs the Premium tier; the Enterprise tier was deprecated on 2026-05-21 and shuts down on or after 2027-05-21, when organizations move to Premium [verify 2026-10-30]. Event Threat Detection, VM Threat Detection and Web Security Scanner are further SCC services — confirm per-service tier availability on the SCC service-tiers page.

```bash
# Active high-severity findings across the organization [verify 2026-10-30]
gcloud scc findings list --organization=<org-id> \
    --filter='state="ACTIVE" AND severity="HIGH"' \
    --format=json
```

### 6.6 VPC Flow Logs

```bash
# Confirm flow logs enabled per subnet
gcloud compute networks subnets describe <subnet-name> --region=<region>

# Query flow logs in Cloud Logging (set a window: the default is the last 24 h) [verify 2026-10-30]
gcloud logging read 'logName="projects/<project>/logs/compute.googleapis.com%2Fvpc_flows" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json
```

### 6.7 Cloud Asset Inventory

Cloud Asset Inventory tracks resource state across projects with a 35-day create / update / delete history [verify 2026-10-30]; keep anything older by exporting it (feeds to Pub/Sub, exports to BigQuery). Useful for detecting "this resource existed at time T but not at time T+1" without re-running enumeration.

```bash
# Org-wide resource search [verify 2026-10-30]
gcloud asset search-all-resources --scope=organizations/<org-id>
# History needs --content-type and one of --project / --organization; --start-time must be within the last 35 days [verify 2026-10-30]
gcloud asset get-history --project=<project> --asset-names=<asset> --content-type=resource \
    --start-time="$(date -u -d '34 days ago' +%Y-%m-%dT%H:%M:%SZ)" --end-time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
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
-- userIdentity.sessionContext.sessionIssuer.arn names the role [verify 2026-10-30]

-- Step 2: find the AssumeRole event that minted that session
SELECT eventTime, userIdentity.arn, userIdentity.principalId,
       requestParameters, responseElements, sourceIPAddress
FROM cloudtrail_logs
WHERE eventName = 'AssumeRole'
  AND responseElements LIKE '%<session-name>%'
  AND eventTime > '<some-prior-window>';

-- Step 3: walk back recursively until userIdentity.type IN ('IAMUser', 'Root', 'SAMLUser', 'WebIdentityUser', 'IdentityCenterUser', 'FederatedUser') [verify 2026-10-30]
```

`AssumeRoleWithSAML` and `AssumeRoleWithWebIdentity` events anchor federated identity to the originating IdP. The IdP linkage sits in `userIdentity.identityProvider` / `userIdentity.userName` and in `responseElements` (`subject`, `issuer`, `nameQualifier` for SAML; `subjectFromWebIdentityToken`, `provider`, `audience` for OIDC); `requestParameters` carries `roleArn`, `principalArn` / `sAMLAssertionID` and session tags. These fields connect the AWS session to the upstream identity provider's audit trail (often Microsoft Entra ID, Okta, or Google Workspace). [verify 2026-10-30]

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
// Service-principal sign-in spikes [verify 2026-10-30]
AADServicePrincipalSignInLogs
| where TimeGenerated > ago(30d)
| summarize count() by ServicePrincipalName, IPAddress
| where count_ > 100

// New federated credential added to a service principal (often persistence); `contains` avoids matching on the dash glyph [verify 2026-10-30]
AuditLogs
| where OperationName contains "Certificates and secrets management"
| extend AppId = tostring(TargetResources[0].id)
| project TimeGenerated, InitiatedBy, AppId, AdditionalDetails

// Managed-identity sign-ins (token requests); high volume from a single resource is unusual [verify 2026-10-30]
AADManagedIdentitySignInLogs
| where TimeGenerated > ago(30d)
| summarize count() by ServicePrincipalName, ResourceDisplayName, IPAddress
```

### 7.4 GCP — Service-Account Impersonation Chains

GCP's privilege-pivot is the `iam.serviceAccountTokenCreator` role, which lets one principal mint short-lived tokens for another service account. Reconstruct the impersonation chain via `protoPayload.methodName` events. [verify 2026-10-30]

```bash
# Find all impersonation events in window (request.name = projects/-/serviceAccounts/<minted-sa-email>) [verify 2026-10-30]
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

```sql
-- AWS side -- WIF assumptions (Athena: requestParameters / responseElements are JSON strings) [verify 2026-10-30]
SELECT eventTime, userIdentity.userName,
       json_extract_scalar(responseElements, '$.provider') AS idp,
       json_extract_scalar(responseElements, '$.subjectFromWebIdentityToken') AS sub,
       json_extract_scalar(responseElements, '$.audience') AS aud,
       json_extract_scalar(requestParameters, '$.roleArn') AS role_arn,
       sourceIPAddress
FROM cloudtrail_logs
WHERE eventName = 'AssumeRoleWithWebIdentity'
  AND eventTime >= '2026-04-01T00:00:00Z';

-- GitHub Actions side (where the WIF originated) -- pair on the OIDC `sub` claim (responseElements.subjectFromWebIdentityToken / userIdentity.userName) and issuer (responseElements.provider / userIdentity.identityProvider) [verify 2026-10-30]
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
# Enumerate all enabled regions (the customer may have opted into non-default regions) [verify 2026-10-30]
aws account list-regions --region-opt-status-contains ENABLED ENABLED_BY_DEFAULT

# Per-region pass: lookup events (--max-items caps output; the API pages 50 at a time) [verify 2026-10-30]
for r in $(aws account list-regions --region-opt-status-contains ENABLED ENABLED_BY_DEFAULT --output text --query 'Regions[].RegionName'); do
    echo "=== Region: $r ==="
    aws cloudtrail lookup-events --region $r --max-items 100 \
        --start-time 2026-04-01T00:00:00Z \
        --lookup-attributes AttributeKey=Username,AttributeValue=<suspect-iam-user>
done

# Per-region resource enumeration via Resource Explorer (if customer has it configured) [verify 2026-10-30]
aws resource-explorer-2 list-views

# Multi-region trail confirmation -- a single trail with `IsMultiRegionTrail=true` captures all regions
aws cloudtrail describe-trails --query 'trailList[?IsMultiRegionTrail==`true`]'
```

CloudTrail's Event history (the 90-day free lookup) is **per-region**; if the trail is not multi-region, only the trail-defined region's events land in S3. For a non-multi-region trail customer, the region sweep is the only way to see the full picture. [verify 2026-10-30]

### 8.2 Azure Region Sweep

```bash
# Activity Log is subscription-scoped, not region-scoped — single query covers all regions in subscription
# Resource Logs via diagnostic settings are per-resource; the region matters only at the resource level

# Enumerate all locations with deployed resources
az resource list --query '[].location' --output tsv | sort -u
```

```kusto
// KQL — surface activity per resource; AzureActivity has no documented location column, so map
// _ResourceId to a region with `az resource list --query '[].{id:id, location:location}'` [verify 2026-10-30]
AzureActivity
| where TimeGenerated > ago(30d)
| summarize count() by _ResourceId, OperationNameValue
```

### 8.3 GCP Region Sweep

```bash
# Cloud Audit Logs are global (or org-aggregated) -- single sink covers all regions
# Per-resource logs land in the resource's region

# Enumerate all regions with deployed compute
gcloud compute instances list --format='value(zone)' | sort -u

# Asset inventory for global view (asset list takes --project / --folder / --organization, not --scope) [verify 2026-10-30]
gcloud asset list --project=<project> --asset-types=compute.googleapis.com/Instance
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

CloudTrail trails optionally produce **digest files** — delivered hourly, each holding the SHA-256 hash of every log file delivered in that hour, signed (SHA-256 with RSA) with a CloudTrail-owned per-Region private key (not KMS) and chained to the previous digest [verify 2026-10-30]. Validation is built into the CLI:

```bash
# Validate a trail's digest chain over a window [verify 2026-10-30]
aws cloudtrail validate-logs \
    --trail-arn arn:aws:cloudtrail:us-east-1:<acct>:trail/<trail-name> \
    --start-time 2026-04-01T00:00:00Z --end-time 2026-04-27T00:00:00Z

# Output: every log file's hash matched the digest, or named files where the chain broke
```

A broken chain indicates either log deletion, log modification, or digest deletion. The digest files themselves should be in a separate, locked-down bucket (S3 Object Lock recommended).

### 9.2 AWS — CloudTrail Lake Immutability

CloudTrail Lake event-data-stores are append-only by design — events cannot be edited or deleted within retention. The retention period itself can be reduced (which deletes events outside the new retention) — the act of reducing retention is itself a CloudTrail event. Lake has been closed to new customers since 2026-05-31; existing event data stores keep operating (§4.2). [verify 2026-10-30]

```sql
-- Detect Lake retention reduction (UpdateEventDataStore parameter RetentionPeriod, in days) [verify 2026-10-30]
-- Lake stores requestParameters as a map: read keys with element_at(); keys are camelCase in AWS's Lake examples -- confirm on one sample event
SELECT eventTime, userIdentity.arn, element_at(requestParameters, 'retentionPeriod') AS retentionPeriod
FROM <lake-event-data-store>
WHERE eventName = 'UpdateEventDataStore';

-- Detect trail / Lake deletion or stop attempts
SELECT eventTime, userIdentity.arn, eventName
FROM <lake-event-data-store>
WHERE eventName IN ('DeleteTrail', 'StopLogging', 'DeleteEventDataStore', 'PutEventSelectors');
```

### 9.3 AWS — S3 Object Lock for Evidence Buckets

Object Lock in **Compliance mode** prevents deletion (even by root) for the retention period [verify 2026-10-30]; Governance mode requires `s3:BypassGovernanceRetention` permission for deletion. For evidence and CloudTrail digest buckets, Compliance mode is the right default.

```bash
# Default COMPLIANCE retention on an Object Lock-enabled bucket [verify 2026-10-30]
aws s3api put-object-lock-configuration --bucket <evidence-bucket> \
    --object-lock-configuration '{"ObjectLockEnabled":"Enabled","Rule":{"DefaultRetention":{"Mode":"COMPLIANCE","Days":365}}}'
```

### 9.4 Azure — Immutable Storage and Diagnostic Setting Changes

Azure's tamper-resistance posture rests on:

- **Immutable Storage policies** on the destination Storage Account containing exported Activity / Resource Logs.
- **Azure Policy** denying `Microsoft.Insights/diagnosticSettings/delete` and `Microsoft.Insights/diagnosticSettings/write` outside an allowed change-management process. [verify 2026-10-30]
- **Microsoft Sentinel analytic rules** on `AzureActivity` where `OperationNameValue` has `Microsoft.Insights/diagnosticSettings/delete` or `/write` — diagnostic-setting changes are Activity Log operations, not Entra `AuditLogs` activities (KQL below). [verify 2026-10-30]

```kusto
// Detect diagnostic-setting disable / delete operations [verify 2026-10-30]
AzureActivity
| where OperationNameValue has "Microsoft.Insights/diagnosticSettings"
| where ActivityStatusValue in ("Started", "Succeeded")
| project TimeGenerated, OperationNameValue, Caller, ResourceGroup, _ResourceId

// Detect Log Analytics workspace deletion [verify 2026-10-30]
AzureActivity
| where OperationNameValue == "Microsoft.OperationalInsights/workspaces/delete"
```

### 9.5 GCP — Log Sink Changes and Org-Level Aggregation

GCP's tamper-resistance posture rests on:

- **Org-level aggregated log sink** — even if a project's sinks are tampered, the org sink continues capturing.
- **Cloud Storage bucket retention policies** on the sink destination (set retention with `gcloud storage buckets update gs://<sink-bucket> --retention-period=P7Y`) prevent log deletion within the retention window. [verify 2026-10-30]
- **Bucket Lock** makes the retention policy irrevocable (uniform bucket-level access is a separate hardening step). [verify 2026-10-30]

```bash
# Detect org-level sink modifications; --freshness widens the 1-day default to the 400-day _Required window [verify 2026-10-30]
gcloud logging read \
    'protoPayload.methodName=~"google.logging.v2.ConfigServiceV2.(Delete|Update)Sink"' \
    --organization=<org-id> --freshness=400d --format=json
# Project-level sinks: repeat with --project=<project>, or query the aggregated sink's destination

# Check, then lock, the retention policy on the sink destination (gsutil is legacy) [verify 2026-10-30]
gcloud storage buckets describe gs://<sink-bucket> --format="default(retention_policy)"
gcloud storage buckets update gs://<sink-bucket> --lock-retention-period     # irrevocable
```

### 9.6 Cross-CSP Tamper-Indicators (Hunting Patterns)

| Indicator | AWS event(s) | Azure event(s) | GCP event(s) |
|---|---|---|---|
| Audit logging stopped | `StopLogging`, `DeleteTrail` | `Microsoft.Insights/diagnosticSettings/delete` | `google.logging.v2.ConfigServiceV2.DeleteSink` [verify 2026-10-30] |
| Retention reduced | `UpdateEventDataStore` (CloudTrail Lake), bucket lifecycle change | Workspace `retentionInDays` decrease | Sink filter narrowed; bucket retention reduced |
| Encryption-key disabled (logs unreadable) | KMS `DisableKey` on log-encryption KMS key | Key Vault `KeyUpdate` (key disabled) or `KeyDelete` on workspace CMK | Cloud KMS `UpdateCryptoKeyVersion` (state → `DISABLED`) or `DestroyCryptoKeyVersion` on log-bucket key [verify 2026-10-30] |
| Notifications muted | `EventBridge` rule disabled / SNS subscription deleted | Action group disabled / Sentinel analytic rule disabled | Pub/Sub subscription deleted; Cloud Monitoring alert policy disabled |
| Forwarding redirected | `PutEventSelectors` reducing scope; Lambda destination changed | Diagnostic setting target re-pointed | Sink destination changed |

---

## 10. Container & Kubernetes Runtime Artifacts

Managed Kubernetes (EKS / AKS / GKE) splits forensic surfaces between the **cloud-provider control plane** (where managed-Kubernetes audit logs live) and the **node / pod runtime** (where classic host forensics applies, see [[sop-forensics-investigation|Digital Forensics Investigation]]). This SOP owns the cloud-side; pod-internal exploitation methodology lives in [[../Pentesting/sop-container-k8s-pentest|Container & Kubernetes Pentesting]].

### 10.1 Kubernetes Audit Logs (apiserver)

apiserver audit events capture every Kubernetes API request — pod creation, secret access, service-account token issuance, RBAC changes, exec into pods. They are the highest-value k8s-forensic artifact.

```bash
# AWS EKS -- audit logs go to CloudWatch Logs, in kube-apiserver-audit-* streams of the cluster log group [verify 2026-10-30]
aws eks describe-cluster --name <cluster-name> --query 'cluster.logging'
aws logs filter-log-events --log-group-name /aws/eks/<cluster>/cluster \
    --log-stream-name-prefix kube-apiserver-audit --start-time <epoch-ms>

# Azure AKS -- audit logs reach Log Analytics only through a diagnostic setting (categories kube-audit / kube-audit-admin); AKSAudit table in resource-specific mode [verify 2026-10-30]
az monitor diagnostic-settings list --resource <aks-cluster-resource-id>
az monitor log-analytics query --workspace <workspace-id> \
    --analytics-query 'AKSAudit
        | where TimeGenerated >= datetime(2026-04-01)
        | project TimeGenerated, Verb, ObjectRef, User, SourceIps, UserAgent, ResponseStatus'
# In Azure-diagnostics mode the same events land in AzureDiagnostics (Category == "kube-audit", event JSON in log_s)

# GCP GKE -- audit logs go to Cloud Logging under cluster's project; methodName is io.k8s.<group>.<version>.<resource>.<verb> [verify 2026-10-30]
gcloud logging read \
    'resource.type="k8s_cluster" AND timestamp>="2026-04-01T00:00:00Z"
     AND (protoPayload.methodName:"deployments.create" OR protoPayload.methodName:"deployments.update" OR protoPayload.methodName:"deployments.delete")' \
    --project=<project> --format=json
```

### 10.2 High-Value Audit Events

The shorthand below is Kubernetes resource[/subresource] + verb — the audit event's `objectRef.resource`, `objectRef.subresource` and `verb` fields (AKS `AKSAudit`: `ObjectRef`, `Verb`) — not a filter string. GKE encodes them in `protoPayload.methodName`; Google's documented filters include `protoPayload.methodName =~ "io.k8s.core.v1.pods.exec.*"` and `protoPayload.methodName:"io.k8s.authorization.rbac.v1.rolebindings"`. [verify 2026-10-30]

- **`pods/exec` and `pods/attach`** — interactive shell into a running pod. Almost always significant in incident response.
- **`secrets/get` and `serviceaccounts/token`** — credential harvest.
- **`rolebindings.create` / `clusterrolebindings.create`** — privilege grants.
- **`pods.create` with `hostNetwork: true`, `hostPID: true`, `privileged: true`, or `volumes.hostPath` mount of `/`** — host-escape primitives.
- **`networkpolicies.delete`** — east-west isolation removal.
- **`mutatingwebhookconfigurations.create`** — admission-controller injection (persistence + tampering).

### 10.3 Container Image Pull Events

Image pulls are recorded per-CSP at the registry layer:

```bash
# AWS ECR -- pulls appear as BatchGetImage / GetDownloadUrlForLayer [verify 2026-10-30]
aws cloudtrail lookup-events --lookup-attributes \
    AttributeKey=EventSource,AttributeValue=ecr.amazonaws.com

# Azure ACR -- pulls are resource logs (diagnostic-setting category ContainerRegistryRepositoryEvents -> Log Analytics), not Activity Log entries [verify 2026-10-30]
az monitor log-analytics query --workspace <workspace-id> \
    --analytics-query 'ContainerRegistryRepositoryEvents
        | where OperationName contains "Pull"
        | project TimeGenerated, Repository, Tag, Digest, Identity, CallerIpAddress'

# GCP Artifact Registry -- pulls are Data Access entries (enable Data Access audit logs for artifactregistry.googleapis.com) [verify 2026-10-30]
gcloud logging read \
    'protoPayload.serviceName="artifactregistry.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"
     AND (protoPayload.methodName="Docker-GetManifest" OR protoPayload.methodName="Docker-ServeBlob")' \
    --project=<project>
```

A pulled image whose hash differs from prior pulls of the same tag is a supply-chain indicator.

### 10.4 Runtime Detection Sources

- **AWS GuardDuty Runtime Monitoring** for EKS, ECS on Fargate and EC2 (not EKS on Fargate) — a security agent observing OS-level activity (process execution, file access, network connections) [verify 2026-10-30]; findings include process injection, reverse shells, crypto-mining patterns.
- **Microsoft Defender for Containers** (Defender for Cloud plan) — runtime threat protection for Kubernetes clusters, nodes and workloads through the Defender sensor, plus agentless discovery and vulnerability assessment; covers AKS, EKS, GKE Standard and Arc-enabled Kubernetes; alerts are investigable in Microsoft Defender XDR. [verify 2026-10-30]
- **GCP Container Threat Detection** (part of Security Command Center Premium; the Enterprise tier is deprecated and shuts down 2027-05-21) [verify 2026-10-30] — kernel-instrumented detection for GKE.
- **Falco** (CNCF graduated) — open-source runtime detection driven by configurable rules; deployed by the customer; logs to syslog / Falcosidekick / SIEM. [verify 2026-10-30]
- **Tetragon** (CNCF, Cilium) — eBPF-based observability and enforcement. [verify 2026-10-30]

### 10.5 Node-Level Artifacts

When access to the underlying compute node is authorized, classical host forensics applies (see [[sop-forensics-investigation|Digital Forensics Investigation]]). Container-specific artifacts:

- **containerd / CRI-O / Docker shim logs** — journald on systemd nodes (`journalctl -u containerd`), otherwise files under `/var/log` (`/var/log/syslog`, `/var/log/messages`). [verify 2026-10-30]
- **Container layer storage** — `/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/` / `/var/lib/docker/overlay2/` [verify 2026-10-30]. Layer mounts retain the file-system state of running and recently-stopped containers.
- **Kubelet logs** — `journalctl -u kubelet` on systemd nodes, otherwise `.log` files under `/var/log`. [verify 2026-10-30]
- **Pod logs** — under `/var/log/pods/` by default (relocatable with the kubelet `podLogsDir` setting); list the tree rather than assuming the per-pod layout. [verify 2026-10-30]
- **Volume mounts** — host-path mounts and persistent-volume claims with backing storage on the node or attached cloud disks.

---

## 11. Evidence Preservation for Cloud Volumes

When a compromised compute resource needs forensic preservation, the cloud-native path is **snapshot, copy, isolate, hash**. A snapshot is a point-in-time copy (crash-consistent, in AWS and GCP terms): it holds data already written to the volume, not data still cached by the guest OS or applications, so expect an unclean file system and mount without journal replay (§11.1). For a multi-volume EC2 instance, `aws ec2 create-snapshots --instance-specification InstanceId=<instance-id>` takes snapshots that are crash-consistent across all attached volumes. [verify 2026-10-30]

### 11.1 AWS — EBS Snapshot for Forensics

```bash
# Step 1 -- identify the affected instance and its volumes
aws ec2 describe-instances --instance-ids <instance-id> \
    --query 'Reservations[].Instances[].BlockDeviceMappings'

# Step 2 -- create snapshot(s) with descriptive metadata [verify 2026-10-30]
aws ec2 create-snapshot \
    --volume-id vol-<id> \
    --description "Forensic snapshot - case <case-id> - $(date -u +%Y%m%dT%H%M%SZ)" \
    --tag-specifications 'ResourceType=snapshot,Tags=[
        {Key=case,Value=<case-id>},
        {Key=type,Value=forensic},
        {Key=collected_by,Value=<investigator>},
        {Key=collected_at,Value=2026-04-27T00:00:00Z}]'

# Step 3 -- share the snapshot privately with the dedicated forensics account [verify 2026-10-30]
aws ec2 modify-snapshot-attribute \
    --snapshot-id snap-<id> \
    --attribute createVolumePermission \
    --operation-type add \
    --user-ids <forensics-acct-id>
# Then in forensics account: copy, encrypting the copy with a forensics-owned KMS key [verify 2026-10-30]
aws ec2 copy-snapshot \
    --source-region <region> --source-snapshot-id snap-<id> \
    --encrypted --kms-key-id <forensics-kms-key-id> \
    --description "Forensic copy - case <case-id>"

# Step 4 -- create a volume from the copy and attach it to a forensic analysis instance; set the device
# read-only and hash it BEFORE mounting -- plain "-o ro" still replays the ext4 journal / XFS log (writes) [verify 2026-10-30]
# Nitro instances expose EBS volumes as NVMe devices named in no fixed order: use the disk whose SERIAL is the
# volume ID without its hyphen (vol-0abc... lists as vol0abc...); on Xen-based instances /dev/sdf may appear as /dev/xvdf [verify 2026-10-30]
lsblk -o NAME,SERIAL,SIZE,FSTYPE
sudo blockdev --setro /dev/<nvme-disk> /dev/<nvme-disk>p1
sudo sha256sum /dev/<nvme-disk> > /evidence/<case-id>-vol.sha256
sudo mount -o ro,noexec,noload /dev/<nvme-disk>p1 /mnt/evidence    # ext4: noload = no journal replay
# XFS instead: sudo mount -o ro,noexec,norecovery,nouuid /dev/<nvme-disk>p1 /mnt/evidence
# Skipping replay can leave a crash-consistent volume inconsistent: if replay is needed, do it on a second
# volume created from the same snapshot, never on the hashed one [verify 2026-10-30]

# Step 5 -- record chain-of-custody per sop-collection-log
```

For **encrypted volumes**, snapshots inherit the source KMS key. Snapshots encrypted with the default AWS managed key cannot be shared — first `copy-snapshot` them inside the source account to a customer managed key, then share that copy. Sharing a customer-managed-key snapshot also means sharing the key: its key policy must let the forensics account use `kms:DescribeKey`, `kms:CreateGrant`, `kms:GenerateDataKey`, `kms:GenerateDataKeyWithoutPlaintext`, `kms:ReEncrypt` and `kms:Decrypt`; the forensics account then copies the snapshot and encrypts the copy with a KMS key it owns (Step 3). [verify 2026-10-30]

### 11.2 Azure — Managed-Disk Snapshot

```bash
# Create snapshot [verify 2026-10-30]
az snapshot create \
    --resource-group <rg> --name <case-id>-osdisk-snap \
    --source <source-disk-id> \
    --tags case=<case-id> type=forensic collected_by=<investigator>

# Grant time-limited read access: returns a SAS URL that expires after --duration-in-seconds [verify 2026-10-30]
az snapshot grant-access --resource-group <rg> --name <snap-name> --duration-in-seconds 3600

# Download the underlying VHD via the SAS URL [verify 2026-10-30]
azcopy cp "<sas-url>" /evidence/<case-id>-osdisk.vhd

# Hash on download
sha256sum /evidence/<case-id>-osdisk.vhd > /evidence/<case-id>-osdisk.sha256
```

### 11.3 GCP — Persistent-Disk Snapshot

```bash
# Create snapshot [verify 2026-10-30]
gcloud compute snapshots create <case-id>-pd-snap \
    --source-disk=<disk-name> --source-disk-zone=<zone> \
    --description="Forensic snapshot - case <case-id>" \
    --labels=case=<case-id>,type=forensic,collected_by=<investigator>

# Share with the forensics principal -- creating a disk needs compute.snapshots.useReadOnly, which Compute Viewer lacks [verify 2026-10-30]
# Least privilege: a custom role with compute.snapshots.get / list / useReadOnly (roles/compute.storageAdmin
# also works but lets the grantee modify or delete the evidence snapshot) [verify 2026-10-30]
gcloud compute snapshots add-iam-policy-binding <snap-name> \
    --member=serviceAccount:<forensics-project-sa> \
    --role=projects/<source-project>/roles/<snapshot-reader-role>

# In the forensics project (compute.disks.create there): gcloud compute disks create --source-snapshot, attach to a
# forensics VM, then set read-only, hash and mount without journal replay as in §11.1
```

### 11.4 Snapshot Chain-of-Custody

Every snapshot lifecycle event must be logged per [[../../Investigations/Techniques/sop-collection-log|Collection Log]]:

- **Source identification** — original instance / VM / GCE name, region, account / subscription / project, attached volumes / disks at snapshot time, instance state (running / stopped) at snapshot time.
- **Snapshot creation** — timestamp, executing principal, source-volume ID, snapshot ID.
- **Cross-account / cross-region copy** — every transfer logged.
- **Hashing** — SHA-256 (baseline) + SHA3-256 (defensive paired) as soon as the snapshot is downloadable as a single artifact, per [[sop-hash-generation-methods|Hash Generation Methods]]. Recompute and verify before any analysis.
- **Mount discipline** — read-only mount only, with the block device set read-only and journal replay disabled (§11.1); the original snapshot is never modified; analysis happens on a copy or via a read-only block-device mount.
- **Storage location** — investigator-controlled S3 / Storage / GCS, encrypted at rest with a key the suspect tenant cannot access.

### 11.5 Memory Acquisition from Cloud VMs

Live RAM acquisition from a running cloud VM is harder than disk. Options:

- **AWS** — Use an in-instance agent (AVML for Linux, WinPmem for Windows) [verify 2026-10-30] over SSM Session Manager or the in-instance agent already deployed (CrowdStrike RTR, etc.). Stream the memory image to S3 or a forensics SSH tunnel.
- **Azure** — Same agent-based pattern over Azure Bastion / RunCommand / Azure VM Agent.
- **GCP** — Same agent-based pattern over IAP TCP tunneling / OS Login.

Treat hypervisor-level memory snapshots as unavailable unless the CSP documents one for the service in scope; agent-based capture remains the practical path. The AWS Nitro System has no mechanism for any system or person to access EC2 instance memory from the host, so it is not readable from outside the instance. [verify 2026-10-30]

---

## 12. Cross-Cloud Correlation

Multi-cloud incidents are routine — adversaries pivot from a compromised AWS access key to an Azure tenant via the same federated SaaS IdP, or from GCP service-account impersonation to a Workload-Identity-Federated AWS role. Cross-cloud correlation is the integration step that classical single-cloud forensics misses.

### 12.1 Correlation Anchors

- **Federated identity events.** A SAML / OIDC sign-in event in the IdP (Okta, Entra ID, Workspace) pairs with `AssumeRoleWithSAML` / `AssumeRoleWithWebIdentity` / Entra federated-credential token / GCP `GenerateAccessToken` events in the consumer cloud.
- **Workload Identity Federation tokens.** A workload running in cloud A produces an OIDC token; cloud B accepts it and mints a session. Both sides log the event.
- **Common source IPs / ASNs.** Adversaries reuse infrastructure; an IP that signed in to AWS may also appear in Azure sign-in logs.
- **Common user agents.** AWS CLI default user agent `aws-cli/<version>` [verify 2026-10-30], custom Python / Go SDK strings, attacker-tooling fingerprints (Pacu, ScoutSuite, Stratus Red Team, etc.) are detectable across clouds.
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

- **Cartography** ([github.com/cartography-cncf/cartography](https://github.com/cartography-cncf/cartography)) — Neo4j graph of multi-cloud asset and identity relationships; useful for mapping "what could principal X reach" rather than "what did principal X do." [verify 2026-10-30]
- **Steampipe / Powerpipe / Flowpipe** ([steampipe.io](https://steampipe.io)) — SQL over multi-cloud APIs; enables ad-hoc cross-cloud queries. [verify 2026-10-30]
- **CloudGrappler** ([permiso.io](https://permiso.io)) — open-source hunting for known threat-actor TTPs across CloudTrail logs in S3, Azure Storage containers and GCS buckets. [verify 2026-10-30]
- **Sigma** ([github.com/SigmaHQ/sigma](https://github.com/SigmaHQ/sigma)) — vendor-neutral detection rule format with cloud-source rule packs; sigma-cli backends convert it to KQL, Splunk SPL, Elasticsearch, OpenSearch, Google SecOps and others (there is no Athena backend). [verify 2026-10-30]

---

## 13. Cloud-Native IR Tooling

### 13.1 AWS

- **Amazon Detective** — graph-based investigation surface over CloudTrail + VPC Flow + GuardDuty + EKS audit [verify 2026-10-30]. Particularly strong for IAM principal / role-chain visualization.
- **Athena** — SQL over CloudTrail / VPC Flow / WAF / S3 access logs in S3.
- **CloudTrail Lake** — built-in long-term store (§4.2).
- **Security Lake** — OCSF-normalized cross-source store (§4.4).
- **Macie** — sensitive-data classification (§4.8).
- **GuardDuty** — managed threat detection (§4.4).
- **AWS Security Incident Response** — first-party service for preparing for, responding to and recovering from security incidents: automated triage of GuardDuty / Security Hub findings, case handling, and 24/7 access to AWS Security Incident Response engineers. [verify 2026-10-30]

### 13.2 Azure

- **Microsoft Sentinel** — KQL-based SIEM; the canonical forensic query surface for Azure-heavy customers.
- **Defender for Cloud** — CSPM + CWPP + runtime detection; finding feed.
- **Defender XDR** — cross-product (Endpoint + Identity + Cloud + Office) advanced hunting.
- **Microsoft Incident Response (formerly DART)** — Microsoft's in-house IR team available under support contracts. [verify 2026-10-30]

### 13.3 GCP

- **Google SecOps (formerly Chronicle)** — cloud-native SIEM with YARA-L 2.0 detection and 12-month default retention. [verify 2026-10-30]
- **Security Command Center** — CSPM + CWPP; finding feed.
- **BigQuery over log sinks** — most flexible long-term forensic-query surface for GCP-heavy customers.
- **Mandiant** (Google-owned) — IR and threat-intel; available under support contracts. [verify 2026-10-30]

### 13.4 Open-Source / Vendor-Neutral

| Tool | Purpose | Notes |
|---|---|---|
| Cartography | Multi-cloud asset / identity graph (Neo4j) | Exploration and what-if reasoning [verify 2026-10-30] |
| Steampipe | SQL over multi-cloud APIs | Ad-hoc cross-cloud queries [verify 2026-10-30] |
| Cloud Custodian | Policy-as-code remediation engine | Useful for evidence-collection automation [verify 2026-10-30] |
| Falco | Runtime detection (containers / Linux) | CNCF graduated [verify 2026-10-30] |
| Tetragon | eBPF observability + enforcement | Cilium [verify 2026-10-30] |
| CloudGrappler | TTP-based hunting across CloudTrail (S3), Azure Storage and GCS log buckets | Permiso [verify 2026-10-30] |
| Stratus Red Team | Adversary emulation in cloud | Validates detection coverage; not for live exploitation [verify 2026-10-30] |
| Sigma | Detection rule format | Vendor-neutral; sigma-cli backends for KQL, Splunk, Elasticsearch, OpenSearch, Google SecOps and more (no Athena backend) [verify 2026-10-30] |
| Prowler | CSPM scanner with forensic-relevant findings | Multi-CSP [verify 2026-10-30] |
| ScoutSuite | Multi-CSP audit toolkit | Snapshot of misconfigurations [verify 2026-10-30] |
| LiME / AVML / WinPmem | RAM acquisition (run inside cloud VM): LiME is a loadable kernel module built for the running kernel; AVML is a static userland binary (x86_64 and aarch64 release builds) that needs no on-target compilation | See [[sop-forensics-investigation|Digital Forensics Investigation]] [verify 2026-10-30] |
| Velociraptor | Cross-platform endpoint hunting / collection | Works on cloud VMs via agent [verify 2026-10-30] |
| GRR | Live-response framework | Low commit cadence (14 commits in the year to 2026-10-30) but still released — v4.0.0.0 on 2025-12-15 [verify 2026-10-30] |
| KAPE (Kroll Artifact Parser and Extractor) | Triage collection + parsing (Windows) | See [[sop-forensics-investigation|Digital Forensics Investigation]] [verify 2026-10-30] |

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
| Pod escape / RBAC abuse / admission-controller bypass methodology | [[../Pentesting/sop-container-k8s-pentest|Container & Kubernetes Pentesting]] |
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
| Google SecOps (formerly Chronicle) | GCP | Cloud-native SIEM (YARA-L 2.0) [verify 2026-10-30] |
| Security Command Center | GCP | CSPM + threat detection |
| BigQuery (log sink target) | GCP | Long-term log analytics |
| Cloud Asset Inventory | GCP | Resource state history |

### Open-Source / Vendor-Neutral

| Tool | Purpose | Link |
|------|---------|------|
| Cartography | Multi-cloud asset / identity graph (Neo4j) | https://github.com/cartography-cncf/cartography [verify 2026-10-30] |
| Steampipe | SQL over multi-cloud APIs | https://steampipe.io [verify 2026-10-30] |
| Cloud Custodian | Cloud governance / policy-as-code | https://cloudcustodian.io [verify 2026-10-30] |
| Falco | Runtime detection (CNCF) | https://falco.org [verify 2026-10-30] |
| Tetragon | eBPF observability + enforcement (CNCF, Cilium) | https://tetragon.io [verify 2026-10-30] |
| CloudGrappler | TTP-driven cloud-log hunting (Permiso) | https://github.com/Permiso-io-tools/CloudGrappler [verify 2026-10-30] |
| Stratus Red Team | Cloud adversary emulation (DataDog) | https://github.com/DataDog/stratus-red-team [verify 2026-10-30] |
| Sigma | Vendor-neutral detection rule format | https://github.com/SigmaHQ/sigma [verify 2026-10-30] |
| Prowler | CSPM scanner (multi-CSP) | https://github.com/prowler-cloud/prowler [verify 2026-10-30] |
| ScoutSuite | Multi-CSP audit toolkit | https://github.com/nccgroup/ScoutSuite [verify 2026-10-30] |
| Velociraptor | Cross-platform endpoint hunting / collection | https://docs.velociraptor.app [verify 2026-10-30] |
| Volatility 3 | Memory analysis (parent template) | https://github.com/volatilityfoundation/volatility3 [verify 2026-10-30] |
| AVML | Linux RAM acquisition | https://github.com/microsoft/avml [verify 2026-10-30] |
| WinPmem | Windows RAM acquisition | https://github.com/Velocidex/WinPmem [verify 2026-10-30] |
| AzureHound (SpecterOps) / PMapper (NCC Group) | Identity graph extraction (offensive-leaning, useful for understanding adversary view): AzureHound exports Azure data for BloodHound; PMapper evaluates AWS IAM permissions (little activity since 2024-08) | https://github.com/SpecterOps/AzureHound ; https://github.com/nccgroup/PMapper [verify 2026-10-30] |

### Reference / Documentation

| Resource | Purpose |
|----------|---------|
| AWS CloudTrail User Guide | https://docs.aws.amazon.com/awscloudtrail/latest/userguide/ [verify 2026-10-30] |
| Microsoft Security Operations Guide | https://learn.microsoft.com/security/operations/ [verify 2026-10-30] |
| Google Cloud Logging | https://cloud.google.com/logging/docs [verify 2026-10-30] |
| MITRE ATT&CK for Cloud | https://attack.mitre.org/matrices/enterprise/cloud/ [verify 2026-10-30] |
| MITRE ATT&CK for Containers | https://attack.mitre.org/matrices/enterprise/containers/ [verify 2026-10-30] |
| NIST SP 800-86 | Guide to Integrating Forensic Techniques into Incident Response [verify 2026-10-30] |
| NIST SP 800-53 / SP 800-171 | Security and Privacy Controls (800-53) / Protecting Controlled Unclassified Information in Nonfederal Systems and Organizations (800-171 Rev. 3) [verify 2026-10-30] |
| NIST SP 800-201 | NIST Cloud Computing Forensic Reference Architecture (July 2024) — https://csrc.nist.gov/pubs/sp/800/201/final [verify 2026-10-30] |
| CSA Cloud Controls Matrix | https://cloudsecurityalliance.org/research/cloud-controls-matrix/ [verify 2026-10-30] |
| SANS FOR509 — Enterprise Cloud Forensics and Incident Response | https://www.sans.org/cyber-security-courses/enterprise-cloud-forensics-incident-response/ [verify 2026-10-30] |

---

## 16. Risks & Limitations

- **Data-plane logging gaps.** When data events / Resource Logs / Data Access logs were not enabled before the incident, the data-access reconstruction is bounded by what control-plane and network-plane evidence can imply. This is the largest evidentiary limitation in most cloud cases. Document the gap in the report rather than overstating evidence.
- **Retention cliffs.** Default retentions (CloudTrail Event history 90 days, Activity Log 90 days, GCP Cloud Audit Logs Admin Activity 400 days, Data Access 30 days) cover the median incident-discovery timeline (global median dwell time 14 days in M-Trends 2026) but not the long tail of incidents discovered after default retention has expired [verify 2026-10-30]. Customers without long-term log export lose evidence to retention silently. Verify retention end-to-end before promising a reconstruction.
- **Sub-account / sub-tenant boundary visibility.** AWS Organizations service-control policies, Azure management-group hierarchy, and GCP organization policy can restrict cross-tenant log visibility. The investigator's IAM scope must be sufficient for the engagement's visibility needs; insufficient scope is itself a finding to document.
- **Provider-side log latency.** CloudTrail delivers log files within about 5 minutes of an API call on average, with no guaranteed bound [verify 2026-10-30]. Activity Log events lag similarly. GCP Cloud Audit Logs are usually faster but vary per service. Real-time alerting and forensic reconstruction tolerate this differently — the investigator must not infer "the event did not happen" from a same-millisecond gap.
- **Log volume vs query budget.** Long-window cross-region queries against multi-TB log stores are expensive. Athena scan-bytes, CloudTrail Lake event-scan-bytes, BigQuery slot-time, Sentinel ingest GB all bill. Pre-engagement budget conversation with the client.
- **Service-coverage drift.** New CSP services launch monthly; not every service emits structured audit logs at launch. Forensic visibility for the newest services may be limited or completely absent. Confirm per-service event coverage in current CSP documentation.
- **Provider-internal action attribution.** Some events are emitted by the provider's own infrastructure (system maintenance, automated lifecycle actions) and look superficially like adversary activity. Familiarize with the per-service "system" principal patterns before flagging.
- **Cross-cloud cross-correlation latency.** When multiple clouds and multiple SaaS providers are involved, log-export pipelines latency-stack; the unified timeline lags the truth by hours.
- **Evidence integrity end-to-end.** A SHA-256 hash at export proves nothing about the source-side integrity (the log writer could already have been compromised). CloudTrail digest validation, GCP sink immutability, Azure WORM all push the integrity boundary closer to the source — but none push it to the source.
- **Encrypted-volume snapshot key dependency.** If the source KMS key is later revoked (or the source account is closed), the snapshot becomes unreadable even from the forensics account. Re-encrypt with a forensics-controlled key during the cross-account copy.
- **Memory acquisition is hard.** Cloud VM memory is rarely directly readable. Agent-based capture requires advance deployment. Many incidents have no live memory to capture.
- **Court-admissibility of cloud evidence is jurisdiction-dependent.** Cloud-provider declarations, log-integrity attestations, and chain-of-custody form the evidentiary spine. In US federal courts, expert testimony built on that evidence must satisfy FRE 702 (as amended 1 Dec 2023, applying *Daubert*) [verify 2026-10-30]; other forums apply their own expert-evidence rules (verify under counsel). See [[sop-legal-ethics|Legal & Ethics]] for the current jurisdictional framing.
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

**Pattern.** A developer's `~/.aws/credentials` file is exfiltrated via a compromised laptop. The attacker authenticates from a residential-proxy IP, calls `GetCallerIdentity` to confirm, then `RunInstances` in a low-cost region the customer does not historically use, deploys crypto-miners on `c7g.16xlarge` instances [verify 2026-10-30], and sets up an SES-based phishing infrastructure. The customer is alerted by AWS Trust & Safety after the SES reputation impacts the broader AWS region.

**Forensic catch.** §4.1 CloudTrail collection identifies the access key's use; §4.7 IAM Access Analyzer + Config flags the access-key creation history; §7.2 access-key abuse indicators (new IP / ASN, anomalous user agent) confirm. §8.1 region sweep enumerates all regions for resources tied to the suspect access key. §11.1 EBS snapshot preserves the `c7g.16xlarge` boot volumes for malware analysis. §13.1 Detective visualizes the principal-action graph for the report.

**Hand-off.** Cryptocurrency-mining wallet addresses route to [[../../Investigations/Techniques/sop-blockchain-investigation|Blockchain Investigation]]. Phishing infrastructure (sender domains, bait pages) routes to [[sop-email-bec-forensics|Email & BEC Forensics]]. Underlying laptop compromise routes to [[sop-forensics-investigation|Digital Forensics Investigation]] for endpoint disk / memory analysis.

### 18.2 Scenario — Compromised CI/CD Pipeline Pivots via Workload Identity Federation

**Pattern.** A GitHub Actions workflow with broad WIF permission to an AWS account is hijacked via a malicious dependency in the build (typo-squatted package). The malicious code executes during CI, the GitHub OIDC token is exchanged for an AWS session via `AssumeRoleWithWebIdentity`, and the session enumerates Secrets Manager and S3 buckets, exfiltrating customer data.

**Forensic catch.** §4.1 CloudTrail collection identifies the `AssumeRoleWithWebIdentity` event whose `responseElements.subjectFromWebIdentityToken` (mirrored in `userIdentity.userName`) carries the GitHub OIDC token's `sub` claim and whose `responseElements.provider` / `audience` name the GitHub OIDC provider [verify 2026-10-30]; §7.5 cross-cloud WIF reconstruction pairs the AWS session with the GitHub Actions workflow run. §7.1 `AssumeRole` chain reconstruction walks subsequent privilege use. §4.5 VPC Flow Logs identify the data-egress destinations. §12.2 cross-cloud correlation timeline shows the GitHub event → AWS event pairing.

**Hand-off.** Compromised dependency analysis routes to [[sop-malware-analysis|Malware Analysis]]. GitHub-side audit (workflow run, artifact, secret access) routes to [[sop-saas-log-forensics|SaaS Log Forensics]]. Pipeline / supply-chain hardening recommendations route to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] for purple-team validation.

### 18.3 Scenario — GKE Cluster Compromise via Exposed Workload Service Account

**Pattern.** A pod in a GKE cluster mounts the cluster's default service account (rather than a least-privilege workload-identity-bound SA). A web-app vulnerability in the pod (server-side request forgery) lets the attacker reach the GCP metadata server and harvest the service account's token. The token has `roles/storage.admin` at the project level. The attacker enumerates buckets and exfiltrates data.

**Forensic catch.** §6.1 Cloud Audit Logs identify the service-account token use from the pod; §7.4 service-account impersonation forensics reconstructs the chain (in this case, no impersonation — direct token use). §10.1 Kubernetes apiserver audit logs identify the pod's service-account binding and the absence of a Workload Identity binding. §10.4 Container Threat Detection (if enabled) may have flagged the runtime SSRF execution. §6.6 VPC Flow Logs from the GKE pod's egress show the connection to the GCP metadata server (an unusual egress pattern). §11.3 persistent-disk snapshots of the affected pod nodes preserve container layer state.

**Hand-off.** Pod / container exploit methodology (the SSRF itself, container-escape primitives) routes to [[../Pentesting/sop-container-k8s-pentest|Container & Kubernetes Pentesting]]. SSRF web-app-side analysis routes to [[../Pentesting/sop-web-application-security|Web Application Security]]. Bucket-data sensitivity analysis (PII / PHI / regulated data) routes to compliance counsel via [[sop-legal-ethics|Legal & Ethics]] for breach-notification timeline. Hardening recommendation: bind workloads to dedicated service accounts via Workload Identity; disable default service account; deploy [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]] purple-team validation against the new boundary.

### 18.4 Scenario — Adversary Disables Logging Before Action

**Pattern.** An attacker with a high-privilege AWS role first disables CloudTrail logging (`StopLogging`), waits 5 minutes, performs the actions of interest, then re-enables logging (`StartLogging`). The intervening window has no CloudTrail visibility.

**Forensic catch.** §9.1 digest validation immediately flags the gap (the digest chain breaks where logging was off) [verify 2026-10-30]. §9.6 cross-CSP tamper-indicators identify the `StopLogging` / `StartLogging` events themselves (which **do** appear in CloudTrail because they are management events independent of trail-status). Cross-correlation with §4.5 VPC Flow Logs (network-plane, separate from CloudTrail) and §10.4 GuardDuty Runtime Monitoring (runtime-plane, separate) reconstructs adversary action during the blind window from non-CloudTrail telemetry.

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
- [[../Pentesting/sop-container-k8s-pentest|Container & Kubernetes Pentesting]] — pod escapes / RBAC abuse / admission-controller bypass methodology; the offensive counterpart to §10 Container & Kubernetes Runtime Artifacts.

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

---

## Legal & Ethical Considerations

> Canonical jurisdictional framework lives in [[sop-legal-ethics|Legal & Ethics]]. The summary below is operational guidance for cloud-forensics engagements specifically; do not substitute it for the cross-referenced source.

### Authorization

- **Tenant-administrator authorization** is the typical engagement authority. The cloud account / tenant / org owner authorizes the investigator's read-only role and any state-changing actions (snapshot creation, principal disablement). Without it, the investigator's access is unauthorized regardless of the suspect's behavior.
- **Provider legal process** is the route for cross-tenant evidence (tenant A is suspect, tenant B is victim). Subpoena / warrant / MLAT to AWS / Microsoft / Google. Provider-published LE guidelines define the form. [verify 2026-10-30]
- **Cross-jurisdiction authorization.** EU-data, healthcare, payment, and government-cloud workloads can carry residency / sovereignty constraints that limit cross-border evidence transfer even with tenant authorization. CLOUD Act executive agreements (US-UK, US-AU, US-CA in progress, etc.), the Budapest Convention Second Additional Protocol (CETS 224; not yet in force — four of the five required ratifications as of April 2026) and, in the EU, the e-Evidence Regulation (EU) 2023/1543 (European Production and Preservation Orders; applies from 18 August 2026) shape MLAT alternatives. Verify under counsel. [verify 2026-10-30]
- **Engagement scope drift.** Cloud incidents tend to expand mid-engagement (initial scope: one account; mid-engagement scope: an Organization with 30 accounts and three SaaS providers). Any scope expansion needs documented re-authorization.

### Anti-Hacking Statute Framing

Cloud-forensics actions are typically read-only against tenants the investigator is authorized to access — far inside the CFAA / Computer Misuse Act / Cybercrime Directive lines. Specifically:

- **Read-only collection within authorized tenants** — allowed.
- **State-changing actions (snapshot creation, principal disablement, log export, role assumption)** — allowed only when the engagement explicitly authorizes them; document each action with attribution.
- **Pivoting into adversary infrastructure observed during the investigation** — generally **not** authorized. "We saw the attacker's IP — let's scan their VPS" crosses into unauthorized access. Attribution and intelligence are valuable; offensive pivots are not the investigator's job. Route adversary-infrastructure findings through threat-intel channels.
- **Active-defense actions** (sinkholing, beaconing payloads back, credential canaries) — verify under counsel before any deployment; actions framed as "defensive" can be charged as offensive in some jurisdictions.

### Data-Subject and Privacy Considerations

- **GDPR Art. 6 / 9** — processing of personal data during investigation requires a lawful basis; legitimate interest is the typical basis but is balanced against data-subject rights.
- **GDPR Art. 33** — supervisory-authority notification within 72 hours of becoming aware of a personal-data breach. [verify 2026-10-30]
- **GDPR Art. 34** — data-subject notification when the breach is high-risk to the data subjects. [verify 2026-10-30]
- **HIPAA Breach Notification Rule** — covered entities + business associates have 60-day notification windows. [verify 2026-10-30]
- **State breach laws** (US) — varies by state; California (CCPA / CPRA), New York (SHIELD), and many others have specific timelines and requirements.
- **PCI DSS Incident Response Plan** — required for cardholder-data environments; provider notification paths defined.
- **Sectoral rules** — finance (NYDFS Part 500, FFIEC, EBA / DORA), healthcare (HIPAA, NIS2 in EU), telecom (sectoral) — verify per engagement.

### Disclosure Discipline

- Pre-disclosure findings are restricted to the engagement team and the client per the engagement contract.
- Findings affecting third parties (a vendor's credential abused; a customer's API key found in suspect activity; an upstream supply-chain compromise indicator) are escalated through the affected party's security contact, not embedded silently in the client's report.
- CSP coordination is sometimes warranted (provider-resident vulnerability in service surface; widespread credential-leak indicator). AWS Security, MSRC, and Google VRP each publish coordinated-disclosure paths. [verify 2026-10-30]
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
- AWS — CloudTrail User Guide — https://docs.aws.amazon.com/awscloudtrail/latest/userguide/ [verify 2026-10-30]
- AWS — Security Incident Response Documentation — https://docs.aws.amazon.com/security-ir/ [verify 2026-10-30]
- AWS Customer Incident Response Team (CIRT) — https://aws.amazon.com/blogs/security/welcoming-the-aws-customer-incident-response-team/ [verify 2026-10-30]
- Microsoft — Security Operations / IR Guide — https://learn.microsoft.com/security/operations/ [verify 2026-10-30]
- Microsoft — Sentinel Documentation — https://learn.microsoft.com/azure/sentinel/ [verify 2026-10-30]
- Microsoft — Defender for Cloud Documentation — https://learn.microsoft.com/azure/defender-for-cloud/ [verify 2026-10-30]
- Microsoft Security Blog — Incident response (Microsoft Incident Response, formerly DART) — https://www.microsoft.com/en-us/security/blog/topic/incident-response/ [verify 2026-10-30]
- Google Cloud — Logging / Audit — https://cloud.google.com/logging/docs [verify 2026-10-30]
- Google Cloud — Security Command Center — https://cloud.google.com/security-command-center/docs [verify 2026-10-30]
- Google Cloud — Google Security Operations (formerly Chronicle) Documentation — https://cloud.google.com/chronicle/docs [verify 2026-10-30]
- Google Cloud Threat Intelligence blog (Mandiant, Google-owned) — https://cloud.google.com/blog/topics/threat-intelligence [verify 2026-10-30]

**Standards and frameworks:**
- NIST SP 800-86 — Guide to Integrating Forensic Techniques into Incident Response [verify 2026-10-30]
- NIST SP 800-53 (Security and Privacy Controls) / SP 800-171 Rev. 3 (Protecting Controlled Unclassified Information in Nonfederal Systems and Organizations) [verify 2026-10-30]
- NIST SP 800-61 Rev. 3 — Incident Response Recommendations and Considerations for Cybersecurity Risk Management: A CSF 2.0 Community Profile (April 2025; supersedes Rev. 2) — https://csrc.nist.gov/pubs/sp/800/61/r3/final [verify 2026-10-30]
- NIST SP 800-201 — NIST Cloud Computing Forensic Reference Architecture (July 2024) — https://csrc.nist.gov/pubs/sp/800/201/final [verify 2026-10-30]
- ISO/IEC 27037:2012 — Guidelines for identification, collection, acquisition and preservation of digital evidence [verify 2026-10-30]
- ISO/IEC 27041:2015 — Guidance on assuring suitability and adequacy of incident investigative method [verify 2026-10-30]
- ISO/IEC 27042:2015 — Guidelines for the analysis and interpretation of digital evidence [verify 2026-10-30]
- ISO/IEC 27043:2015 — Incident investigation principles and processes [verify 2026-10-30]
- CSA Cloud Controls Matrix — https://cloudsecurityalliance.org/research/cloud-controls-matrix/ [verify 2026-10-30]
- CIS Benchmarks (AWS / Azure / GCP / EKS / AKS / GKE) — https://www.cisecurity.org/cis-benchmarks [verify 2026-10-30]
- MITRE ATT&CK for Cloud — https://attack.mitre.org/matrices/enterprise/cloud/ [verify 2026-10-30]
- MITRE ATT&CK for Containers — https://attack.mitre.org/matrices/enterprise/containers/ [verify 2026-10-30]
- ENISA — Exploring Cloud Incidents (2016; overview of forensic analysis techniques and processes for cloud incidents) — https://www.enisa.europa.eu/publications/exploring-cloud-incidents [verify 2026-10-30]
- Berkeley Protocol (UN OHCHR 2022) — for human-rights / open-source intelligence dimensions where applicable [verify 2026-10-30]

**Open-source projects and tools:**
- Cartography — https://github.com/cartography-cncf/cartography [verify 2026-10-30]
- Steampipe — https://steampipe.io [verify 2026-10-30]
- Cloud Custodian — https://cloudcustodian.io [verify 2026-10-30]
- Falco — https://falco.org [verify 2026-10-30]
- Tetragon — https://tetragon.io [verify 2026-10-30]
- CloudGrappler — https://github.com/Permiso-io-tools/CloudGrappler [verify 2026-10-30]
- Stratus Red Team — https://github.com/DataDog/stratus-red-team [verify 2026-10-30]
- Sigma — https://github.com/SigmaHQ/sigma [verify 2026-10-30]
- Prowler — https://github.com/prowler-cloud/prowler [verify 2026-10-30]
- ScoutSuite — https://github.com/nccgroup/ScoutSuite [verify 2026-10-30]
- Velociraptor — https://docs.velociraptor.app [verify 2026-10-30]
- AVML — https://github.com/microsoft/avml [verify 2026-10-30]
- WinPmem — https://github.com/Velocidex/WinPmem [verify 2026-10-30]
- Volatility 3 — https://github.com/volatilityfoundation/volatility3 [verify 2026-10-30]
- OCSF (Open Cybersecurity Schema Framework) — https://schema.ocsf.io/ [verify 2026-10-30]

**Training and certification:**
- SANS FOR509 — Enterprise Cloud Forensics and Incident Response [verify 2026-10-30]
- SANS FOR578 — Cyber Threat Intelligence [verify 2026-10-30]
- Offensive Security — for cloud-pentesting / detection-evasion adjacent skills (cross-link to [[../Pentesting/sop-cloud-pentest|Cloud Pentesting]])
- AWS — AWS Certified Security – Specialty; AWS CIRT public incident-response workshops — https://aws.amazon.com/blogs/security/aws-cirt-announces-the-release-of-five-publicly-available-workshops/ [verify 2026-10-30]
- Microsoft — SC-200 / SC-100 (Security Operations Analyst / Cybersecurity Architect) [verify 2026-10-30]
- Google Cloud — Professional Cloud Security Engineer [verify 2026-10-30]

**Research and commentary:**
- Permiso Security blog — https://permiso.io/blog [verify 2026-10-30]
- DataDog Security Labs blog — https://securitylabs.datadoghq.com/ [verify 2026-10-30]
- Wiz Threat Research — https://www.wiz.io/blog [verify 2026-10-30]
- Orca Security blog — https://orca.security/resources/blog/ [verify 2026-10-30]
- Lacework Labs (now Fortinet FortiCNAPP) [verify 2026-10-30]
- Christophe Tafani-Dereeper blog — https://blog.christophetd.fr/ [verify 2026-10-30]
- Rami McCarthy (Wiz Research) — https://ramimac.me/ [verify 2026-10-30]
- Nick Frichette ("Hacking the Cloud") — https://hackingthe.cloud/ [verify 2026-10-30]

**Incident catalogues and case studies:**
- Cloud Security Alliance — Top Threats reports — https://cloudsecurityalliance.org/research/working-groups/top-threats [verify 2026-10-30]
- Verizon DBIR — annual incident analysis (cloud breakouts each year) — https://www.verizon.com/business/resources/reports/dbir/ [verify 2026-10-30]
- CrowdStrike Global Threat Report — annual — https://www.crowdstrike.com/global-threat-report/ [verify 2026-10-30]
- Mandiant M-Trends — annual — https://cloud.google.com/security/resources/m-trends [verify 2026-10-30]
- Sysdig Cloud-Native Security and Usage Reports — annual [verify 2026-10-30]

---

**Version:** 1.0
**Last Updated:** 2026-10-30
**Review Frequency:** Quarterly (CSP control-plane API field renames, retention defaults, managed-Kubernetes audit-log structure, and cloud-native threat-detection product feature drift on a quarterly cadence; classical DFIR fundamentals and evidence-discipline are slower)
