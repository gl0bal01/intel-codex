---
type: sop
title: Digital Forensics Investigation SOP
description: "Conduct digital forensics: disk imaging, memory analysis, artifact recovery, timeline creation & chain of custody. Tools: FTK, Autopsy, Volatility."
tags: [sop, forensics, incident-response, dfir, investigation]
template_version: 2026-04-25
updated: 2026-10-30
---

# Digital Forensics Investigation SOP

> **Authorized investigations only.** Proper chain of custody, legal compliance, and evidence preservation required.

---

## Table of Contents

1. [Pre-Investigation Setup](#1-pre-investigation-setup)
2. [Initial Response & Containment](#2-initial-response--containment)
3. [Evidence Collection & Preservation](#3-evidence-collection--preservation)
4. [Analysis Phase](#4-analysis-phase)
5. [Documentation & Reporting](#5-documentation--reporting)
6. [Evidence Storage & Retention](#6-evidence-storage--retention)
7. [Tools Reference](#7-tools-reference)
8. [Legal & Quality Assurance](#8-legal--quality-assurance)
9. [Common Pitfalls](#9-common-pitfalls)
10. [Quick Reference Checklist](#10-quick-reference-checklist)

---

## 1. Pre-Investigation Setup

### Authorization & Legal

**Pre-Investigation Checklist:**
- [ ] Obtain written authorization from legal counsel/management
- [ ] Verify scope and boundaries (systems, time period, data types)
- [ ] Ensure compliance with applicable laws (jurisdiction-specific)
- [ ] Document retention and legal hold requirements
- [ ] Coordinate with HR, Legal, and IT Security teams
- [ ] Establish privilege review protocols (attorney-client, work product)
- [ ] Determine if law enforcement involvement is required

**Legal Considerations:**
- **Fourth Amendment** (US): Government searches require warrant/consent
- **ECPA/Stored Communications Act**: Email and communication privacy
- **GDPR** (EU): Data protection and privacy requirements
- **CFAA**: Computer Fraud and Abuse Act compliance
- **State Laws**: Vary by jurisdiction (e.g., California CCPA)

**Documentation Requirements:**
```text
Authorization Form Must Include:
- Name of authorizing party (CEO, General Counsel, etc.)
- Scope of investigation (specific systems/users/time period)
- Purpose of investigation (incident response, HR, litigation)
- Data handling restrictions (privilege, confidentiality)
- Authorized investigators (names and roles)
- Approval date and signature
```

### Team Assembly

**Roles and Responsibilities:**
- **Lead Investigator**: Overall case management, reporting, expert witness
- **Forensic Analysts**: Evidence collection, analysis, technical documentation
- **Legal Representative**: Privilege review, compliance, admissibility
- **IT/System Admins**: System access, architecture knowledge, technical support
- **HR Representative**: Employee-related investigations, personnel actions
- **External Consultants**: Specialized expertise (mobile, malware, cloud)

**Communication Protocols:**
- Secure communication channels (encrypted email, secure chat)
- Attorney-client privilege for legal discussions
- Need-to-know information sharing
- Documentation of all case-related communications

---

## 2. Initial Response & Containment

### Order of Volatility (RFC 3227)

**Most volatile to least volatile:**
1. CPU registers, cache
2. Routing table, ARP cache, process table, kernel statistics, memory (RAM) [verify 2026-10-30]
3. Temporary file systems
4. Hard disk
5. Remote logging and monitoring data
6. Physical configuration, network topology
7. Archival media (backups, offline storage)

### Immediate Actions

**If system is RUNNING:**
```text
# DO NOT:
❌ Power off the system (loses volatile memory)
❌ Close running applications
❌ Shutdown or restart
❌ Trust system utilities (may be compromised)

# DO:
✅ Photograph the screen
✅ Document running processes and network connections
✅ Capture volatile memory (RAM)
✅ Document system time and timezone
✅ Note logged-in users
```

**If system is OFF:**
```text
# DO NOT:
❌ Power on the system
❌ Boot from internal drives

# DO:
✅ Document physical state (power indicator, physical damage)
✅ Photograph the scene
✅ Secure the system and transport to forensics lab
✅ Boot from forensic media (if required for imaging)
```

### Live Memory Acquisition

**Windows:**
```powershell
# Using FTK Imager [verify 2026-10-30]
FTK Imager.exe → File → Capture Memory
# Output: memdump.mem

# Using Magnet RAM Capture (free; legacy — last release v1.20, Jul 2019) [verify 2026-10-30]
MagnetRAMCapture.exe
# Follow GUI prompts

# Using DumpIt
DumpIt.exe
# Magnet DumpIt for Windows (free; x86/x64/ARM64) writes a full-memory Microsoft crash dump; the vendor does not document the output path, so record where the dump lands [verify 2026-10-30]
```

**Linux:**
```bash
# LiME (Linux Memory Extractor) — kernel module; must be built against the EXACT running kernel
# (uname -r). Pre-build in a clean test VM with matching headers, then load on the target. [verify 2026-10-30]
insmod lime.ko "path=/mnt/usb/memory.lime format=lime"
# Or stream over TCP to investigator host (avoids touching target disk):
insmod lime.ko "path=tcp:4444 format=lime"
# Investigator: nc target 4444 > memory.lime

# AVML (Microsoft, statically linked, no kernel module required — preferred for cloud/containers)
# AVML >= 0.19 needs the `acquire` subcommand; older releases took the output path directly [verify 2026-10-30]
sudo ./avml acquire --compress /mnt/usb/memory.lime.compressed

# With no source given, AVML tries /dev/crash, /proc/kcore and /dev/mem in turn; it cannot acquire if kernel_lockdown is enabled [verify 2026-10-30]
# /dev/mem is filtered by CONFIG_STRICT_DEVMEM on modern kernels; /dev/crash is the Red Hat/Fedora crash driver used where /dev/mem is restricted [verify 2026-10-30]
```

**macOS:**
```bash
# Note: traditional macOS RAM acquisition tooling has degraded. SIP, kernel extension deprecation
# (kexts deprecated since macOS 10.15, kexts using deprecated KPIs not loaded by default since macOS 11,
# third-party kexts on Apple silicon need Reduced Security + explicit approval) [verify 2026-10-30]
# and hypervisor-protected memory regions on Apple Silicon have made full physical RAM capture
# difficult or impossible without DMA / EFI access.
# OSXPmem (Rekall project) is the historical tool. Verify support for the exact macOS major version
# before relying on any RAM-capture tool. [verify 2026-10-30]

# Live triage alternative: collect runtime state without a full RAM image [verify 2026-10-30]
sudo log collect --output sysdiagnose-$(date +%Y%m%d).logarchive    # unified log capture
sudo sysdiagnose -f /tmp/sysdiagnose                                # full diagnostic bundle (heavyweight)

# Volexity Surge Collect (commercial) — vendor advertises Windows/Linux/macOS acquisition; Apple silicon
# support is not stated on the product page, so confirm with the vendor for the target macOS build [verify 2026-10-30]
# osxpmem (Rekall) — last release 2017, unmaintained; Rekall itself is end-of-life [verify 2026-10-30]
```

### System State Documentation

**Capture before imaging:**
```cmd
# Windows (from external USB with forensic tools)
# Parentheses group both commands so date AND time go to the file [verify 2026-10-30]
(date /t && time /t) > system_info.txt
echo %COMPUTERNAME% >> system_info.txt
ipconfig /all >> system_info.txt
netstat -ano >> netstat.txt
tasklist /v >> processes.txt
net user >> users.txt
net localgroup administrators >> admins.txt
```

```bash
# Linux
date -u > system_info.txt
hostname >> system_info.txt
ip addr show >> system_info.txt
ss -tulnp > netstat.txt
ps aux > processes.txt
who > logged_in_users.txt
last > login_history.txt

# macOS
date -u > system_info.txt
hostname >> system_info.txt
ifconfig >> system_info.txt
netstat -an > netstat.txt
ps aux > processes.txt
last > login_history.txt
```

### Network Isolation

**Immediate containment:**
```text
# Physical isolation (preferred)
1. Unplug Ethernet cable
2. Disable Wi-Fi (airplane mode or physical switch)
3. Document MAC address and IP before disconnection

# If remote collection required:
1. Place in isolated VLAN
2. Block internet egress (allow only to collection server)
3. Monitor all network activity during collection
```

### Evidence Identification

**Primary Evidence Sources:**
- [ ] Desktop/laptop computers
- [ ] Mobile devices (phones, tablets)
- [ ] External storage (USB drives, external HDDs)
- [ ] Servers (physical and virtual)
- [ ] Network attached storage (NAS)
- [ ] Cloud storage accounts
- [ ] IoT devices (smart home, wearables)

**Secondary Evidence Sources:**
- [ ] System logs (Windows Event Logs, syslog, auth.log)
- [ ] Network logs (firewall, IDS/IPS, proxy, DNS)
- [ ] Application logs (web server, database, email)
- [ ] Cloud service logs (AWS CloudTrail, Azure Activity Log)
- [ ] Backup systems
- [ ] SIEM/Security monitoring data
- [ ] Network packet captures (PCAP files)

**Witness Information:**
- [ ] Interview IT staff who discovered incident
- [ ] Document user statements (written/recorded)
- [ ] Obtain administrative credentials (encrypted storage)
- [ ] Identify subject matter experts for systems involved

---

## 3. Evidence Collection & Preservation

### Chain of Custody

**Evidence Labeling:**
```text
Label Format:
CASE-[YYYY-MM-DD]-[EVIDENCE_TYPE]-[###]

Example:
CASE-2025-10-05-LAPTOP-001
CASE-2025-10-05-USB-002
CASE-2025-10-05-PHONE-003
```

**Chain of Custody Form (Required Fields):**
- [ ] Case number and case name
- [ ] Evidence identifier (unique label)
- [ ] Description of evidence (make, model, serial number)
- [ ] Date and time of collection (UTC)
- [ ] Collector name and signature
- [ ] Location of collection (physical address, room number)
- [ ] Condition of evidence (powered on/off, physical damage)
- [ ] Transfer log (who received evidence, when, purpose)

**Physical Evidence Handling:**
```text
# Immediate steps upon collection:
1. Photograph evidence in situ (before touching)
2. Apply evidence label with unique identifier
3. Document serial numbers, MAC addresses, physical condition
4. Place in anti-static bag (electronics)
5. Seal bag with tamper-evident tape
6. Sign and date the seal
7. Store in climate-controlled, secure location
8. Log in evidence management system
```

### Disk Imaging & Acquisition

**Write Blockers (ALWAYS USE):**
- **Hardware Write Blockers**: Tableau, WiebeTech, CRU
- **Software Write Blockers**: Linux live boot (read-only mount)

**Creating Forensic Images:**

**Using dd (Linux):**
```bash
# Identify target disk
lsblk
fdisk -l

# Create forensic image with write blocker attached [verify 2026-10-30]
dd if=/dev/sdb of=/mnt/evidence/case001-disk.dd bs=512 conv=noerror,sync status=progress

# Create split image (for FAT32 file systems with 4GB limit) [verify 2026-10-30]
dd if=/dev/sdb bs=512 conv=noerror,sync | split -b 4000M - /mnt/evidence/case001-disk.dd.

# Generate hash simultaneously. sha256sum labels stdin "-"; sed swaps in the image name so that
# `cd /mnt/evidence && sha256sum -c case001-disk.dd.sha256` works [verify 2026-10-30]
dd if=/dev/sdb bs=512 conv=noerror,sync | tee /mnt/evidence/case001-disk.dd | sha256sum | sed 's|-$|case001-disk.dd|' > /mnt/evidence/case001-disk.dd.sha256
```

**Using dc3dd (Enhanced dd for forensics):**
```bash
# Image with built-in hashing: hof= hashes the output too and verifies it against the input hash
# (plain of= hashes the input only) [verify 2026-10-30]
dc3dd if=/dev/sdb hof=/mnt/evidence/case001-disk.dd hash=sha256 hash=md5 log=/mnt/evidence/case001.log

# Source hash verification (read-only re-hash to confirm acquisition matches the live source).
# of=/dev/null is required: with no output option dc3dd writes the data to stdout [verify 2026-10-30]
dc3dd if=/dev/sdb of=/dev/null hash=sha256 hash=md5 log=/mnt/evidence/verify.log
```

**Using FTK Imager (Windows/GUI):** [verify 2026-10-30]
```text
1. File → Create Disk Image
2. Select Source: Physical Drive
3. Choose drive from list
4. Add destination: Evidence Image (E01 format recommended)
5. Fill in case information and evidence details
6. Select "Verify images after they are created"
7. Start imaging
8. Save hash report
```

**Using Guymager (Linux/GUI):**
```text
1. Launch Guymager
2. Right-click target drive → Acquire image
3. File format: Expert Witness Format (E01) or dd [verify 2026-10-30]
4. Fill case metadata
5. Enable "Calculate SHA-256" and "Verify image after acquisition"
6. Start acquisition
```

### Image Formats

**E01 (EnCase Evidence File):**
- Compressed
- Includes metadata
- Industry standard
- Supports case information embedded

**DD (Raw Image):**
- Exact bit-for-bit copy
- No compression
- Largest file size
- Universal compatibility

**AFF (Advanced Forensics Format):**
- Open source
- Compressed
- Metadata support
- Splitting support
- Legacy: AFFLIB v3 is in maintenance mode while work on AFFv4 continues; prefer E01 or raw for new acquisitions [verify 2026-10-30]

### Hash Verification

> **Algorithm choice.** SHA-256 is the minimum baseline for new evidence (NIST FIPS 180-4). MD5 is broken by practical collisions (Wang et al. 2004) and SHA-1 is broken by the SHAttered collision (2017) — record them only as a *secondary* hash for legacy compatibility. Never rely on MD5 or SHA-1 alone in court. See [[sop-hash-generation-methods|Hash Generation Methods]] for full guidance, integration with FTK/EnCase/Autopsy, and verification scripts. [verify 2026-10-30]

**Generate hashes:**
```bash
# SHA-256 (primary — required)
sha256sum case001-disk.dd > case001-disk.dd.sha256

# MD5 + SHA-1 (secondary — legacy RDS 2.x sets, AV/threat-intel lookups, older case files) [verify 2026-10-30]
md5sum case001-disk.dd > case001-disk.dd.md5
sha1sum case001-disk.dd > case001-disk.dd.sha1

# Verify later (sha256sum -c reads "<hash>  <filename>" format directly) [verify 2026-10-30]
sha256sum -c case001-disk.dd.sha256
```

**Windows (PowerShell):**
```powershell
# SHA-256 [verify 2026-10-30]
Get-FileHash -Path C:\Evidence\case001-disk.dd -Algorithm SHA256 | Format-List

# MD5
Get-FileHash -Path C:\Evidence\case001-disk.dd -Algorithm MD5 | Format-List

# Save to file
Get-FileHash -Path C:\Evidence\case001-disk.dd -Algorithm SHA256 | Out-File C:\Evidence\case001-disk.dd.sha256.txt
```

### Mobile Device Acquisition

> **Tool versioning.** Vendor tools are tightly version-locked to the OS — Cellebrite UFED, Magnet AXIOM, GrayKey, and Elcomsoft iOS Forensic Toolkit publish per-iOS / per-Android support matrices that change every minor release. Always check the vendor matrix against the target's exact OS build before acquisition; an iOS 17.4 device may be unsupported by a UFED build that handled 17.3. [verify 2026-10-30]

**Preparation:**
```text
Immediate isolation
1. Place device in Faraday bag (blocks cellular/Wi-Fi/Bluetooth/UWB)
2. If device is on: enable airplane mode FIRST, then disable Wi-Fi and Bluetooth explicitly (on iOS, Airplane Mode turns off all radios except Bluetooth, and Wi-Fi/Bluetooth can be re-enabled inside it) [verify 2026-10-30]
3. Document battery level — connect to charger inside Faraday environment
4. Photograph device (all sides, screen contents, IMEI/serial sticker if exposed)
5. Note any passwords/PINs (with user consent and legal authority)
6. Keep device powered on if possible — locked devices that reboot enter BFU (Before First Unlock) state where most data remains encrypted
```

**Acquisition state matters (iOS):**
- **AFU (After First Unlock)** — device has been unlocked at least once since boot; user data keys are loaded in memory; logical and most filesystem extractions possible
- **BFU (Before First Unlock)** — device has rebooted and not been unlocked; only a limited keybag is available; most user data remains encrypted at rest

Preserve AFU state by keeping the device powered and avoiding reboots until the imaging plan is final.

**Acquisition Methods:**

**Logical Acquisition** — extracts active files via vendor APIs (iTunes/Finder backup, ADB). Requires device cooperation (unlocked, paired, backup not encrypted with unknown password):

```bash
# iOS logical backup (libimobiledevice) [verify 2026-10-30]
idevice_id -l                            # confirm device is paired
idevicebackup2 backup --full /path/to/backup

# Encrypted iTunes backup (richer artifact set than unencrypted). Encryption is a device setting:
# turning it on changes the device, so document it. -i prompts for the password. [verify 2026-10-30]
# Hash the first backup before running this; use a separate target directory (backups land in DIRECTORY/<UDID>/). [verify 2026-10-30]
idevicebackup2 -i encryption on
idevicebackup2 backup --full /path/to/backup-encrypted
# Decrypt later with: iphone-backup-decrypt, or load in Magnet AXIOM as an image and enter the backup password [verify 2026-10-30]

# Android — modern (recommended): ADB pull of accessible app data on rooted/dev devices
adb devices
adb shell pm list packages -f            # enumerate package paths
adb pull /sdcard/                        # external storage
adb pull /data/data/<package>/           # rooted only

# Android — legacy `adb backup`: since Android 12 it excludes app data for apps targeting API 31+
# unless the app sets android:debuggable=true, so modern devices yield little app data. Prefer vendor
# tooling; use Android Backup Extractor (`abe.jar`) only for legacy backups. [verify 2026-10-30]
adb backup -all -apk -shared -system -f backup.ab   # Android 12+: no app data for apps targeting API 31+ unless debuggable
```

**Filesystem / Physical Acquisition:**
- **Filesystem (iOS)** — checkm8-based tools (checkra1n family, palera1n) on A11-and-earlier hardware reach a fuller filesystem; A12+ devices generally require GrayKey or comparable LE-grade tooling [verify 2026-10-30]
- **Physical (Android)** — chip-off, JTAG, ISP, EDL (Qualcomm Emergency Download), or vendor exploits via Cellebrite/MSAB; recovers deleted data and full userdata partition
- **Advanced iOS** — Cellebrite Inseyets (positioned as the successor to Premium; no sunset date announced), GrayKey, Elcomsoft iOS Forensic Toolkit; capability is OS-version-bounded and often LE-restricted [verify 2026-10-30]

**Vendor Tools:**
- **Cellebrite Inseyets (Inseyets.UFED)** — all-in-one extraction and analysis suite; unlocks sold separately; replaces UFED Ultimate (UFED4PC), Physical Analyzer 7 and Premium, which Cellebrite's FAQ lists for discontinuation (no sunset date announced); requires a Cellebrite Max dongle. Check per-release support notes for the target OS build [verify 2026-10-30]
- **Magnet AXIOM (Process / Examine)** — mobile, computer, cloud and vehicle sources [verify 2026-10-30]
- **MSAB XRY** — physical, logical and cloud extraction; app decoding updated in every release [verify 2026-10-30]
- **Oxygen Forensic Detective** — broad app coverage including encrypted messengers
- **Elcomsoft iOS Forensic Toolkit** — checkm8-based imaging on supported iPhones; keychain extraction [verify 2026-10-30]
- **GrayKey (Magnet/Grayshift)** — passcode brute-force and full-file-system on supported iOS [verify 2026-10-30]

**Open-source parsing (run AFTER vendor extraction):**
- **iLEAPP** ([github.com/abrignoni/iLEAPP](https://github.com/abrignoni/iLEAPP)) — parses iOS extractions: KnowledgeC, biome, PowerLog, Photos.sqlite, Health, app artifacts; HTML/TSV/KML reports [verify 2026-10-30]
- **ALEAPP** ([github.com/abrignoni/ALEAPP](https://github.com/abrignoni/ALEAPP)) — Android counterpart: usagestats, accessibility, Wi-Fi history, app artifacts [verify 2026-10-30]
- **VLEAPP / RLEAPP** ([github.com/abrignoni/VLEAPP](https://github.com/abrignoni/VLEAPP), [github.com/abrignoni/RLEAPP](https://github.com/abrignoni/RLEAPP)) — vehicle and returns extractions in the same family [verify 2026-10-30]
- **APOLLO** ([github.com/mac4n6/APOLLO](https://github.com/mac4n6/APOLLO)) — Apple Pattern of Life Lazy Output'er; correlates KnowledgeC, biome, Health, PowerLog into a single timeline [verify 2026-10-30]
- **mvt-ios / mvt-android** ([mvt.re](https://mvt.re)) — Mobile Verification Toolkit (Amnesty International); spyware indicator scanning against STIX2 IOC bundles [verify 2026-10-30]

**Cloud & SIM Card:**
```bash
# SIM card reader acquisition (MSAB XRY or a dedicated PC/SC reader)
# Capture: ICCID, IMSI, ADN/SMS, LOCI/PSLOCI (last cell location), authentication keys (Ki not extractable on modern SIMs)

# Cloud data preservation — legal process required (subpoena/warrant/MLAT):
# - iCloud (Apple): backups, Photos, iCloud Drive, Find My, Messages-in-iCloud
# - Google Account: Takeout export, Workspace audit (admins), Location History (now "Timeline", on-device since 2024) [verify 2026-10-30]
# - Microsoft 365 / OneDrive: Compliance Search + UAL (see Cloud Forensics §3)
# - Dropbox / Box / Slack / Discord: provider-specific legal request portals
# Law-enforcement preservation request (US, 18 U.S.C. § 2703(f): 90 days, renewable once) or a Budapest Convention Article 29
# expedited-preservation request via the Article 35 24/7 network (cross-border) freezes data pending warrant / MLAT. [verify 2026-10-30]
# Only a governmental entity can send a § 2703(f) request (Art. 29 is State-to-State); corporate/private teams ask law enforcement, via counsel. [verify 2026-10-30]
```

### Cloud Evidence Acquisition

> **Authority and provider cooperation.** Cloud evidence acquisition almost always requires (a) tenant-admin authorization, (b) provider legal process (subpoena/warrant/preservation letter), or both. Verify legal basis with counsel before issuing API calls — even read-only collection can violate ToS or data-residency law. Cross-border requests usually go through MLAT or the Budapest Convention.

**Triage rules:**
- Pull *audit/control-plane* logs first (who did what) — they have shorter retention and are the highest-value evidence for incident scoping.
- Pull *data-plane* logs (S3 access, Drive opens) second — far higher volume, longer retention windows for many providers.
- Snapshot/preserve before mutating: copy logs out of the source tenant into investigator-controlled storage with hash verification before any analysis.

#### AWS

```bash
# Confirm CloudTrail is enabled across all regions and identify the trail's S3 destination [verify 2026-10-30]
aws cloudtrail describe-trails --include-shadow-trails
aws cloudtrail get-trail-status --name <trail-name>

# Lookup recent control-plane events (90-day default lookup window via the API; full retention in the S3 bucket) [verify 2026-10-30]
aws cloudtrail lookup-events --start-time 2026-04-01T00:00:00Z --end-time 2026-04-25T00:00:00Z \
    --lookup-attributes AttributeKey=Username,AttributeValue=<suspect-iam-user>

# Pull the underlying CloudTrail logs from S3 (gzipped JSON, one object per ~5 min per region) [verify 2026-10-30]
aws s3 sync s3://<cloudtrail-bucket>/AWSLogs/<account-id>/CloudTrail/ /evidence/cloudtrail/ \
    --exclude "*" --include "*/2026/04/*"

# Query CloudTrail at scale with Athena (recommended for >1 GB of logs)
# CREATE EXTERNAL TABLE cloudtrail_logs ... LOCATION 's3://<bucket>/AWSLogs/...';
# SELECT eventTime, userIdentity.arn, eventName, sourceIPAddress FROM cloudtrail_logs
#   WHERE eventTime BETWEEN '2026-04-01' AND '2026-04-25' AND eventName LIKE '%Console%';

# GuardDuty findings (managed threat detection)
aws guardduty list-detectors
aws guardduty list-findings --detector-id <id>
aws guardduty get-findings --detector-id <id> --finding-ids <ids>

# VPC Flow Logs (network-plane), S3 Server Access Logs (object-plane), CloudFront / ALB / ELB access logs
# All land in S3 — sync the relevant prefix and validate hashes
```

Key services: **CloudTrail** (control plane), **GuardDuty** (threat detection), **VPC Flow Logs** (network), **S3 Server Access Logs / IAM Access Analyzer for S3** (object access), **IAM Access Analyzer** (over-permissioned roles), **Config** (resource state history). Default CloudTrail management-event retention in Event history is 90 days; long-term retention requires a trail writing to S3. [verify 2026-10-30]

#### Azure / Microsoft 365

```bash
# Azure Activity Log (subscription/tenant control-plane events) [verify 2026-10-30]
az login
az monitor activity-log list --start-time 2026-04-01T00:00:00Z --end-time 2026-04-25T00:00:00Z \
    --max-events 1000 --output json > activity-log.json

# Microsoft Entra ID (Azure AD) sign-in and audit logs — primary identity-compromise evidence [verify 2026-10-30]
az rest --method GET --uri "https://graph.microsoft.com/v1.0/auditLogs/signIns?\$filter=createdDateTime ge 2026-04-01T00:00:00Z"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?\$filter=activityDateTime ge 2026-04-01T00:00:00Z"
```

```powershell
# M365 Unified Audit Log (UAL) via Exchange Online PowerShell (Search-UnifiedAuditLog). It returns 100 records by
# default; -SessionCommand is required for more. ReturnLargeSet pages unsorted results (-ResultSize = page size,
# max 5000): re-run with the same -SessionId until nothing comes back (max 50,000 per session). [verify 2026-10-30]
# For programmatic pulls Microsoft recommends the Microsoft 365 Management Activity API; the Graph
# auditLogQuery API (v1.0, POST /security/auditLog/queries) creates a query you poll, then read records.
# Search-MailboxAuditLog / New-MailboxAuditLogSearch are being deprecated in Exchange Online in favour
# of Search-UnifiedAuditLog; do not build new collection on them. [verify 2026-10-30]
Connect-ExchangeOnline -UserPrincipalName <admin>@<tenant>
Search-UnifiedAuditLog -StartDate 2026-04-01 -EndDate 2026-04-25 -UserIds <upn> -SessionId case001-ual -SessionCommand ReturnLargeSet -ResultSize 5000

# Defender / Purview Compliance — content searches for mailbox content (eDiscovery)
# Compliance Center → Content search → New search → scope to user/site/team
```

Key sources: **Azure Activity Log**, **Entra ID sign-in/audit logs**, **M365 Unified Audit Log (UAL)**, **Defender for 365** (alerts, threat-explorer), **Purview eDiscovery** (mailbox/SharePoint/Teams content). UAL retention is **180 days** with Audit (Standard); **1 year** for Exchange, SharePoint, OneDrive and Entra records with Audit (Premium) / E5 (other workloads stay at 180 days unless a custom retention policy is set); **up to 10 years** only with the 10-Year Audit Log Retention add-on on top of E5 [verify 2026-10-30].

#### Google Cloud / Workspace

```bash
# GCP Cloud Audit Logs (Admin Activity, Data Access, System Event, Policy Denied) [verify 2026-10-30]
gcloud auth login
gcloud logging read 'protoPayload.serviceName="iam.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json > gcp-iam-audit.json

# Export audit logs to a sink (BigQuery, Cloud Storage, Pub/Sub) for long-term preservation [verify 2026-10-30]
gcloud logging sinks create case-001-sink storage.googleapis.com/<bucket> \
    --log-filter='logName:"cloudaudit.googleapis.com"'

# Google Workspace Reports / Audit API — admin, login, drive, gmail, mobile, token, groups, calendar
# Required scope: https://www.googleapis.com/auth/admin.reports.audit.readonly [verify 2026-10-30]
curl -H "Authorization: Bearer $GOOGLE_ADMIN_TOKEN" \
    "https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/login?startTime=2026-04-01T00:00:00Z"

# Gmail / Drive content via Vault (eDiscovery)
# admin.google.com → Vault → Matter → Hold + Search + Export
```

Key sources: **Cloud Audit Logs** (Admin Activity is enabled by default and free; Data Access is opt-in and billed), **Workspace Reports/Audit** (login, drive, admin, token, gmail, mobile), **Google Vault** (eDiscovery hold + export), **Security Command Center** (findings), **VPC Flow Logs**. [verify 2026-10-30]

#### SaaS / Identity

- **Okta** — System Log API (`/api/v1/logs`); 90-day sliding window; export (CSV or via the API) to keep older events [verify 2026-10-30]
- **Slack** — Audit Logs API (Enterprise plan only); Discovery API for content [verify 2026-10-30]
- **GitHub** — Audit Log API (org/enterprise); push, fork, repo creation, OAuth grants [verify 2026-10-30]
- **Salesforce** — Setup Audit Trail (180 days), Event Monitoring (with add-on), Login History [verify 2026-10-30]

**Acquisition hashing:** treat exported logs and snapshots like any other digital evidence — hash on download (SHA-256), record source URL/API endpoint and timestamp range, store with a chain-of-custody entry per [[../../Investigations/Techniques/sop-collection-log|Collection Log]].

### Network Evidence

**Packet Capture:**
```bash
# Live capture with tcpdump [verify 2026-10-30]
tcpdump -i eth0 -w capture.pcap

# Capture specific host
tcpdump -i eth0 host 192.168.1.100 -w host_capture.pcap

# Capture specific port
tcpdump -i eth0 port 443 -w https_capture.pcap

# Wireshark (GUI)
# Capture → Options → Select interface → Start
```

**Log Collection:**
```cmd
# Windows Event Logs [verify 2026-10-30]
wevtutil epl Security C:\Evidence\Security.evtx
wevtutil epl System C:\Evidence\System.evtx
wevtutil epl Application C:\Evidence\Application.evtx
```

```bash
# Linux syslog
cp /var/log/syslog /mnt/evidence/syslog.txt
cp /var/log/auth.log /mnt/evidence/auth.log.txt
journalctl > /mnt/evidence/journalctl_full.txt

# Web server logs
cp /var/log/apache2/access.log /mnt/evidence/
cp /var/log/nginx/access.log /mnt/evidence/
```

---

## 4. Analysis Phase

### Preparation

**Working Environment:**
```text
CRITICAL RULE: Never work on original evidence
1. Verify hash of forensic image matches collection hash
2. Create working copy of forensic image
3. Document analysis workstation specs
4. Use isolated analysis network (no internet for malware analysis)
5. Time-sync all analysis systems to UTC
```

**Analysis Documentation:**
```text
Analysis Log Must Include:
- Case number and analyst name
- Date and time of each analysis session (UTC)
- Tool name and version for each operation
- Command line syntax for CLI tools
- Search keywords and queries used
- Findings with supporting evidence references
- Hash values of extracted artifacts
```

### Mounting Forensic Images

**Linux:**
```bash
# Mount E01 image (requires ewf-tools/libewf) [verify 2026-10-30]
ewfmount image.E01 /mnt/ewf
mount -o ro,loop,noexec /mnt/ewf/ewf1 /mnt/analysis

# Mount dd image (read-only)
mount -o ro,loop,noexec image.dd /mnt/analysis

# Mount with specific filesystem
mount -t ntfs-3g -o ro,loop,noexec image.dd /mnt/analysis
```

**FTK Imager (Windows):**
```text
1. File → Add Evidence Item
2. Select Image File → Browse to E01/dd file
3. Evidence tree shows filesystem
4. Right-click folders → Export files (preserves metadata)
```

### File System Analysis

**Autopsy (Open Source Forensics Platform):**
```text
1. Create New Case
2. Add Data Source → Disk Image
3. Select ingest modules:
   - File Type Identification
   - Extension Mismatch Detector
   - PhotoRec Carver (unallocated carving) [verify 2026-10-30]
   - Hash Lookup (NSRL, known bad hashes)
   - Keyword Search
   - Email Parser
   - Recent Activity (web/OS artifacts) [verify 2026-10-30]
4. Run analysis
5. Review results in tree view/table
```

**Deleted File Recovery:**
```bash
# Using Sleuth Kit [verify 2026-10-30]
fls -r -d image.dd > deleted_files.txt  # List deleted files
icat image.dd [inode] > recovered_file.dat  # Recover specific file

# Using Scalpel (file carving) [verify 2026-10-30]
scalpel -c scalpel.conf -o /output image.dd

# Using PhotoRec (GUI/CLI) [verify 2026-10-30]
photorec image.dd
```

**File Metadata Examination:**
```bash
# Using Sleuth Kit [verify 2026-10-30]
ils image.dd  # List inodes (including deleted)
istat image.dd [inode]  # Get detailed inode info

# Using exiftool (extract EXIF data)
exiftool image.jpg > image_metadata.txt
exiftool -r /mnt/analysis/Users/JohnDoe/Pictures > all_photo_metadata.txt

# NTFS $MFT parsing — must extract $MFT from the image first (it lives at the root of the volume)
# Option A: Sleuth Kit
icat image.dd 0 > MFT.bin                            # inode 0 is $MFT on NTFS

# Option B: mount image read-only and copy via NTFS-3G (show_sys_files / streams_interface are ntfs-3g options) [verify 2026-10-30]
mount -t ntfs-3g -o ro,loop,noexec,show_sys_files,streams_interface=windows image.dd /mnt/analysis
cp /mnt/analysis/\$MFT ./MFT.bin

# Parse — MFTECmd (Eric Zimmerman) is the modern recommendation; analyzeMFT is also fine [verify 2026-10-30]
MFTECmd.exe -f MFT.bin --csv .\out --csvf mft.csv     # also parses $J / $LogFile / $Boot / $SDS
analyzeMFT.py -f MFT.bin -o mft_timeline.csv --csv
```

### Timeline Construction

**Using log2timeline / Plaso** (current release 20261027; releases are date-versioned) [verify 2026-10-30]:
```bash
# Create the storage file (Plaso storage is SQLite-based) [verify 2026-10-30]
log2timeline.py --storage-file timeline.plaso image.dd

# Limit parsers for speed (skip noisy ones during initial triage) [verify 2026-10-30]
log2timeline.py --parsers '!filestat,!winreg' --storage-file timeline.plaso image.dd

# Convert / filter to CSV with psort [verify 2026-10-30]
psort.py -o l2tcsv -w timeline.csv timeline.plaso

# Date-range filter (psort filter expression syntax) [verify 2026-10-30]
psort.py -o l2tcsv -w filtered.csv timeline.plaso "date > '2026-04-01' AND date < '2026-04-25'"

# User filter
psort.py -o l2tcsv -w user_timeline.csv timeline.plaso "username contains 'johndoe'"

# Line-delimited JSON export (opensearch_ts writes straight to an OpenSearch server, not to a file).
# For Timesketch, the .plaso file itself can be imported (web UI or timesketch_importer). [verify 2026-10-30]
psort.py -o json_line -w analysis.jsonl timeline.plaso
```

**Manual timeline (Mac Times):**
```bash
# Sleuth Kit fls + mactime — fast bodyfile generation when you only want filesystem MAC times [verify 2026-10-30]
fls -m C:/ -r image.dd > bodyfile.txt
mactime -b bodyfile.txt -d > timeline.csv
```

**Timeline Analysis Tools:**
- **Timesketch** ([github.com/google/timesketch](https://github.com/google/timesketch)) — web-based collaborative timeline analysis with sketches, tagging, Sigma-rule running, and AI-assisted analysis (newer releases) [verify 2026-10-30]
- **Timeline Explorer** (Eric Zimmerman) — Windows GUI for filtering CSV/L2TCSV timelines [verify 2026-10-30]
- **Hayabusa** ([github.com/Yamato-Security/hayabusa](https://github.com/Yamato-Security/hayabusa)) — Sigma-driven Windows event log timeline; produces a triage-ready CSV in minutes [verify 2026-10-30]
- **Chainsaw** ([github.com/WithSecureOpenSource/chainsaw](https://github.com/WithSecureOpenSource/chainsaw)) — fast EVTX hunting with Sigma + custom rules [verify 2026-10-30]

### Registry Analysis (Windows)

**Extract Registry Hives:**
```bash
# Hive locations:
# C:\Windows\System32\config\SAM
# C:\Windows\System32\config\SECURITY
# C:\Windows\System32\config\SOFTWARE
# C:\Windows\System32\config\SYSTEM
# C:\Windows\System32\config\BCD-Template
# C:\Users\[username]\NTUSER.DAT
# C:\Users\[username]\AppData\Local\Microsoft\Windows\UsrClass.dat

# Export with FTK Imager or:
icat image.dd [inode_of_SAM] > SAM
icat image.dd [inode_of_SYSTEM] > SYSTEM
```

**Registry Analysis:**
```bash
# Using RegRipper (rr.exe / rip.pl). RegRipper 4.0 (github.com/keydet89/RegRipper4.0) is current but licensed for
# personal/academic use only; RegRipper3.0 remains the freely redistributable release.
# -a runs every plugin for the detected hive type (-aT for TLN output); -p takes a single plugin name. [verify 2026-10-30]
rip.pl -r SAM -a > sam_output.txt
rip.pl -r SYSTEM -a > system_output.txt
rip.pl -r SOFTWARE -a > software_output.txt
rip.pl -r NTUSER.DAT -a > ntuser_output.txt
rip.pl -r UsrClass.dat -a > usrclass_output.txt

# Eric Zimmerman's Registry Explorer / RECmd (Windows GUI/CLI) is the modern alternative [verify 2026-10-30]
RECmd.exe --bn BatchExamples\\RegistryASEPs.reb -d C:\\Evidence\\hives --csv .\\out

# Key artifacts (legacy, well-known):
# - USB device history:           SYSTEM\CurrentControlSet\Enum\USBSTOR + USB
# - UserAssist (GUI execution):   NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist (ROT13-encoded value names)
# - ShimCache / AppCompatCache:   SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache (program path + last-modified time of binary; entry count is capped — 1024 on Win10/11 is commonly cited but not documented by Microsoft)
# - Run keys:                     SOFTWARE\Microsoft\Windows\CurrentVersion\Run, RunOnce; NTUSER.DAT\...\Run
# - Services:                     SYSTEM\CurrentControlSet\Services
# - Scheduled tasks (XML):        C:\Windows\System32\Tasks\ + SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree
```

**Modern Windows execution & activity artifacts** (these are frequently the most useful and are easy to miss):

| Artifact | Location | What it records | Parser |
|---|---|---|---|
| **AmCache.hve** | `C:\Windows\AppCompat\Programs\Amcache.hve` | PE files inventoried by the application-compatibility engine — presence is not proof of execution, corroborate it: full path, SHA-1, PE header fields, publisher; timestamps are registry key last-write times, not first execution | `AmcacheParser.exe` (EZ Tools); RegRipper `amcache` plugin [verify 2026-10-30] |
| **ShimCache (AppCompatCache)** | Registry `SYSTEM\...\AppCompatCache` | Path + last-modified timestamp + execution flag; populated on shutdown | `AppCompatCacheParser.exe` (EZ Tools) [verify 2026-10-30] |
| **BAM / DAM** | `SYSTEM\CurrentControlSet\Services\bam\State\UserSettings\<SID>` and `dam\...` | Per-user, per-binary last execution time (FILETIME); BAM = Background Activity Moderator, DAM = Desktop Activity Moderator; some Win10 builds use `bam\UserSettings\<SID>` without `State` | RegRipper `bam` plugin; raw `reg.exe query` [verify 2026-10-30] |
| **PCA (Program Compatibility Assistant)** | `C:\Windows\appcompat\pca\PcaAppLaunchDic.txt`, `PcaGeneralDb0.txt`, `PcaGeneralDb1.txt` (Win11 22H2+) | Pipe-delimited text. `PcaAppLaunchDic.txt`: full path + last execution time (UTC), GUI launches only. `PcaGeneralDb0/1.txt`: typed records such as installer failure, blocked driver, abnormal exit (with exit code) | manual review [verify 2026-10-30] |
| **SRUM (System Resource Usage Monitor)** | `C:\Windows\System32\sru\SRUDB.dat` (ESE database) | Per-process network bytes sent/received, energy, application runtime — hourly buckets; retention ~30 days (tool documentation; Microsoft does not document it) | `SrumECmd.exe` (EZ Tools); `SRUM-DUMP` v3 (Mark Baggett); KAPE module [verify 2026-10-30] |
| **UserAssist** | `NTUSER.DAT\...\Explorer\UserAssist\{GUID}\Count` | GUI-launched programs and shortcuts: count, focus time, last execution (ROT13 names) | RegRipper `userassist`; `UserAssistView` (NirSoft) |
| **Prefetch** | `C:\Windows\Prefetch\*.pf` | First/last 8 run timestamps, run count, files referenced, volumes. Not always enabled: Windows 7 turned prefetching off on fast SSDs, and on Windows Server it is off by default. Check `EnablePrefetcher` under `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters` before treating an empty Prefetch folder as suspicious | `PECmd.exe` (EZ Tools) [verify 2026-10-30] |
| **JumpLists** | `%AppData%\Microsoft\Windows\Recent\(Custom\|Automatic)Destinations\*.\{customDestinations,automaticDestinations\}-ms` | Recently opened files per application (per AppID) | `JLECmd.exe` (EZ Tools) [verify 2026-10-30] |
| **LNK files** | `%AppData%\Microsoft\Windows\Recent\*.lnk`; user Desktop and SendTo | Target path, MAC times, volume serial, MAC address, NetBIOS name of host that created the link | `LECmd.exe` (EZ Tools); ExifTool [verify 2026-10-30] |
| **Recycle Bin metadata** | `C:\$Recycle.Bin\<SID>\$I*` (index) and `$R*` (renamed content) | Original filename, original path, deletion timestamp, original size — even after empty if `$R` is recovered from unallocated | `RBCmd.exe` (EZ Tools) [verify 2026-10-30] |
| **Windows Event Logs** | `C:\Windows\System32\winevt\Logs\*.evtx` | Security (4624 logon, 4634 logoff, 4688 process create with cmdline), System, Application, PowerShell/Operational (4104 script block), Sysmon (1/3/7/10/11/13) | `EvtxECmd.exe` (EZ Tools); `Get-WinEvent`; Hayabusa for fast triage [verify 2026-10-30] |
| **USN Journal ($J)** | `\$Extend\$UsnJrnl:$J` (NTFS ADS) | Filesystem change journal (CREATE/DELETE/RENAME with timestamps); typically days to weeks of history | `MFTECmd.exe -f J.bin -m MFT.bin --csv .\out --csvf usn.csv` (`$J` extracted as `J.bin`; `-m` resolves parent paths) [verify 2026-10-30] |
| **$LogFile** | NTFS volume root `\$LogFile` | NTFS transaction log; recoverable transactions for very recent activity | `NTFS Log Tracker` |

**KAPE (Kroll Artifact Parser and Extractor)** is the canonical workflow for collecting and parsing this set — `kape.exe --tsource C: --target KapeTriage --tdest .\out\targets --module !EZParser --mdest .\out\modules` runs targets (collection) followed by modules (parsing) end-to-end; `--mdest` is required for module output, and `--msource` defaults to `--tdest`. [verify 2026-10-30]

### macOS Artifacts

**Filesystem & system snapshots:**
- **APFS local snapshots** — only when Back Up Automatically is on, Time Machine keeps hourly local snapshots on the same APFS disk as the files for up to 24 h (or until space is needed); they remain available when the backup disk isn't; `tmutil listlocalsnapshots /` enumerates them, `mount_apfs -s <snapshot> /System/Volumes/Data /mnt/snap` mounts read-only. Snapshots survive most user-driven deletions. [verify 2026-10-30]
- **`/.fseventsd`** — FSEvents log; per-volume directory of gzipped change records (event type, inode, path). Parsers: **FSEventsParser** (G-C Partners), **mac_apt FSEvents plugin**.

**User activity ("Pattern of Life"):**
- **`KnowledgeC.db`** — `~/Library/Application Support/Knowledge/knowledgeC.db` (user) and `/private/var/db/CoreDuet/Knowledge/knowledgeC.db` (system). SQLite; tracks application focus, screen on/off, device lock/unlock, Siri suggestions, in-app activity. Retention varies by stream and macOS version (Apple does not document it).
- **Biome** — `~/Library/Biome/streams/public/` (introduced around macOS 12 per community research; Apple does not document it). Replaces parts of KnowledgeC; binary protobuf streams covering app intents, location pings, focus modes, AirDrop. Parse with **APOLLO**, **mac_apt**, or **iLEAPP** (cross-applies on iOS extractions).
- **Spotlight** — `/.Spotlight-V100/Store-V2/<UUID>/store.db` indexes file content metadata; survivable artifact for filenames even after deletion.
- **QuickLook thumbnails** — `/private/var/folders/<xx>/<random>/C/com.apple.QuickLook.thumbnailcache/` (`$TMPDIR/../C/`; `index.sqlite` = paths/names, `thumbnails.data` = bitmaps) — rich source for files no longer present, including files on removable or encrypted volumes. Location per Objective-See research (2018); confirm on newer macOS releases. [verify 2026-10-30]
- **Unified Logs (`.tracev3`)** — `/var/db/diagnostics/` and `/var/db/uuidtext/`. Replaces traditional syslog on macOS 10.12+. Live capture: `log show --predicate 'process == "loginwindow"' --style ndjson --start "2026-04-25 00:00:00"`. Offline parse: **macos-UnifiedLogs** (Mandiant, Rust), **mac_apt** unifiedlogs plugin; **UnifiedLogReader** (Yogesh Khatri, Python) is no longer maintained per its README. [verify 2026-10-30]

**Persistence & execution:**
- **LaunchAgents / LaunchDaemons** — `/Library/LaunchAgents`, `/Library/LaunchDaemons`, `~/Library/LaunchAgents`, `/System/Library/LaunchDaemons` (SIP-protected, but malware uses the user-writable paths)
- **Login Items / Background Task Management** — macOS 13 Ventura+: `/private/var/db/com.apple.backgroundtaskmanagement/BackgroundItems-v*.btm`, which consolidates login items and launch agents/daemons; dump with `sfltool dumpbtm` (Apple) or DumpBTM (Objective-See). Pre-Ventura: `~/Library/Application Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm` (community-documented path); legacy: `loginwindow.plist`. [verify 2026-10-30]
- **Configuration profiles** — `/Library/Managed Preferences/`, `/var/db/ConfigurationProfiles/` (MDM enrollment, policy, certs)
- **TCC database** — `/Library/Application Support/com.apple.TCC/TCC.db` (system) and `~/Library/Application Support/com.apple.TCC/TCC.db` (user); records consent for camera/mic/full-disk-access — useful for spotting malware that escalated to FDA.

**Tools:**
- **mac_apt** (Yogesh Khatri) — primary cross-artifact parser; outputs SQLite/Excel/CSV [verify 2026-10-30]
- **APOLLO** (Sarah Edwards) — Pattern of Life timeline correlator [verify 2026-10-30]
- **OSXCollector** (legacy Yelp; repository archived 2019) — live response collection [verify 2026-10-30]
- **iLEAPP** parses the iOS/iPadOS equivalents (Biome, KnowledgeC); for macOS use mac_apt or APOLLO [verify 2026-10-30]

### Linux Artifacts

**Logs:**
- **systemd-journald** — `/var/log/journal/<machine-id>/system.journal` (binary, indexed). Live: `journalctl --since "2026-04-25 00:00:00" --output=json`. Offline (image): `journalctl -D /mnt/image/var/log/journal --output=json --no-pager`. On systems with persistent journaling disabled, only `/run/log/journal` exists and is lost at reboot — check `Storage=` in `/etc/systemd/journald.conf`. [verify 2026-10-30]
- **auditd / `audit.log`** — `/var/log/audit/audit.log`. Records syscalls, file access, login events when configured. Parse with `ausearch` / `aureport`. Default rule sets are sparse; investigators should look for organisation-specific rule additions.
- **Traditional syslog** — `/var/log/syslog`, `/var/log/messages`, `/var/log/auth.log`, `/var/log/secure`, `/var/log/wtmp`, `/var/log/btmp`, `/var/log/lastlog` (all standard via `last`, `lastb`, `who /var/log/wtmp`).

**Identity & install fingerprints:**
- **`/etc/machine-id`** — 32-char hex; persistent host identifier set on first boot. Critical for correlating logs and disk images to a specific install. Don't confuse with `/var/lib/dbus/machine-id` (often a symlink to it). [verify 2026-10-30]
- **`/etc/hostname`, `/etc/hosts`, `/etc/resolv.conf`** — basic identity / network config
- **Package install history** — `/var/log/dpkg.log` (Debian/Ubuntu), `/var/log/apt/history.log`, `/var/log/yum.log` or `dnf.log` (RHEL/Fedora), `/var/log/pacman.log` (Arch); RPM DB `/var/lib/rpm/rpmdb.sqlite` (rpm 4.16+: Fedora 33+, RHEL 9+) or `/var/lib/rpm/Packages` (Berkeley DB, older RHEL/CentOS) [verify 2026-10-30]

**User activity:**
- **Shell histories** — `~/.bash_history`, `~/.zsh_history`, `~/.local/share/fish/fish_history`. Trivially editable; treat as supporting evidence only.
- **`~/.viminfo`, `~/.lesshst`, `~/.python_history`** — secondary activity traces frequently overlooked
- **`/var/log/wtmp`, `utmp`, `btmp`** — login records (binary; use `utmpdump`) [verify 2026-10-30]
- **SSH** — `~/.ssh/authorized_keys`, `~/.ssh/known_hosts` (for host pivoting), `/var/log/auth.log` (sshd events)

**Persistence:**
- **systemd units** — `/etc/systemd/system/`, `/usr/lib/systemd/system/`, `~/.config/systemd/user/`; check `systemctl list-unit-files --state=enabled`
- **cron** — `/etc/crontab`, `/etc/cron.{d,daily,hourly,monthly,weekly}/`, `/var/spool/cron/crontabs/<user>`
- **Init scripts** — `/etc/init.d/`, `/etc/rc*.d/` (legacy SysV)
- **Profile / shell init** — `/etc/profile`, `/etc/profile.d/`, `~/.bashrc`, `~/.bash_profile`, `~/.zshrc`
- **LD_PRELOAD / `/etc/ld.so.preload`** — library-injection persistence
- **SUID binaries** — `find / -perm -4000 -type f 2>/dev/null` baseline diff against package manager-shipped expected list

**Filesystem snapshots (recovery & rollback):**
- **Btrfs** — `btrfs subvolume list /`, `btrfs subvolume snapshot -r <subvol> <name>`. Default on openSUSE (snapper-managed), Fedora 33+ workstation. [verify 2026-10-30]
- **ZFS** — `zfs list -t snapshot`. Optional disk-setup choice in the Ubuntu Desktop installer (not offered in the Server installer UI); OpenZFS broadly. [verify 2026-10-30]
- **LVM thin snapshots** — `lvs`, `lvdisplay`. Common for VM disk images and backup tooling.

**Tools:**
- **UAC (Unix-like Artifacts Collector)** — vendor-neutral live-response collector [verify 2026-10-30]
- **Velociraptor** — modern cross-platform live-response framework with Linux artifacts pack [verify 2026-10-30]
- **chkrootkit / rkhunter / Lynis** — known-rootkit scans during triage

### Browser Artifacts

**Chrome/Edge (Chromium):**
```bash
# History location: AppData\Local\Google\Chrome\User Data\Default\History (SQLite)

# Query with SQLite [verify 2026-10-30]
sqlite3 History "SELECT url, title, visit_count, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 100;"

# Downloads [verify 2026-10-30]
sqlite3 History "SELECT target_path, start_time, end_time, total_bytes FROM downloads;"

# Using Hindsight (automated parser) [verify 2026-10-30]
hindsight.py -i "/path/to/Chrome/Profile" -o /output
```

**Firefox:**
```bash
# History: AppData\Roaming\Mozilla\Firefox\Profiles\[profile]\places.sqlite [verify 2026-10-30]

sqlite3 places.sqlite "SELECT url, title, visit_count, last_visit_date FROM moz_places ORDER BY last_visit_date DESC LIMIT 100;"
```

**Browser Artifacts to Examine:**
- [ ] History (URLs, timestamps)
- [ ] Downloads (files, sources, completion status)
- [ ] Cache (images, HTML, scripts)
- [ ] Cookies (session data, authentication)
- [ ] Auto fill data (forms, passwords if stored)
- [ ] Extensions/add-ons installed

### Email Analysis

**PST/OST Files (Outlook):**
```bash
# libpst (readpst) — converts PST/OST to MBOX or per-folder structure
#   -r recursive folder structure   -D include deleted items   -cv contacts as vCard [verify 2026-10-30]
readpst -r -D -cv -o /output file.pst

# pffexport (libpff, libyal) — preferred for forensics; better recovery and metadata preservation
# -f all = every output format (text + html + rtf); -t is a basename: pffexport appends .export/.orphans/.recovered
# -m all = allocated + orphan + recovered items [verify 2026-10-30]
pffexport -t /output/case001 -f all file.pst
pffexport -m all -t /output/case001-all -f all file.pst

# Outlook OST recovery — Kernel OST Viewer (commercial), SysTools, or libpff pffexport
```

**MBOX/EML Files:**
```bash
# Per-message extraction
# formail -s pipes each message to a new process and sets $FILENO (000, 001, ...) [verify 2026-10-30]
formail -ds sh -c 'cat > msg_$FILENO.eml' < archive.mbox   # one .eml per message
python3 -c "import mailbox; [print(m['Subject']) for m in mailbox.mbox('archive.mbox')]"

# EML parsing (Python email library, mail-parser, or commercial: MailStore, aid4mail)
# pip install mail-parser (CLI: mailparser) [verify 2026-10-30]
mailparser -f evidence.eml -j > evidence.json
```

**Header Analysis & BEC investigation:**

Headers are read **bottom-to-top** — the last `Received:` header was added first (closest to the sender). Each hop should add an IP that resolves consistently with the claimed sender domain.

```bash
# Extract every Received header, From, Return-Path, Authentication-Results
grep -iE "^(From|Reply-To|Return-Path|Received|Authentication-Results|Received-SPF|DKIM-Signature|ARC-|Message-ID|X-Originating-IP|X-Mailer):" evidence.eml > headers.txt

# Parse Authentication-Results — this is where SPF/DKIM/DMARC verdicts live for the receiving server
# Expected: spf=pass dkim=pass dmarc=pass
# BEC red flag: spf=fail OR dkim=none OR dmarc=fail with a high-trust display name
```

**Key forensic interpretation:**
- **SPF (Sender Policy Framework)** — `Received-SPF: pass/fail/softfail/none`. A `fail` from a domain that publishes `-all` is a hard indicator of spoofing or compromised relay. Validate by querying the sender domain's TXT record: `dig +short TXT example.com | grep spf`.
- **DKIM** — `DKIM-Signature:` carries `d=` (signing domain), `s=` (selector), and `b=` (signature). The `d=` MUST align with the From header's domain to satisfy DMARC alignment. Verify with `opendkim-testmsg < evidence.eml` or online validators on a sanitized copy.
- **DMARC** — published in `_dmarc.<domain>` TXT record (`v=DMARC1; p=reject|quarantine|none`). Receiver-side verdict appears in `Authentication-Results` as `dmarc=pass/fail`. A `dmarc=fail` against a domain publishing `p=reject` that nonetheless reached the inbox usually indicates an internal forwarder, allowlist abuse, or look-alike domain.
- **ARC (Authenticated Received Chain)** — `ARC-Seal:` / `ARC-Message-Signature:` chain preserves auth results across forwarders that would otherwise break SPF. Inspect when messages traverse mailing lists or third-party gateways.
- **Display-name spoofing** — `From: "CEO Name" <attacker@lookalike.com>`; the display name matches an executive but the address does not. Pull the address out of every `From:` and compare.
- **Look-alike domains** — punycode (`xn--`) homoglyphs, character substitutions (`rn` for `m`, `0` for `o`), TLD swaps. Run `dnstwist <victim-domain>` to enumerate likely candidates and check against the message domain. [verify 2026-10-30]
- **Message-ID structure** — Microsoft 365 IDs end in `.prod.outlook.com` or `.outlook.com`; Google Workspace in `@mail.gmail.com`. A claimed Microsoft sender with a Google Message-ID is suspicious.
- **X-Originating-IP / Received chain** — first external hop's IP geolocation should be plausible for the claimed sender. Cross-reference with sign-in logs (Entra ID, Workspace) for the impersonated account.

**BEC investigation pivots:**
1. Pull the M365 UAL or Workspace audit log for the impersonated account around the email's timestamp — look for inbox-rule creation, mailbox-forwarding rule, OAuth grant, MFA failures, sign-ins from new ASNs.
2. Check `Set-InboxRule` / `New-InboxRule` events and existing forwarding rules — exfil-staging rules often hide messages by moving them to RSS Feeds / Conversation History.
3. Recover deleted items from the **Recoverable Items** folder (`Get-MailboxFolderStatistics -FolderScope RecoverableItems`); attackers commonly hard-delete the bait reply. [verify 2026-10-30]
4. Hash and preserve the original `.eml` (or PST export) before any cleanup; record SHA-256 in chain of custody.

### Memory Analysis

> **Volatility 3 is the default.** Volatility 2 was deprecated and its repository archived in May 2025, alongside the Volatility 3 v2.26.0 parity release; use it only for legacy memory images that Volatility 3 cannot handle. Volatility 3 downloads and caches Windows symbols on demand; Linux and macOS symbol tables must be supplied (symbol packs, or built with dwarf2json) via `--symbol-dirs <path>`. There is no `--profile=` step. Current release: v2.28.2 (Sep 2026) [verify 2026-10-30].

**Using Volatility 3 (current):**
```bash
# Install: pipx install volatility3   (CLI entrypoint is `vol`; `vol.py` works on source checkouts) [verify 2026-10-30]
# OS / build identification [verify 2026-10-30]
vol -f memory.dmp windows.info
vol -f memory.dmp banners.Banners       # Linux: identify the kernel banner, then obtain matching ISF symbols
# macOS analysis support is deprecated as of v2.28.2 (Sep 2026); expect removal [verify 2026-10-30]
vol -f memory.dmp mac.kevents

# Process tree and command line [verify 2026-10-30]
vol -f memory.dmp windows.pslist
vol -f memory.dmp windows.pstree
vol -f memory.dmp windows.cmdline
vol -f memory.dmp windows.psscan        # carve EPROCESS structures (catches hidden/exited)

# Network connections (Windows 7+) [verify 2026-10-30]
vol -f memory.dmp windows.netscan
vol -f memory.dmp windows.netstat

# Loaded modules / DLLs [verify 2026-10-30]
vol -f memory.dmp windows.dlllist --pid <PID>
vol -f memory.dmp windows.modules
vol -f memory.dmp windows.modscan       # carve module structures

# Dump process memory / executable / DLL [verify 2026-10-30]
vol -f memory.dmp windows.memmap --pid <PID> --dump
vol -f memory.dmp windows.dumpfiles --pid <PID>
vol -f memory.dmp windows.pslist --dump

# Registry hives loaded in RAM [verify 2026-10-30]
vol -f memory.dmp windows.registry.hivelist
vol -f memory.dmp windows.registry.printkey --offset <hive-offset> --key 'Software\Microsoft\Windows\CurrentVersion\Run'

# Code-injection / malicious-region detection. Since v2.26.2 the malware plugins live under windows.malware.*;
# the old names (windows.malfind, windows.hollowprocesses) are deprecated and due for removal. [verify 2026-10-30]
vol -f memory.dmp windows.malware.malfind                   # RWX private regions, suspicious headers
vol -f memory.dmp windows.malware.hollowprocesses           # process hollowing
vol -f memory.dmp windows.ssdt                              # SSDT hooks
vol -f memory.dmp windows.callbacks                         # kernel callbacks (rootkit indicator)

# Credential material in memory (paired with Mimikatz-style offline parsers). The old names (windows.hashdump,
# windows.lsadump, windows.cachedump) are deprecated aliases of windows.registry.*, past their 2026-09-25 removal date. [verify 2026-10-30]
vol -f memory.dmp windows.registry.hashdump
vol -f memory.dmp windows.registry.lsadump
vol -f memory.dmp windows.registry.cachedump

# Linux (linux.check_modules is deprecated in favour of linux.malware.check_modules) [verify 2026-10-30]
vol -f memory.lime linux.pslist
vol -f memory.lime linux.bash           # recovers shell history from heap
vol -f memory.lime linux.malware.check_modules   # rootkit detection
```

**Using Volatility 2 (archived; legacy images only):**
```bash
# Volatility 2 is archived and unmaintained — only use it when V3 lacks symbols for the target build
volatility -f memory.dmp imageinfo
# Win10x64_19041 exists only on the final master branch (added Dec 2020), not in the 2.6.1 release [verify 2026-10-30]
volatility -f memory.dmp --profile=Win10x64_19041 pslist
```

**Companion tools:**
- **MemProcFS** ([github.com/ufrisk/MemProcFS](https://github.com/ufrisk/MemProcFS)) — mounts a memory image as a virtual filesystem; complementary to Volatility for fast triage [verify 2026-10-30]
- **bulk_extractor** — IOC carving (URLs, emails, credit cards) from raw memory or disk
- **YARA** — run rule sets directly against memory images: `vol -f mem.dmp yarascan.YaraScan --yara-file malware.yar` (kernel memory); `vol -f mem.dmp windows.vadyarascan --yara-file malware.yar` (per-process memory) [verify 2026-10-30]

### Malware Analysis (Basic Triage)

> **Scope guard.** Full static + dynamic malware analysis is out of scope for this SOP. The role of the forensic examiner is **identification, preservation, and IOC extraction** — sufficient to scope the incident and pivot. Hand off to a malware analyst (or follow [[sop-malware-analysis|Malware Analysis SOP]]) for unpacking, deobfuscation, family attribution, YARA/Sigma authoring, and report-grade behavioral analysis.

**Triage steps performed at the forensic bench:**
```bash
# 1. Hash and reputation lookup (do not upload — submit hash only)
sha256sum suspicious.exe
# Query VirusTotal / MalwareBazaar / Hybrid Analysis by hash; uploading the binary may tip the adversary

# 2. Quick string and import inventory
strings -a suspicious.exe > strings_ascii.txt
strings -el suspicious.exe > strings_unicode.txt
# FLOSS recovers stack/decoded strings that plain `strings` misses
floss suspicious.exe > strings_floss.txt

# 3. PE/format inspection (read-only)
pe-bear suspicious.exe                   # GUI
# CLI: pefile (Python), peframe, Detect It Easy (DIE) for packer signature
```

**Indicators to record for handoff** (consult [[sop-malware-analysis|Malware Analysis SOP]] §3 / §4 / §10 for the full reference set):
- Hashes (MD5, SHA-1, SHA-256), file size, original filename
- Compilation timestamp (treat as suspect — trivially forged), digital signature status
- Packer signature (UPX, Themida, VMProtect, Enigma, MPRESS, ASPack — see Malware Analysis SOP §3.5)
- Suspicious imports: `CreateRemoteThread`, `VirtualAllocEx`, `WriteProcessMemory`, `NtUnmapViewOfSection`, AMSI/ETW targets (`AmsiScanBuffer`, `EtwEventWrite`)
- Embedded URLs / IPs / domains (defanged on report — see §5)
- Mutex names, hardcoded service / scheduled-task names, registry persistence keys
- Anti-VM / anti-debug strings (`vmware`, `vbox`, `IsDebuggerPresent`)

**Where to detonate:** isolated VM with Sysmon + Procmon + Wireshark + INetSim/FakeNet — **never on the analyst workstation, never on the live evidence**. See [[sop-malware-analysis|Malware Analysis SOP]] §2 (sandbox setup) for REMnux/FlareVM build details.

**Online sandbox options** (be aware: uploading a sample makes it public-by-default on most services and can warn the adversary):
- **CAPEv2** ([github.com/kevoreilly/CAPEv2](https://github.com/kevoreilly/CAPEv2)) — modern, actively maintained Cuckoo fork with config + payload extraction; preferred local sandbox [verify 2026-10-30]
- **ANY.RUN** — interactive cloud sandbox (Pro tier offers private submissions)
- **Joe Sandbox** — cloud or on-prem; private mode available
- **Triage (Recorded Future, ex-Hatching)** — fast cloud sandbox, free + paid tiers [verify 2026-10-30]
- **Hybrid Analysis (Falcon Sandbox)** — community + paid
- **Cuckoo Sandbox** (original) — largely abandoned upstream; CAPE is the active successor

### Anti-Forensic Awareness

Modern attackers actively suppress the artifact set above. Treat the *absence* of expected artifacts as a finding, not a clean bill of health.

**Common evasion techniques that distort or remove forensic evidence** (see [[sop-malware-analysis|Malware Analysis SOP]] §10.4 for the offensive perspective):

| Technique | What it breaks | What still survives |
|---|---|---|
| **ETW patching** (`EtwEventWrite` prologue → `ret 0xC3`) | Sysmon, EDR, PowerShell ScriptBlockLogging, AMSI events for the patched process | Other processes; kernel callbacks; network captures; memory image of the patched process (the patch itself is visible in RAM) |
| **AMSI bypass** (patch `AmsiScanBuffer` to return `S_OK` with `AMSI_RESULT_CLEAN=0`, or `E_INVALIDARG`) | AV/EDR script content scanning; `Defender` script telemetry | PowerShell module/transcript logging; ScriptBlock logging if loaded before patch; memory dump [verify 2026-10-30] |
| **Direct syscalls / Hell's Gate / Halo's Gate / Tartarus Gate** | EDR userland hooks on `ntdll.dll` exports | Kernel ETW-Ti (`Microsoft-Windows-Threat-Intelligence`) on PatchGuard-protected systems; memory; network |
| **PPID spoofing** (`UpdateProcThreadAttribute` → `PROC_THREAD_ATTRIBUTE_PARENT_PROCESS`) | Process-tree heuristics that flag implausible parent-child pairs | Sysmon Event ID 1 records the *spoofed* parent. The real creator shows in ETW `Microsoft-Windows-Kernel-Process` process-start events (the emitting process ≠ `ParentProcessID`); ETW-Ti [verify 2026-10-30] |
| **Module stomping / DLL hollowing** | Module-name signature heuristics; trusts because module is signed | `.text` section hash mismatch vs. on-disk file; memory image; `pe-sieve` / `hollows_hunter` flag the divergence [verify 2026-10-30] |
| **Timestomping** (`SetFileTime`, `$STANDARD_INFORMATION` rewrite) | Filesystem MAC-time timelines | `$FILE_NAME` MFT attribute (a second timestamp set, often missed by attackers); USN journal; AmCache; ShimCache; PCA |
| **Log clearing** (Event Log, journald, audit.log truncation) | The cleared log itself | Backup forwarders (SIEM, syslog server); Event ID 1102 (Security log cleared) survives in subsequent log; carved log fragments from unallocated; memory; network [verify 2026-10-30] |
| **Recycle Bin / shadow copy deletion** (`vssadmin delete shadows`) | VSS-based file recovery | NTFS journal, USN; backups outside the host |
| **Living-off-the-land** (`certutil`, `bitsadmin`, `mshta`, `rundll32`, `regsvr32`, `wmic`) | Signature-based AV; defender heuristics that whitelist signed Microsoft binaries | Command-line logging (4688 + "Include command line in process creation events" policy), Sysmon Event ID 1, PCA, AmCache [verify 2026-10-30] |

**Investigative implication:** when the obvious artifact is missing, look one layer down — `$FILE_NAME` over `$STANDARD_INFORMATION`, AmCache over Prefetch, USN journal over Recycle Bin, Sysmon Event ID 1 over Security 4688, network captures over endpoint telemetry, memory images over disk.

### Keyword Searching

**Using Autopsy:**
```text
Tools → Keyword Search
- Add keyword lists (financial terms, PII, company confidential)
- Regular expressions for patterns (SSN, credit cards, email)
- Run search across all files and unallocated space
```

**Using grep (Linux mounted images):**
```bash
# Search for keyword
grep -r "confidential" /mnt/analysis/

# Case-insensitive
grep -ri "password" /mnt/analysis/

# Regular expression (email addresses)
grep -rE "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b" /mnt/analysis/

# Credit card numbers (basic pattern)
grep -rE "\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b" /mnt/analysis/
```

---

## 5. Documentation & Reporting

### Report Structure

**1. Executive Summary** (1-2 pages for non-technical audience)
- Investigation purpose and scope
- Key findings (bullet points)
- Overall conclusions
- Recommended actions

**2. Case Background**
- Case number and reference
- Date/time investigation initiated
- Requesting party and authorization
- Incident summary

**3. Evidence Inventory**
```text
Evidence ID | Description | Collection Date | Custodian | Hash (SHA-256)
CASE-001    | Dell Laptop | 2025-10-05 UTC  | J. Smith  | abc123...
CASE-002    | USB Drive   | 2025-10-05 UTC  | J. Smith  | def456...
```

**4. Methodology**
- Forensic tools used (name, version, vendor)
- Analysis procedures followed
- Standards/frameworks referenced (NIST SP 800-86, ISO 27037) [verify 2026-10-30]
- Assumptions and limitations

**5. Detailed Findings**
```markdown
### Finding 1: Unauthorized USB Device Usage
**Evidence**: CASE-001 (Laptop), Registry analysis
**Artifact**: SYSTEM\CurrentControlSet\Enum\USBSTOR
**Description**: USB device (SN: 12345) connected on 2025-10-01 14:32 UTC
**Significance**: Device not in authorized hardware list
**Supporting Evidence**:
- Registry key screenshot
- USB device vendor/model details
```

> **IOC defanging is mandatory** for any URL, domain, IP, or email address that appears in a written report or shared electronically. Defanging prevents accidental clicks, automatic URL preview / link expansion in chat clients, mail-gateway sandbox detonation, and search-engine indexing. Convention used across this vault and aligned with [[sop-malware-analysis|Malware Analysis SOP]]:
>
> - URLs: `http` → `hxxp`, `https` → `hxxps` (e.g., `hxxps://malicious[.]example[.]com/payload`)
> - Domains: bracket the dot before the TLD (e.g., `evil[.]com`, `sub.domain[.]net`)
> - IP addresses: bracket each separator (e.g., `192[.]168[.]1[.]1`, `2001[:]db8[::]1`)
> - Email addresses: `@` → `[@]` (e.g., `attacker[@]evil[.]com`)
> - File paths and registry keys do not need defanging.
>
> Quick refanging for analyst use (do not include in deliverables): `sed -e 's/hxxp/http/g; s/\[\.\]/./g; s/\[@\]/@/g'`. CyberChef's "Defang URL" / "Defang IP Addresses" / "Fang URL" operations cover edge cases. [verify 2026-10-30]

**6. Timeline of Events**
```text
2025-10-01 09:15 UTC | User logged in (Event ID 4624)
2025-10-01 14:32 UTC | USB device connected (Registry)
2025-10-01 14:35 UTC | File copied to USB (USN Journal)
2025-10-01 14:40 UTC | USB device removed
2025-10-01 17:00 UTC | User logged off (Event ID 4634)
```

**7. Conclusions**
- Interpretation of findings
- Opinion on what occurred (based on evidence)
- Confidence level (high/medium/low)

**8. Appendices**
- Chain of custody forms
- Tool validation reports
- Screenshots and exhibits
- Hash values and verification logs
- Detailed technical data

### Peer Review
- [ ] Technical review by second examiner
- [ ] Legal review for privilege/confidentiality
- [ ] Quality assurance check (methodology, citations)
- [ ] Final approval by lead investigator

---

## 6. Evidence Storage & Retention

**Secure Storage Requirements:**
```text
Physical Security:
- Locked evidence room with access control
- Climate-controlled (stable temperature and humidity per media-manufacturer specs and your accreditation requirements)
- Fire suppression system
- Video surveillance with retention

Digital Security:
- Encrypted storage (AES-256 minimum)
- Access logging and monitoring
- Backup copies in geographically separate location
- Offline/air-gapped storage for critical cases
```

**Retention Schedule:**
- **Active Investigation**: Secure evidence room, immediate access
- **Post-Investigation (Pending Action)**: Retain per legal hold requirements
- **Closed Cases**: Follow the organizational / regulator retention schedule (varies by jurisdiction and offence type; cite it in the case file)
- **Legal Proceedings**: Retain until final adjudication + appeal period
- **Secure Disposal**: Sanitize per NIST SP 800-88r2 (clear, purge or destroy, matched to the media type; multi-pass overwrite is not needed and DoD 5220.22-M pass counts are obsolete), with a certificate of sanitization [verify 2026-10-29]

---

## 7. Tools Reference

| Tool | Purpose | Platform | Link |
|------|---------|----------|------|
| **Acquisition — disk** |
| FTK Imager | Disk imaging, memory capture | Windows | [exterro.com/digital-forensics-software/ftk-imager](https://www.exterro.com/digital-forensics-software/ftk-imager) (free; formerly AccessData) [verify 2026-10-30] |
| dc3dd | Forensic dd with built-in hashing | Linux | [sourceforge.net/projects/dc3dd](https://sourceforge.net/projects/dc3dd/) [verify 2026-10-30] |
| Guymager | Disk imaging (GUI) | Linux | `apt install guymager` [verify 2026-10-30] |
| ewfacquire (libewf) | E01/EWF imaging with hash verification | Multi | [github.com/libyal/libewf](https://github.com/libyal/libewf) [verify 2026-10-30] |
| **Acquisition — memory** |
| AVML | Linux RAM acquisition (static, no kmod) | Linux | [github.com/microsoft/avml](https://github.com/microsoft/avml) [verify 2026-10-30] |
| LiME | Linux Memory Extractor (kernel module) | Linux | [github.com/jtsylve/LiME](https://github.com/jtsylve/LiME) [verify 2026-10-30] |
| WinPmem / Magnet DumpIt for Windows / Magnet RAM Capture | Windows RAM acquisition (DumpIt: free, x86/x64/ARM64; RAM Capture: last release v1.20, Jul 2019 — legacy) | Windows | [github.com/Velocidex/WinPmem](https://github.com/Velocidex/WinPmem) [verify 2026-10-30] |
| Volexity Surge Collect | Commercial RAM capture — vendor advertises Windows/Linux/macOS; Apple silicon support not stated, confirm with the vendor | Multi | [volexity.com/products-overview/surge](https://www.volexity.com/products-overview/surge/) [verify 2026-10-30] |
| **Live response & triage** |
| KAPE | Targeted artifact collection + parsing | Windows | [kroll.com/kape](https://www.kroll.com/kape) (Kroll; free licence covers internal business use only per the [EULA](https://www.kroll.com/en/kape-license-agreement), paid enterprise licence otherwise) [verify 2026-10-30] |
| Velociraptor | Cross-platform live response & hunting | Multi | [docs.velociraptor.app](https://docs.velociraptor.app/) [verify 2026-10-30] |
| UAC | Unix-like artifacts collector | Linux/macOS/*BSD/AIX/Solaris/ESXi | [github.com/tclahr/uac](https://github.com/tclahr/uac) [verify 2026-10-30] |
| **Analysis** |
| Autopsy / Sleuth Kit | Digital forensics platform + CLI | Multi | [sleuthkit.org](https://www.sleuthkit.org) [verify 2026-10-30] |
| X-Ways Forensics | Commercial forensics suite | Windows | [x-ways.net](https://www.x-ways.net) [verify 2026-10-30] |
| EZ Tools (MFTECmd, EvtxECmd, RECmd, AmcacheParser, AppCompatCacheParser, JLECmd, LECmd, RBCmd, PECmd) | Targeted artifact parsers | Windows / .NET | [ericzimmerman.github.io](https://ericzimmerman.github.io) [verify 2026-10-30] |
| MemProcFS | Mount memory image as filesystem | Multi | [github.com/ufrisk/MemProcFS](https://github.com/ufrisk/MemProcFS) [verify 2026-10-30] |
| **Memory** |
| Volatility 3 | Memory analysis (current) | Multi | [github.com/volatilityfoundation/volatility3](https://github.com/volatilityfoundation/volatility3) [verify 2026-10-30] |
| Volatility 2 | Memory analysis (legacy; deprecated and repo archived May 2025 at the Volatility 3 parity release; last tag 2.6.1, Dec 2018) | Multi | [github.com/volatilityfoundation/volatility](https://github.com/volatilityfoundation/volatility) [verify 2026-10-30] |
| Rekall | Memory forensics (unmaintained since 2017) | Multi | [github.com/google/rekall](https://github.com/google/rekall) [verify 2026-10-30] |
| **Registry** |
| RegRipper3.0 | Windows Registry parser | Multi | [github.com/keydet89/RegRipper3.0](https://github.com/keydet89/RegRipper3.0) [verify 2026-10-30] |
| Registry Explorer / RECmd | Registry viewer (GUI/CLI) | Windows | [ericzimmerman.github.io](https://ericzimmerman.github.io) [verify 2026-10-30] |
| **Event logs** |
| Hayabusa | Sigma-driven EVTX timeline | Multi | [github.com/Yamato-Security/hayabusa](https://github.com/Yamato-Security/hayabusa) [verify 2026-10-30] |
| Chainsaw | Fast EVTX hunting with Sigma | Multi | [github.com/WithSecureOpenSource/chainsaw](https://github.com/WithSecureOpenSource/chainsaw) [verify 2026-10-30] |
| **Timeline** |
| log2timeline / Plaso | Super timeline creation | Multi | [github.com/log2timeline/plaso](https://github.com/log2timeline/plaso) [verify 2026-10-30] |
| Timesketch | Timeline analysis platform | Multi | [github.com/google/timesketch](https://github.com/google/timesketch) [verify 2026-10-30] |
| **Mobile / iOS / Android** |
| Cellebrite UFED / Inseyets | Mobile extraction (LE-grade) | Windows | [cellebrite.com](https://www.cellebrite.com) [verify 2026-10-30] |
| Magnet AXIOM | Mobile / computer / cloud forensics | Windows | [magnetforensics.com](https://www.magnetforensics.com) [verify 2026-10-30] |
| MSAB XRY | LE-grade mobile extraction | Windows | [msab.com](https://www.msab.com) [verify 2026-10-30] |
| Oxygen Forensic Detective | Broad app coverage incl. messengers | Windows | [oxygenforensics.com](https://www.oxygenforensics.com) [verify 2026-10-30] |
| iLEAPP / ALEAPP | Open-source iOS / Android artifact parser | Multi (Python) | [github.com/abrignoni/iLEAPP](https://github.com/abrignoni/iLEAPP) [verify 2026-10-30] |
| MVT | Spyware / IOC scan for mobile | Multi (Python) | [mvt.re](https://mvt.re) [verify 2026-10-30] |
| **macOS** |
| mac_apt | macOS / iOS artifact parser | Multi (Python) | [github.com/ydkhatri/mac_apt](https://github.com/ydkhatri/mac_apt) [verify 2026-10-30] |
| APOLLO | Apple Pattern of Life timeline | Multi (Python) | [github.com/mac4n6/APOLLO](https://github.com/mac4n6/APOLLO) [verify 2026-10-30] |
| macos-UnifiedLogs | Parse `.tracev3` unified logs offline | Multi | [github.com/mandiant/macos-UnifiedLogs](https://github.com/mandiant/macos-UnifiedLogs) [verify 2026-10-30] |
| **Network** |
| Wireshark | Packet analysis | Multi | [wireshark.org](https://www.wireshark.org) [verify 2026-10-30] |
| NetworkMiner | PCAP analysis (file/credential carving) | Windows (Linux via Mono) | [netresec.com](https://www.netresec.com) [verify 2026-10-30] |
| Zeek | Network metadata + protocol logs | Multi | [zeek.org](https://zeek.org) [verify 2026-10-30] |
| **Cloud** |
| AWS CLI / Athena | CloudTrail / S3 audit pull and SQL query | Multi | [aws.amazon.com/cli](https://aws.amazon.com/cli/) [verify 2026-10-30] |
| Azure CLI / Microsoft Graph PowerShell | Activity Log, Entra ID, M365 UAL | Multi | [learn.microsoft.com/cli/azure](https://learn.microsoft.com/cli/azure/) [verify 2026-10-30] |
| gcloud / Workspace Reports API | GCP audit + Workspace audit | Multi | [cloud.google.com/sdk](https://cloud.google.com/sdk) [verify 2026-10-30] |
| **Process / system** |
| System Informer | Process / handle / module inspection (formerly Process Hacker) | Windows | [github.com/winsiderss/systeminformer](https://github.com/winsiderss/systeminformer) [verify 2026-10-30] |
| Process Monitor / Process Explorer | Live procmon / process tree | Windows | [Sysinternals](https://learn.microsoft.com/sysinternals/) [verify 2026-10-30] |
| Sysmon | Endpoint event telemetry | Windows | [Sysinternals](https://learn.microsoft.com/sysinternals/downloads/sysmon) [verify 2026-10-30] |

---

## 8. Legal & Quality Assurance

### Admissibility (Court Standards)

**Admissibility (US Federal — FRE 702 as amended 1 Dec 2023, applying *Daubert*):**
- [ ] Proponent can show the court, more likely than not, that (a) the expert's knowledge will help the trier of fact, (b) the testimony is based on sufficient facts or data, (c) it is the product of reliable principles and methods, and (d) the opinion reflects a reliable application of those principles and methods to the facts of the case (FRE 702(a)–(d)) [verify 2026-10-30]
- [ ] *Daubert* reliability factors documented: whether the technique can be (and has been) tested; peer review and publication; known or potential rate of error and the existence and maintenance of standards controlling the technique's operation; general acceptance in the field [verify 2026-10-30]
- [ ] No overstated certainty: no "absolute / 100 % certainty" or "reasonable degree of scientific certainty" claims for subjective methods; give an error-rate estimate where one exists (FRE 702, 2023 Committee Note) [verify 2026-10-30]
- [ ] Digital evidence authenticated under FRE 901(a); hash-verified copies (FRE 902(14)) and system-generated records (FRE 902(13)) can be self-authenticated by a qualified person's certification, with notice under FRE 902(11) [verify 2026-10-30]

**Chain of Custody Requirements:**
- Continuous accountability from collection → court
- Documentation of every transfer
- Ability to demonstrate evidence integrity (hashes) [verify 2026-10-30]
- Explanation of any gaps or anomalies

**Expert Witness Preparation:**
- Curriculum vitae (education, training, certifications)
- Prior testimony experience
- Case-specific preparation (review all notes, reports)
- Mock cross-examination practice

### Standards & Certifications

**Industry Standards:**
- **NIST SP 800-86**: Guide to Integrating Forensic Techniques into Incident Response [verify 2026-10-30]
- **ISO/IEC 27037:2012**: Guidelines for identification, collection, acquisition and preservation of digital evidence [verify 2026-10-30]
- **UK — Forensic Science Regulator Code of Practice v2** (statutory under the Forensic Science Regulator Act 2021, England & Wales; in force 2 Oct 2025, replacing v1 of 2 Oct 2023): FSA DIG 100 (data capture, processing and analysis from digital storage devices) requires accreditation to ISO/IEC 17025:2017, assessed by UKAS — [gov.uk](https://www.gov.uk/government/publications/forensic-science-activities-statutory-code-of-practice-version-2) [verify 2026-10-30]
- **ACPO Good Practice Guide for Digital Evidence** v5 (Oct 2011, published Mar 2012): the four UK digital-evidence principles; non-statutory, historical context [verify 2026-10-30]
- **SWGDE**: Scientific Working Group on Digital Evidence [verify 2026-10-30]

**Professional Certifications:**
- **GCFE**: GIAC Certified Forensic Examiner [verify 2026-10-30]
- **EnCE**: EnCase Certified Examiner [verify 2026-10-30]
- **CFCE**: Certified Forensic Computer Examiner [verify 2026-10-30]
- **CCE**: Certified Computer Examiner (ISFCE) [verify 2026-10-30]
- **CHFI**: Computer Hacking Forensic Investigator [verify 2026-10-30]

---

## 9. Common Pitfalls

- ❌ Working on original evidence instead of forensic copies
- ❌ Not documenting system state before collection
- ❌ Powering off live systems (losing volatile data)
- ❌ Using untrusted/compromised system tools
- ❌ Forgetting to use write blockers
- ❌ Not verifying hash values throughout process
- ❌ Incomplete chain of custody documentation
- ❌ Analyzing without proper authorization
- ❌ Not time-syncing analysis systems
- ❌ Failing to document tool versions and commands
- ❌ Not preserving metadata (incorrect file copy methods)
- ❌ Inadequate privilege review (exposing attorney-client material)
- ❌ Over-relying on automated tools without validation
- ❌ Poor report writing (technical jargon for legal audience)

---

## 10. Quick Reference Checklist

**Immediate Response:**
- [ ] Obtain authorization
- [ ] Photograph scene
- [ ] Document system state
- [ ] Isolate from network
- [ ] Capture volatile memory (if running)
- [ ] Initiate chain of custody

**Evidence Collection:**
- [ ] Use write blockers
- [ ] Create forensic images
- [ ] Generate SHA-256 hash (primary; current NSRL RDSv3 carries SHA-256, SHA-1 and MD5); MD5/SHA-1 secondary, for legacy RDS 2.x text sets, AV/threat-intel lookups and older case files [verify 2026-10-30]
- [ ] Verify image integrity
- [ ] Label and seal evidence
- [ ] Store securely

**Analysis:**
- [ ] Work only on copies
- [ ] Document all commands/tools
- [ ] Maintain analysis log
- [ ] Extract artifacts systematically
- [ ] Build timeline
- [ ] Correlate findings

**Reporting:**
- [ ] Executive summary
- [ ] Detailed findings with evidence
- [ ] Timeline of events
- [ ] Methodology documentation
- [ ] Peer review
- [ ] Legal review

---

## Related SOPs

**Analysis:**
- [[../Analysis/sop-reverse-engineering|Reverse Engineering]] - Binary analysis during forensic investigation
- [[../Analysis/sop-cryptography-analysis|Cryptography Analysis]] - Encrypted data recovery and analysis
- [[../Analysis/sop-malware-analysis|Malware Analysis]] - Malware forensics and artifact analysis
- [[../Analysis/sop-hash-generation-methods|Hash Generation Methods]] - Evidence integrity verification

**Pentesting & Security:**
- [[sop-linux-pentest|Linux Pentesting]] - Linux system compromise investigation
- [[sop-ad-pentest|Active Directory Pentesting]] - AD attack pattern identification
- [[sop-web-application-security|Web Application Security]] - Web application compromise investigation
- [[sop-mobile-security|Mobile Security]] - Mobile device forensics
- [[sop-firmware-reverse-engineering|Firmware Reverse Engineering]] - IoT and embedded device forensics
- [[sop-detection-evasion-testing|Detection Evasion Testing]] - Understanding anti-forensics techniques
- [[sop-vulnerability-research|Vulnerability Research]] - Identifying exploitation artifacts

**Investigations:**
- [[../../Investigations/Techniques/sop-collection-log|Collection Log & Chain of Custody]] - Canonical chain-of-custody and evidence-hashing workflow
- [[../../Investigations/Techniques/sop-legal-ethics|Legal & Ethics]] - Authorization, jurisdiction, prohibited actions
- [[../../Investigations/Techniques/sop-opsec-plan|OPSEC Planning]] - Investigator OPSEC during live response

---

**Version:** 2.0
**Last Updated:** 2026-10-30
**Review Frequency:** Quarterly (cloud, mobile-vendor, and Volatility ecosystems rot fastest)