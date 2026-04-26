---
type: sop
title: Digital Forensics Investigation SOP
description: "Conduct digital forensics: disk imaging, memory analysis, artifact recovery, timeline creation & chain of custody. Tools: FTK, Autopsy, Volatility."
tags: [sop, forensics, incident-response, dfir, investigation]
template_version: 2026-04-25
updated: 2026-04-25
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
```
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
2. RAM (running processes, network connections)
3. Swap/pagefile
4. Hard disk
5. Remote logging and monitoring data
6. Physical configuration, network topology
7. Archival media (backups, offline storage)

### Immediate Actions

**If system is RUNNING:**
```bash
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
```bash
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
# Using FTK Imager
FTK Imager.exe → File → Capture Memory
# Output: memdump.mem

# Using Magnet RAM Capture
MagnetRAMCapture.exe
# Follow GUI prompts

# Using DumpIt
DumpIt.exe
# Automatically dumps to DumpIt.exe directory
```

**Linux:**
```bash
# LiME (Linux Memory Extractor) — kernel module; must be built against the EXACT running kernel
# (uname -r). Pre-build in a clean test VM with matching headers, then load on the target.
insmod lime.ko "path=/mnt/usb/memory.lime format=lime"
# Or stream over TCP to investigator host (avoids touching target disk):
insmod lime.ko "path=tcp:4444 format=lime"
# Investigator: nc target 4444 > memory.lime

# AVML (Microsoft, statically linked, no kernel module required — preferred for cloud/containers)
sudo ./avml --compress memory.lime.compressed

# /proc/kcore (read via static memcap or LiME's "lime-forensics-static") — limited to mapped kernel memory
# /dev/mem and /dev/crash are restricted (CONFIG_STRICT_DEVMEM=y on modern kernels) — generally unusable
```

**macOS:**
```bash
# Note: traditional macOS RAM acquisition tooling has degraded. SIP, kernel extension deprecation
# (KEXTs disabled by default since macOS 11), and hypervisor-protected memory regions on Apple Silicon
# have made full physical RAM capture difficult or impossible without DMA / EFI access.
# OSXPmem (Rekall project) and Volexity Surge Collect are the historical tools; verify current
# support for the exact macOS major version before relying on either. [verify 2026-04-25]

# Live triage alternative: collect runtime state without a full RAM image
sudo log collect --output sysdiagnose-$(date +%Y%m%d).logarchive    # unified log capture
sudo sysdiagnose -f /tmp/sysdiagnose                                # full diagnostic bundle (heavyweight)

# Volexity Surge Collect Pro (commercial) — supports current macOS including Apple Silicon [verify 2026-04-25]
# osxpmem (Rekall) — last release 2017, unmaintained; Rekall itself is end-of-life
```

### System State Documentation

**Capture before imaging:**
```bash
# Windows (from external USB with forensic tools)
date /t && time /t > system_info.txt
echo %COMPUTERNAME% >> system_info.txt
ipconfig /all >> system_info.txt
netstat -ano >> netstat.txt
tasklist /v >> processes.txt
net user >> users.txt
net localgroup administrators >> admins.txt

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
ifconfig > system_info.txt
netstat -an > netstat.txt
ps aux > processes.txt
last > login_history.txt
```

### Network Isolation

**Immediate containment:**
```bash
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
```
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
```bash
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
- **Software Write Blockers**: Linux live boot (read-only mount), FTK Imager

**Creating Forensic Images:**

**Using dd (Linux):**
```bash
# Identify target disk
lsblk
fdisk -l

# Create forensic image with write blocker attached
dd if=/dev/sdb of=/mnt/evidence/case001-disk.dd bs=512 conv=noerror,sync status=progress

# Create split image (for FAT32 file systems with 4GB limit)
dd if=/dev/sdb bs=512 conv=noerror,sync | split -b 4000M - /mnt/evidence/case001-disk.dd.

# Generate hash simultaneously
dd if=/dev/sdb bs=512 conv=noerror,sync | tee /mnt/evidence/case001-disk.dd | sha256sum > case001-disk.dd.sha256
```

**Using dc3dd (Enhanced dd for forensics):**
```bash
# Image with built-in hashing
dc3dd if=/dev/sdb of=/mnt/evidence/case001-disk.dd hash=sha256 hash=md5 log=/mnt/evidence/case001.log

# Source hash verification (read-only re-hash to confirm acquisition matches the live source)
dc3dd if=/dev/sdb hash=sha256 hash=md5 log=/mnt/evidence/verify.log
```

**Using FTK Imager (Windows/GUI):**
```
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
```
1. Launch Guymager
2. Right-click target drive → Acquire image
3. File format: Expert Witness Format (E01) or dd
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

### Hash Verification

> **Algorithm choice.** SHA-256 is the minimum baseline for new evidence (NIST FIPS 180-4). MD5 is broken by practical collisions (Wang et al. 2004) and SHA-1 is broken by the SHAttered collision (2017) — record them only as a *secondary* hash for legacy compatibility. Never rely on MD5 or SHA-1 alone in court. See [[sop-hash-generation-methods|Hash Generation Methods]] for full guidance, integration with FTK/EnCase/Autopsy, and verification scripts.

**Generate hashes:**
```bash
# SHA-256 (primary — required)
sha256sum case001-disk.dd > case001-disk.dd.sha256

# MD5 + SHA-1 (secondary — legacy compatibility / NSRL lookups only)
md5sum case001-disk.dd > case001-disk.dd.md5
sha1sum case001-disk.dd > case001-disk.dd.sha1

# Verify later (sha256sum -c reads "<hash>  <filename>" format directly)
sha256sum -c case001-disk.dd.sha256
```

**Windows (PowerShell):**
```powershell
# SHA-256
Get-FileHash -Path C:\Evidence\case001-disk.dd -Algorithm SHA256 | Format-List

# MD5
Get-FileHash -Path C:\Evidence\case001-disk.dd -Algorithm MD5 | Format-List

# Save to file
Get-FileHash -Path C:\Evidence\case001-disk.dd -Algorithm SHA256 | Out-File C:\Evidence\case001-disk.dd.sha256.txt
```

### Mobile Device Acquisition

> **Tool versioning.** Vendor tools are tightly version-locked to the OS — Cellebrite UFED, Magnet AXIOM, GrayKey, and Elcomsoft iOS Forensic Toolkit publish per-iOS / per-Android support matrices that change every minor release. Always check the vendor matrix against the target's exact OS build before acquisition; an iOS 17.4 device may be unsupported by a UFED build that handled 17.3. [verify 2026-04-25]

**Preparation:**
```bash
# Immediate isolation
1. Place device in Faraday bag (blocks cellular/Wi-Fi/Bluetooth/UWB)
2. If device is on: enable airplane mode FIRST, then disable Wi-Fi and Bluetooth explicitly (airplane mode does not always disable both on iOS)
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
# iOS logical backup (libimobiledevice)
idevice_id -l                            # confirm device is paired
idevicebackup2 backup --full /path/to/backup

