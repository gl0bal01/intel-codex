---
type: sop
title: Digital Forensics Investigation SOP
description: "Conduct digital forensics: disk imaging, memory analysis, artifact recovery, timeline creation & chain of custody. Tools: FTK, Autopsy, Volatility."
tags: [sop, forensics, incident-response, dfir, investigation]
template_version: 2025-10-05
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
# Using LiME (Linux Memory Extractor)
insmod lime.ko "path=/mnt/usb/memory.lime format=lime"

# Using AVML (Microsoft Azure VM Memory Acquisition)
./avml memory.lime

# Using dd (if /dev/mem accessible - not recommended on modern systems)
dd if=/dev/mem of=/mnt/usb/memory.dd bs=1M
```

**macOS:**
```bash
# Using OSXPMem
sudo osxpmem.app/osxpmem -o memory.aff4

# Using Rekall
sudo rekal mem_dump -o memory.raw
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

# Wipe source verification (sanity check - read only)
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

**Generate hashes:**
```bash
# MD5 (legacy, still used for verification)
md5sum case001-disk.dd > case001-disk.dd.md5

# SHA-1
sha1sum case001-disk.dd > case001-disk.dd.sha1

# SHA-256 (recommended)
sha256sum case001-disk.dd > case001-disk.dd.sha256

# Verify later
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

**Preparation:**
```bash
# Immediate isolation
1. Place device in Faraday bag (blocks cellular/Wi-Fi signals)
2. If device is on: enable airplane mode FIRST
3. Document battery level
4. Photograph device (all sides, screen contents)
5. Note any passwords/PINs (with user consent)
6. Keep device powered on if possible (avoid lock screen issues)
```

**Acquisition Methods:**

**Logical Acquisition:**
- Extracts active files and data
- Requires device cooperation (unlocked, authorized backup)
- Tools: iTunes backup (iOS), Android Debug Bridge (ADB)

```bash
# iOS logical backup
idevicebackup2 backup --full /path/to/backup

# Android ADB logical acquisition
adb devices
adb backup -all -apk -shared -system -f backup.ab
```

**Physical Acquisition:**
- Bit-for-bit copy of device storage
- Recovers deleted data
- Requires specialized tools

**Tools:**
- **Cellebrite UFED**: Physical/logical extraction, cloud data
- **Magnet AXIOM**: Mobile forensics, cloud extraction
- **Oxygen Forensics**: iOS/Android, app data extraction
- **XRY (MSAB)**: Law enforcement grade extraction

**Cloud & SIM Card:**
```bash
# SIM card reader acquisition
# Use specialized SIM card readers (e.g., Cellebrite SIM Card Reader)

# Cloud data preservation
# Legal process required for:
# - iCloud (Apple)
# - Google Account (Gmail, Drive, Photos)
# - Microsoft OneDrive
# - Dropbox, etc.
```

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

# NTFS $MFT parsing
analyzeMFT.py -f $MFT -o mft_timeline.csv
```

### Timeline Construction

**Using log2timeline/Plaso:**
```bash
# Create supertimeline from image
log2timeline.py --storage-file timeline.plaso image.dd

# Parse timeline to CSV
psort.py -o l2tcsv -w timeline.csv timeline.plaso

# Filter by date range
psort.py -o l2tcsv -w filtered.csv timeline.plaso "date > '2025-10-01' AND date < '2025-10-06'"

# Filter by user
psort.py -o l2tcsv -w user_timeline.csv timeline.plaso "username contains 'johndoe'"
```

**Manual Timeline (Mac Times):**
```bash
# Using Sleuth Kit's mactime
fls -m C: -r image.dd > bodyfile.txt
mactime -b bodyfile.txt -d > timeline.csv
```

**Timeline Analysis Tools:**
- **Timesketch**: Web-based collaborative timeline analysis
- **Excel/Sheets**: Manual pivoting and filtering
- **Timeline Explorer**: Eric Zimmerman's tool (Windows)

### Registry Analysis (Windows)

**Extract Registry Hives:**
```bash
# Hive locations:
# C:\Windows\System32\config\SAM
# C:\Windows\System32\config\SECURITY
# C:\Windows\System32\config\SOFTWARE
# C:\Windows\System32\config\SYSTEM
# C:\Users\[username]\NTUSER.DAT

# Export with FTK Imager or:
icat image.dd [inode_of_SAM] > SAM
icat image.dd [inode_of_SYSTEM] > SYSTEM
```