# Encrypted iTunes backup with known password (richer artifact set than unencrypted)
idevicebackup2 -i backup --full /path/to/backup
# Decrypt later with: iphone-backup-decrypt or Magnet AXIOM / Cellebrite Reader

# Android — modern (recommended): ADB pull of accessible app data on rooted/dev devices
adb devices
adb shell pm list packages -f            # enumerate package paths
adb pull /sdcard/                        # external storage
adb pull /data/data/<package>/           # rooted only

# Android — legacy `adb backup` is deprecated in Android 12+ and removed in Android 13;
# many OEMs (Samsung, Huawei) disabled it years earlier. Prefer vendor tooling or
# Android Backup Extractor (`abe.jar`) only for legacy devices that still honor it.
adb backup -all -apk -shared -system -f backup.ab   # Android <=11 only [verify 2026-04-25]
```

**Filesystem / Physical Acquisition:**
- **Filesystem (iOS)** — checkm8-based tools (checkra1n family, palera1n) on A11-and-earlier hardware reach a fuller filesystem; A12+ devices generally require GrayKey or comparable LE-grade tooling
- **Physical (Android)** — chip-off, JTAG, ISP, EDL (Qualcomm Emergency Download), or vendor exploits via Cellebrite/MSAB; recovers deleted data and full userdata partition
- **Advanced iOS** — Cellebrite UFED Premium, GrayKey, Elcomsoft iOS Forensic Toolkit; capability is OS-version-bounded and often LE-restricted

**Vendor Tools:**
- **Cellebrite UFED / UFED Premium / Inseyets** — physical/logical/filesystem extraction, lock bypass; UFED 4PC + UFED Touch hardware; OS support matrix updated monthly [verify 2026-04-25]
- **Magnet AXIOM (Process / Examine)** — mobile + computer + cloud; iOS/Android filesystem & full-file-system parsing, biome/KnowledgeC enrichment [verify 2026-04-25]
- **MSAB XRY** — LE-grade physical/logical, decoding of 30k+ apps [verify 2026-04-25]
- **Oxygen Forensic Detective** — broad app coverage including encrypted messengers
- **Elcomsoft iOS Forensic Toolkit** — checkm8-based imaging on supported iPhones; keychain extraction [verify 2026-04-25]
- **GrayKey (Magnet/Grayshift)** — passcode brute-force and full-file-system on supported iOS [verify 2026-04-25]

**Open-source parsing (run AFTER vendor extraction):**
- **iLEAPP** ([github.com/abrignoni/iLEAPP](https://github.com/abrignoni/iLEAPP)) — parses iOS extractions: KnowledgeC, biome, PowerLog, Photos.sqlite, Health, app artifacts; HTML/TSV/KML reports
- **ALEAPP** ([github.com/abrignoni/ALEAPP](https://github.com/abrignoni/ALEAPP)) — Android counterpart: usagestats, accessibility, Wi-Fi history, app artifacts
- **VLEAPP / WLEAPP / RLEAPP** — vehicle, watch, returns extractions in the same family
- **APOLLO** ([github.com/mac4n6/APOLLO](https://github.com/mac4n6/APOLLO)) — Apple Pattern of Life Lazy Output'er; correlates KnowledgeC, biome, Health, PowerLog into a single timeline
- **artex / mvt-ios / mvt-android** ([mvt.re](https://mvt.re)) — Mobile Verification Toolkit (Amnesty International); spyware indicator scanning against STIX2 IOC bundles

**Cloud & SIM Card:**
```bash
# SIM card reader acquisition (Cellebrite UME-36Pro, MSAB XRY, dedicated PC/SC reader)
# Capture: ICCID, IMSI, ADN/SMS, LOCI/PSLOCI (last cell location), authentication keys (Ki not extractable on modern SIMs)

# Cloud data preservation — legal process required (subpoena/warrant/MLAT):
# - iCloud (Apple): backups, Photos, iCloud Drive, Find My, Messages-in-iCloud
# - Google Account: Takeout export, Workspace audit (admins), Location History (now "Timeline", on-device since 2024)
# - Microsoft 365 / OneDrive: Compliance Search + UAL (see Cloud Forensics §3)
# - Dropbox / Box / Slack / Discord: provider-specific legal request portals
# Preservation letter (US) or Article 18 Budapest Convention request (cross-border) freezes data pending warrant.
```

### Cloud Evidence Acquisition

> **Authority and provider cooperation.** Cloud evidence acquisition almost always requires (a) tenant-admin authorization, (b) provider legal process (subpoena/warrant/preservation letter), or both. Verify legal basis with counsel before issuing API calls — even read-only collection can violate ToS or data-residency law. Cross-border requests usually go through MLAT or the Budapest Convention.

**Triage rules:**
- Pull *audit/control-plane* logs first (who did what) — they have shorter retention and are the highest-value evidence for incident scoping.
- Pull *data-plane* logs (S3 access, Drive opens) second — far higher volume, longer retention windows for many providers.
- Snapshot/preserve before mutating: copy logs out of the source tenant into investigator-controlled storage with hash verification before any analysis.

#### AWS

```bash
# Confirm CloudTrail is enabled across all regions and identify the trail's S3 destination
aws cloudtrail describe-trails --include-shadow-trails
aws cloudtrail get-trail-status --name <trail-name>

# Lookup recent control-plane events (90-day default lookup window via the API; full retention in the S3 bucket)
aws cloudtrail lookup-events --start-time 2026-04-01T00:00:00Z --end-time 2026-04-25T00:00:00Z \
    --lookup-attributes AttributeKey=Username,AttributeValue=<suspect-iam-user>

# Pull the underlying CloudTrail logs from S3 (gzipped JSON, one object per ~5 min per region)
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

Key services: **CloudTrail** (control plane), **GuardDuty** (threat detection), **VPC Flow Logs** (network), **S3 Server Access Logs / S3 Access Analyzer** (object access), **IAM Access Analyzer** (over-permissioned roles), **Config** (resource state history). Default CloudTrail management-event retention in Event history is 90 days; long-term retention requires a trail writing to S3.

#### Azure / Microsoft 365

```bash
# Azure Activity Log (subscription/tenant control-plane events)
az login
az monitor activity-log list --start-time 2026-04-01T00:00:00Z --end-time 2026-04-25T00:00:00Z \
    --max-events 1000 --output json > activity-log.json

# Microsoft Entra ID (Azure AD) sign-in and audit logs — primary identity-compromise evidence
az rest --method GET --uri "https://graph.microsoft.com/v1.0/auditLogs/signIns?\$filter=createdDateTime ge 2026-04-01T00:00:00Z"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/auditLogs/directoryAudits?\$filter=activityDateTime ge 2026-04-01T00:00:00Z"

# M365 Unified Audit Log (UAL) via Exchange Online PowerShell (Search-UnifiedAuditLog is the
# legacy synchronous cmdlet; for large pulls Microsoft now recommends the Audit Search Graph API
# or `New-MailboxAuditLogSearch` / `Start-MailboxFolderAuditLogSearch`)
Connect-ExchangeOnline -UserPrincipalName <admin>@<tenant>
Search-UnifiedAuditLog -StartDate 2026-04-01 -EndDate 2026-04-25 -UserIds <upn> -ResultSize 5000

# Defender / Purview Compliance — content searches for mailbox content (eDiscovery)
# Compliance Center → Content search → New search → scope to user/site/team
```

Key sources: **Azure Activity Log**, **Entra ID sign-in/audit logs**, **M365 Unified Audit Log (UAL)**, **Defender for 365** (alerts, threat-explorer), **Purview eDiscovery** (mailbox/SharePoint/Teams content). UAL retention is **180 days** for most plans, **365 days** with Audit Standard, and up to **10 years** with Audit Premium add-on [verify 2026-04-25].

#### Google Cloud / Workspace

```bash
# GCP Cloud Audit Logs (Admin Activity, Data Access, System Event, Policy Denied)
gcloud auth login
gcloud logging read 'protoPayload.serviceName="iam.googleapis.com" AND timestamp>="2026-04-01T00:00:00Z"' \
    --project=<project> --format=json > gcp-iam-audit.json

# Export audit logs to a sink (BigQuery, Cloud Storage, Pub/Sub) for long-term preservation
gcloud logging sinks create case-001-sink storage.googleapis.com/<bucket> \
    --log-filter='logName:"cloudaudit.googleapis.com"'

# Google Workspace Reports / Audit API — admin, login, drive, gmail, mobile, token, groups, calendar
# Required scope: https://www.googleapis.com/auth/admin.reports.audit.readonly
curl -H "Authorization: Bearer $GOOGLE_ADMIN_TOKEN" \
    "https://admin.googleapis.com/admin/reports/v1/activity/users/all/applications/login?startTime=2026-04-01T00:00:00Z"

# Gmail / Drive content via Vault (eDiscovery)
# admin.google.com → Vault → Matter → Hold + Search + Export
```

Key sources: **Cloud Audit Logs** (Admin Activity is enabled by default and free; Data Access is opt-in and billed), **Workspace Reports/Audit** (login, drive, admin, token, gmail, mobile), **Google Vault** (eDiscovery hold + export), **Security Center** (findings), **VPC Flow Logs**.

#### SaaS / Identity

- **Okta** — System Log API (`/api/v1/logs`); 90-day default retention, longer with subscription
- **Slack** — Audit Logs API (Enterprise Grid only); Discovery API for content
- **GitHub** — Audit Log API (org/enterprise); push, fork, repo creation, OAuth grants
- **Salesforce** — Setup Audit Trail (180 days), Event Monitoring (with add-on), Login History

**Acquisition hashing:** treat exported logs and snapshots like any other digital evidence — hash on download (SHA-256), record source URL/API endpoint and timestamp range, store with a chain-of-custody entry per [[../../Investigations/Techniques/sop-collection-log|Collection Log]].

### Network Evidence

**Packet Capture:**
```bash
# Live capture with tcpdump
tcpdump -i eth0 -w capture.pcap

# Capture specific host
tcpdump -i eth0 host 192.168.1.100 -w host_capture.pcap

# Capture specific port
tcpdump -i eth0 port 443 -w https_capture.pcap

# Wireshark (GUI)
# Capture → Options → Select interface → Start
```

**Log Collection:**
```bash
# Windows Event Logs
wevtutil epl Security C:\Evidence\Security.evtx
wevtutil epl System C:\Evidence\System.evtx
wevtutil epl Application C:\Evidence\Application.evtx

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
```bash
# CRITICAL RULE: Never work on original evidence
1. Verify hash of forensic image matches collection hash
2. Create working copy of forensic image
3. Document analysis workstation specs
4. Use isolated analysis network (no internet for malware analysis)
5. Time-sync all analysis systems to UTC
```

**Analysis Documentation:**
```
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
# Mount E01 image (requires ewf-tools/libewf)
ewfmount image.E01 /mnt/ewf
mount -o ro,loop,noexec /mnt/ewf/ewf1 /mnt/analysis

# Mount dd image (read-only)
mount -o ro,loop,noexec image.dd /mnt/analysis

# Mount with specific filesystem
mount -t ntfs-3g -o ro,loop,noexec image.dd /mnt/analysis
```

**FTK Imager (Windows):**
```
1. File → Add Evidence Item
2. Select Image File → Browse to E01/dd file
3. Evidence tree shows filesystem
4. Right-click folders → Export files (preserves metadata)
```

### File System Analysis

**Autopsy (Open Source Forensics Platform):**
```
1. Create New Case
2. Add Data Source → Disk Image
3. Select ingest modules:
   - File Type Identification
   - Extension Mismatch Detector
   - Deleted File Recovery
   - Hash Lookup (NSRL, known bad hashes)
   - Keyword Search
   - Email Parser
   - Web Artifacts
4. Run analysis
5. Review results in tree view/table
```

**Deleted File Recovery:**
```bash
# Using Sleuth Kit
fls -r -d image.dd > deleted_files.txt  # List deleted files
icat image.dd [inode] > recovered_file.dat  # Recover specific file

# Using Scalpel (file carving)
scalpel -c scalpel.conf -o /output image.dd

# Using PhotoRec (GUI/CLI)
photorec image.dd
```

**File Metadata Examination:**
```bash
# Using Sleuth Kit
ils image.dd  # List inodes (including deleted)
istat image.dd [inode]  # Get detailed inode info

# Using exiftool (extract EXIF data)
exiftool image.jpg > image_metadata.txt
exiftool -r /mnt/analysis/Users/JohnDoe/Pictures > all_photo_metadata.txt

# NTFS $MFT parsing — must extract $MFT from the image first (it lives at the root of the volume)
# Option A: Sleuth Kit
icat image.dd 0 > MFT.bin                            # inode 0 is $MFT on NTFS

# Option B: mount image read-only and copy via NTFS-3G (preserves the file)
mount -o ro,loop,noexec,show_sys_files,streams_interface=windows image.dd /mnt/analysis
cp /mnt/analysis/\$MFT ./MFT.bin