**Registry Analysis:**
```bash
# Using RegRipper
rip.pl -r SAM -p sam > sam_output.txt
rip.pl -r SYSTEM -p system > system_output.txt
rip.pl -r SOFTWARE -p software > software_output.txt
rip.pl -r NTUSER.DAT -p ntuser > ntuser_output.txt

# Key artifacts:
# - USB device history: SYSTEM\CurrentControlSet\Enum\USBSTOR
# - User assist (program execution): NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist
# - Shimcache (program execution): SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache
# - Run keys (persistence): SOFTWARE\Microsoft\Windows\CurrentVersion\Run
```

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
# Use Kernel OST Viewer, SysTools, or:
readpst -r -D -cv -o /output file.pst

# Metadata extraction
# - From/To addresses
# - Subject lines
# - Timestamps
# - Attachments (extract and hash)
# - Headers (IP addresses of mail servers)
```

**MBOX/EML Files:**
```bash
# Parse with Python/email library or tools like:
# - Thunderbird (import MBOX)
# - MailStore Home
# - aid4mail
```

### Memory Analysis

**Using Volatility 3:**
```bash
# Identify OS profile
vol.py -f memory.dmp windows.info

# List processes
vol.py -f memory.dmp windows.pslist
vol.py -f memory.dmp windows.pstree  # Tree view

# Network connections
vol.py -f memory.dmp windows.netscan

# Command line arguments
vol.py -f memory.dmp windows.cmdline

# DLLs loaded by process
vol.py -f memory.dmp windows.dlllist --pid [PID]

# Dump process memory
vol.py -f memory.dmp windows.memmap --pid [PID] --dump

# Registry hives in memory
vol.py -f memory.dmp windows.registry.hivelist

# Malware detection
vol.py -f memory.dmp windows.malfind
```

**Using Volatility 2 (legacy):**
```bash
# Identify profile
volatility -f memory.dmp imageinfo

# Use profile for subsequent commands
volatility -f memory.dmp --profile=Win10x64_19041 pslist
```

### Malware Analysis (Basic Triage)

**Static Analysis:**
```bash
# File hash check (VirusTotal, malware databases)
sha256sum malware.exe

# Strings analysis
strings malware.exe > strings_output.txt
strings -el malware.exe >> strings_output.txt  # Unicode

# PE file analysis
peframe malware.exe
pev malware.exe
```

**Behavioral Indicators:**
```bash
# Check for:
- Packed/obfuscated executables (UPX, Themida)
- Suspicious imports (VirtualAlloc, CreateRemoteThread)
- Embedded IPs/domains in strings
- Anti-debugging/anti-VM techniques
- Code signing (lack of or invalid signature)
```

**Sandbox Analysis (Safe Environment Only):**
- **Cuckoo Sandbox**: Automated malware analysis
- **ANY.RUN**: Interactive online sandbox
- **Joe Sandbox**: Cloud-based analysis

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
| **Acquisition** |
| FTK Imager | Disk imaging, memory capture | Windows | [AccessData](https://accessdata.com) |
| dd / dc3dd | Disk imaging (CLI) | Linux | Built-in / [dc3dd](https://sourceforge.net/projects/dc3dd/) |
| Guymager | Disk imaging (GUI) | Linux | `apt install guymager` |
| **Analysis** |
| Autopsy | Digital forensics platform | Multi | [sleuthkit.org/autopsy](https://www.sleuthkit.org/autopsy/) |
| Sleuth Kit | CLI forensics tools | Multi | [sleuthkit.org](https://www.sleuthkit.org) |
| X-Ways Forensics | Commercial forensics suite | Windows | [x-ways.net](https://www.x-ways.net) |
| **Memory** |
| Volatility 3 | Memory analysis | Multi | [github.com/volatilityfoundation/volatility3](https://github.com/volatilityfoundation/volatility3) |
| Rekall | Memory forensics | Multi | [github.com/google/rekall](https://github.com/google/rekall) |
| **Registry** |
| RegRipper | Windows Registry parser | Multi | [github.com/keydet89/RegRipper3.0](https://github.com/keydet89/RegRipper3.0) |
| Registry Explorer | Registry viewer (GUI) | Windows | [Eric Zimmerman Tools](https://ericzimmerman.github.io) |
| **Timeline** |
| log2timeline/Plaso | Super timeline creation | Multi | [github.com/log2timeline/plaso](https://github.com/log2timeline/plaso) |
| Timesketch | Timeline analysis platform | Multi | [github.com/google/timesketch](https://github.com/google/timesketch) |
| **Mobile** |
| Cellebrite UFED | Mobile extraction | Multi | [cellebrite.com](https://www.cellebrite.com) |
| Magnet AXIOM | Mobile/computer forensics | Windows | [magnetforensics.com](https://www.magnetforensics.com) |
| **Network** |
| Wireshark | Packet analysis | Multi | [wireshark.org](https://www.wireshark.org) |
| NetworkMiner | PCAP analysis | Windows/Linux | [netresec.com](https://www.netresec.com) |

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
- [ ] Generate hash values (MD5, SHA-256)
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