# Parse — MFTECmd (Eric Zimmerman) is the modern recommendation; analyzeMFT is also fine
MFTECmd.exe -f MFT.bin --csv .\out --csvf mft.csv     # also parses $J / $LogFile / $Boot / $SDS
analyzeMFT.py -f MFT.bin -o mft_timeline.csv
```

### Timeline Construction

**Using log2timeline / Plaso** (current release ~20240826; releases are date-versioned) [verify 2026-04-25]:
```bash
# Create the storage file (Plaso 2.x default storage format is SQLite)
log2timeline.py --storage-file timeline.plaso image.dd

# Limit parsers for speed (skip noisy ones during initial triage)
log2timeline.py --parsers '!filestat,!winreg' --storage-file timeline.plaso image.dd

# Convert / filter to CSV with psort
psort.py -o l2tcsv -w timeline.csv timeline.plaso

# Date-range filter (psort filter expression syntax)
psort.py -o l2tcsv -w filtered.csv timeline.plaso "date > '2026-04-01' AND date < '2026-04-25'"

# User filter
psort.py -o l2tcsv -w user_timeline.csv timeline.plaso "username contains 'johndoe'"

# Native output for Timesketch ingestion (recommended for >1 GB timelines)
psort.py -o opensearch_ts -w analysis.jsonl timeline.plaso
```

**Manual timeline (Mac Times):**
```bash
# Sleuth Kit fls + mactime — fast bodyfile generation when you only want filesystem MAC times
fls -m C:/ -r image.dd > bodyfile.txt
mactime -b bodyfile.txt -d > timeline.csv
```

**Timeline Analysis Tools:**
- **Timesketch** ([github.com/google/timesketch](https://github.com/google/timesketch)) — web-based collaborative timeline analysis with sketches, tagging, Sigma-rule running, and AI-assisted analysis (newer releases)
- **Timeline Explorer** (Eric Zimmerman) — Windows GUI for filtering CSV/L2TCSV timelines
- **Hayabusa** ([github.com/Yamato-Security/hayabusa](https://github.com/Yamato-Security/hayabusa)) — Sigma-driven Windows event log timeline; produces a triage-ready CSV in minutes
- **Chainsaw** ([github.com/WithSecureLabs/chainsaw](https://github.com/WithSecureLabs/chainsaw)) — fast EVTX hunting with Sigma + custom rules

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
# Using RegRipper (rr.exe / rip.pl). RegRipper3.0 is current; profile-mode plugins live in plugins/
rip.pl -r SAM -p sam > sam_output.txt
rip.pl -r SYSTEM -p system > system_output.txt
rip.pl -r SOFTWARE -p software > software_output.txt
rip.pl -r NTUSER.DAT -p ntuser > ntuser_output.txt
rip.pl -r UsrClass.dat -p usrclass > usrclass_output.txt

# Eric Zimmerman's Registry Explorer / RECmd (Windows GUI/CLI) is the modern alternative
RECmd.exe --bn BatchExamples\\RegistryASEPs.reb -d C:\\Evidence\\hives --csv .\\out

# Key artifacts (legacy, well-known):
# - USB device history:           SYSTEM\CurrentControlSet\Enum\USBSTOR + USB
# - UserAssist (GUI execution):   NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist (ROT13-encoded value names)
# - ShimCache / AppCompatCache:   SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache (program path + last-modified time of binary; size capped at ~1024 entries on Win10/11)
# - Run keys:                     SOFTWARE\Microsoft\Windows\CurrentVersion\Run, RunOnce; NTUSER.DAT\...\Run
# - Services:                     SYSTEM\CurrentControlSet\Services
# - Scheduled tasks (XML):        C:\Windows\System32\Tasks\ + SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree
```

**Modern Windows execution & activity artifacts** (these are frequently the most useful and are easy to miss):

| Artifact | Location | What it records | Parser |
|---|---|---|---|
| **AmCache.hve** | `C:\Windows\AppCompat\Programs\Amcache.hve` | Every executed PE: full path, SHA1, PE header fields, first-execution time, publisher | `AmcacheParser.exe` (EZ Tools); RegRipper `amcache` plugin |
| **ShimCache (AppCompatCache)** | Registry `SYSTEM\...\AppCompatCache` | Path + last-modified timestamp + execution flag; populated on shutdown | `AppCompatCacheParser.exe` (EZ Tools) |
| **BAM / DAM** | `SYSTEM\CurrentControlSet\Services\bam\State\UserSettings\<SID>` and `dam\...` | Per-user, per-binary last execution time (FILETIME); BAM = foreground apps, DAM = Desktop Activity Moderator | RegRipper `bam` plugin; raw `reg.exe query` |
| **PCA (Program Compatibility Assistant)** | `C:\Windows\appcompat\pca\PcaAppLaunchDic.txt`, `PcaGeneralDb0.txt`, `PcaGeneralDb1.txt` (Win11 22H2+) | Tab-separated execution log: full path + first/last execution time + ABI status | manual review; community `PCA Parser` scripts [verify 2026-04-25] |
| **SRUM (System Resource Usage Monitor)** | `C:\Windows\System32\sru\SRUDB.dat` (ESE database) | Per-process network bytes sent/received, energy, application runtime — hourly buckets, ~30-60 day retention | `srum-dump` (Mark Baggett) or `SRUM-DUMP3`; KAPE module |
| **UserAssist** | `NTUSER.DAT\...\Explorer\UserAssist\{GUID}\Count` | GUI-launched programs and shortcuts: count, focus time, last execution (ROT13 names) | RegRipper `userassist`; `UserAssistView` (NirSoft) |
| **Prefetch** | `C:\Windows\Prefetch\*.pf` | First/last 8 run timestamps, run count, files referenced, volumes; disabled by default on SSD-only systems prior to Win10 1803 | `PECmd.exe` (EZ Tools) |
| **JumpLists** | `%AppData%\Microsoft\Windows\Recent\(Custom|Automatic)Destinations\*.{customDestinations,automaticDestinations}-ms` | Recently opened files per application (per AppID) | `JLECmd.exe` (EZ Tools) |
| **LNK files** | `%AppData%\Microsoft\Windows\Recent\*.lnk`; user Desktop and SendTo | Target path, MAC times, volume serial, MAC address, NetBIOS name of host that created the link | `LECmd.exe` (EZ Tools); ExifTool |
| **Recycle Bin metadata** | `C:\$Recycle.Bin\<SID>\$I*` (index) and `$R*` (renamed content) | Original filename, original path, deletion timestamp, original size — even after empty if `$R` is recovered from unallocated | `RBCmd.exe` (EZ Tools) |
| **Windows Event Logs** | `C:\Windows\System32\winevt\Logs\*.evtx` | Security (4624 logon, 4634 logoff, 4688 process create with cmdline), System, Application, PowerShell/Operational (4104 script block), Sysmon (1/3/7/10/11/13) | `EvtxECmd.exe` (EZ Tools); `Get-WinEvent`; Hayabusa for fast triage |
| **USN Journal ($J)** | `\$Extend\$UsnJrnl:$J` (NTFS ADS) | Filesystem change journal (CREATE/DELETE/RENAME with timestamps); typically days to weeks of history | `MFTECmd.exe --json -f $UsnJrnl --csv .` |
| **$LogFile** | NTFS volume root `\$LogFile` | NTFS transaction log; recoverable transactions for very recent activity | `NTFS Log Tracker` |

**KAPE (Kroll Artifact Parser and Extractor)** is the canonical workflow for collecting and parsing this set — `kape.exe --tsource C: --target KapeTriage --tdest .\out --module !EZParser` runs targets (collection) followed by modules (parsing) end-to-end.

### macOS Artifacts

**Filesystem & system snapshots:**
- **APFS local snapshots** — Time Machine writes ~24 h of read-only snapshots even without an external disk; `tmutil listlocalsnapshots /` enumerates them, `mount_apfs -s <snapshot> /System/Volumes/Data /mnt/snap` mounts read-only. Snapshots survive most user-driven deletions.
- **`/.fseventsd`** — FSEvents log; per-volume directory of gzipped change records (event type, inode, path). Parsers: **FSEventsParser** (G-C Partners), **mac_apt FSEvents plugin**.

**User activity ("Pattern of Life"):**
- **`KnowledgeC.db`** — `~/Library/Application Support/Knowledge/knowledgeC.db` (user) and `/private/var/db/CoreDuet/Knowledge/knowledgeC.db` (system). SQLite; tracks application focus, screen on/off, device lock/unlock, Siri suggestions, in-app activity. ~30 days retention.
- **Biome** — `~/Library/Biome/streams/public/` (macOS 12+/iOS 15+). Replaces parts of KnowledgeC; binary protobuf streams covering app intents, location pings, focus modes, AirDrop. Parse with **APOLLO**, **mac_apt**, or **iLEAPP** (cross-applies on iOS extractions).
- **Spotlight** — `/.Spotlight-V100/Store-V2/<UUID>/store.db` indexes file content metadata; survivable artifact for filenames even after deletion.
- **QuickLook thumbnails** — `~/Library/Application Support/Quicklook/` cached file previews — rich source for files no longer present.
- **Unified Logs (`.tracev3`)** — `/var/db/diagnostics/` and `/var/db/uuidtext/`. Replaces traditional syslog on macOS 10.12+. Live capture: `log show --predicate 'process == "loginwindow"' --style ndjson --start "2026-04-25 00:00:00"`. Offline parse: **UnifiedLogReader** (mandiant), **macos-UnifiedLogs** (mandiant Rust port), **mac_apt** unifiedlogs plugin.

**Persistence & execution:**
- **LaunchAgents / LaunchDaemons** — `/Library/LaunchAgents`, `/Library/LaunchDaemons`, `~/Library/LaunchAgents`, `/System/Library/LaunchDaemons` (SIP-protected, but malware uses the user-writable paths)
- **Login Items** — `~/Library/Application Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm` (modern); `loginwindow.plist` (legacy). The BTM database is the macOS Ventura+ replacement and is the single most important persistence artifact since 2022.
- **Configuration profiles** — `/Library/Managed Preferences/`, `/var/db/ConfigurationProfiles/` (MDM enrollment, policy, certs)
- **TCC database** — `/Library/Application Support/com.apple.TCC/TCC.db` (system) and `~/Library/Application Support/com.apple.TCC/TCC.db` (user); records consent for camera/mic/full-disk-access — useful for spotting malware that escalated to FDA.

**Tools:**
- **mac_apt** (Yogesh Khatri) — primary cross-artifact parser; outputs SQLite/Excel/CSV
- **APOLLO** (Sarah Edwards) — Pattern of Life timeline correlator
- **OSXCollector** (legacy Yelp) — live response collection [verify 2026-04-25]
- **AutoMacTC** — automated triage collection
- **iLEAPP** also handles macOS biome/KnowledgeC artifacts

### Linux Artifacts

**Logs:**
- **systemd-journald** — `/var/log/journal/<machine-id>/system.journal` (binary, indexed). Live: `journalctl --since "2026-04-25 00:00:00" --output=json`. Offline (image): `journalctl -D /mnt/image/var/log/journal --output=json --no-pager`. On systems with persistent journaling disabled, only `/run/log/journal` exists and is lost at reboot — check `Storage=` in `/etc/systemd/journald.conf`.
- **auditd / `audit.log`** — `/var/log/audit/audit.log`. Records syscalls, file access, login events when configured. Parse with `ausearch` / `aureport`. Default rule sets are sparse; investigators should look for organisation-specific rule additions.
- **Traditional syslog** — `/var/log/syslog`, `/var/log/messages`, `/var/log/auth.log`, `/var/log/secure`, `/var/log/wtmp`, `/var/log/btmp`, `/var/log/lastlog` (all standard via `last`, `lastb`, `who /var/log/wtmp`).

**Identity & install fingerprints:**
- **`/etc/machine-id`** — 32-char hex; persistent host identifier set on first boot. Critical for correlating logs and disk images to a specific install. Don't confuse with `/var/lib/dbus/machine-id` (often a symlink to it).
- **`/etc/hostname`, `/etc/hosts`, `/etc/resolv.conf`** — basic identity / network config
- **Package install history** — `/var/log/dpkg.log` (Debian/Ubuntu), `/var/log/apt/history.log`, `/var/log/yum.log` or `dnf.log` (RHEL/Fedora), `/var/log/pacman.log` (Arch), `/var/lib/rpm/Packages` (RPM DB)

**User activity:**
- **Shell histories** — `~/.bash_history`, `~/.zsh_history`, `~/.local/share/fish/fish_history`. Trivially editable; treat as supporting evidence only.
- **`~/.viminfo`, `~/.lesshst`, `~/.python_history`** — secondary activity traces frequently overlooked
- **`/var/log/wtmp`, `utmp`, `btmp`** — login records (binary; use `utmpdump`)
- **SSH** — `~/.ssh/authorized_keys`, `~/.ssh/known_hosts` (for host pivoting), `/var/log/auth.log` (sshd events)

**Persistence:**
- **systemd units** — `/etc/systemd/system/`, `/usr/lib/systemd/system/`, `~/.config/systemd/user/`; check `systemctl list-unit-files --state=enabled`
- **cron** — `/etc/crontab`, `/etc/cron.{d,daily,hourly,monthly,weekly}/`, `/var/spool/cron/crontabs/<user>`
- **Init scripts** — `/etc/init.d/`, `/etc/rc*.d/` (legacy SysV)
- **Profile / shell init** — `/etc/profile`, `/etc/profile.d/`, `~/.bashrc`, `~/.bash_profile`, `~/.zshrc`
- **LD_PRELOAD / `/etc/ld.so.preload`** — library-injection persistence
- **SUID binaries** — `find / -perm -4000 -type f 2>/dev/null` baseline diff against package manager-shipped expected list

**Filesystem snapshots (recovery & rollback):**
- **Btrfs** — `btrfs subvolume list /`, `btrfs subvolume snapshot -r <subvol> <name>`. Default on openSUSE (snapper-managed), Fedora 33+ workstation.
- **ZFS** — `zfs list -t snapshot`. Default on Ubuntu Server with ZFS-on-root; OpenZFS broadly.
- **LVM thin snapshots** — `lvs`, `lvdisplay`. Common for VM disk images and backup tooling.

**Tools:**
- **Linux Forensic Triage Kit** — community scripts collecting the artifact set above
- **UAC (Unix-like Artifacts Collector)** — vendor-neutral live-response collector
- **Velociraptor** — modern cross-platform live-response framework with Linux artifacts pack
- **chkrootkit / rkhunter / Lynis** — known-rootkit scans during triage

### Browser Artifacts

**Chrome/Edge (Chromium):**
```bash
# History location: AppData\Local\Google\Chrome\User Data\Default\History (SQLite)

# Query with SQLite
sqlite3 History "SELECT url, title, visit_count, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 100;"

# Downloads
sqlite3 History "SELECT target_path, start_time, end_time, total_bytes FROM downloads;"

# Using Hindsight (automated parser)
hindsight.py -i "/path/to/Chrome/Profile" -o /output
```

**Firefox:**
```bash
# History: AppData\Roaming\Mozilla\Firefox\Profiles\[profile]\places.sqlite

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
#   -r recursive folder structure   -D include deleted items   -cv per-message verbose output
readpst -r -D -cv -o /output file.pst

# pffexport (libpff, libyal) — preferred for forensics; better recovery and metadata preservation
pffexport -t /output -f all file.pst                    # all message items
pffexport -m all -t /output -f all file.pst             # include unallocated message recovery

# Outlook OST recovery — Kernel OST Viewer (commercial), SysTools, or libpff pffexport
```

**MBOX/EML Files:**
```bash
# Per-message extraction
formail -s procmail < archive.mbox                       # split MBOX into individual messages
python3 -c "import mailbox; [print(m['Subject']) for m in mailbox.mbox('archive.mbox')]"

# EML parsing (Python email library, mail-parser, or commercial: MailStore, aid4mail)
python3 -m mailparse parse evidence.eml --json > evidence.json
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
- **Look-alike domains** — punycode (`xn--`) homoglyphs, character substitutions (`rn` for `m`, `0` for `o`), TLD swaps. Run `dnstwist <victim-domain>` to enumerate likely candidates and check against the message domain.
- **Message-ID structure** — Microsoft 365 IDs end in `.prod.outlook.com` or `.outlook.com`; Google Workspace in `@mail.gmail.com`. A claimed Microsoft sender with a Google Message-ID is suspicious.
- **X-Originating-IP / Received chain** — first external hop's IP geolocation should be plausible for the claimed sender. Cross-reference with sign-in logs (Entra ID, Workspace) for the impersonated account.

**BEC investigation pivots:**
1. Pull the M365 UAL or Workspace audit log for the impersonated account around the email's timestamp — look for inbox-rule creation, mailbox-forwarding rule, OAuth grant, MFA failures, sign-ins from new ASNs.
2. Check `Set-InboxRule` / `New-InboxRule` events and existing forwarding rules — exfil-staging rules often hide messages by moving them to RSS Feeds / Conversation History.
3. Recover deleted items from the **Recoverable Items** folder (`Get-MailboxFolderStatistics -FolderScope RecoverableItems`); attackers commonly hard-delete the bait reply.
4. Hash and preserve the original `.eml` (or PST export) before any cleanup; record SHA-256 in chain of custody.

### Memory Analysis

> **Volatility 3 is the default.** Volatility 2 reached end-of-life upstream in 2020 and is no longer accepting plugin or profile contributions; use it only for legacy memory images that pre-date Volatility 3 symbol support. Volatility 3 fetches symbols on demand from the public symbol pack (or `--symbol-dirs <path>` for offline use) and replaces the manual `--profile=` step entirely. Current release: 2.x [verify 2026-04-25].

**Using Volatility 3 (current):**
```bash
# Install: pipx install volatility3   (CLI entrypoint is `vol`; `vol.py` works on source checkouts)
# OS / build identification
vol -f memory.dmp windows.info
vol -f memory.dmp linux.banner          # Linux equivalent
vol -f memory.dmp mac.kevents           # macOS plugins are limited compared to Windows

# Process tree and command line
vol -f memory.dmp windows.pslist
vol -f memory.dmp windows.pstree
vol -f memory.dmp windows.cmdline
vol -f memory.dmp windows.psscan        # carve EPROCESS structures (catches hidden/exited)

# Network connections (Windows 7+)
vol -f memory.dmp windows.netscan
vol -f memory.dmp windows.netstat

# Loaded modules / DLLs
vol -f memory.dmp windows.dlllist --pid <PID>
vol -f memory.dmp windows.modules
vol -f memory.dmp windows.modscan       # carve module structures

# Dump process memory / executable / DLL
vol -f memory.dmp windows.memmap --pid <PID> --dump
vol -f memory.dmp windows.dumpfiles --pid <PID>
vol -f memory.dmp windows.pslist --dump

# Registry hives loaded in RAM
vol -f memory.dmp windows.registry.hivelist
vol -f memory.dmp windows.registry.printkey --offset <hive-offset> --key 'Software\Microsoft\Windows\CurrentVersion\Run'

# Code-injection / malicious-region detection
vol -f memory.dmp windows.malfind                           # RWX private regions, suspicious headers
vol -f memory.dmp windows.hollowprocesses                   # process hollowing
vol -f memory.dmp windows.ssdt                              # SSDT hooks
vol -f memory.dmp windows.callbacks                         # kernel callbacks (rootkit indicator)

# Credential material in memory (paired with Mimikatz-style offline parsers)
vol -f memory.dmp windows.hashdump
vol -f memory.dmp windows.lsadump
vol -f memory.dmp windows.cachedump

# Linux
vol -f memory.lime linux.pslist
vol -f memory.lime linux.bash           # recovers shell history from heap
vol -f memory.lime linux.check_modules  # rootkit detection
```

**Using Volatility 2 (legacy / pre-2020 images only):**
```bash
# Volatility 2 is unmaintained — only use it when V3 lacks symbols for the target build
volatility -f memory.dmp imageinfo
volatility -f memory.dmp --profile=Win10x64_19041 pslist
```

**Companion tools:**
- **MemProcFS** ([github.com/ufrisk/MemProcFS](https://github.com/ufrisk/MemProcFS)) — mounts a memory image as a virtual filesystem; complementary to Volatility for fast triage
- **bulk_extractor** — IOC carving (URLs, emails, credit cards) from raw memory or disk
- **YARA** — run rule sets directly against memory images (`vol -f mem.dmp yarascan.YaraScan --yara-rules malware.yar`)

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
- **CAPEv2** ([github.com/kevoreilly/CAPEv2](https://github.com/kevoreilly/CAPEv2)) — modern, actively maintained Cuckoo fork with config + payload extraction; preferred local sandbox
- **ANY.RUN** — interactive cloud sandbox (Pro tier offers private submissions)
- **Joe Sandbox** — cloud or on-prem; private mode available
- **Triage (Hatching)** — fast cloud sandbox, free + paid tiers
- **Hybrid Analysis (Falcon Sandbox)** — community + paid
- **Cuckoo Sandbox** (original) — largely abandoned upstream; CAPE is the active successor

### Anti-Forensic Awareness

Modern attackers actively suppress the artifact set above. Treat the *absence* of expected artifacts as a finding, not a clean bill of health.

**Common evasion techniques that distort or remove forensic evidence** (see [[sop-malware-analysis|Malware Analysis SOP]] §10.4 for the offensive perspective):

| Technique | What it breaks | What still survives |
|---|---|---|
| **ETW patching** (`EtwEventWrite` prologue → `ret 0xC3`) | Sysmon, EDR, PowerShell ScriptBlockLogging, AMSI events for the patched process | Other processes; kernel callbacks; network captures; memory image of the patched process (the patch itself is visible in RAM) |
| **AMSI bypass** (patch `AmsiScanBuffer` to return `S_OK` with `AMSI_RESULT_CLEAN=0`, or `E_INVALIDARG`) | AV/EDR script content scanning; `Defender` script telemetry | PowerShell module/transcript logging; ScriptBlock logging if loaded before patch; memory dump |
| **Direct syscalls / Hell's Gate / Halo's Gate / Tartarus Gate** | EDR userland hooks on `ntdll.dll` exports | Kernel ETW-Ti (`Microsoft-Windows-Threat-Intelligence`) on PatchGuard-protected systems; memory; network |
| **PPID spoofing** (`UpdateProcThreadAttribute` → `PROC_THREAD_ATTRIBUTE_PARENT_PROCESS`) | Process-tree heuristics that flag implausible parent-child pairs | Sysmon Event ID 1 logs the *real* creator PID alongside the spoofed parent; ETW-Ti |
| **Module stomping / DLL hollowing** | Module-name signature heuristics; trusts because module is signed | `.text` section hash mismatch vs. on-disk file; memory image; `pe-sieve` / `hollows_hunter` flag the divergence |
| **Timestomping** (`SetFileTime`, `$STANDARD_INFORMATION` rewrite) | Filesystem MAC-time timelines | `$FILE_NAME` MFT attribute (a second timestamp set, often missed by attackers); USN journal; AmCache; ShimCache; PCA |
| **Log clearing** (Event Log, journald, audit.log truncation) | The cleared log itself | Backup forwarders (SIEM, syslog server); Event ID 1102 (Security log cleared) survives in subsequent log; carved log fragments from unallocated; memory; network |
| **Recycle Bin / shadow copy deletion** (`vssadmin delete shadows`) | VSS-based file recovery | NTFS journal, USN; backups outside the host |
| **Living-off-the-land** (`certutil`, `bitsadmin`, `mshta`, `rundll32`, `regsvr32`, `wmic`) | Signature-based AV; defender heuristics that whitelist signed Microsoft binaries | Command-line logging (4688 + ProcessCreationIncludeCmdLine), Sysmon Event ID 1, PCA, AmCache |

**Investigative implication:** when the obvious artifact is missing, look one layer down — `$FILE_NAME` over `$STANDARD_INFORMATION`, AmCache over Prefetch, USN journal over Recycle Bin, Sysmon Event ID 1 over Security 4688, network captures over endpoint telemetry, memory images over disk.

### Keyword Searching

**Using Autopsy:**
```
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
```
Evidence ID | Description | Collection Date | Custodian | Hash (SHA-256)
CASE-001    | Dell Laptop | 2025-10-05 UTC  | J. Smith  | abc123...
CASE-002    | USB Drive   | 2025-10-05 UTC  | J. Smith  | def456...
```

**4. Methodology**
- Forensic tools used (name, version, vendor)
- Analysis procedures followed
- Standards/frameworks referenced (NIST SP 800-86, ISO 27037)
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
> Quick refanging for analyst use (do not include in deliverables): `sed -e 's/hxxp/http/g; s/\[\.\]/./g; s/\[@\]/@/g'`. Re-fanging utilities in CyberChef ("Defang URL" / "Refang URL" recipes) cover edge cases.

**6. Timeline of Events**
```
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
```
Physical Security:
- Locked evidence room with access control
- Climate-controlled (15-25°C, 30-50% humidity)
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
- **Closed Cases**: Follow organizational policy (typically 3-7 years)
- **Legal Proceedings**: Retain until final adjudication + appeal period
- **Secure Disposal**: DoD 5220.22-M wipe or physical destruction with certificate

---

## 7. Tools Reference

| Tool | Purpose | Platform | Link |
|------|---------|----------|------|
| **Acquisition — disk** |
| FTK Imager | Disk imaging, memory capture | Windows | [exterro.com/ftk-imager](https://www.exterro.com/ftk-imager) (formerly AccessData) |
| dc3dd | Forensic dd with built-in hashing | Linux | [sourceforge.net/projects/dc3dd](https://sourceforge.net/projects/dc3dd/) |
| Guymager | Disk imaging (GUI) | Linux | `apt install guymager` |
| ewfacquire (libewf) | E01/EWF imaging with hash verification | Multi | [github.com/libyal/libewf](https://github.com/libyal/libewf) |
| **Acquisition — memory** |
| AVML | Linux RAM acquisition (static, no kmod) | Linux | [github.com/microsoft/avml](https://github.com/microsoft/avml) |
| LiME | Linux Memory Extractor (kernel module) | Linux | [github.com/504ensicsLabs/LiME](https://github.com/504ensicsLabs/LiME) |
| WinPmem / DumpIt / Magnet RAM Capture | Windows RAM acquisition | Windows | [github.com/Velocidex/WinPmem](https://github.com/Velocidex/WinPmem) |
| Volexity Surge Collect Pro | Cross-platform commercial RAM capture (incl. Apple Silicon) | Multi | [volexity.com](https://www.volexity.com) [verify 2026-04-25] |
| **Live response & triage** |
| KAPE | Targeted artifact collection + parsing | Windows | [kape.gerardalattanzio.com](https://www.kroll.com/en/services/cyber/incident-response-litigation-support/kroll-artifact-parser-extractor-kape) |
| Velociraptor | Cross-platform live response & hunting | Multi | [docs.velociraptor.app](https://docs.velociraptor.app/) |
| UAC | Unix-like artifacts collector | Linux/macOS/AIX/Solaris | [github.com/tclahr/uac](https://github.com/tclahr/uac) |
| **Analysis** |
| Autopsy / Sleuth Kit | Digital forensics platform + CLI | Multi | [sleuthkit.org](https://www.sleuthkit.org) |
| X-Ways Forensics | Commercial forensics suite | Windows | [x-ways.net](https://www.x-ways.net) |
| EZ Tools (MFTECmd, EvtxECmd, RECmd, AmcacheParser, AppCompatCacheParser, JLECmd, LECmd, RBCmd, PECmd) | Targeted artifact parsers | Windows / .NET | [ericzimmerman.github.io](https://ericzimmerman.github.io) |
| MemProcFS | Mount memory image as filesystem | Multi | [github.com/ufrisk/MemProcFS](https://github.com/ufrisk/MemProcFS) |
| **Memory** |
| Volatility 3 | Memory analysis (current) | Multi | [github.com/volatilityfoundation/volatility3](https://github.com/volatilityfoundation/volatility3) |
| Volatility 2 | Memory analysis (legacy, EOL 2020) | Multi | [github.com/volatilityfoundation/volatility](https://github.com/volatilityfoundation/volatility) |
| Rekall | Memory forensics (unmaintained since 2017) | Multi | [github.com/google/rekall](https://github.com/google/rekall) |
| **Registry** |
| RegRipper3.0 | Windows Registry parser | Multi | [github.com/keydet89/RegRipper3.0](https://github.com/keydet89/RegRipper3.0) |
| Registry Explorer / RECmd | Registry viewer (GUI/CLI) | Windows | [ericzimmerman.github.io](https://ericzimmerman.github.io) |
| **Event logs** |
| Hayabusa | Sigma-driven EVTX timeline | Multi | [github.com/Yamato-Security/hayabusa](https://github.com/Yamato-Security/hayabusa) |
| Chainsaw | Fast EVTX hunting with Sigma | Multi | [github.com/WithSecureLabs/chainsaw](https://github.com/WithSecureLabs/chainsaw) |
| **Timeline** |
| log2timeline / Plaso | Super timeline creation | Multi | [github.com/log2timeline/plaso](https://github.com/log2timeline/plaso) |
| Timesketch | Timeline analysis platform | Multi | [github.com/google/timesketch](https://github.com/google/timesketch) |
| **Mobile / iOS / Android** |
| Cellebrite UFED / Inseyets | Mobile extraction (LE-grade) | Windows | [cellebrite.com](https://www.cellebrite.com) |
| Magnet AXIOM | Mobile / computer / cloud forensics | Windows | [magnetforensics.com](https://www.magnetforensics.com) |
| MSAB XRY | LE-grade mobile extraction | Windows | [msab.com](https://www.msab.com) |
| Oxygen Forensic Detective | Broad app coverage incl. messengers | Windows | [oxygenforensics.com](https://www.oxygenforensics.com) |
| iLEAPP / ALEAPP | Open-source iOS / Android artifact parser | Multi (Python) | [github.com/abrignoni/iLEAPP](https://github.com/abrignoni/iLEAPP) |
| MVT | Spyware / IOC scan for mobile | Multi (Python) | [mvt.re](https://mvt.re) |
| **macOS** |
| mac_apt | macOS / iOS artifact parser | Multi (Python) | [github.com/ydkhatri/mac_apt](https://github.com/ydkhatri/mac_apt) |
| APOLLO | Apple Pattern of Life timeline | Multi (Python) | [github.com/mac4n6/APOLLO](https://github.com/mac4n6/APOLLO) |
| UnifiedLogReader / macos-UnifiedLogs | Parse `.tracev3` unified logs offline | Multi | [github.com/mandiant/macos-UnifiedLogs](https://github.com/mandiant/macos-UnifiedLogs) |
| **Network** |
| Wireshark | Packet analysis | Multi | [wireshark.org](https://www.wireshark.org) |
| NetworkMiner | PCAP analysis (file/credential carving) | Multi | [netresec.com](https://www.netresec.com) |
| Zeek | Network metadata + protocol logs | Multi | [zeek.org](https://zeek.org) |
| **Cloud** |
| AWS CLI / Athena | CloudTrail / S3 audit pull and SQL query | Multi | [aws.amazon.com/cli](https://aws.amazon.com/cli/) |
| Azure CLI / Microsoft Graph PowerShell | Activity Log, Entra ID, M365 UAL | Multi | [learn.microsoft.com/cli/azure](https://learn.microsoft.com/cli/azure/) |
| gcloud / Workspace Reports API | GCP audit + Workspace audit | Multi | [cloud.google.com/sdk](https://cloud.google.com/sdk) |
| **Process / system** |
| System Informer | Process / handle / module inspection (formerly Process Hacker) | Windows | [github.com/winsiderss/systeminformer](https://github.com/winsiderss/systeminformer) |
| Process Monitor / Process Explorer | Live procmon / process tree | Windows | [Sysinternals](https://learn.microsoft.com/sysinternals/) |
| Sysmon | Endpoint event telemetry | Windows | [Sysinternals](https://learn.microsoft.com/sysinternals/downloads/sysmon) |

---

## 8. Legal & Quality Assurance

### Admissibility (Court Standards)

**Daubert Standard (US Federal):**
- [ ] Methodology is scientifically valid
- [ ] Technique has been peer reviewed
- [ ] Known error rate is acceptable
- [ ] Methodology is generally accepted in field

**Chain of Custody Requirements:**
- Continuous accountability from collection → court
- Documentation of every transfer
- Ability to demonstrate evidence integrity (hashes)
- Explanation of any gaps or anomalies

**Expert Witness Preparation:**
- Curriculum vitae (education, training, certifications)
- Prior testimony experience
- Case-specific preparation (review all notes, reports)
- Mock cross-examination practice

### Standards & Certifications

**Industry Standards:**
- **NIST SP 800-86**: Guide to Integrating Forensic Techniques into Incident Response
- **ISO/IEC 27037**: Guidelines for identification, collection, and preservation
- **ACPO Good Practice Guide**: UK digital evidence principles
- **SWGDE**: Scientific Working Group on Digital Evidence

**Professional Certifications:**
- **GCFE**: GIAC Certified Forensic Examiner
- **EnCE**: EnCase Certified Examiner
- **CFCE**: Certified Forensic Computer Examiner
- **CCE**: Certified Computer Examiner (ISFCE)
- **CHFI**: Computer Hacking Forensic Investigator

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
- [ ] Generate SHA-256 hash (primary); MD5/SHA-1 secondary for legacy NSRL/AV lookups only
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
**Last Updated:** 2026-04-25
**Review Frequency:** Quarterly (cloud, mobile-vendor, and Volatility ecosystems rot fastest)